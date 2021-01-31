////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class StringCreateTests implements IUnitTest
{
	void run()
	{
		String<u8> s0();
		test(s0.numChars == 0);
		test(s0.chars == null);

		String<u8> s1 = String<u8>(22);
		test(s1.numChars == 0);
		test(s1.chars != null);
		test(s1.chars.length() == 22);

		String<u8> s2 = String<u8>("ABC");
		test(s2.numChars == 3);
		test(s2.chars != null);
		test(s2.chars.length() == 3);
		test(s2[0] == Chars:A); // access chars via get(u64 index) [] operator override
		test(s2.chars[1] == Chars:B);
		test(s2.chars[2] == Chars:C);
	}
}

class StringIObjTests implements IUnitTest
{
	void run()
	{
		String<u8> s1 = String<u8>("xxx");
		String<u8> s2 = String<u8>("bbb");

		test(s1.compare(s2) == false);
		test(s1.getHash() != s2.getHash());
		test(s1.toString().compare(s1) == true);
	}
}

class StringCompareTests implements IUnitTest
{
	void run()
	{
		String<u8> s1 = String<u8>("abcdefghijklmnopqrstuvwxyz");
		String<u8> s2 = String<u8>("abcdefghijklmnopqrstuvwxyz");

		test(s1.compare(s2) == true);
		test(s2.compare(s1) == true);

		s1.copy("ABC");
		s2.copy("abc");

		// Case sensensitive compare
		test(s1.compare(s2, true) == false);

		// Case insensitive compare
		test(s1.compare(s2, false) == true);
	}
}

class StringSearchTests implements IUnitTest
{
	void run()
	{
		String<u8> s4 = String<u8>("xxxccxxc");

		// exact replace
		s4.replace("cc", 0, 1); //= ccxccxxc
		test(s4.chars[0] == Chars:c && s4.chars[1] == Chars:c);
		test(s4.countOccurrences(Chars:c) == 5);

		s4.append("ddcccc");
		test(s4.countOccurrences("cc") == 4);
		test(s4.beginsWith("cc") == true);
		test(s4.endsWith("cc") == true);

		s4.copy("abc def ghi");
		test(s4.findNext(Chars:d, 0) == 4);
		test(s4.findNextNonWhitespace(5) == 5);
		test(s4.findNextWhitespace(4) == 7);
		
		// finding pairs (i.e. brackets)
		String<u8> p1 = String<u8>("class { function() { } }");
		test(p1.findPairEnd(String<u8>("{"), String<u8>("}"), 6) == 23);

		// find previous char
		String<u8> filepath = String<u8>("input\\CodeGenerator.h");
		i64 periodIndex = filepath.findPrev(Chars:PERIOD, filepath.length()-1);
		test(periodIndex == 19);
	}
}

class StringAppendTests implements IUnitTest
{
	void run()
	{
		String<u8> s1 = String<u8>("yes");
		String<u8> s2 = String<u8>("no");
		String<u8> s3 = String<u8>("maybe");

		String<u8> a1 = String<u8>();
		a1.append("no");
		test(a1.compare(s2) == true);

		a1.append(s3);
		test(a1.compare("nomaybe") == true);
	}
}

class StringRemoveTests implements IUnitTest
{
	void run()
	{
		String<u8> s1 = String<u8>("abcdefghijklmnopqrstuvwxyz");
		String<u8> s3 = s1.subString(0, 0); // overflow and corrected
		test(s3.numChars == 1);

		s3 = s1.subString(0, 25);
		test(s1.compare(s3) == true);

		String<u8> s4 = s1.subString(1, 2);
		test(s4.chars[0] == Chars:b);

		String<u8> s5 = String<u8>("  trimmed white space  ");
		s5.trimWhitespace();
		test(s5.chars[0] == Chars:t && s5.chars[s5.numChars-1] == Chars:e);

		String<u8> s8 = String<u8>("aaRemovebb");
		s8.remove(2, 7);
		test(s8.chars[2] != Chars:R && s8.numChars == 4);

		String<u8> s9 = String<u8>("aaRemovebb\r\naa");
		test(s9.countOccurrences(Chars:NEW_LINE) == 1);

		s9.removeAll(Chars:NEW_LINE);
		test(s9.countOccurrences(Chars:NEW_LINE) == 0);
	}
}

class StringNumberFormatTests implements IUnitTest
{
	void run()
	{
		String<u8> s0 = String<u8>:formatNumber(1);
		test(s0.compare("1") == true);

		s0 = String<u8>:formatNumber(9902);
		test(s0.compare("9902") == true);

		s0 = String<u8>:formatNumber(1.0f, 1);
		test(s0.compare("1.0") == true);

		s0 = String<u8>:formatNumber(-22.2, 2);
		test(s0.compare("-22.20") == true);

		s0 = String<u8>:formatNumber(33.1f, 1);
		test(s0.compare("33.1") == true);

		s0 = String<u8>:formatNumber(100.02f, 2);
		test(s0.compare("100.02") == true);

		u8 hex0 = 0x00;
		s0 = String<u8>:formatNumberHex(hex0);
		test(s0.compare("00") == true);

		hex0 = 0xAB;
		s0 = String<u8>:formatNumberHex(hex0);
		test(s0.compare("AB") == true);

		u16 hex1 = 0xABCD;
		s0 = String<u8>:formatNumberHex(hex1);
		test(s0.compare("ABCD") == true);

		u32 hex2 = 0xABCDEF12;
		s0 = String<u8>:formatNumberHex(hex2);
		test(s0.compare("ABCDEF12") == true);

		u64 hex3 = 0xABCDEF0012345678;
		s0 = String<u8>:formatNumberHex(hex3);
		test(s0.compare("ABCDEF0012345678") == true);
	}
}

