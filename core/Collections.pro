////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// IComparer
////////////////////////////////////////////////////////////////////////////////////////////////////

// Interface to compare two objects for the purposes of sorting etc. 
interface IComparer<A>
{
	// Returns true if a and b are equivalent. Does not have to the same as order() returning zero
	// for order equivalency.
	bool equals(A a, A b);

	// Returns -1 if first < second, 0 if first == second, +1 is first > second
	i8 order(A a, A b);

	// Hash value.
	u64 hash(A a);

	// Clone this
	IComparer<A> clone();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// IIterator
////////////////////////////////////////////////////////////////////////////////////////////////////

// Generic iterator interface.
interface IIterator<A>
{
	// Will next() return another element?
	bool hasNext();

	// Return next element, advances. If out of bounds, returns 0/null.
	A next();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// ICollection
////////////////////////////////////////////////////////////////////////////////////////////////////

// Interface to a group of values/objects.
interface ICollection<A>
{
	// Number of elements stored in this collection.
	u64 size();

	// Duplicate collection. Element order not guaranteed to be maintained.
	ICollection<A> clone();

	// Remove all elements in this collection.
	void clear();

	// Get iterator for this collection.
	IIterator<A> getIterator();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// IList
////////////////////////////////////////////////////////////////////////////////////////////////////

// Interface to a list of values or objects.
interface IList<A>
{
	// Number of elements stored in this collection.
	u64 size();

	// Duplicate this list, maintains elements order.
	ICollection<A> clone();

	// Get an element by index. Overloads '[]' operator too.
	A get(u64 index);

	// Add an element to the end of the list.
	void add(A element);

	// Add an element to the end of the list.
	void add(u64 index, A element);

	// Add all elements from passed-in list to this.
	void addAll(IList<A> list);

	// Remove all elements in this list.
	void clear();

	// Remove an element from the list by index.
	A remove(u64 index);

	// Get last element of list.
	A getLast();

	// Remove last element of list.
	A removeLast();

	// Get iterator for this collection.
	IIterator<A> getIterator();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// ArrayListIterator
////////////////////////////////////////////////////////////////////////////////////////////////////

// For visiting all elements once.
class ArrayListIterator<A> implements IIterator<A>
{
	A[] data     = null;
	u64 numUsed  = 0;
	u64 curIndex = 0;

	void constructor(A[] dataIn, u64 numUsedIn)
	{
		this.data     = dataIn;
		this.numUsed  = numUsedIn;
		this.curIndex = 0;
	}

	// Will next() return another element?
	bool hasNext()
	{
		if(curIndex < numUsed)
			return true;

		return false;
	}

