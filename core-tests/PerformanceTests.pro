////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2020 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class TimeSamplerTests implements IUnitTest
{
	void run()
	{
        TimeSampler s(10);

        test(s.getNumValidSamples() == 0);

        u64 i=0;

        s.start();
        f64 waitTillTime = System:getTime() + 10.0;
        while(waitTillTime > System:getTime()) { i++; }
        s.end();

        test(s.getNumValidSamples() == 1);
        test(s.getAverage() > 5.0 && s.getAverage() < 15.0);

        s.start();
        f64 waitTillTime = System:getTime() + 20.0;
        while(waitTillTime > System:getTime()) { i++; }
        s.end();

        test(s.getNumValidSamples() == 2);
        test(s.getAverage() > 10.0 && s.getAverage() < 20.0);
        test(s.getSmallest() > 5.0 && s.getSmallest() < 15.0);
        test(s.getLargest() > 15.0 && s.getLargest() < 25.0);

        s.start();
        f64 waitTillTime = System:getTime() + 25.0;
        while(waitTillTime > System:getTime()) { i++; }
        s.end();

        s.start();
        f64 waitTillTime = System:getTime() + 60.0;
        while(waitTillTime > System:getTime()) { i++; }
        s.end();

        s.start();
        f64 waitTillTime = System:getTime() + 5.0;
        while(waitTillTime > System:getTime()) { i++; }
        s.end();

        test(s.getNumValidSamples() == 5);
        test(s.getAverageFromSubset(20.0, false) > 4.0 && s.getAverageFromSubset(20.0, false) < 6.0);
        test(s.getAverageFromSubset(20.0, true) > 55.0 && s.getAverageFromSubset(20.0, true) < 65.0);
    }
}

class SystemPerformanceTests implements IUnitTest
{
	void run()
	{
        HVM:setCPUPerformance(false); // we want the HVM manager thread to not eat CPU time 

        Log:log("\nSystemPerformanceTests - CPU Report\n\n" + SystemPerf:getCPUPerfReportV1() + "\n\n");

        HVM:setCPUPerformance(true); // we want the HVM manager thread to not eat CPU time 
    }
}