////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// JSON
////////////////////////////////////////////////////////////////////////////////////////////////////

// Represents parsed JavaScript Object Notation (JSON) objects. This class acts as both the root
// element of a JSON "document" as well as all child nodes. This class supports parsing raw JSON
// text (RFC 1759) to JSON object tree, as well as serializing back to text format. Optionally can
// use XMapping system to parse/serialize from/to JSON directly to/from Pronto objects.
class JSON
{
	// Types, including primitives, objects and arrays.
	const u32 TYPE_NULL   = 0;
	const u32 TYPE_STRING = 1;
	const u32 TYPE_NUMBER = 2;
	const u32 TYPE_BOOL   = 3;
	const u32 TYPE_OBJECT = 4;
	const u32 TYPE_ARRAY  = 5;

	// Properties
	String<u8> name    = null;      // property name
	String<u8> val     = null;      // property value (primitive) - can be unused if this is a complex object
	u32    valType = TYPE_NULL; // one of TYPE_
	ArrayList<JSON> properties = null; // If this is a complex object (i.e. not a primitive) - used by valType = TYPE_OBJECT and TYPE_ARRAY
		
	// Construct NULL property.
	void constructor()
	{

	}

	// Construct named but no-value.
	void constructor(String<u8> name)
	{
		this.name     = name;
		this.val      = null;
		this.valType  = TYPE_NULL;
	}

	// Construct string property.
	void constructor(String<u8> name, String<u8> val)
	{
		this.name     = name;
		this.val      = val;
		this.valType  = TYPE_STRING;
	}

	// Construct numeric property.
	void constructor(String<u8> name, u8 val)
	{
		this.name    = name;
		this.val     = String<u8>:formatNumber(val);
		this.valType = TYPE_NUMBER;
	}

	// Construct numeric property.
	void constructor(String<u8> name, i8 val)
	{
		this.name    = name;
		this.val     = String<u8>:formatNumber(val);
		this.valType = TYPE_NUMBER;
	}

	// Construct numeric property.
	void constructor(String<u8> name, u16 val)
	{
		this.name    = name;
		this.val     = String<u8>:formatNumber(val);
		this.valType = TYPE_NUMBER;
	}

	// Construct numeric property.
	void constructor(String<u8> name, i16 val)
	{
		this.name    = name;
		this.val     = String<u8>:formatNumber(val);
		this.valType = TYPE_NUMBER;
	}

	// Construct numeric property.
	void constructor(String<u8> name, u32 val)
	{
		this.name    = name;
		this.val     = String<u8>:formatNumber(val);
		this.valType = TYPE_NUMBER;
	}

	// Construct numeric property.
	void constructor(String<u8> name, i32 val)
	{
		this.name    = name;
		this.val     = String<u8>:formatNumber(val);
		this.valType = TYPE_NUMBER;
	}

	// Construct numeric property.
	void constructor(String<u8> name, u64 val)
	{
		this.name    = name;
		this.val     = String<u8>:formatNumber(val);
		this.valType = TYPE_NUMBER;
	}

	// Construct numeric property.
	void constructor(String<u8> name, i64 val)
	{
		this.name    = name;
		this.val     = String<u8>:formatNumber(val);
		this.valType = TYPE_NUMBER;
	}

	// Construct numeric property.
	void constructor(String<u8> name, f32 val)
	{
		this.name    = name;
		this.val     = String<u8>:formatNumber(val);
		this.valType = TYPE_NUMBER;
	}

	// Construct numeric property.
	void constructor(String<u8> name, f64 val)
	{
		this.name    = name;
		this.val     = String<u8>:formatNumber(val);
		this.valType = TYPE_NUMBER;
	}

	// Construct array property.
	void constructor(String<u8> name, IArray arr)
	{
		this.name    = name;
		this.valType = TYPE_ARRAY;
	}

	// Copy-constructor.
	void constructor(JSON j)
	{
		copy(j);
	}

	// Release memory.
	void destroy()
	{
		name = null;
		val = null;
		properties= null;
	}

	// Copy passed-in.
	void copy(JSON j)
	{
		this.name     = String<u8>(j.name);
		this.val      = String<u8>(j.val);
		this.valType  = j.valType;

		if(j.properties != null)
		{
			if(this.properties == null)
				this.properties = ArrayList<JSON>();
			else
				this.properties.clear();

			for(u32 p=0; p<j.properties.size(); p++)
			{
				this.properties.add(JSON(j.properties[p]));
			}
		}
	}

	// To JSON text format. Generally RFC 7159 compliant.
	String<u8> toString()
	{
		String<u8> s(512);
		JSON:addToString(s, this, 0);

		return s;
	}

	// Does this JSON object have any properties?
	bool hasProperties()
	{
		if(this.properties == null)
			return false;

		if(this.properties.size() == 0)
			return false;

		return true;
	}

	// Allocate storage for properties if not done already.
	void initProperties()
	{
		if(this.properties != null)
			return;

		this.properties = ArrayList<JSON>();
	}

	// Does this child have a name?
	bool hasName()
	{
		if(this.name == null)
			return false;

		if(this.name.length() == 0)
			return false;

		return true;
	}

