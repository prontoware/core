////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// ByteIO
////////////////////////////////////////////////////////////////////////////////////////////////////

// Read/write primitive types from/to byte array. Default functions use little endian format which
// is native to x86-32, x86-64, ARMv7-32, ARMv8-64 for pronto on windws/linux/android/iOS. Use *Big
// functions for big endian / network byte order.
class ByteIO
{
	// Read little/big endian (same for single byte) unsigned integer.
	shared u8 readU8(u8[] bytes, u64 index)  { return bytes[index];  }

	// Read little/big endian (same for single byte) signed integer.
	shared i8 readI8(u8[] bytes, u64 index)  { i8 v = bytes[index]; return v;  }

	// Read little endian 2 bytes unsigned
	shared u16 readU16(u8[] bytes, u64 index)
	{
		u16 t = bytes[index+1];
		t = t << 8;
		u16 v = t | bytes[index];
		return v;
	}

	// Read big endian 2 bytes unsigned
	shared u16 readU16Big(u8[] bytes, u64 index)
	{
		u16 t = bytes[index];
		t = t << 8;
		u16 v = t | bytes[index+1];
		return v;
	}

	// Read little endian 2 bytes signed
	shared u16 readI16(u8[] bytes, u64 index)
	{
		u16 t = bytes[index+1];
		t = t << 8;
		i16 v = t | bytes[index];
		return v;
	}

	// Read little endian 2 bytes signed
	shared u16 readI16Big(u8[] bytes, u64 index)
	{
		u16 t = bytes[index];
		t = t << 8;
		i16 v = t | bytes[index+1];
		return v;
	}

	// Read little endian 4 bytes unsigned
	shared u32 readU32(u8[] bytes, u64 index)
	{
		u32 t = 0;
		u32 v = 0;
		
		for(u8 b=0; b<4; b++)
		{
			t = bytes[index+b];
			t = t << (8 * b);
			v |= t;
		}

		return v;
	}

	// Read big endian 4 bytes unsigned
	shared u32 readU32Big(u8[] bytes, u64 index)
	{
		u32 t = 0;
		u32 v = 0;
		
		for(u8 b=0; b<4; b++)
		{
			t = bytes[(index+3)-b];
			t = t << (8 * b);
			v |= t;
		}

		return v;
	}

	// Read little endian 4 bytes signed
	shared i32 readI32(u8[] bytes, u64 index)
	{
		u32 t = 0;
		u32 v = 0;
		
		for(u8 b=0; b<4; b++)
		{
			t = bytes[index+b];
			t = t << (8 * b);
			v |= t;
		}

		i32 castV = v;
		return castV;
	}

	// Read big endian 4 bytes signed
	shared i32 readI32Big(u8[] bytes, u64 index)
	{
		u32 t = 0;
		u32 v = 0;
		
		for(u8 b=0; b<4; b++)
		{
			t = bytes[(index+3)-b];
			t = t << (8 * b);
			v |= t;
		}

		i32 castV = v;
		return castV;
	}

	// Read little endian 8 bytes unsigned
	shared u64 readU64(u8[] bytes, u64 index)
	{
		u64 t = 0;
		u64 v = 0;
		
		for(u8 b=0; b<8; b++)
		{
			t = bytes[index+b];
			t = t << (8 * b);
			v |= t;
		}

		return v;
	}

	// Read big endian 8 bytes unsigned
	shared u64 readU64Big(u8[] bytes, u64 index)
	{
		u64 t = 0;
		u64 v = 0;
		
		for(u8 b=0; b<8; b++)
		{
			t = bytes[(index+7)-b];
			t = t << (8 * b);
			v |= t;
		}

		return v;
	}

	// Read little endian 8 bytes signed
	shared i64 readI64(u8[] bytes, u64 index)
	{
		u64 t = 0;
		u64 v = 0;
		
		for(u8 b=0; b<8; b++)
		{
			t = bytes[index+b];
			t = t << (8 * b);
			v |= t;
		}

		i64 castV = v;
		return castV;
	}

	// Read big endian 8 bytes signed
	shared i64 readI64Big(u8[] bytes, u64 index)
	{
		u64 t = 0;
		u64 v = 0;
		
		for(u8 b=0; b<8; b++)
		{
			t = bytes[(index+7)-b];
			t = t << (8 * b);
			v |= t;
		}

		i64 castV = v;
		return castV;
	}

	// Unpacks a 16 bit floating-point value (little endian) to 32 bit floating-point native type.
	shared f32 readF16(u8[] bytes, u64 index)
	{
		u16 bits16 = ByteIO:readU16(bytes, index);
		u32 hbits  = bits16;

	    u32 mant = hbits & 0x03FF;            // 10 bits mantissa
	    u32 exp =  hbits & 0x7C00;            // 5 bits exponent
		if(exp == 0x7C00 )                    // NaN/Inf
	    	exp = 0x3FC00;                    // -> NaN/Inf
	    else if(exp != 0)                     // normalized value
	    {
	        exp += 0x1C000;                   // exp - 15 + 127
	        if(mant == 0 && exp > 0x1C400)    // smooth transition
				return Math:castBitsToF32(((hbits & 0x8000) << 16) | (exp << 13) | 0x3FF);
	    }
	    else if(mant != 0)                    // && exp==0 -> subnormal
	    {
	        exp = 0x1c400;                    // make it normal

	        mant = mant << 1;                 // mantissa * 2
	        exp -= 0x400;                     // decrease exp by 1
	        while((mant & 0x400) == 0)        // while not normal
	        {
	            mant = mant << 1;             // mantissa * 2
	        	exp -= 0x400;                 // decrease exp by 1
	        }
	        mant &= 0x3FF;                    // discard subnormal bit
	    }                                     // else +/-0 -> +/-0

	    // combine all parts, sign  << ( 31 - 15 ), value << ( 23 - 10 )
	    return Math:castBitsToF32(((hbits & 0x8000 ) << 16) | ((exp | mant) << 13));         
	}

	// Unpacks a 16 bit floating-point value (big endian) to 32 bit floating-point native type.
	shared f32 readF16Big(u8[] bytes, u64 index)
	{
		u16 bits16 = ByteIO:readU16Big(bytes, index);
		u32 hbits  = bits16;

	    u32 mant = hbits & 0x03FF;            // 10 bits mantissa
	    u32 exp =  hbits & 0x7C00;            // 5 bits exponent
		if(exp == 0x7C00 )                    // NaN/Inf
	    	exp = 0x3FC00;                    // -> NaN/Inf
	    else if(exp != 0)                     // normalized value
	    {
	        exp += 0x1C000;                   // exp - 15 + 127
	        if(mant == 0 && exp > 0x1C400)    // smooth transition
				return Math:castBitsToF32(((hbits & 0x8000) << 16) | (exp << 13) | 0x3FF);
	    }
	    else if(mant != 0)                    // && exp==0 -> subnormal
	    {
	        exp = 0x1c400;                    // make it normal

	        mant = mant << 1;                 // mantissa * 2
	        exp -= 0x400;                     // decrease exp by 1
	        while((mant & 0x400) == 0)        // while not normal
	        {
	            mant = mant << 1;             // mantissa * 2
	        	exp -= 0x400;                 // decrease exp by 1
	        }
	        mant &= 0x3FF;                    // discard subnormal bit
	    }                                     // else +/-0 -> +/-0

	    // combine all parts, sign  << ( 31 - 15 ), value << ( 23 - 10 )
	    return Math:castBitsToF32(((hbits & 0x8000 ) << 16) | ((exp | mant) << 13));         
	}

