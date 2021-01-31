////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// RandomFast
////////////////////////////////////////////////////////////////////////////////////////////////////

// Variation of marsaglia's xorshf algorithm. Very fast, no meaningful memory overhead. Not suitable
// for cryptography or monte carlo etc.
class RandomFast
{
	u64 x = 1234567891234;
	u64 y = 8654362436069;
	u64 z = 8201521288629;

	// Default seeded.
	void constructor()
	{

	}

	// Explict seeded.
	void constructor(u64 seed)
	{
		x += seed;
	}

	// Generate next number.
	void generate()
	{
		// period 2^96-1
		x ^= x << 16;
		x ^= x >> 5;
		x ^= x << 1;

		u64 t = x;
		x = y;
		y = z;
		z = t ^ x ^ y;
	}

	// Generate pseudo-random floating-number.
	f32 getF32(f32 min, f32 max)
	{
		return getF64(min, max);
	}

	// Generate pseudo-random floating-number.
	f64 getF64(f64 min, f64 max)
	{
		generate();

		// 1 billion possible numbers between 0 and 1
		f64 val   = getI64(0, 1000000000) / 1000000000.0;
		f64 range = max - min;
		val = min + (val * range);

		return val;
	}

	// Generate pseudo-random integer-number.
	u32 getU32()
	{
		return getI64(Math:U32_MIN, Math:U32_MAX);
	}

	// Generate pseudo-random integer-number.
	u32 getU32(u32 min, u32 max)
	{
		return getI64(min, max);
	}

	// Generate pseudo-random integer-number.
	i32 getI32()
	{
		return getI64(Math:I32_MIN, Math:I32_MAX);
	}

	// Generate pseudo-random integer-number.
	i32 getI32(i32 min, i32 max)
	{
		return getI64(min, max);
	}

	// Generate pseudo-random integer-number.
	i64 getI64(i64 min, i64 max)
	{
		i64 temp = max;
		if(max < min)
		{
			max = min;
			min = temp;
		}

		if(max == min)
			return min;

		generate();

		u64 range = (max - min) + 1;
		i64 val = min + (z % range);

		return val;
	}

	// Generate pseudo-random integer.
	u64 getU64()
	{
		return getU64(0, Math:U64_MAX);
	}

	// Generate pseudo-random integer.
	u64 getU64(u64 min, u64 max)
	{
		u64 temp = max;
		if(max < min)
		{
			max = min;
			min = temp;
		}

		if(max == min)
			return min;

		generate();

		u64 range = (max - min) + 1;
		u64 val = min + (z % range);

		return val;
	}

	shared RandomFast globalRandomFast = RandomFast(0);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Math
////////////////////////////////////////////////////////////////////////////////////////////////////

// Basic math functions. Generally C-compatible.
// Note many of Math's functions are implementend with native functions and do not appear here.
class Math
{
	const f32 PI = 3.14159265f;
	const f32 E  = 2.71828182;

	const u8 U8_MIN = 0;
	const u8 U8_MAX = 255;

	const i8 I8_MIN = -128;
	const i8 I8_MAX = 127;

	const u16 U16_MIN = 0;
	const u16 U16_MAX = 65535;

	const i16 I16_MIN = -32768;
	const i16 I16_MAX = 32767;

	const u32 U32_MIN = 0;
	const u32 U32_MAX = 4294967295;

	const i32 I32_MIN = -2147483648;
	const i32 I32_MAX = 2147483647;

	const u64 U64_MIN = 0;
	const u64 U64_MAX = 18446744073709551615;

	const i64 I64_MIN = -9223372036854775808;
	const i64 I64_MAX = 9223372036854775807;

	//const f32 F32_MIN Built-in
	//const f32 F32_MAX Built-in

	//const f64 F64_MIN Built-in
	//const f64 F64_MAX Built-in

	// Return smaller
	shared u8 min(u8 a, u8 b)
	{
		if(a < b) return a;

		return b;
	}

	// Return smaller
	shared i8 min(i8 a, i8 b)
	{
		if(a < b) return a;

		return b;
	}

	// Return smaller
	shared u16 min(u16 a, u16 b)
	{
		if(a < b) return a;

		return b;
	}

	// Return smaller
	shared i16 min(i16 a, i16 b)
	{
		if(a < b) return a;

		return b;
	}

	// Return smaller
	shared u32 min(u32 a, u32 b)
	{
		if(a < b) return a;

		return b;
	}

