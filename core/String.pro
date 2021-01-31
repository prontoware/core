////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// String<A>
////////////////////////////////////////////////////////////////////////////////////////////////////

// Basic mutable UT8/UTF16/UCS2/UTF32 string type for Pronto standard package. Supports very large
// strings up to 2^63 in length in theory. String<A> template type is flexible enough to hold any
// scalar integer/floating-point primitive.
//
// Note that while UTF8/UTF16 string can be represented and reasoned with here, methods like
// length() don't consider special multi-byte combined characters etc.
//
// We are extending the built-in String<A> class. This just means that the String<A> class
// basics are built-in to the language, but the complex functions are all in source form here.
class String<A>
{
	// Builtin class variables
	//u64 numChars = 0; // always <= chars.length()
	//A[] chars    = null;

	// Builtin - Default empty string.
	//void constructor() {}

	// Builtin - Create from array of UTF8 characters. 
	//void constructor(u8[] s0) { this.numChars = 0; this.chars = A[](s0.length()); append(s0); }

	// Copy-constructor from ASCII/UTF8 string.
	void constructor(u8[] copyFrom)
	{
		this.numChars = 0;
		this.append(copyFrom);
	}

	// Copy-constructor from UCS2/UTF16 string.
	void constructor(u16[] copyFrom)
	{
		this.numChars = 0;
		this.append(copyFrom);
	}

	// Copy-constructor from UTF32 string.
	void constructor(u32[] copyFrom)
	{
		this.numChars = 0;
		this.append(copyFrom);
	}

	// Copy-constructor from an imaginary 64-bit per charactor format string.
	void constructor(u64[] copyFrom)
	{
		this.numChars = 0;
		this.append(copyFrom);
	}

	// Copy-constructor from ASCII/UTF8 string.
	void constructor(String<u8> copyFrom)
	{
		this.numChars = 0;
		this.append(copyFrom);
	}

	// Copy-constructor from UCS2/UTF16 string.
	void constructor(String<u16> copyFrom)
	{
		this.numChars = 0;
		this.append(copyFrom);
	}

	// Copy-constructor from UTF32 string.
	void constructor(String<u32> copyFrom)
	{
		this.numChars = 0;
		this.append(copyFrom);
	}

	// Copy-constructor from an imaginary 64-bit per charactor format string.
	void constructor(String<u64> copyFrom)
	{
		this.numChars = 0;
		this.append(copyFrom);
	}

	// (Built-in) Default empty string, but sized, ready to hold characters.
	// void constructor(u64 size)

	// Create from a subset of an array of UTF8 characters.
	void constructor(A[] str, u64 strLen)
	{
		this.append(str, strLen);
	}

	// Clone passed-in string.
	void constructor(String<A> s)
	{
		this.numChars = s.numChars;
		this.chars    = A[](s.numChars);
		for(u64 i=0; i<s.numChars; i++)
			this.chars[i] = s.chars[i];
	}

	// Clone passed-in strings, appending them.
	void constructor(String<A> s0, String<A> s1)
	{
		this.numChars = 0;
		this.chars    = A[](s0.numChars + s1.numChars);
		
		append(s0, s1);
	}

	// Clone passed-in strings, appending them.
	void constructor(String<A> s0, String<A> s1, String<A> s2)
	{
		this.numChars = 0;
		this.chars    = A[](s0.numChars + s1.numChars + s2.numChars);
		
		append(s0, s1, s2);
	}

	// Clone passed-in strings, appending them.
	void constructor(String<A> s0, String<A> s1, String<A> s2, String<A> s3)
	{
		this.numChars = 0;
		this.chars    = A[](s0.numChars + s1.numChars + s2.numChars + s3.numChars);
		
		append(s0, s1, s2, s3);
	}

	// Clone passed-in strings, appending them.
	void constructor(String<A> s0, String<A> s1, String<A> s2, String<A> s3, String<A> s4)
	{
		this.numChars = 0;
		this.chars    = A[](s0.numChars + s1.numChars + s2.numChars + s3.numChars + s4.numChars);
		
		append(s0, s1, s2, s3, s4);
	}

	// Get a character by array-indexing.
	//A get(u64 index) { return chars[index]; }

	// Number of characters in this string.
	//u64 length() { return numChars; }

	// Append number via + operator.
	String<A> add(u8 number)
	{
		String<A> newStr(this);
		newStr.append(String<A>:formatNumber(number));
		return newStr;
	}

	// Append number via + operator.
	String<A> add(i8 number)
	{
		String<A> newStr(this);
		newStr.append(String<A>:formatNumber(number));
		return newStr;
	}

	// Append number via + operator.
	String<A> add(u16 number)
	{
		String<A> newStr(this);
		newStr.append(String<A>:formatNumber(number));
		return newStr;
	}

	// Append number via + operator.
	String<A> add(i16 number)
	{
		String<A> newStr(this);
		newStr.append(String<A>:formatNumber(number));
		return newStr;
	}

	// Append number via + operator.
	String<A> add(u32 number)
	{
		String<A> newStr(this);
		newStr.append(String<A>:formatNumber(number));
		return newStr;
	}

	// Append number via + operator.
	String<A> add(i32 number)
	{
		String<A> newStr(this);
		newStr.append(String<A>:formatNumber(number));
		return newStr;
	}

	// Append number via + operator.
	String<A> add(u64 number)
	{
		String<A> newStr(this);
		newStr.append(String<A>:formatNumber(number));
		return newStr;
	}

	// Append number via + operator.
	String<A> add(i64 number)
	{
		String<A> newStr(this);
		newStr.append(String<A>:formatNumber(number));
		return newStr;
	}

	// Append number via + operator.
	String<A> add(f32 number)
	{
		String<A> newStr(this);
		newStr.append(String<A>:formatNumber(number));
		return newStr;
	}

	// Append number via + operator.
	String<A> add(f64 number)
	{
		String<A> newStr(this);
		newStr.append(String<A>:formatNumber(number));
		return newStr;
	}

	// Copy from another string.
	void copy(String<u8> s)
	{
		if(s == null || s.chars == null || s.numChars == 0)
		{
			this.numChars = 0;
			return;
		}
		
		if(this.chars == null)
		{
			this.chars = A[](s.numChars);
		}
		else if(this.numChars < s.numChars)
		{
			this.chars = A[](s.numChars);
		}
		
		for(u64 i=0; i<s.numChars; i++)
			this.chars[i] = s.chars[i];
			
		this.numChars = s.numChars;
	}

	// Copy from another string.
	void copy(String<u16> s)
	{
		if(s == null || s.chars == null || s.numChars == 0)
		{
			this.numChars = 0;
			return;
		}
		
		if(this.chars == null)
		{
			this.chars = A[](s.numChars);
		}
		else if(this.numChars < s.numChars)
		{
			this.chars = A[](s.numChars);
		}
		
		for(u64 i=0; i<s.numChars; i++)
			this.chars[i] = s.chars[i];
			
		this.numChars = s.numChars;
	}

	// Copy from another string.
	void copy(String<u32> s)
	{
		if(s == null || s.chars == null || s.numChars == 0)
		{
			this.numChars = 0;
			return;
		}
		
		if(this.chars == null)
		{
			this.chars = A[](s.numChars);
		}
		else if(this.numChars < s.numChars)
		{
			this.chars = A[](s.numChars);
		}
		
		for(u64 i=0; i<s.numChars; i++)
			this.chars[i] = s.chars[i];
			
		this.numChars = s.numChars;
	}

	// Copy from another string.
	void copy(String<u64> s)
	{
		if(s == null || s.chars == null || s.numChars == 0)
		{
			this.numChars = 0;
			return;
		}
		
		if(this.chars == null)
		{
			this.chars = A[](s.numChars);
		}
		else if(this.numChars < s.numChars)
		{
			this.chars = A[](s.numChars);
		}
		
		for(u64 i=0; i<s.numChars; i++)
			this.chars[i] = s.chars[i];
			
		this.numChars = s.numChars;
	}
	
	// Copy from another string.
	void copy(String<A> s)
	{
		if(s == null || s.chars == null || s.numChars == 0)
		{
			this.numChars = 0;
			return;
		}
		
		if(this.chars == null)
		{
			this.chars = A[](s.numChars);
		}
		else if(this.numChars < s.numChars)
		{
			this.chars = A[](s.numChars);
		}
		
		for(u64 i=0; i<s.numChars; i++)
			this.chars[i] = s.chars[i];
			
		this.numChars = s.numChars;
	}