	// Read little endian 4 bytes floating point value
	shared f32 readF32(u8[] bytes, u64 index)
	{
		u32 tempBits = ByteIO:readU32(bytes, index);
		return Math:castBitsToF32(tempBits);
	}

	// Read big endian 4 bytes floating point value
	shared f32 readF32Big(u8[] bytes, u64 index)
	{
		u32 tempBits = ByteIO:readU32Big(bytes, index);
		return Math:castBitsToF32(tempBits);
	}

	// Read little endian 8 bytes floating point value
	shared f64 readF64(u8[] bytes, u64 index)
	{
		u64 tempBits = ByteIO:readU64(bytes, index);
		return Math:castBitsToF64(tempBits);
	}

	// Read big endian 8 bytes floating point value
	shared f64 readF64Big(u8[] bytes, u64 index)
	{
		u64 tempBits = ByteIO:readU64Big(bytes, index);
		return Math:castBitsToF64(tempBits);
	}

	// Write single byte unsigned integer. Same for big/little endian.
	shared void writeU8(u8[] bytes, u64 index, u8 val)  { bytes[index] = val; }

	// Write single byte signed integer. Same for big/little endian.
	shared void writeI8(u8[] bytes, u64 index, i8 val)  { bytes[index] = val; }

	// Write little endian 2 byte unsigned integer.
	shared void writeU16(u8[] bytes, u64 index, u16 val)
	{
		bytes[index+0] =  0x00FF & val;
		bytes[index+1] = (0xFF00 & val) >> 8;
	}

	// Write big endian 2 byte unsigned integer.
	shared void writeU16Big(u8[] bytes, u64 index, u16 val)
	{
		bytes[index+1] =  0x00FF & val;
		bytes[index+0] = (0xFF00 & val) >> 8;
	}

	// Write little endian 2 byte signed integer.
	shared void writeI16(u8[] bytes, u64 index, i16 val)
	{
		u16 uVal = val;
		ByteIO:writeU16(bytes, index, uVal);
	}

	// Write big endian 2 byte signed integer.
	shared void writeI16Big(u8[] bytes, u64 index, i16 val)
	{
		u16 uVal = val;
		ByteIO:writeU16Big(bytes, index, uVal);
	}

	// Write little endian 4 byte unsigned integer.
	shared void writeU32(u8[] bytes, u64 index, u32 val)
	{
		bytes[index+0] =  0x000000FF & val;
		bytes[index+1] = (0x0000FF00 & val) >> 8;
		bytes[index+2] = (0x00FF0000 & val) >> 16;
		bytes[index+3] = (0xFF000000 & val) >> 24;
	}

	// Write big endian 4 byte unsigned integer.
	shared void writeU32Big(u8[] bytes, u64 index, u32 val)
	{
		bytes[index+3] =  0x000000FF & val;
		bytes[index+2] = (0x0000FF00 & val) >> 8;
		bytes[index+1] = (0x00FF0000 & val) >> 16;
		bytes[index+0] = (0xFF000000 & val) >> 24;
	}

	// Write little endian 4 byte signed integer.
	shared void writeI32(u8[] bytes, u64 index, i32 val)
	{
		u32 uVal = val;
		ByteIO:writeU32(bytes, index, uVal);
	}

	// Write big endian 4 byte signed integer.
	shared void writeI32Big(u8[] bytes, u64 index, i32 val)
	{
		u32 uVal = val;
		ByteIO:writeU32Big(bytes, index, uVal);
	}

	// Write little endian 8 byte unsigned integer.
	shared void writeU64(u8[] bytes, u64 index, u64 val)
	{
		bytes[index+0] =  0x00000000000000FF & val;
		bytes[index+1] = (0x000000000000FF00 & val) >> 8;
		bytes[index+2] = (0x0000000000FF0000 & val) >> 16;
		bytes[index+3] = (0x00000000FF000000 & val) >> 24;
		bytes[index+4] = (0x000000FF00000000 & val) >> 32;
		bytes[index+5] = (0x0000FF0000000000 & val) >> 40;
		bytes[index+6] = (0x00FF000000000000 & val) >> 48;
		bytes[index+7] = (0xFF00000000000000 & val) >> 56;
	}

	// Write big endian 8 byte unsigned integer.
	shared void writeU64Big(u8[] bytes, u64 index, u64 val)
	{
		bytes[index+7] =  0x00000000000000FF & val;
		bytes[index+6] = (0x000000000000FF00 & val) >> 8;
		bytes[index+5] = (0x0000000000FF0000 & val) >> 16;
		bytes[index+4] = (0x00000000FF000000 & val) >> 24;
		bytes[index+3] = (0x000000FF00000000 & val) >> 32;
		bytes[index+2] = (0x0000FF0000000000 & val) >> 40;
		bytes[index+1] = (0x00FF000000000000 & val) >> 48;
		bytes[index+0] = (0xFF00000000000000 & val) >> 56;
	}

	// Write little endian 8 byte signed integer.
	shared void writeI64(u8[] bytes, u64 index, i64 val)
	{
		u64 uVal = val;
		ByteIO:writeU64(bytes, index, uVal);
	}

	// Write big endian 8 byte signed integer.
	shared void writeI64Big(u8[] bytes, u64 index, i64 val)
	{
		u64 uVal = val;
		ByteIO:writeU64Big(bytes, index, uVal);
	}