	// Append JSON object to a string. Returns passed-in string. Generally RFC 7159 compliant.
	shared String<u8> addToString(String<u8> s, JSON childObject, i32 tabCount)
	{
		if(childObject == null)
			return String<u8>("");

		String<u8> tabStr(tabCount);
		for(u32 t=0; t<tabCount; t++)
			tabStr.append(Chars:HTAB);

		if(childObject.hasProperties() == false)
		{
			if(childObject.valType == TYPE_NULL)
			{
				if(childObject.hasName())
					s.append(tabStr, String<u8>("\""), childObject.name, String<u8>("\": null"));
				else
					s.append(tabStr, String<u8>("null")); // array element (i.e. parent is an array)
			}
			else if(childObject.valType == TYPE_NUMBER || childObject.valType == TYPE_BOOL)
			{
				if(childObject.hasName())
					s.append(tabStr, String<u8>("\""), childObject.name, String<u8>("\": "), childObject.val);
				else
					s.append(tabStr, childObject.val); // array element (i.e. parent is an array)
			}
			else
			{
				String<u8> finalVal = childObject.val;
				// escape quotes etc.
				finalVal.replaceAll(String<u8>("\\"), String<u8>("\\\\")); // escape back slashes
				finalVal.replaceAll(String<u8>("\""), String<u8>("\\\"")); // espace double quotes

				if(childObject.hasName())
				{
					s.append(tabStr, String<u8>("\""), childObject.name, String<u8>("\": "));
					s.append(String<u8>("\""), finalVal, String<u8>("\""));
				}
				else
				{
					s.append(tabStr, String<u8>("\""), finalVal, String<u8>("\"")); // array element (i.e. parent is an array)
				}
			}
		}
		else
		{
			bool inlineArray = false;
			if(childObject.hasProperties() && childObject.isArray() == true)
			{
				if(childObject.properties[0] != null)
				{
					if(childObject.properties[0].valType == TYPE_NUMBER || childObject.properties[0].valType == TYPE_BOOL)
						inlineArray = true;
				}
			}

			if(childObject.hasName())
			{
				if(inlineArray == true)
					s.append(tabStr, String<u8>("\""), childObject.name, String<u8>("\": "));
				else
					s.append(tabStr, String<u8>("\""), childObject.name, String<u8>("\": \n"));
			}
			else
				s.append(tabStr); // array element (i.e. parent is an array)

			
			if(childObject.isArray() == false)
				s.append(tabStr, String<u8>("{\n"));
			else
			{
				if(inlineArray == true)
					s.append(String<u8>("[ "));
				else
					s.append(tabStr, String<u8>("[\n"));
			}

			if(childObject.hasProperties())
			{
				for(u64 p=0; p<childObject.properties.size(); p++)
				{
					if(childObject.properties[p] == null)
						continue;

					if(inlineArray == true)
						addToString(s, childObject.properties[p], 0);
					else
						addToString(s, childObject.properties[p], tabCount + 1);

					if(p < childObject.properties.size()-1)
					{
						if(childObject.isArray() == false)
						{
							s.append(",\n");
						}
						else
						{
							if(inlineArray == true)
								s.append(", "); // no newline
							else
								s.append(",\n");
						}
					}
				}
			}

			if(childObject.isArray() == false)
				s.append(String<u8>("\n"), tabStr, String<u8>("}"));
			else
			{
				if(inlineArray == true)
					s.append(String<u8>(" ]"));
				else
					s.append(String<u8>("\n"), tabStr, String<u8>("]"));
			}
		}

		return s;
	}

	// Is array?
	bool isArray()
	{
		if(valType == TYPE_ARRAY)
			return true;

		return false;
	}

	// Returns false if not found.
	bool hasProperty(String<u8> name)
	{
		for(u32 p=0; p<properties.size(); p++)
		{
			if(properties[p].name.compare(name))
				return true;
		}

		return false;
	}

	// Returns null if not found.
	JSON getProperty(String<u8> name)
	{
		if(properties == null)
			return null;

		for(u32 p=0; p<properties.size(); p++)
		{
			if(properties[p].name.compare(name))
				return properties[p];
		}

		return null;
	}

	// Get property by zero-based index. Returns null if out of range.
	JSON getProperty(u64 index)
	{
		if(properties == null)
			return null;

		if(index < 0 || index >= properties.size())
			return null;

		return properties[index];
	}

	// Append a property.
	void addProperty(JSON val)
	{
		if(properties == null)
			properties = ArrayList<JSON>();

		properties.add(val);
	}

	// Append a property.
	void addProperty(String<u8> propName, String<u8> propVal) { initProperties(); properties.add(JSON(propName, propVal)); }

	// Append a numeric property.
	void addProperty(String<u8> propName, u8 propVal) { initProperties(); properties.add(JSON(propName, propVal)); }

	// Append a numeric property.
	void addProperty(String<u8> propName, i8 propVal) { initProperties(); properties.add(JSON(propName, propVal)); }

	// Append a numeric property.
	void addProperty(String<u8> propName, u16 propVal) { initProperties(); properties.add(JSON(propName, propVal)); }

	// Append a numeric property.
	void addProperty(String<u8> propName, i16 propVal) { initProperties(); properties.add(JSON(propName, propVal)); }

	// Append a numeric property.
	void addProperty(String<u8> propName, u32 propVal) { initProperties(); properties.add(JSON(propName, propVal)); }

	// Append a numeric property.
	void addProperty(String<u8> propName, i32 propVal) { initProperties(); properties.add(JSON(propName, propVal)); }

	// Append a numeric property.
	void addProperty(String<u8> propName, u64 propVal) { initProperties(); properties.add(JSON(propName, propVal)); }

	// Append a numeric property.
	void addProperty(String<u8> propName, i64 propVal) { initProperties(); properties.add(JSON(propName, propVal)); }

	// Append a numeric property.
	void addProperty(String<u8> propName, f32 propVal) { initProperties(); properties.add(JSON(propName, propVal)); }

