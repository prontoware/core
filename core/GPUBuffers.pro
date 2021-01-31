////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// VertexBuffer
////////////////////////////////////////////////////////////////////////////////////////////////////

// An arbitrary sized buffer to hold per-vertex attributes. Note that all types are converted to
// float types in the vertex shader.
class VertexBuffer
{
	u64  bufHandle = 0;       // meaning is specific to platform HRT
	u32  size      = 0;       // in bytes
	u8   type      = Type:U8; // one of Type:U8, Type:I8, Type:U16, Type:I16, Type:U32, Type:I32, or Type:F32.
	bool normalize = false;   // if true, integer values will be normalized to 0 to 1 for unsigned types or -1 to +1 for signed types when passed to vertex shader.

	// Allocate.
	void constructor(u8 mappedType, u32 sizeInBytes)
	{
		this.bufHandle = createVertexBuffer_native(sizeInBytes, false);
		this.size      = sizeInBytes;
		this.type      = mappedType;
	}

	// Allocate.
	void constructor(u8 mappedType, u32 sizeInBytes, bool frequentUpdates)
	{
		this.bufHandle = createVertexBuffer_native(sizeInBytes, frequentUpdates);
		this.size      = sizeInBytes;
		this.type      = mappedType;
	}

	// Allocate and set data.
	void constructor(u8[] data)
	{
		this.size      = data.length() * 1;
		this.bufHandle = createVertexBuffer_native(this.size, false);
		setData(data);
	}

	// Allocate and set data.
	void constructor(i8[] data)
	{
		this.size      = data.length() * 1;
		this.bufHandle = createVertexBuffer_native(this.size, false);
		setData(data);
	}

	// Allocate and set data.
	void constructor(u16[] data)
	{
		this.size      = data.length() * 2;
		this.bufHandle = createVertexBuffer_native(this.size, false);
		setData(data);
	}

	// Allocate and set data.
	void constructor(i16[] data)
	{
		this.size      = data.length() * 2;
		this.bufHandle = createVertexBuffer_native(this.size, false);
		setData(data);
	}

	// Allocate and set data.
	void constructor(u32[] data)
	{
		this.size      = data.length() * 4;
		this.bufHandle = createVertexBuffer_native(this.size, false);
		setData(data);
	}

	// Allocate and set data.
	void constructor(i32[] data)
	{
		this.size      = data.length() * 4;
		this.bufHandle = createVertexBuffer_native(this.size, false);
		setData(data);
	}

	// Allocate and set data.
	void constructor(f32[] data)
	{
		this.size      = data.length() * 4;
		this.bufHandle = createVertexBuffer_native(this.size, false);
		setData(data);
	}

	// Allocate and set data.
	void constructor(f32[4][] data)
	{
		this.size      = data.length() * 16;
		this.bufHandle = createVertexBuffer_native(this.size, false);
		setData(data);
	}

	// Release GPU resources.
	void destroy()
	{
		deleteVertexBuffer_native(this.bufHandle);
		this.size = 0;
	}

	// If enabled integer values will be normalized to 0 to 1 for unsigned types or -1 to +1 for signed types when passed to vertex shader. No effect for float types.
	void setNormalizeValues(bool enabled)
	{
		this.normalize = enabled;
	}

	// Was memory allocated successfully?
	bool isValid() { if(this.bufHandle == 0) { return false; }  return true;}

	// Get size of allocated buffer in bytes.
	u32 getSize() { return size; }

	// Set u8 data.
	void setData(u8[] data) { setData(data, 0, data.length() * 1); }

	// Set subset of passed-in u8 data.
	void setData(u8[] data, u32 startIndex, u32 numElements)
	{
		setVertexBufferData_native(bufHandle, data, startIndex, numElements); 
		this.type = Type:U8;
	}

	// Set i8 data.
	void setData(i8[] data) { setData(data, 0, data.length() * 1); }

	// Set subset of passed-in i8 data.
	void setData(i8[] data, u32 startIndex, u32 numElements)
	{
		u8[] tempData = data.reinterpret(Type:U8, 0);
		setVertexBufferData_native(bufHandle, tempData, startIndex, numElements); 
		tempData.reinterpret(Type:I8, 0);
		this.type = Type:I8;
	}

	// Set u16 data.
	void setData(u16[] data) { setData(data, 0, data.length() * 2); }

	// Set subset of passed-in u16 data.
	void setData(u16[] data, u32 startIndex, u32 numElements)
	{
		u8[] tempData = data.reinterpret(Type:U8, 0);
		setVertexBufferData_native(bufHandle, tempData, startIndex, numElements * 2);
		tempData.reinterpret(Type:U16, 0);
		this.type = Type:U16;
	}

	// Set i16 data.
	void setData(i16[] data) { setData(data, 0, data.length() * 2); }

	// Set subset of passed-in i16 data.
	void setData(i16[] data, u32 startIndex, u32 numElements)
	{
		u8[] tempData = data.reinterpret(Type:U8, 0);
		setVertexBufferData_native(bufHandle, tempData, startIndex, numElements * 2);
		tempData.reinterpret(Type:I16, 0);
		this.type = Type:I16;
	}