	// Writes a little endian 16 bit floating-point value to the array, converting from 32 bit floating-point value.
	shared void writeF16(u8[] bytes, u64 index, f32 fval)
	{
	    u32 fbits = Math:castF32ToBits(fval);
	    u32 sign  = fbits >> 16 & 0x8000;          // sign only
	    u32 val   = (fbits & 0x7FFFFFFF) + 0x1000; // rounded value
	    u16 finalBits = 0;

	    if(val >= 0x47800000)                 // might be or become NaN/Inf
	    {                                     // avoid Inf due to rounding
			if((fbits & 0x7FFFFFFF) >= 0x47800000)
	        {                                 // is or must become NaN/Inf
				if(val < 0x7F800000)          // was value but too large
				{
	                finalBits = sign | 0x7C00;     // make it +/-Inf
	                ByteIO:writeU16(bytes, index, finalBits);
	                return;
				}

	            finalBits = sign | 0x7C00 | (fbits & 0x007FFFFF) >> 13; // remains +/-Inf or NaN, keep NaN (and Inf) bits
	            ByteIO:writeU16(bytes, index, finalBits);
	            return;
	        }

	        finalBits = sign | 0x7BFF; // unrounded not quite Inf
	        ByteIO:writeU16(bytes, index, finalBits);
	        return;
	    }

	    if(val >= 0x38800000)               // remains normalized value
	    {
	        finalBits = sign | val - 0x38000000 >> 13; // exp - 127 + 15
	        ByteIO:writeU16(bytes, index, finalBits);
	        return;
	    }

	    if(val < 0x33000000)                // too small for subnormal
	    {
	    	finalBits = sign;               // becomes +/-0
	    	ByteIO:writeU16(bytes, index, finalBits);
	        return;
	    }

	    val = (fbits & 0x7FFFFFFF) >> 23;  // tmp exp for subnormal calc

	    // add subnormal bit // round depending on cut off // div by 2^(1-(exp-127+15)) and >> 13 | exp=0
	    finalBits = sign | ((fbits & 0x7FFFFF | 0x800000) + (0x800000 >> val - 102) >> 126 - val);
	    ByteIO:writeU16(bytes, index, finalBits);
	}

	// Writes a big endian 16 bit floating-point value to the array, converting from 32 bit floating-point value.
	shared void writeF16Big(u8[] bytes, u64 index, f32 fval)
	{
	    u32 fbits = Math:castF32ToBits(fval);
	    u32 sign  = fbits >> 16 & 0x8000;          // sign only
	    u32 val   = (fbits & 0x7FFFFFFF) + 0x1000; // rounded value
	    u16 finalBits = 0;

	    if(val >= 0x47800000)                 // might be or become NaN/Inf
	    {                                     // avoid Inf due to rounding
			if((fbits & 0x7FFFFFFF) >= 0x47800000)
	        {                                 // is or must become NaN/Inf
				if(val < 0x7F800000)          // was value but too large
				{
	                finalBits = sign | 0x7C00;     // make it +/-Inf
	                ByteIO:writeU16Big(bytes, index, finalBits);
	                return;
				}

	            finalBits = sign | 0x7C00 | (fbits & 0x007FFFFF) >> 13; // remains +/-Inf or NaN, keep NaN (and Inf) bits
	            ByteIO:writeU16Big(bytes, index, finalBits);
	            return;
	        }

	        finalBits = sign | 0x7BFF; // unrounded not quite Inf
	        ByteIO:writeU16Big(bytes, index, finalBits);
	        return;
	    }

	    if(val >= 0x38800000)               // remains normalized value
	    {
	        finalBits = sign | val - 0x38000000 >> 13; // exp - 127 + 15
	        ByteIO:writeU16Big(bytes, index, finalBits);
	        return;
	    }

	    if(val < 0x33000000)                // too small for subnormal
	    {
	    	finalBits = sign;               // becomes +/-0
	    	ByteIO:writeU16Big(bytes, index, finalBits);
	        return;
	    }

	    val = (fbits & 0x7FFFFFFF) >> 23;  // tmp exp for subnormal calc

	    // add subnormal bit // round depending on cut off // div by 2^(1-(exp-127+15)) and >> 13 | exp=0
	    finalBits = sign | ((fbits & 0x7FFFFF | 0x800000) + (0x800000 >> val - 102) >> 126 - val);
	    ByteIO:writeU16Big(bytes, index, finalBits);
	}

	// Write little endian 4 byte floating point value.
	shared void writeF32(u8[] bytes, u64 index, f32 val)
	{
		u32 uVal = Math:castF32ToBits(val);
		ByteIO:writeU32(bytes, index, uVal);
	}

	// Write big endian 4 byte floating point value.
	shared void writeF32Big(u8[] bytes, u64 index, f32 val)
	{
		u32 uVal = Math:castF32ToBits(val);
		ByteIO:writeU32Big(bytes, index, uVal);
	}

	// Write little endian 8 byte floating point value.
	shared void writeF64(u8[] bytes, u64 index, f64 val)
	{
		u64 uVal = Math:castF64ToBits(val);
		ByteIO:writeU64(bytes, index, uVal);
	}

	// Write big endian 8 byte floating point value.
	shared void writeF64Big(u8[] bytes, u64 index, f64 val)
	{
		u64 uVal = Math:castF64ToBits(val);
		ByteIO:writeU64Big(bytes, index, uVal);
	}

	// Returns length of bytes written. Write format is u8 or u8+u32 string length followed by bytes of string.
	shared u64 writeString(u8[] bytes, u64 index, String<u8> val)
	{
		u64 bytesNeeded = val.numChars + 1;
		if(val.numChars >= 255)
			bytesNeeded += 4;

		if((index+bytesNeeded) > bytes.length())
			return 0;

		assert(val.length() < Math:U32_MAX);

		u64 pos = index;

		u32 len = val.numChars;
		if(len < 255)
		{
			ByteIO:writeU8(bytes, pos, len);
			pos += 1;
		}
		else
		{
			ByteIO:writeU8(bytes, pos, 255);
			pos += 1;
			ByteIO:writeU32(bytes, pos, len);
			pos += 4;
		}

		for(u32 i=0; i<len; i++)
		{
			bytes[pos] = val.chars[i];
			pos++;
		}

		return pos - index;
	}