	// Append a numeric property.
	void addProperty(String<u8> propName, f64 propVal) { initProperties(); properties.add(JSON(propName, propVal)); }

	// Append a string element.
	void addElement(String<u8> propVal) { initProperties(); properties.add(JSON(null, propVal)); }

	// Append a numeric element.
	void addElement(u8 propVal) { initProperties(); properties.add(JSON(null, propVal)); }

	// Append a numeric element.
	void addElement(i8 propVal) { initProperties(); properties.add(JSON(null, propVal)); }

	// Append a numeric element.
	void addElement(u16 propVal) { initProperties(); properties.add(JSON(null, propVal)); }

	// Append a numeric element.
	void addElement(i16 propVal) { initProperties(); properties.add(JSON(null, propVal)); }

	// Append a numeric element.
	void addElement(u32 propVal) { initProperties(); properties.add(JSON(null, propVal)); }

	// Append a numeric element.
	void addElement(i32 propVal) { initProperties(); properties.add(JSON(null, propVal)); }

	// Append a numeric element.
	void addElement(u64 propVal) { initProperties(); properties.add(JSON(null, propVal)); }

	// Append a numeric element.
	void addElement(i64 propVal) { initProperties(); properties.add(JSON(null, propVal)); }

	// Append a numeric element.
	void addElement(f32 propVal) { initProperties(); properties.add(JSON(null, propVal)); }

	// Append a numeric element.
	void addElement(f64 propVal) { initProperties(); properties.add(JSON(null, propVal)); }

	// Append an object element.
	void addElement(JSON propVal) { initProperties(); properties.add(propVal); }

	// Add primitive (scalar or vector) array elements to this.
	void addArrayElements(IArray arr)
	{
		ProntoType arrayType(arr.getClassName());
		ProntoType elemType = arrayType.getElementType();

		if(elemType.typeID == Type:OBJ)
			return;

		// add each element
		u32 numVecElem = Math:max(1, elemType.numElements);
		for(u64 a=0; a<arr.length(); a++)
		{
			for(u64 v=0; v<numVecElem; v++)
			{
				if(elemType.typeID == Type:U8)
					addElement(Array:getElementU8(arr, a, v));
				else if(elemType.typeID == Type:I8)
					addElement(Array:getElementI8(arr, a, v));
				else if(elemType.typeID == Type:U16)
					addElement(Array:getElementU16(arr, a, v));
				else if(elemType.typeID == Type:I16)
					addElement(Array:getElementI16(arr, a, v));
				else if(elemType.typeID == Type:U32)
					addElement(Array:getElementU32(arr, a, v));
				else if(elemType.typeID == Type:I32)
					addElement(Array:getElementI32(arr, a, v));
				else if(elemType.typeID == Type:U64)
					addElement(Array:getElementU64(arr, a, v));
				else if(elemType.typeID == Type:I64)
					addElement(Array:getElementI64(arr, a, v));
				else if(elemType.typeID == Type:F32)
					addElement(Array:getElementF32(arr, a, v));
				else if(elemType.typeID == Type:F64)
					addElement(Array:getElementF64(arr, a, v));
			}
		}
	}

	// Get value as string of this property. Returns null if not set.
	String<u8> getString()
	{
		return val;
	}

	// Get value as boolean of this property.
	bool getBool()
	{
		if(val == null)
			return false;

		String<u8> valLow(val);
		valLow.toLowercase();

		if(valLow.compare("true"))
			return true;

		return false;
	}

	// Get value as float of this property.
	f64 getFloat()
	{
		if(val == null)
			return 0.0;

		return val.parseFloat();
	}

	// Get value as integer of this property.
	i64 getInteger()
	{
		if(val == null)
			return 0;

		return val.parseInteger();
	}

	// Parse JSON raw text into JSON tree.
	shared JSON parse(String<u8> s, String<u8> errOut)
	{
		// Example
		//{"menu": {
		//	"id": "file",
		//	"value" : "File",
		//	"popup" : {
		//	"menuitem": [
		//	{"value": "New", "onclick" : "CreateNewDoc()"},
		//	{"value": "Open", "onclick" : "OpenDoc()"},
		//	{"value": "Close", "onclick" : "CloseDoc()"}
		//	]
		//	}
		//}}

		JSON jsonObj();

		// find start of object
		i64 nextStartObjIndex = s.findNext(Chars:OPEN_BRACE, 0);
		i64 nextStartArrIndex = s.findNext(Chars:OPEN_SQUARE_BRACKET, 0);
		if(nextStartObjIndex == -1 && nextStartArrIndex == -1)
		{
			errOut.append("No braces, so no valid JSON!\n");
			return jsonObj;
		}

		// top level is object or array?
		if((nextStartObjIndex != -1 && nextStartObjIndex < nextStartArrIndex) || nextStartArrIndex == -1)
		{
			// object
			jsonObj.valType = JSON:TYPE_OBJECT;
			i32 endObjIndex = s.findPairEnd(Chars:OPEN_BRACE, Chars:CLOSE_BRACE, nextStartObjIndex, s.length()-1);
			if(endObjIndex == -1)
			{
				errOut.append("No end brace to top-level object, so no valid JSON!\n");
				return jsonObj;
			}

			String<u8> childStr = s.subString(nextStartObjIndex+1, endObjIndex-1);

			// recursively parse rest
			parse(childStr, jsonObj, errOut);
		}
		else
		{
			// array
			jsonObj.valType = JSON:TYPE_ARRAY;
			i32 endArrIndex = s.findPairEnd(Chars:OPEN_SQUARE_BRACKET, Chars:CLOSE_SQUARE_BRACKET, nextStartArrIndex, s.length()-1);
			if(endArrIndex == -1)
			{
				errOut.append("No end sq brace to top-level array, so no valid JSON!\n");
				return jsonObj;
			}

			String<u8> childStr = s.subString(nextStartArrIndex+1, endArrIndex-1);

			// recursively parse rest
			parse(childStr, jsonObj, errOut);
		}
		
		if(errOut.length() > 0)
			errOut.append("\n\n");

		return jsonObj;
	}