	// Copy from raw array of characters.
	void copy(A[] fromChars)
	{
		if(fromChars == null || fromChars.length() == 0)
		{
			this.numChars = 0;
		}
		else
		{
			this.chars = null;
				
			// make copy
			this.chars    = A[](fromChars.length());
			this.numChars = fromChars.length();
	
			for(u64 i=0; i<fromChars.length(); i++)
				this.chars[i] = fromChars[i];
		}
	}

	// Copy from raw array of characters.
	void copy(A[] fromChars, u64 numFromChars)
	{
		if(fromChars == null || numFromChars == 0)
		{
			this.numChars = 0;
		}
		else
		{
			this.chars = null;
				
			// make copy
			this.chars    = A[](numFromChars);
			this.numChars = numFromChars;
	
			for(u64 i=0; i<numFromChars; i++)
				this.chars[i] = fromChars[i];
		}
	}

	// Create copy of this string.
	String<A> clone()
	{
		String<A> s = String<A>();
		s.copy(this);
		return s;
	}

	// Replace default method implementation. Return hash code.
	u64 getHash()
	{
		u64 len = this.length();
		if(len > 8)
			len = 8;

		u64 hash = 0;
		for(u64 c=0; c<len; c++)
		{
			hash = hash | this.chars[c];
			hash = hash << 8;
		}

		return hash;
	}

	// Replace default method implementation. Exact match, case-sensitive.
	bool equals(IObj b)
	{
		String<A> strB = b;
		if(strB == null)
			return false;

		if(this.compare(strB) == true)
			return true;

		return false;
	}

	// Replace default method implementation. Is this less than passed-in.
	bool lessThan(IObj b)
	{
		String<A> strB = b;
		if(strB == null)
			return false;
		
		if(this.order(strB) < 0)
			return true;

		return false;
	}

	// Replace default method implementation. Is this less than passed-in.
	bool moreThan(IObj b)
	{
		String<A> strB = b;
		if(strB == null)
			return false;
		
		if(this.order(strB) > 0)
			return true;

		return false;
	}

	// Replace default method implementation. Return clone of this string.
	String<A> toString()
	{
		return String<A>(this);
	}

	// To exact size array (clone of data).
	A[] toArray()
	{
		A[] arr(numChars);

		for(u64 c=0; c<numChars; c++)
			arr[c] = chars[c];

		return arr;
	}

	// Set to empty string.
	void clear()
	{
		this.numChars = 0;
	}

	// Reverse string.
	void reverse()
	{
		if(numChars <= 1)
			return;

		u64 endIndex = numChars-1;
		u64 midIndex = Math:ceil(numChars/2.0) - 1; // -1 because zero-based indexing
		for(u64 c=0; c<=midIndex; c++)
		{
			A temp = chars[c];
			chars[c] = chars[endIndex];
			chars[endIndex] = temp;
			endIndex--;	
		}
	}

	// Append a char onto this string.
	void appendChar(A ch)
	{
		checkToResize(1);
			
		this.chars[numChars] = ch;
		numChars++;
	}

	// Append a char onto this string.
	void append(A ch) { appendChar(ch); }

	// Append two chars onto this string.
	void append(A c0, A c1) { appendChar(c0); appendChar(c1); }

	// Append three chars onto this string.
	void append(A c0, A c1, A c2) { appendChar(c0); appendChar(c1); appendChar(c2); }

	// Append four chars onto this string.
	void append(A c0, A c1, A c2, A c3) { appendChar(c0); appendChar(c1); appendChar(c2); appendChar(c3); }

	// Append five chars onto this string.
	void append(A c0, A c1, A c2, A c3, A c4) { appendChar(c0); appendChar(c1); appendChar(c2); appendChar(c3); appendChar(c4); }

	// Append six chars onto this string.
	void append(A c0, A c1, A c2, A c3, A c4, A c5) { appendChar(c0); appendChar(c1); appendChar(c2); appendChar(c3); appendChar(c4); appendChar(c5); }

	// Append a string onto this string.
	void append(String<A> s)
	{
		if(s == null)
			return;

		u64 maxNumChars = this.numChars + s.numChars;
		checkToResize(s.numChars);
			
		for(u64 i=this.numChars; i<maxNumChars; i++)
			this.chars[i] = s.chars[i - this.numChars];

		numChars += s.numChars;
	}

	// Append a ASCII/UTF8 string.
	void append(u8[] s)
	{
		if(s == null)
			return;

		u64 maxNumChars = this.numChars + s.length();
		checkToResize(s.length());
			
		for(u64 i=this.numChars; i<maxNumChars; i++)
			this.chars[i] = s[i - this.numChars];

		numChars += s.length();
	}

	// Append a UCS2/UTF16 string.
	void append(u16[] s)
	{
		if(s == null)
			return;

		u64 maxNumChars = this.numChars + s.length();
		checkToResize(s.length());
			
		for(u64 i=this.numChars; i<maxNumChars; i++)
			this.chars[i] = s[i - this.numChars];

		numChars += s.length();
	}

	// Append a UTF32 string.
	void append(u32[] s)
	{
		if(s == null)
			return;

		u64 maxNumChars = this.numChars + s.length();
		checkToResize(s.length());
			
		for(u64 i=this.numChars; i<maxNumChars; i++)
			this.chars[i] = s[i - this.numChars];

		numChars += s.length();
	}

	// Append an imaginary 64-bit per character format string.
	void append(u64[] s)
	{
		if(s == null)
			return;

		u64 maxNumChars = this.numChars + s.length();
		checkToResize(s.length());
			
		for(u64 i=this.numChars; i<maxNumChars; i++)
			this.chars[i] = s[i - this.numChars];

		numChars += s.length();
	}

	// Append a ASCII/UTF8 string.
	void append(String<u8> s)
	{
		if(s == null)
			return;

		u64 maxNumChars = this.numChars + s.length();
		checkToResize(s.numChars);
			
		for(u64 i=this.numChars; i<maxNumChars; i++)
			this.chars[i] = s.chars[i - this.numChars];

		numChars += s.numChars;
	}

	// Append a UCS2/UTF16 string.
	void append(String<u16> s)
	{
		if(s == null)
			return;

		u64 maxNumChars = this.numChars + s.length();
		checkToResize(s.numChars);
			
		for(u64 i=this.numChars; i<maxNumChars; i++)
			this.chars[i] = s.chars[i - this.numChars];

		numChars += s.numChars;
	}

	// Append a UTF32 string.
	void append(String<u32> s)
	{
		if(s == null)
			return;

		u64 maxNumChars = this.numChars + s.length();
		checkToResize(s.numChars);
			
		for(u64 i=this.numChars; i<maxNumChars; i++)
			this.chars[i] = s.chars[i - this.numChars];

		numChars += s.numChars;
	}

	// Append an imaginary 64-bit per charactor format string.
	void append(String<u64> s)
	{
		if(s == null)
			return;

		u64 maxNumChars = this.numChars + s.length();
		checkToResize(s.numChars);
			
		for(u64 i=this.numChars; i<maxNumChars; i++)
			this.chars[i] = s.chars[i - this.numChars];

		numChars += s.numChars;
	}

	// Append two strings onto this string.
	void append(String<A> s0, String<A> s1)
	{
		append(s0);
		append(s1);
	}

	// Append three strings onto this string.
	void append(String<A> s0, String<A> s1, String<A> s2)
	{
		append(s0);
		append(s1);
		append(s2);
	}

	// Append four strings onto this string.
	void append(String<A> s0, String<A> s1, String<A> s2, String<A> s3)
	{
		append(s0);
		append(s1);
		append(s2);
		append(s3);
	}

	// Append five strings onto this string.
	void append(String<A> s0, String<A> s1, String<A> s2, String<A> s3, String<A> s4)
	{
		append(s0);
		append(s1);
		append(s2);
		append(s3);
		append(s4);
	}

	// Append six strings onto this string.
	void append(String<A> s0, String<A> s1, String<A> s2, String<A> s3, String<A> s4, String<A> s5)
	{
		append(s0);
		append(s1);
		append(s2);
		append(s3);
		append(s4);
		append(s5);
	}

