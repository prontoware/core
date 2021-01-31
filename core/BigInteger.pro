////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// BigInt
////////////////////////////////////////////////////////////////////////////////////////////////////

// BigInt is designed to work with numbers up to ~16k bits large. Useful for public key cryptography
// like RSA etc. 
class BigInt
{
    const u32 DEFAULT_NUMBERS_SIZE = 128; // U32s (4 bytes per)
    const u32 MAX_BITS    = 16384; // we haven't really designed or tested BigInt to work with numbers larger than ~16k bits
    const i64 POW_2_TO_32 = 4294967296; // this is exactly 2^32

    // Shared state (per thread)
    shared String<u8> DECIMAL_CONSTS = "0123456789";
    shared RandomFast randFast();
    shared bool NO_TRUE_RANDOMS_WARNING = false;

    // Temporaries / cache
    shared u32[] differenceCache(512);
    shared u32[] mulCache(1024);
    shared BigInt ZERO(0);
    shared BigInt ONE(1);

    // Properties
    i8    sign;    // always 1 or -1
    u64   numUsed; // number of u32's in num that are in use
    u32[] numbers; // in base 2^32. We use u32 so that we can do intermediate math (like u32 * u32) in u64 etc. val[0] has lowest num

    // Set random generator seed (reset).
    shared void setRandomSeed(u64 seed)
    {
        randFast = RandomFast(seed);
    }

    // Create zero
    void constructor()
    {
        this.sign    = 1;
        this.numUsed = 0;
        this.numbers = u32[](DEFAULT_NUMBERS_SIZE);
    }

    // Create from passed-in value
    void constructor(i8 val)
    {
        this.sign    = 1;
        this.numUsed = 0;
        this.numbers = u32[](DEFAULT_NUMBERS_SIZE);

        set(val);
    }

    // Create from passed-in value
    void constructor(i16 val)
    {
        this.sign    = 1;
        this.numUsed = 0;
        this.numbers = u32[](DEFAULT_NUMBERS_SIZE);

        set(val);
    }

    // Create from passed-in value
    void constructor(i32 val)
    {
        this.sign    = 1;
        this.numUsed = 0;
        this.numbers = u32[](DEFAULT_NUMBERS_SIZE);

        set(val);
    }

    // Create from passed-in value
    void constructor(i64 val)
    {
        this.sign    = 1;
        this.numUsed = 0;
        this.numbers = u32[](DEFAULT_NUMBERS_SIZE);

        set(val);
    }

    // Create from passed-in value
    void constructor(u8 val)
    {
        this.sign    = 1;
        this.numUsed = 0;
        this.numbers = u32[](DEFAULT_NUMBERS_SIZE);

        set(val);
    }

    // Create from passed-in value
    void constructor(u16 val)
    {
        this.sign    = 1;
        this.numUsed = 0;
        this.numbers = u32[](DEFAULT_NUMBERS_SIZE);

        set(val);
    }

    // Create from passed-in value
    void constructor(u32 val)
    {
        this.sign    = 1;
        this.numUsed = 0;
        this.numbers = u32[](DEFAULT_NUMBERS_SIZE);

        set(val);
    }

    // Create from passed-in value
    void constructor(u64 val)
    {
        this.sign    = 1;
        this.numUsed = 0;
        this.numbers = u32[](DEFAULT_NUMBERS_SIZE);

        set(val);
    }

    // Set from bytes, assumes little endian, unless treatAsBigEndian = true.
    void constructor(u8[] bytes, bool treatAsBigEndian)
    {
        this.sign    = 1;
        this.numUsed = 0;
        this.numbers = u32[](DEFAULT_NUMBERS_SIZE);

        if(treatAsBigEndian == false)
            setFromBytesLittleEndian(bytes);
        else
            setFromBytesBigEndian(bytes);
    }

    // Create from string, assumed to be base10 (decimal). Can use "0b" prefix for binary base, or "0x" for hex base.
    void constructor(String<u8> str)
    {
        this.sign    = 1;
        this.numUsed = 0;
        this.numbers = u32[](DEFAULT_NUMBERS_SIZE);

        set(str);
    }

    // Create from string, pass explicity base parameter. base can be 2, 10, or 16.
    void constructor(String<u8> str, u8 base)
    {
        this.sign    = 1;
        this.numUsed = 0;
        this.numbers = u32[](DEFAULT_NUMBERS_SIZE);

        set(str, base);
    }

    // Copy constructor
    void constructor(BigInt b)
    {
        if(b == null)
        {
            this.sign    = 1;
            this.numUsed = 0;
            this.numbers = u32[](DEFAULT_NUMBERS_SIZE);
        }
        else
        {
            this.sign    = b.sign;
            this.numUsed = b.numUsed;
            this.numbers = u32[](b.numbers.length());

            for(u64 x=0; x<b.numUsed; x++)
                this.numbers[x] = b.numbers[x];
        }
    }

    // Create a sized buffer
    void constructor(u32 numU32s, bool createSized)
    {
        this.sign    = 1;
        this.numUsed = 0;
        this.numbers = u32[](numU32s);
    }

    // Copy passed-in
    void copy(BigInt b)
    {
        this.sign = b.sign;
        this.numUsed = b.numUsed;
        if(this.numbers.length() < b.numUsed)
        {
            this.numbers = u32[](b.numbers.length());

            for(u64 x=0; x<b.numUsed; x++)
                this.numbers[x] = b.numbers[x];
        }
        else
        {
            for(u64 x=0; x<b.numUsed; x++)
                this.numbers[x] = b.numbers[x];

            for(u64 c=this.numUsed; c<this.numbers.length(); c++)
                this.numbers[c] = 0;
        }
    }

    // Set from bytes. Assumes positive number. Assumes bytes[0] is the least significant byte.
    void setFromBytesLittleEndian(u8[] bytes)
    {
        this.sign    = 1;
        this.numUsed = 0;
        this.numbers = u32[]((bytes.length() / 4) + 1);

        if(bytes == null)
            return;

        u64 b = 0;
        while(b < bytes.length())
        {
            u32 bVal = bytes[b];
            bVal = bVal << ((b % 4) * 8);
            this.numbers[(b / 4)] |= bVal;
            b++;
        }

        setNumUsed();
    }

    // Set from bytes. Assumes positive number. Assumes bytes[0] is the most significant byte.
    void setFromBytesBigEndian(u8[] bytes)
    {
        this.sign    = 1;
        this.numUsed = 0;

        if(bytes == null)
            return;

        // reverse bytes order
        u8[] rBytes(bytes.length());
        for(u64 b=0; b<bytes.length(); b++)
        {
            rBytes[b] = bytes[bytes.length() - (b + 1)];
        }

        setFromBytesLittleEndian(rBytes);
    }

    // For small numbers it's possible to convert directly to u64. Any bits higher than 64 are ignored.
    u64 asU64()
    {
        if(numUsed == 0)
            return 0;

        if(numUsed == 1)
            return this.numbers[0];

        u64 x = this.numbers[0];
        u64 y = this.numbers[1];

        return ((x) | (y << 32));
    }

    // For small numbers it's possible to convert directly to i64. Any bits higher than 63 are ignored.
    i64 asI64()
    {
        i64 r = asU64();
        if(this.sign == -1)
            r = r * -1;

        return r;
    }

    // Get the entire number (ignoring sign) as u8[] array of bytes where u8[0] = least significant (AKA little endian).
    u8[] asBytesLittleEndian()
    {
        u64 bitLen = getBitLength();
        u64 numBytes = bitLen / 8;
        if((bitLen % 8) > 0)
            numBytes++;

        u8[] r(numBytes);

        for(u64 n=0; n<this.numUsed; n++)
        {
            u32 v = this.numbers[n];

            // byte values
            u8 v0 = v & 0x000000FF;
            u8 v1 = (v & 0x0000FF00) >> 8;
            u8 v2 = (v & 0x00FF0000) >> 16;
            u8 v3 = (v & 0xFF000000) >> 24;

            // indexes into r
            u64 i0 = (n * 4) + 0;
            u64 i1 = (n * 4) + 1;
            u64 i2 = (n * 4) + 2;
            u64 i3 = (n * 4) + 3;

            // make sure extra bytes not going AIOOB
            if(i0 < r.length())
                r[i0] = v0;

            if(i1 < r.length())
                r[i1] = v1;

            if(i2 < r.length())
                r[i2] = v2;

            if(i3 < r.length())
                r[i3] = v3;
        }

        return r;
    }

    // Get the entire number (ignoring sign) as u8[] array of bytes where u8[0] = most significant (big endian, AKA network order)
    u8[] asBytesBigEndian()
    {
        u8[] a = asBytesLittleEndian();
        u8[] b(a.length());

        // reverse
        for(u64 z=0; z<a.length(); z++)
            b[z] = a[a.length() - (z + 1)];

        return b;
    }