	// Parse JSON, called recursively for each object in tree.
	shared void parse(String<u8> s, JSON parentObj, String<u8> errOut)
	{
		// parse properties of this object
		i32 curChIndex = 0;
		while(curChIndex < s.length())
		{
			i32 nextChIndex = s.findNextNonWhitespace(curChIndex);
			if(nextChIndex == -1)
				break;

			if(parentObj.isArray() == false)
			{
				if(s.chars[nextChIndex] == Chars:DOUBLE_QUOTE)
				{
					// must be property name, example:
					// "id": "val"
					i32 endIndex = s.findNext(Chars:DOUBLE_QUOTE, nextChIndex+1);
					if(endIndex == -1)
					{
						errOut.append(String<u8>("Failed to find end of property name starting at index: "), String<u8>:formatNumber(nextChIndex));
						return;
					}

					String<u8> propName = s.subString(nextChIndex+1, endIndex-1);
				
					i32 colonIndex = s.findNext(Chars:COLON, endIndex+1);
					if(colonIndex == -1)
					{
						errOut.append(String<u8>("Failed to find colon after property name: "), propName);
						return;
					}

					i32 valStartIndex = s.findNextNonWhitespace(colonIndex+1);
					if(valStartIndex == -1)
					{
						errOut.append(String<u8>("Failed to find val after colon for property name: "), propName);
						return;
					}

					if(s.chars[valStartIndex] == Chars:OPEN_BRACE)
					{
						// another JSON obj
						i32 newObjEndIndex = s.findPairEnd(Chars:OPEN_BRACE, Chars:CLOSE_BRACE, valStartIndex, s.length()-1);
						if(newObjEndIndex == -1)
						{
							errOut.append(String<u8>("Failed to find end brace after colon for property name: "), propName);
							return;
						}

						String<u8> childObjStr = s.subString(valStartIndex+1, newObjEndIndex-1);
						JSON newChildObj();
						newChildObj.name    = propName;
						newChildObj.valType = JSON:TYPE_OBJECT;
						parse(childObjStr, newChildObj, errOut);
						parentObj.addProperty(newChildObj); // after parse so we have props

						i32 commaIndex = s.findNext(Chars:COMMA, newObjEndIndex+1);
						if(commaIndex == -1)
						{
							// last property of this object
							return;
						}

						curChIndex = commaIndex+1;
					}
					else if(s.chars[valStartIndex] == Chars:OPEN_SQUARE_BRACKET)
					{
						// array
						i32 newObjEndIndex = s.findPairEnd(Chars:OPEN_SQUARE_BRACKET, Chars:CLOSE_SQUARE_BRACKET, valStartIndex, s.length()-1);
						if(newObjEndIndex == -1)
						{
							errOut.append(String<u8>("Failed to find end sq bracket after colon for property name: "), propName);
							return;
						}

						String<u8> childObjStr = s.subString(valStartIndex+1, newObjEndIndex-1);
						JSON newChildObj();
						newChildObj.name     = propName;
						newChildObj.valType  = JSON:TYPE_ARRAY;
						parse(childObjStr, newChildObj, errOut);
						parentObj.addProperty(newChildObj); // after parse so we have props

						i32 commaIndex = s.findNext(Chars:COMMA, newObjEndIndex+1);
						if(commaIndex == -1)
						{
							// last property of this object
							return;
						}

						curChIndex = commaIndex+1;

						//errOut += String<u8>("Can't parse arrays yet!") + nextChIndex;
						return;
					}
					else if(s.chars[valStartIndex] == Chars:DOUBLE_QUOTE)
					{
						// must be a string
						i32 endOfValIndex = s.findNext(Chars:DOUBLE_QUOTE, valStartIndex+1);
						if(endOfValIndex == -1)
						{
							errOut.append(String<u8>("Failed to find end quote for value for property name: "), propName);
							return;
						}

						String<u8> strVal = s.subString(valStartIndex+1, endOfValIndex-1);

						JSON newChildObj();
						newChildObj.valType = JSON:TYPE_STRING;
						newChildObj.name    = propName;
						newChildObj.val     = strVal;
						parentObj.addProperty(newChildObj);

						i32 commaIndex = s.findNext(Chars:COMMA, endOfValIndex+1);
						if(commaIndex == -1)
						{
							// last property of this object
							return;
						}

						curChIndex = commaIndex+1;
					}
					else
					{
						// must be a number, bool or null etc?
						i32 closestCommaIndex = s.findNext(Chars:COMMA, valStartIndex+1);
						i32 closestWhiteIndex = s.findNextWhitespace(valStartIndex+1);
						i32 endOfValIndex = closestCommaIndex;
						if(endOfValIndex == -1 || closestWhiteIndex < closestCommaIndex)
							endOfValIndex = closestWhiteIndex;

						if(endOfValIndex == -1)
						{
							errOut.append(String<u8>("Failed to find end of value (number/bool) for property name: "), propName);
							return;
						}

						String<u8> strVal = s.subString(valStartIndex, endOfValIndex-1);

						JSON newChildObj();
						newChildObj.name    = propName;
						newChildObj.val     = strVal;
						newChildObj.valType = JSON:TYPE_NUMBER;

						// check if type is bool instead of number
						String<u8> valLower(strVal);
						valLower.toLowercase();
						if(valLower.compare("true") || valLower.compare("false"))
							newChildObj.valType = JSON:TYPE_BOOL;

						// check if type is null instead of number
						if(valLower.compare("null"))
							newChildObj.valType = JSON:TYPE_NULL;

						parentObj.addProperty(newChildObj);

						if(closestCommaIndex == -1)
						{
							// last property of this object
							return;
						}

						curChIndex = closestCommaIndex + 1;
					}
				}
				else
				{
					errOut.append(String<u8>("Unknown property issue. "));
					errOut.append(String<u8>("JSON string: "), s);
					return;
				}
			}
			else
			{
				if(s.chars[nextChIndex] == Chars:OPEN_BRACE)
				{
					// object literal, must be a object in an array?
					if(parentObj.isArray() == false)
					{
						errOut.append(String<u8>("Object literal found in properties of object that isn't array: "), parentObj.name);
						return;
					}

					// another JSON obj
					i32 newObjEndIndex = s.findPairEnd(Chars:OPEN_BRACE, Chars:CLOSE_BRACE, nextChIndex, s.length()-1);
					if(newObjEndIndex == -1)
					{
						errOut.append(String<u8>("Failed to find end brace after colon for property name: "), parentObj.name);
						return;
					}

					String<u8> childObjStr = s.subString(nextChIndex+1, newObjEndIndex-1);
					JSON newChildObj();
					newChildObj.valType = JSON:TYPE_OBJECT;
					// newChildObj.name = propName; no name of this "object" because this is just an element in an array
					parse(childObjStr, newChildObj, errOut);
					parentObj.addProperty(newChildObj); // after parse so we have props

					i32 commaIndex = s.findNext(Chars:COMMA, newObjEndIndex+1);
					if(commaIndex == -1)
					{
						// last property of this object
						return;
					}

					curChIndex = commaIndex+1;
				}
				else if(s.chars[nextChIndex] == Chars:DOUBLE_QUOTE) // single quotes aren't valid JSON || s.chars[nextChIndex] == Chars:SINGLE_QUOTE)
				{
					// string value
					i32 endIndex = s.findNext(Chars:DOUBLE_QUOTE, nextChIndex+1);
					if(endIndex == -1)
					{
						errOut.append(String<u8>("Failed to find end of string literal in array: "), parentObj.name);
						return;
					}

					String<u8> strVal = s.subString(nextChIndex+1, endIndex-1);
					JSON newChildObj(String<u8>(""), strVal);
					newChildObj.valType = JSON:TYPE_STRING;
					parentObj.addProperty(newChildObj);

					// next
					i32 commaIndex = s.findNext(Chars:COMMA, nextChIndex+1);
					if(commaIndex == -1)
					{
						// last property of this object
						return;
					}

					curChIndex = commaIndex+1;
				}
				else if(s.chars[nextChIndex] == Chars:n)
				{
					// null property, i.e. arrays can have null
					JSON newChildObj(String<u8>(""), String<u8>(""));
					newChildObj.valType = JSON:TYPE_NULL;
					parentObj.addProperty(newChildObj);

					i32 commaIndex = s.findNext(Chars:COMMA, nextChIndex+1);
					if(commaIndex == -1)
					{
						// last property of this object
						return;
					}

					curChIndex = commaIndex+1;
				}
				else if(s.chars[nextChIndex] == Chars:COMMA)
				{
					// empty array element
					JSON newChildObj(String<u8>(""), String<u8>(""));
					newChildObj.valType = JSON:TYPE_NULL;
					parentObj.addProperty(newChildObj);

					curChIndex = nextChIndex+1;
				}
				else
				{
					// must be a number, bool etc?
					i32 closestCommaIndex = s.findNext(Chars:COMMA, nextChIndex+1);
					i32 closestWhiteIndex = s.findNextWhitespace(nextChIndex+1);
					i32 endOfValIndex = closestCommaIndex;
					if(endOfValIndex == -1 || closestWhiteIndex < closestCommaIndex)
						endOfValIndex = closestWhiteIndex;

					if(endOfValIndex == -1)
					{
						errOut.append(String<u8>("Failed to find end of value (number/bool) for array element of array: "), parentObj.name);
						return;
					}

					String<u8> strVal = s.subString(nextChIndex, endOfValIndex-1);

					JSON newChildObj();
					newChildObj.name    = String<u8>(""); // array element, not a property with a name
					newChildObj.val     = strVal;
					newChildObj.valType = JSON:TYPE_NUMBER;

					// check if type is bool instead of number
					String<u8> valLower(strVal);
					valLower.toLowercase();
					if(valLower.compare("true") || valLower.compare("false"))
						newChildObj.valType = JSON:TYPE_BOOL;

					parentObj.addProperty(newChildObj);

					if(closestCommaIndex == -1)
					{
						// last property of this object
						return;
					}

					curChIndex = closestCommaIndex + 1;
				}
			}
		}
	}

