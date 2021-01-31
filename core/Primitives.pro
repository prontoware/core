////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Constants for primitive data types.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Type
////////////////////////////////////////////////////////////////////////////////////////////////////

// Utilities for dealing with primitive type constants etc. These represent the fundemental data
// types that Pronto works with. These also corresepond to what modern CPUs (ARMv8, X86-64 etc.)
// work with.
// This is a built-in class where variables are already declared. Just adding some shared functions
// for utility here.
class Type
{
	// BADVAL, VOID, U8 ... OBJ byte sizes (and some padding at end)
	shared u8[16] SIZES = u8( 0, 0, 1, 1, 2, 2, 4, 4, 8, 8, 4, 8, 8, 0, 0, 0 );

	// Primitive types enumeration - already built-in!
	/*
	const u64 BADVAL    = 0;
	const u64 VOID      = 1;
	const u64 U8        = 2;
	const u64 I8        = 3;
	const u64 U16       = 4;
	const u64 I16       = 5;
	const u64 U32       = 6;
	const u64 I32       = 7;
	const u64 U64       = 8;
	const u64 I64       = 9;
	const u64 F32       = 10;
	const u64 F64       = 11;
	const u64 OBJ       = 12; // memory address, 64 bit
	const u64 MAX_BYTE_SIZE = 128; // for 1024 bit vector
	*/

	// Get byte-size of data type.
	shared u8 getSize(u8 t)
	{
		return SIZES[t];
	}

	// Pass-in one of  etc. Works for primitives, not vectors.
	shared bool isIntType(u8 t)
	{
		if(t >= U8 && t <= I64)
			return true;
	
		return false;
	}

	// Pass-in one of  etc. Works for primitives, not vectors.
	shared bool isIntTypeUnsigned(u8 t)
	{
		if(t == U8 || t == U16 || t == U32 || t == U64)
			return true;
	
		return false;
	}

	// Pass-in one of  etc. Works for primitives, not vectors.
	shared bool isIntTypeSigned(u8 t)
	{
		if(t == I8 || t == I16 || t == I32 || t == I64)
			return true;
	
		return false;
	}

	// Pass-in one of  etc. Works for primitives, not vectors.
	shared bool isFloatType(u8 t)
	{
		if(t >= F32 && t <= F64)
			return true;
	
		return false;
	}
	
	// Make unsigned signed
	shared u8 makeSigned(u8 t)
	{
		if(Type:isIntTypeSigned(t) == false)
			return t + 1;
	
		return t;
	}
}