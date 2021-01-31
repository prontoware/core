////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// INIEntry
////////////////////////////////////////////////////////////////////////////////////////////////////

// Used by INIFile, holds a name/value/comment triple. This triple normally represents one line in
// an INI file, i.e. "name=value; comment".
class INIEntry
{
	String<u8> name    = String<u8>();
	String<u8> val     = String<u8>();
	String<u8> comment = String<u8>();

	void constructor() { }
	
	void constructor(String<u8> name, String<u8> val)
	{
		this.name.copy(name);
		this.val.copy(val);
	}

	void constructor(String<u8> name, String<u8> val, String<u8> comment)
	{
		this.name.copy(name);
		this.val.copy(val);
		this.comment.copy(comment);
	}

	void constructor(String<u8> name, i64 integerValue)
	{
		this.name.copy(name);
		setValue(integerValue);
	}

	void constructor(String<u8> name, i64 integerValue, String<u8> comment)
	{
		this.name.copy(name);
		this.comment.copy(comment);

		setValue(integerValue);
	}

	void constructor(String<u8> name, f64 floatValue)
	{
		this.name.copy(name);
		setValue(floatValue);
	}

	void constructor(String<u8> name, f64 floatValue, String<u8> comment)
	{
		this.name.copy(name);
		this.comment.copy(comment);

		setValue(floatValue);
	}

	void constructor(String<u8> name, bool booleanValue)
	{
		this.name.copy(name);
		setValue(booleanValue);
	}

	void constructor(String<u8> name, bool booleanValue, String<u8> comment)
	{
		this.name.copy(name);
		this.comment.copy(comment);

		setValue(booleanValue);
	}

	void constructor(INIEntry copyFrom)
	{
		this.name.copy(copyFrom.name);
		this.val.copy(copyFrom.val);
		this.comment.copy(copyFrom.comment);
	}

	void destroy()
	{
		this.name = null;
		this.val  = null;
		this.comment = null;
	}

	// Copies name/value/comment.
	void copy(INIEntry copyFrom)
	{
		this.name.copy(copyFrom.name);
		this.val.copy(copyFrom.val);
		this.comment.copy(copyFrom.comment);
	}

	// Name/value/comment must all match for true result.
	bool compare(INIEntry b)
	{
		if(name.compare(b.name) == false)
			return false;

		if(val.compare(b.val) == false)
			return false;

		if(comment.compare(b.comment) == false)
			return false;

		return true;
	}

	// Set value to integer.
	void setValue(i64 i)
	{
		val = String<u8>:formatNumber(i);
	}

	// Set value to floating-point number.
	void setValue(f64 f)
	{
		val = String<u8>:formatNumber(f);
	}

	// Set value to true/false.
	void setValue(bool b)
	{
		val.numChars = 0;
		if(b == false)
			val.append("false");
		else
			val.append("true");
	}

	// Get value as true/false.
	bool getBool(bool defaultVal)
	{
		if(val.contains("true") || val.contains("TRUE") || val.contains("True"))
			return true;
		if(val.contains("false") || val.contains("FALSE") || val.contains("False"))
			return false;

		return defaultVal;
	}

	// Get value as floating-point number.
	f64 getF64(f64 defaultVal)
	{
		if(val.length() > 0)
			return val.parseFloat();

		return defaultVal;
	}

	// Get value as integer.
	i64 getI64(i64 defaultVal)
	{
		if(val.length() > 0)
			return val.parseInteger();

		return defaultVal;
	}