	// Write the properties of the passed-in object and all of it's connected objects to an JSON tree.
	shared JSON objToJSON(IObj obj)
	{
		XMapping tempMapping();
		JSON doc = objToJSON(obj, tempMapping);
		return doc;
	}

	// Write the properties of the passed-in object and all of it's connected objects to an JSON tree.
	shared JSON objToJSON(IObj obj, XMapping mapping)
	{
		JSON jsonRoot();

		ProntoType rootObjType(obj.getClassName());
		String<u8> rootClassName = rootObjType.className;
		String<u8> rootJSONName  = rootClassName;
		ProntoType rootClass = ProntoType(rootClassName);
		XClassMapping rootClassMapping = mapping.getClassPronto(rootClass.namespace, rootClass.className);
		if(rootClassMapping != null)
		{
			if(rootClassMapping.mapAs == XPropertyMapping:MAP_AS_EXCLUDED)
				return jsonRoot; // weird, but we follow

			rootJSONName = rootClassMapping.xName;
		}

		jsonRoot.name = XClassMapping:classNameToXName(rootJSONName.clone());
		jsonRoot.valType = JSON:TYPE_OBJECT;

		ProntoType objType = ProntoType(obj.getClassName());
		if(objType.isArray() == true)
			jsonRoot.valType = JSON:TYPE_ARRAY;

		objOrArrayToJSON(obj, mapping, jsonRoot);

		return jsonRoot;
	}