	// Return smaller
	shared i32 min(i32 a, i32 b)
	{
		if(a < b) return a;

		return b;
	}

	// Return smaller
	shared u64 min(u64 a, u64 b)
	{
		if(a < b) return a;

		return b;
	}

	// Return smaller
	shared i64 min(i64 a, i64 b)
	{
		if(a < b) return a;

		return b;
	}

	// Return smaller
	shared f32 min(f32 a, f32 b)
	{
		if(a < b) return a;

		return b;
	}

	// Return smaller
	shared f64 min(f64 a, f64 b)
	{
		if(a < b) return a;

		return b;
	}

	// Return larger
	shared u8 max(u8 a, u8 b)
	{
		if(a > b) return a;

		return b;
	}

	// Return larger
	shared i8 max(i8 a, i8 b)
	{
		if(a > b) return a;

		return b;
	}

	// Return larger
	shared u16 max(u16 a, u16 b)
	{
		if(a > b) return a;

		return b;
	}

	// Return larger
	shared i16 max(i16 a, i16 b)
	{
		if(a > b) return a;

		return b;
	}

	// Return larger
	shared u32 max(u32 a, u32 b)
	{
		if(a > b) return a;

		return b;
	}

	// Return larger
	shared i32 max(i32 a, i32 b)
	{
		if(a > b) return a;

		return b;
	}

	// Return larger
	shared u64 max(u64 a, u64 b)
	{
		if(a > b) return a;

		return b;
	}

	// Return larger
	shared i64 max(i64 a, i64 b)
	{
		if(a > b) return a;

		return b;
	}

	// Return larger
	shared f32 max(f32 a, f32 b)
	{
		if(a > b) return a;

		return b;
	}

	// Return larger
	shared f64 max(f64 a, f64 b)
	{
		if(a > b) return a;

		return b;
	}

	// Restrict value to range specified.
	shared u8 minMax(u8 min, u8 max, u8 val)
	{
		if(val < min) return min;
		if(val > max) return max;

		return val;
	}

	// Restrict value to range specified.
	shared i8 minMax(i8 min, i8 max, i8 val)
	{
		if(val < min) return min;
		if(val > max) return max;

		return val;
	}

	// Restrict value to range specified.
	shared u16 minMax(u16 min, u16 max, u16 val)
	{
		if(val < min) return min;
		if(val > max) return max;

		return val;
	}

	// Restrict value to range specified.
	shared i16 minMax(i16 min, i16 max, i16 val)
	{
		if(val < min) return min;
		if(val > max) return max;

		return val;
	}

	// Restrict value to range specified.
	shared u32 minMax(u32 min, u32 max, u32 val)
	{
		if(val < min) return min;
		if(val > max) return max;

		return val;
	}

	// Restrict value to range specified.
	shared i32 minMax(i32 min, i32 max, i32 val)
	{
		if(val < min) return min;
		if(val > max) return max;

		return val;
	}

	// Restrict value to range specified.
	shared u64 minMax(u64 min, u64 max, u64 val)
	{
		if(val < min) return min;
		if(val > max) return max;

		return val;
	}

	// Restrict value to range specified.
	shared i64 minMax(i64 min, i64 max, i64 val)
	{
		if(val < min) return min;
		if(val > max) return max;

		return val;
	}

	// Restrict value to range specified.
	shared f32 minMax(f32 min, f32 max, f32 val)
	{
		if(val < min) return min;
		if(val > max) return max;

		return val;
	}

	// Restrict value to range specified.
	shared f64 minMax(f64 min, f64 max, f64 val)
	{
		if(val < min) return min;
		if(val > max) return max;

		return val;
	}

	// Compare floating values within a +/- 1% tolerance range.
	shared bool compare(f32 actual, f32 expected)
	{
		f32 diff = expected * 0.01f; // 1% difference
		if(Math:abs(actual - expected) > diff)
			return false;

		return true;
	}

	// Compare floating values within a +/- tolerance range.
	shared bool compare(f32 actual, f32 expected, f32 tolerance)
	{
		if(Math:abs(actual - expected) > tolerance)
			return false;

		return true;
	}

	// Compare floating values within a +/- 0.1% tolerance range.
	shared bool compare(f64 actual, f64 expected)
	{
		f64 diff = expected * 0.001f; // 0.1% difference
		if(Math:abs(actual - expected) > diff)
			return false;

		return true;
	}

