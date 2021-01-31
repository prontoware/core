////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// UUID
////////////////////////////////////////////////////////////////////////////////////////////////////

// Generates a "universally unique identifier" stored as 128 bit number. Low 64 bits are 
// epoch-relative time in seconds. High 64 bits are random values combined with hashed computer
// information.
class UUID
{
	shared RandomFast uuidRandomNums(System:getTime() ^ Thread:getID());
	shared u32 uuidCounter = 1;

	u64[2] id; // id[0] 64 bits is epoch-relative date time.

	// Creates a new unique GUID.
	void constructor()
	{
		id = generateValue();
	}

	// Copy constructor.
	void constructor(UUID uuid)
	{
		this.id = uuid.id;
	}

	// From hex string.
	void constructor(String<u8> str)
	{
		fromString(str);
	}

	// Replace default method implementation. Return hash code.
	u64 getHash()
	{
		return id[0] ^ id[1];
	}

	// Replace default method implementation. Exact match, case-sensitive.
	bool equals(IObj obj)
	{
		UUID b = obj;
		if(b == null)
			return false;

		if(id[0] == b.id[0] && id[1] == b.id[1])
			return true;

		return false;
	}

	// Replace default method implementation. Is this less than passed-in.
	bool lessThan(IObj obj)
	{
		UUID b = obj;
		if(b == null)
			return false;

		if(this.id[0] < b.id[0])
			return true;

		if(this.id[1] < b.id[1])
			return true;
		
		return false;
	}

	// Replace default method implementation. Is this less than passed-in.
	bool moreThan(IObj obj)
	{
		UUID b = obj;
		if(b == null)
			return false;

		if(this.id[0] > b.id[0])
			return true;

		if(this.id[1] > b.id[1])
			return true;
		
		return false;
	}

	// Returns string in format hex values.
	String<u8> toString()
	{
		String<u8> s(16);

		s.append(String<u8>:formatNumberHex(id[0]));
		s.append(String<u8>:formatNumberHex(id[1]));

		s.toLowercase();

		return s;
	}

	// Parse from string.
	void fromString(String<u8> idStr)
	{
		String<u8> s(idStr);
		s.trimWhitespace();

		if(s.length() != 32)
			return;

		String<u8> lowStr  = s.subString(0, 15);
		String<u8> highStr = s.subString(16, 31);

		id[0] = lowStr.parseHex();
		id[1] = highStr.parseHex();
	}

	// Generate values.
	u64[2] generateValue()
	{
		// TODO combine with MAC address high 64 bits

		u64[2] vals;
		vals[0] = DateTime:getSecondsPastEpoch();
		vals[1] = uuidRandomNums.getI32(Math:I32_MIN, Math:I32_MAX); 
		vals[1] = vals[1] << 32;

		uuidCounter++;

		u64 combo = uuidCounter;
		vals[1] = vals[1] | combo;

		return vals;
	}
}