	// Write the properties of the passed-in object and all of it's connected objects to an JSON tree.
	shared void objOrArrayToJSON(IObj obj, XMapping mapping, JSON parentElement)
	{
		if(obj == null || parentElement == null)
			return;

		ProntoType objType = ProntoType(obj.getClassName());
		if(objType.isArray() == true)
		{
			IArray arr = obj;
			arrayToJSON(arr, mapping, parentElement);
		}
		else
		{
			objToJSON(obj, mapping, parentElement);
		}
	}

	// Create the elements of the passed-in array and place in parentElement.
	shared void arrayToJSON(IArray arr, XMapping mapping, JSON parentElement)
	{
		if(arr == null || parentElement == null)
			return;

		if(parentElement.valType != JSON:TYPE_ARRAY)
		{
			assert(false);
			return;
		}

		if(arr.length() == 0)
			return;

		ProntoType arrayType = ProntoType(arr.getClassName());

		XClassMapping clsMapping = mapping.getClassPronto(arrayType.namespace, arrayType.className);
		if(clsMapping == null)
			clsMapping = XClassMapping(arrayType.namespace, arrayType.className, arrayType.className);

		if(clsMapping.mapAs == XPropertyMapping:MAP_AS_EXCLUDED)
			return;

		ProntoType arrayElemType = arrayType.getElementType();
		if(arrayElemType.typeID == Type:OBJ) // array of objects
		{
			for(u64 a=0; a<arr.length(); a++)
			{
				// Use class name for each element (or json mapped name).
				IObj elemObj = Array:getElementObj(arr, a);
				if(elemObj == null)
					continue; // skip

				// Array could be IObj[] with each element being different class like String, Cat, Dog etc.
				ProntoType elemType = ProntoType(elemObj.getClassName());

				XClassMapping elemClassMapping = mapping.getClassPronto(elemType.namespace, elemType.className);
				if(elemClassMapping == null)
					elemClassMapping = XClassMapping(elemType.namespace, elemType.className, elemType.className);

				String<u8> jName = XClassMapping:classNameToXName(elemClassMapping.xName);
				JSON arrElementJSONObj(jName);
				arrElementJSONObj.valType = JSON:TYPE_OBJECT;
				arrElementJSONObj.initProperties();
				objOrArrayToJSON(elemObj, mapping, arrElementJSONObj);

				parentElement.addElement(arrElementJSONObj);
			}
		}
		else // array of primitives or vectors
		{
			parentElement.addArrayElements(arr); // elements added automatically
		}
	}