	// Set u32 data.
	void setData(u32[] data) { setData(data, 0, data.length() * 4); }

	// Set subset of passed-in u32 data.
	void setData(u32[] data, u32 startIndex, u32 numElements)
	{
		u8[] tempData = data.reinterpret(Type:U8, 0);
		setVertexBufferData_native(bufHandle, tempData, startIndex, numElements * 4);
		tempData.reinterpret(Type:U32, 0);
		this.type = Type:U32;
	}

	// Set i32 data.
	void setData(i32[] data) { setData(data, 0, data.length() * 4); }

	// Set subset of passed-in i32 data.
	void setData(i32[] data, u32 startIndex, u32 numElements)
	{
		u8[] tempData = data.reinterpret(Type:U8, 0);
		setVertexBufferData_native(bufHandle, tempData, startIndex, numElements * 4);
		tempData.reinterpret(Type:I32, 0);
		this.type = Type:I32;
	}

	// Set f32 data.
	void setData(f32[] data) { setData(data, 0, data.length() * 4); }

	// Set subset of passed-in f32 data.
	void setData(f32[] data, u32 startIndex, u32 numElements)
	{
		u8[] tempData = data.reinterpret(Type:U8, 0);
		setVertexBufferData_native(bufHandle, tempData, startIndex, numElements * 4);
		tempData.reinterpret(Type:F32, 0);
		this.type = Type:F32;
	}

	// Set f32[2] data. Note this method is equivalent to setting f32[] data.
	void setData(f32[2][] data) { setData(data, 0, data.length() * 8); }

	// Set subset of passed-in f32[2] data. Note this method is equivalent to setting f32[] data.
	void setData(f32[2][] data, u32 startIndex, u32 numElements)
	{
		u8[] tempData = data.reinterpret(Type:U8, 0);
		setVertexBufferData_native(bufHandle, tempData, startIndex, numElements * 8);
		tempData.reinterpret(Type:F32, 2);
		this.type = Type:F32;
	}

	// Set f32[3] data. Note this method is equivalent to setting f32[] data.
	void setData(f32[3][] data) { setData(data, 0, data.length() * 12); }

	// Set subset of passed-in f32[3] data. Note this method is equivalent to setting f32[] data.
	void setData(f32[3][] data, u32 startIndex, u32 numElements)
	{
		u8[] tempData = data.reinterpret(Type:U8, 0);
		setVertexBufferData_native(bufHandle, tempData, startIndex, numElements * 12);
		tempData.reinterpret(Type:F32, 3);
		this.type = Type:F32;
	}

	// Set f32[4] data. Note this method is equivalent to setting f32[] data.
	void setData(f32[4][] data) { setData(data, 0, data.length() * 16); }

	// Set subset of passed-in f32[4] data. Note this method is equivalent to setting f32[] data.
	void setData(f32[4][] data, u32 startIndex, u32 numElements)
	{
		u8[] tempData = data.reinterpret(Type:U8, 0);
		setVertexBufferData_native(bufHandle, tempData, startIndex, numElements * 16);
		tempData.reinterpret(Type:F32, 4);
		this.type = Type:F32;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// IndexBuffer
////////////////////////////////////////////////////////////////////////////////////////////////////

// An arbitrary sized buffer to hold per-vertex indices. Used in conjunction with VertexBuffer.
// Indices must be u16 values.
class IndexBuffer
{
	u64 bufHandle = 0;        // meaning is specific to platform HRT
	u32 size      = 0;        // in bytes
	u8  type      = Type:U16; // must be u16, only index type supported as of Pronto 1.x

	// Allocate.
	void constructor(u32 sizeInBytes)
	{
		this.bufHandle = createIndexBuffer_native(sizeInBytes, false);
		this.size      = sizeInBytes;
	}

	// Allocate.
	void constructor(u32 sizeInBytes, bool frequentUpdates)
	{
		this.bufHandle = createIndexBuffer_native(sizeInBytes, frequentUpdates);
		this.size      = sizeInBytes;
	}

	// Allocate and set data.
	void constructor(u16[] data)
	{
		this.size      = data.length() * 2;
		this.bufHandle = createIndexBuffer_native(this.size, false);
		setData(data);
	}

	// Allocate and set data.
	void constructor(u16[] data, bool frequentUpdates)
	{
		this.size      = data.length() * 2;
		this.bufHandle = createIndexBuffer_native(this.size, frequentUpdates);
		setData(data);
	}

	// Release GPU resources.
	void destroy()
	{
		deleteIndexBuffer_native(this.bufHandle);
		this.size = 0;
	}

	// Was memory allocated successfully?
	bool isValid() { if(this.bufHandle == 0) { return false; }  return true;}

	// Get size of allocated buffer in bytes.
	u32 getSize() { return size; }

	// Set data.
	void setData(u16[] data) { setData(data, 0, data.length() * 2); }

	// Set data.
	void setData(u16[] data, u32 startIndex, u32 numElements)
	{
		u8[] tempData = data.reinterpret(Type:U8, 0);
		setIndexBufferData_native(bufHandle, tempData, startIndex, numElements * 2);
		tempData.reinterpret(Type:U16, 0);
	}
}