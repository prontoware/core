////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// HVM Memory Profiler
////////////////////////////////////////////////////////////////////////////////////////////////////
/*
bool __HVM_MEMORY_PROFILER_INSESSION; // Are we actively monitoring memory allocations / deallocations?

// "HVM" stands for Hybrid Virtual Machine. 
class HVM
{
    // Start memory allocation monitoring. Returns false if unable to run profiling (unsupported or disabled by HVM).
    bool startMemoryProfiling()
    {
        __HVM_MEMORY_PROFILER_INSESSION = startMemoryProfiling_native();
        return __HVM_MEMORY_PROFILER_INSESSION;
    }

    // Stop memory allocation monitoring. Returns false if memory profiler unsupported or not in-use.
    bool stopMemoryProfiling()
    {
        __HVM_MEMORY_PROFILER_INSESSION = false;
        return stopMemoryProfiling_native();
    }
}*/

////////////////////////////////////////////////////////////////////////////////////////////////////
// Heap Allocator Functions Override - LOW MEMORY OVERHEAD ALLOCATOR
////////////////////////////////////////////////////////////////////////////////////////////////////
/*
// This is the default allocator for Pronto-Core. It has no meaningful memory overhead. It has a 
// small number of fixed block tracking (16 to 256 bytes, in increments of 16 bytes). The rest of
// the free blocks (larger than 256 bytes) are stored in a general list.
//
// Free blocks store their own size and a pointer to the next free block (if any) in the first 16 
// bytes of the block (size first 8 bytes, pointer next 8). This means we maintain 17 a singlely 
// linked-lists of free blocks total.

// Object/Array memory layout
const u64 __PRONTO_OBJ_HEADER_SIZE      =  16; // 16 bytes for arrays/objects
const u64 __PRONTO_OBJ_REFCOUNT_OFFSET  =  4;  // -4 from object base address, u32
const u64 __PRONTO_OBJ_CTABLE_OFFSET    =  8;  // -8 from object base address, u32 (offset from SHARED start address)
const u64 __PRONTO_ARR_NUM_ELEM_OFFSET  =  16; // -16 from object base address, u64
const u64 __PRONTO_HEAP_ALIGN           =  16; // always 16 bytes for heap blocks.
const u64 __PHEAP_MAX_BLOCK_FIXED_SIZE  = 256;

// Class meta table layout
const u64 __CTABLE_NAMESPACE_OFFSET     = 0;   // MAX_NAME_LEN
const u64 __CTABLE_CLASSNAME_OFFSET     = 64;  // MAX_NAME_LEN
const u64 __CTABLE_CLASS_SIZE_OFFSET    = 128; // MAX_NAME_LEN:class name comes first, then u32:byteSizeOfClassInst, eats 4 bytes for alignment purposes
const u64 __CTABLE_ARRAY_ELEM_TYPE      = 132; // U8+U8 Pype : type ID + U8 numVecElem one of TYPE_BADVAL (for not array), TYPE_U8 etc., eats 4 bytes for alignment purposes
const u64 __CTABLE_NUM_OBJ_PROPS        = 136; // U16 class obj properties memory offsets (for deallocObj() etc), appear after virtual function mappings as U16s
const u64 __CTABLE_NUM_MAPPINGS         = 144; // U16 num method mappings, eats 8 bytes for alignment purposes
const u64 __CTABLE_HEADER_SIZE          = 152; // MAX_NAME_LEN bytes for namespace, MAX_NAME_LEN bytes for classname, 8 bytes for class instance size, 8 bytes for num entries in method table
const u64 __CTABLE_ENTRY_SIZE           = 16;  // u64:funcID + u64:

u8[16] TYPE_BYTE_SIZES = u8( 0, 0, 1, 1, 2, 2, 4, 4, 8, 8, 4, 8, 8, 0, 0, 0 ); // TYPE_U8, TYPE_I8, ... TYPE_F64 etc.

u64  __PHEAP_START; // DO NOT INITILIZE THESE HERE! They will be initialized to zero automatically before __INIT() is called, but __setupHeapAllocator() is called *before* __INIT()
u64  __PHEAP_SIZE;
u64  __PHEAP_USED_SIZE;
u64  __PSHARED_PTR; // base of shared memory pointer, used for class tables

// Lists for various sized heap chunks. This is the fragementation / reclamation info
const u64 __PHEAP_NUM_16B_LISTS = 16;
u64[16] __PHEAP_16B_LISTS;  // multiple of 16 bytes size, first bucket is 16 byte blocks, second is 32 byte blocks, ... 256 bytes last bucket
u64     __PHEAP_MIXED_LIST; // various sized blocks larger than 256 bytes (but all multiples of 16)
u64     __PHEAP_MIXED_LAST; // last block in mixed list, we add to the back in order to maximize the first-run thru performance of the heap memory

// This gets called before __INIT(), no globals are initialized. Return zero to indicate not using custom allocator
// (using HVM native one). Any positive value indicates the amount of fixed memory used for the heap allocator etc. from heap start.
bool __setupHeapAllocator(u64 heapStart, u64 heapSize, u64 sharedMemPtr, bool startWithMemoryProfilingActive)
{
    __PHEAP_START = heapStart;
    __PHEAP_SIZE  = heapSize;
    __PSHARED_PTR = sharedMemPtr;
    __HVM_MEMORY_PROFILER_INSESSION = startWithMemoryProfilingActive;

    // fixed-size lists start empty
    for(u64 p=0; p<__PHEAP_NUM_16B_LISTS; p++)
    {
        __PHEAP_16B_LISTS[p] = 0;
    }

    // mixed list starts with entire heap block
    __PHEAP_MIXED_LIST = heapStart;
    __PHEAP_MIXED_LAST = heapStart;
    writeRawU64_native(__PHEAP_MIXED_LIST + 0, heapSize);
    writeRawU64_native(__PHEAP_MIXED_LIST + 8, 0); // last (only) block in list to start

    return true; // we are doing a pronto-based allocator, no HVM one required.
}

// Reset free heap blocks. We clear all existing free blocks.
void __resetFreeBlocks(u64 newHeapUsed)
{
    // fixed-size lists empty
    for(u64 p=0; p<__PHEAP_NUM_16B_LISTS; p++)
    {
        __PHEAP_16B_LISTS[p] = 0;
    }

    __PHEAP_MIXED_LIST = 0;
    __PHEAP_MIXED_LAST = 0;
    __PHEAP_USED_SIZE = newHeapUsed;
}

// Add free heap blocks. blockAddrs + blockSizes is up to 16 pairs specifying block addr start + size. May not all be used (addr=0).
void __addFreeBlocks(u64[16] blockAddrs, u64[16] blockSizes)
{
    // insert new free blocks to lists
    for(u8 i=0; i<16; i++)
    {
        u64 blockAddr = blockAddrs[i];
        u64 blockSize = blockSizes[i];

        if(blockAddr == 0 || blockSize == 0)
            continue;

        // zero out block so it's ready for use
        u64 numBytesDiv8 = blockSize >> 3; // divide by 8
        u64 zeroPtr = blockAddr;
        for(u64 b=0; b<numBytesDiv8; b++)
        {
            writeRawU64_native(zeroPtr, 0);
            zeroPtr += 8;
        }

        // check for existing perfect sized fixed block?
        if(blockSize <= __PHEAP_MAX_BLOCK_FIXED_SIZE)
        {
            u64 index16 = (blockSize >> 4) - 1; // divide by 16

            // add this block to front of list (which also has cache-hit advantages when reused)
            // we don't write size for fixed size blocks because it's implied! AKA writeRawU64_native(blockAddr + 0, blockSize);
            writeRawU64_native(blockAddr + 8, __PHEAP_16B_LISTS[index16]);

            __PHEAP_16B_LISTS[index16] = blockAddr;
        }
        else
        {
            // write block size into block
            writeRawU64_native(blockAddr + 0, blockSize);

            if(__PHEAP_MIXED_LIST == 0)
            {
                __PHEAP_MIXED_LIST = blockAddr;
                __PHEAP_MIXED_LAST = blockAddr;
            }
            else
            {
                // add this block to back of mixed list
                writeRawU64_native(__PHEAP_MIXED_LAST + 8, blockAddr);
                __PHEAP_MIXED_LAST = blockAddr;
            }
        }
    }
}

// Callback from C++ land
u64 __allocateMemory(u64 numBytes, u64 instAddr)
{
    // must be aligned size
    if(numBytes <= __PRONTO_HEAP_ALIGN)
    {
        numBytes = __PRONTO_HEAP_ALIGN;
    }
    else
    {
        u64 remainder = numBytes % __PRONTO_HEAP_ALIGN;
        if(remainder != 0)
        {
            numBytes += __PRONTO_HEAP_ALIGN - remainder;
        }
    }

    __PHEAP_USED_SIZE += numBytes;

    // check for existing perfect sized fixed block?
    if(numBytes <= __PHEAP_MAX_BLOCK_FIXED_SIZE)
    {
        u64 index16 = (numBytes >> 4) - 1;  // divide by 16
        u64 firstBlockPtr = __PHEAP_16B_LISTS[index16];
        if(firstBlockPtr != 0)
        {
            __PHEAP_16B_LISTS[index16] = readRawU64_native(firstBlockPtr + 8); // remove first block from list, point to next block (which could be null)

            // zero-out bytes we used to store list link
            writeRawU64_native(firstBlockPtr + 8, 0); // rest of block bytes should be zero

            if(__HVM_MEMORY_PROFILER_INSESSION == true)
            {
                __reportHeapAlloc_native(instAddr, firstBlockPtr, numBytes);
            }

            return firstBlockPtr;
        }
    }

    // check mixed blocks, first fit
    u64 prevBlockPtr = 0;
    u64 thisBlockPtr = __PHEAP_MIXED_LIST;
    while(thisBlockPtr != 0)
    {
        u64 thisBlockSize = readRawU64_native(thisBlockPtr + 0);
        u64 nextBlockPtr  = readRawU64_native(thisBlockPtr + 8);

        if(numBytes < thisBlockSize)
        {
            // eat the end of this block so we don't have to update anything other than size
            u64 newBlockSize = thisBlockSize - numBytes;
            u64 retBlockPtr  = (thisBlockPtr + thisBlockSize) - numBytes;

            writeRawU64_native(thisBlockPtr + 0, newBlockSize);

            if(__HVM_MEMORY_PROFILER_INSESSION == true)
            {
                __reportHeapAlloc_native(instAddr, retBlockPtr, numBytes);
            }

            return retBlockPtr;
        }
        else if(numBytes == thisBlockSize)
        {
            // remove this block from list, linking previous block to next
            if(prevBlockPtr == 0)
            {
                // first block in list
                __PHEAP_MIXED_LIST = nextBlockPtr;
            }
            else
            {
                writeRawU64_native(prevBlockPtr + 8, nextBlockPtr);
            }

            // zero-out bytes we used to store list link and block size, other bytes should be zero
            writeRawU64_native(thisBlockPtr + 0, 0);
            writeRawU64_native(thisBlockPtr + 8, 0);

            if(__PHEAP_MIXED_LAST == thisBlockPtr)
            {
                __PHEAP_MIXED_LAST = prevBlockPtr;
            }

            if(__HVM_MEMORY_PROFILER_INSESSION == true)
            {
                __reportHeapAlloc_native(instAddr, thisBlockPtr, numBytes);
            }

            return thisBlockPtr;
        }

        // else go to next block
        prevBlockPtr = thisBlockPtr;
        thisBlockPtr = nextBlockPtr;
    }
    
    //Log:log("ERROR OUT OF HEAP MEMORY!");
    //Log:log("Heap size: "); Log:log(__PHEAP_SIZE);
    //Log:log("Heap used size: "); Log:log(__PHEAP_USED_SIZE);
    //Log:log("__PHEAP_MIXED_LIST: "); Log:log(__PHEAP_MIXED_LIST);
    //if(__PHEAP_MIXED_LIST != 0)
    //{
    //    Log:log("__PHEAP_MIXED_LIST[0] size: "); Log:log(readRawU64_native(__PHEAP_MIXED_LIST));
    //}

    // if we get all the way here, we need to try running the Garbage Collector to free some memory not normally claimable by reference counting (i.e. circular references)
    HVM:runGC();

    // try allocation again...

    // check for existing perfect sized fixed block?
    if(numBytes <= __PHEAP_MAX_BLOCK_FIXED_SIZE)
    {
        u64 index16 = (numBytes >> 4) - 1;  // divide by 16
        u64 firstBlockPtr = __PHEAP_16B_LISTS[index16];
        if(firstBlockPtr != 0)
        {
            __PHEAP_16B_LISTS[index16] = readRawU64_native(firstBlockPtr + 8); // remove first block from list, point to next block (which could be null)

            // zero-out bytes we used to store list link
            writeRawU64_native(firstBlockPtr + 8, 0); // rest of block bytes should be zero

            if(__HVM_MEMORY_PROFILER_INSESSION == true)
            {
                __reportHeapAlloc_native(instAddr, firstBlockPtr, numBytes);
            }

            return firstBlockPtr;
        }
    }

    // check mixed blocks, first fit
    prevBlockPtr = 0;
    thisBlockPtr = __PHEAP_MIXED_LIST;
    while(thisBlockPtr != 0)
    {
        thisBlockSize = readRawU64_native(thisBlockPtr + 0);
        nextBlockPtr  = readRawU64_native(thisBlockPtr + 8);

        if(numBytes < thisBlockSize)
        {
            // eat the end of this block so we don't have to update anything other than size
            newBlockSize = thisBlockSize - numBytes;
            retBlockPtr  = (thisBlockPtr + thisBlockSize) - numBytes;

            writeRawU64_native(thisBlockPtr + 0, newBlockSize);

            if(__HVM_MEMORY_PROFILER_INSESSION == true)
            {
                __reportHeapAlloc_native(instAddr, retBlockPtr, numBytes);
            }

            return retBlockPtr;
        }
        else if(numBytes == thisBlockSize)
        {
            // remove this block from list, linking previous block to next
            if(prevBlockPtr == 0)
            {
                // first block in list
                __PHEAP_MIXED_LIST = nextBlockPtr;
            }
            else
            {
                writeRawU64_native(prevBlockPtr + 8, nextBlockPtr);
            }

            // zero-out bytes we used to store list link and block size, other bytes should be zero
            writeRawU64_native(thisBlockPtr + 0, 0);
            writeRawU64_native(thisBlockPtr + 8, 0);

            if(__PHEAP_MIXED_LAST == thisBlockPtr)
            {
                __PHEAP_MIXED_LAST = prevBlockPtr;
            }

            if(__HVM_MEMORY_PROFILER_INSESSION == true)
            {
                __reportHeapAlloc_native(instAddr, thisBlockPtr, numBytes);
            }

            return thisBlockPtr;
        }

        // else go to next block
        prevBlockPtr = thisBlockPtr;
        thisBlockPtr = nextBlockPtr;
    }

    assert(false); // out of memory
    return 0;
}

// Used by Garbage Collector etc.
void __deallocateMemory(u64 memAddr, u64 numBytes) 
{
    if(memAddr == 0 || numBytes == 0)
        return; // no need

    // must be aligned size
    if(numBytes <= __PRONTO_HEAP_ALIGN)
    {
        numBytes = __PRONTO_HEAP_ALIGN;
    }
    else
    {
        u64 remainder = numBytes % __PRONTO_HEAP_ALIGN;
        if(remainder != 0)
        {
            numBytes += __PRONTO_HEAP_ALIGN - remainder;
        }
    }

    __PHEAP_USED_SIZE -= numBytes;

    // zero out block so it's ready for reuse
    u64 numBytesDiv8 = numBytes >> 3; // divide by 8
    u64 zeroPtr = memAddr;
    for(u64 b=0; b<numBytesDiv8; b++)
    {
        writeRawU64_native(zeroPtr, 0);
        zeroPtr += 8;
    }

    // check for existing perfect sized fixed block?
    if(numBytes <= __PHEAP_MAX_BLOCK_FIXED_SIZE)
    {
        u64 index16 = (numBytes >> 4) - 1; // divide by 16

        // add this block to front of list (which also has cache-hit advantages when reused)
        // we don't write size for fixed size blocks because it's implied! AKA writeRawU64_native(memAddr + 0, numBytes);
        writeRawU64_native(memAddr + 8, __PHEAP_16B_LISTS[index16]);

        __PHEAP_16B_LISTS[index16] = memAddr;
    }
    else
    {
        // add this block to back of mixed list
        writeRawU64_native(memAddr + 0, numBytes);
        writeRawU64_native(__PHEAP_MIXED_LAST + 8, memAddr);

        __PHEAP_MIXED_LAST = memAddr;
    }

    if(__HVM_MEMORY_PROFILER_INSESSION == true)
    {
        __reportHeapDealloc_native(memAddr, numBytes);
    }
}

IObj __allocateArray(u64 numElements, u16 elemSize, u32 clsTableOffset, u64 instAddr)
{
    u64 arrSize = __PRONTO_OBJ_HEADER_SIZE + (numElements * elemSize);
    u64 arrAddr = __allocateMemory(arrSize, instAddr);
    arrAddr += __PRONTO_OBJ_HEADER_SIZE; // array refs always start at elements

    // write header info - all these calls are intrinsics, not real functions
    writeRawU32_native(arrAddr - __PRONTO_OBJ_REFCOUNT_OFFSET, 0);
    writeRawU32_native(arrAddr - __PRONTO_OBJ_CTABLE_OFFSET, clsTableOffset);
    writeRawU64_native(arrAddr - __PRONTO_ARR_NUM_ELEM_OFFSET, numElements);

    return castU64ToIObj_native(arrAddr);
}

IObj __allocateObject(u32 numBytes, u64 instAddr)
{
    u64 objAddr = __allocateMemory(numBytes, instAddr);
    objAddr += __PRONTO_OBJ_HEADER_SIZE; // obj refs always start at properties

    // write header info - all these calls are intrinsics, not real functions
    writeRawU32_native(objAddr - __PRONTO_OBJ_REFCOUNT_OFFSET, 0);
    writeRawU32_native(objAddr - __PRONTO_OBJ_CTABLE_OFFSET, 0);
    writeRawU64_native(objAddr - __PRONTO_ARR_NUM_ELEM_OFFSET, 0);

    IObj retObj = castU64ToIObj_native(objAddr);

    return retObj;
}

// Utility for __deallocateObject
void __decreaseObjRefCount(u64 objAddr, bool releaseObjIfRefCountZero)
{
	if(objAddr == 0)
		return;

	u32 objRefCount = readRawU32_native(objAddr - __PRONTO_OBJ_REFCOUNT_OFFSET);
	if(objRefCount == 0)
	{
		// Do nothing, see "zero ensures we won't circularly comeback to this"
	}
	else if(objRefCount <= 1) // we are about to go to zero
	{
        writeRawU32_native(objAddr - __PRONTO_OBJ_REFCOUNT_OFFSET, 0); // zero ensures we won't circularly comeback to this
		if(releaseObjIfRefCountZero == true)
			__deallocateObject(objAddr);
	}
	else // greater than 1
	{
		writeRawU32_native(objAddr - __PRONTO_OBJ_REFCOUNT_OFFSET, objRefCount - 1); // reference count is at least 1
	}
}

// Works for arrays too.
void __deallocateObject(u64 objAddr)
{
	if(objAddr == 0)
		return;

	// deallocate this object since we know there are no more references to it
	u64 clsTableAddr      = __PSHARED_PTR + readRawU32_native(objAddr - __PRONTO_OBJ_CTABLE_OFFSET);
	u8  arrElemTypeID     = readRawU8_native(clsTableAddr + __CTABLE_ARRAY_ELEM_TYPE);
	u8  arrElemTypeNumVec = readRawU8_native(clsTableAddr + __CTABLE_ARRAY_ELEM_TYPE + 1);

	if(arrElemTypeID == 0)
	{
		// class members that are objects need reference decrement etc.
		u16 numVirFuncs = readRawU16_native(clsTableAddr + __CTABLE_NUM_MAPPINGS);
		u16 numObjProps = readRawU16_native(clsTableAddr + __CTABLE_NUM_OBJ_PROPS);

		u64 clsPropAddr = clsTableAddr + __CTABLE_HEADER_SIZE + (numVirFuncs * __CTABLE_ENTRY_SIZE);

		// for each class member that is an object 
		for(u64 m=0; m<numObjProps; m++)
		{
			u16 propOffset = readRawU16_native(clsPropAddr);
			clsPropAddr += 2;

			u64 clsPropObjAddr = readRawU64_native(objAddr + propOffset);
			if(clsPropObjAddr == 0) // null
				continue;

			__decreaseObjRefCount(clsPropObjAddr, true);
		}

		u32 objSizeBytes = readRawU32_native(clsTableAddr + __CTABLE_CLASS_SIZE_OFFSET);
        __deallocateMemory(objAddr - __PRONTO_OBJ_HEADER_SIZE, objSizeBytes);

        // TODO port memory profiler?
		//if(memProfiler != NULL)
		//{
		//	if(memProfiler->getState() == IVMMemProfiler::STATE_INSESSION)
		//		memProfiler->onDeallocation(objAddr - __PRONTO_OBJ_HEADER_SIZE, objSizeBytes);
		//}
	}
	else // array
	{
		u64 numElemInArray = readRawU64_native(objAddr - __PRONTO_ARR_NUM_ELEM_OFFSET);

		if(arrElemTypeID == 12) // array of objects
		{
			// each valid object (non null) needs to have it's own reference count reduced by 1
			for(u64 i=0; i<numElemInArray; i++)
			{
				u64 arrElemObjAddr = readRawU64_native(objAddr + (8 * i));
				if(arrElemObjAddr == 0) // "null"
					continue;

				__decreaseObjRefCount(arrElemObjAddr, true);
			}
		}

		u64 elemSize = TYPE_BYTE_SIZES[arrElemTypeID];
		if(arrElemTypeNumVec != 0)
			elemSize *= arrElemTypeNumVec; // array of vectors, i.e. u8[4][]

		u64 arraySizeBytes = __PRONTO_OBJ_HEADER_SIZE + (numElemInArray * elemSize);
        __deallocateMemory(objAddr - __PRONTO_OBJ_HEADER_SIZE, arraySizeBytes);

        // TODO port memory profiler?
		//if(memProfiler != NULL)
		//{
		//	if(memProfiler->getState() == IVMMemProfiler::STATE_INSESSION)
		//		memProfiler->onDeallocation(objAddr - __PRONTO_OBJ_HEADER_SIZE, arraySizeBytes);
		//}
	}
}

// In bytes for heap
u64 __getUsedMemorySize()
{
    return __PHEAP_USED_SIZE;
}*/