	// Append an array of A-type characters onto this string.
	void append(A[] str)
	{
		if(str == null)
			return;

		u64 maxNumChars = this.numChars + str.length();
		checkToResize(str.length());
			
		for(u64 i=this.numChars; i<maxNumChars; i++)
			this.chars[i] = str[i - this.numChars];

		numChars += str.length();
	}

	// Append two arrays of UTF8 characters onto this string.
	void append(A[] s0, A[] s1)
	{
		append(s0);
		append(s1);
	}

	// Append three arrays of UTF8 characters onto this string.
	void append(A[] s0, A[] s1, A[] s2)
	{
		append(s0);
		append(s1);
		append(s2);
	}

	// Append four arrays of UTF8 characters onto this string.
	void append(A[] s0, A[] s1, A[] s2, A[] s3)
	{
		append(s0);
		append(s1);
		append(s2);
		append(s3);
	}

	// Append five arrays of UTF8 characters onto this string.
	void append(A[] s0, A[] s1, A[] s2, A[] s3, A[] s4)
	{
		append(s0);
		append(s1);
		append(s2);
		append(s3);
		append(s4);
	}

	// Append six arrays of UTF8 characters onto this string.
	void append(A[] s0, A[] s1, A[] s2, A[] s3, A[] s4, A[] s5)
	{
		append(s0);
		append(s1);
		append(s2);
		append(s3);
		append(s4);
		append(s5);
	}

	// Append an array of UTF8 characters onto this string. 
	// @param str UTF8 characters
	// @param strLen defines how many valid characters in str.
	void append(A[] str, u64 strLen)
	{
		checkToResize(strLen);
			
		u64 maxNumChars = this.numChars + strLen;
		for(u64 i=this.numChars; i<maxNumChars; i++)
			this.chars[i] = str[i - this.numChars];

		numChars += strLen;
	}

	// Append a string onto this string with left (before) or right (after) padding. padRight=false means pad to the left.
	void appendPadded(String<A> s, A padChar, u32 padToMinLen, bool padRight)
	{
		if(s.length() >= padToMinLen)
			append(s); // no padding needed
		else
		{
			u32 numPad = padToMinLen - s.length();
			if(padRight == false)
			{
				for(u32 p=0; p<numPad; p++)
					append(padChar);
			}

			append(s);

			if(padRight == true)
			{
				for(u32 p=0; p<numPad; p++)
					append(padChar);
			}
		}
	}
	
	// Get a subset of this string. Indices are inclusive.
	String<A> subString(u64 startIndex, u64 endIndex)
	{
		if(startIndex >= this.numChars || startIndex > endIndex)
			return String<A>();
			
		if(endIndex >= this.numChars)
			endIndex = this.numChars-1;
			
		u64 ssNumChars = (endIndex+1) - startIndex;
		String<A> ss(ssNumChars);
		
		for(u64 i=startIndex; i<=endIndex; i++)
			ss.chars[i - startIndex] = this.chars[i];

		ss.numChars = ssNumChars;
			
		return ss;
	}

	// Enlarge the capacity of this string if needed.
	void checkToResize(u64 numAdditionalChars)
	{
		if(this.chars == null)
			resize(numAdditionalChars);
		else if(this.numChars + numAdditionalChars >= this.chars.length())
			resize((this.numChars + numAdditionalChars) * 1.2);
	}
	
	// Resize this string's available buffer without losing its current contents / length.
	void resize(u64 newSize)
	{
		if(this.chars != null)
		{
			if(newSize == this.chars.length())
				return; // no need to do anything
		}

		if(newSize == 0)
		{
			this.chars = null;
			this.numChars = 0;
			return;
		}

		if(this.numChars > 0)
		{
			A[] newChars = A[](newSize);

			// Copy existing data over
			u64 copyNumChars = this.numChars;
			if(copyNumChars > newSize)
				copyNumChars = newSize;
				
			for(u64 i=0; i<copyNumChars; i++)
				newChars[i] = this.chars[i];
			
			// Use new
			this.chars    = newChars;
			this.numChars = copyNumChars;
		}
		else
		{
			this.chars    = A[](newSize);
			this.numChars = 0;
		}
	}

	// Insert a character into this string.
	void insert(A ch, u64 index)
	{
		if(index >= numChars || numChars == 0)
		{
			appendChar(ch);
			return;
		}

		checkToResize(1);

		// shift chars up by 1
		for(i64 i=numChars-1; i>=index; i--)
		{
			chars[i+1] = chars[i];
		}

		chars[index] = ch;

		numChars++;
	}

	// Insert a string into this string.
	void insert(String<A> s, u64 index)
	{
		if(s == null)
			return;

		if(s.numChars == 0)
			return;

		if(index >= numChars || numChars == 0)
		{
			append(s);
			return;
		}

		checkToResize(s.numChars);

		// shift chars up by s.numChars
		for(i64 i=numChars-1; i>=index; i--)
		{
			chars[i+s.numChars] = chars[i];
		}

		// copy in s.chars
		for(i64 c=index; c<(index+s.numChars); c++)
		{
			chars[c] = s.chars[c-index];
		}

		numChars += s.numChars;
	}

	// Insert a character every N characters. Useful for breaking up text into lines etc.
	void insertRegular(u64 nChars, A ch)
	{
		String<A> originalStr(this);

		this.clear();

		u64 i = 0;
		while(i < originalStr.length())
		{
			String<A> strPiece = originalStr.subString(i, i + (nChars-1));

			this.append(strPiece);
			this.appendChar(ch);

			i += nChars;
		}
	}

	// Insert a string every N characters. Useful for breaking up text into lines etc.
	void insertRegular(u64 nChars, String<A> str)
	{
		String<A> originalStr(this);

		this.clear();

		u64 i = 0;
		while(i < originalStr.length())
		{
			String<A> strPiece = originalStr.subString(i, i + (nChars-1));

			this.append(strPiece);
			this.appendChar(str);

			i += nChars;
		}
	}

	// Replace a portion of this string. Inclusive indexes.
	void replace(String<A> replaceStr, i64 desStart, i64 desEnd)
	{
		if(replaceStr.numChars == 0)
			return;

		if(desStart < 0 || desEnd < 0 || desStart >= numChars || desEnd >= numChars)
			return;

		i64 lenDiff = replaceStr.numChars - (desEnd + 1 - desStart);
		checkToResize(lenDiff);

		// shift extra space into insertion/replace point if necessary
		if(lenDiff < 0)
		{
			// we need to shift chars down (towards zero) and get rid of excess room
			for(i64 c=(desEnd+1)+lenDiff; c<numChars; c++)
			{
				i64 index2 = c + (lenDiff * -1);
				if(index2 < chars.length())
				{
					if(c < 0 && c >= chars.length()) return;
					if(index2 < 0 && index2 >= chars.length()) return;

					chars[c] = chars[index2];
				}
			}
		}
		else if(lenDiff > 0)
		{
			// we need to shift chars up (away from zero) and add some extra room
			for(i64 c=(numChars-1)+lenDiff; c>desEnd; c--)
			{
				i64 index2 = c-lenDiff;
				if(index2 >= 0 && index2 < chars.length())
				{
					if(c < 0 && c >= chars.length()) return;
					if(index2 < 0 && index2 >= chars.length()) return;

					chars[c] = chars[index2];
				}
			}
		}

		numChars += lenDiff;

		// ok, now copy in replacement
		for(i64 c=desStart; c<(desStart+replaceStr.numChars); c++)
		{
			i64 index2 = c - desStart;
			if(c >= 0 && c < chars.length() && index2 >= 0 && index2 < chars.length())
			{
				if(c < 0 && c >= chars.length()) return;
				if(index2 < 0 && index2 >= chars.length()) return;

				chars[c] = replaceStr.chars[index2];
			}
		}
	}

	// Replace all occurences
	void replaceAll(A findChar, A charReplacement)
	{
		replaceAll(0, numChars-1, findChar, charReplacement);
	}

