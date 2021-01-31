////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class INIFileEntryTests implements IUnitTest
{
	void run()
	{
		INIEntry entry = INIEntry();
		test(entry.name.length() == 0);
		test(entry.val.length() == 0);
		test(entry.comment.length() == 0);

		entry = INIEntry(String<u8>("Name"), String<u8>("Value"), String<u8>("Comment"));
		test(entry.name.compare("Name") == true);
		test(entry.val.compare("Value") == true);
		test(entry.comment.compare("Comment") == true);

		i64 numVal = 22;
		entry.setValue(numVal);
		test(entry.getI64(0) == 22);

		f64 floatVal = -22.2;
		entry.setValue(floatVal);
		test(entry.getF64(0.0) >= -23.0 && entry.getF64(0.0) <= -22.0);

		bool boolVal = true;
		entry.setValue(boolVal);
		test(entry.getBool(false) == true);
	}
}

class INIFileReadTests implements IUnitTest
{
	void run()
	{
		String<u8> iniTxt = String<u8>("cow=12\nfrog=true\ntrout=fish");

		INIFile iniFile = INIFile();
		test(iniFile.read(iniTxt) == true);
		test(iniFile.entries.size() == 3);
		test(iniFile.getI64(String<u8>("cow"), 0) == 12);
		test(iniFile.getBool(String<u8>("frog"), false) == true);
		test(iniFile.getString(String<u8>("trout"), String<u8>("")).compare("fish") == true);
	}
}

class INIFileWriteTests implements IUnitTest
{
	void run()
	{
		INIFile iniFile = INIFile();
		iniFile.setEntryI64(String<u8>("cow"), 99);
		iniFile.setEntry(String<u8>("frog"), String<u8>("ribbit"));

		String<u8> iniTxt = String<u8>(16);
		test(iniFile.write(iniTxt) == true);
		test(iniTxt.contains(String<u8>("cow=99\nfrog=ribbit")) == true);
	}
}