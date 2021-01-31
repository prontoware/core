 ////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2020 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// TimeSampler
////////////////////////////////////////////////////////////////////////////////////////////////////

// Track execution time including average, smallest, largest, and N% lows/highs. Measured in milliseconds.
class TimeSampler
{
    f64[] samples; // time samples in milliseconds. these are the newest maxSamples, but not guaranteed to be in-order taken since it's a circular buffer.
    u64   oldestIndex = 0; // points to the oldest (or unused) sample
    u64   numSamplesTaken = 0; // total, can be less, more or equal to samples.length()
    u64   maxSamples = 1000;
    f64   startTime;

    // maxSamples to be between 1 and anything that can fit in memory.
    void constructor(u64 maxNumSamples)
    {
        if(maxNumSamples == 0)
            maxNumSamples = 1;

        this.maxSamples = maxNumSamples;
        this.samples    = f64[](maxNumSamples);
    }

    // Start a sample
    void start()
    {
        this.startTime = System:getTime();
    }

    // Stop (collect) a sample
    void end()
    {
        f64 execTime = System:getTime() - this.startTime;

        if(oldestIndex >= samples.length())
            oldestIndex = 0;

        samples[oldestIndex] = execTime;
        oldestIndex++;

        numSamplesTaken++;
    }

    // Get number of valid samples which is less than or equal to maxSamples
    u64 getNumValidSamples()
    {
        if(numSamplesTaken < maxSamples)
            return numSamplesTaken;

        return maxSamples;
    }

    // Get the smallest of all time samples.
    f64 getSmallest()
    {
        f64 smallestTime = 1000000000000000000.0;
        for(u64 s=0; s<getNumValidSamples(); s++)
        {
            if(smallestTime > samples[s])
                smallestTime = samples[s];
        }
        return smallestTime;
    }

    // Get the largest of all time samples.
    f64 getLargest()
    {
        f64 largestTime = 0.0;
        for(u64 s=0; s<getNumValidSamples(); s++)
        {
            if(largestTime < samples[s])
                largestTime = samples[s];
        }
        return largestTime;
    }

    // Get the average of all time samples.
    f64 getAverage()
    {
        if(getNumValidSamples() == 0)
            return 0.0;

        f64 totalTime = 0.0;
        for(u64 s=0; s<getNumValidSamples(); s++)
        {
            totalTime += samples[s];
        }
        return totalTime / getNumValidSamples();
    }