	// Replace all occurences within range (inclusive).
	void replaceAll(u64 startIndex, u64 endIndex, A findChar, A charReplacement)
	{
		if(endIndex < startIndex)
		{
			u64 temp   = startIndex;
			startIndex = endIndex;
			endIndex   = temp;
		}

		for(u64 c=startIndex; c<=endIndex; c++)
		{
			if(c >= this.numChars)
				continue;

			if(chars[c] != findChar)
				continue;

			chars[c] = charReplacement;
		}
	}

	// Replace all occurences
	void replaceAll(String<A> findStr, String<A> strReplacement)
	{
		i64 nextIndex = findNext(findStr, 0);
		while(nextIndex != -1)
		{
			this.replace(strReplacement, nextIndex, nextIndex + findStr.length()-1);
			nextIndex = findNext(findStr, nextIndex + strReplacement.length());
		}
	}

	// Remove portion of this string.
	void remove(u64 startIndex, u64 endIndex)
	{
		if(numChars == 0)
			return;

		if(startIndex >= numChars)
			return;

		if(endIndex < startIndex)
			return;

		if(endIndex > numChars-1)
			endIndex = numChars-1;

		// Special case, removing whole string
		if(startIndex == 0 && endIndex == numChars-1)
		{
			chars     = null;
			numChars  = 0;
			return;
		}

		// Overwrite removed
		for(u64 i=0; i<((numChars - 1) - endIndex); i++)
			chars[startIndex + i] = chars[endIndex + i + 1];

		numChars = numChars - (endIndex + 1 - startIndex);
	}

	// Remove all instance of character.
	void removeAll(A c)
	{
		removeAll(c, 0, numChars-1);
	}

	// Remove all instance of character within range specified.
	void removeAll(A c, u64 startIndex, u64 endIndex)
	{
		if(numChars == 0)
			return;

		// Copy valid characters to new array
		A[] newChars     = A[](numChars);
		u64  newCharsSize = numChars;

		u64 newCharIndex = 0;
		for(u64 i=0; i<numChars; i++)
		{
			if(i < startIndex || i > endIndex)
			{
				newChars[newCharIndex] = chars[i];
				newCharIndex++;
			}
			else
			{
				//might skip this
				if(chars[i] != c)
				{
					newChars[newCharIndex] = chars[i];
					newCharIndex++;
				}
			}
		}

		chars    = newChars;
		numChars = newCharIndex;
	}

	// Remove all instances of this char group chars.
	void removeAll(CharGroup group)
	{
		removeAll(group, 0, numChars-1);
	}

	// Remove all instances of this char group chars.
	void removeAll(CharGroup group, u64 startIndex, u64 endIndex)
	{
		if(numChars == 0)
			return;

		// Copy valid characters to new array
		A[] newChars     = A[](numChars);
		u64  newCharsSize = numChars;

		u64 newCharIndex = 0;
		for(u64 i = 0; i<numChars; i++)
		{
			if(i < startIndex || i > endIndex)
			{
				newChars[newCharIndex] = chars[i];
				newCharIndex++;
			}
			else
			{
				// might skip this
				if(group.contains(chars[i]) == false)
				{
					newChars[newCharIndex] = chars[i];
					newCharIndex++;
				}
			}
		}

		chars    = newChars;
		numChars = newCharIndex;
	}

	void removeAll(String<A> s)
	{
		removeAll(s, 0, numChars-1);
	}

	void removeAll(String<A> s, u64 startIndex, u64 endIndex)
	{
		u64 nextIndex = findNext(s, startIndex, endIndex);
		while(nextIndex != -1)
		{
			remove(nextIndex, nextIndex + (s.numChars - 1));
			endIndex -= s.numChars;
			nextIndex = findNext(s, startIndex, endIndex);
		}
	}

	// Returns true if same (must be same number of characters).
	bool compare(A[] chs)
	{
		bool res = compare(chs, true);
		return res;
	}

	// Returns true if same (must be same number of characters).
	bool compare(A[] chs, bool caseSensitive)
	{
		if(numChars != chs.length())
			return false;

		if(caseSensitive == true)
		{
			for(i64 c=0; c<numChars; c++)
			{
				if(chars[c] != chs[c])
					return false;
			}
		}
		else
		{
			for(i64 c=0; c<numChars; c++)
			{
				if(Chars:toLower(chars[c]) != Chars:toLower(chs[c]))
					return false;
			}
		}

		return true;
	}

	// Compare sub string. Returns true if same.
	bool compare(i64 thisStartIndex, A[] chs, i64 strStartIndex, i64 len, bool caseSensitive)
	{
		if(len <= 0)
			return false;
		
		if((thisStartIndex + len) > numChars)
			return false; // not enough characters in this

		if((strStartIndex + len) > chs.length())
			return false; // not enough characters in this

		if(caseSensitive == true)
		{
			for(i64 c=0; c<len; c++)
			{
				if(chars[thisStartIndex + c] != chs[strStartIndex + c])
					return false;
			}
		}
		else
		{
			for(i64 c=0; c<len; c++)
			{
				if(Chars:toLower(chars[thisStartIndex + c]) != Chars:toLower(chs[strStartIndex + c]))
					return false;
			}
		}

		return true;
	}

	// Returns true if same (must be same number of characters). Built-in method.
	/*
	bool compare(String<A> str)
	{
		return compare(str, true);
	}*/

	// Returns true if same (must be same number of characters).
	bool compare(String<A> str, bool caseSensitive)
	{
		if(numChars != str.numChars)
			return false;

		if(caseSensitive == true)
		{
			for(i64 c=0; c<numChars; c++)
			{
				if(chars[c] != str.chars[c])
					return false;
			}
		}
		else
		{
			for(i64 c=0; c<numChars; c++)
			{
				if(Chars:toLower(chars[c]) != Chars:toLower(str.chars[c]))
					return false;
			}
		}

		return true;
	}

	// Compare sub string. Returns true if same (must be same number of characters).
	bool compare(i64 thisStartIndex, String<A> str, i64 strStartIndex, i64 len, bool caseSensitive)
	{
		if(len <= 0)
			return false;

		if((thisStartIndex+len) > this.numChars)
			return false;

		if((strStartIndex+len) > str.numChars)
			return false;

		if(caseSensitive == true)
		{
			for(i64 c=0; c<len; c++)
			{
				if(chars[thisStartIndex + c] != str.chars[strStartIndex + c])
					return false;
			}
		}
		else
		{
			for(i64 c=0; c<len; c++)
			{
				if(Chars:toLower(chars[thisStartIndex + c]) != Chars:toLower(str.chars[strStartIndex + c]))
					return false;
			}
		}

		return true;
	}

	// Convert a-z to upper case.
	void toUppercase()
	{
		for(i64 i=0; i<numChars; i++)
			chars[i] = Chars:toUpper(chars[i]);
	}

	// Convert A-Z to lower case.
	void toLowercase()
	{
		for(i64 i=0; i<numChars; i++)
			chars[i] = Chars:toLower(chars[i]);
	}

	// Search string for a specific character. Returns -1 if not found.
	i64 findNext(A ch, i64 fromIndex) { return findNext(ch, fromIndex, numChars-1); }

	// Search string for a specific character. Returns -1 if not found.
	i64 findNext(A ch, i64 fromIndex, i64 endIndex)
	{
		if(fromIndex < 0)
			fromIndex = 0;

		if(endIndex >= numChars)
			endIndex = numChars-1;
			
		for(i64 i=fromIndex; i<=endIndex; i++)
		{
			if(chars[i] == ch)
				return i;
		}

		return -1;
	}

	// Search string for a specific character. Returns -1 if not found.
	i64 findNext(CharGroup group, i64 fromIndex) { return findNext(group, fromIndex, numChars-1); }

	// Search string for one of the specified characters. Returns -1 if not found.
	i64 findNext(CharGroup group, i64 fromIndex, i64 endIndex)
	{
		if(fromIndex < 0)
			fromIndex = 0;

		if(endIndex >= numChars)
			endIndex = numChars-1;

		for(i64 i=fromIndex; i<=endIndex; i++)
		{
			if(group.contains(chars[i]) == true)
				return i;
		}

		return -1;
	}

	// Find start index of first match of specified string. Returns -1 if not found.
	i64 findNext(String<A> s, i64 fromIndex) { return findNext(s, fromIndex, numChars-1); }

	// Find start index of first match of specified string. Returns -1 if not found.
	i64 findNext(String<A> s, i64 fromIndex, i64 endIndex) { return findNext(s, fromIndex, endIndex, true); }