    // Split the bits of this number into two numbers. hi/low params can be null to indicate not wanted.
    void split(BigInt hi, BigInt low, u64 firstBitOfHiIndex)
    {
        u64 thisNumBits = this.getBitLength();
        u64 hiNumBits   = thisNumBits - firstBitOfHiIndex;
        u64 lowNumBits  = firstBitOfHiIndex;

        if(hi != null)
        {
            hi.copy(this);
            u32 numU32sToZero      = lowNumBits / 32;
            u32 leftOverBitsToZero = lowNumBits % 32;

            for(u32 x=0; x<numU32sToZero; x++)
            {
                hi.numbers[x] = 0;
            }

            // remainder bits in last U32
            if(leftOverBitsToZero > 0)
            {
                u32 mask = 0xFFFFFFFF;
                mask = mask << leftOverBitsToZero;
                hi.numbers[numU32sToZero] = mask & hi.numbers[numU32sToZero];
            }
        }

        if(low != null)
        {
            low.copy(this);
            u32 numU32sToKeep      = lowNumBits / 32;
            u32 leftOverBitsToKeep = lowNumBits % 32;

            u32 partialU32 = 0;
            if(numU32sToKeep < this.numUsed && leftOverBitsToKeep > 0)
            {
                partialU32 = this.numbers[numU32sToKeep];
            }

            for(u32 x=numU32sToKeep; x<low.numbers.length(); x++)
            {
                low.numbers[x] = 0;
            }

            // remainder bits in last U32
            if(leftOverBitsToKeep > 0)
            {
                u32 mask = 0xFFFFFFFF;
                mask = mask >> (32 - leftOverBitsToZero);
                low.numbers[numU32sToKeep] = mask & partialU32;
            }

            low.setNumUsed();
        }
    }

    // Is zero?
    bool isZero()
    {
        for(u64 i=0; i<numUsed; i++)
        {
            if(numbers[i] != 0)
                return false;
        }

        return true;
    }

    // Is negative (less than zero)?
    bool isNegative()
    {
        if(sign == -1)
            return true;

        return false;
    }

    // Is positive (more than or equal to zero)?
    bool isPositive()
    {
        if(sign == -1)
            return false;

        return true;
    }

    // Is odd number? i.e. 1, 3, 5...
    bool isOdd()
    {
        if((numbers[0] & 0b00000000000000000000000000000001) == 1)
            return true;

        return false;
    }

    // Is even number? i.e. 2, 4, 6...
    bool isEven()
    {
        if((numbers[0] & 0b00000000000000000000000000000001) == 0)
            return true;

        return false;
    } 

    // Set to zero
    void clear()
    {
        sign = 1;
        numUsed = 1;
        for(u64 i=0; i<numbers.length(); i++)
            numbers[i] = 0;
    }

    // Resize number of num u32 spots available. If shrinking less than numUsed num will be lost (zero).
    void resize(u64 numSpots)
    {
        if(numSpots < 1)
        {
            numSpots = 1;
            this.numbers = u32[](numSpots);
            this.numbers[0] = 0;
            this.sign = 1;
        }

        // shrinking smaller than num?
        if(numSpots < numUsed)
        {
            this.clear();
            this.numbers = u32[](numSpots);
            return;
        }

        u32[] newVal(numSpots);
        for(u64 i=0; i<numUsed; i++)
            newVal[i] = this.numbers[i];

        this.numbers = newVal;
    }

    // Decimal (AKA base 10) UTF8 string representation (human readable).
    String<u8> toString()
    {
        return toString(0);
    }

    // UTF8 string representation (human readable). base parameter can be 2, 10, or 16.
    String<u8> toString(u8 base)
    {
        if(base == 2)
            return toStringBase2();
        else if(base == 16)
            return toStringBase16();

        return toStringBase10();
    }

    // Binary (AKA base 2) UTF8 string representation (human readable).
    String<u8> toStringBase2()
    {
        if(isZero() == true)
            return "0";

        String<u8> s((numUsed + 2) * 32);
        

        u32 charIndex = 0;
	    for(u32 i=0; i<numUsed; i++) // u32s
        {
            u32 number = this.numbers[i];
            for(u32 b=0; b<32; b++) // bits
            {
                u32 bits = number >> b;
                bits = bits & 0b00000000000000000000000000000001;
                u8 ch = Chars:ZERO + bits;

                s.chars[charIndex] = ch;
                charIndex++;
            }
        }

        s.numChars = charIndex;

        // remove any leading zeros
        for(i32 c=s.numChars-1; c>=0; c--)
        {
            if(s.chars[c] == Chars:ZERO)
                s.numChars--;
            else
                break;
        }

        if(this.sign == -1)
            s.append("-");

	    s.reverse();

        return s;
    }

    // Decimal (AKA base 10) UTF8 string representation (human readable).
    String<u8> toStringBase10()
    {
        if(isZero() == true)
            return "0";

        String<u8> s((numUsed + 2) * 10);

        BigInt remainder(this);
        remainder.sign = 1;
        BigInt remainderMod10(this);
        remainderMod10.sign = 1;
        BigInt big10(10);

	    i32 digitIndex = 0;
        u32 numIterations = 0;
        u32 MAX_ITERATIONS = 10000;
	    while(remainder.isZero() == false && numIterations < MAX_ITERATIONS)
	    {
            remainderMod10.copy(remainder);
            remainderMod10.modulo(big10);
            u64 mod10 = remainderMod10.numbers[0];
            assert(mod10 < 10);
	    	s.chars[digitIndex] = DECIMAL_CONSTS.chars[mod10];
            digitIndex++;

            if(remainder.lessThan(big10) == true)
                break; // that was last digit

            remainder.divide(big10);
            numIterations++;
	    }
	    s.numChars = digitIndex;

        assert(numIterations < MAX_ITERATIONS);

        if(this.sign == -1)
            s.append("-");

	    s.reverse();

        return s;
    }

    // Hexadecimal (AKA base 16) UTF8 string representation (human readable).
    String<u8> toStringBase16()
    {
        if(isZero() == true)
            return "0";

        String<u8> s((numUsed + 2) * 8);

        u32 charIndex = 0;
	    for(u32 i=0; i<numUsed; i++) // u32s
        {
            u32 number = this.numbers[i];
            for(u32 b=0; b<32; b+=4) // bits
            {
                u32 bits = number >> b;
                bits = bits & 0b00000000000000000000000000001111;

                u8 ch = 0;
                if(bits < 10)
                    ch = Chars:ZERO + bits;
                else
                    ch = Chars:A + (bits - 10);

                s.chars[charIndex] = ch;
                charIndex++;
            }
        }

        s.numChars = charIndex;

        // remove any leading zeros
        for(i32 c=s.numChars-1; c>=0; c--)
        {
            if(s.chars[c] == Chars:ZERO)
                s.numChars--;
            else
                break;
        }

        if(this.sign == -1)
            s.append("-");

	    s.reverse();

        return s;
    }

    void setNumUsed()
    {
        u64 numLen = this.numbers.length();
        this.numUsed = 1; // always minimum of 1 for zero (consistency)

        for(i64 x=numLen-1; x>=0; x--)
        {
            if(this.numbers[x] != 0)
            {
                this.numUsed = x + 1;
                return;
            }
        }
    }

    // Is equal to small number? Signs must match.
    bool equals(i32 number)
    {
        if(numUsed > 1)
            return false;

        i8 numSign = 1;
        if(number < 0)
            numSign = -1;

        if(this.sign != numSign)
            return false;

        if(this.numbers[0] == Math:abs(number))
            return true;

        return false;
    }

    // Are equal?
    bool equals(BigInt b)
    {
        if(this.numUsed != b.numUsed)
            return false;

        if(this.sign != b.sign)
            return false;

        for(i16 i=0; i<this.numUsed; i++)
        {
            if(this.numbers[i] != b.numbers[i])
                return false;
        }

        return true;
    }

    // Is this greater than passed-in? Equal to will return false.
    bool moreThan(BigInt b)
    {
        if(this.sign == 1 && b.sign == -1)
            return true;

        if(this.sign == -1 && b.sign == 1)
            return false;

        if(this.sign == 1) // both positive
        {
            if(this.numUsed < b.numUsed)
                return false;

            if(this.numUsed > b.numUsed)
                return true;

            for(i16 i=this.numUsed-1; i>=0; i--)
            {
                if(this.numbers[i] > b.numbers[i])
                    return true; // larger
                else if(this.numbers[i] < b.numbers[i])
                    return false; // smaller
                
                // equal, keep going...
            }
        }
        else // both negative
        {
            if(this.numUsed > b.numUsed) // this is like -1000 and b is like -100
                return false;

            if(this.numUsed < b.numUsed)
                return true;

            for(i16 i=this.numUsed-1; i>=0; i--)
            {
                if(this.numbers[i] > b.numbers[i])
                    return false; // this is like -200 and b is like -100
                else if(this.numbers[i] < b.numbers[i])
                    return true; // this is like -100 and b is like -200
                
                // equal, keep going...
            }
        }

        return false; // must be equal
    }

