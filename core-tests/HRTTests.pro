////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

// Special tests including weird HRT bugs (regression testing) etc.
class GCEatsRealObjsTests implements IUnitTest
{
	shared String<u8> hrtTestsGlobalStr;

	void run()
	{
		String<u8> str("Hello");
		hrtTestsGlobalStr = String<u8>();

		HVM:runGC(); // make sure it doesn't eat local str or global hrtTestsGlobalStr or function param msg etc.

		test(isObjRefValid(str) == true); // local param
		test(isObjRefValid(hrtTestsGlobalStr) == true); // global param

		HVM:runGC(); // make sure it doesn't eat local str or global hrtTestsGlobalStr or function param msg etc.
	}
}

class HRTBuildVersionDateTests implements IUnitTest
{
	void run()
	{
		String<u8> verStr = HVM:getVersion();

		test(verStr != null);
		test(verStr.contains("2019") || verStr.contains("2020") || verStr.contains("2021") || verStr.contains("2022") || verStr.contains("2023") || verStr.contains("2024") || verStr.contains("2025"));
	}
}

class HRTStartupVars implements IUnitTest
{
	void run()
	{
		String<u8>[] vars = HVM:getStartupVars();

		test(vars != null);
		test(vars.length() == 2); // _testvar="This is a startup variable, similar to a command line argument."
		test(vars[0].compare("testvar") == true);
		test(vars[1].compare("This is a startup variable, similar to a command line argument.") == true);
	}
}


