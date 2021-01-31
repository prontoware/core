////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class ByteIOLittleEndianTests implements IUnitTest
{
	void run()
	{
		u8[] a = u8[](1024);

		ByteIO:writeU8(a, 0, 11);
		test(ByteIO:readU8(a, 0) == 11);

		ByteIO:writeI8(a, 1, -12);
		test(ByteIO:readI8(a, 1) == -12);

		ByteIO:writeU16(a, 1, 1024);
		test(ByteIO:readU16(a, 1) == 1024);

		ByteIO:writeI16(a, 1, -1024);
		test(ByteIO:readI16(a, 1) == -1024);

		ByteIO:writeU32(a, 1, 100000);
		test(ByteIO:readU32(a, 1) == 100000);

		ByteIO:writeI32(a, 1, -100000);
		test(ByteIO:readI32(a, 1) == -100000);

		ByteIO:writeU64(a, 1, 100000123456);
		test(ByteIO:readU64(a, 1) == 100000123456);

		ByteIO:writeI64(a, 1, -100000123456);
		test(ByteIO:readI64(a, 1) == -100000123456);

		ByteIO:writeF16(a, 1, 0.5f); // f16 has very low precision especially outside of 0 to 1 range.
		test(ByteIO:readF16(a, 1) > 0.4f && ByteIO:readF16(a, 1) < 0.6f);

		ByteIO:writeF32(a, 1, 1.0f);
		test(ByteIO:readF32(a, 1) > 0.9f && ByteIO:readF32(a, 1) < 1.1f);

		ByteIO:writeF64(a, 1, 1.0);
		test(ByteIO:readF64(a, 1) > 0.9 && ByteIO:readF64(a, 1) < 1.1);
	}
}

class ByteIOBigEndianTests implements IUnitTest
{
	void run()
	{
		u8[] a = u8[](1024);

		ByteIO:writeU8(a, 0, 11);
		test(ByteIO:readU8(a, 0) == 11);

		ByteIO:writeI8(a, 1, -12);
		test(ByteIO:readI8(a, 1) == -12);

		ByteIO:writeU16Big(a, 1, 1024);
		test(ByteIO:readU16Big(a, 1) == 1024);

		ByteIO:writeI16Big(a, 1, -1024);
		test(ByteIO:readI16Big(a, 1) == -1024);

		ByteIO:writeU32Big(a, 1, 100000);
		test(ByteIO:readU32Big(a, 1) == 100000);

		ByteIO:writeI32Big(a, 1, -100000);
		test(ByteIO:readI32Big(a, 1) == -100000);

		ByteIO:writeU64Big(a, 1, 100000123456);
		test(ByteIO:readU64Big(a, 1) == 100000123456);

		ByteIO:writeI64Big(a, 1, -100000123456);
		test(ByteIO:readI64Big(a, 1) == -100000123456);

		ByteIO:writeF16Big(a, 1, 0.5f); // f16 has very low precision especially outside of 0 to 1 range.
		test(ByteIO:readF16Big(a, 1) > 0.4f && ByteIO:readF16Big(a, 1) < 0.6f);

		ByteIO:writeF32Big(a, 1, 1.0f);
		test(ByteIO:readF32Big(a, 1) > 0.9f && ByteIO:readF32Big(a, 1) < 1.1f);

		ByteIO:writeF64Big(a, 1, 1.0);
		test(ByteIO:readF64Big(a, 1) > 0.9 && ByteIO:readF64Big(a, 1) < 1.1);
	}
}

class ByteVecIOTests implements IUnitTest
{
	void run()
	{
		u8[64] a;
		a = ByteVecIO<u8[64]>:writeU8(a, 0, 11);
		test(a[0] == 11);
		test(ByteVecIO<u8[64]>:readU8(a, 0) == 11);

		a = ByteVecIO<u8[64]>:writeI8(a, 1, -12);
		test(ByteVecIO<u8[64]>:readI8(a, 1) == -12);

		a = ByteVecIO<u8[64]>:writeU16(a, 1, 1024);
		test(ByteVecIO<u8[64]>:readU16(a, 1) == 1024);

		a = ByteVecIO<u8[64]>:writeI16(a, 1, -1024);
		test(ByteVecIO<u8[64]>:readI16(a, 1) == -1024);

		a = ByteVecIO<u8[64]>:writeU32(a, 1, 100000);
		test(ByteVecIO<u8[64]>:readU32(a, 1) == 100000);

		a = ByteVecIO<u8[64]>:writeI32(a, 1, -100000);
		test(ByteVecIO<u8[64]>:readI32(a, 1) == -100000);

		a = ByteVecIO<u8[64]>:writeU64(a, 1, 100000123456);
		test(ByteVecIO<u8[64]>:readU64(a, 1) == 100000123456);

		a = ByteVecIO<u8[64]>:writeI64(a, 1, -100000123456);
		test(ByteVecIO<u8[64]>:readI64(a, 1) == -100000123456);

		a = ByteVecIO<u8[64]>:writeF16(a, 1, 0.5f); // f16 has very low precision especially outside of 0 to 1 range.
		test(ByteVecIO<u8[64]>:readF16(a, 1) > 0.4f && ByteVecIO<u8[64]>:readF16(a, 1) < 0.6f);

		a = ByteVecIO<u8[64]>:writeF32(a, 1, 1.0f);
		test(ByteVecIO<u8[64]>:readF32(a, 1) > 0.9f && ByteVecIO<u8[64]>:readF32(a, 1) < 1.1f);

		a = ByteVecIO<u8[64]>:writeF64(a, 1, 1.0);
		test(ByteVecIO<u8[64]>:readF64(a, 1) > 0.9 && ByteVecIO<u8[64]>:readF64(a, 1) < 1.1);
	}
}