    // Is this greater than passed-in? Equal to will return true as well.
    bool moreThanOrEqual(BigInt b)
    {
        if(this.sign == 1 && b.sign == -1)
            return true;

        if(this.sign == -1 && b.sign == 1)
            return false;

        if(this.sign == 1) // both positive
        {
            if(this.numUsed < b.numUsed)
                return false;

            if(this.numUsed > b.numUsed)
                return true;

            for(i16 i=this.numUsed-1; i>=0; i--)
            {
                if(this.numbers[i] > b.numbers[i])
                    return true; // larger
                else if(this.numbers[i] < b.numbers[i])
                    return false; // smaller
                
                // equal, keep going...
            }
        }
        else // both negative
        {
            if(this.numUsed > b.numUsed) // this is like -1000 and b is like -100
                return false;

            if(this.numUsed < b.numUsed)
                return true;

            for(i16 i=this.numUsed-1; i>=0; i--)
            {
                if(this.numbers[i] > b.numbers[i])
                    return false; // this is like -200 and b is like -100
                else if(this.numbers[i] < b.numbers[i])
                    return true; // this is like -100 and b is like -200
                
                // equal, keep going...
            }
        }

        return true; // must be equal
    }

    // Is this less than passed-in? Equal to will return false.
    bool lessThan(BigInt b)
    {
        if(moreThanOrEqual(b) == true)
            return false;

        return true; // must be less than
    }

    // Is this less than passed-in? Equal to will return true as well.
    bool lessThanOrEqual(BigInt b)
    {
        if(lessThan(b) == true || equals(b) == true)
            return true;

        return false;
    }

    // Set a single bit. Will enlarge number as needed.
    void setBit(u32 bitIndex, u8 bitVal)
    {
        if(this.numUsed == 0)
            return;

        u64 wIndex = bitIndex / 32;
        u64 pIndex = bitIndex % 32;

        if(this.numbers.length() <= wIndex)
            this.resize(wIndex + 1);

        u32 curVal = this.numbers[wIndex];
        u32 mask = 1 << pIndex;

        if(bitVal == 0)
        {
            curVal &= ~mask;
        }
        else
        {
            curVal |= mask;
        }

        this.numbers[wIndex] = curVal;

        setNumUsed();
    }

    // Shift right. Shifting right by 1 is equivalent to dividing by 2.
    void shiftRight(u32 numBits)
    {
        // Faster shift by 32 bits at a time...
        if(numBits >= 32)
        {
            i32 numSpotsToMove = numBits / 32;
            numBits = numBits % 32;

            for(u64 n=numSpotsToMove; n<numUsed; n++)
            {
                u32 valueToMove = numbers[n];
                numbers[n - numSpotsToMove] = valueToMove;
                numbers[n] = 0; // value moved, no long valid
            }

            this.numUsed -= numSpotsToMove;
        }

        // less than 32 bits left to shift, so one last pass
        if(numBits > 0)
        {
            u32 carryBits    = 0;
            u32 carryNumBits = 32 - numBits;
            u32 carryMask    = 0b11111111111111111111111111111111 >> carryNumBits;
            for(i32 q=numUsed-1; q>=0; q--)
            {
                u32 originalVal = numbers[q];
                u32 shiftedVal  = originalVal >> numBits;
                u32 carriedVal  = carryBits << carryNumBits;
                numbers[q] = carriedVal | shiftedVal;

                // new carry bit
                carryBits = originalVal & carryMask;
            }

            if(numUsed > 1 && numbers[numUsed - 1] == 0)
                numUsed--; // we shifted another spot away
        }
    }

    // Shift left. Shifting left by 1 is equivalent to multiplying by 2.
    void shiftLeft(u32 numBits)
    {
        // need to resize?
        u32 numU32sNeeded = numUsed + ((numBits / 32) + 1);
        if(this.numbers.length() < numU32sNeeded)
            resize(numU32sNeeded);

        // Faster shift by 32 bits at a time...
        if(numBits >= 32)
        {
            u64 numSpotsToMove = numBits / 32;
            numBits = numBits % 32;

            for(i32 n=numUsed-1; n>=0; n--)
            {
                numbers[n + numSpotsToMove] = numbers[n];
                numbers[n] = 0; // value moved, no long valid
            }
        }

        this.numUsed = numU32sNeeded; // might be more than we need, but we'll fix with setNumUsed() call at end

        // less than 32 bits left to shift, so one last pass
        if(numBits > 0)
        {
            u32 carryBits    = 0;
            u32 carryNumBits = 32 - numBits;
            u32 carryMask    = 0b11111111111111111111111111111111 << carryNumBits;
            for(i32 n=0; n<numUsed; n++)
            {
                u32 originalVal = numbers[n];
                u32 shiftedVal  = originalVal << numBits;
                u32 carriedVal  = carryBits >> carryNumBits;
                numbers[n] = carriedVal | shiftedVal;

                // new carry bit
                carryBits = originalVal & carryMask;
            }
        }

        if(numUsed > 1 && numbers[numUsed - 1] == 0)
            numUsed--; // we shifted another spot away
    }

    // Addition. Result = this + b.
    void add(i32 b)
    {
        if(b == 0)
            return;

        // fast path for positive numbers
        if(this.sign == 1 && b > 0)
        {
            if(this.numbers.length() < 2)
                this.resize(2);

            u64 total = this.numbers[0] + u64(b);
            if(total < POW_2_TO_32)
            {
                this.numbers[0] = this.numbers[0] + b;
                if(this.numUsed == 0)
                    this.numUsed = 1;
            }
            else // would lead to carry, just use normal path
            {
                add(BigInt(b));
            }
        }
        else // negative numbers etc.
        {
            add(BigInt(b));
        }
    }

    // Addition. Result = this + b.
    void add(BigInt b)
    {
        // isZero() check:
        if(this.numUsed <= 1 && this.numbers[0] == 0)
        {
            this.copy(b);
            return;
        }

        if(this.sign == 1)
        {
            if(b.sign == 1) // c = (+a) + (+b)
            {
                this.absAdd(b);
            }
            else // c = (+a) + (-b) AKA c = a - b
            {
                b.sign = 1;
                this.subtract(b);
                b.sign = -1;
            }
        }
        else
        {
            if(b.sign == 1) // c = (-a) + (+b) AKA c = b - a
            {
                BigInt temp(b);
                this.sign = 1;
                temp.subtract(this);
                this.copy(temp);
            }
            else // c = (-a) + (-b) AKA c = -(a + b)
            {
                this.absAdd(b);
                this.sign = -1;
            }
        }
    }

    // Add big number to this
    void absAdd(BigInt b)
    {
        if(b.numUsed > numbers.length())
            resize(b.numUsed); // make same size

        if(b.numUsed > this.numUsed)
            this.numUsed = b.numUsed;

        if(this.numUsed > b.numUsed)
            b.numUsed = this.numUsed;

        // add column by column like you learned in grade school
        u64 carry = 0;
        for(u64 i=0; i<numUsed; i++)
        {
            u64 res = this.numbers[i] + (b.numbers[i] + carry); // () important for implicit u64 cast
            carry = 0;

            if(res >= POW_2_TO_32)
            {
                // carry forward
                res -= POW_2_TO_32;
                carry = 1;
            }

            numbers[i] = res; // new combined value
        }

        if(carry != 0)
        {
            if(numUsed == numbers.length())
            {
                resize(numUsed + 1); // so we have room for carry
            }

            this.numUsed++;
            this.numbers[numUsed-1] = carry;
        }
    }

    // Subtract small number
    void subtract(i32 b)
    {
        if(b == 0)
            return;

        // fast path for positive numbers
        if(this.sign == 1 && b >= 0 && numbers[0] >= b)
        {
            numbers[0] = numbers[0] - b;
            return;
        }

        subtract(BigInt(b));
    }

    // Subtract. Result = this - b.
    void subtract(BigInt b)
    {
        if(this.sign == 1 && b.sign == 1)
        {
            if(this.moreThan(b) == true)
            {
                this.absDifference(b, this);
            }
            else
            {
                b.absDifference(this, this);
                this.sign = -1; // small number - large number
            }
        }
        else if(this.sign == -1 && b.sign == -1) // c = (-a) - (-b) AKA c = (-a) + b AKA c = b - a
        {
            this.sign = 1; // absolute value
            if(this.moreThan(b) == true)
            {
                this.absDifference(b, this);
                this.sign = -1;
            }
            else // b is more than or equal to this, so positive result
            {
                b.absDifference(this, this);
                this.sign = 1;
            }
        }
        else if(this.sign == 1) // c = (+a) - (-b) AKA c = a + b
        {
            this.absAdd(b);
        }
        else  // c = (-a) - (+b)
        {
            this.absAdd(b);
            this.sign = -1;
        }
    }

    // Calculates the absolute difference between this and b, storing result in this.
    void absDifference(BigInt b, BigInt result)
    {
        u64 largerNumUsed  = this.numUsed;
        u64 smallerNumUsed = b.numUsed;

        u32[] thisNums = this.numbers;
        u32[] bNums    = b.numbers;
        u32[] resNums  = result.numbers;

        u64 borrow = 0;
        i64 res;
        i64 numL;
        i64 numS;
        u64 diffNumUsed = 0;
        for(u64 i=0; i<largerNumUsed; i++)
        {
            numL = thisNums[i];
            numS = borrow;
            if(i < smallerNumUsed)
                numS += bNums[i];

            borrow = 0;
            res = numL - numS;
            if(numL < numS)
            {
                borrow = 1;
                res += POW_2_TO_32;
            }

            resNums[i] = res; // new combined value

            if(res != 0)
                diffNumUsed = i;
        }

        result.numUsed = diffNumUsed + 1;

        // this clear shouldn't be needed if other functions written correctly...
        //u64 resNumLen = resNums.length();
        //for(u64 r=diffNumUsed+1; r<resNumLen; r++)
        //{
        //    resNums[r] = 0;
        //}
    }