	// Find start index of first match of specified string. Returns -1 if not found.
	i64 findNext(String<A> s, i64 fromIndex, i64 endIndex, bool caseSensitive)
	{
		if(fromIndex < 0)
			fromIndex = 0;

		if(endIndex >= numChars)
			endIndex = numChars-1;

		for(i64 i=fromIndex; i<=endIndex-(s.numChars-1); i++)
		{
			if(compare(i, s, 0, s.numChars, caseSensitive) == true)
				return i;
		}

		return -1;
	}

	// Find start index of first match of specified strings. Returns -1 if not found.
	i64 findNext(ArrayList<String<A>> strings, i64 fromIndex, i64 endIndex, bool caseSensitive)
	{
		if(fromIndex < 0)
			fromIndex = 0;

		if(endIndex >= numChars)
			endIndex = numChars-1;

		for(i64 i=fromIndex; i<=endIndex; i++)
		{
			for(u64 s=0; s<strings.size(); s++)
			{
				if((i+strings.get(s).numChars-1) > endIndex)
					continue;

				if(compare(i, strings.get(s), 0, strings.get(s).numChars, caseSensitive) == true)
					return i;
			}
		}

		return -1;
	}

	// Search the string backwards for the specified character. Returns -1 if not found.
	i64 findPrev(A ch, i64 fromIndex) { return findPrev(ch, fromIndex, 0); }

	// Search the string backwards for the specified character. Returns -1 if not found.
	i64 findPrev(A ch, i64 fromIndex, i64 endIndex)
	{
		if(numChars == 0)
			return -1;

		if(fromIndex >= numChars)
			fromIndex = numChars-1;

		if(fromIndex < 0)
			return -1;

		if(endIndex < 0)
			endIndex = 0;

		for(i64 i=fromIndex; i>=endIndex; i--)
		{
			if(chars[i] == ch)
				return i;
		}

		return -1;
	}

	// Search the string backwards for one of the specified characters. Returns -1 if not found.
	i64 findPrev(CharGroup group, i64 fromIndex) { return findPrev(group, fromIndex, 0); }

	// Search the string backwards for of the specified characters. Returns -1 if not found.
	i64 findPrev(CharGroup group, i64 fromIndex, i64 endIndex)
	{
		if(numChars == 0)
			return -1;

		if(fromIndex >= numChars)
			fromIndex = numChars-1;

		if(fromIndex < 0)
			return -1;

		if(endIndex < 0)
			endIndex = 0;

		for(i64 i=fromIndex; i>=endIndex; i--)
		{
			if(group.contains(chars[i]) == true)
				return i;
		}

		return -1;
	}

	// Find start index of first match of specified string. Returns -1 if not found.
	i64 findPrev(String<A> s, i64 fromIndex) { return findPrev(s, fromIndex, 0, true); }

	// Find start index of first match of specified string. Returns -1 if not found.
	i64 findPrev(String<A> s, i64 fromIndex, i64 endIndex) { return findPrev(s, fromIndex, endIndex, true); }

	// Find start index of first match of specified string. Returns -1 if not found.
	i64 findPrev(String<A> s, i64 fromIndex, i64 endIndex, bool caseSensitive)
	{
		if(numChars == 0)
			return -1;

		if(fromIndex >= numChars)
			fromIndex = numChars-1;

		if(fromIndex < 0)
			return -1;

		if(endIndex < 0)
			endIndex = 0;

		for(i64 i=fromIndex-(s.numChars-1); i>=endIndex; i--)
		{
			if(compare(i, s, 0, s.numChars, caseSensitive) == true)
				return i;
		}

		return -1;
	}

	// Find start index of first match of specified strings. Returns -1 if not found.
	i64 findPrev(ArrayList<String<A>> strings, i64 fromIndex, i64 endIndex, bool caseSensitive)
	{
		if(numChars == 0)
			return -1;

		if(fromIndex >= numChars)
			fromIndex = numChars-1;

		if(fromIndex < 0)
			return -1;

		if(endIndex < 0)
			endIndex = 0;
			
		for(i64 i=fromIndex; i>=endIndex; i--)
		{
			for(u64 s=0; s<strings.size(); s++)
			{
				if((i+strings.get(s).numChars-1) > fromIndex)
					continue;

				if(compare(i, strings.get(s), 0, strings.get(s).numChars, caseSensitive) == true)
					return i;
			}
		}

		return -1;
	}

	// Find matching pair end (i.e. '[...]' is a pair). Returns -1 if no match found.
	i64 findPairEnd(A pairStartType, A pairEndType, i64 startPairIndex, i64 maxEndIndex)
	{
		i64 numOpen = 1; // once this reaches zero, we can return that index
		for(i64 c=startPairIndex+1; c<numChars; c++)
		{
			if(c > maxEndIndex)
				return -1;

			if(chars[c] == pairStartType)
				numOpen++;

			if(chars[c] == pairEndType)
				numOpen--;

			if(numOpen == 0)
				return c;
		}

		return -1; // no end to pair
	}

	// Find matching pair end (i.e. '/*' and '*/' are a pair). Returns -1 if no match found.
	i64 findPairEnd(String<A> pairStartType, String<A> pairEndType, i64 startPairIndex)
	{
		i64 numOpen = 1; // once this reaches zero, we can return that index
		for(i64 c=startPairIndex+pairStartType.numChars; c<numChars; c++)
		{
			if(compare(c, pairStartType, 0, pairStartType.numChars, true) == true)
				numOpen++;

			if(compare(c, pairEndType, 0, pairEndType.numChars, true) == true)
				numOpen--;

			if(numOpen == 0)
				return c;
		}

		return -1; // no end to pair
	}

	// Find matching pair start (i.e. '[...]' is a pair). Returns -1 if no match found.
	i64 findPairStart(A pairStartType, A pairEndType, i64 endPairIndex, i64 minStartIndex)
	{
		if(minStartIndex < 0)
			minStartIndex = 0;

		i64 numOpen = 1; // once this reaches zero, we can return that index
		for(i64 c=endPairIndex-1; c>=minStartIndex; c--)
		{
			if(c < 0)
				return -1;

			if(chars[c] == pairEndType)
				numOpen++;

			if(chars[c] == pairStartType)
				numOpen--;

			if(numOpen == 0)
				return c;
		}

		return -1; // no end to pair
	}

	// Find matching pair start (i.e. '/*' and '*/' are a pair). Returns -1 if no match found.
	i64 findPairStart(String<A> pairStartType, String<A> pairEndType, i64 endPairIndex, i64 minStartIndex)
	{
		if(minStartIndex < 0)
			minStartIndex = 0;

		i64 numOpen = 1; // once this reaches zero, we can return that index
		for(i64 c=endPairIndex-pairStartType.numChars; c>=minStartIndex; c--)
		{
			if(compare(c, pairStartType, 0, pairStartType.numChars, true) == true)
				numOpen++;

			if(compare(c, pairEndType, 0, pairEndType.numChars, true) == true)
				numOpen--;

			if(numOpen == 0)
				return c;
		}

		return -1; // no start to pair
	}

	// Count number of times this character appears in this string.
	i64 countOccurrences(A c)
	{
		return countOccurrences(c, 0, numChars-1);
	}

	// Count number of times this character appears in this string within range provided (inclusive).
	i64 countOccurrences(A c, i64 fromIndex, i64 endIndex)
	{
		if(fromIndex >= numChars)
			fromIndex = numChars-1;

		if(fromIndex < 0)
			fromIndex = 0;

		if(endIndex > numChars-1)
			endIndex = numChars-1;

		i64 count = 0;
		for(i64 i=fromIndex; i<=endIndex; i++)
		{
			if(chars[i] == c)
				count++;
		}

		return count;
	}

	// Count number of times this string appears in this string.
	i64 countOccurrences(String<A> s)
	{
		return countOccurrences(s, 0, numChars-1);
	}

	// Count number of times this string appears in this string within range provided (inclusive).
	i64 countOccurrences(String<A> s, i64 fromIndex, i64 endIndex)
	{
		if(fromIndex >= numChars)
			fromIndex = numChars-1;

		if(fromIndex < 0)
			fromIndex = 0;

		if(endIndex >= numChars)
			endIndex = numChars-1;
			
		i64 count = 0;
		for(i64 i=fromIndex; i<=(endIndex - (s.numChars-1)); i++)
		{
			if(compare(i, s, 0, s.numChars, true) == true)
			{
				count++;
				i = i + s.numChars-1;
			}
		}

		return count;
	}