	// Return next element, advances. If out of bounds, returns 0/null.
	A next()
	{
		if(curIndex >= numUsed)
			return null;

		curIndex++;

		return data[curIndex - 1];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// ArrayList
////////////////////////////////////////////////////////////////////////////////////////////////////

// List backed by a resizable array.
class ArrayList<A> implements IList<A>, ICollection<A>
{
	A[]   data    = null; // array of A
	u64   numUsed = 0;    // num spots used

	void constructor()
	{
		data     = null;
		numUsed  = 0;
	}

	// Create an array with an initial number of spots allocated.
	void constructor(u64 initCapacity)
	{
		if(initCapacity > 0)
		{
			this.data     = A[](initCapacity);
			this.numUsed  = 0;
		}
	}

	// Duplicate this list. Maintains order.
	ICollection<A> clone()
	{
		ArrayList<A> newList = ArrayList<A>();

		newList.data     = A[](this.numUsed);
		newList.numUsed  = this.numUsed;

		for(u64 c=0; c<this.numUsed; c++)
			newList.data[c] = this.data[c];

		return newList;
	}

	// Get element by index. Overloads '[]' operator.
	A get(u64 index)
	{
		return data[index];
	}

	// Set element by index. Overloads '[]' operator.
	void set(u64 index, A element)
	{
		data[index] = element;
	}

	// Get iterator for this collection.
	IIterator<A> getIterator()
	{
		IIterator<A> iter = ArrayListIterator<A>(data, numUsed);
		return iter;
	}

	// Change the number of used spaces - capacity will be resized if needed.
	void setSize(u64 numUsed)
	{
		if(numUsed > data.length())
			setCapacity(numUsed);

		this.numUsed = numUsed;
	}

	// The number of objects stored in this list
	u64 size()
	{
		return numUsed;
	}

	// The number of declared spots available in total for objects to be stored in
	u64 capacity()
	{
		return data.length();
	}

	// Get last element of list
	A getLast()
	{
		return data[numUsed-1];
	}

	// Add to end index.
	void add(A val)
	{
		add(numUsed, val);
	}

	// Insert into specific index.
	void add(u64 index, A val)
	{
		if(this.data == null)
			setCapacity(1);

		u64 len = this.data.length();
		
		if(numUsed == len)
		{
			if(numUsed > 4)
				setCapacity(len * 2); // double up
			else
				setCapacity(len + 1); // save memory on small lists
		}

		for(u64 i=numUsed; i>index; i--)
		{
			data[i] = data[i-1];
		}

		data[index] = val;

		numUsed++;
	}

	// Shuffle two values in the list.
	void swap(u64 indexA, u64 indexB)
	{
		A aVal = data[indexA];
		data[indexA] = data[indexB];
		data[indexB] = aVal;
	}

	// Add all elements from passed-in list.
	void addAll(IList<A> list)
	{
		for(u64 a=0; a<list.size(); a++)
			add(list.get(a));
	}

	// Remove by index.
	A remove(u64 index)
	{
		if(index < 0 || index >= numUsed)
			return data[0];

		A a = data[index];

		for(u64 i=index; i+1<numUsed; i++)
			data[i] = data[i+1];

		numUsed--;

		return a;
	}

	// Remove last, size()-1 index.
	A removeLast()
	{
		u64 index = size()-1;
		return remove(index);
	}

	// Remove one or more by indices, inclusive.
	void remove(u64 startIndex, u64 endIndex)
	{
		if(startIndex < 0 || startIndex >= numUsed)
			return;

		if(endIndex < 0 || endIndex >= numUsed)
			return;

		if(startIndex > endIndex)
			return;

		for(u64 i=startIndex; i+1<numUsed; i++)
		{
			if(endIndex + (i - startIndex) + 1 < numUsed)
				data[i] = data[endIndex + (i - startIndex) + 1];
		}

		numUsed -= (endIndex - startIndex) + 1;
	}

	// Contains check using equality equals().
	bool contains(A a)
	{
		for(u64 i=0; i<numUsed; i++)
		{
			if(data[i].equals(a))
				return true;
		}

		return false;
	}

	// Remove first element in list to match by using equality equals().
	bool removeElement(A a)
	{
		for(u64 i=0; i<numUsed; i++)
		{
			if(data[i].equals(a))
			{
				remove(i);
				return true;
			}
		}

		return false;
	}

	// Clear all elements from list.
	void clear()
	{
		numUsed = 0;
	}

	// Copy over elements from passed-in.
	void copy(ArrayList<A> list)
	{
		numUsed = 0;
		addAll(list);
	}

	// Set the unused portion of the data array to some value (i.e. for debugging etc.)
	void setUnused(A val)
	{
		for(u64 i=numUsed; i<data.length(); i++)
			data[i] = val;
	}

	// Set how many spots are available to hold elements.
	void setCapacity(u64 newCapacity)
	{
		if(data != null)
		{
			A[] newData = A[](newCapacity);

			u64 copyToIndex = newCapacity;
			if(numUsed < newCapacity)
				copyToIndex = numUsed;

			for(u64 c=0; c<copyToIndex; c++)
				newData[c] = data[c];

			data     = newData;
			numUsed  = copyToIndex;
		}
		else
		{
			data     = A[](newCapacity);
			numUsed  = 0;
		}
	}

	// Reverse elements order.
	void reverse()
	{
		A temp;

		u64 b = numUsed-1;
		for(u64 a=0; a<numUsed; a++)
		{
			if(a >= b)
				break;

			temp = data[b];
			data[b] = data[a];
			data[a] = temp;

			b--;
		}
	}

	// Fast sort (from least to greatest) based on natural ordering via lessThan() / moreThan().
	void sort()
	{
		if(numUsed <= 1)
			return; //already sorted

		quickSort(0, numUsed-1);
	}

	// Sort in-place using quicksort via lessThan() / moreThan().
	void quickSort(i64 left, i64 right)
	{
		i64 moveLeft  = left;
		i64 moveRight = right;
		A tmp;
		A pivot = data[(left + right) / 2];

		while(moveLeft < moveRight)
		{
			// Minimize number of swaps by checking for already sorted items on both sides

			while(data[moveLeft].lessThan(pivot) == true)
				moveLeft++;

			while(data[moveRight].moreThan(pivot) == true)
				moveRight--;

			if(moveLeft <= moveRight)
			{
				tmp = data[moveLeft];
				data[moveLeft] = data[moveRight];
				data[moveRight] = tmp;
				moveLeft++;
				moveRight--;
			}
		}

		if(left < moveRight)
			quickSort(left, moveRight);

		if(moveLeft < right)
			quickSort(moveLeft, right);
	}

	// Fast sort (from least to greatest) based on comparer.
	void sort(IComparer<A> comparer)
	{
		if(numUsed <= 1)
			return; //already sorted

		quickSort(0, numUsed-1, comparer);
	}

	// Fast sort of sub-list (from least to greatest) based on comparer.
	void sort(IComparer<A> comparer, u64 startIndex, u64 endIndex)
	{
		if(numUsed <= 1)
			return; //already sorted

		quickSort(startIndex, endIndex, comparer);
	}

	// Sort in-place using quicksort via comparer.
	void quickSort(i64 left, i64 right, IComparer<A> comparer)
	{
		i64 moveLeft = left;
		i64 moveRight = right;
		A tmp;
		A pivot = data[(left + right) / 2];

		while(moveLeft < moveRight)
		{
			// Minimize number of swaps by checking for already sorted items on both sides

			while(comparer.order(data[moveLeft], pivot) < 0)
				moveLeft++;

			while(comparer.order(data[moveRight], pivot) > 0)
				moveRight--;

			if(moveLeft <= moveRight)
			{
				tmp = data[moveLeft];
				data[moveLeft] = data[moveRight];
				data[moveRight] = tmp;
				moveLeft++;
				moveRight--;
			}
		}

		if(left < moveRight)
			quickSort(left, moveRight, comparer);

		if(moveLeft < right)
			quickSort(moveLeft, right, comparer);
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// LinkedListNode
////////////////////////////////////////////////////////////////////////////////////////////////////

// For internal usage by LinkedList.
class LinkedListNode<A>
{
	A val;
	LinkedListNode<A> prevNode;
	LinkedListNode<A> nextNode;

	void constructor(LinkedListNode<A> prevNode, A val, LinkedListNode<A> nextNode)
	{
		this.prevNode = prevNode;
		this.val = val;
		this.nextNode = nextNode;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// LinkedListIterator
////////////////////////////////////////////////////////////////////////////////////////////////////

// Implements Iterator interface for LinkedList.
class LinkedListIterator<A> implements IIterator<A>
{
	LinkedListNode<A> curNode;

	void constructor(LinkedListNode<A> firstNode)
	{
		this.curNode = firstNode;
	}

	bool hasNext()
	{
		if(curNode == null)
			return false;

		return true;
	}

	A next()
	{
		if(curNode == null)
			return null; // nicely evaluates to zero for numeric types

		A val   = curNode.val;
		curNode = curNode.nextNode;

		return val;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// LinkedList
////////////////////////////////////////////////////////////////////////////////////////////////////

// Basic double-linked list implementation. O(n) insertion at start/end. O(n) retrieval at start/end.
class LinkedList<A> implements IList<A>, ICollection<A>
{
	LinkedListNode<A> firstNode;
	LinkedListNode<A> lastNode;
	u64 numUsed; // number of nodes

	void constructor()
	{
		this.firstNode  = null;
		this.lastNode   = null;
		this.numUsed    = 0;
	}

	// Duplicate this list. Maintains order.
	ICollection<A> clone()
	{
		LinkedList<A> newList = LinkedList<A>();

		LinkedListNode<A> curNode = firstNode;
		while(curNode != null)
		{
			newList.add(curNode.val);
			curNode = curNode.nextNode;
		}

		return newList;
	}

	// Return number of elements stored
	u64 size() { return numUsed; }

	// Get an element by index.
	A get(u64 index)
	{
		if(index >= numUsed)
			return null;

		if(index == numUsed-1) // O(n) retrieval promise
			return lastNode.val;

		LinkedListNode<A> curNode = firstNode;
		for(u64 i=0; i<index; i++)
			curNode = curNode.nextNode;

		return curNode.val;
	}

	// Set an element by index.
	void set(u64 index, A val)
	{
		if(index >= numUsed)
			return;

		if(index == numUsed-1) // O(n) retrieval promise
			return;

		LinkedListNode<A> curNode = firstNode;
		for(u64 i=0; i<index; i++)
			curNode = curNode.nextNode;

		curNode.val = val;
	}

	// Add an element to end of list.
	void add(A val)
	{
		add(size(), val);
	}

	// Add an element.
	void add(u64 index, A val)
	{
		if(index > numUsed)
			index = numUsed; // insert at end

		if(firstNode == null)
		{
			firstNode = LinkedListNode<A>(null, val, null);
			lastNode  = firstNode;
		}
		else if(index == numUsed)
		{
			// O(n) insert at end
			LinkedListNode<A> newNode = LinkedListNode<A>(lastNode, val, null);
			lastNode.nextNode = newNode;
			lastNode = newNode;
		}
		else
		{
			LinkedListNode<A> curNode = firstNode;
			for(u64 i=0; i<index; i++)
				curNode = curNode.nextNode;

			LinkedListNode<A> newNode = LinkedListNode<A>(curNode.prevNode, val, curNode);
			curNode.prevNode = newNode;
			if(newNode.prevNode != null)
				newNode.prevNode.nextNode = newNode;
			else
				firstNode = newNode;
		}

		numUsed++;
	}

	// Add all elements of another list to this list.
	void addAll(IList<A> list)
	{
		for(u64 c=0; c<list.size(); c++)
			add(list.get(c));
	}

	//Remove an element
	A remove(u64 index)
	{
		if(index >= numUsed)
			return firstNode.val;

		LinkedListNode<A> curNode = firstNode;
		for(u64 i=0; i<index; i++)
			curNode = curNode.nextNode;

		if(curNode.prevNode != null)
			curNode.prevNode.nextNode = curNode.nextNode;
		else
			firstNode = curNode.nextNode;

		if(curNode.nextNode != null)
			curNode.nextNode.prevNode = curNode.prevNode;
		else
			lastNode = curNode.prevNode;

		A a = curNode.val;

		numUsed--;

		return a;
	}

	// Remove one or more elements
	void remove(u64 startIndex, u64 endIndex)
	{
		// Not very efficient
		u64 numElements = (endIndex + 1) - startIndex;
		for(u64 i=0; i<numElements; i++)
			remove(startIndex);
	}

	// Get last element of list.
	A getLast()
	{
		if(lastNode == null)
			return null;

		return lastNode.val;
	}

	// Remove last element of list.
	A removeLast()
	{
		if(lastNode == null)
			return null;

		LinkedListNode<A> oldNode = lastNode;
		A val = lastNode.val;

		lastNode = lastNode.prevNode;

		numUsed--;

		if(numUsed == 0)
		{
			firstNode = null;
		}

		return val;
	}

	// Remove all elements.
	void clear()
	{
		LinkedListNode<A> curNode = firstNode;
		for(u64 i=0; i<numUsed; i++)
		{
			LinkedListNode<A> deleteNode = curNode;
			curNode = curNode.nextNode;
		}
	}

	// Return iterator for visiting all elements once.
	IIterator<A> getIterator()
	{
		return LinkedListIterator<A>(firstNode);
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Single
////////////////////////////////////////////////////////////////////////////////////////////////////

// Useful for wrapping primitives like u8, i8, ... f64. Also vectors u8[16] etc.
class Single<A>
{
	A a;

	// Do nothing constructor
	void constructor() { }

	// Set key/value
	void constructor(A aVal)
	{
		a = aVal;
	}

	// Get value
	A get() { return a; }

	// Get value (array [] operator overload)
	A get(u64 index) { return a; }

	// Set value
	void set(A a) { this.a = a; }

	// Set value (array [] operator overload)
	void set(u64 index, A a) { this.a = a; }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Pair
////////////////////////////////////////////////////////////////////////////////////////////////////

// Simple pair of values (i.e. key/value)
class Pair<A,B>
{
	A a;
	B b;

	// Do nothing constructor
	void constructor() { }

	// Set key/value
	void constructor(A aVal, B bVal)
	{
		a = aVal;
		b = bVal;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// IMap
////////////////////////////////////////////////////////////////////////////////////////////////////

// Interface to a map of key/value pairs.
interface IMap<A,B>
{
	// Number of elements stored in this collection.
	u64 size();

	// Duplicate collection. Element order not guaranteed to be maintained.
	ICollection<A> clone();

	// Remove all elements in this collection.
	void clear();

	// Get iterator for this collection.
	IIterator<A> getIterator();

	// Add all key/value pairs of passed-in map to this map.
	void addAll(IMap<A, B> map);

	// Add/replace single key/val pair mapping.
	void add(A key, B val);

	// Get value by key.
	B get(A key);

	// Looking for key to remove mapping.
	void remove(A key);

	// Check if key is in map.
	bool contains(A key);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// ArrayMapIterator
////////////////////////////////////////////////////////////////////////////////////////////////////

// For use with ArrayMap.
class ArrayMapIterator<A> implements IIterator<A>
{
	ArrayList<A> keys;
	u64 curIndex;

	void constructor(ArrayList<A> keysIn)
	{
		keys = keysIn;
		curIndex = 0;
	}

	bool hasNext()
	{
		if(curIndex < keys.size())
			return true;

		return false;
	}

	A next()
	{
		curIndex++;

		if(curIndex-1 < keys.size())
			return keys.get(curIndex-1);

		return null;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// ArrayMap
////////////////////////////////////////////////////////////////////////////////////////////////////

// Uses IComparer<A> for equality check.
class ArrayMap<A,B> implements IMap<A,B>, ICollection<A>
{
	ArrayList<A> keys = ArrayList<A>();
	ArrayList<B> vals = ArrayList<B>();
	IComparer<A> comparer = null; // strategy pattern usage

	// Uses equals() default comparison.
	void constructor()
	{

	}

	// Set how keys are tested for equality. Pass-in null for == operator default check.
	void constructor(IComparer<A> comparerTest)
	{
		comparer = comparerTest;
	}

	// Uses == operator default check.
	void constructor(u64 initCapacity)
	{
		keys.setCapacity(initCapacity);
		vals.setCapacity(initCapacity);
	}

	// Set how keys are tested for equality. Pass-in null for == operator default check.
	void setComparer(IComparer<A> comparerTest)
	{
		comparer = comparerTest;
	}

	// Clone exact, keeping element order.
	ICollection<A> clone()
	{
		ArrayMap<A,B> newMap = ArrayMap<A,B>();

		if(comparer != null)
			newMap.setComparer(comparer.clone());

		for(u64 i=0; i<size(); i++)
			newMap.add(getKeyByIndex(i), getValueByIndex(i));

		return newMap;
	}

	// Get keys iterator.
	IIterator<A> getIterator()
	{
		return ArrayMapIterator<A>(keys);
	}

	// Get keys internal list.
	ArrayList<A> getKeys()
	{
		return keys;
	}

	// Add all key/value pairs of passed-in map to this map.
	void addAll(IMap<A, B> map)
	{
		IIterator<A> iter = map.getIterator();
		while(iter.hasNext())
		{
			A key = iter.next();
			B val = map.get(key);
			add(key, val);
		}
	}

	// Add/replace single key/val pair mapping.
	void add(A key, B val)
	{
		// find existing
		if(comparer == null)
		{
			for(u64 k=0; k<keys.size(); k++)
			{
				if(key.equals(keys.get(k)))
				{
					keys[k] = key; // replace existing
					vals[k] = val;
					return;
				}
			}
		}
		else
		{
			for(u64 k=0; k<keys.size(); k++)
			{
				if(comparer.equals(key, keys.get(k)) == true)
				{
					keys[k] = key; // replace existing
					vals[k] = val;
					return;
				}
			}
		}

		// new key
		keys.add(key);
		vals.add(val);
	}

	// Get value by key
	B get(A key)
	{
		// Find existing
		if(comparer == null)
		{
			for(u64 k=0; k<keys.size(); k++)
			{
				if(key.equals(keys.get(k)))
				{
					return vals.get(k);
				}
			}
		}
		else
		{
			for(u64 k=0; k<keys.size(); k++)
			{
				if(comparer.equals(key, keys.get(k)) == true)
				{
					return vals.get(k);
				}
			}
		}

		return null;
	}

	// Get a key by 0 ... N index
	A getKeyByIndex(u64 index)
	{
		return keys.get(index);
	}

	// Get a value by 0 ... N index
	B getValueByIndex(u64 index)
	{
		return vals.get(index);
	}

	// Looking for key.
	bool contains(A key)
	{
		// Find existing
		if(comparer == null)
		{
			for(u64 k=0; k<keys.size(); k++)
			{
				if(key.equals(keys.get(k)))
				{
					return true;
				}
			}
		}
		else
		{
			for(u64 k=0; k<keys.size(); k++)
			{
				if(comparer.equals(key, keys.get(k)) == true)
				{
					return true;
				}
			}
		}

		return false;
	}

	// Looking for key to remove mapping.
	void remove(A key)
	{
		// Find existing
		if(comparer == null)
		{
			for(u64 k=0; k<keys.size(); k++)
			{
				if(key.equals(keys.get(k)))
				{
					keys.remove(k);
					vals.remove(k);
					return;
				}
			}
		}
		else
		{
			for(u64 k=0; k<keys.size(); k++)
			{
				if(comparer.equals(key, keys.get(k)) == true)
				{
					keys.remove(k);
					vals.remove(k);
					return;
				}
			}
		}
	}

	// Number of mappings
	u64 size()
	{
		return keys.size();
	}

	// Clear all mappings
	void clear()
	{
		keys.clear();
		vals.clear();
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// ISet
////////////////////////////////////////////////////////////////////////////////////////////////////

interface ISet<A>
{
	// Number of elements stored in this collection.
	u64 size();

	// Duplicate collection. Element order not guaranteed to be maintained.
	ICollection<A> clone();

	// Remove all elements in this collection.
	void clear();

	// Get iterator for this collection.
	IIterator<A> getIterator();

	// Add a unique element
	void add(A object);

	// Remove a unique element
	void remove(A object);

	// Contains?
	bool contains(A object);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// ArraySet
////////////////////////////////////////////////////////////////////////////////////////////////////

// This set does a linear search for each contains check, making it only suitable for small 
// sets (i.e. < 10 elements), or large sets that use the contains check infrequently.
class ArraySet<A> implements ISet<A>, ICollection<A>
{
	ArrayList<A> list = ArrayList<A>();
	IComparer<A> comparer = null; // strategy pattern usage

	// Default constructor, uses equals() for equality.
	void constructor() { }

	// Set how elements are tested for equality. Pass-in null for == operator default check.
	void constructor(IComparer<A> comparerTest)
	{
		comparer = comparerTest;
	}

	// Set how keys are tested for equality. Pass-in null for equals() operator default check.
	void setComparer(IComparer<A> comparerTest)
	{
		comparer = comparerTest;
	}

	// Clone exact, keeping element order.
	ICollection<A> clone()
	{
		ArraySet<A> newSet = ArraySet<A>();

		if(comparer != null)
			newSet.setComparer(comparer.clone());

		for(u64 i=0; i<size(); i++)
			newSet.add(list.get(i));

		return newSet;
	}

	// Get iterator.
	IIterator<A> getIterator()
	{
		return ArrayListIterator<A>(list.data, list.numUsed);
	}

	// Overload [] operator
	A get(u64 index)
	{
		return list.data[index];
	}

	// Overload [] operator (set)
	void set(u64 index, A val)
	{
		list.data[index] = val;
	}

	// Add - overwrites existing.
	void add(A object)
	{
		if(comparer == null)
		{
			for(u64 c=0; c<list.size(); c++)
			{
				if(list.get(c).equals(object))
					return; // already added
			}
		}
		else
		{
			for(u64 c=0; c<list.size(); c++)
			{
				if(comparer.equals(list.get(c), object) == true)
					return; // already added
			}
		}

		list.add(list.size(), object);
	}

	// Add all elements of a collection to this.
	void addAll(ICollection<A> set)
	{
		IIterator<A> iter = set.getIterator();
		while(iter.hasNext() == true)
			add(iter.next());
	}

	// Remove element.
	void remove(A object)
	{
		if(comparer == null)
		{
			for(u64 c=0; c<list.size(); c++)
			{
				if(list.get(c).equals(object))
				{
					list.remove(c);
					return;
				}
			}
		}
		else
		{
			for(u64 c=0; c<list.size(); c++)
			{
				if(comparer.equals(list.get(c), object) == true)
				{
					list.remove(c);
					return;
				}
			}
		}
	}

	// Check if element already in set.
	bool contains(A object)
	{
		if(comparer == null)
		{
			for(u64 c=0; c<list.size(); c++)
			{
				if(list.get(c).equals(object))
					return true;
			}
		}
		else
		{
			for(u64 c=0; c<list.size(); c++)
			{
				if(comparer.equals(list.get(c), object) == true)
					return true;
			}
		}

		return false;
	}

	void clear()
	{
		list.clear();
	}

	u64 size()
	{
		return list.size();
	}
}

//////////////////////////////////////////////////////////////////////////////////////////
// HashTableIterator
//////////////////////////////////////////////////////////////////////////////////////////

class HashTableIterator<A> implements IIterator<A>
{
	ArrayList<A>            singlesTable;     // if there is one/none entry for the hash value
	ArrayList<bool>         singlesUsedTable; // true if singles table value is in-use
	ArrayList<ArrayList<A>> collisionsTable;  // always same size as singlesTable

	u64  index = 0; // if zero, in signles tables, is >= 1, collisionsTable
	u64  subIndex = 0;
	bool noMoreValues = false;

	void constructor(ArrayList<A> singlesTableIn, ArrayList<bool> singlesUsedTableIn, ArrayList<ArrayList<A>> collisionsTableIn)
	{
		this.singlesTable     = singlesTableIn;
		this.singlesUsedTable = singlesUsedTableIn;
		this.collisionsTable  = collisionsTableIn;

		this.index        = 0;
		this.subIndex     = 0;
		this.noMoreValues = false;

		goToNextValue();
	}

	bool hasNext()
	{
		return !noMoreValues;
	}

	A next()
	{
		if(noMoreValues == true)
			return null;

		u32 curIndex    = index;
		u32 curSubIndex = subIndex;

		subIndex++; // skip current since we return it
		goToNextValue();

		if(curSubIndex == 0)
			return singlesTable.data[curIndex];

		return collisionsTable.data[curIndex][curSubIndex-1];
	}

	// Move index & subIndex to next value
	void goToNextValue()
	{
		// subIndex++; let caller do this so we can get first value in constructor

		for(u64 xx=0; index<singlesTable.size(); index++)
		{
			if(singlesUsedTable[index] == false)
			{
				subIndex = 0;
				continue;
			}
			else if(subIndex == 0)
				return;

			if(collisionsTable[index] == null)
			{
				subIndex = 0;
			}
			else
			{
				if((subIndex-1) < collisionsTable[index].size())
					return;
				else
					subIndex = 0;
			}
		}

		noMoreValues = true;
	}
}

//////////////////////////////////////////////////////////////////////////////////////////
// HashTable
//////////////////////////////////////////////////////////////////////////////////////////

// HashTable will use equals() and getHash() primitive/IObj methods by default for 
// sorting etc. Can optionally provide IComparer<A> for equality checks. Provides O(n)
// insertion, removal, contains, and retrieval when the operations don't generate collisions.
class HashTable<A> implements ICollection<A>
{
	// Tri-table setup ensures we make far fewer dynamic memory allocations (only for collisions)
	ArrayList<A>            singlesTable;     // if there is one/none entry for the hash value
	ArrayList<bool>         singlesUsedTable; // true if singlesTable has valid entry
	ArrayList<ArrayList<A>> collisionsTable;  // always same size as table

	IComparer<A> comparer = null;
	u64 numObjects = 0;

	// Default-sized table.
	void constructor()
	{
		create(128);
	}

	// Pre-sized table.
	void constructor(u64 initSize)
	{
		create(initSize);
	}

	// HashTable owns comparer.
	void constructor(IComparer<A> comparer, u64 initSize)
	{
		this.comparer = comparer;
		create(initSize);
	}

	// Create with allocated number of spots.
	void create(u64 initSize)
	{
		if(initSize == 0)
			initSize = 1;

		singlesTable         = ArrayList<A>(initSize);
		singlesTable.numUsed = singlesTable.data.length();

		singlesUsedTable         = ArrayList<bool>(initSize);
		singlesUsedTable.numUsed = singlesTable.data.length();

		collisionsTable         = ArrayList<ArrayList<A>>(initSize);
		collisionsTable.numUsed = singlesTable.data.length();

		numObjects = 0;
	}

	// Clone
	ICollection<A> clone()
	{
		HashTable<A> newTable = null;
		if(comparer == null)
			newTable = HashTable<A>(singlesTable.size());
		else
			newTable = HashTable<A>(comparer.clone(), singlesTable.size());

		// copy over items
		IIterator<A> iter = getIterator();
		while(iter.hasNext() == true)
		{
			newTable.add(iter.next());
		}

		return newTable;
	}

	// Set how elements are tested for equality. Pass-in null for default equals()/getHash() check.
	void setComparer(IComparer<A> comparerTest)
	{
		comparer = comparerTest;
	}

	// Returns number of objects stored in this hash table
	u64 size()
	{
		return numObjects;
	}

	// Iterator
	IIterator<A> getIterator()
	{
		return HashTableIterator<A>(singlesTable, singlesUsedTable, collisionsTable);
	}

	// Returns the found object or null/zero if not found.
	A get(A obj)
	{
		if(singlesTable.numUsed == 0)
			return null;

		if(comparer == null)
		{
			u64 tableIndex = obj.getHash() % singlesTable.numUsed;

			// O(n) case, single used, no collisions
			if(singlesUsedTable[tableIndex] == false)
				return null;

			if(singlesTable[tableIndex].equals(obj))
				return singlesTable[tableIndex];

			if(collisionsTable[tableIndex] == null)
				return null;

			// Not O(n), search through collision array because single isn't the match
			ArrayList<A> list = collisionsTable[tableIndex];
			if(list == null)
				return null;

			
			// Really just a contains check since we return the exact object
			for(u64 s=0; s<list.numUsed; s++)
			{
				if(obj.equals(list[s]))
				{
					return list[s];
				}
			}
		}
		else
		{
			u64 tableIndex = comparer.hash(obj) % singlesTable.numUsed;

			// O(n) case, single used, no collisions
			if(singlesUsedTable[tableIndex] == false)
				return null;

			if(comparer.equals(singlesTable[tableIndex], obj) == true)
				return singlesTable[tableIndex];
			
			if(collisionsTable[tableIndex] == null)
				return null;

			// Not O(n), search through collision array because single isn't the match
			ArrayList<A> list = collisionsTable[tableIndex];
			if(list == null)
				return null;

			// We return object from table that compares the same as the passed-in obj, but might have extra info.
			for(u64 s=0; s<list.numUsed; s++)
			{
				if(comparer.equals(obj, list[s]) == true)
				{
					return list[s];
				}
			}
		}

		return null;
	}

	// Returns true if object is already in table
	bool contains(A obj)
	{
		if(singlesTable.numUsed == 0)
			return false;

		if(comparer == null)
		{
			u64 tableIndex = obj.getHash() % singlesTable.numUsed;

			// O(n) case, single used, no collisions
			if(singlesUsedTable[tableIndex] == false)
				return false;

			if(singlesTable[tableIndex].equals(obj))
				return true;

			if(collisionsTable[tableIndex] == null)
				return false;

			// Not O(n), search through collision array because single isn't the match
			ArrayList<A> list = collisionsTable[tableIndex];
			if(list == null)
				return false;

			// Really just a contains check since we return the exact object
			for(u64 s=0; s<list.numUsed; s++)
			{
				if(obj.equals(list[s]))
				{
					return true;
				}
			}
		}
		else
		{
			u64 tableIndex = comparer.hash(obj) % singlesTable.numUsed;

			// O(n) case, single used, no collisions
			if(singlesUsedTable[tableIndex] == false)
				return false;
			
			if(comparer.equals(singlesTable[tableIndex], obj) == true)
				return true;
			
			if(collisionsTable[tableIndex] == null)
				return false;

			// Not O(n), search through collision array because single isn't the match
			ArrayList<A> list = collisionsTable[tableIndex];
			if(list == null)
				return false;

			// We return object from table that compares the same as the passed-in obj, but might have extra info.
			for(u64 s=0; s<list.numUsed; s++)
			{
				if(comparer.equals(obj, list[s]) == true)
				{
					return true;
				}
			}
		}

		return false;
	}

	// Add/Replace an element.
	void add(A obj)
	{
		if(singlesTable.size() == 0)
		{
			setCapacity(10);
		}

		if(singlesTable.numUsed == 0)
			return;

		if(comparer == null)
		{
			u64 tableIndex = obj.getHash() % singlesTable.numUsed;

			// O(n) case, single used, no collisions
			if(singlesUsedTable[tableIndex] == false)
			{
				singlesTable[tableIndex] = obj; // add
				singlesUsedTable[tableIndex] = true;
				numObjects++;
				return;
			}

			if(singlesTable[tableIndex].equals(obj))
			{
				//singlesTable[tableIndex] = obj; // this is a noop because it's *exactly* the same object or numeric value
				return;
			}

			// First collision?
			if(collisionsTable[tableIndex] == null)
			{
				collisionsTable[tableIndex] = ArrayList<A>(2); // if we have one collision, we probably will have more than one
				collisionsTable[tableIndex].add(obj);
				numObjects++;
				return;
			}

			// Not O(n), search through collision array because single isn't the match
			ArrayList<A> list = collisionsTable[tableIndex];

			// Really just a contains check since we return the exact object
			for(u64 s=0; s<list.numUsed; s++)
			{
				if(obj.equals(list[s]))
				{
					//return list[s]; // noop because obj is *identical* obj ref / value to existing
					return;
				}
			}

			// add as collision
			list.add(obj);
			numObjects++;
		}
		else
		{
			u64 tableIndex = comparer.hash(obj) % singlesTable.numUsed;

			// O(n) case, single used, no collisions
			if(singlesUsedTable[tableIndex] == false)
			{
				singlesTable[tableIndex] = obj; // add
				singlesUsedTable[tableIndex] = true;
				numObjects++;
				return;
			}

			if(comparer.equals(singlesTable[tableIndex], obj) == true)
			{
				singlesTable[tableIndex] = obj; // replace
				return;
			}
			
			// First collision?
			if(collisionsTable[tableIndex] == null)
			{
				collisionsTable[tableIndex] = ArrayList<A>(2); // if we have one collision, we probably will have more than one
				collisionsTable[tableIndex].add(obj);
				numObjects++;
				return;
			}

			// Not O(n), search through collision array because single isn't the match
			ArrayList<A> list = collisionsTable[tableIndex];
			
			// We return object from table that compares the same as the passed-in obj, but might have extra info.
			for(u64 s=0; s<list.numUsed; s++)
			{
				if(comparer.equals(obj, list[s]) == true)
				{
					list[s] = obj; // replace
					return;
				}
			}

			// add as collision
			list.add(obj);
			numObjects++;
		}
	}

	// Add all elements of a collection to this.
	void addAll(ICollection<A> collection)
	{
		IIterator<A> iter = collection.getIterator();
		while(iter.hasNext() == true)
			add(iter.next());
	}

	// Returns true if object was found and removed, false otherwise
	void remove(A obj)
	{
		if(singlesTable.numUsed == 0)
			return;

		if(comparer == null)
		{
			u64 tableIndex = obj.getHash() % singlesTable.numUsed;

			// O(n) case, nothing stored
			if(singlesUsedTable[tableIndex] == false)
				return;

			bool singlesMatch = false;
			if(singlesTable[tableIndex].equals(obj))
				singlesMatch = true;

			// O(n) case, single is match
			if(singlesMatch == true)
			{
				singlesUsedTable[tableIndex] = false;
				numObjects--;

				if(collisionsTable[tableIndex] == null)
					return;
				if(collisionsTable[tableIndex].size() == 0)
					return;

				// shift collision table entry down
				singlesUsedTable[tableIndex] = true;
				singlesTable[tableIndex] = collisionsTable[tableIndex].removeLast();
				return;
			}

			// Not O(n), search through collision array because single isn't the match, but we have collisions
			ArrayList<A> list = collisionsTable[tableIndex];
			if(list == null)
				return; // no collision table means no possible matches

			// Really just a contains check since we return the exact object
			for(u64 s=0; s<list.numUsed; s++)
			{
				if(obj.equals(list[s]))
				{
					list.remove(s);
					numObjects--;
					return;
				}
			}
		}
		else
		{
			u64 tableIndex = comparer.hash(obj) % singlesTable.numUsed;

			// O(n) case, nothing stored
			if(singlesUsedTable[tableIndex] == false)
				return;

			bool singlesMatch = false;
			if(comparer.equals(singlesTable[tableIndex], obj) == true)
				singlesMatch = true;

			// O(n) case, single is match
			if(singlesMatch == true)
			{
				singlesUsedTable[tableIndex] = false;
				numObjects--;

				if(collisionsTable[tableIndex] == null)
					return;
				if(collisionsTable[tableIndex].size() == 0)
					return;

				// shift collision table entry down
				singlesUsedTable[tableIndex] = true;
				singlesTable[tableIndex] = collisionsTable[tableIndex].removeLast();
				return;
			}

			// Not O(n), search through collision array because single isn't the match, but we have collisions
			ArrayList<A> list = collisionsTable[tableIndex];
			if(list == null)
				return; // no collision table means no possible matches

			// We return object from table that compares the same as the passed-in obj, but might have extra info.
			for(u64 s=0; s<list.numUsed; s++)
			{
				if(comparer.equals(obj, list[s]) == true)
				{
					list.remove(s);
					numObjects--;
					return;
				}
			}
		}
	}

	// Returns 0 - 1 indicating how full the table is. Can be > 1.0 if many collisions.
	f32 getLoadFactor()
	{
		if(singlesTable.numUsed == 0)
			return 0.0f;

		f32 full = singlesTable.numUsed;

		return numObjects / full;
	}

	// Resize the table to add/remove spaces - a costly operation!
	void setCapacity(u64 newSize)
	{
		IIterator<A> iter = getIterator(); // have to get this before changing table

		ArrayList<A>            oldSinglesTable     = singlesTable;
		ArrayList<bool>         oldSinglesUsedTable = singlesUsedTable;
		ArrayList<ArrayList<A>> oldCollisionsTable  = collisionsTable;

		singlesTable         = ArrayList<A>(newSize);
		singlesTable.numUsed = singlesTable.data.length();

		singlesUsedTable         = ArrayList<bool>(newSize);
		singlesUsedTable.numUsed = singlesTable.data.length();

		collisionsTable         = ArrayList<ArrayList<A>>(newSize);
		collisionsTable.numUsed = singlesTable.data.length();

		numObjects = 0;

		// Add items to new table
		while(iter.hasNext() == true)
		{
			A obj = iter.next();
			add(obj);
		}

		// drop old tables
		if(oldCollisionsTable != null)
		{
			for(u64 t=0; t<oldCollisionsTable.numUsed; t++)
			{
				ArrayList<A> list = oldCollisionsTable[t];
			}
		}
	}

	// Remove all objects / values mappings.
	void clear()
	{
		if(singlesUsedTable != null)
		{
			for(u64 u=0; u<singlesUsedTable.size(); u++)
			{
				singlesUsedTable[u] = false;
			}
		}

		if(collisionsTable != null)
		{
			for(u64 t=0; t<collisionsTable.size(); t++)
			{
				ArrayList<A> list = collisionsTable[t];
				if(list != null)
					list.clear();
			}
		}
		
		numObjects = 0;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// HashSet
////////////////////////////////////////////////////////////////////////////////////////////////////

// Provides O(n) insertion, removal, contains and retrieval for non-colliding hashes. Set-element
// hash/equality determined by comparer.
class HashSet<A> implements ISet<A>, ICollection<A>
{
	HashTable<A> table; // ISet/ICollection primarily implemented via auto-composition.

	// Default constructor.
	void constructor()
	{
		table = HashTable<A>(128);
	}

	// Default constructor.
	void constructor(u64 initCapacity)
	{
		table = HashTable<A>(initCapacity);
	}

	// Comparer used for hashing/equality checks.
	void constructor(IComparer<A> comparer, u64 initCapacity)
	{
		table = HashTable<A>(comparer, initCapacity);
	}

	// Set how elements are tested for equality. Pass-in null for == operator default check.
	void setComparer(IComparer<A> comparerTest)
	{
		table.setComparer(comparerTest);
	}

	// Clone does not guarantee order maintained.
	ICollection<A> clone()
	{
		HashSet<A> newSet = HashSet<A>(table.comparer.clone(), table.singlesTable.size());

		if(table.comparer != null)
			newSet.setComparer(table.comparer.clone());

		IIterator<A> iter = table.getIterator();
		while(iter.hasNext() == true)
		{
			A val = iter.next();
			newSet.add(val);
		}

		return newSet;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// HashMap
////////////////////////////////////////////////////////////////////////////////////////////////////

// Uses equals()/getHash() by default for equality, can be customized with IComparer. Provides
// O(n) insertion, removal and retrieval for non-colliding cases.
class HashMap<Key, Val> implements IMap<Key, Val>, ICollection<Key>
{
	// Five-table setup ensures we make far fewer dynamic memory allocations (only for collisions)
	ArrayList<Key>            singleKeysTable;     // if there is one/none entry for the hash value
	ArrayList<Val>            singleValsTable;     // if there is one/none entry for the hash value
	ArrayList<bool>           singlesUsedTable;    // true if singlesTable has valid entry
	ArrayList<ArrayList<Key>> collisionKeysTable;  // always same size as table
	ArrayList<ArrayList<Val>> collisionValsTable;  // always same size as table

	IComparer<Key> comparer = null;
	u64 numObjects = 0;

	// HashMap uses equals()/getHash() for comparison.
	void constructor()
	{
		create(128);
	}

	// HashMap uses equals()/getHash() for comparison.
	void constructor(u64 initSize)
	{
		create(initSize);
	}

	// HashMap owns comparer.
	void constructor(IComparer<Key> comparer, u64 initSize)
	{
		this.comparer = comparer;
		create(initSize);
	}

	// Create sized.
	void create(u64 initSize)
	{
		if(initSize == 0)
			initSize = 1;

		singleKeysTable         = ArrayList<Key>(initSize);
		singleKeysTable.numUsed = singleKeysTable.data.length();

		singleValsTable         = ArrayList<Val>(initSize);
		singleValsTable.numUsed = singleKeysTable.data.length();

		singlesUsedTable         = ArrayList<bool>(initSize);
		singlesUsedTable.numUsed = singleKeysTable.data.length();

		collisionKeysTable         = ArrayList<ArrayList<Key>>(initSize);
		collisionKeysTable.numUsed = singleKeysTable.data.length();

		collisionValsTable         = ArrayList<ArrayList<Val>>(initSize);
		collisionValsTable.numUsed = singleKeysTable.data.length();

		numObjects = 0;
	}

	// Clone
	ICollection<Key> clone()
	{
		HashMap<Key, Val> newMap = null;
		if(comparer == null)
			newMap = HashMap<Key, Val>(singleKeysTable.size());
		else
			newMap = HashMap<Key, Val>(comparer.clone(), singleKeysTable.size());

		// copy over items
		IIterator<Key> iter = getIterator();
		while(iter.hasNext() == true)
		{
			Key key = iter.next();
			newMap.add(key, this.get(key));
		}

		return newMap;
	}

	// Set how elements are tested for equality. Pass-in null for == operator default use of equals()/getHash().
	void setComparer(IComparer<Key> comparerTest)
	{
		comparer = comparerTest;
	}

	// Returns number of objects stored in this hash table
	u64 size()
	{
		return numObjects;
	}

	// Iterator
	IIterator<Key> getIterator()
	{
		return HashTableIterator<Key>(singleKeysTable, singlesUsedTable, collisionKeysTable);
	}

	// Returns the found object or null/zero if not found.
	Val get(Key key)
	{
		if(singleKeysTable.numUsed == 0)
			return null;

		if(comparer == null)
		{
			u64 tableIndex = key.getHash() % singleKeysTable.numUsed;

			// O(n) case, single used, no collisions
			if(singlesUsedTable[tableIndex] == false)
				return null;

			if(singleKeysTable[tableIndex].equals(key))
				return singleValsTable[tableIndex];

			// Not O(n), search through collision array because single isn't the match
			ArrayList<Key> keysList = collisionKeysTable[tableIndex];
			ArrayList<Val> valsList = collisionValsTable[tableIndex];
			if(keysList == null)
				return null;

			// Really just a contains check since we return the exact object
			for(u64 s=0; s<keysList.numUsed; s++)
			{
				if(key.equals(keysList[s]))
				{
					return valsList[s];
				}
			}
		}
		else
		{
			u64 tableIndex = comparer.hash(key) % singleKeysTable.numUsed;

			// O(n) case, single used, no collisions
			if(singlesUsedTable[tableIndex] == false)
				return null;

			if(comparer.equals(singleKeysTable[tableIndex], key) == true)
				return singleValsTable[tableIndex];
			
			// Not O(n), search through collision array because single isn't the match
			ArrayList<Key> keysList = collisionKeysTable[tableIndex];
			ArrayList<Val> valsList = collisionValsTable[tableIndex];
			if(keysList == null)
				return null;

			// We return object from table that compares the same as the passed-in key, but might have extra info.
			for(u64 s=0; s<keysList.numUsed; s++)
			{
				if(comparer.equals(key, keysList[s]) == true)
				{
					return valsList[s];
				}
			}
		}

		return null;
	}

	// Returns true if key is already in table.
	bool contains(Key key)
	{
		if(singleKeysTable.numUsed == 0)
			return null;

		if(comparer == null)
		{
			u64 tableIndex = key.getHash() % singleKeysTable.numUsed;

			// O(n) case, single used, no collisions
			if(singlesUsedTable[tableIndex] == false)
				return false;

			if(singleKeysTable[tableIndex].equals(key))
				return true;

			// Not O(n), search through collision array because single isn't the match
			ArrayList<Key> keysList = collisionKeysTable[tableIndex];
			if(keysList == null)
				return false;

			// Really just a contains check since we return the exact object
			for(u64 s=0; s<keysList.numUsed; s++)
			{
				if(key.equals(keysList[s]))
					return true;
			}
		}
		else
		{
			u64 tableIndex = comparer.hash(key) % singleKeysTable.numUsed;

			// O(n) case, single used, no collisions
			if(singlesUsedTable[tableIndex] == false)
				return false;

			if(comparer.equals(singleKeysTable[tableIndex], key) == true)
				return true;
			
			// Not O(n), search through collision array because single isn't the match
			ArrayList<Key> keysList = collisionKeysTable[tableIndex];
			if(keysList == null)
				return false;

			// We return object from table that compares the same as the passed-in key, but might have extra info.
			for(u64 s=0; s<keysList.numUsed; s++)
			{
				if(comparer.equals(key, keysList[s]) == true)
					return true;
			}
		}

		return false;
	}

	// Add/Replace a mapping.
	void add(Key key, Val val)
	{
		if(singleKeysTable.size() == 0)
			setCapacity(10);

		if(singleKeysTable.numUsed == 0)
			return;

		if(comparer == null)
		{
			u64 tableIndex = key.getHash() % singleKeysTable.numUsed;

			// O(n) case, single used, no collisions
			if(singlesUsedTable[tableIndex] == false)
			{
				singleKeysTable[tableIndex]  = key; // add
				singleValsTable[tableIndex]  = val;
				singlesUsedTable[tableIndex] = true;
				numObjects++;
				return;
			}

			if(singleKeysTable[tableIndex].equals(key))
			{
				singleKeysTable[tableIndex] = key; // replace
				singleValsTable[tableIndex] = val;
				return;
			}

			// First collision?
			if(collisionKeysTable[tableIndex] == null)
			{
				collisionKeysTable[tableIndex] = ArrayList<Key>(2); // if we have one collision, we probably will have more than one
				collisionKeysTable[tableIndex].add(key);
				collisionValsTable[tableIndex] = ArrayList<Val>(2);
				collisionValsTable[tableIndex].add(val);
				numObjects++;
				return;
			}

			// Not O(n), search through collision array because single isn't the match
			ArrayList<Key> keysList = collisionKeysTable[tableIndex];
			ArrayList<Val> valsList = collisionValsTable[tableIndex];

			// Really just a contains check since we return the exact object
			for(u64 s=0; s<keysList.numUsed; s++)
			{
				if(key.equals(keysList[s]))
				{
					keysList[s] = key; // replace
					valsList[s] = val;
					return;
				}
			}

			// new mapping collision
			keysList.add(key);
			valsList.add(val);
			numObjects++;
		}
		else
		{
			u64 tableIndex = comparer.hash(key) % singleKeysTable.numUsed;

			// O(n) case, single used, no collisions
			if(singlesUsedTable[tableIndex] == false)
			{
				singleKeysTable[tableIndex]  = key; // add
				singleValsTable[tableIndex]  = val;
				singlesUsedTable[tableIndex] = true;
				numObjects++;
				return;
			}
			
			if(comparer.equals(singleKeysTable[tableIndex], key) == true)
			{
				singleKeysTable[tableIndex] = key; // replace
				singleValsTable[tableIndex] = val;
				return;
			}
			
			// First collision?
			if(collisionKeysTable[tableIndex] == null)
			{
				collisionKeysTable[tableIndex] = ArrayList<Key>(2); // if we have one collision, we probably will have more than one
				collisionKeysTable[tableIndex].add(key);
				collisionValsTable[tableIndex] = ArrayList<Val>(2);
				collisionValsTable[tableIndex].add(val);
				numObjects++;
				return;
			}

			// Not O(n), search through collision array because single isn't the match
			ArrayList<Key> keysList = collisionKeysTable[tableIndex];
			ArrayList<Val> valsList = collisionValsTable[tableIndex];

			// We return object from table that compares the same as the passed-in obj, but might have extra info.
			for(u64 s=0; s<keysList.numUsed; s++)
			{
				if(comparer.equals(key, keysList[s]) == true)
				{
					keysList[s] = key; // replace
					valsList[s] = val;
					return;
				}
			}

			// new mapping collision
			keysList.add(key);
			valsList.add(val);
			numObjects++;
		}		
	}

	// Add all key/value pairs of passed-in map to this map.
	void addAll(IMap<Key, Val> map)
	{
		IIterator<Key> iter = map.getIterator();
		while(iter.hasNext())
		{
			Key key = iter.next();
			Val val = map.get(key);
			add(key, val);
		}
	}

	// Returns true if object was found and removed, false otherwise
	void remove(Key key)
	{
		if(singleKeysTable.numUsed == 0)
			return;

		if(comparer == null)
		{
			u64 tableIndex = key.getHash() % singleKeysTable.numUsed;

			// O(n) case, nothing stored
			if(singlesUsedTable[tableIndex] == false)
				return;

			bool singlesMatch = false;
			if(singleKeysTable[tableIndex].equals(key))
				singlesMatch = true;

			// O(n) case, single is match
			if(singlesMatch == true)
			{
				singlesUsedTable[tableIndex] = false;
				numObjects--;

				if(collisionKeysTable[tableIndex] == null)
					return;
				if(collisionKeysTable[tableIndex].size() == 0)
					return;

				// shift collision table entry down
				singlesUsedTable[tableIndex] = true;
				singleKeysTable[tableIndex] = collisionKeysTable[tableIndex].removeLast();
				singleValsTable[tableIndex] = collisionValsTable[tableIndex].removeLast();
				return;
			}

			// Not O(n), search through collision array because single isn't the match, but we have collisions
			ArrayList<Key> keysList = collisionKeysTable[tableIndex];
			ArrayList<Val> valsList = collisionValsTable[tableIndex];
			if(keysList == null)
				return; // no collision table means no possible matches

			// Really just a contains check since we return the exact object
			for(u64 s=0; s<keysList.numUsed; s++)
			{
				if(key.equals(keysList[s]))
				{
					keysList.remove(s);
					valsList.remove(s);
					numObjects--;
					return;
				}
			}
		}
		else
		{
			u64 tableIndex = comparer.hash(key) % singleKeysTable.numUsed;

			// O(n) case, nothing stored
			if(singlesUsedTable[tableIndex] == false)
				return;

			bool singlesMatch = false;
			if(comparer.equals(singleKeysTable[tableIndex], key) == true)
				singlesMatch = true;

			// O(n) case, single is match
			if(singlesMatch == true)
			{
				singlesUsedTable[tableIndex] = false;
				numObjects--;

				if(collisionKeysTable[tableIndex] == null)
					return;
				if(collisionKeysTable[tableIndex].size() == 0)
					return;

				// shift collision table entry down
				singlesUsedTable[tableIndex] = true;
				singleKeysTable[tableIndex] = collisionKeysTable[tableIndex].removeLast();
				singleValsTable[tableIndex] = collisionValsTable[tableIndex].removeLast();
				return;
			}

			// Not O(n), search through collision array because single isn't the match, but we have collisions
			ArrayList<Key> keysList = collisionKeysTable[tableIndex];
			ArrayList<Val> valsList = collisionValsTable[tableIndex];
			if(keysList == null)
				return; // no collision table means no possible matches

			// We return object from table that compares the same as the passed-in key, but might have extra info.
			for(u64 s=0; s<keysList.numUsed; s++)
			{
				if(comparer.equals(key, keysList[s]) == true)
				{
					keysList.remove(s);
					valsList.remove(s);
					numObjects--;
					return;
				}
			}
		}
	}

	// Returns 0 - 1 indicating how full the table is. Can be > 1.0 if many collisions.
	f32 getLoadFactor()
	{
		if(singleKeysTable.numUsed == 0)
			return 0.0f;

		f32 full = singleKeysTable.numUsed;

		return numObjects / full;
	}

	// Resize the table to add/remove spaces - a costly operation!
	void setCapacity(u64 newSize)
	{
		IIterator<Key> iter = getIterator(); // have to get this before changing table

		HashMap<Key, Val> newMap = null;
		if(comparer == null)
			newMap = HashMap<Key, Val>(newSize);
		else
			newMap = HashMap<Key, Val>(comparer.clone(), newSize);

		// Add items to new map
		while(iter.hasNext() == true)
		{
			Key key = iter.next();
			Val val = get(key);
			newMap.add(key, val);
		}

		// steal new maps data
		this.singleKeysTable   = newMap.singleKeysTable;
		newMap.singleKeysTable = null;

		this.singleValsTable   = newMap.singleValsTable;
		newMap.singleValsTable = null;

		this.singlesUsedTable   = newMap.singlesUsedTable;
		newMap.singlesUsedTable = null;

		this.collisionKeysTable   = newMap.collisionKeysTable;
		newMap.collisionKeysTable = null;

		this.collisionValsTable   = newMap.collisionValsTable;
		newMap.collisionValsTable = null;

		if(newMap.comparer != null)
		{
			this.comparer   = newMap.comparer;
			newMap.comparer = null;
		}
		else
			this.comparer = null;

		this.numObjects = newMap.numObjects;
	}

	// Remove all objects / values mappings.
	void clear()
	{
		if(singlesUsedTable != null)
		{
			for(u64 u=0; u<singlesUsedTable.size(); u++)
			{
				singlesUsedTable[u] = false;
			}
		}

		if(collisionKeysTable != null)
		{
			for(u64 t=0; t<collisionKeysTable.size(); t++)
			{
				ArrayList<Key> keysList = collisionKeysTable[t];
				if(keysList != null)
					keysList.clear();
			}
		}
		
		if(collisionValsTable != null)
		{
			for(u64 v=0; v<collisionValsTable.size(); v++)
			{
				ArrayList<Val> valsList = collisionValsTable[v];
				if(valsList != null)
					valsList.clear();
			}
		}

		numObjects = 0;
	}
}