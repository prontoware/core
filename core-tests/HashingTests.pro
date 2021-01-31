////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class HashNullTests implements IUnitTest
{
	void run()
	{
		String<u8> originalMsg  = "RedBlueGreen";
		String<u8> computedHash = Hashing:hashToHexStr(originalMsg, Hashing:HASH_NULL);
		test(computedHash != null);
		test(computedHash.length() == 0);
	}
}

class HashSHA1Tests implements IUnitTest
{
	void run()
	{
		String<u8> originalMsg  = "RedBlueGreen";
		String<u8> expectedHash = "8a15beb6708f72edfa330b2d0a666d5b8d729ad9";
		String<u8> computedHash = Hashing:hashToHexStr(originalMsg, Hashing:HASH_SHA1);
		test(computedHash != null);
		test(computedHash.compare(expectedHash) == true);
	}
}

class HashSHA256BitsTests implements IUnitTest
{
	void run()
	{
		SHA256Hash hasher();

		/*
		Log:log("ROTLEFT: "  + String<u8>:formatNumberHex(hasher.ROTLEFT(0xF4556677, 0xFF992211)));
		Log:log("ROTRIGHT: " + String<u8>:formatNumberHex(hasher.ROTRIGHT(0xF4556677, 0xFF992211)));
		Log:log("CH: "   + String<u8>:formatNumberHex(hasher.CH(0xF4556677, 0xFF992211, 0xFF992277)));
		Log:log("MAJ: "  + String<u8>:formatNumberHex(hasher.MAJ(0xF4556677, 0xFF992211, 0xFF992277)));
		Log:log("EP0: "  + String<u8>:formatNumberHex(hasher.EP0(0xF4556677)));
		Log:log("EP1: "  + String<u8>:formatNumberHex(hasher.EP1(0xF4556677)));
		Log:log("SIG0: " + String<u8>:formatNumberHex(hasher.SIG0(0xF4556677)));
		Log:log("SIG1: " + String<u8>:formatNumberHex(hasher.SIG1(0xF4556677)));
		*/

		/* Should be:
		ROTLEFT: 0xCCEFE8AA
		ROTRIGHT: 0xB33BFA2A
		CH: 0xFF992211
		MAJ: 0xFF992277
		EP0: 0x9B3324E7
		EP1: 0x3B9CE4CF
		SIG0: 0xA8FFFB17
		SIG1: 0x1FC811F9
		*/

		test(hasher.ROTLEFT(0xF4556677, 0xFF992211) == 0xCCEFE8AA);

		test(hasher.ROTRIGHT(0xF4556677, 0xFF992211) == 0xB33BFA2A);

		test(hasher.CH(0xF4556677, 0xFF992211, 0xFF992277) == 0xFF992211);

		test(hasher.MAJ(0xF4556677, 0xFF992211, 0xFF992277) == 0xFF992277);

		test(hasher.EP0(0xF4556677) == 0x9B3324E7);

		test(hasher.EP1(0xF4556677) == 0x3B9CE4CF);

		test(hasher.SIG0(0xF4556677) == 0xA8FFFB17);

		test(hasher.SIG1(0xF4556677) == 0x1FC811F9);

		// higher level funcs
		ByteArray   data = ByteArray("RedBlueGreen");
		SHA256State ctx  = SHA256State();
		SHA256Hash  sha2 = SHA256Hash();

		sha2.sha256Update(ctx, data);

		test(ctx.data[0] == Chars:R); // "SHA256 sub func test : sha256Update(), ctx.data[0]: " + ctx.data[0];
		test(ctx.data[1] == Chars:e); // "SHA256 sub func test : sha256Update(), ctx.data[1]: " + ctx.data[1];

		sha2.sha256Transform(ctx, ctx.data);

		//Log:log("testSHA256HashSubFuncs ctx.state[0]" + String<u8>:formatNumberHex(ctx.state[0])); // half-calc-test: D413CCCE
		test(ctx.state[0] == 0x2CBEC3CE); // "SHA256 sub func test : sha256Transform(), ctx.state[0]: " + ctx.state[0];
	}
}

class HashSHA256Tests implements IUnitTest
{
	void run()
	{
		ArrayMap<String<u8>, String<u8>> map();

		// original data, expected hash
		map.add("RedBlueGreen",  "1c81cb42c06821395001de250fd8bf779dacf65b5a16554caeacbdcb883cba9c");
		map.add("password",      "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8");
		map.add("abc123",        "6ca13d52ca70c883e0f0bb101e425a89e8624de51db2d2392593af6a84118090");
		map.add("#*$&DKFLC@*",   "a2f796ddd86ac396e1ae67d7c34c34b32c264889e38ef904cf24541e7df38d91");

		IIterator<String<u8>> mapIter = map.getIterator();
		while(mapIter.hasNext())
		{
			String<u8> pwKey        = mapIter.next();
			String<u8> expectedHash = map.get(pwKey);
			String<u8> computedHash = Hashing:hashToHexStr(pwKey, Hashing:HASH_SHA256);

			test(computedHash != null);
			test(computedHash.compare(expectedHash) == true);
		}
	}
}

class UUIDTests implements IUnitTest
{
	void run()
	{
		HashSet<UUID> uuids();

		for(u32 x=0; x<256; x++)
		{
			UUID u();
			test(uuids.contains(u) == false);
			
			uuids.add(u);
		}

		UUID a();
		String<u8> strA = a.toString();
		test(strA.length() == 32); // 16 bytes as hex is 32 characters

		UUID a2(strA);
		test(a2.equals(a) == true);
	}
}