	// Is string in this string?
	bool contains(String<A> s) { if(countOccurrences(s) > 0) { return true; }  return false; }

	// Is char in this string?
	bool contains(A s) { if(countOccurrences(s) > 0) { return true; }  return false; }

	// Contains only characters specified by CharGroup passed-in?
	bool containsOnly(CharGroup chGroup)
	{
		for(u64 c=0; c<numChars; c++)
		{
			if(chGroup.contains(chars[c]) == false)
				return false;
		}

		return true;
	}

	// Does string begin with passed-in character?
	bool beginsWith(A ch)
	{
		if(numChars == 0)
			return false;

		if(chars[0] == ch)
			return true;

		return false;
	}

	// Does string begin with?
	bool beginsWith(String<A> valueX) { return beginsWith(valueX, true); }
	
	// Does string begin with?
	bool beginsWith(String<A> valueX, bool caseSensitive)
	{
		return compare(0, valueX, 0, valueX.numChars, caseSensitive);
	}

	// Does string end with passed-in character?
	bool endsWith(A ch)
	{
		if(numChars == 0)
			return false;

		if(chars[numChars-1] == ch)
			return true;

		return false;
	}

	// Does string begin with?
	bool endsWith(String<A> valueX) { return endsWith(valueX, true); }
	
	// Does string end with?
	bool endsWith(String<A> valueX, bool caseSensitive)
	{
		u64 startIndex = Math:max(0, i64(numChars) - i64(valueX.numChars));
		return compare(startIndex, valueX, 0, valueX.numChars, caseSensitive);
	}

	// Linear search to next non-whitespace char.
	i64 findNextNonWhitespace(i64 fromIndex)
	{
		return findNextNonWhitespace(fromIndex, numChars-1);
	}

	// Linear search to next non-whitespace char.
	i64 findNextNonWhitespace(i64 fromIndex, i64 endIndex)
	{
		if(fromIndex >= numChars)
			fromIndex = numChars-1;

		if(fromIndex < 0)
			fromIndex = 0;

		if(endIndex >= numChars)
			endIndex = numChars-1;

		for(i64 i=fromIndex; i<=endIndex; i++)
		{
			if(Chars:isWhitespace(chars[i]) == true)
				continue;

			return i;
		}

		return -1;
	}

	// Linear search to next whitespace char.
	i64 findNextWhitespace(i64 fromIndex)
	{
		return findNextWhitespace(fromIndex, numChars-1);
	}

	// Linear search to next whitespace char.
	i64 findNextWhitespace(i64 fromIndex, i64 endIndex)
	{
		if(fromIndex >= numChars)
			fromIndex = numChars-1;

		if(fromIndex < 0)
			fromIndex = 0;

		if(endIndex >= numChars)
			endIndex = numChars-1;

		for(i64 i=fromIndex; i<=endIndex; i++)
		{
			if(Chars:isWhitespace(chars[i]) == true)
				return i;
		}

		return -1;
	}

	// is this string whitespace only?
	bool isWhitespace()
	{
		if(findNextNonWhitespace(0) == -1)
			return true;

		return false;
	}

	// Remove start/end whitespace.
	void trimWhitespace()
	{
		i64 firstChar = findNextNonWhitespace(0);
		if(firstChar > 0)
		{
			String<A> s = this.subString(firstChar, numChars-1);
			this.chars = s.chars;
			s.chars = null;
			this.numChars = s.numChars;
		}

		i64 lastChar = numChars-1;
		for(i64 i=lastChar; i>=0; i--)
		{
			if(Chars:isWhitespace(chars[i]))
				numChars--;
			else
				break;
		}
	}

	// Split this string by character specified, no whitespace trimming.
	ArrayList<String<A>> split(A splitChar)
	{
		return split(splitChar, false);
	}

	// Split this string by character specified.
	ArrayList<String<A>> split(A splitChar, bool trimWhitespace)
	{
		ArrayList<String<A>> items();

		i64 lastIndex = 0;
		i64 index = findNext(splitChar, lastIndex);
		while(index != -1)
		{
			String<A> item = subString(lastIndex, index-1);
			if(trimWhitespace == true)
				item.trimWhitespace();
			items.add(item);

			lastIndex = index+1;
			index = findNext(splitChar, lastIndex);
		}

		if(lastIndex < length())
		{
			String<A> item = subString(lastIndex, length()-1);
			if(trimWhitespace == true)
				item.trimWhitespace();
			items.add(item);
		}

		return items;
	}

	// Split this string by character specified, skipping over pair type.
	ArrayList<String<A>> split(A splitChar, A openPairChar, A closePairChar, bool trimWhitespacePer)
	{
		ArrayList<String<A>> params = ArrayList<String<A>>();

		// scan for split chars, skipping over any match pairs (...)
		i64 startParamIndex = 0;
		for(i64 c=0; c<length(); c++)
		{
			if(chars[c] == openPairChar)
			{
				i64 closeParenthesisIndex = findPairEnd(openPairChar, closePairChar, c, length()-1);
				if(closeParenthesisIndex == -1)
				{
					params.clear();
					return params;
				}

				c = closeParenthesisIndex; // skip over this since it could contain split chars for other symbols etc.
			}
			else if(chars[c] == splitChar)
			{
				String<A> paramStr = subString(startParamIndex, c-1);
				if(trimWhitespacePer == true) { paramStr.trimWhitespace(); }
				params.add(paramStr);
				startParamIndex = c + 1; // skip over split char
			}

			if(c == length()-1)
			{
				// last param
				String<A> paramStr = subString(startParamIndex, length()-1);
				if(trimWhitespacePer == true) { paramStr.trimWhitespace(); }
				params.add(paramStr);
			}
		}

		return params;
	}

	// Split this string by whitespace.
	ArrayList<String<A>> splitByWhitespace()
	{
		ArrayList<String<A>> items = ArrayList<String<A>>();

		i64 termStartIndex = -1;
		for(i64 c=0; c<numChars; c++)
		{
			if(termStartIndex != -1)
			{
				// in a word, looking for end
				if(Chars:isWhitespace(chars[c]) == true)
				{
					String<A> term = this.subString(termStartIndex, c-1);
					items.add(term);

					termStartIndex = -1;
				}
				else if(c == numChars-1)
				{
					// end of word because end of string
					String<A> term = this.subString(termStartIndex, c);
					items.add(term);

					termStartIndex = -1;
				}
			}
			else // looking for start of word
			{
				if(Chars:isWhitespace(chars[c]) == false)
				{
					termStartIndex = c;

					// special case, single char last word
					if(c == numChars-1)
					{
						String<A> term = this.subString(termStartIndex, c);
						items.add(term);

						termStartIndex = -1;
					}
				}
			}
		}

		return items;
	}

	// Split each term by whitespace and/or by quote pairs.
	ArrayList<String<A>> splitByWhitespaceQuotes()
	{
		ArrayList<String<A>> terms = ArrayList<String<A>>();

		i64  termStartIndex = -1;
		bool termStartedWithQuote = false;
		for(i64 c = 0; c<numChars; c++)
		{
			if(termStartIndex != -1)
			{
				// in a word, looking for end
				if(termStartedWithQuote == true)
				{
					if(chars[c] == Chars:DOUBLE_QUOTE) // end of term
					{
						String<A> term = subString(termStartIndex+1, c-1); // don't include quotes
						terms.add(term);

						termStartIndex = -1;
						termStartedWithQuote = false;
					}
					else if(c == numChars-1)
					{
						// end of word because end of string
						String<A> term = subString(termStartIndex+1, c); // don't start quote
						terms.add(term);

						termStartIndex = -1;
						termStartedWithQuote = false;
					}
				}
				else
				{
					if(Chars:isWhitespace(chars[c]) == true) // end of term
					{
						String<A> term = subString(termStartIndex, c-1);
						terms.add(term);

						termStartIndex = -1;
					}
					else if(c == numChars-1)
					{
						// end of word because end of string
						String<A> term = subString(termStartIndex, c);
						terms.add(term);

						termStartIndex = -1;
					}
				}
			}
			else // looking for start of word
			{
				if(Chars:isWhitespace(chars[c]) == false)
				{
					termStartIndex = c;

					// special case, terms started with quotes
					if(chars[c] == Chars:DOUBLE_QUOTE)
					{
						termStartedWithQuote = true;
					}

					// special case, single char last word
					if(c == numChars-1)
					{
						String<A> term = subString(termStartIndex, c);
						terms.add(term);

						termStartIndex = -1;
					}
				}
			}
		}

		return terms;
	}