class ByteIOFloat16Tests implements IUnitTest
{
	void run()
	{
		u8[] a = u8[](1024);

		// F16 support isn't native to Pronto or mainstream CPUs, so do extensive testing of packing/unpacking.
		f32[] values = f32[](8);
		values[0] = 0.0f;
		values[1] = 0.25f;
		values[2] = 0.5f;
		values[3] = 1.0f;
		values[4] = 1.5f;
		values[5] = 10.0f;
		values[6] = 100.0f;
		values[7] = 1000.0f;

		// positive
		for(u64 v=0; v<values.length(); v++)
		{
			f32 fVal = values[v];
			f32 fRange = 0.1f * fVal; // 10% because f16 has very low precision especially outside of 0 to 1 range.
			ByteIO:writeF16(a, v, fVal);
			test(ByteIO:readF16(a, v) >= (fVal - fRange) && ByteIO:readF16(a, v) <= (fVal + fRange));
		}

		// negative
		for(u64 n=0; n<values.length(); n++)
		{
			f32 fVal = values[n] * -1.0f;
			f32 fRange = 0.1f * values[n]; // 10% because f16 has very low precision especially outside of 0 to 1 range.
			ByteIO:writeF16(a, n, fVal);
			test(ByteIO:readF16(a, n) >= (fVal - fRange) && ByteIO:readF16(a, n) <= (fVal + fRange));
		}
	}
}

class ByteArrayEndianTests implements IUnitTest
{
	void run()
	{
		ByteArray file = ByteArray(1024, 0);
		file.setBigEndian();

		file.writeU16(0xF00E);
		file.setIndex(0);
		file.setLittleEndian();
		test(file.readU16() == 0x0EF0);
		file.setIndex(0);
		file.setBigEndian();
		test(file.readU16() == 0xF00E);

		file.setIndex(0);
		file.writeI32(-10029338);
		file.setIndex(0);
		test(file.readI32() == -10029338);

		file.setIndex(0);
		file.writeF32(1.02f);
		file.setIndex(0);
		test(file.readF32() > 1.0f);
	}
}

class ByteArrayIndexTests implements IUnitTest
{
	void run()
	{
		ByteArray file = ByteArray(1024, 0);

		file.writeU8(10);
		file.setIndex(0);
		test(file.readU8() == 10);
		test(file.size() == 1);

		file.writeU8(13);
		file.setIndex(1);
		test(file.readU8() == 13);
		test(file.size() == 2);

		u8[] bytes = u8[](3);
		bytes[0] = 100;
		bytes[1] = 101;
		bytes[2] = 102;

		file.write(bytes, 3);
		file.setIndex(2);
		test(file.readU8() == 100);
		file.setIndex(4);
		test(file.readU8() == 102);

		ByteArray fileCopy = ByteArray(file);
		fileCopy.setIndex(2);
		test(fileCopy.readU8() == 100);
		test(fileCopy.compare(file) == true);

		String<u8> name = "Dave";
		file.numUsed = 0;
		file.setIndex(0);
		file.writeString(name);
		file.setIndex(0);
		test(file.readU8() == 4); // four chars in "Dave"
		test(file.readU8() == Chars:D); // D in Dave
		file.index = 0;
		test(file.readString().compare("Dave") == true);
	}
}

class ByteArrayRandomTests implements IUnitTest
{
	void run()
	{
		ByteArray file = ByteArray(1024, 0);

		file.writeU8(0, 10);
		test(file.readU8(0) == 10);
		test(file.size() == 1);

		file.writeU16(22, 14449);
		test(file.readU16(22) == 14449);
		test(file.size() == 24);

		file.writeI64(1, -10293487474545);
		test(file.readU64(1) == -10293487474545);
		test(file.size() == 24);
	}
}

class ByteArrayMiscTests implements IUnitTest
{
	void run()
	{
		ByteArray file = ByteArray(1024, 0);

		file.writeU32(0xAABBCCDD);
		test(file.readU32(0) == 0xAABBCCDD);

		file.remove(1, 2);
		file.setIndex(0);
		test(file.size() == 2);
		test(file.readU16() == 0xAADD);
	}
}