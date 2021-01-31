////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// ITask
////////////////////////////////////////////////////////////////////////////////////////////////////

// Simple interface for tasks.
interface ITask
{
	void run();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// GlobalTasks
////////////////////////////////////////////////////////////////////////////////////////////////////

// Simple list of tasks to process.
class GlobalTasks
{
	shared ArrayList<ITask> globalProcessTasks();

	// Add task that will be run everytime process() is called.
	shared void addProcessTask(ITask task)
	{
		globalProcessTasks.add(task);
	}

	// Remove task that will be run everytime process() is called.
	shared void removeProcessTask(ITask task)
	{
		globalProcessTasks.removeElement(task);
	}

	// This should be called regularly to pump input and other events.
	shared void process(f64 sleepTimeInMs)
	{
		if(sleepTimeInMs > 0.1)
			Thread:sleep(sleepTimeInMs);

		for(u64 x=0; x<globalProcessTasks.size(); x++)
		{
			ITask task = globalProcessTasks[x];
			task.run();
		}
	}
}