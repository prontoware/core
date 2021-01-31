////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// ProntoType
////////////////////////////////////////////////////////////////////////////////////////////////////

// Extend built-in type.
class ProntoType
{
	// String<u8> namespace;
	// String<u8> className;
	// u16 numElements;
	// u8 typeID;

	// Primitive type.
	void constructor(u8 typeID)
	{
		this.typeID      = typeID;
		this.numElements = 0;
		this.namespace   = null;
		this.className   = null;
	}

	// Vector type.
	void constructor(u8 typeID, u16 numElem)
	{
		this.typeID      = typeID;
		this.numElements = numElem;
		this.namespace   = null;
		this.className   = null;
	}

	// Class type. Can be class name or full qualified namespace::className string.
	void constructor(String<u8> fullClassName)
	{
		parse(fullClassName);
	}

	// Class type.
	void constructor(String<u8> nameSpace, String<u8> className)
	{
		this.typeID      = Type:OBJ;
		this.numElements = 0;
		this.namespace   = String<u8>(nameSpace);
		this.className   = String<u8>(className);
	}

	// Copy constructor.
	void constructor(ProntoType t)
	{
		this.typeID      = t.typeID;
		this.numElements = t.numElements;
		this.namespace   = String<u8>(t.namespace);
		this.className   = String<u8>(t.className);
	}

	// Clone
	ProntoType clone()
	{
		ProntoType c(this);
		return c;
	}

	// Get full pronto class name, i.e. "namespace::classname"
	String<u8> getFullClassName()
	{
		String<u8> fullName();

		if(namespace != null)
		{
			if(namespace.length() != 0)
			{
				fullName.append(namespace);
				fullName.append("::");
			}
		}

		fullName.append(className);

		return fullName;
	}

	// Get classname without templates (if applicable).
	String<u8> getClassNameWithoutTemplate()
	{
		if(className == null)
			return String<u8>();

		i64 angleBracketStartIndex = className.findNext(Chars:OPEN_ANGLE_BRACKET, 0);
		if(angleBracketStartIndex < 0)
			return String<u8>(className);

		return className.subString(0, angleBracketStartIndex-1);
	}

	// Is this an array?
	bool isArray()
	{
		if(className == null)
			return false;

		//String<u8> classNameNoTemplate = getClassNameWithoutTemplate();
		if(className.endsWith(String<u8>("[]")) == true)
			return true;

		return false;
	}

	// Is this the class specified?
	bool isClass(String<u8> classNameOnly)
	{
		if(className == null)
			return false;

		if(typeID != Type:OBJ)
			return false;

		if(className.compare(classNameOnly) == false)
			return false;

		return true;
	}

	// Is this the class specified?
	bool isClass(String<u8> namespaceOnly, String<u8> classNameOnly)
	{
		if(className == null)
			return false;

		if(typeID != Type:OBJ)
			return false;

		if(namespace != null && namespaceOnly != null)
		{
			if(namespace.compare(namespaceOnly) == false)
				return false;
		}

		if(className.compare(classNameOnly) == false)
			return false;

		return true;
	}

	// Get element type of this array. If this is not an array, returns Type:BADVAL.
	ProntoType getElementType()
	{
		if(isArray() == false)
			return ProntoType(Type:BADVAL);

		// String<u8>[] u16[] f32[4][] ArrayList<f32[4][]>[] etc.
		String<u8> elemStr = className.subString(0, className.length()-3);

		// array of primitives / vectors ?
		if(elemStr.chars[0] == Chars:u || elemStr.chars[0] == Chars:i || elemStr.chars[0] == Chars:f)
		{
			u8 elemID = Type:BADVAL;
			if(elemStr.beginsWith("u8")) elemID  = Type:U8;
			if(elemStr.beginsWith("i8")) elemID  = Type:I8;
			if(elemStr.beginsWith("u16")) elemID = Type:U16;
			if(elemStr.beginsWith("i16")) elemID = Type:I16;
			if(elemStr.beginsWith("u32")) elemID = Type:U32;
			if(elemStr.beginsWith("i32")) elemID = Type:I32;
			if(elemStr.beginsWith("u64")) elemID = Type:U64;
			if(elemStr.beginsWith("i64")) elemID = Type:I64;
			if(elemStr.beginsWith("f32")) elemID = Type:F32;
			if(elemStr.beginsWith("f64")) elemID = Type:F64;

			if(elemID != Type:BADVAL)
			{
				if(elemStr.length() <= 3)
					return ProntoType(elemID); // just an array of primitives

				// must be array of vectors
				i64 vecStartIndex = elemStr.findNext(Chars:OPEN_SQUARE_BRACKET, 0);
				if(vecStartIndex == -1)
					return ProntoType(Type:BADVAL); // umm

				i64 vecEndIndex = elemStr.findNext(Chars:CLOSE_SQUARE_BRACKET, 0);
				if(vecEndIndex == -1)
					return ProntoType(Type:BADVAL); // umm

				ProntoType elemType(elemID);
				elemType.numElements = elemStr.parseInteger(vecStartIndex+1, vecEndIndex-1);

				return elemType;
			}
		}

		// must be array of objects
		ProntoType objType(Type:OBJ);
		if(this.namespace != null)
			objType.namespace = String<u8>(this.namespace);
		objType.className = elemStr;

		return objType;
	}

	// Split class name from namespace. i.e. "NamespaceX::ClassY".
	void parse(String<u8> fullClassName)
	{
		this.typeID      = Type:OBJ;
		this.numElements = 0;
		this.namespace   = null;
		this.className   = null;

		i64 colonIndex = fullClassName.findNext(Chars:COLON, 0);
		if(colonIndex < 0)
		{
			this.className = String<u8>(fullClassName);
		}
		else
		{
			this.namespace = fullClassName.subString(0, colonIndex-1);
			this.className = fullClassName.subString(colonIndex+2, fullClassName.length()-1); // +2 to skip "::"
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Class
////////////////////////////////////////////////////////////////////////////////////////////////////

// Extend built-in type. Class is the central class for the Introspection API. The Introspection API
// allows dynamic object property access (read/write) amoung other class meta uses.
class Class
{
	// Get class property's type. Returns null if propName has no match.
	shared ProntoType getPropertyType(String<u8> className, String<u8> propName)
	{
		ClassProperty[] props = Class:getProperties(className);
		for(u64 c=0; c<props.length(); c++)
		{
			if(props[c].name.compare(propName) == true)
				return props[c].type;
		}

		return null;
	}
}