    // Multiply big number with this.
    void multiply(i64 b)
    {
        multiply(BigInt(b));
    }

    // Multiply big number with this.
    void multiply(BigInt b)
    {
        u8 newSign = 1;
        if(this.sign == 1 && b.sign == -1)
            newSign = -1;
        else if(this.sign == -1 && b.sign == 1)
            newSign = -1;

        this.absMultiply(b);
        this.sign = newSign;
    }

    // Multiply big number with this ignoring signs.
    void absMultiply(BigInt b)
    {
        // multiply each digit in b by each digit in this (except each digit means each base 2^32 number, AKA u32)
        
        u32 largerLen = (this.numUsed * 2) + 1;
        if(largerLen < ((b.numUsed * 2) + 1))
            largerLen = ((b.numUsed * 2) + 1);

        u32[] total = mulCache;

        i64 totalNumUsed = this.numUsed + b.numUsed; // max we could potentially use
        for(u32 q=0; q<=totalNumUsed; q++)
            total[q] = 0;

        u64 thisNumUsed = this.numUsed;
        u64 bNumUsed    = b.numUsed;

        // Standard long multiplication O(n^2). TODO use Karatsuba/Toom-Cook-3 multiplication for numbers in excess of ~512 bits.
        for(u64 tIndex=0; tIndex<thisNumUsed; tIndex++)
        {
            u64 tNum = this.numbers[tIndex];

            for(u64 bIndex=0; bIndex<bNumUsed; bIndex++)
            {
                u64 bNum = b.numbers[bIndex];

                u64 numTotal = tNum * bNum;
                u64 numCols  = tIndex + bIndex; // u32^numCols (yes, number gets fucking big fast)

                u64 carry    = numTotal >> 32; // divide by POW_2_TO_32
                u64 leftOver = numTotal - (carry << 32); // multiply by POW_2_TO_32

                // manually add two (or more because of carry) columns
                u64 col0Total = total[numCols] + leftOver;
                if(col0Total >= POW_2_TO_32)
                {
                    col0Total -= POW_2_TO_32;
                    carry += 1;
                }
                total[numCols] = col0Total;

                u64 col1Total = total[numCols+1] + carry;
                carry = 0;
                if(col1Total >= POW_2_TO_32)
                {
                    col1Total -= POW_2_TO_32;
                    carry = 1;
                }
                total[numCols+1] = col1Total;

                // we might have to propagate carry for a long time
                u64 curColIndex = numCols+2;
                while(carry > 0)
                {
                    u64 colTotal = total[curColIndex] + carry;
                    carry = 0;
                    if(colTotal >= POW_2_TO_32)
                    {
                        colTotal -= POW_2_TO_32;
                        carry = 1;
                    }
                    total[curColIndex] = colTotal;

                    curColIndex++;
                }
            }
        }

        while(total[totalNumUsed] == 0 && totalNumUsed >= 1)
        {
            totalNumUsed--;
        }
        totalNumUsed++; // always 1+

        if(this.numbers.length() < totalNumUsed)
            this.resize(totalNumUsed);
        else
            this.clear();

        for(u64 c=0; c<totalNumUsed; c++)
        {
            this.numbers[c] = total[c];
        }

        this.numUsed = totalNumUsed;
    }

    // Divide big number by passed-in.
    void divide(u64 b)
    {
        divide(BigInt(b));
    }

    // Divide big number by passed-in.
    void divide(BigInt b)
    {
        divide(b, null);
    }

    // Divide big number by passed-in. Also provides remainder via remainderOut.
    void divide(BigInt divisor, BigInt remainderOut)
    {
        u8 finalSign = 1;
        if((this.sign == -1 && divisor.sign == 1) || (this.sign == 1 && divisor.sign == -1))
            finalSign = -1;

        if(divisor.numUsed <= 1 && divisor.numbers[0] == 0)
        {
            this.set(0);  // undefined really
            this.sign = finalSign;

            if(remainderOut != null)
                remainderOut.set(0);

            return;
        }

        if(divisor.equals(ONE) == true)
        {
            this.sign = finalSign;

            if(remainderOut != null)
                remainderOut.set(0);

            return; // divide by one
        }

        if(this.lessThan(divisor) == true)
        {
            if(remainderOut != null)
                remainderOut.copy(this);

            this.set(0);
            this.sign = finalSign;
            return;
        }

        if(this.equals(divisor) == true)
        {
            if(remainderOut != null)
                remainderOut.set(0);

            this.set(1);
            this.sign = finalSign;
            return;
        }

        BigInt a(this); // we subtract away until no whole divisor (b) left
        a.sign = 1;
        BigInt b(divisor);
        b.sign = 1;

        BigInt bCount(a.numUsed, true); // how many times divisor (b) goes into a
        bCount.set(0);
        
        // Number of iterations needed for 2048bit / 1024bit.
        // BigInt.divide numIters =  33 LongDiv-shift method rounds needed (plus <= 32 rounds of binary-shift)
        // BigInt.divide numIters = 250 Multiply-highbits method rounds needed
        // BigInt.divide numIters = 502 Binary-shift method rounds needed
        //
        // LongDiv-Shift Method, for 2048/1024 bit
        // 46 rounds orignally
        // 39 rounds after optimizing 16 bit a difference
        // 33 rounds after optimizing for dividend's bit length (calculating ~31 bits of result per round which is basically optimal for this approach)
        // 
        // So the gap grows with larger numbers. However, each iteration with
        // the multiply method is significantly more expensive (more than 2x).
        //
        // Using the Long-Division Estimate Method (64/32 high bits) we reduce
        // the dividend by approx. 31 bits per iteration. The multiply is also
        // much faster because one of the numbers is 1 or 2 u32s in length.
        //
        // Long-Div Estimate speeds up division by about a 5x factor vs binary-shift alone.
        i32 bNumBits = divisor.getBitLength();
        u64 bTop = divisor.numbers[divisor.numUsed - 1] + 1; // + 1 guarantees that bTop is more than divisor (AKA b)

        // Long division-estimate method
        // Divide the top 32 bits of the divisor into the top 64 bits of the dividend. Use
        // that as a chunk estimate. Reduce by continual chunking away. Reduces dividend by
        // ~31 bits per iteration.
        i32 divNumUsed = divisor.numUsed;
        BigInt bMul(a.numUsed, true);
        BigInt bCountTemp(a.numUsed, true);
        while((a.numUsed - divNumUsed) >= 2)
        {
            u64 aTop = a.numbers[a.numUsed - 1];
            u32 aTopTemp = a.numbers[a.numUsed - 1];

            // Count how many more bits we can stuff in a, then grab those
            // Quick binary search for most significant bit
            u64 numExtraABits = 0;
            if(aTopTemp >= 0b00000000000000001000000000000000)
            {
                aTopTemp = aTopTemp >> 16;
                numExtraABits += 16;
            }
            
            if(aTopTemp >= 0b00000000000000000000000010000000)
            {
                aTopTemp = aTopTemp >> 8;
                numExtraABits += 8;
            }

            if(aTopTemp >= 0b00000000000000000000000000001000)
            {
                aTopTemp = aTopTemp >> 4;
                numExtraABits += 4;
            }

            if(aTopTemp >= 0b00000000000000000000000000000010)
            {
                aTopTemp = aTopTemp >> 2;
                numExtraABits += 2;
            }

            if(aTopTemp >= 0)
            {
                aTopTemp = aTopTemp >> 1;
                numExtraABits += 1;
            }

            if(aTopTemp >= 0)
            {
                aTopTemp = aTopTemp >> 1;
                numExtraABits += 1;
            }

            numExtraABits = 32 - numExtraABits;

            if(numExtraABits > 0 && (a.numUsed - divNumUsed) >= 3)
            {
                // give a N more bits...
                aTop = aTop << (32 + numExtraABits);
                u64 a2 = a.numbers[a.numUsed - 2];
                aTop = aTop | (a2 << numExtraABits);
                aTop = aTop | ((a.numbers[a.numUsed - 3] & 0x00000000FFFFFFFF) >> (32 - numExtraABits));
            }
            else
            {
                numExtraABits = 0; // important, it's possible we end up here because if( ... && (a.numUsed - divNumUsed) >= 3) !!

                aTop = aTop << 32;
                aTop = aTop | a.numbers[a.numUsed - 2];
            }

            u64 bCountEst = aTop / bTop;

            bMul.numbers[0] = bCountEst & 0x00000000FFFFFFFF;
            bMul.numbers[1] = (bCountEst & 0xFFFFFFFF00000000) >> 32;

            bMul.numUsed = 2;
            if(bMul.numbers[1] == 0)
                bMul.numUsed = 1;

            i32 shiftLeftAmount = (((a.numUsed - 1) - divNumUsed) * 32) - numExtraABits;

            bCountTemp.copy(bMul);
            bCountTemp.shiftLeft(shiftLeftAmount);
            bCount.add(bCountTemp);

            bMul.absMultiply(divisor);
            bMul.shiftLeft(shiftLeftAmount);
            a.absDifference(bMul, a);
        }

        // Binary-shift method
        // Use binary power (2n) to chunk away most of the remaining difference
        // This basically solves 2 bits of the result per iteration.
        // b * (2^n) before simple subtraction (critical optimization)
        BigInt b2n(b);
        bCountTemp.set(0);
        i32 aNumBits = a.getBitLength();
        
        i32 bitsDiff = aNumBits - bNumBits;
        i32 prevBitsDiff = bitsDiff;
        b2n.shiftLeft(bitsDiff);
        while(aNumBits > bNumBits)
        {
            // We need to take a big number out of a each round. So we use powers of 2. b * (2^n) and bCount * (2^n)
            // We can use bit length to estimate power of 2 needed.
            
            b2n.shiftRight(prevBitsDiff - bitsDiff); // using bits offset saves us b2n.copy()
            prevBitsDiff = bitsDiff;

            // it's possible that b2n is now larger than a, in which case we have to shift right 1 bit
            if(b2n.moreThan(a) == true)
            {
                b2n.shiftRight(1);

                prevBitsDiff--;

                u32 b2nCountIndex = (prevBitsDiff >> 5);
                u32 bitField = 1 << (prevBitsDiff % 32);

                bCountTemp.numbers[b2nCountIndex] |= bitField; // note using bCountTemp instead of bCount because of clever bitfield shit
                if(bCountTemp.numUsed < (b2nCountIndex+1))
                    bCountTemp.numUsed = b2nCountIndex+1;
            }
            else
            {
                u32 b2nCountIndex = (bitsDiff >> 5);
                u32 bitField = 1 << (bitsDiff % 32);

                bCountTemp.numbers[b2nCountIndex] |= bitField;
                if(bCountTemp.numUsed < (b2nCountIndex+1))
                    bCountTemp.numUsed = b2nCountIndex+1;
            }

            // reduce a
            a.subtract(b2n);

            // reset for next iteration
            aNumBits = a.getBitLength();
            bitsDiff = aNumBits - bNumBits;
        }

        bCount.add(bCountTemp); // because of our bit field shenanigans above, we had to keep these separate until now

        // finish with simple subtract until we get there
        u32 numItersC = 0;
        u32 MAX_ITERS_C = 3; // shouldn't need more than 2 subtractions total, since a can't be more than one bit bigger than b now
        while(a.moreThanOrEqual(b) == true && numItersC < MAX_ITERS_C)
        {
            a.subtract(b);
            bCount.add(1);
            numItersC++;
        }

        // remainder is in a
        if(remainderOut != null)
            remainderOut.copy(a);

        // bCount has answer
        this.copy(bCount);
        this.sign = finalSign;
    }

