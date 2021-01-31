////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// LogLimit
////////////////////////////////////////////////////////////////////////////////////////////////////

// Log messages with limits on repeats of the same message.
class Log
{
	shared HashMap<String<u8>, u32> gLogLimits();
	
	// Log a message if the exact message has been logged less or equal than limit times. Limits apply to each thread/VM instance individually.
	shared void logLimit(String<u8> msg, u32 limit)
	{
		if(gLogLimits.contains(msg) == false)
			gLogLimits.add(msg, 0);

		u32 loggedNumTimes = gLogLimits.get(msg);
		if(loggedNumTimes < limit)
		{
			Log:log(msg);

			loggedNumTimes++;
			gLogLimits.add(msg, loggedNumTimes);
		}
	}

	// Log a message if the message has been logged less or equal than limit times based on uniqueToken as the key. Limits apply to each thread/VM instance individually.
	shared void logLimit(String<u8> msg, String<u8> uniqueToken, u32 limit)
	{
		if(gLogLimits.contains(uniqueToken) == false)
			gLogLimits.add(uniqueToken, 0);

		u32 loggedNumTimes = gLogLimits.get(uniqueToken);
		if(loggedNumTimes < limit)
		{
			Log:log(msg);

			loggedNumTimes++;
			gLogLimits.add(uniqueToken, loggedNumTimes);
		}
	}

	// Log a message if the message has been logged less than limit times based on uniqueToken as the key. Limits apply to each thread/VM instance individually.
	shared void logLimit(String<u8> channel, String<u8> msg, String<u8> uniqueToken, u32 limit)
	{
		if(gLogLimits.contains(uniqueToken) == false)
			gLogLimits.add(uniqueToken, 0);

		u32 loggedNumTimes = gLogLimits.get(uniqueToken);
		if(loggedNumTimes < limit)
		{
			Log:log(channel, msg);

			loggedNumTimes++;
			gLogLimits.add(uniqueToken, loggedNumTimes);
		}
	}
}