	// Combine a list of strings into a single string.
	shared String<A> combine(ArrayList<String<A>> strs, String<A> betweenStr)
	{
		String<A> s = String<A>(16 + (strs.size() * (10 + betweenStr.length())));

		for(u32 i=0; i<strs.size(); i++)
		{
			s.append(strs[i]);

			if(i != strs.size()-1)
				s.append(betweenStr);
		}

		return s;
	}

	// Parse boolean ("true/false") value from this string.
	bool parseBoolean()
	{
		if(contains(String<A>("true")) || contains(String<A>("TRUE")) || contains(String<A>("True")))
			return true;

		return false;
	}

	// Parse boolean ("true/false") value from this string.
	bool parseBoolean(bool defVal)
	{
		if(contains(String<A>("true")) || contains(String<A>("TRUE")) || contains(String<A>("True")))
			return true;

		if(contains(String<A>("false")) || contains(String<A>("FALSE")) || contains(String<A>("False")))
			return true;

		return defVal;
	}

	// Parse I64 value from this string.
	i64 parseInteger()
	{
		return parseInteger(0, numChars-1);
	}

	// Parse I64 value from this string.
	i64 parseInteger(i64 startIndex, i64 endIndex)
	{
		if(startIndex >= numChars)
			return 0;

		if(endIndex < startIndex)
			return 0;

		assert(endIndex < numChars);

		if(endIndex >= numChars)
			endIndex = numChars-1;

		i64 valueOut = 0;

		// ignore leading white space
		startIndex = findNextNonWhitespace(startIndex);
		if(startIndex < 0)
			return 0; //nothing but white space

		// very first char could be + / - char
		bool numberIsNegative = false;
		if(chars[startIndex] == Chars:PLUS)
			startIndex++; //just ignore it since we assume positive

		if(chars[startIndex] == Chars:HYPHEN)
		{
			startIndex++;
			numberIsNegative = true;
		}

		// find end of digits
		i64 lastDigitIndex = startIndex;
		while(lastDigitIndex <= endIndex)
		{ 
			if(Chars:isNumeric(chars[lastDigitIndex]) == true)
				lastDigitIndex++;
			else
				break;
		}

		lastDigitIndex--; // last char is not digit

		i64 numDigits = (lastDigitIndex+1) - startIndex;
		if(numDigits <= 0)
		{
			return 0; // no number in this string
		}
		else if(numDigits > 19)
		{
			// too big of a number
			valueOut = 9223372036854775807;
			if(numberIsNegative == true)
				valueOut = -9223372036854775807;
		}
		else
		{
			valueOut = 0;
			i64 multiply = 1;

			for(i64 i=lastDigitIndex; i>=startIndex; i--)
			{
				if(numDigits == 19 && i == startIndex && ((chars[i] == Chars:NINE && valueOut > 223372036854775807) || chars[i] > Chars:NINE))
				{
					// number will end up being too big
					valueOut = 9223372036854775807;
					if(numberIsNegative == true)
						valueOut = -9223372036854775807;
					return lastDigitIndex;
				}

				valueOut += (chars[i] - Chars:ZERO) * multiply;
				multiply *= 10;
			}

			if(numberIsNegative == true)
				valueOut *= -1;
		}

		return valueOut;
	}

	// Parse F64 value from this string.
	f64 parseFloat()
	{
		return parseFloat(0, numChars-1);
	}

	// Parse F64 value from this string.
	f64 parseFloat(i64 startIndex, i64 endIndex)
	{
		if(startIndex >= numChars)
			return 0.0;

		if(endIndex < startIndex)
			return 0.0;

		assert(startIndex >= 0);
		assert(endIndex < numChars);

		f64 valueOut = 0.0;

		// ignore leading white space
		startIndex = findNextNonWhitespace(startIndex);
		if(startIndex < 0)
			return valueOut; // nothing but white space

		// very first char could be + / - char
		bool numberIsNegative = false;
		if(chars[startIndex] == Chars:PLUS)
			startIndex++; // just ignore it since we assume positive

		if(startIndex >= numChars)
			return 0.0;

		if(chars[startIndex] == Chars:HYPHEN)
		{
			startIndex++;
			numberIsNegative = true;
		}

		if(startIndex >= numChars)
			return 0.0;

		// the first/next char could be a decimal - i.e. .004
		i64 decimalIndex = -1;

		bool hasWholeNumber = true;
		if(chars[startIndex] == Chars:PERIOD)
		{
			hasWholeNumber = false;
			decimalIndex = startIndex;
		}

		// find end of digits
		i64 lastDigitIndex = -1;
		if(hasWholeNumber == true)
		{
			lastDigitIndex = startIndex;
			while(lastDigitIndex <= endIndex)
			{
				if(Chars:isNumeric(chars[lastDigitIndex]) == true)
					lastDigitIndex++;
				else
					break;
			}

			// check for decimal 
			if(lastDigitIndex <= endIndex)
			{
				if(chars[lastDigitIndex] == Chars:PERIOD)
					decimalIndex = lastDigitIndex;
			}

			lastDigitIndex--; // last char is not digit
		}

		// check for fractional part
		i64 fractionStartIndex = -1;
		i64 fractionEndIndex   = -1;
		if(decimalIndex != -1)
		{
			fractionEndIndex = decimalIndex + 1;
			while(fractionEndIndex <= endIndex)
			{
				if(Chars:isNumeric(chars[fractionEndIndex]) == true)
					fractionEndIndex++;
				else
					break;
			}

			fractionEndIndex--; // last is non digit

			if(fractionEndIndex <= endIndex && fractionEndIndex >= 0)
			{
				fractionStartIndex = decimalIndex + 1;
			}

			if(fractionEndIndex == decimalIndex)
				fractionEndIndex = -1;
		}

		// setup
		valueOut = 0;

		// do whole number part
		if(hasWholeNumber == true)
		{
			i64 numDigits = (lastDigitIndex+1) - startIndex;
			if(numDigits <= 0)
			{
				return valueOut; // no number in this string
			}
			else
			{
				i64 multiply = 1;
				for(i64 i=lastDigitIndex; i>=startIndex; i--)
				{
					valueOut += (chars[i] - Chars:ZERO) * multiply;
					multiply *= 10;
				}
			}
		}

		// do fractional part
		if(fractionStartIndex != -1 && fractionEndIndex >= fractionStartIndex)
		{
			i64 numDigits = (fractionEndIndex+1) - fractionStartIndex;
			if(numDigits > 0)
			{
				f64 multiplyFloat = 0.1f;
				for(i64 q=fractionStartIndex; q<=fractionEndIndex; q++)
				{
					valueOut += (chars[q] - Chars:ZERO) * multiplyFloat;
					multiplyFloat *= 0.1f;
				}
			}
		}

		if(numberIsNegative == true)
			valueOut *= -1;

		return valueOut; // there is a decimal, but no digits follow it, so we ignore it (assume it's a period)
	}

	// Parse hexidecimal number from this string, i.e. "FFAABB11". Does not handle 0x prefix.
	u64 parseHex()
	{
		String<A> s = this.clone();

		s.trimWhitespace();
		s.toUppercase();

		// max
		u64 newNumChars = s.length();
		if(newNumChars > 16)
			newNumChars = 16;

		u64 val = 0;
		u64 exponent = Math:pow(16, newNumChars-1);
		for(u64 c=0; c<newNumChars; c++)
		{
			A  ch    = s.chars[c];
			u64 chVal = 0;
			if(ch >= Chars:ZERO && ch <= Chars:NINE)
				chVal = ch - Chars:ZERO;
			else if(ch >= Chars:A && ch <= Chars:F) // upper case letters
				chVal = (ch - Chars:A) + 10;
			else if(ch >= Chars:a && ch <= Chars:f) // lower case letters
				chVal = (ch - Chars:a) + 10;
			else
				return val;

			val += chVal * exponent;
			
			exponent /= 16;
		}

		return val;
	}