    // Modulo this by b.
    void modulo(u64 b)
    {
        modulo(BigInt(b));
    }

    // Modulo this by b.
    void modulo(BigInt divisor)
    {
        u8 finalSign = 1;
        if((this.sign == -1 && divisor.sign == 1) || (this.sign == 1 && divisor.sign == -1))
            finalSign = -1;

        if(divisor.numUsed <= 1 && divisor.numbers[0] == 0)
        {
            this.set(0);  // undefined really
            this.sign = finalSign;
            return;
        }

        if(divisor.equals(ONE) == true)
        {
            this.sign = finalSign;
            this.set(0);
            return; // divide by one
        }

        if(this.lessThan(divisor) == true)
        {
            this.sign = finalSign;
            return;
        }

        if(this.equals(divisor) == true)
        {
            this.set(0);
            this.sign = finalSign;
            return;
        }

        BigInt a(this); // we subtract away until no whole divisor (b) left
        a.sign = 1;

        // Long division-estimate method
        // Divide the top 32 bits of the divisor into the top 64 bits of the dividend. Use
        // that as a chunk estimate. Reduce by continual chunking away. Reduces dividend by
        // ~31 bits per iteration.
        u64 bTop = divisor.numbers[divisor.numUsed - 1] + 1; // + 1 guarantees that bTop is more than divisor (AKA b)
        i32 divNumUsed = divisor.numUsed;
        BigInt bMul(a.numUsed, true);
        while((a.numUsed - divNumUsed) >= 2)
        {
            u64 aTop = a.numbers[a.numUsed - 1];
            u32 aTopTemp = a.numbers[a.numUsed - 1];

            // Count how many more bits we can stuff in a, then grab those
            // Quick binary search for most significant bit
            u64 numExtraABits = 0;
            if(aTopTemp >= 0b00000000000000001000000000000000)
            {
                aTopTemp = aTopTemp >> 16;
                numExtraABits += 16;
            }
            
            if(aTopTemp >= 0b00000000000000000000000010000000)
            {
                aTopTemp = aTopTemp >> 8;
                numExtraABits += 8;
            }

            if(aTopTemp >= 0b00000000000000000000000000001000)
            {
                aTopTemp = aTopTemp >> 4;
                numExtraABits += 4;
            }

            if(aTopTemp >= 0b00000000000000000000000000000010)
            {
                aTopTemp = aTopTemp >> 2;
                numExtraABits += 2;
            }

            if(aTopTemp >= 0)
            {
                aTopTemp = aTopTemp >> 1;
                numExtraABits += 1;
            }

            if(aTopTemp >= 0)
            {
                aTopTemp = aTopTemp >> 1;
                numExtraABits += 1;
            }

            numExtraABits = 32 - numExtraABits;

            if(numExtraABits > 0 && (a.numUsed - divNumUsed) >= 3)
            {
                // give a N more bits...
                aTop = aTop << (32 + numExtraABits);
                u64 a2 = a.numbers[a.numUsed - 2];
                aTop = aTop | (a2 << numExtraABits);
                aTop = aTop | ((a.numbers[a.numUsed - 3] & 0x00000000FFFFFFFF) >> (32 - numExtraABits));
            }
            else
            {
                numExtraABits = 0; // important, it's possible we end up here because if( ... && (a.numUsed - divNumUsed) >= 3) !!

                aTop = aTop << 32;
                aTop = aTop | a.numbers[a.numUsed - 2];
            }

            u64 bCountEst = aTop / bTop;

            bMul.numbers[0] = bCountEst & 0x00000000FFFFFFFF;
            bMul.numbers[1] = (bCountEst & 0xFFFFFFFF00000000) >> 32;

            bMul.numUsed = 2;
            if(bMul.numbers[1] == 0)
                bMul.numUsed = 1;

            i32 shiftLeftAmount = (((a.numUsed - 1) - divNumUsed) * 32) - numExtraABits;

            bMul.absMultiply(divisor);
            bMul.shiftLeft(shiftLeftAmount);
            a.absDifference(bMul, a);
        }

        // Binary-shift method
        // Use binary power (2n) to chunk away most of the remaining difference
        // Reduces dividend by ~2 bits per iteration.
        i32 aNumBits = a.getBitLength();
        i32 bNumBits = divisor.getBitLength();
        i32 bitsDiff = aNumBits - bNumBits;
        i32 prevBitsDiff = bitsDiff;
        BigInt b2n(divisor);
        b2n.shiftLeft(bitsDiff);
        while(aNumBits > bNumBits)
        {
            // We need to take a big number out of a each round. So we use powers of 2. b * (2^n) and bCount * (2^n)
            // We can use bit length to estimate power of 2 needed.
            b2n.shiftRight(prevBitsDiff - bitsDiff); // using bits offset saves us b2n.copy()
            prevBitsDiff = bitsDiff;

            // it's possible that b2n is now larger than a, in which case we have to shift right 1 bit
            if(b2n.moreThan(a) == true)
            {
                b2n.shiftRight(1);
                prevBitsDiff--;
            }

            // reduce a
            a.absDifference(b2n, a);

            // reset for next iteration
            aNumBits = a.getBitLength();
            bitsDiff = aNumBits - bNumBits;
        }

        // finish with simple subtract until we get there
        u32 numItersC = 0;
        u32 MAX_ITERS_C = 3; // shouldn't need more than 2 subtractions total, since a can't be more than one bit bigger than b now
        while(a.moreThanOrEqual(divisor) == true && numItersC < MAX_ITERS_C)
        {
            a.subtract(divisor);
            numItersC++;
        }

        // a has remainder answer
        this.copy(a);
        this.sign = finalSign;
    }

