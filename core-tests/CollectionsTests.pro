////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class ArrayListTests implements IUnitTest
{
	void run()
	{
		ArrayList<u32> arr0 = ArrayList<u32>(10);
		test(arr0.size() == 0);

		arr0.add(1);
		test(arr0.size() == 1);

		arr0.add(7);
		test(arr0.size() == 2);

		test(arr0.get(1) == 7);

		test(arr0[1] == 7);

		arr0.remove(0);
		test(arr0.size() == 1);

		test(arr0.get(0) == 7);

		ArrayList<String<u8>> arrB(3);
		arrB.add(String<u8>("bb"));
		arrB.add(String<u8>("cc"));
		arrB.add(String<u8>("aa"));

		test(arrB[0].compare(String<u8>("bb")) == true);

		test(arrB[0].equals(String<u8>("bb")) == true);

		arrB.sort();
		test(arrB[0].compare(String<u8>("aa")) == true);

		test(arrB[1].compare(String<u8>("bb")) == true);

		test(arrB[2].compare(String<u8>("cc")) == true);
	}
}

class ListInterfaceTests implements IUnitTest
{
	void run()
	{
		IList<u32> list = ArrayList<u32>(10);
		test(list.size() == 0);

		list.add(1);
		test(list.size() == 1);

		list.add(7);
		test(list.size() == 2);

		test(list.get(1) == 7);

		test(list[1] == 7);

		list.remove(0);
		test(list.size() == 1);

		test(list.get(0) == 7);
	}
}

class LinkedListTests implements IUnitTest
{
	void run()
	{
		LinkedList<String<u8>> list1 = LinkedList<String<u8>>();
		test(list1.size() == 0);

		list1.add(0, String<u8>("1"));
		list1.add(1, String<u8>("2"));
		list1.add(0, String<u8>("0"));

		test(list1.size() == 3);

		test(list1[0].compare("0") == true);

		test(list1[1].compare("1") == true);

		test(list1[2].compare("2") == true);

		list1.remove(1);
		test(list1.size() == 2);

		test(list1[0].compare("0") == true);

		test(list1[1].compare("2") == true);

		IIterator<String<u8>> iterator = list1.getIterator();
		
		test(iterator.hasNext() == true);

		test(iterator.next().compare("0") == true);

		test(iterator.hasNext() == true);

		test(iterator.next().compare("2") == true);

		test(iterator.hasNext() == false);

		test(iterator.next() == null);
	}
}

class ArrayMapTests implements IUnitTest
{
	void run()
	{
		ArrayMap<u32, String<u8>> map();

		test(map.size() == 0);

		map.add(0, String<u8>("Zero"));
		map.add(1, String<u8>("One"));
		map.add(2, String<u8>("Two"));

		test(map.size() == 3);

		map.remove(1);

		test(map.size() == 2);

		test(map.get(2).compare("Two") == true);

		IIterator<u32> iterator = map.getIterator();

		test(iterator.hasNext() == true);

		test(map.get(iterator.next()).compare("Zero") == true);

		test(iterator.hasNext() == true);

		test(map.get(iterator.next()).compare("Two") == true);

		test(iterator.hasNext() == false);

		// Test obj.equals(), in this case, default IObj.equals() is replaced by String.
		ArrayMap<String<u8>, u32> mapB();

		mapB.add(String<u8>("Zero"), 10);
		mapB.add(String<u8>("One"), 20);

		// testing a different string (same value, different object) gets us our value
		test(mapB.get(String<u8>("One")) == 20);

		// Test vector.equals() etc.
		ArrayMap<u32[4], u32> mapC();

		mapC.add(u32(1, 2, 3, 4), 10);
		mapC.add(u32(11, 12, 13, 14), 20);

		// testing vector gets us value
		test(mapC.get(u32(11, 12, 13, 14)) == 20);
	}
}

class ArraySetTests implements IUnitTest
{
	void run()
	{
		ArraySet<u32> set = ArraySet<u32>();

		test(set.size() == 0);

		set.add(1);
		set.add(2);
		set.add(3);

		test(set.size() == 3);

		test(set[0] == 1);

		test(set[1] == 2);

		test(set[2] == 3);

		set.remove(2);
		test(set.size() == 2);

		test(set[0] == 1);

		test(set[1] == 3);

		IIterator<u32> iterator = set.getIterator();

		test(iterator.hasNext() == true);

		test(iterator.next() == 1);

		test(iterator.hasNext() == true);

		u32 val = iterator.next();
		test(val == 3);

		test(iterator.hasNext() == false);
	}
}