	// Get value as string.
	String<u8> getString()
	{
		return val;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// INIFile
////////////////////////////////////////////////////////////////////////////////////////////////////

// Read/write INI files.
class INIFile
{
	u8 COMMENT_CHAR = Chars:VERTICAL_BAR;
	ArrayList<INIEntry> entries = ArrayList<INIEntry>();

	void constructor()
	{

	}

	void constructor(INIFile ini)
	{
		copy(ini);
	}

	void destroy()
	{
		deleteEntries();
	}

	// If any entires do not match or are missing, returns false.
	bool compare(INIFile b)
	{
		if(entries.size() != b.entries.size())
			return false;

		for(u64 e=0; e<entries.size(); e++)
		{
			INIEntry aEntry = entries[e];
			if(b.hasEntry(aEntry.name) == false)
				return false;
			INIEntry bEntry = b.getEntry(aEntry.name);
			if(aEntry != bEntry)
				return false;
		}

		return true;
	}

	void copy(INIFile i)
	{
		this.entries.clear();
		for(u64 e=0; e<i.entries.size(); e++)
		{
			this.entries.add(i.entries.get(e));
		}
	}

	INIFile clone()
	{
		return INIFile(this);
	}

	// Get entries that do not have a match.
	ArrayList<Pair<INIEntry, INIEntry>> diff(INIFile b)
	{
		ArrayList<Pair<INIEntry, INIEntry>> diffs;

		// compare this entries to b
		for(u64 e=0; e<entries.size(); e++)
		{
			INIEntry aEntry = entries[e];
			if(b.hasEntry(aEntry.name) == false)
			{
				// b doesn't have this, indicate with empty name
				diffs.add(Pair<INIEntry, INIEntry>(aEntry, INIEntry(String<u8>(""), String<u8>(""), String<u8>(""))));
			}
			else
			{
				INIEntry bEntry = b.getEntry(aEntry.name);
				if(aEntry != bEntry)
				{
					// b's value is different
					diffs.add(Pair<INIEntry, INIEntry>(aEntry, bEntry));
				}
			}
		}

		// check for entries in b but not this
		for(u64 f=0; f<b.entries.size(); f++)
		{
			INIEntry bEntry = b.entries[f];
			if(this.hasEntry(bEntry.name) == false)
			{
				// a doesn't have this, indicate with empty name
				diffs.add(Pair<INIEntry, INIEntry>(INIEntry(String<u8>(""), String<u8>(""), String<u8>("")), bEntry));
			}
		}

		return diffs;
	}

	// Get entries that do not have a match as a human readable string.
	String<u8> diffString(INIFile b)
	{
		ArrayList<Pair<INIEntry, INIEntry>> diffs = diff(b);

		String<u8> s = String<u8>(1024);

		for(u64 e=0; e<diffs.size(); e++)
		{
			Pair<INIEntry, INIEntry> ab = diffs[e];

			s.append("A_Name: ");
			s.append(ab.a.name);

			s.append(" A_Val: ");
			s.append(ab.a.val);

			s.append(" B_Name: ");
			s.append(ab.b.name);

			s.append(" B_Val: ");
			s.append(ab.b.val);

			s.append("\n");
		}

		return s;
	}

	// Read INIFile from text contents. Clears any existing entries.
	bool read(String<u8> textIn)
	{
		// clear existing
		entries.clear();

		String<u8> text = String<u8>(textIn);
		text.removeAll(Chars:RETURN);

		// Parse each line
		i64 currentIndex = 0;
		i64 lineEndIndex = text.findNext(Chars:NEW_LINE, currentIndex);
		if(lineEndIndex == -1)
			lineEndIndex = text.numChars-1;
		while(currentIndex < text.numChars && currentIndex < lineEndIndex)
		{
			String<u8> lineStr = null;
			if(text.chars[lineEndIndex] == Chars:NEW_LINE)
				lineStr = text.subString(currentIndex, lineEndIndex-1);
			else
				lineStr = text.subString(currentIndex, lineEndIndex);

			String<u8> comment = String<u8>("");
			i64 commentIndex = lineStr.findNext(COMMENT_CHAR, 0);
			if(commentIndex != -1)
			{
				if(commentIndex != lineStr.length()-1)
					comment = lineStr.subString(commentIndex+1, lineStr.length()-1);

				if(commentIndex != 0)
					lineStr = lineStr.subString(0, commentIndex-1);
			}

			if(commentIndex != 0) // line could be full comment, which we would ignore
			{
				i64 equalsIndex = lineStr.findNext(Chars:EQUALS, 0);
				if(equalsIndex >= 1)
				{
					String<u8> name = lineStr.subString(0, equalsIndex-1);
					name.trimWhitespace();

					if(equalsIndex < lineStr.length()-1)
					{
						String<u8> val = lineStr.subString(equalsIndex+1, lineStr.length()-1);
						val.trimWhitespace();

						entries.add(INIEntry(name, val, comment));
					}
				}
			}

			// prepare to parse next line
			currentIndex = lineEndIndex + 1;
			if(currentIndex < text.numChars)
			{
				lineEndIndex = text.findNext(Chars:NEW_LINE, currentIndex);
				if(lineEndIndex == -1)
					lineEndIndex = text.numChars-1;
			}
		}

		return true;
	}

	// Write all entries, one per line.
	bool write(String<u8> text)
	{
		for(u64 e=0; e<entries.size(); e++)
		{
			//name=value
			text.append(entries.get(e).name);
			text.append("=");
			text.append(entries.get(e).val);

			//comment (optional)
			if(entries.get(e).comment.numChars > 0)
			{
				text.append(COMMENT_CHAR);
				text.append(entries.get(e).comment);
			}

			//next line
			text.append(Chars:NEW_LINE);
		}

		return true;
	}

	// Contains check, by name of entry.
	bool hasEntry(String<u8> name)
	{
		for(u64 e=0; e<entries.size(); e++)
		{
			if(entries.get(e).name.compare(name) == true)
				return true;
		}

		return false;
	}

	// Get by name of entry.
	INIEntry getEntry(String<u8> name)
	{
		for(u64 e=0; e<entries.size(); e++)
		{
			if(entries.get(e).name.compare(name) == true)
				return entries.get(e);
		}

		return INIEntry(String<u8>(""), String<u8>(""));
	}

	// Get entry value, assuming boolean value.
	bool getBool(String<u8> name, bool defaultVal)
	{
		INIEntry entry = getEntry(name);
		if(entry.name.length() != 0)
			return entry.getBool(defaultVal);

		return defaultVal;
	}

	// Get entry value, assuming floating-point value.
	f64 getF64(String<u8> name, f64 defaultVal)
	{
		INIEntry entry = getEntry(name);
		if(entry.name.length() != 0)
			return entry.getF64(defaultVal);

		return defaultVal;
	}

	// Get entry value, assuming integer value.
	i64 getI64(String<u8> name, i64 defaultVal)
	{
		INIEntry entry = getEntry(name);
		if(entry.name.length() != 0)
			return entry.getI64(defaultVal);

		return defaultVal;
	}

	// Get entry value, assuming String<u8> value.
	String<u8> getString(String<u8> name, String<u8> defaultVal)
	{
		INIEntry entry = getEntry(name);
		if(entry.name.length() != 0)
			return entry.getString();

		return defaultVal;
	}

	// Add/replace entry value.
	void setEntry(INIEntry entry)
	{
		// try to find first
		for(u64 e=0; e<entries.size(); e++)
		{
			if(entries.data[e].name.compare(entry.name) == true)
			{
				INIEntry oldEntry = entries.get(e);
				entries.data[e] = entry;
				return;
			}
		}

		// new entry
		entries.add(entry);
	}

	// Add/replace entry value.
	void setEntry(String<u8> name, String<u8> val)
	{
		// try to find first
		for(u64 e=0; e<entries.size(); e++)
		{
			if(entries.data[e].name.compare(name) == true)
			{
				entries.data[e].val.copy(val);
				return;
			}
		}

		// new entry
		entries.add(INIEntry(name, val));
	}

	// Add/replace entry value.
	void setEntryI64(String<u8> name, i64 integerValue)
	{
		// try to find first
		for(u64 e=0; e<entries.size(); e++)
		{
			if(entries.data[e].name.compare(name) == true)
			{
				entries.data[e].setValue(integerValue);
				return;
			}
		}

		// new entry
		entries.add(INIEntry(name, integerValue));
	}

	// Add/replace entry value.
	void setEntryF64(String<u8> name, f64 floatValue)
	{
		// try to find first
		for(u64 e=0; e<entries.size(); e++)
		{
			if(entries.data[e].name.compare(name) == true)
			{
				entries.data[e].setValue(floatValue);
				return;
			}
		}

		// new entry
		entries.add(INIEntry(name, floatValue));
	}

	// Add/replace entry value.
	void setEntryBool(String<u8> name, bool booleanValue)
	{
		// try to find first
		for(u64 e=0; e<entries.size(); e++)
		{
			if(entries.data[e].name.compare(name) == true)
			{
				entries.data[e].setValue(booleanValue);
				return;
			}
		}

		// new entry
		entries.add(INIEntry(name, booleanValue));
	}

	// Delete entry object, removing from internal list.
	void deleteEntry(String<u8> name)
	{
		for(u64 e=0; e<entries.size(); e++)
		{
			if(entries.data[e].name.compare(name) == true)
			{
				INIEntry entry = entries.remove(e);
				return;
			}
		}
	}

	// Delete all entries.
	void deleteEntries()
	{
		while(entries.size() > 0)
		{
			INIEntry entry = entries.removeLast();
		}
	}

	// Returns internal representation.
	ArrayList<INIEntry> getAllEntries()
	{
		return entries;
	}

	// Get all entries.
	ArrayList<Pair<String<u8>,String<u8>>> getAllEntriesAsStrings()
	{
		ArrayList<Pair<String<u8>, String<u8>>> props = ArrayList<Pair<String<u8>, String<u8>>>();

		for(u64 a=0; a<entries.size(); a++)
		{
			INIEntry entry = entries.data[a];
			props.add(Pair<String<u8>, String<u8>>(String<u8>(entry.name), String<u8>(entry.val)));
		}

		return props;
	}

	// Set all entries from string pairs.
	void setAllEntries(ArrayList<Pair<String<u8>, String<u8>>> pairs)
	{
		for(u64 p=0; p<pairs.size(); p++)
		{
			INIEntry entry = INIEntry(pairs.data[p].a, pairs.data[p].b);
			setEntry(entry);
		}
	}

	// Get entries from command line arguments string. Assumes format is " program.exe nameA=valB nameB="c:\path\file.png"  " etc.
	INIFile parseCmdLineArgs(String<u8> cmdLineStr)
	{
		INIFile iniFile = INIFile();
		String<u8> emptyStr = String<u8>("");

		ArrayList<String<u8>> cmdLineArgsStrSplit = cmdLineStr.splitByWhitespaceQuotes();
		while(cmdLineArgsStrSplit.size() > 0)
		{
			String<u8> argStr = cmdLineArgsStrSplit.removeLast();

			i64 equalsIndex = argStr.findNext(Chars:EQUALS, 0);
			if(equalsIndex >= 0)
			{
				String<u8> name = argStr.subString(0, equalsIndex-1);
				String<u8> val  = argStr.subString(equalsIndex+1, argStr.length()-1);

				iniFile.setEntry(name, val);
			}
			else
			{
				
				iniFile.setEntry(argStr, emptyStr); // name with no value
			}
		}
		
		return iniFile;
	}

	// Merge two ini files. File b will overwrite file a entries if same name.
	INIFile merge(INIFile a, INIFile b)
	{
		INIFile m = INIFile();

		m.copy(a);

		for(u64 e=0; e<b.entries.size(); e++)
		{
			String<u8> name = b.entries.data[e].name;
			String<u8> val  = b.entries.data[e].val;

			m.setEntry(name, val);
		}

		return m;
	}
}