    // Modulo this by b. Assumes divisor isn't zero, one.
    void moduloFast(BigInt divisor)
    {
        if(this.lessThan(divisor) == true)
        {
            return;
        }

        if(this.equals(divisor) == true)
        {
            this.set(0);
            return;
        }

        // Long division-estimate method
        // Divide the top 32 bits of the divisor into the top 64 bits of the dividend. Use
        // that as a chunk estimate. Reduce by continual chunking away. Reduces dividend by
        // ~31 bits per iteration.
        i32 bTopNumBits = divisor.getBitLength() % 32;
        u64 bTop = 0; 
        u64 bExtraBits = 0;
        if(bTopNumBits != 0 && divisor.numUsed >= 2)
        {
            bExtraBits = 32 - bTopNumBits;
            bTop = divisor.numbers[divisor.numUsed - 1];
            bTop = (bTop << bExtraBits) | (divisor.numbers[divisor.numUsed - 2] >> bTopNumBits);
            bTop += 1; // + 1 guarantees that bTop is more than divisor (AKA b)
        }
        else
            bTop = divisor.numbers[divisor.numUsed - 1] + 1; // + 1 guarantees that bTop is more than divisor (AKA b)

        i32 divNumUsed = divisor.numUsed;
        BigInt bMul(this.numUsed, true);
        while((this.numUsed - divNumUsed) >= 2)
        {
            u64 thisNumUsed = this.numUsed;
            u64 aTop = this.numbers[thisNumUsed - 1];
            u32 aTopTemp = this.numbers[thisNumUsed - 1];

            // Count how many more bits we can stuff in a, then grab those
            // Quick binary search for most significant bit
            u64 numExtraABits = 0;
            if(aTopTemp >= 0b00000000000000001000000000000000)
            {
                aTopTemp = aTopTemp >> 16;
                numExtraABits += 16;
            }
            
            if(aTopTemp >= 0b00000000000000000000000010000000)
            {
                aTopTemp = aTopTemp >> 8;
                numExtraABits += 8;
            }

            if(aTopTemp >= 0b00000000000000000000000000001000)
            {
                aTopTemp = aTopTemp >> 4;
                numExtraABits += 4;
            }

            if(aTopTemp >= 0b00000000000000000000000000000010)
            {
                aTopTemp = aTopTemp >> 2;
                numExtraABits += 2;
            }

            if(aTopTemp >= 0)
            {
                aTopTemp = aTopTemp >> 1;
                numExtraABits += 1;
            }

            if(aTopTemp >= 0)
            {
                aTopTemp = aTopTemp >> 1;
                numExtraABits += 1;
            }

            numExtraABits = 32 - numExtraABits;

            if(numExtraABits > 0 && (thisNumUsed - divNumUsed) >= 3)
            {
                // give a N more bits...
                aTop = aTop << (32 + numExtraABits);
                u64 a2 = this.numbers[thisNumUsed - 2];
                aTop = aTop | (a2 << numExtraABits);
                aTop = aTop | ((this.numbers[thisNumUsed - 3] & 0x00000000FFFFFFFF) >> (32 - numExtraABits));
            }
            else
            {
                numExtraABits = 0; // important, it's possible we end up here because if( ... && (a.numUsed - divNumUsed) >= 3) !!

                aTop = aTop << 32;
                aTop = aTop | this.numbers[thisNumUsed - 2];
            }

            u64 bCountEst = aTop / bTop;

            bMul.numbers[0] = bCountEst & 0x00000000FFFFFFFF;
            bMul.numbers[1] = (bCountEst & 0xFFFFFFFF00000000) >> 32;

            bMul.numUsed = 2;
            if(bMul.numbers[1] == 0)
                bMul.numUsed = 1;

            i32 shiftLeftAmount = ((((thisNumUsed - 1) - divNumUsed) * 32) - numExtraABits) + bExtraBits;

            bMul.absMultiply(divisor);
            bMul.shiftLeft(shiftLeftAmount);
            this.absDifference(bMul, this);
        }

        // Binary-shift method
        // Use binary power (2n) to chunk away most of the remaining difference
        // Reduces dividend by ~2 bits per iteration.
        i32 aNumBits = this.getBitLength();
        i32 bNumBits = divisor.getBitLength();
        i32 bitsDiff = aNumBits - bNumBits;
        i32 prevBitsDiff = bitsDiff;
        BigInt b2n(divisor);
        b2n.shiftLeft(bitsDiff);
        while(aNumBits > bNumBits)
        {
            // We need to take a big number out of a each round. So we use powers of 2. b * (2^n) and bCount * (2^n)
            // We can use bit length to estimate power of 2 needed.
            b2n.shiftRight(prevBitsDiff - bitsDiff); // using bits offset saves us b2n.copy()
            prevBitsDiff = bitsDiff;

            // it's possible that b2n is now larger than a, in which case we have to shift right 1 bit
            if(b2n.moreThan(this) == true)
            {
                b2n.shiftRight(1);
                prevBitsDiff--;
            }

            // reduce a
            this.absDifference(b2n, this);

            // reset for next iteration
            aNumBits = this.getBitLength();
            bitsDiff = aNumBits - bNumBits;
        }

        // finish with simple subtract until we get there shouldn't need more than 2 subtractions total, since a can't be more than one bit bigger than b now
        while(this.moreThanOrEqual(divisor) == true)
        {
            this.absDifference(divisor, this);
        }
    }

    // Raise this (base) to exponent exp.
    void power(BigInt exp)
    {
        // special cases first
        if(exp.isZero() == true)
        {
            this.set(1);
            return;
        }

        if(exp.equals(1) == true)
            return;

        if(this.isZero() == true)
            return;

        if(this.equals(1) == true)
            return;

        BigInt result = powerSq(BigInt(this), BigInt(exp));

        this.copy(result);
    }

    // Recursive calculation of power squared
    BigInt powerSq(BigInt base, BigInt exp)
    {
        // Exponentiation by squaring algorithm here

        if(exp.isZero() == true)
            return BigInt(1);
        else if(exp.equals(1) == true)
            return base;
        else if(exp.isOdd() == true)
        {
            BigInt sqBase(base);
            sqBase.multiply(base);
            BigInt result(base);
            BigInt exp2(exp);
            exp2.shiftRight(1);
            result.multiply(powerSq(sqBase, exp2));
            return result;
        }
        
        // even exponent
        BigInt sqBase(base);
        sqBase.multiply(base);
        BigInt result(base);
        BigInt exp2(exp);
        exp2.shiftRight(1);
        return powerSq(sqBase, exp2);
    }

    // Raise this (base) to exponent exp modulo m.
    void moduloPower(BigInt exp, BigInt m)
    {
        BigInt e(exp);

        if(m.equals(1) == true)
        {
            this.set(0);
            return;
        }

        // Exponentiation by squaring algorithm here

        BigInt r(1); // result
        BigInt b(this); // base
        b.moduloFast(m);

        while(e.isZero() == false)
        {
            if(e.isOdd() == true)
            {
                r.multiply(b);
                r.moduloFast(m);
            }

            e.shiftRight(1); // divide by 2
            b.multiply(b);
            b.moduloFast(m);
        }

        this.copy(r);
    }

    // Calculate greatest common divisor between this and b.
    void greatestCommonDivisor(BigInt q)
    {
        BigInt q2(q);

        // Euclidean algorithm
        BigInt temp();
        while(q2.isZero() == false)
        {
            temp.copy(q2);
            this.modulo(q2);
            q2.copy(this);
            this.copy(temp);
        }
    }
    
    // Greated common denominator using extended Euclidean algorithm. Used to implement modInv()
    BigInt greatestCommonDivisorExtended(BigInt a, BigInt b, BigInt xOut, BigInt yOut)
    {
        // Extended Euclidean algorithm
        if(a.isZero())
        {
            xOut.set(0);
            yOut.set(1);
            return BigInt(b);
        }

        BigInt x1(1);
        BigInt y1(1);

        BigInt b1(b);
        b1.modulo(a);

        BigInt gcd = greatestCommonDivisorExtended(b1, BigInt(a), x1, y1);

        // calculate xOut
        BigInt bDivA(b);
        bDivA.divide(a);
        bDivA.multiply(x1);
        xOut.copy(y1);
        xOut.subtract(bDivA);

        yOut.copy(x1);

        return gcd;
    }

    // Modulo inverse = 1 / this mod b
    void modInv(BigInt bIn)
    {
        BigInt a(this);
        BigInt b(bIn);

        if(b.isNegative())
            b.sign = 1;

        if(a.isNegative())
        {
            a.sign = 1;
            a.modulo(b);

            BigInt tempB(b);
            tempB.subtract(a);

            a.copy(tempB);
        }

        BigInt t(0);
        BigInt nt(1);
        BigInt r(b);
        BigInt nr(a);
        nr.modulo(b);
        BigInt q();
        BigInt tmp();
        BigInt tmp2();

        while(nr.isZero() == false)
        {
            q.copy(r);
            q.divide(nr);

            tmp.copy(nt);

            tmp2.copy(q);
            tmp2.multiply(nt);
            nt.copy(t);
            nt.subtract(tmp2);

            t.copy(tmp);

            tmp.copy(nr);

            tmp2.copy(q);
            tmp2.multiply(nr);
            nr.copy(r);
            nr.subtract(tmp2);

            r.copy(tmp);
        }

        if(r.moreThan(ONE))
        {
            this.set(-1);
            return; // No inverse
        }

        if(t.isNegative())
            t.add(b);

        this.copy(t);
    }

    // Set value from u8.
    void set(u8 newVal) { set(u32(newVal)); }

    // Set value from i8.
    void set(i8 newVal) { set(i32(newVal)); }

    // Set value from u16.
    void set(u16 newVal) { set(u32(newVal)); }

    // Set value from i16.
    void set(i16 newVal) { set(i32(newVal)); }

    // Set value from u32.
    void set(u32 newVal)
    {
        this.clear();

        if(newVal < 0)
            this.sign = -1;
        else
            this.sign = 1;

        this.numbers[0] = newVal;
        this.numUsed = 1;
    }