    // Get average of smallest/largest samples percent. This is useful for determing worst case performance
    // metrics like what are the 0.1% of worst service times for transactions/frametimes etc. samplePercent 
    // should be 0.0 to 100.0.
    f64 getAverageFromSubset(f64 samplePercent, bool useLarge)
    {
        if(getNumValidSamples() == 0)
            return 0.0;

        f64 samplePortion = Math:minMax(0.0, 1.0, samplePercent / 100.0);

        // we need to sort samples by smallest to largest
        ArrayList<f64> sortedSamples(getNumValidSamples());
        for(u64 s=0; s<getNumValidSamples(); s++)
            sortedSamples.add(samples[s]);
        sortedSamples.sort(); // default sort for numbers is smallest to largest
        if(useLarge == true)
            sortedSamples.reverse();

        // number of samples to use
        u64 numSamplesToAvg = Math:max(1, Math:roundToInt(sortedSamples.size() * samplePortion));

        // average smallest %
        f64 totalTime = 0.0;
        for(u64 s=0; s<numSamplesToAvg; s++)
            totalTime += sortedSamples[s];

        f64 avgTime = totalTime / numSamplesToAvg;
        return avgTime;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// SystemPerf
////////////////////////////////////////////////////////////////////////////////////////////////////

// For multi-core performance testing.
void systemPerfCPUMultiThreadFunc()
{
    RandomFast r(1);
    u64 result = 0;

    // wait for start message
    u64 parentThreadID = 0;
    while(true)
    {
        IObj obj = Thread:recv();
        if(obj == null)
            continue;

        Pair<u64, u64> msg = obj;
        if(obj == null)
            return; // fail

        parentThreadID = msg.a;
        
        break;
    }
    
    // run test
    for(u64 i=0; i<SystemPerf:V1_NUM_ITERS; i++)
    {
        result += r.getU64(); // will wrap
    }

    // signal done
    Pair<u64, u64> msg2(Thread:getID(), 1);
    Thread:send(parentThreadID, msg2);
}

// Provides an estimate for system performance and tools for normalizing performance benchmarks.
// Useful for unit tests for performance monitoring etc.
class SystemPerf
{
    const u64 V1_NUM_ITERS = 100000000; // 100 000 000 iterations = about ~3 seconds runtime on 9700k
    const f64 V1_SCORE_SCALER = 0.01; // want single core range in 0 to 100 range.

    // Get performance score for system. fastMode=true is less accurate, but returns the same result in 1% of the time. Execution time from 1 to 10 seconds on modern CPUs. Baseline is Intel i7 9700k based system at ~1000 points.
    shared f64 getCPUSingleCorePerfScoreV1()
    {
        RandomFast r(1);
        u64 result = 0;

        f64 startTime = System:getTime();

        for(u64 i=0; i<V1_NUM_ITERS; i++)
        {
            result += r.getU64(); // will wrap
        }

        f64 execTime = System:getTime() - startTime;

        f64 scoreF = f64(V1_NUM_ITERS) / execTime;

        return scoreF * V1_SCORE_SCALER;
    }

    // Get performance score for system. Execution time from 1 to 10 seconds on modern CPUs. Baseline is Intel i7 9700k based system at ~1000 points per
    // physical CPU core, so ~7000 points. Due to overhead and other considerations expect the CPU multi score to be very approximately ST*(N-1) where 
    // ST is the single thread score and N is the number of physical CPU cores.
    shared f64 getCPUMultiCorePerfScoreV1()
    {
        u64 numPhysicalCPUCores = System:getCPUCoreCount();
        u64 numLogicalCPUCores  = System:getCPUThreadCount();
        u64 numThreads          = numLogicalCPUCores;
        u64 numThreadsDone      = 0;

        u64[] threadIDs(numThreads);
        u64[] threadStates(numThreads);
        f64[] threadTimes(numThreads);

        // create threads
        for(u64 t=0; t<numThreads; t++)
        {
            u64 threadID = Thread:create(String<u8>("systemPerfCPUMultiThreadFunc"), 2048, 1024 * 1024); // 1 MB heap
            threadIDs[t] = threadID;
            threadStates[t] = 0;
        }

        // give some time for thread creation
        Thread:sleep(200.0);

        f64 startTime = System:getTime();

        // make threads start work
        u64 thisThreadID = Thread:getID();
        for(u64 t=0; t<numThreads; t++)
        {
            u64 threadID = threadIDs[t];
            Pair<u64, u64> msg(thisThreadID, 0);
            Thread:send(threadID, msg);
            threadStates[t] = 1; // started
        }

        // wait for completion.
        f64 maxTime = System:getTime() + 100000.0;
        while(numThreadsDone < numThreads)
        {
            IObj obj = Thread:recv();
            if(obj != null)
            {
                Pair<u64, u64> msg = obj;
                u64 msgThreadID = msg.a;
                for(u64 t=0; t<numThreads; t++)
                {
                    if(msgThreadID == threadIDs[t])
                    {
                        if(threadStates[t] == 1)
                        {
                            threadStates[t] = 2;
                            threadTimes[t]  = System:getTime() - msg.b;
                            numThreadsDone++;
                        }
                    }
                }
            }

            Thread:sleep(1.1); // we don't want absolute time on a CPU core for this thread

            if(System:getTime() > maxTime)
                return -1.0; // error, failed
        }

        f64 execTime = System:getTime() - startTime;
        f64 scoreF = (f64(V1_NUM_ITERS) / execTime) * numThreads;

        return scoreF * V1_SCORE_SCALER;
    }

    // Get a human readable CPU performance report.
    shared String<u8> getCPUPerfReportV1()
    {
        f64 singleCoreScoreV1 = SystemPerf:getCPUSingleCorePerfScoreV1();
        f64 multiCoreScoreV1  = SystemPerf:getCPUMultiCorePerfScoreV1();

        String<u8> s(1024);
        s += "=== CPU PERFORMANCE REPORT (V1) ===\n";
        s += "Single Core Score:       " + String<u8>:formatNumber(u64(singleCoreScoreV1)) + " points\n";
        s += "Multi Core Score:        " + String<u8>:formatNumber(u64(multiCoreScoreV1)) + " points\n";
        s += "Multi Core Multiplier:   " + String<u8>:formatNumber(multiCoreScoreV1 / singleCoreScoreV1, 1) + "x\n";
        s += "Physical CPU Core Count: " + String<u8>:formatNumber(System:getCPUCoreCount()) + "\n";
        s += "Logical CPU Core Count:  " + String<u8>:formatNumber(System:getCPUThreadCount()) + "\n";
        s += "NOTE: Single core normal range is 100 to 1000 points for modern CPU in the year 2020. As reference an Intel i7 9700k scores approximately 500 points.\n";

        return s;
    }
}