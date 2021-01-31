////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// XPropertyMapping
////////////////////////////////////////////////////////////////////////////////////////////////////

// Describes how to map a Pronto object property to/from XML/JSON.
class XPropertyMapping
{
	const u8 MAP_AS_ELEMENT       = 0;
	const u8 MAP_AS_ATTRIBUTE     = 1; // when exporting, make this an attribute of the parent element
	const u8 MAP_AS_CHILDREN_ONLY = 2; // when exporting class, export it's properties only
	const u8 MAP_AS_EXCLUDED      = 3; // don't export class/property

	String<u8> propName  = null;
	String<u8> xName     = null;
	u8         mapAs     = MAP_AS_ELEMENT;
	ProntoType type      = null; // optional, the value type expected

	// Pronto name and x-mapping name same.
	void constructor(String<u8> propName)
	{
		this.propName = propName;
		this.xName    = propName.clone();
		this.mapAs    = MAP_AS_ELEMENT;
	}

	// Pronto name and x-mapping name same.
	void constructor(String<u8> propName, ProntoType type)
	{
		this.propName = propName;
		this.xName    = propName.clone();
		this.mapAs    = MAP_AS_ELEMENT;
		this.type     = type;
	}

	// mapAs one of MAP_AS_ELEMENT etc.
	void constructor(String<u8> propName, String<u8> xName, u8 mapAs)
	{
		this.propName = propName;
		this.xName    = xName;
		this.mapAs    = mapAs;
	}