	// Read a String<u8> value. Assumes format is u8 or u8+u32 string length followed by bytes of string.
	shared String<u8> readString(u8[] bytes, u64 index)
	{
		u64 pos = index;

		if((pos+1) > bytes.length())
			return String<u8>();

		u64 numChars = ByteIO:readU8(bytes, pos);
		pos += 1;

		if(numChars == 255)
		{
			if((pos+4) > bytes.length())
				return String<u8>();

			numChars = ByteIO:readU32(bytes, pos);
			pos += 4;
		}

		if((pos+numChars) > bytes.length())
			return String<u8>();

		String<u8> s = String<u8>(numChars);
		for(u64 i=0; i<numChars; i++)
		{
			s.chars[i] = bytes[pos];
			pos++;
		}
		s.numChars = numChars;

		return s;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// ByteVecIO
////////////////////////////////////////////////////////////////////////////////////////////////////

// Read/write primitive types from/to byte vector. i.e. Vec could be u8[4], u8[32] ... Little endian
// only.
class ByteVecIO<Vec>
{
	shared u8 readU8(Vec bytes, u64 index)  { return bytes[index];  }

	shared u8 readBool(Vec bytes, u64 index)
	{
		u8 val = bytes[index];
		if(val == 1)
			return true; 
			
		return false;
	}

	shared i8 readI8(Vec bytes, u64 index)  { i8 v = bytes[index]; return v;  }

	shared u16 readU16(Vec bytes, u64 index)
	{
		u16 t = bytes[index+1];
		t = t << 8;
		u16 v = t | bytes[index];
		return v;
	}

	shared u16 readI16(Vec bytes, u64 index)
	{
		u16 t = bytes[index+1];
		t = t << 8;
		i16 v = t | bytes[index];
		return v;
	}

	shared u32 readU32(Vec bytes, u64 index)
	{
		u32 t = 0;
		u32 v = 0;
		
		for(u8 b=0; b<4; b++)
		{
			t = bytes[index+b];
			t = t << (8 * b);
			v |= t;
		}

		return v;
	}

	shared i32 readI32(Vec bytes, u64 index)
	{
		u32 t = 0;
		u32 v = 0;
		
		for(u8 b=0; b<4; b++)
		{
			t = bytes[index+b];
			t = t << (8 * b);
			v |= t;
		}

		i32 castV = v;
		return castV;
	}

	shared u64 readU64(Vec bytes, u64 index)
	{
		u64 t = 0;
		u64 v = 0;
		
		for(u8 b=0; b<8; b++)
		{
			t = bytes[index+b];
			t = t << (8 * b);
			v |= t;
		}

		return v;
	}

	shared i64 readI64(Vec bytes, u64 index)
	{
		u64 t = 0;
		u64 v = 0;
		
		for(u8 b=0; b<8; b++)
		{
			t = bytes[index+b];
			t = t << (8 * b);
			v |= t;
		}

		i64 castV = v;
		return castV;
	}

	// Unpacks a 16 bit floating-point value to 32 bit floating-point native type.
	shared f32 readF16(Vec bytes, u64 index)
	{
		u16 bits16 = ByteVecIO<Vec>:readU16(bytes, index);
		u32 hbits  = bits16;

	    u32 mant = hbits & 0x03FF;            // 10 bits mantissa
	    u32 exp =  hbits & 0x7C00;            // 5 bits exponent
		if(exp == 0x7C00 )                    // NaN/Inf
	    	exp = 0x3FC00;                    // -> NaN/Inf
	    else if(exp != 0)                     // normalized value
	    {
	        exp += 0x1C000;                   // exp - 15 + 127
	        if(mant == 0 && exp > 0x1C400)    // smooth transition
				return Math:castBitsToF32(((hbits & 0x8000) << 16) | (exp << 13) | 0x3FF);
	    }
	    else if(mant != 0)                    // && exp==0 -> subnormal
	    {
	        exp = 0x1c400;                    // make it normal

	        mant = mant << 1;                 // mantissa * 2
	        exp -= 0x400;                     // decrease exp by 1
	        while((mant & 0x400) == 0)        // while not normal
	        {
	            mant = mant << 1;             // mantissa * 2
	        	exp -= 0x400;                 // decrease exp by 1
	        }
	        mant &= 0x3FF;                    // discard subnormal bit
	    }                                     // else +/-0 -> +/-0

	    // combine all parts, sign  << ( 31 - 15 ), value << ( 23 - 10 )
	    return Math:castBitsToF32(((hbits & 0x8000 ) << 16) | ((exp | mant) << 13));         
	}

	shared f32 readF32(Vec bytes, u64 index)
	{
		u32 tempBits = ByteVecIO<Vec>:readU32(bytes, index);
		return Math:castBitsToF32(tempBits);
	}

	shared f64 readF64(Vec bytes, u64 index)
	{
		u64 tempBits = ByteVecIO<Vec>:readU64(bytes, index);
		return Math:castBitsToF64(tempBits);
	}

	shared Vec writeU8(Vec bytes, u64 index, u8 val)  { bytes[index] = val; return bytes; }

	shared Vec writeBool(Vec bytes, u64 index, bool val)  { bytes[index] = val; return bytes; }

	shared Vec writeI8(Vec bytes, u64 index, i8 val)  { bytes[index] = val; return bytes; }

	shared Vec writeU16(Vec bytes, u64 index, u16 val)
	{
		bytes[index+0] =  0x00FF & val;
		bytes[index+1] = (0xFF00 & val) >> 8;
		return bytes;
	}

	shared Vec writeI16(Vec bytes, u64 index, i16 val)
	{
		u16 uVal = val;
		return ByteVecIO<Vec>:writeU16(bytes, index, uVal);
	}

	shared Vec writeU32(Vec bytes, u64 index, u32 val)
	{
		bytes[index+0] =  0x000000FF & val;
		bytes[index+1] = (0x0000FF00 & val) >> 8;
		bytes[index+2] = (0x00FF0000 & val) >> 16;
		bytes[index+3] = (0xFF000000 & val) >> 24;
		return bytes;
	}

	shared Vec writeI32(Vec bytes, u64 index, i32 val)
	{
		u32 uVal = val;
		return ByteVecIO<Vec>:writeU32(bytes, index, uVal);
	}

	shared Vec writeU64(Vec bytes, u64 index, u64 val)
	{
		bytes[index+0] =  0x00000000000000FF & val;
		bytes[index+1] = (0x000000000000FF00 & val) >> 8;
		bytes[index+2] = (0x0000000000FF0000 & val) >> 16;
		bytes[index+3] = (0x00000000FF000000 & val) >> 24;
		bytes[index+4] = (0x000000FF00000000 & val) >> 32;
		bytes[index+5] = (0x0000FF0000000000 & val) >> 40;
		bytes[index+6] = (0x00FF000000000000 & val) >> 48;
		bytes[index+7] = (0xFF00000000000000 & val) >> 56;
		return bytes;
	}

	shared Vec writeI64(Vec bytes, u64 index, i64 val)
	{
		u64 uVal = val;
		return ByteVecIO<Vec>:writeU64(bytes, index, uVal);
	}

	// Writes a 16 bit floating-point value to the array, converting from 32 bit floating-point value.
	shared Vec writeF16(Vec bytes, u64 index, f32 fval)
	{
	    u32 fbits = Math:castF32ToBits(fval);
	    u32 sign  = fbits >> 16 & 0x8000;          // sign only
	    u32 val   = (fbits & 0x7FFFFFFF) + 0x1000; // rounded value
	    u16 finalBits = 0;

	    if(val >= 0x47800000)                 // might be or become NaN/Inf
	    {                                     // avoid Inf due to rounding
			if((fbits & 0x7FFFFFFF) >= 0x47800000)
	        {                                 // is or must become NaN/Inf
				if(val < 0x7F800000)          // was value but too large
				{
	                finalBits = sign | 0x7C00;     // make it +/-Inf
	                return ByteVecIO<Vec>:writeU16(bytes, index, finalBits);
				}

	            finalBits = sign | 0x7C00 | (fbits & 0x007FFFFF) >> 13; // remains +/-Inf or NaN, keep NaN (and Inf) bits
	            return ByteVecIO<Vec>:writeU16(bytes, index, finalBits);
	        }

	        finalBits = sign | 0x7BFF; // unrounded not quite Inf
	        return ByteVecIO<Vec>:writeU16(bytes, index, finalBits);
	    }

	    if(val >= 0x38800000)               // remains normalized value
	    {
	        finalBits = sign | val - 0x38000000 >> 13; // exp - 127 + 15
	        return ByteVecIO<Vec>:writeU16(bytes, index, finalBits);
	    }

	    if(val < 0x33000000)                // too small for subnormal
	    {
	    	finalBits = sign;               // becomes +/-0
	    	return ByteVecIO<Vec>:writeU16(bytes, index, finalBits);
	    }

	    val = (fbits & 0x7FFFFFFF) >> 23;  // tmp exp for subnormal calc

	    // add subnormal bit // round depending on cut off // div by 2^(1-(exp-127+15)) and >> 13 | exp=0
	    finalBits = sign | ((fbits & 0x7FFFFF | 0x800000) + (0x800000 >> val - 102) >> 126 - val);
	    return ByteVecIO<Vec>:writeU16(bytes, index, finalBits);
	}

	shared Vec writeF32(Vec bytes, u64 index, f32 val)
	{
		u32 uVal = Math:castF32ToBits(val);
		return ByteVecIO<Vec>:writeU32(bytes, index, uVal);
	}

	shared Vec writeF64(Vec bytes, u64 index, f64 val)
	{
		u64 uVal = Math:castF64ToBits(val);
		return ByteVecIO<Vec>:writeU64(bytes, index, uVal);
	}

	// Write format is u8 or u8+u32 string length followed by bytes of string.
	shared Vec writeString(Vec bytes, u64 index, String<u8> val)
	{
		u64 bytesNeeded = val.numChars + 1;
		if(val.numChars >= 255)
			bytesNeeded += 4;

		//if((index+bytesNeeded) > bytes.length())
		//	return 0;

		assert(val.length() < Math:U32_MAX);

		u64 pos = index;

		u32 len = val.numChars;
		if(len < 255)
		{
			ByteVecIO<Vec>:writeU8(bytes, pos, len);
			pos += 1;
		}
		else
		{
			ByteVecIO<Vec>:writeU8(bytes, pos, 255);
			pos += 1;
			ByteVecIO<Vec>:writeU32(bytes, pos, len);
			pos += 4;
		}

		for(u32 i=0; i<len; i++)
		{
			bytes[pos] = val.chars[i];
			pos++;
		}

		return bytes;
	}

	// Read a String<u8> value. Assumes format is u8 or u8+u32 string length followed by bytes of string.
	String<u8> readString(Vec bytes, u64 index)
	{
		u64 pos = index;

		//if((pos+1) > bytes.length())
		//	return String<u8>();

		u64 numChars = ByteVecIO<Vec>:readU8(bytes, pos);
		pos += 1;

		if(numChars == 255)
		{
			//if((pos+4) > bytes.length())
			//	return String<u8>();

			numChars = ByteVecIO<Vec>:readU32(bytes, pos);
			pos += 4;
		}

		//if((pos+numChars) > bytes.length())
		//	return String<u8>();

		String<u8> s = String<u8>(numChars);
		for(u64 i=0; i<numChars; i++)
		{
			s.chars[i] = bytes[pos];
			pos++;
		}
		s.numChars = numChars;

		return s;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// ByteArray
////////////////////////////////////////////////////////////////////////////////////////////////////

// Read/write primitive types from/to backing byte array. Use index property to change read/write
// location. Default is little endian, but can be switch via bigEndian = true;
class ByteArray
{
	bool bigEndian = false; // set to true for big endian read/write (AKA network byte order)
	u8[] data      = null;  // backing data
	u64  numUsed   = 0;     // number of bytes (elements of array) used
	u64  index     = 0;     // current index to read/write from/to

	// Empty array
	void constructor()
	{
		this.data    = null;
		this.numUsed = 0;
		this.index   = 0;
	}

	// Create with allocated backing array.
	void constructor(u64 allocatedSize)
	{
		this.data    = u8[](allocatedSize);
		this.numUsed = 0;
		this.index   = 0;
	}

	// Create with allocated backing array.
	void constructor(u64 allocatedSize, u64 numUsed)
	{
		this.data    = u8[](allocatedSize);
		this.numUsed = numUsed;
		this.index   = 0;
	}

	// Create with allocated backing array. ByteArray now owns data.
	void constructor(u8[] data)
	{
		this.data    = data;
		this.numUsed = data.length();
		this.index   = 0;
	}

	// Create with allocated backing array. ByteArray now owns data.
	void constructor(u8[] data, u64 numUsed)
	{
		this.data    = data;
		this.numUsed = numUsed;
		this.index   = 0;
	}

	// Create with allocated backing array, copying string bytes over.
	void constructor(String<u8> strBytes)
	{
		this.numUsed = strBytes.length();
		this.data    = u8[](strBytes.length());
		this.index   = this.numUsed;

		for(u64 c=0; c<strBytes.length(); c++)
			data[c] = strBytes.chars[c];
	}

	// Create copy
	void constructor(ByteArray b)
	{
		copy(b);
	}

	// Bytes to string (ASCII/UTF8). Creates copy of data.
	String<u8> toString()
	{
		String<u8> str(numUsed);
		str.numChars = numUsed;
		for(u64 c=0; c<numUsed; c++)
			str.chars[c] = data[c];
		return str;
	}

	// To hex string. Each byte represented as two hex digits.
	String<u8> toHexString()
	{
		return toHexString(true);
	}

	// To hex string. Each byte represented as two hex digits.
	String<u8> toHexString(bool addWhitespace)
	{
		if(data == null || numUsed == 0)
			return "";

		String<u8> s(numUsed * 3);

		u8[16] hexChars = u8(Chars:ZERO, Chars:ONE, Chars:TWO, Chars:THREE, Chars:FOUR, Chars:FIVE, Chars:SIX, Chars:SEVEN, 
							 Chars:EIGHT, Chars:NINE, Chars:A, Chars:B, Chars:C, Chars:D, Chars:E, Chars:F);

		if(addWhitespace == true)
		{
			s.numChars = (numUsed * 3) - 1;

			for(u64 b=0; b<numUsed; b++)
			{
				u8 val = data[b];
				s.chars[(b*3) + 0] = hexChars[(val & 0b11110000) >> 4];
				s.chars[(b*3) + 1] = hexChars[(val & 0b00001111)];

				if(((b+1) % 40) == 0 && b != 0)
				{
					s.chars[(b*3) + 2] = Chars:NEW_LINE;
				}
				else
				{
					s.chars[(b*3) + 2] = Chars:SPACE;
				}
			}
		}
		else
		{
			s.numChars = (numUsed * 2);

			for(u64 b=0; b<numUsed; b++)
			{
				u8 val = data[b];

				s.chars[(b*2) + 0] = hexChars[(val & 0b11110000) >> 4];
				s.chars[(b*2) + 1] = hexChars[(val & 0b00001111)];
			}
		}

		return s;
	}

	// Get exact sized array of bytes of data.
	u8[] toArray()
	{
		u8[] a(numUsed);

		for(u64 i=0; i<numUsed; i++)
			a[i] = data[i];

		return a;
	}

	// Set endian (big/little) format to work with which changes how the byte order is interpreted.
	void setBigEndian() { this.bigEndian = true; }

	// Set endian (big/little) format to work with which changes how the byte order is interpreted.
	void setLittleEndian() { this.bigEndian = false; }

	// Get the current index into the array of backing data.
	u64 getIndex() { return index; }

	// Set the current index into the array of backing data.
	void setIndex(u64 index) { this.index = index; }

	// Set read/write index to zero, number of used bytes to zero.
	void clear()
	{
		this.index = 0;
		this.numUsed = 0;
	}

	// Zero all bytes.
	void zero()
	{
		if(this.data == null)
			return;

		for(u64 i=0; i<this.data.length(); i++)
			this.data[i] = 0;
	}

	// Overload [] operator
	u8 get(u64 index)
	{
		return data[index];
	}

	// Overload [] operator
	void set(u64 index, u8 value)
	{
		data[index] = value;
	}

	// Get allocated size
	u64 getAllocatedSize()
	{
		if(data == null)
			return 0;

		return data.length();
	}

	// Get used size.
	u64 size()
	{
		if(data == null)
			return 0;

		return numUsed;
	}

	// Get remaining bytes left to read from index to numUsed.
	u64 getNumBytesLeft()
	{
		if(data == null)
			return 0;

		return numUsed - index;
	}

	// Copy passed-in objects data.
	void copy(ByteArray b)
	{
		if(b.data == null)
		{
			this.data    = null;
			this.numUsed = 0;
		}
		else if(b.data.length() == 0)
		{
			this.data    = null;
			this.numUsed = 0;
		}
		else
		{
			this.data    = u8[](b.data.length());
			this.numUsed = b.numUsed;
			this.data.copy(b.data, 0, 0, b.numUsed);
		}

		this.index = this.numUsed;
	}

	// Get exact clone.
	ByteArray clone()
	{
		return ByteArray(this);
	}

	// Get a clone of partial data.
	ByteArray subset(u64 startIndex, u64 numBytes)
	{
		ByteArray a(numBytes);
		a.numUsed = 0;

		if(startIndex >= this.numUsed)
			return a;

		if((startIndex + numBytes) > this.numUsed)
			numBytes = this.numUsed - startIndex;

		for(u64 i=0; i<numBytes; i++)
			a.data[i] = this.data[startIndex + i];

		a.numUsed = numBytes;

		return a;
	}

	// Remove a chunk of data. Moves data above into place.
	void remove(u64 startIndex, u64 numBytes)
	{
		if(startIndex >= this.numUsed)
			return;

		if((startIndex + numBytes) > this.numUsed)
		{
			numBytes -= (startIndex + numBytes) - this.numUsed;
		}

		u64 startIndexNew = startIndex + numBytes;
		for(u64 i=0; i<this.numUsed; i++)
		{
			if((startIndexNew + i) >= this.numUsed)
				break;

			data[startIndex + i] = data[startIndexNew + i];
		}

		if(numBytes <= this.numUsed)
			this.numUsed -= numBytes;
		else
			this.numUsed = 0;
	}

	// Are equivalent?
	bool compare(ByteArray file)
	{
		if(this.numUsed != file.numUsed)
			return false;

		for(u64 b=0; b<numUsed; b++)
		{
			if(data[b] != file.data[b])
				return false;
		}

		return true;
	}

	// Resize, preserving existing data.
	void resize(u64 newSize)
	{
		u8[] newData = u8[](newSize);
		
		if(data != null)
		{
			u64 copySize = Math:min(newSize, numUsed);
			numUsed = copySize;

			// preserve existing data
			for(u64 i=0; i<copySize; i++)
				newData[i] = data[i];
		}
		else
			numUsed = 0;

		data = newData;
	}

	// Increased this.numUsed by "numBytes" checking there is sufficient allocated space, and resizing backing array if necessary.
	bool validateWrite(u64 pos, u64 numBytes)
	{
		if(data == null)
			resize(1024);

		if(pos + numBytes >= numUsed)
		{
			if(pos + numBytes >= data.length())
				resize(((data.length() + 1) + numBytes) * 2);

			numUsed = pos + numBytes;
		}

		return true;
	}

	// Set a sequence of bytes to a single value.
	void writeBytes(u64 numBytes, u8 val)
	{
		validateWrite(index, numBytes);

		for(u64 p=0; p<numBytes; p++)
		{
			data[index + p] = val;
		}

		index += numBytes;
	}

	// Copy an array of data to this.
	void write(u8[] bytes)
	{
		validateWrite(index, bytes.length());

		for(u64 p=0; p<bytes.length(); p++)
		{
			data[index + p] = bytes[p];
		}

		index += bytes.length();
	}

	// Copy a subset of the passed-in array to this.
	void write(u8[] bytes, u64 numBytes)
	{
		validateWrite(index, numBytes);

		for(u64 p=0; p<numBytes; p++)
		{
			data[index + p] = bytes[p];
		}

		index += numBytes;
	}

	// Copy a subset of the passed-in array to this.
	void write(u8[] bytes, u64 startIndex, u64 numBytes)
	{
		validateWrite(index, numBytes);

		for(u64 p=0; p<numBytes; p++)
		{
			data[index + p] = bytes[startIndex + p];
		}

		index += numBytes;
	}

	// Copy an array of data to this.
	void write(ByteArray bytes)
	{
		validateWrite(index, bytes.numUsed);

		for(u64 p=0; p<bytes.numUsed; p++)
		{
			data[index + p] = bytes.data[p];
		}

		index += bytes.numUsed;
	}

	// Copy a subset of the passed-in array to this.
	void write(ByteArray bytes, u64 startIndex, u64 numBytes)
	{
		validateWrite(index, numBytes);

		for(u64 p=0; p<numBytes; p++)
		{
			data[index + p] = bytes.data[startIndex + p];
		}

		index += numBytes;
	}

	// Write value to index.
	void writeU8(u8 val)
	{
		validateWrite(index, 1);
		data[index] = val;
		index += 1;
	}

	// Write value to index.
	void writeI8(i8 val)
	{
		validateWrite(index, 1);
		ByteIO:writeI8(data, index, val);
		index += 1;
	}

	// Write value to index.
	void writeBool(bool val)
	{
		validateWrite(index, 1);
		data[index] = val;
		index += 1;
	}

	// Write value to index.
	void writeU16(u16 val)
	{
		validateWrite(index, 2);
		if(bigEndian == false)
			ByteIO:writeU16(data, index, val);
		else
			ByteIO:writeU16Big(data, index, val);
		index += 2;
	}

	// Write value to index.
	void writeI16(i16 val)
	{
		validateWrite(index, 2);
		if(bigEndian == false)
			ByteIO:writeI16(data, index, val);
		else
			ByteIO:writeI16Big(data, index, val);
		index += 2;
	}

	// Write value to index.
	void writeU32(u32 val)
	{
		validateWrite(index, 4);
		if(bigEndian == false)
			ByteIO:writeU32(data, index, val);
		else
			ByteIO:writeU32Big(data, index, val);
		index += 4;
	}

	// Write value to index.
	void writeI32(i32 val)
	{
		validateWrite(index, 4);
		if(bigEndian == false)
			ByteIO:writeI32(data, index, val);
		else
			ByteIO:writeI32Big(data, index, val);
		index += 4;
	}

	// Write value to index.
	void writeU64(u64 val)
	{
		validateWrite(index, 8);
		if(bigEndian == false)
			ByteIO:writeU64(data, index, val);
		else
			ByteIO:writeU64Big(data, index, val);
		index += 8;
	}

	// Write value to index.
	void writeI64(i64 val)
	{
		validateWrite(index, 8);
		if(bigEndian == false)
			ByteIO:writeI64(data, index, val);
		else
			ByteIO:writeI64Big(data, index, val);
		index += 8;
	}

	// Write value to index.
	void writeF32(f32 val)
	{
		validateWrite(index, 4);
		if(bigEndian == false)
			ByteIO:writeF32(data, index, val);
		else
			ByteIO:writeF32Big(data, index, val);
		index += 4;
	}

	// Write value to index.
	void writeF64(f64 val)
	{
		validateWrite(index, 8);
		if(bigEndian == false)
			ByteIO:writeF64(data, index, val);
		else
			ByteIO:writeF64Big(data, index, val);
		index += 8;
	}

	// Write string to index. Write format is u8 or u8+u32 string length followed by characters of string.
	void writeString(String<u8> val)
	{
		u64 bytesNeeded = val.numChars + 1;
		if(val.numChars >= 255)
			bytesNeeded += 4;

		validateWrite(index, bytesNeeded);

		u32 len = val.numChars;
		if(len < 255)
		{
			writeU8(len);
		}
		else
		{
			writeU8(255);
			writeU32(len);
		}

		for(u64 i=0; i<len; i++)
		{
			data[index] = val.chars[i];
			index++;
		}
	}

	// Set a sequence of bytes to a single value.
	void writeBytes(u64 pos, u64 numBytes, u8 val)
	{
		validateWrite(pos, numBytes);

		for(u64 p=0; p<numBytes; p++)
		{
			data[pos + p] = val;
		}

		pos += numBytes;
	}

	// Copy an array of data to this.
	void write(u64 pos, u8[] bytes, u64 numBytes)
	{
		validateWrite(pos, numBytes);

		for(u64 p=0; p<numBytes; p++)
		{
			data[pos + p] = bytes[p];
		}

		pos += numBytes;
	}

	// Copy an array of data to this.
	void write(u64 pos, ByteArray bytes)
	{
		validateWrite(pos, bytes.numUsed);

		for(u64 p=0; p<bytes.numUsed; p++)
		{
			data[pos + p] = bytes.data[p];
		}

		pos += bytes.numUsed;
	}

	// Write value to pos.
	void writeU8(u64 pos, u8 val)
	{
		validateWrite(pos, 1);
		data[pos] = val;
	}

	// Write value to pos.
	void writeI8(u64 pos, i8 val)
	{
		validateWrite(pos, 1);
		ByteIO:writeI8(data, pos, val);
	}

	// Write value to pos.
	void writeBool(u64 pos, bool val)
	{
		validateWrite(pos, 1);
		data[pos] = val;
	}

	// Write value to pos.
	void writeU16(u64 pos, u16 val)
	{
		validateWrite(pos, 2);
		if(bigEndian == false)
			ByteIO:writeU16(data, pos, val);
		else
			ByteIO:writeU16Big(data, pos, val);
	}

	// Write value to pos.
	void writeI16(u64 pos, i16 val)
	{
		validateWrite(pos, 2);
		if(bigEndian == false)
			ByteIO:writeI16(data, pos, val);
		else
			ByteIO:writeI16Big(data, pos, val);
	}

	// Write value to pos.
	void writeU32(u64 pos, u32 val)
	{
		validateWrite(pos, 4);
		if(bigEndian == false)
			ByteIO:writeU32(data, pos, val);
		else
			ByteIO:writeU32Big(data, pos, val);
	}

	// Write value to pos.
	void writeI32(u64 pos, i32 val)
	{
		validateWrite(pos, 4);
		if(bigEndian == false)
			ByteIO:writeI32(data, pos, val);
		else
			ByteIO:writeI32Big(data, pos, val);
	}

	// Write value to pos.
	void writeU64(u64 pos, u64 val)
	{
		validateWrite(pos, 8);
		if(bigEndian == false)
			ByteIO:writeU64(data, pos, val);
		else
			ByteIO:writeU64Big(data, pos, val);
	}

	// Write value to pos.
	void writeI64(u64 pos, i64 val)
	{
		validateWrite(pos, 8);
		if(bigEndian == false)
			ByteIO:writeI64(data, pos, val);
		else
			ByteIO:writeI64Big(data, pos, val);
	}

	// Write value to pos.
	void writeF32(u64 pos, f32 val)
	{
		validateWrite(pos, 4);
		if(bigEndian == false)
			ByteIO:writeF32(data, pos, val);
		else
			ByteIO:writeF32Big(data, pos, val);
	}

	// Write value to pos.
	void writeF64(u64 pos, f64 val)
	{
		validateWrite(pos, 8);
		if(bigEndian == false)
			ByteIO:writeF64(data, pos, val);
		else
			ByteIO:writeF64Big(data, pos, val);
	}

	// Write string to pos. Write format is u8 or u8+u32 string length followed by characters of string.
	void writeString(u64 pos, String<u8> val)
	{
		u64 bytesNeeded = val.numChars + 1;
		if(val.numChars >= 255)
			bytesNeeded += 4;

		validateWrite(pos, bytesNeeded);

		u32 len = val.numChars;
		if(len < 255)
		{
			writeU8(pos, len);
			pos += 1;
		}
		else
		{
			writeU8(pos, 255);
			pos += 1;
			writeU32(pos, len);
			pos += 4;
		}

		for(u64 i=0; i<len; i++)
		{
			data[pos] = val.chars[i];
			pos++;
		}
	}

	// Read a chunk of data from index position.
	ByteArray read(u64 numBytesToRead)
	{
		ByteArray retData = ByteArray(numBytesToRead, 0);

		for(u64 b=0; b<numBytesToRead; b++)
		{
			retData.data[b] = data[index + b];
		}

		retData.numUsed = numBytesToRead;

		index += numBytesToRead;

		return retData;
	}

	// Read a chunk of data from index position.
	void read(u64 numBytesToRead, u8[] des)
	{
		des.copy(data, index, 0, numBytesToRead);
		index += numBytesToRead;
	}

	// Read a value from index position (and move index past value).
	u8 readU8()
	{
		u8 val = data[index];
		index += 1;
		return val;
	}

	// Read a value from index position (and move index past value).
	i8 readI8()
	{
		index += 1;
		return ByteIO:readI8(data, index - 1);
	}

	// Read a value from aribtrary location in array.
	bool readBool()
	{
		u8 val = ByteIO:readU8(data, index);
		index += 1;
		if(val == 0)
			return false;

		return true;
	}

	// Read a value from index position (and move index past value).
	u16 readU16()
	{
		u16 val = 0;
		if(bigEndian == false)
			val = ByteIO:readU16(data, index);
		else
			val = ByteIO:readU16Big(data, index);
		index += 2;
		return val;
	}

	// Read a value from index position (and move index past value).
	i16 readI16()
	{
		i16 val = 0;
		if(bigEndian == false)
			val = ByteIO:readI16(data, index);
		else
			val = ByteIO:readI16Big(data, index);
		index += 2;
		return val;
	}

	// Read a value from index position (and move index past value).
	u32 readU32()
	{
		u32 val = 0;
		if(bigEndian == false)
			val = ByteIO:readU32(data, index);
		else
			val = ByteIO:readU32Big(data, index);
		index += 4;
		return val;
	}

	// Read a value from index position (and move index past value).
	i32 readI32()
	{
		i32 val = 0;
		if(bigEndian == false)
			val = ByteIO:readI32(data, index);
		else
			val = ByteIO:readI32Big(data, index);
		index += 4;
		return val;
	}

	// Read a value from index position (and move index past value).
	u64 readU64()
	{
		u64 val = 0;
		if(bigEndian == false)
			val = ByteIO:readU64(data, index);
		else
			val = ByteIO:readU64Big(data, index);
		index += 8;
		return val;
	}

	// Read a value from index position (and move index past value).
	i64 readI64()
	{
		i64 val = 0;
		if(bigEndian == false)
			val = ByteIO:readI64(data, index);
		else
			val = ByteIO:readI64Big(data, index);
		index += 8;
		return val;
	}

	// Read a value from index position (and move index past value).
	f32 readF32()
	{
		f32 val = 0.0f;
		if(bigEndian == false)
			val = ByteIO:readF32(data, index);
		else
			val = ByteIO:readF32Big(data, index);
		index += 4;
		return val;
	}

	// Read a value from index position (and move index past value).
	f64 readF64()
	{
		f64 val = 0.0;
		if(bigEndian == false)
			val = ByteIO:readF64(data, index);
		else
			val = ByteIO:readF64Big(data, index);
		index += 8;
		return val;
	}

	// Read a String<u8> value. Assumes format is u8 / u8+u32 string length followed by bytes of string.
	String<u8> readString()
	{
		u64 numChars = readU8();
		if(numChars == 255)
		{
			numChars = readU32();
		}

		String<u8> s = String<u8>(numChars);
		for(u64 i=0; i<numChars; i++)
		{
			s.chars[i] = data[index];
			index++;
		}
		s.numChars = numChars;

		return s;
	}
	
	// Read a chunk of data from passed-in position.
	ByteArray read(u64 pos, u64 numBytesToRead)
	{
		ByteArray retData = ByteArray(numBytesToRead, 0);

		for(u64 b=0; b<numBytesToRead; b++)
		{
			retData.data[b] = data[pos];
			pos++;
		}

		retData.numUsed = numBytesToRead;

		return retData;
	}

	// Read a chunk of data from passed-in position.
	void read(u64 pos, u64 numBytesToRead, u8[] des)
	{
		des.copy(data, 0, pos, numBytesToRead);
		pos += numBytesToRead;
	}

	// Read a value from passed-in position.
	u8 readU8(u64 pos)
	{
		u8 val = data[pos];
		pos += 1;
		return val;
	}

	// Read a value from passed-in position.
	i8 readI8(u64 pos)
	{
		pos += 1;
		return ByteIO:readI8(data, pos - 1);
	}

	// Read a value from aribtrary location in array.
	bool readBool(u64 pos)
	{
		u8 val = ByteIO:readU8(data, pos);
		pos += 1;
		if(val == 0)
			return false;

		return true;
	}

	// Read a value from passed-in position (and move index past value).
	u16 readU16(u64 pos)
	{
		u16 val = 0;
		if(bigEndian == false)
			val = ByteIO:readU16(data, pos);
		else
			val = ByteIO:readU16Big(data, pos);
		pos += 2;
		return val;
	}

	// Read a value from index position (and move index past value).
	i16 readI16(u64 pos)
	{
		i16 val = 0;
		if(bigEndian == false)
			val = ByteIO:readI16(data, pos);
		else
			val = ByteIO:readI16Big(data, pos);
		pos += 2;
		return val;
	}

	// Read a value from index position (and move index past value).
	u32 readU32(u64 pos)
	{
		u32 val = 0;
		if(bigEndian == false)
			val = ByteIO:readU32(data, pos);
		else
			val = ByteIO:readU32Big(data, pos);
		pos += 4;
		return val;
	}

	// Read a value from index position (and move index past value).
	i32 readI32(u64 pos)
	{
		i32 val = 0;
		if(bigEndian == false)
			val = ByteIO:readI32(data, pos);
		else
			val = ByteIO:readI32Big(data, pos);
		pos += 4;
		return val;
	}

	// Read a value from index position (and move index past value).
	u64 readU64(u64 pos)
	{
		u64 val = 0;
		if(bigEndian == false)
			val = ByteIO:readU64(data, pos);
		else
			val = ByteIO:readU64Big(data, pos);
		pos += 8;
		return val;
	}

	// Read a value from index position (and move index past value).
	i64 readI64(u64 pos)
	{
		i64 val = 0;
		if(bigEndian == false)
			val = ByteIO:readI64(data, pos);
		else
			val = ByteIO:readI64Big(data, pos);
		pos += 8;
		return val;
	}

	// Read a value from index position (and move index past value).
	f32 readF32(u64 pos)
	{
		f32 val = 0.0f;
		if(bigEndian == false)
			val = ByteIO:readF32(data, pos);
		else
			val = ByteIO:readF32Big(data, pos);
		pos += 4;
		return val;
	}

	// Read a value from index position (and move index past value).
	f64 readF64(u64 pos)
	{
		f64 val = 0.0;
		if(bigEndian == false)
			val = ByteIO:readF64(data, pos);
		else
			val = ByteIO:readF64Big(data, pos);
		pos += 8;
		return val;
	}

	// Read a String<u8> value. Assumes format is u8 / u8+u32 string length followed by bytes of string.
	String<u8> readString(u64 pos)
	{
		u64 numChars = readU8(pos);
		pos +=1;
		if(numChars == 255)
		{
			numChars = readU32(pos);
			pos += 4;
		}

		String<u8> s = String<u8>(numChars);
		for(u64 i=0; i<numChars; i++)
		{
			s.chars[i] = data[pos];
			pos++;
		}
		s.numChars = numChars;

		return s;
	}
}