    // Set value from i32.
    void set(i32 newVal)
    {
        this.clear();

        if(newVal < 0)
            this.sign = -1;
        else
            this.sign = 1;

        this.numbers[0] = Math:abs(newVal);
        this.numUsed = 1;
    }

    // Set value from u64.
    void set(u64 newVal)
    {
        this.clear();
        this.sign = 1;
        if(this.numbers.length() < 2)
            this.resize(2);

        u64 numU32s = newVal >> 32; // divide by POW_2_TO_32;
        this.numbers[0] = newVal - (numU32s << 32); // multiply by POW_2_TO_32
        this.numbers[1] = numU32s;
        this.numUsed = 2;
        if(numU32s == 0)
            this.numUsed = 1;
    }

    // Set value from i64.
    void set(i64 newVal)
    {
        set(u64(Math:abs(newVal)));
        if(newVal < 0)
            this.sign = -1;
    }

    // Set from decimal string. If string has "0b" prefix, assumed to be binary string. If string has "0x" prefix, assumed to be hexadecimal string. 
    void set(String<u8> str)
    {
        if(str.beginsWith("0b") || str.beginsWith("+0b") || str.beginsWith("-0b") || str.beginsWith("0B") || str.beginsWith("+0B") || str.beginsWith("-0B"))
        {
            setFromBase2String(str);
        }
        else if(str.beginsWith("0x") || str.beginsWith("+0x") || str.beginsWith("-0x") || str.beginsWith("0X") || str.beginsWith("+0X") || str.beginsWith("-0X"))
        {
            setFromBase16String(str);
        }
        else
        {
            setFromBase10String(str);
        }
    }

    // Set from string specifying base (base 2, 10, 16 supported)
    void set(String<u8> str, u8 base)
    {
        if(base == 2)
        {
            setFromBase2String(str);
        }
        else if(base == 16)
        {
            setFromBase16String(str);
        }
        else
        {
            setFromBase10String(str);
        }
    }

    // Set num from UTF8 string (assumed to be binary, AKA base-2). Format can be zero and ones, or with a leading "0b" before 0/1s. Can have negative sign.
    void setFromBase2String(String<u8> str)
    {
        clear();

        if(str == null)
            return;

        str = str.clone();
        str.trimWhitespace();

        if(str.length() == 0)
            return;

        // handle sign
        u8 finalSign = 1;
        if(str.chars[0] == Chars:HYPHEN)
        {
            str = str.subString(1, str.length()-1);
            finalSign = -1;
        }
        else if(str.chars[0] == Chars:PLUS)
        {
            str = str.subString(1, str.length()-1);
            finalSign = 1;
        }

        if(str.length() == 0)
            return;

        // handle 0b prefix
        if(str.beginsWith("0b") || str.beginsWith("0B"))
            str = str.subString(2, str.length()-1);

        if(str.length() == 0)
            return;

        if(str.length() > 16384)
            return; // there's a limit to this madness

        // eat any leading zeros
        while(str.length() > 0)
        {
            if(str.chars[0] == Chars:ZERO)
                str = str.subString(1, str.length()-1);
            else
                break;
        }

        str.removeAll(Chars:SPACE); // inner number spacing

        u32 numBitsNeeded = str.length();
        u32 numU32s = numBitsNeeded / 32;
        if((numBitsNeeded % 32) != 0)
            numU32s++;

        this.resize(numU32s);
        this.numUsed = numU32s;

        // process from end (least bit) to start.
        u32 bitIndex = 0;
        u32 u32Index = 0;
        for(i64 i=str.length()-1; i>=0; i--)
        {
            u8 ch = str.chars[i];
            u32 bitVal = 0;
            if(ch == Chars:ZERO)
            {
                bitVal = 0;
            }
            else if(ch == Chars:ONE)
            {
                bitVal = 1;
            }
            else
            {
                this.sign = finalSign;
                return;
            }

            u32 curU32 = this.numbers[u32Index];
            u32 bitU32 = bitVal << bitIndex;
            this.numbers[u32Index] = curU32 | bitU32;

            bitIndex++;
            if(bitIndex == 32)
            {
                u32Index++;
                bitIndex = 0;
            }
        }

        this.sign = finalSign;
    }

    // Set num from UTF8 string (assumed to be hexadecimal, AKA base-16). Format can have prefix "0x". Can have negative sign.
    void setFromBase16String(String<u8> str)
    {
        clear();

        if(str == null)
            return;

        str = str.clone();
        str.trimWhitespace();

        if(str.length() == 0)
            return;

        // handle sign
        u8 finalSign = 1;
        if(str.chars[0] == Chars:HYPHEN)
        {
            str = str.subString(1, str.length()-1);
            finalSign = -1;
        }
        else if(str.chars[0] == Chars:PLUS)
        {
            str = str.subString(1, str.length()-1);
            finalSign = 1;
        }

        if(str.length() == 0)
            return;

        // handle 0b prefix
        if(str.beginsWith("0x") || str.beginsWith("0X"))
            str = str.subString(2, str.length()-1);

        if(str.length() == 0)
            return;

        if(str.length() > 4096)
            return; // there's a limit to this madness

        // eat any leading zeros
        while(str.length() > 0)
        {
            if(str.chars[0] == Chars:ZERO)
                str = str.subString(1, str.length()-1);
            else
                break;
        }

        str.removeAll(Chars:SPACE); // inner number spacing

        u32 numBitsNeeded = str.length() * 4;
        u32 numU32s = numBitsNeeded / 32;
        if((numBitsNeeded % 32) != 0)
            numU32s++;

        this.resize(numU32s);
        this.numUsed = numU32s;

        // process from end (least value) to start.
        u32 bitIndex = 0;
        u32 u32Index = 0;
        for(i64 i=str.length()-1; i>=0; i--)
        {
            u8 ch = str.chars[i];
            u32 val = 0;
            if(ch >= Chars:ZERO && ch <= Chars:NINE)
            {
                val = ch - Chars:ZERO;
            }
            else if(ch >= Chars:A && ch <= Chars:F)
            {
                val = 10 + (ch - Chars:A);
            }
            else if(ch >= Chars:a && ch <= Chars:f)
            {
                val = 10 + (ch - Chars:a);
            }
            else
            {
                this.sign = finalSign;
                return;
            }

            u32 curU32  = this.numbers[u32Index];
            val = val << bitIndex;
            this.numbers[u32Index] = curU32 | val;

            bitIndex += 4;
            if(bitIndex == 32)
            {
                u32Index++;
                bitIndex = 0;
            }
        }

        this.sign = finalSign;
    }

    // Set num from UTF8 string (assumed to be decimal, AKA base-10).
    void setFromBase10String(String<u8> str)
    {
        clear();

        if(str == null)
            return;

        str = str.clone();
        str.trimWhitespace();

        if(str.length() == 0)
            return;

        // handle sign
        u8 finalSign = 1;
        if(str.chars[0] == Chars:HYPHEN)
        {
            str = str.subString(1, str.length()-1);
            finalSign = -1;
        }
        else if(str.chars[0] == Chars:PLUS)
        {
            str = str.subString(1, str.length()-1);
            finalSign = 1;
        }

        if(str.length() > 5000)
            return; // there's a limit to this madness

        // eat any leading zeros
        while(str.length() > 0)
        {
            if(str.chars[0] == Chars:ZERO)
                str = str.subString(1, str.length()-1);
            else
                break;
        }

        str.removeAll(Chars:SPACE); // inner number spacing

        // process digits from end (least) to start.
        BigInt numDigit();
        BigInt numPow10(1);
        BigInt num10(10);
        for(i64 i=str.length()-1; i>=0; i--)
        {
            // we could do 10+ digits at a time in a single u64 but this is fine too. Convert base 10 into base 2^32...
            u8 ch = str.chars[i];
            if(ch < Chars:ZERO || ch > Chars:NINE)
            {
                this.sign = finalSign;
                return;
            }

            numDigit.set(i32(ch - Chars:ZERO));
            numDigit.multiply(numPow10);
            this.add(numDigit);

            // prepare for next digit
            numPow10.multiply(num10);
        }

        this.sign = finalSign;
    }

    // Calculate number of bits to represent number (not including sign).
    u32 getBitLength()
    {
        if(this.numUsed == 0)
            return 0;

        u32 numBits = (this.numUsed-1) * 32;

        // the last u32 could add 0 to 31 bits
        u32 lastU32 = this.numbers[this.numUsed - 1];
        u32 numLastBits = 0;
        while(lastU32 > 0)
        {
            lastU32 = lastU32 >> 1; // drop bit
            numLastBits++;
        }

        numBits += numLastBits;
        return numBits;
    }

    // Calculate closest integer square root.
    void sqrt()
    {
        sqrt(false);
    }

    // Calculate closest integer square root. Passing true for alwaysLargerRoot will ensure that the sqrt value calculate is ceil(sqrtInt).
    void sqrt(bool alwaysLargerRoot)
    {
        BigInt x(this);

        BigInt div(1);
        div.shiftLeft(getBitLength() / 2); // roughly bit length / 2
        BigInt div2(div);

        // Loop until we hit the same value twice in a row, or wind up alternating.
        while(true)
        {
            BigInt xDiv(x);
            xDiv.divide(div);
            BigInt y(div);
            y.add(xDiv);
            y.shiftRight(1);

            if(y.equals(div) || y.equals(div2))
             {
                 // verify this is the 
                 if(alwaysLargerRoot == true)
                 {
                     BigInt rootSqd(y);
                     rootSqd.multiply(y);
                     if(rootSqd.lessThan(this) == true)
                     {
                        y.add(1); // ceil()
                     }
                 }

                 this.copy(y);
                 return;
             }

            div2 = div;
            div = y;
        }
    }