	// Format boolean to string as "true" or "false"
	shared String<A> formatBoolean(bool b)
	{
		if(b == true)
			return String<A>("true");

		return String<A>("false");
	}

	// Format number to base 10 string.
	shared String<A> formatNumber(u8 n)
	{
		u64 val64 = n;
		return String<A>:formatNumber(val64);
	}

	// Format number to base 10 string.
	shared String<A> formatNumber(i8 n)
	{
		i64 val64 = n;
		return String<A>:formatNumber(val64);
	}

	// Format number to base 10 string.
	shared String<A> formatNumber(u16 n)
	{
		u64 val64 = n;
		return String<A>:formatNumber(val64);
	}

	// Format number to base 10 string.
	shared String<A> formatNumber(i16 n)
	{
		i64 val64 = n;
		return String<A>:formatNumber(val64);
	}

	// Format number to base 10 string.
	shared String<A> formatNumber(u32 n)
	{
		u64 val64 = n;
		return String<A>:formatNumber(val64);
	}

	// Format number to base 10 string.
	shared String<A> formatNumber(i32 n)
	{
		i64 val64 = n;
		return String<A>:formatNumber(val64);
	}

	// Format number to base 10 string.
	shared String<A> formatNumber(u64 val)
	{
		String<A> s = String<A>(32);

		if(val == 0)
		{
			s.copy("0");
			return s;
		}

	    i32 digitIndex = 0;
	    while(val > 0)
	    {
	    	s.chars[digitIndex] = Chars:ZERO + (val % 10);
	    	val /= 10;
	    	digitIndex++;
	    }
	    s.numChars = digitIndex;

	    s.reverse();
		return s;
	}

	// Format number to base 10 string.
	shared String<A> formatNumber(i64 n)
	{
		String<A> s = String<A>(32);

		if(n == 0)
		{
			s.copy("0");
			return s;
		}

		i64 val = Math:abs(n);
	    i32 digitIndex = 0;
	    while(val > 0)
	    {
	    	s.chars[digitIndex] = Chars:ZERO + (val % 10);
	    	val /= 10;
	    	digitIndex++;
	    }
	    s.numChars = digitIndex;

	    if(n < 0)
	    {
	    	s.chars[s.numChars] = Chars:HYPHEN;
	    	s.numChars++;
	    }

	    s.reverse();
		return s;
	}

	// Format number to base 10 string. - Native function.
	shared String<A> formatNumber(f32 val)
	{
		return String<A>(formatNumber_native(val, 2)); // wrapped String<A>(...) to handle u8.u16 etc.
	}

	// Format number to base 10 string. - Native function.
	shared String<A> formatNumber(f64 val)
	{
		return String<A>(formatNumber_native(val, 2)); // wrapped String<A>(...) to handle u8.u16 etc.
	}

	// Format number to base 10 string. - Native function.
	shared String<A> formatNumber(f32 val, u8 numFracDigits)
	{
		return String<A>(formatNumber_native(val, numFracDigits)); // wrapped String<A>(...) to handle u8.u16 etc.
	}

	// Format number to base 10 string. - Native function.
	shared String<A> formatNumber(f64 val, u8 numFracDigits)
	{
		return String<A>(formatNumber_native(val, numFracDigits)); // wrapped String<A>(...) to handle u8.u16 etc.
	}

	// Format number to base 16 string. Pads to 2 digits automatically.
	shared String<A> formatNumberHex(u8 n)
	{
		return String<A>:formatNumberHex(n, 2);
	}

	// Format number to base 16 string. Pads to 4 digits automatically.
	shared String<A> formatNumberHex(u16 n)
	{
		return String<A>:formatNumberHex(n, 4);
	}

	// Format number to base 16 string. Pads to 8 digits automatically.
	shared String<A> formatNumberHex(u32 n)
	{
		return String<A>:formatNumberHex(n, 8);
	}

	// Format number to base 16 string. Pads to 16 digits automatically.
	shared String<A> formatNumberHex(u64 n)
	{
		return String<A>:formatNumberHex(n, 16);
	}

	shared String<u8> HEX_CONSTS = "0123456789ABCDEF";

	// Format number to base 16 string.
	shared String<A> formatNumberHex(u64 val, i32 padLen)
	{
		String<A> s = String<A>(32);

	    i32 digitIndex = 0;
	    while(val > 0)
	    {
	    	s.chars[digitIndex] = HEX_CONSTS.chars[(val % 16)];
	    	val /= 16;
	    	digitIndex++;
	    }
	    s.numChars = digitIndex;

	    // pad to N digits
	    u32 numZeros = padLen - s.numChars;
	    for(u32 p=0; p<numZeros; p++)
	    	s.append("0");
	    
	    s.reverse();
		return s;
	}

	// Encode special characters
	String<A> encodeXMLText()
	{
		// '   &apos;
		// "   &quot;
		// <   &lt;
		// >   &gt;
		// &   &amp;

		String<A> cpy(numChars);

		for(u64 c=0; c<numChars; c++)
		{
			if(chars[c] == Chars:SINGLE_QUOTE)
				cpy.append(String<A>("&apos;"));
			else if(chars[c] == Chars:DOUBLE_QUOTE)
				cpy.append(String<A>("&quot;"));
			else if(chars[c] == Chars:OPEN_ANGLE_BRACKET)
				cpy.append(String<A>("&lt;"));
			else if(chars[c] == Chars:CLOSE_ANGLE_BRACKET)
				cpy.append(String<A>("&gt;"));
			else if(chars[c] == Chars:AMPERSAND)
				cpy.append(String<A>("&amp;"));
			else
				cpy.append(chars[c]);
		}

		return cpy;
	}

	// Decode special characters
	String<A> decodeXMLText()
	{
		String<A> cpy(numChars);

		for(u64 c=0; c<numChars; c++)
		{
			if(chars[c] == Chars:AMPERSAND)
			{
				if(this.compare(c+1, String<A>("apos;"), 0, 5, true) == true)
				{
					cpy.append(Chars:SINGLE_QUOTE);
					c += 5;
				}
				else if(this.compare(c+1, String<A>("quot;"), 0, 5, true) == true)
				{
					cpy.append(Chars:DOUBLE_QUOTE);
					c += 5;
				}
				else if(this.compare(c+1, String<A>("lt;"), 0, 3, true) == true)
				{
					cpy.append(Chars:OPEN_ANGLE_BRACKET);
					c += 3;
				}
				else if(this.compare(c+1, String<A>("gt;"), 0, 3, true) == true)
				{
					cpy.append(Chars:CLOSE_ANGLE_BRACKET);
					c += 3;
				}
				else if(this.compare(c+1, String<A>("amp;"), 0, 4, true) == true)
				{
					cpy.append(Chars:AMPERSAND);
					c += 4;
				}
				else
					cpy.append(chars[c]);
			}
			else
				cpy.append(chars[c]);
		}

		return cpy;
	}

	// Alphabetical ordering. Returns -1 if this string is less than passed-in. +1 if this string is more than passed-in.
	i8 order(String<A> b)
	{
		u64 minChars = this.numChars;
		if(b.numChars < minChars)
			minChars = b.numChars;

		for(u64 c=0; c<minChars; c++)
		{
			A charA = Chars:toLower(this.chars[c]);
			A charB = Chars:toLower(b.chars[c]);

			if(charA < charB)
				return -1;

			if(charA > charB)
				return 1;
		}

		if(this.numChars < b.numChars)
			return -1;

		if(this.numChars > b.numChars)
			return 1;

		return 0;
	}

	// Calculate hash for object.
	u64 hash()
	{
		u64 len = this.length();
		if(len > 8)
			len = 8;

		u64 hash = 0;
		for(u64 c=0; c<len; c++)
		{
			hash = hash | this.chars[c];
			hash = hash << 8;
		}

		return hash;
	}

	// Instantiate common types template-class-instances.
	shared String<u8>  defaultStringUTF8;
	shared String<u16> defaultStringUTF16;
	shared String<u32> defaultStringUTF32;
}