	// Set mapAs to MAP_AS_ELEMENT, MAP_AS_ATTRIBUTE, MAP_AS_CHILDREN_ONLY, or MAP_AS_EXCLUDED.
	void setMapAs(u8 mapAs)
	{
		this.mapAs = mapAs;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// XClassMapping
////////////////////////////////////////////////////////////////////////////////////////////////////

// Describes how to map a Pronto object to/from XML/JSON etc. Use this to exclude Pronto object 
// properties from being mapped etc. Any properties not specified will be serialized by default.
class XClassMapping
{
	String<u8> namespace = null;
	String<u8> className = null;
	String<u8> xName     = null;
	u8         mapAs     = XPropertyMapping:MAP_AS_ELEMENT;

	ArrayList<XPropertyMapping> properties();

	// Construct valid mapping.
	void constructor(String<u8> className)
	{
		this.namespace = String<u8>();
		this.className = className;
		this.xName     = classNameToXName(className.clone());
	}

	// Construct valid mapping.
	void constructor(String<u8> className, String<u8> xName)
	{
		this.namespace = String<u8>();
		this.className = className;
		this.xName     = classNameToXName(xName);
	}

	// Construct valid mapping.
	void constructor(String<u8> namespace, String<u8> className, String<u8> xName)
	{
		this.namespace = namespace;
		this.className = className;
		this.xName     = classNameToXName(xName);
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

	// Add class property mapping.
	void addProperty(String<u8> propName, String<u8> xName)
	{
		properties.add(XPropertyMapping(propName, xName, XPropertyMapping:MAP_AS_ELEMENT));
	}

	// Exclude a property from mapping to/from XML/JSON document.
	void addPropertyExcluded(String<u8> propName, String<u8> xName)
	{
		properties.add(XPropertyMapping(propName, xName, XPropertyMapping:MAP_AS_EXCLUDED));
	}

	// Mark a property it so that only it's children are added to the XML/JSON document.
	void addPropertyChildrenOnly(String<u8> propName, String<u8> xName)
	{
		properties.add(XPropertyMapping(propName, xName, XPropertyMapping:MAP_AS_CHILDREN_ONLY));
	}

	// Mark a property to be output as a attribute (i.e. <tag attribute="1">)
	void addPropertyAttribute(String<u8> propName, String<u8> xName)
	{
		properties.add(XPropertyMapping(propName, xName, XPropertyMapping:MAP_AS_ATTRIBUTE));
	}

	// Get property mapping by pronto property name.
	XPropertyMapping getPropertyPronto(String<u8> prontoPropName)
	{
		for(u64 p=0; p<properties.size(); p++)
		{
			if(properties[p].propName != null)
			{
				if(properties[p].propName.compare(prontoPropName) == true)
					return properties[p];
			}
		}

		return null;
	}

	// Get property mapping by x-name.
	XPropertyMapping getPropertyXName(String<u8> xPropName)
	{
		for(u64 p=0; p<properties.size(); p++)
		{
			if(properties[p].xName != null)
			{
				if(properties[p].xName.compare(xPropName) == true)
					return properties[p];
			}
		}

		return null;
	}

	// Get property mapping by x-name or Pronto property name. Case-insensitive.
	XPropertyMapping getProperty(String<u8> name)
	{
		for(u64 p=0; p<properties.size(); p++)
		{
			if(properties[p].xName != null)
			{
				if(properties[p].xName.compare(name, false) == true)
					return properties[p];
			}
		}

		for(u64 x=0; x<properties.size(); x++)
		{
			if(properties[x].propName != null)
			{
				if(properties[x].propName.compare(name, false) == true)
					return properties[x];
			}
		}

		return null;
	}

	// Fill-in "missing" mapped-properties with default-mapped Pronto class properties.
	void mapMissingProperties()
	{
		ClassProperty[] clsProps = Class:getProperties(getFullClassName());
		if(clsProps == null)
			return;

		for(u64 p=0; p<clsProps.length(); p++)
		{
			String<u8>     propName = clsProps[p].name;
			ProntoType propType = clsProps[p].type;

			XPropertyMapping propMapping = getPropertyPronto(propName);
			if(propMapping == null)
			{
				propMapping = XPropertyMapping(propName, propType);
				this.properties.add(propMapping);
			}
			else
			{
				if(propMapping.type == null)
					propMapping.type = propType;
			}
		}
	}

	// Substitutes invalid element name characters. Used for handling templates, i.e. ArrayList<u8> etc.
	shared String<u8> classNameToXName(String<u8> clsName)
	{
		if(clsName == null)
			return String<u8>();

		String<u8> retName = clsName.clone();
		i64 openAngleIndex = retName.findNext(Chars:OPEN_ANGLE_BRACKET, 0);
		if(openAngleIndex != -1)
		{
			retName.replaceAll(Chars:OPEN_ANGLE_BRACKET, Chars:OPEN_PARENTHESIS);
			retName.replaceAll(Chars:CLOSE_ANGLE_BRACKET, Chars:CLOSE_PARENTHESIS);
		}

		return retName;
	}

	// Substitutes invalid element name characters. Used for handling templates, i.e. ArrayList<u8> etc.
	shared String<u8> classNameFromXName(String<u8> xName)
	{
		if(xName == null)
			return String<u8>();

		String<u8> retName = xName.clone();
		i64 openAngleIndex = retName.findNext(Chars:OPEN_PARENTHESIS, 0);
		if(openAngleIndex != -1)
		{
			retName.replaceAll(Chars:OPEN_PARENTHESIS, Chars:OPEN_ANGLE_BRACKET);
			retName.replaceAll(Chars:CLOSE_PARENTHESIS, Chars:CLOSE_ANGLE_BRACKET);
		}

		return retName;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// XMapping
////////////////////////////////////////////////////////////////////////////////////////////////////

// Describes how to map Pronto objects to/from XML/JSON etc.
class XMapping
{
	ArrayList<XClassMapping> classes();
	u8 numFracDigits = 2; // number of digits after decimal for floating-point number strings

	// Empty mapping.
	void constructor() {}

	// Add class mapping.
	void addClass(XClassMapping clsMapping)
	{
		classes.add(clsMapping);
	}

	// Get class mapping by pronto class name.
	XClassMapping getClassPronto(String<u8> prontoClassName)
	{
		for(u64 p=0; p<classes.size(); p++)
		{
			if(classes[p].className.compare(prontoClassName) == true)
				return classes[p];
		}

		return null;
	}

	// Get class mapping by pronto class name.
	XClassMapping getClassPronto(String<u8> namespace, String<u8> prontoClassName)
	{
		if(namespace == null)
			return getClassPronto(prontoClassName);

		if(namespace.length() == 0)
			return getClassPronto(prontoClassName);

		for(u64 p=0; p<classes.size(); p++)
		{
			if(classes[p].namespace.compare(namespace) == false)
				continue;

			if(classes[p].className.compare(prontoClassName) == true)
				return classes[p];
		}

		return null;
	}

	// Get class mapping by x-name class name.
	XClassMapping getClassXName(String<u8> xName)
	{
		for(u64 p=0; p<classes.size(); p++)
		{
			if(classes[p].xName != null)
			{
				if(classes[p].xName.compare(xName) == true)
					return classes[p];
			}
		}

		return null;
	}

	// Get class mapping by matching x-name or Pronto class name. Case-insentive. 
	XClassMapping getClass(String<u8> xElemName)
	{
		for(u64 p=0; p<classes.size(); p++)
		{
			if(classes[p].xName != null)
			{
				if(classes[p].xName.compare(xElemName, false) == true)
					return classes[p];
			}
		}

		String<u8> prontoName = XClassMapping:classNameFromXName(xElemName);

		for(u64 x=0; x<classes.size(); x++)
		{
			if(classes[x].className != null)
			{
				if(classes[x].className.compare(prontoName, false) == true)
					return classes[x];
			}
		}

		return null;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// XMappingUtils
////////////////////////////////////////////////////////////////////////////////////////////////////

// Utilities for parsing etc.
class XMappingUtils
{
	// String<u8> of comma separated values.
	shared IArray stringToArray(ProntoType arrayType, String<u8> valsStr)
	{
		IArray arr = null;

		ArrayList<String<u8>> valsStrs = null;
		if(valsStr.contains(Chars:COMMA) == true)
			valsStrs = valsStr.split(Chars:COMMA, true);
		else
			valsStrs = valsStr.splitByWhitespace();

		if(valsStrs == null)
			return Class:createArray(arrayType.getFullClassName(), 0);

		ProntoType elemType = arrayType.getElementType();

		u64 arrSize = valsStrs.size();
		if(elemType.numElements > 1)
			arrSize /= elemType.numElements;

		arr = Class:createArray(arrayType.getFullClassName(), arrSize);

		for(u64 s=0; s<valsStrs.size(); s++)
		{
			u64 e = s;
			u64 v = 0;
			if(elemType.numElements > 0) // vector
			{
				e = s / elemType.numElements;
				v = s % elemType.numElements;
			}

			if(elemType.typeID == Type:U8)
				Array:setElementU8(arr, e, v, valsStrs[s].parseInteger());
			else if(elemType.typeID == Type:I8)
				Array:setElementI8(arr, e, v, valsStrs[s].parseInteger());
			else if(elemType.typeID == Type:U16)
				Array:setElementU16(arr, e, v, valsStrs[s].parseInteger());
			else if(elemType.typeID == Type:I16)
				Array:setElementI16(arr, e, v, valsStrs[s].parseInteger());
			else if(elemType.typeID == Type:U32)
				Array:setElementU32(arr, e, v, valsStrs[s].parseInteger());
			else if(elemType.typeID == Type:I32)
				Array:setElementI32(arr, e, v, valsStrs[s].parseInteger());
			else if(elemType.typeID == Type:U64)
				Array:setElementU64(arr, e, v, valsStrs[s].parseInteger());
			else if(elemType.typeID == Type:I64)
				Array:setElementI64(arr, e, v, valsStrs[s].parseInteger());
			else if(elemType.typeID == Type:F32)
				Array:setElementF32(arr, e, v, valsStrs[s].parseFloat());
			else if(elemType.typeID == Type:F64)
				Array:setElementF64(arr, e, v, valsStrs[s].parseFloat());
			else
				assert(false); // missing a case?
		}

		return arr;
	}

	// Array of primitive scalars/vectors to string. If array of objects, obj.toString() used. Format output is comma seperated.
	shared String<u8> arrayToString(IArray arr, u8 numFracDigits)
	{
		if(arr == null)
			return String<u8>("");
		
		String<u8> clsName = arr.getClassName();
		ProntoType arrType(clsName);
		ProntoType elemType = arrType.getElementType();

		String<u8> valStr = null;
		if(elemType.typeID == Type:OBJ) // array of objects
		{
			// each element toString()
			valStr = String<u8>(arr.length() * 8);
			for(u64 e=0; e<arr.length(); e++)
			{
				valStr.append(Array:getElementObj(arr, e).toString());

				if(e != (arr.length()-1))
					valStr.append(", ");
			}

			return valStr;
		}
		else if(elemType.numElements > 0) // array of vectors
		{
			valStr = String<u8>(arr.length() * elemType.numElements * 4);
			for(u64 e=0; e<arr.length(); e++)
			{
				for(u64 v=0; v<elemType.numElements; v++)
				{
					if(elemType.typeID == Type:U8)
						valStr.append(String<u8>:formatNumber(Array:getElementU8(arr, e, v)));
					else if(elemType.typeID == Type:I8)
						valStr.append(String<u8>:formatNumber(Array:getElementI8(arr, e, v)));
					else if(elemType.typeID == Type:U16)
						valStr.append(String<u8>:formatNumber(Array:getElementU16(arr, e, v)));
					else if(elemType.typeID == Type:I16)
						valStr.append(String<u8>:formatNumber(Array:getElementI16(arr, e, v)));
					else if(elemType.typeID == Type:U32)
						valStr.append(String<u8>:formatNumber(Array:getElementU32(arr, e, v)));
					else if(elemType.typeID == Type:I32)
						valStr.append(String<u8>:formatNumber(Array:getElementI32(arr, e, v)));
					else if(elemType.typeID == Type:U64)
						valStr.append(String<u8>:formatNumber(Array:getElementU64(arr, e, v)));
					else if(elemType.typeID == Type:I64)
						valStr.append(String<u8>:formatNumber(Array:getElementI64(arr, e, v)));
					else if(elemType.typeID == Type:F32)
						valStr.append(String<u8>:formatNumber(Array:getElementF32(arr, e, v), numFracDigits));
					else if(elemType.typeID == Type:F64)
						valStr.append(String<u8>:formatNumber(Array:getElementF64(arr, e, v), numFracDigits));

					if(e != (arr.length()-1) || v != (elemType.numElements-1))
						valStr.append(", ");
				}
			}

			return valStr;
		}
		else
		{
			// array of scalars
			valStr = String<u8>(arr.length() * 4);
			for(u64 e=0; e<arr.length(); e++)
			{
				if(elemType.typeID == Type:U8)
					valStr.append(String<u8>:formatNumber(Array:getElementU8(arr, e)));
				else if(elemType.typeID == Type:I8)
					valStr.append(String<u8>:formatNumber(Array:getElementI8(arr, e)));
				else if(elemType.typeID == Type:U16)
					valStr.append(String<u8>:formatNumber(Array:getElementU16(arr, e)));
				else if(elemType.typeID == Type:I16)
					valStr.append(String<u8>:formatNumber(Array:getElementI16(arr, e)));
				else if(elemType.typeID == Type:U32)
					valStr.append(String<u8>:formatNumber(Array:getElementU32(arr, e)));
				else if(elemType.typeID == Type:I32)
					valStr.append(String<u8>:formatNumber(Array:getElementI32(arr, e)));
				else if(elemType.typeID == Type:U64)
					valStr.append(String<u8>:formatNumber(Array:getElementU64(arr, e)));
				else if(elemType.typeID == Type:I64)
					valStr.append(String<u8>:formatNumber(Array:getElementI64(arr, e)));
				else if(elemType.typeID == Type:F32)
					valStr.append(String<u8>:formatNumber(Array:getElementF32(arr, e), numFracDigits));
				else if(elemType.typeID == Type:F64)
					valStr.append(String<u8>:formatNumber(Array:getElementF64(arr, e), numFracDigits));

				if(e != (arr.length()-1))
					valStr.append(", ");
			}
		}

		return valStr;
	}

	// Get an object's property value as a string. Works for integer/float scalars/vectors and arrays of scalars/vectors. Objects return obj.toString().
	shared String<u8> getPropertyAsString(IObj obj, String<u8> propName, u8 numFracDigits)
	{
		ProntoType propType = Class:getPropertyType(obj.getClassName(), propName);
		if(propType == null)
			return String<u8>("");

		if(propType.isArray() == true)
		{
			IArray arr = Class:getPropertyValueObj(obj, propName);
			if(arr != null)
				return arrayToString(arr, numFracDigits);

			return String<u8>();
		}
		else if(propType.typeID == Type:OBJ)
		{
			IObj propObj = Class:getPropertyValueObj(obj, propName);
			if(propObj != null)
				return propObj.toString();

			return String<u8>();
		}
		else // primitive scalar or vector
		{
			String<u8> strNum = null;
			if(propType.numElements == 0) // scalar
			{
				if(propType.typeID == Type:U8)
					strNum = String<u8>:formatNumber(Class:getPropertyValueU8(obj, propName));
				else if(propType.typeID == Type:I8)
					strNum = String<u8>:formatNumber(Class:getPropertyValueI8(obj, propName));
				else if(propType.typeID == Type:U16)
					strNum = String<u8>:formatNumber(Class:getPropertyValueU16(obj, propName));
				else if(propType.typeID == Type:I16)
					strNum = String<u8>:formatNumber(Class:getPropertyValueI16(obj, propName));
				else if(propType.typeID == Type:U32)
					strNum = String<u8>:formatNumber(Class:getPropertyValueU32(obj, propName));
				else if(propType.typeID == Type:I32)
					strNum = String<u8>:formatNumber(Class:getPropertyValueI32(obj, propName));
				else if(propType.typeID == Type:U64)
					strNum = String<u8>:formatNumber(Class:getPropertyValueU64(obj, propName));
				else if(propType.typeID == Type:I64)
					strNum = String<u8>:formatNumber(Class:getPropertyValueI64(obj, propName));
				else if(propType.typeID == Type:F32)
					strNum = String<u8>:formatNumber(Class:getPropertyValueF32(obj, propName), numFracDigits);
				else if(propType.typeID == Type:F64)
					strNum = String<u8>:formatNumber(Class:getPropertyValueF64(obj, propName), numFracDigits);
			}
			else
			{
				strNum = String<u8>(32);
				for(u64 v=0; v<propType.numElements; v++)
				{
					if(propType.typeID == Type:U8)
						strNum.append(String<u8>:formatNumber(Class:getPropertyValueU8(obj, propName, v)));
					else if(propType.typeID == Type:I8)
						strNum.append(String<u8>:formatNumber(Class:getPropertyValueI8(obj, propName, v)));
					else if(propType.typeID == Type:U16)
						strNum.append(String<u8>:formatNumber(Class:getPropertyValueU16(obj, propName, v)));
					else if(propType.typeID == Type:I16)
						strNum.append(String<u8>:formatNumber(Class:getPropertyValueI16(obj, propName, v)));
					else if(propType.typeID == Type:U32)
						strNum.append(String<u8>:formatNumber(Class:getPropertyValueU32(obj, propName, v)));
					else if(propType.typeID == Type:I32)
						strNum.append(String<u8>:formatNumber(Class:getPropertyValueI32(obj, propName, v)));
					else if(propType.typeID == Type:U64)
						strNum.append(String<u8>:formatNumber(Class:getPropertyValueU64(obj, propName, v)));
					else if(propType.typeID == Type:I64)
						strNum.append(String<u8>:formatNumber(Class:getPropertyValueI64(obj, propName, v)));
					else if(propType.typeID == Type:F32)
						strNum.append(String<u8>:formatNumber(Class:getPropertyValueF32(obj, propName, v), numFracDigits));
					else if(propType.typeID == Type:F64)
						strNum.append(String<u8>:formatNumber(Class:getPropertyValueF64(obj, propName, v), numFracDigits));

					if(v != (propType.numElements-1))
						strNum.append(", ");
				}
			}

			return strNum;
		}

		return String<u8>("");
	}

	// Set a pronto class property (primitive/vector/string/array of primitives) from the value pulled from XML/JSON etc.
	shared void setPropertyFromString(IObj obj, String<u8> propName, ProntoType propType, String<u8> value)
	{
		if(propType == null)
		{
			Class:setPropertyValueObj(obj, propName, String<u8>(value));
			return;
		}

		if(propType.typeID == Type:OBJ)
		{
			if(propType.isArray())
			{
				ProntoType elemType = propType.getElementType();
				if(elemType.typeID == Type:OBJ)
				{
					// we don't handle this
					return;
				}

				// parse array of integers/floats
				XMappingUtils:setPropertyFromStringOfValues(obj, propName, elemType, value);
			}
			else if(propType.className != null)
			{
				if(propType.className.compare("String<u8>"))
				{
					Class:setPropertyValueObj(obj, propName, String<u8>(value));
					return;
				}
			}
		}
		else if(propType.numElements > 0) // vector
		{
			ProntoType elemType(propType);
			elemType.numElements = 0; // we just treat our vector like array
			XMappingUtils:setPropertyFromStringOfValues(obj, propName, elemType, value);
		}
		else // scalar
		{
			if(propType.typeID == Type:U8)
				Class:setPropertyValueU8(obj, propName, value.parseInteger());
			else if(propType.typeID == Type:I8)
				Class:setPropertyValueI8(obj, propName, value.parseInteger());
			else if(propType.typeID == Type:U16)
				Class:setPropertyValueU16(obj, propName, value.parseInteger());
			else if(propType.typeID == Type:I16)
				Class:setPropertyValueI16(obj, propName, value.parseInteger());
			else if(propType.typeID == Type:U32)
				Class:setPropertyValueU32(obj, propName, value.parseInteger());
			else if(propType.typeID == Type:I32)
				Class:setPropertyValueI32(obj, propName, value.parseInteger());
			else if(propType.typeID == Type:U64)
				Class:setPropertyValueU64(obj, propName, value.parseInteger());
			else if(propType.typeID == Type:I64)
				Class:setPropertyValueI64(obj, propName, value.parseInteger());
			else if(propType.typeID == Type:F32)
				Class:setPropertyValueF32(obj, propName, value.parseFloat());
			else if(propType.typeID == Type:F64)
				Class:setPropertyValueF64(obj, propName, value.parseFloat());
			else
				assert(false); // missing a case?
		}
	}

	// Set a pronto class property primitive (integer or float) scalar or single element of array/vector from the String<u8> value provided.
	shared void setPropertyFromString(IObj obj, String<u8> propName, ProntoType elemType, u64 arrayIndex, u64 vecIndex, String<u8> value)
	{
		if(elemType.typeID == Type:U8)
			Class:setPropertyValueU8(obj, propName, arrayIndex, vecIndex, value.parseInteger());
		else if(elemType.typeID == Type:I8)
			Class:setPropertyValueI8(obj, propName, arrayIndex, vecIndex, value.parseInteger());
		else if(elemType.typeID == Type:U16)
			Class:setPropertyValueU16(obj, propName, arrayIndex, vecIndex, value.parseInteger());
		else if(elemType.typeID == Type:I16)
			Class:setPropertyValueI16(obj, propName, arrayIndex, vecIndex, value.parseInteger());
		else if(elemType.typeID == Type:U32)
			Class:setPropertyValueU32(obj, propName, arrayIndex, vecIndex, value.parseInteger());
		else if(elemType.typeID == Type:I32)
			Class:setPropertyValueI32(obj, propName, arrayIndex, vecIndex, value.parseInteger());
		else if(elemType.typeID == Type:U64)
			Class:setPropertyValueU64(obj, propName, arrayIndex, vecIndex, value.parseInteger());
		else if(elemType.typeID == Type:I64)
			Class:setPropertyValueI64(obj, propName, arrayIndex, vecIndex, value.parseInteger());
		else if(elemType.typeID == Type:F32)
			Class:setPropertyValueF32(obj, propName, arrayIndex, vecIndex, value.parseFloat());
		else if(elemType.typeID == Type:F64)
			Class:setPropertyValueF64(obj, propName, arrayIndex, vecIndex, value.parseFloat());
		else
			assert(false); // missing a case?
	}

	// Set a array element primitive (integer or float) scalar or single element of array/vector from the String<u8> value provided.
	shared void setArrayElementFromString(IArray arr, u64 arrayIndex, u64 vecIndex, String<u8> value)
	{
		String<u8> arrClassName = arr.getClassName();
		ProntoType arrType(arrClassName);
		if(arrType.isArray() == false)
			return;

		ProntoType elemType = arrType.getElementType();

		setArrayElementFromString(arr, elemType, arrayIndex, vecIndex, value);
	}

	// Set a array element primitive (integer or float) scalar or single element of array/vector from the String<u8> value provided.
	shared void setArrayElementFromString(IArray arr, ProntoType elemType, u64 arrayIndex, u64 vecIndex, String<u8> value)
	{
		if(elemType.typeID == Type:U8)
			Array:setElementU8(arr, arrayIndex, vecIndex, value.parseInteger());
		else if(elemType.typeID == Type:I8)
			Array:setElementI8(arr, arrayIndex, vecIndex, value.parseInteger());
		else if(elemType.typeID == Type:U16)
			Array:setElementU16(arr, arrayIndex, vecIndex, value.parseInteger());
		else if(elemType.typeID == Type:I16)
			Array:setElementI16(arr, arrayIndex, vecIndex, value.parseInteger());
		else if(elemType.typeID == Type:U32)
			Array:setElementU32(arr, arrayIndex, vecIndex, value.parseInteger());
		else if(elemType.typeID == Type:I32)
			Array:setElementI32(arr, arrayIndex, vecIndex, value.parseInteger());
		else if(elemType.typeID == Type:U64)
			Array:setElementU64(arr, arrayIndex, vecIndex, value.parseInteger());
		else if(elemType.typeID == Type:I64)
			Array:setElementI64(arr, arrayIndex, vecIndex, value.parseInteger());
		else if(elemType.typeID == Type:F32)
			Array:setElementF32(arr, arrayIndex, vecIndex, value.parseFloat());
		else if(elemType.typeID == Type:F64)
			Array:setElementF64(arr, arrayIndex, vecIndex, value.parseFloat());
		else
			assert(false); // missing a case?
	}

	// Split a comma or whitespace seperated string of numbers and write values to array/vector property of an object.
	shared void setPropertyFromStringOfValues(IObj obj, String<u8> propName, ProntoType elemType, String<u8> value)
	{
		// parse the comma seperated list of numbers etc.
		ArrayList<String<u8>> elemStrs = null;
		if(value.contains(Chars:COMMA) == true) // assume seperated by commas
		{
			elemStrs = value.split(Chars:COMMA, true);
		}
		else if(value.contains(Chars:SPACE) == true) // assume seperated by whitespace
		{
			elemStrs = value.splitByWhitespace();
		}
		else
		{
			// must be single number
			elemStrs = ArrayList<String<u8>>(1);
			elemStrs.add(value.clone());
		}

		// check if we need to create array
		String<u8> className = obj.getClassName();

		u64 propLen = Class:getPropertyLength(className, propName);
		if(propLen != elemStrs.size())
		{
			// create right-sized array
			u64 arrNewSize = elemStrs.size();
			if(elemType.numElements > 0) // vector
			{
				arrNewSize = elemStrs.size() / elemType.numElements;
				if((elemStrs.size() % elemType.numElements) != 0)
					arrNewSize++; // need space for partials
			}

			Class:setPropertyToNewArray(obj, propName, arrNewSize);
		}

		for(u64 s=0; s<elemStrs.size(); s++)
		{
			u64 e = s;
			u64 v = 0;
			if(elemType.numElements > 0) // vector
			{
				e = s / elemType.numElements;
				v = s % elemType.numElements;
			}

			if(elemType.typeID == Type:U8)
				Class:setPropertyValueU8(obj, propName, e, v, elemStrs[s].parseInteger());
			else if(elemType.typeID == Type:I8)
				Class:setPropertyValueI8(obj, propName, e, v, elemStrs[s].parseInteger());
			else if(elemType.typeID == Type:U16)
				Class:setPropertyValueU16(obj, propName, e, v, elemStrs[s].parseInteger());
			else if(elemType.typeID == Type:I16)
				Class:setPropertyValueI16(obj, propName, e, v, elemStrs[s].parseInteger());
			else if(elemType.typeID == Type:U32)
				Class:setPropertyValueU32(obj, propName, e, v, elemStrs[s].parseInteger());
			else if(elemType.typeID == Type:I32)
				Class:setPropertyValueI32(obj, propName, e, v, elemStrs[s].parseInteger());
			else if(elemType.typeID == Type:U64)
				Class:setPropertyValueU64(obj, propName, e, v, elemStrs[s].parseInteger());
			else if(elemType.typeID == Type:I64)
				Class:setPropertyValueI64(obj, propName, e, v, elemStrs[s].parseInteger());
			else if(elemType.typeID == Type:F32)
				Class:setPropertyValueF32(obj, propName, e, v, elemStrs[s].parseFloat());
			else if(elemType.typeID == Type:F64)
				Class:setPropertyValueF64(obj, propName, e, v, elemStrs[s].parseFloat());
			else
				assert(false); // missing a case?
		}
	}
}

