////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// ProfilingTests
////////////////////////////////////////////////////////////////////////////////////////////////////

// Tests performance (CPU) and allocation (memory) profiling.
class CPUProfilingTests implements IUnitTest
{
	void run()
	{
		HVM:startPerfProfiling();

		for(u32 i=0; i<100000; i++)
		{
			fastFunc();
			slowFunc();
		}

		HVM:stopPerfProfiling();

		String<u8> xmlReport = HVM:getPerfProfilingReport();
		test(xmlReport != null);

		// report can be empty if profiling is disabled/unavailable in HRT
		if(xmlReport.length() > 50)
		{
			test(xmlReport.contains("fastFunc") == true);
			test(xmlReport.contains("slowFunc") == true);
		}
	}
}

class MemoryProfilingTests implements IUnitTest
{
	void run()
	{
		HVM:startMemoryProfiling();

		for(u32 i=0; i<100; i++)
		{
			String<u8> str = String<u8>();
			i32[] arr = i32[](i);
		}

		HVM:stopMemoryProfiling();

		String<u8> xmlReport = HVM:getMemoryProfilingReport();
		test(xmlReport != null);

		// report can be empty if profiling is disabled/unavailable in HRT
		if(xmlReport.length() > 50)
		{
			test(xmlReport.contains("String") == true);
			test(xmlReport.contains("i32[]") == true);
		}
	}
}

i32 fastFunc()
{
	i32 x = 0;
	i32 y = 11;
	return x + y;
}

i32 slowFunc()
{
	i32 total = 0;

	for(u32 a=0; a<10; a++)
	{
		total += Math:randomI32(1, 1024);	
	}

	return total;
}