class StringBooleanParsingTests implements IUnitTest
{
	void run()
	{
		String<u8> s1 = String<u8>("True");
		test(s1.parseBoolean() == true);

		String<u8> s2 = String<u8>(" true");
		test(s2.parseBoolean() == true);

		String<u8> s3 = String<u8>(" FALSE  ");
		test(s3.parseBoolean() == false);

		String<u8> s4 = String<u8>(" x2  ");
		test(s4.parseBoolean(true) == true); // default value
	}
}

class StringNumberParsingTests implements IUnitTest
{
	void run()
	{
		String<u8> s6 = String<u8>("123");
		test(s6.parseInteger() == 123);

		s6.copy("  123456789");
		test(s6.parseInteger() == 123456789);

		s6.copy("-123456789");
		test(s6.parseInteger() == -123456789);

		s6.copy("adfa123");
		test(s6.parseInteger() == 0);

		s6.copy("555adfa123");
		test(s6.parseInteger() == 555);

		s6.copy("");
		test(s6.parseInteger() == 0);

		s6.copy("123");
		f32 floatValue = s6.parseFloat();
		test(floatValue >= 122.9f && floatValue <= 123.1f);

		s6.copy("123.");
		floatValue = s6.parseFloat();
		test(floatValue >= 122.9f && floatValue <= 123.1f);

		s6.copy("123.2");
		floatValue = s6.parseFloat();
		test(floatValue >= 123.1f && floatValue <= 123.3f);

		s6.copy(".25");
		floatValue = s6.parseFloat();
		test(floatValue >= 0.24f && floatValue <= 0.26f);

		s6.copy("  .25");
		floatValue = s6.parseFloat();
		test(floatValue >= 0.24f && floatValue <= 0.26f);

		s6.copy("adf.25");
		floatValue = s6.parseFloat();
		test(floatValue >= -0.01f && floatValue <= 0.01f); // zero = failed to parse

		s6.copy(" -.25");
		floatValue = s6.parseFloat();
		test(floatValue >= -0.26f && floatValue <= -0.24f);

		s6.copy("aa-.25");
		floatValue = s6.parseFloat();
		test(floatValue >= -0.01f && floatValue <= 0.01f); // zero = failed to parse

		s6.copy("aa-.25 -.023");
		floatValue = s6.parseFloat();
		test(floatValue >= -0.01f && floatValue <= 0.01f); // zero = failed to parse

		s6.copy("v 1.000000 -1.000000 -1.000000");
		floatValue = s6.parseFloat();
		test(floatValue >= -0.01f && floatValue <= 0.01f); // zero = failed to parse

		s6.copy("AB");
		u64 hexVal = s6.parseHex();
		test(hexVal == 0xAB);

		s6.copy("ABCDEF01");
		hexVal = s6.parseHex();
		test(hexVal == 0xABCDEF01);

		s6.copy("ABCDEF0122334455");
		hexVal = s6.parseHex();
		test(hexVal == 0xABCDEF0122334455);
	}
}

class StringInsertTests implements IUnitTest
{
	void run()
	{
		String<u8> s0("abc");
		u8 ch0 = Chars:f;

		s0.insert(ch0, 0);
		test(s0.length() == 4);
		test(s0.compare("fabc") == true);

		s0.insert(ch0, 2);
		test(s0.length() == 5);
		test(s0.compare("fafbc") == true);

		s0.insert(ch0, 5);
		test(s0.length() == 6);
		test(s0.compare("fafbcf") == true);

		s0 = String<u8>("abc");
		String<u8> s1("xyz");

		s0.insert(s1, 0);
		test(s0.length() == 6);
		test(s0.compare("xyzabc") == true);

		s0 = String<u8>("abc");
		s0.insert(s1, 1);
		test(s0.length() == 6);
		test(s0.compare("axyzbc") == true);

		s0 = String<u8>("abc");
		s0.insert(s1, 3);
		test(s0.length() == 6);
		test(s0.compare("abcxyz") == true);
	}
}

class StringMiscTests implements IUnitTest
{
	void run()
	{
		String<u8> s1 = String<u8>("abcdefghijklmnopqrstuvwxyz");
		String<u8> s2 = String<u8>("abcdefghijklmnopqrstuvwxyz");
		
		s2.toUppercase();
		test(s1.compare(s2) == false);

		test(s2.chars[0] == Chars:A);

		String<u8> beforeStr = String<u8>("2099");
		String<u8> afterStr  = String<u8>("9902");
		beforeStr.reverse();
		test(beforeStr.compare(afterStr) == true);
	}
}

class StringOperatorsTests implements IUnitTest
{
	void run()
	{
		String<u8> strA = "" + 25;
		test(strA.compare("25") == true);

		f32 numA = 1.0f;
		String<u8> strB = "" + numA;
		test(strB.contains("1.0") == true);
	}
}