	// Write the class-name element and properties of the passed-in object and all of it's connected objects to the JSON tree.
	shared void objToJSON(IObj obj, XMapping mapping, JSON parentElement)
	{
		if(obj == null || parentElement == null)
			return;

		ProntoType objType = ProntoType(obj.getClassName());

		XClassMapping clsMapping = mapping.getClassPronto(objType.namespace, objType.className);
		if(clsMapping == null)
			clsMapping = XClassMapping(objType.namespace, objType.className, objType.className);

		if(clsMapping.mapAs == XPropertyMapping:MAP_AS_EXCLUDED)
			return;

		// special handling of String<u8> class
		if(objType.className.compare("String<u8>") == true)
		{
			String<u8> objStr = obj;
			parentElement.valType = JSON:TYPE_STRING;
			parentElement.val     = String<u8>(objStr);
			return;
		}

		ClassProperty[] classProps = Class:getProperties(obj.getClassName());
		for(u64 p=0; p<classProps.length(); p++)
		{
			ClassProperty prop = classProps[p];

			XPropertyMapping propMapping = clsMapping.getPropertyPronto(prop.name);
			if(propMapping == null)
				propMapping = XPropertyMapping(prop.name, prop.type);

			if(propMapping.mapAs == XPropertyMapping:MAP_AS_EXCLUDED)
				continue; // skip

			if(prop.type.typeID == Type:OBJ)
			{
				IObj childObj = Class:getPropertyValueObj(obj, prop.name);
				if(childObj != null)
				{
					ProntoType childObjType(childObj.getClassName());

					JSON jsonObj(propMapping.xName);
					jsonObj.valType = JSON:TYPE_OBJECT;
					if(childObjType.isArray())
						jsonObj.valType = JSON:TYPE_ARRAY;

					objOrArrayToJSON(childObj, mapping, jsonObj);

					parentElement.addProperty(jsonObj);
				}
			}
			else // primitive scalar or vector
			{
				if(prop.type.numElements <= 1) // scalar
				{
					if(prop.type.typeID == Type:U8)
						parentElement.addProperty(propMapping.xName, Class:getPropertyValueU8(obj, prop.name));
					else if(prop.type.typeID == Type:I8)
						parentElement.addProperty(propMapping.xName, Class:getPropertyValueI8(obj, prop.name));
					else if(prop.type.typeID == Type:U16)
						parentElement.addProperty(propMapping.xName, Class:getPropertyValueU16(obj, prop.name));
					else if(prop.type.typeID == Type:I16)
						parentElement.addProperty(propMapping.xName, Class:getPropertyValueI16(obj, prop.name));
					else if(prop.type.typeID == Type:U32)
						parentElement.addProperty(propMapping.xName, Class:getPropertyValueU32(obj, prop.name));
					else if(prop.type.typeID == Type:I32)
						parentElement.addProperty(propMapping.xName, Class:getPropertyValueI32(obj, prop.name));
					else if(prop.type.typeID == Type:U64)
						parentElement.addProperty(propMapping.xName, Class:getPropertyValueU64(obj, prop.name));
					else if(prop.type.typeID == Type:I64)
						parentElement.addProperty(propMapping.xName, Class:getPropertyValueI64(obj, prop.name));
					else if(prop.type.typeID == Type:F32)
						parentElement.addProperty(propMapping.xName, Class:getPropertyValueF32(obj, prop.name));
					else if(prop.type.typeID == Type:F64)
						parentElement.addProperty(propMapping.xName, Class:getPropertyValueF64(obj, prop.name));
					else
						assert(false);
				}
				else // vector
				{
					JSON vecJSON(propMapping.xName);
					vecJSON.valType = JSON:TYPE_ARRAY;
					for(u64 v=0; v<prop.type.numElements; v++)
					{
						if(prop.type.typeID == Type:U8)
							vecJSON.addElement(Class:getPropertyValueU8(obj, prop.name, v));
						else if(prop.type.typeID == Type:I8)
							vecJSON.addElement(Class:getPropertyValueI8(obj, prop.name, v));
						else if(prop.type.typeID == Type:U16)
							vecJSON.addElement(Class:getPropertyValueU16(obj, prop.name, v));
						else if(prop.type.typeID == Type:I16)
							vecJSON.addElement(Class:getPropertyValueI16(obj, prop.name, v));
						else if(prop.type.typeID == Type:U32)
							vecJSON.addElement(Class:getPropertyValueU32(obj, prop.name, v));
						else if(prop.type.typeID == Type:I32)
							vecJSON.addElement(Class:getPropertyValueI32(obj, prop.name, v));
						else if(prop.type.typeID == Type:U64)
							vecJSON.addElement(Class:getPropertyValueU64(obj, prop.name, v));
						else if(prop.type.typeID == Type:I64)
							vecJSON.addElement(Class:getPropertyValueI64(obj, prop.name, v));
						else if(prop.type.typeID == Type:F32)
							vecJSON.addElement(Class:getPropertyValueF32(obj, prop.name, v));
						else if(prop.type.typeID == Type:F64)
							vecJSON.addElement(Class:getPropertyValueF64(obj, prop.name, v));
						else
							assert(false);
					}
					parentElement.addProperty(vecJSON);
				}
			}
		}
	}

	// Read the JSON values into a tree of Pronto objects. Pronto will automatically
	// match elements with releveants classes.
	shared ArrayList<IObj> jsonToObj(JSON jsonDoc)
	{
		XMapping mapping(); // default mapping will be filled-in as we go
		return jsonToObj(mapping, jsonDoc);
	}

	// Read the JSON values into a tree of Pronto objects. You provide some (or all) possible objects 
	// class names that could be mapped from the JSON to Pronto objects and this algorithm determines
	// matches based on JSON element names and object class/property names. It's a little bit of
	// dynamic magic.
	shared ArrayList<IObj> jsonToObj(XMapping mapping, JSON jsonDoc)
	{
		ArrayList<IObj> objRoots();
		if(jsonDoc == null)
			return objRoots;

		// Build up a list of all class properties (do it once for efficency)
		for(u64 c=0; c<mapping.classes.size(); c++)
			mapping.classes[c].mapMissingProperties();

		// Process JSON document root
		IObj obj = jsonToObj(mapping, null, jsonDoc);
		if(obj != null)
			objRoots.add(obj);
		
		return objRoots;
	}