    // This uses "probablistic" methods for primes, but the odds of it being incorrect are insignificant for values less than ~16k bits long.
    bool isPrime()
    {
        /* Exhaustive test is too slow to be practical for even small numbers (128 bits).
        if(this.isEven() == true)
            return false;

        BigInt sqRoot(this);
        sqRoot.sqrt(true); // true because we want integer root that when sq'd always gives a value larger than this prime canadidate

        BigInt n(this);
        BigInt factor(3);
        while(factor.lessThan(sqRoot) == true)
        {
            n.modulo(factor);
            if(n.isZero() == true)
                return false;

            n.copy(this);
            factor.add(2); // next odd number
        }

        return true;*/

        return isProbablyPrime(128); // sufficient up to numbers ~16k bits long
    }

    // Probably check if number is prime.
    bool isProbablyPrime()
    {
        u64 bitLen = getBitLength();
        if(bitLen <= 128)
            return isProbablyPrime(16);
        else if(bitLen <= 256)
            return isProbablyPrime(24);
        else if(bitLen <= 512)
            return isProbablyPrime(32);
        else if(bitLen <= 1024)
            return isProbablyPrime(40); // rounds chosen by NIST-FIPS-186-4 C.1
        else if(bitLen <= 2048)
            return isProbablyPrime(56); // rounds chosen by NIST-FIPS-186-4 C.1
        else if(bitLen <= 3072)
            return isProbablyPrime(64); // rounds chosen by NIST-FIPS-186-4 C.1
        
        return isProbablyPrime(128); // sufficient up to numbers ~16k bits long
    }

    // Probably check if number is prime. When the value is non-prime, Miller-Rabin will detect it with probability 3/4 at each round (kTimes param).
    // For a ~1024 bit number...
    // 8  rounds gives a ~0.000015% chance of returning true when the number is not prime.
    // 16 rounds gives a ~0.0000000002% chance of returning true when the number is not prime. AKA less than 1 in a billion.
    // By ~40 rounds the risks of computer malfunction start to become dominant (0.25^40).
    bool isProbablyPrime(u32 kTimes)
    {
        if(this.equals(1) || this.equals(4))
            return false;

        if(this.equals(2) || this.equals(3) || this.equals(5) || this.equals(7))
            return true;

        // Calculate r such that n=2^d * r + 1
        BigInt d(this);
        d.subtract(1);
        while(d.isEven() && d.isZero() == false)
            d.shiftRight(1); // divide by 2

        // Test 
        for(u32 i=0; i<kTimes; i++)
        {
            if(millerRabin(d) == false)
                return false;
        }

        return true;
    }

    // Returns false if this is definitely not a prime. True indicates likely prime, with each call returning true increasing confidence.
    bool millerRabin(BigInt dIn)
    {
        BigInt d(dIn);
        BigInt n(this);
        BigInt two(2);
        BigInt nMinus1(n);
        nMinus1.subtract(1);
        BigInt nMinus4(n);
        nMinus4.subtract(4);

        BigInt a = generateFastRandom(two, nMinus4);

        BigInt x(a);
        x.moduloPower(d, n);

        if(x.equals(1) || x.equals(nMinus1))
            return true;

        // Keep sq'ing
        u32 MAX_ITERS = 4096;
        u32 numIters = 0;
        //while(d.equals(nMinus1) == false && numIters < MAX_ITERS)
        while(d.moreThanOrEqual(nMinus1) == false && numIters < MAX_ITERS)
        {
            x.moduloPower(two, n);
            d.shiftLeft(2); // multiply * 2

            if(x.equals(1))
                return false;
            if(x.equals(nMinus1))
                return true;

            numIters++;
        }

        assert(numIters < MAX_ITERS);

        return false;
    }

    // Generate random number within range of min to max (inclusive).
    shared BigInt generateFastRandom(BigInt min, BigInt max)
    {
        assert(max.moreThan(min));

        u32 numIters = 0;
        u32 MAX_ITERS = 10;
        while(numIters < MAX_ITERS)
        {
            BigInt minMaxDiff(max);
            minMaxDiff.subtract(min);

            i32 bitsRange = minMaxDiff.getBitLength();

            BigInt randOffsetFromMin = generateFastRandom(bitsRange);

            BigInt finalNum(min);
            finalNum.add(randOffsetFromMin);

            // make sure this number falls into range
            if(finalNum.moreThanOrEqual(min) && finalNum.lessThanOrEqual(max))
            {
                return finalNum;
            }
            else
            {
                // try shifting down by 1
                finalNum.shiftRight(1);

                if(finalNum.moreThan(min) && finalNum.lessThan(max))
                    return finalNum;
            }

            numIters++;
        }

        return BigInt(0);
    }

    // Generate random number of bits length. 
    shared BigInt generateFastRandom(u32 numBits)
    {
        u32 numU32s = numBits / 32;
        if((numBits % 32) != 0)
            numU32s++;

        BigInt r();
        r.resize(numU32s);
        r.numUsed = numU32s;

        // Fill r with fast random numbers.
        u8 rIndex = 0;
        for(i16 i=0; i<numU32s; i++)
        {
            r.numbers[i] = randFast.getU32();
        }

        // we could be up to 31 bits too big, shrink if needed
        i32 bitsDiff = r.getBitLength() - numBits;
        if(bitsDiff > 0)
        {
            r.shiftRight(bitsDiff);
        }

        return r;
    }

    // Generate true random number of bits length. Can be slow. Only use for crypto-secure random numbers etc.
    shared BigInt generateTrueRandom(u32 numBits)
    {
        u32 numU32s = numBits / 32;
        if((numBits % 32) != 0)
            numU32s++;

        BigInt r();
        r.resize(numU32s);
        r.numUsed = numU32s;

        // Fill r with true random numbers.
        u8 rIndex = 0;
        for(i16 i=0; i<numU32s; i++)
        {
            u64 trueRandomNumber = System:getTrueRandom();
            if(trueRandomNumber == 0)
            {
                // System isn't providing random numbers, generate something reasonable
                trueRandomNumber = randFast.getU64();
                u64 time = System:getTime();
                trueRandomNumber = trueRandomNumber ^ time;

                // log a one-time warning (per thread potentially)
                if(NO_TRUE_RANDOMS_WARNING == false)
                {
                    NO_TRUE_RANDOMS_WARNING = true;
                    String<u8> msg = "WARNING BigInt.generateTrueRandom() could not get true random number from system.";
                    Log:log("", msg);
                    Log:log("__PRONTO", msg);
                }
            }

            // use all of random u64
            r.numbers[i] = u32(trueRandomNumber & 0x00000000FFFFFFFF);
            if((i+1) < numU32s)
            {
                r.numbers[i+1] = u32((trueRandomNumber & 0xFFFFFFFF00000000) >> 32);
                i++;
            }
        }

        if((numBits % 32) != 0)
        {
            u32 clearNumBits = 32 - (numBits % 32);
            u32 bitsMask = 0xFFFFFFFF;
            bitsMask = bitsMask >> clearNumBits;
            r.numbers[numU32s-1] = bitsMask & r.numbers[numU32s-1];
        }

        return r;
    }

    // Generate probably random prime number. Max 4096 bit numbers, min 8 bits.
    shared BigInt randomProbablePrime(u32 numBits)
    {
        if(numBits > 4096)
            return null; // too big, fuck off

        if(numBits < 8)
            return null; // too small, fuck off

        BigInt n = generateTrueRandom(numBits);

        n.setBit(numBits-1, 1); // make sure top bits is 1 to ensure numBits requirment met
        n.setBit(numBits-2, 1); // make sure top bits is 1 to ensure numBits requirment met
        n.setBit(numBits-3, 0); // so number is small enough that it won't become too big (more than numBits) while search for next prime
        n.setBit(0, 1); // always odd

        u32 MAX_ITERS = 10000; // TODO should be 10 000 or more for 2048+ bits
        u32 numIters = 0;

        u64 bitLen = n.getBitLength();
        u64 numRounds = 40;
        if(bitLen <= 1024)
            numRounds = 40; // rounds chosen by NIST-FIPS-186-4 C.1
        else if(bitLen <= 2048)
            numRounds = 56; // rounds chosen by NIST-FIPS-186-4 C.1
        else if(bitLen <= 3072)
            numRounds = 64; // rounds chosen by NIST-FIPS-186-4 C.1
        else
            numRounds = 128; // sufficient for 16k etc.

        BigInt d(n);
        while(numIters < MAX_ITERS)
        {
            // n is odd at least
            if(n.isProbablyPrime(numRounds) == true)
            {
                return n;
            }
            else
            {
                // go to next odd number
                n.add(2);
            }

            assert(n.getBitLength() == numBits);

            numIters++;
        }

        //assert(false); // failed to generate prime

        return BigInt(0);
    }
}