	// Compare floating values within a +/- tolerance range.
	shared bool compare(f64 actual, f64 expected, f64 tolerance)
	{
		if(Math:abs(actual - expected) > tolerance)
			return false;

		return true;
	}

	// Return a random integer between start and end inclusive.
	shared i32 randomI32(i32 start, i32 end)
	{
		return RandomFast:globalRandomFast.getI32(start, end);
	}

	// Return a random integer between start and end inclusive.
	shared i64 randomI64(i64 start, i64 end)
	{
		return RandomFast:globalRandomFast.getI64(start, end);
	}

	// Return a random floating-point number between start and end inclusive.
	shared f32 randomF32(f32 start, f32 end)
	{
		return RandomFast:globalRandomFast.getF32(start, end);
	}

	// Return a random floating-point number between start and end inclusive.
	shared f64 randomF64(f64 start, f64 end)
	{
		return RandomFast:globalRandomFast.getF64(start, end);
	}

	// Convert to radians from degrees.
	shared f32 toRadians(f32 angleDegrees)
	{
		return angleDegrees * 0.0174533f;
	}

	// Convert to radians from degrees.
	shared f64 toRadians(f64 angleDegrees)
	{
		return angleDegrees * 0.01745329;
	}

	// Convert to degrees from radians.
	shared f32 toDegrees(f32 radians)
	{
		return radians * 57.2957795f;
	}

	// Convert to degrees from radians.
	shared f64 toDegrees(f64 radians)
	{
		return radians * 57.2957795;
	}

	// Wrap a value in a range (AKA circular number line). Min/max are inclusive.
	shared i32 wrap(i32 min, i32 max, i32 val)
	{
		i32 range = Math:abs((max+1) - min);
		if(range == 0)
			return min;

		if(val < min)
		{
			val = Math:abs((val + 1) - min) % range;
			val = max - val;
		}
		else if(val > max)
		{
			val = Math:abs((val - 1) - max) % range;
			val = min + val;
		}

		return val;
	}

	// Wrap a value in a range (AKA circular number line). Min/max are inclusive.
	shared i64 wrap(i64 min, i64 max, i64 val)
	{
		i64 range = Math:abs((max+1) - min);
		if(range == 0)
			return min;

		if(val < min)
		{
			val = Math:abs((val + 1) - min) % range;
			val = max - val;
		}
		else if(val > max)
		{
			val = Math:abs((val - 1) - max) % range;
			val = min + val;
		}

		return val;
	}

	// Round floating point to integer.
	shared i32 roundToInt(f32 val)
	{
		return Math:round(val);
	}

	// Round floating point to integer.
	shared i64 roundToInt(f64 val)
	{
		return Math:round(val);
	}

	// Same as atan2 except atan2 doesn't return a value relative to the Y+ axis, it returns it relative to X+ which is kinda
	// like polar coordinates the -ve Y half return is backwards. This returns relative to Y+ axis.
	shared f32 atan2Clockwise(f32 x, f32 y)
	{
		// normal atan2(y, x) returns:
		// atan2 y: 1.0, 0.0:  1.570796
		// atan2 y: 0.5, 0.5:  0.785398
		// atan2 y: 0.0, 1.0:  0.000000
		// atan2 y:-0.5, 0.5: -0.785398
		// atan2 y:-0.5,-0.5: -2.356194
		// atan2 y: 0.5,-0.5:  2.356194

		f32 radians = Math:atan2(y, x);

		if(y >= 0 && x >= 0)
			return (Math:PI / 2.0f) - radians;
		else if(y >= 0 && x <= 0)
			return (Math:PI + (Math:PI / 2.0f)) + (Math:PI - radians);
		
		return (Math:PI / 2.0f) + (radians * -1.0f);
	}

	// Is the passed-in number a power of 2? Zero is not considered a power of two.
	bool isPowerOfTwo(u64 val)
	{
		return ((val & (val - 1)) == 0);
	}

	// Is the passed-in number a power of the specified base? Only checks up to u64_max / base powers!
	bool isPowerOf(u64 val, u32 base)
	{
		// max
		u64 maxVal = U64_MAX / base;

		u64 cur = base;
		while(cur)
		{
			if(cur == val)
				return true; // found a match

			if(cur >= maxVal)
				return false; // can't check any more

			cur *= base;
		}

		return false;
	}
}