	// Process JSON element. clsMapping can be null, in which case a class mapping will be auto-selected (if possible).
	shared IObj jsonToObj(XMapping mapping, XClassMapping clsMapping, JSON jsonElem)
	{
		if(jsonElem == null)
			return null;

		// pick the best class that matches this element
		if(clsMapping == null)
		{
			if(jsonElem.name != null)
			{
				clsMapping = mapping.getClass(jsonElem.name);
				if(clsMapping == null)
				{
					// try to create a new class mapping
					String<u8> useClassName = XClassMapping:classNameFromXName(jsonElem.name);
					IObj unknownObj = Class:createObj(useClassName);
					if(unknownObj != null)
					{
						ProntoType newClassType(unknownObj.getClassName());
						if(newClassType.namespace == null)
							newClassType.namespace = String<u8>();

						XClassMapping newClassMapping(newClassType.namespace, newClassType.className, newClassType.className.clone());

						newClassMapping.mapMissingProperties();
						mapping.addClass(newClassMapping);

						clsMapping = newClassMapping;
					}
				}
			}
		}

		if(clsMapping == null)
			return null; // we have no idea what to map this JSON to

		// map child elements to properties of this class
		String<u8> clsName = clsMapping.getFullClassName();
		ProntoType clsType(clsName);

		IObj obj = null;
		if(clsType.isArray())
		{
			ProntoType clsElemType = clsType.getElementType();
			if(clsElemType.typeID == Type:OBJ)
			{
				// special handling of this
				ArrayList<IObj> tempList();

				// process each child element as object
				if(jsonElem.hasProperties())
				{
					for(u64 c=0; c<jsonElem.properties.size(); c++)
					{
						IObj childObj = jsonToObj(mapping, null, jsonElem.properties[c]);
						if(childObj != null)
							tempList.add(childObj);
					}
				}

				// create array
				obj = Class:createArray(clsName, tempList.size());
				if(obj == null)
					return null;

				IObj[] objs = obj;
				if(objs == null)
					return null;

				// add objects
				for(u64 a=0; a<tempList.size(); a++)
				{
					objs[a] = tempList[a];
				}

				return obj;
			}
			else // array of primitive scalars/vectors
			{
				if(jsonElem.hasProperties())
				{
					String<u8> arrValsStr = null;
					if(jsonElem.properties.size() == 1)
					{
						if(jsonElem.properties[0].val != null)
						{
							arrValsStr = String<u8>(jsonElem.properties[0].val);
						}
					}

					if(arrValsStr != null)
					{
						IArray arr = XMappingUtils:stringToArray(clsType, arrValsStr);
						return arr;
					}
					else // parse each JSON element as a single value
					{
						ProntoType elemType = clsType.getElementType();
						u64 arrNumElem = jsonElem.properties.size();
						if(elemType.numElements > 1)
							arrNumElem /= elemType.numElements;

						IArray arr = Class:createArray(clsType.getFullClassName(), arrNumElem);
						if(arr == null)
							return null;

						for(u64 c=0; c<jsonElem.properties.size(); c++)
						{
							JSON valTagElem = jsonElem.properties[c];
							if(valTagElem == null)
								continue;

							String<u8> valStr = null;
							if(valTagElem.val != null)
								valStr = valTagElem.val;
							else if(valTagElem.hasProperties() == true)
								valStr = valTagElem.properties[0].val;

							if(valStr == null)
								continue;
						
							u64 e = c;
							u64 v = 0;
							if(elemType.numElements > 1) // vector
							{
								e = c / elemType.numElements;
								v = c % elemType.numElements;
							}

							XMappingUtils:setArrayElementFromString(arr, elemType, e, v, valStr);
						}

						return arr;
					}
				}
			}

			obj = Class:createObj(clsName);
			if(obj == null)
				return null; // wtf

			jsonChildElementsToObjProps(mapping, clsMapping, jsonElem, obj);
			
			return obj;
		}

		if(clsName.compare("String<u8>") == true)
		{
			if(jsonElem.val != null)
				return String<u8>(jsonElem.val);

			return String<u8>();
		}

		obj = Class:createObj(clsName);
		if(obj == null)
			return null; // wtf

		jsonChildElementsToObjProps(mapping, clsMapping, jsonElem, obj);
		
		return obj;
	}

	// Map attributes of JSON to a pronto object's properties (where match found).
	shared void jsonChildElementsToObjProps(XMapping mapping, XClassMapping clsMapping, JSON jsonElem, IObj obj)
	{
		if(jsonElem == null || clsMapping == null)
			return;

		if(jsonElem.hasProperties() == false)
			return;

		for(u64 c=0; c<jsonElem.properties.size(); c++)
		{
			// find match
			XPropertyMapping propMapping = null;

			JSON childElem = jsonElem.properties[c];
			if(childElem == null)
				continue;

			if(childElem.name == null)
				continue;

		
			propMapping = clsMapping.getProperty(childElem.name);
			if(propMapping == null)
				continue; // nothing we can do

			if(propMapping.type == null)
				continue;

			if(propMapping.type.typeID == Type:OBJ)
			{
				if(propMapping.type.isClass(String<u8>("String<u8>")) == true)
				{
					Class:setPropertyValueObj(obj, propMapping.propName, String<u8>(childElem.val));
					continue;
				}

				XClassMapping propertyClassMapping = mapping.getClass(propMapping.type.className);
				if(propertyClassMapping == null)
					propertyClassMapping = mapping.getClass(childElem.name);

				if(propertyClassMapping == null)
				{
					// try to create a new class mapping
					IObj unknownObj = Class:createObj(XClassMapping:classNameFromXName(propMapping.type.className));
					if(unknownObj == null)
						unknownObj = Class:createObj(XClassMapping:classNameFromXName(childElem.name));

					if(unknownObj != null)
					{
						ProntoType newClassType(unknownObj.getClassName());
						if(newClassType.namespace == null)
							newClassType.namespace = String<u8>();

						XClassMapping newClassMapping(newClassType.namespace, newClassType.className, newClassType.className.clone());

						newClassMapping.mapMissingProperties();
						mapping.addClass(newClassMapping);

						propertyClassMapping = newClassMapping;
					}
				}

				if(propertyClassMapping == null)
					continue; // nothing we can do

				IObj parsedPropObj = jsonToObj(mapping, propertyClassMapping, childElem);

				Class:setPropertyValueObj(obj, propMapping.propName, parsedPropObj);
			}
			else // scalar or vector
			{
				String<u8> valStr = null;

				if(childElem.val != null)
					valStr = childElem.val;
				else if(childElem.hasProperties() == true)
				{
					if(childElem.properties[0].val != null)
						valStr = childElem.properties[0].val;
				}

				if(valStr != null)
				{
					XMappingUtils:setPropertyFromString(obj, propMapping.propName, propMapping.type, valStr);
				}
			}
		}	
	}
}