class HashTableTests implements IUnitTest
{
	void run()
	{
		// Hash table
		HashTable<String<u8>> hashTableZero = HashTable<String<u8>>();
		hashTableZero.clear(); // was bug

		// Hash table
		HashTable<String<u8>> hashTable = HashTable<String<u8>>(100);

		String<u8> michaelStrObj = String<u8>("Michael");
		String<u8> jessicaStrObj = String<u8>("Jessica");

		hashTable.add(michaelStrObj);
		hashTable.add(jessicaStrObj);
		hashTable.add(String<u8>("Dan"));
		hashTable.add(String<u8>("JessicaX"));

		test(hashTable.size() == 4);

		i32 numJessicas = 0;
		i32 numMichaels = 0;
		i32 numDans     = 0;
		i32 numOthers   = 0;
		i32 numVisited  = 0;
		HashTableIterator<String<u8>> hashTableIter = hashTable.getIterator();

		test(hashTableIter.noMoreValues == false);

		bool hashTableHasNext = hashTableIter.hasNext();
		test(hashTableHasNext == true);

		test(hashTableIter.hasNext() == true);

		while(hashTableIter.hasNext() == true)
		{
			String<u8> name = hashTableIter.next();
			if(name.compare(String<u8>("Michael")) == true)
				numMichaels++;
			else if(name.compare(String<u8>("Jessica")) == true)
				numJessicas++;
			else if(name.compare(String<u8>("Dan")) == true)
				numDans++;
			else
				numOthers++;

			numVisited++;
		}

		test(numVisited == 4);

		test(numMichaels == 1 && numJessicas == 1 && numDans == 1 && numOthers == 1);

		test(hashTable.contains(michaelStrObj) == true);
		
		// test again after resizing
		hashTable.setCapacity(200);

		test(hashTable.size() == 4);

		numJessicas = 0;
		numMichaels = 0;
		numDans     = 0;
		numOthers   = 0;
		hashTableIter = hashTable.getIterator();
		while(hashTableIter.hasNext() == true)
		{
			String<u8> name = hashTableIter.next();
			if(name.compare(String<u8>("Michael")) == true)
				numMichaels++;
			else if(name.compare(String<u8>("Jessica")) == true)
				numJessicas++;
			else if(name.compare(String<u8>("Dan")) == true)
				numDans++;
			else
				numOthers++;
		}

		test(numMichaels == 1 && numJessicas == 1 && numDans == 1 && numOthers == 1);

		hashTable.remove(jessicaStrObj);

		test(hashTable.size() == 3);

		numJessicas = 0;
		numMichaels = 0;
		numDans     = 0;
		numOthers   = 0;
		hashTableIter = hashTable.getIterator();
		while(hashTableIter.hasNext() == true)
		{
			String<u8> name = hashTableIter.next();
			if(name.compare(String<u8>("Michael")) == true)
				numMichaels++;
			else if(name.compare(String<u8>("Jessica")) == true)
				numJessicas++;
			else if(name.compare(String<u8>("Dan")) == true)
				numDans++;
			else
				numOthers++;
		}

		test(numMichaels == 1 && numJessicas == 0 && numDans == 1 && numOthers == 1);
	}
}

class HashMapTests implements IUnitTest
{
	void run()
	{
		HashMap<u32, String<u8>> mapX = HashMap<u32, String<u8>>(1000);
		mapX.clear(); // bug

		HashMap<u32, String<u8>> map = HashMap<u32, String<u8>>(1000);

		test(map.size() == 0);

		map.add(0, String<u8>("Zero"));
		map.add(1, String<u8>("One"));
		map.add(2, String<u8>("Two"));

		test(map.size() == 3);

		map.remove(1);

		test(map.size() == 2);

		test(map.get(2).compare("Two") == true);

		IIterator<u32> iterator = map.getIterator();

		test(iterator.hasNext() == true);

		test(map.get(iterator.next()).compare("Zero") == true);

		test(iterator.hasNext() == true);

		test(map.get(iterator.next()).compare("Two") == true);

		test(iterator.hasNext() == false);
	}
}

class HashSetTests implements IUnitTest
{
	void run()
	{
		HashSet<u32> set = HashSet<u32>(1000);

		test(set.size() == 0);

		set.add(1);
		set.add(2);
		set.add(3);

		test(set.size() == 3);

		IIterator<u32> iter = set.getIterator();

		bool one = false;
		bool two = false;
		bool three = false;
		while(iter.hasNext())
		{
			u32 val = iter.next();
			if(val == 1)
				one = true;
			if(val == 2)
				two = true;
			if(val == 3)
				three = true;
		}

		test(one == true && two == true && three == true);

		set.remove(2);
		test(set.size() == 2);

		set.add(3); // should "replace" not add
		test(set.size() == 2);

		test(set.contains(3) == true);

		test(set.contains(1) == true);
	}
}