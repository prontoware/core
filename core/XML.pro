////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// XML
////////////////////////////////////////////////////////////////////////////////////////////////////

// XML constants and utilities.
class XML
{
	// Encode a XML string value making it safe by replacing <>'"& with &lt; &gt; &apos; &quot; &amp; respectively.
	shared String<u8> encodeText(String<u8> s)
	{
		if(s == null)
			return null;

		// '   &apos;
		// "   &quot;
		// <   &lt;
		// >   &gt;
		// &   &amp;

		String<u8> cpy(s.numChars);

		for(u64 c=0; c<s.numChars; c++)
		{
			if(s.chars[c] == Chars:SINGLE_QUOTE)
				cpy.append("&apos;");
			else if(s.chars[c] == Chars:DOUBLE_QUOTE)
				cpy.append("&quot;");
			else if(s.chars[c] == Chars:OPEN_ANGLE_BRACKET)
				cpy.append("&lt;");
			else if(s.chars[c] == Chars:CLOSE_ANGLE_BRACKET)
				cpy.append("&gt;");
			else if(s.chars[c] == Chars:AMPERSAND)
			{
				// make sure we aren't encoding an encoding
				if(s.compare(c, "&apos;", 0, 6, false) == true)
					cpy.append(s.chars[c]);
				else if(s.compare(c, "&quot;", 0, 6, false) == true)
					cpy.append(s.chars[c]);
				else if(s.compare(c, "&lt;", 0, 4, false) == true)
					cpy.append(s.chars[c]);
				else if(s.compare(c, "&gt;", 0, 4, false) == true)
					cpy.append(s.chars[c]);
				else if(s.compare(c, "&amp;", 0, 5, false) == true)
					cpy.append(s.chars[c]);
				else if(s.compare(c, "&nbsp;", 0, 5, false) == true) // this is HTML-only, but shows up in XHTML etc.
					cpy.append(s.chars[c]);
				else if(s.compare(c, "&#", 0, 2, false) == true) // assume this is a &#NN...N; character encoding
					cpy.append(s.chars[c]);
				else
					cpy.append("&amp;");
			}
			else
				cpy.append(s.chars[c]);
		}

		return cpy;
	}

	// Decode a XML string value by replacing &lt; &gt; &apos; &quot; &amp; with <>'"& respectively.
	shared String<u8> decodeText(String<u8> s)
	{
		if(s == null)
			return null;
		
		String<u8> cpy(s.numChars);

		for(u64 c=0; c<s.numChars; c++)
		{
			if(s.chars[c] == Chars:AMPERSAND)
			{
				if(s.compare(c+1, "apos;", 0, 5, true) == true)
				{
					cpy.append(Chars:SINGLE_QUOTE);
					c += 5;
				}
				else if(s.compare(c+1, "quot;", 0, 5, true) == true)
				{
					cpy.append(Chars:DOUBLE_QUOTE);
					c += 5;
				}
				else if(s.compare(c+1, "lt;", 0, 3, true) == true)
				{
					cpy.append(Chars:OPEN_ANGLE_BRACKET);
					c += 3;
				}
				else if(s.compare(c+1, "gt;", 0, 3, true) == true)
				{
					cpy.append(Chars:CLOSE_ANGLE_BRACKET);
					c += 3;
				}
				else if(s.compare(c+1, "amp;", 0, 4, true) == true)
				{
					cpy.append(Chars:AMPERSAND);
					c += 4;
				}
				else
					cpy.append(s.chars[c]);
			}
			else
				cpy.append(s.chars[c]);
		}

		return cpy;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// XMLAttribute
////////////////////////////////////////////////////////////////////////////////////////////////////

// Represents parsed XML attribute which is a name/value pair. Example x="1" within <section x="1">.
class XMLAttribute
{
	String<u8> name;  // name="value"
	String<u8> value; // name="value"

	// Construct empty invalid attribute.
	void constructor() { this.name = String<u8>(); this.value = String<u8>(); }

	// Construct attribute.
	void constructor(String<u8> name, String<u8> value)
	{
		this.name  = name;
		this.value = value;
	}

	// Release memory.
	void destroy()
	{
		name  = null;
		value = null;
	}

	// Clone this name/value.
	XMLAttribute clone()
	{
		XMLAttribute twin();
		if(this.name != null)
			twin.name = this.name.clone();
		if(this.value != null)
			twin.value = this.value.clone();

		return twin;
	}

	// To form: name="value".
	String<u8> toString()
	{
		if(this.name == null && this.value == null)
			return String<u8>();

		if(this.name != null && this.value == null)
		{
			String<u8> halfStr(this.name.length() + 3);
			halfStr.append(name);
			halfStr.append("=\"\"");

			return halfStr;
		}

		String<u8> s(this.name.length() + 3 + this.value.length());

		s.append(name);
		s.append("=\"");
		s.append(XML:encodeText(value));
		s.append("\"");

		return s;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// XMLTag
////////////////////////////////////////////////////////////////////////////////////////////////////

// Represents parsed XML tag object.
class XMLTag
{
	const u8 TYPE_START  = 0; // i.e. <tag>
	const u8 TYPE_END    = 1; // i.e. </tag>
	const u8 TYPE_SINGLE = 2; // i.e. <tag />

	String<u8> name; // i.e. <section>
	u8 tagType; // one of TYPE_XXX 
	ArrayList<XMLAttribute> attributes = null; // null for none

	// Construct empty invalid tag.
	void constructor() { this.name = String<u8>(); this.tagType = TYPE_START; }

	// Construct tag. TYPE_SINGLE.
	void constructor(String<u8> name)
	{
		this.name    = name;
		this.tagType = TYPE_SINGLE;
	}

	// Construct tag. tagType one of TYPE_START, TYPE_END, TYPE_SINGLE.
	void constructor(String<u8> name, u8 tagType)
	{
		this.name    = name;
		this.tagType = tagType;
	}

	// Construct tag with one or more attributes. tagType one of TYPE_START, TYPE_END, TYPE_SINGLE.
	void constructor(String<u8> name, u8 tagType, XMLAttribute xmlAttribute)
	{
		this.name       = name;
		this.tagType    = tagType;
		this.attributes = ArrayList<XMLAttribute>(1);
		this.attributes.add(xmlAttribute);
	}

	// Release memory.
	void destroy()
	{
		name = null;
		
		if(attributes != null)
		{
			while(attributes.size() > 0)
			{
				XMLAttribute att = attributes.removeLast();
			}

			attributes = null;
		}
	}

	// Clone this including all attributes.
	XMLTag clone()
	{
		XMLTag twin();
		if(this.name != null)
			twin.name = this.name.clone();
		twin.tagType = this.tagType;

		if(this.hasAttributes())
		{
			twin.attributes = ArrayList<XMLAttribute>(this.attributes.size());
			for(u64 e=0; e<this.attributes.size(); e++)
			{
				twin.attributes.add(this.attributes[e].clone());
			}
		}

		return twin;
	}

	// To form: <name x="1">
	String<u8> toString()
	{
		String<u8> s(16);

		s.append(Chars:OPEN_ANGLE_BRACKET);

		if(tagType == TYPE_END)
			s.append(Chars:FORWARD_SLASH);

		s.append(name);

		if(attributes != null)
		{
			for(u64 a=0; a<attributes.size(); a++)
			{
				XMLAttribute attribute = attributes[a];
				if(attribute == null)
					continue;

				s.append(Chars:SPACE);
				s.append(attribute.toString()); 
			}
		}

		if(tagType == TYPE_SINGLE)
		{
			s.append(Chars:SPACE);
			s.append(Chars:FORWARD_SLASH);
		}

		s.append(Chars:CLOSE_ANGLE_BRACKET);

		return s;
	}

	// Is a comment tag? i.e. <!-- Comment text -->
	bool isComment()
	{
		if(name.compare("!--") == true)
			return true;

		return false;
	}

	// Does this tag have any attributes?
	bool hasAttributes()
	{
		if(this.attributes == null)
			return false;

		if(this.attributes.size() == 0)
			return false;

		return true;
	}

	// Does this tag have any attributes?
	u64 getNumAttributes()
	{
		if(this.attributes == null)
			return 0;

		return this.attributes.size();
	}

	// Add/Set an attribute.
	void addAttribute(String<u8> name, String<u8> value)
	{
		if(attributes == null)
			attributes = ArrayList<XMLAttribute>(1);

		// check for existing
		for(u64 a=0; a<attributes.size(); a++)
		{
			XMLAttribute att = attributes[a];
			if(att.name.compare(name) == true)
			{
				att.value.copy(value);
				return;
			}
		}

		attributes.add(XMLAttribute(name, value));
	}

	// Add/Set an attribute.
	void addAttribute(XMLAttribute attribute)
	{
		if(attributes == null)
			attributes = ArrayList<XMLAttribute>(1);

		// check for existing
		for(u64 a=0; a<attributes.size(); a++)
		{
			XMLAttribute att = attributes[a];
			if(att.name.compare(attribute.name) == true)
			{
				att.value.copy(attribute.value);
				return;
			}
		}

		attributes.add(attribute);
	}

	// Get child attribute via [index] operator.
	XMLAttribute get(u64 index)
	{
		if(attributes == null)
			return null;
		
		return attributes[index];
	}

	// Get attribute by index.
	XMLAttribute getAttribute(u64 index)
	{
		if(this.attributes == null)
			return null;

		return this.attributes[index];
	}

	// Get attribute by name. Returns null if not found.
	XMLAttribute getAttribute(String<u8> attName)
	{
		if(attributes == null)
			return null;

		for(u64 a=0; a<attributes.size(); a++)
		{
			if(attributes[a].name.compare(attName) == true)
				return attributes[a];
		}

		return null;
	}

	// Get attribute value by name. Returns null if not found.
	String<u8> getAttributeValue(String<u8> attName)
	{
		if(attributes == null)
			return null;

		for(u64 a=0; a<attributes.size(); a++)
		{
			if(attributes[a].name.compare(attName) == true)
				return attributes[a].value;
		}

		return null;
	}

	// Get attribute value by name. Returns defaultValue if not found.
	String<u8> getAttributeValue(String<u8> attName, String<u8> defValue)
	{
		if(attributes == null)
			return defValue;

		for(u64 a=0; a<attributes.size(); a++)
		{
			if(attributes[a].name.compare(attName) == true)
			{
				if(attributes[a].value == null)
					return defValue;

				return attributes[a].value;
			}
		}

		return defValue;
	}

	// Create start tag
	shared XMLTag createStartTag(String<u8> name)
	{
		XMLTag t();
		t.name = name.clone();
		t.tagType = TYPE_START;
		return t;
	}

	// Create end tag
	shared XMLTag createEndTag(String<u8> name)
	{
		XMLTag t();
		t.name = name.clone();
		t.tagType = TYPE_END;
		return t;
	}

	// Create single tag
	shared XMLTag createSingleTag(String<u8> name)
	{
		XMLTag t();
		t.name = name.clone();
		t.tagType = TYPE_SINGLE;
		return t;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// XMLElement
////////////////////////////////////////////////////////////////////////////////////////////////////

// Represents parsed XML/HTML element which is one of:
// (1) A start/end tag combo.
// (2) A single tag.
// (3) Content text block. Optionally CDATA.
class XMLElement
{
	const u8 CONTENT_TAG     = 0;
	const u8 CONTENT_TEXT    = 1;
	const u8 CONTENT_CDATA   = 2;
	const u8 CONTENT_COMMENT = 3;

	String<u8> content     = null; // text content
	u8         contentType = CONTENT_TAG; // text content is CDATA/Comment section?
	XMLTag     startTag    = null;
	XMLTag     endTag      = null; // optional
	ArrayList<XMLElement> childElements = null;

	// Empty (invalid) element construction.
	void constructor() {}

	// Construct Text element. This object owns content parameter now.
	void constructor(String<u8> content, u8 contentType)
	{
		this.content     = content;
		this.contentType = contentType;
	}

	// Construct element. This object owns tag parameters now.
	void constructor(XMLTag startTag, XMLTag endTag)
	{
		this.startTag = startTag;
		if(this.startTag != null)
			this.startTag.tagType = XMLTag:TYPE_START;

		this.endTag = endTag;
		if(this.endTag != null)
			this.endTag.tagType = XMLTag:TYPE_END;
	}

	// Construct start/end tag element.
	shared XMLElement createTag(String<u8> tagName)
	{
		XMLElement e();
		e.startTag = XMLTag:createStartTag(tagName.clone());
		e.endTag   = XMLTag:createEndTag(tagName.clone());
		return e;
	}

	// Construct start/end tag element with text contents.
	shared XMLElement createTag(String<u8> tagName, String<u8> content)
	{
		XMLElement e();
		e.startTag = XMLTag:createStartTag(tagName);
		e.endTag   = XMLTag:createEndTag(tagName);

		XMLElement c();
		e.addChild(c);
		c.contentType = XMLElement:CONTENT_TEXT;
		c.content     = String<u8>(content);

		return e;
	}

	// Construct start/end tag element with true/false content.
	shared XMLElement createTag(String<u8> tagName, bool content)
	{
		XMLElement e();
		e.startTag = XMLTag:createStartTag(tagName);
		e.endTag   = XMLTag:createEndTag(tagName);

		XMLElement c();
		e.addChild(c);
		c.contentType = XMLElement:CONTENT_TEXT;
		c.content     = String<u8>:formatBoolean(content);

		return e;
	}

	// Construct start/end tag element with numeric content.
	shared XMLElement createTag(String<u8> tagName, i64 valContent)
	{
		XMLElement e();
		e.startTag = XMLTag:createStartTag(tagName);
		e.endTag   = XMLTag:createEndTag(tagName);

		XMLElement c();
		e.addChild(c);
		c.contentType = XMLElement:CONTENT_TEXT;
		c.content     = String<u8>:formatNumber(valContent);

		return e;
	}

	// Construct start/end tag element with numeric content.
	shared XMLElement createTag(String<u8> tagName, f64 valContent)
	{
		XMLElement e();
		e.startTag = XMLTag:createStartTag(tagName);
		e.endTag   = XMLTag:createEndTag(tagName);

		XMLElement c();
		e.addChild(c);
		c.contentType = XMLElement:CONTENT_TEXT;
		c.content     = String<u8>:formatNumber(valContent, 8);

		return e;
	}

	// Construct start/end tag element.
	shared XMLElement createSingleTag(String<u8> tagName)
	{
		XMLElement e();
		e.startTag = XMLTag:createSingleTag(tagName.clone());
		e.endTag   = null;
		return e;
	}

	// Construct text element.
	shared XMLElement createText(String<u8> text)
	{
		XMLElement e();
		e.content     = text;
		e.contentType = CONTENT_TEXT;
		return e;
	}

	// Construct comment element.
	shared XMLElement createComment(String<u8> comment)
	{
		XMLElement e();
		e.content     = comment;
		e.contentType = CONTENT_COMMENT;
		return e;
	}

	// Construct comment element.
	shared XMLElement createCDATA(String<u8> cdata)
	{
		XMLElement e();
		e.content     = cdata;
		e.contentType = CONTENT_CDATA;
		return e;
	}

	// Release memory.
	void destroy()
	{
		content  = null;
		startTag = null;
		endTag   = null;

		if(childElements != null)
		{
			while(childElements.size() > 0)
			{
				XMLElement child = childElements.removeLast();
			}

			childElements = null;
		}
	}

	// Get child element via [index] operator.
	XMLElement get(u64 index)
	{
		if(childElements == null)
			return null;

		return childElements[index];
	}

	// Get text contents of element.
	String<u8> getElementContent(String<u8> tagName)
	{
		ArrayList<XMLElement> elements = getElements(tagName);

		if(elements.size() == 0)
			return null;

		if(elements[0].childElements == null)
			return null;
			
		if(elements[0].childElements.size() == 0)
			return null;

		return elements[0].childElements[0].content;
	}

	// Get text contents of element.
	String<u8> getElementContent(String<u8> tagName, String<u8> defValue)
	{
		String<u8> str = getElementContent(tagName);

		if(str != null)
			return str;

		return defValue;
	}

	// Get text contents of element as boolean.
	bool getElementContentBoolean(String<u8> tagName, bool defValue)
	{
		String<u8> str = getElementContent(tagName);

		if(str == null)
			return defValue;

		return str.parseBoolean(defValue);
	}

	// Get text contents of element as integer.
	i64 getElementContentInteger(String<u8> tagName, i64 defValue)
	{
		String<u8> str = getElementContent(tagName);

		if(str == null)
			return defValue;

		if(str.length() == 0)
			return defValue;

		if(str.isWhitespace() == true)
			return defValue;

		return str.parseInteger();
	}

	// Get text contents of element as floating point value.
	i64 getElementContentFloat(String<u8> tagName, f64 defValue)
	{
		String<u8> str = getElementContent(tagName);

		if(str == null)
			return defValue;

		if(str.length() == 0)
			return defValue;

		if(str.isWhitespace() == true)
			return defValue;

		return str.parseFloat();
	}

	// Clone this and all children.
	XMLElement clone()
	{
		XMLElement twin();
		if(this.startTag != null)
			twin.startTag = this.startTag.clone();
		if(this.endTag != null)
			twin.endTag = this.endTag.clone();

		if(this.content != null)
			twin.content = this.content.clone();
		twin.contentType = this.contentType;

		if(this.hasChildren())
		{
			twin.childElements = ArrayList<XMLElement>(this.childElements.size());
			for(u64 e=0; e<this.childElements.size(); e++)
			{
				twin.childElements.add(this.childElements[e].clone());
			}
		}

		return twin;
	}

	// Stringify this and all child elements.
	String<u8> toString()
	{
		String<u8> s(256);

		toString(s, 0);

		return s;
	}

	// Append to parentStr.
	void toString(String<u8> parentStr, u32 depth)
	{
		if(startTag != null && endTag != null)
		{
			bool inlineChildContent = false;
			if(childElements != null)
			{
				if(childElements.size() == 1)
				{
					if(childElements[0].startTag == null)
						inlineChildContent = true; // <x>text</text>
				}
				else if(childElements.size() == 0)
					inlineChildContent = true;
			}

			parentStr.append(startTag.toString());

			if(inlineChildContent == false)
			{
				parentStr.append(Chars:NEW_LINE);
				toStringAddTabs(parentStr, depth);
			}

			toStringContent(parentStr); // if any
			toStringChildElements(parentStr, depth); // if any

			if(inlineChildContent == false)
			{
				parentStr.append(Chars:NEW_LINE);
				toStringAddTabs(parentStr, depth);
			}

			parentStr.append(endTag.toString());
		}
		else if(startTag != null)
		{
			parentStr.append(startTag.toString()); // i.e. <name />

			// Well formed shouldn't really have content / child elements for single
			// tags (since no containment) but we handle anyways.
			toStringContent(parentStr); // if any
			toStringChildElements(parentStr, depth); // if any

			parentStr.append(Chars:NEW_LINE);
			toStringAddTabs(parentStr, depth);
		}
		else if(content != null)
		{
			toStringContent(parentStr);

			// Well formed shouldn't really have child elements for content with no
			// tags (since no containment) but we handle anyways.
			toStringChildElements(parentStr, depth); // if any
		}
	}

	// Append whitespace.
	void toStringAddTabs(String<u8> parentStr, u32 depth)
	{
		for(u32 d=0; d<depth; d++)
			parentStr.append(Chars:HTAB);
	}

	// Append text / CDATA / comment content (if any).
	void toStringContent(String<u8> parentStr)
	{
		if(content == null)
			return;
		
		if(contentType == CONTENT_TEXT)
		{
			parentStr.append(XML:encodeText(content));
		}
		else if(contentType == CONTENT_CDATA)
		{
			parentStr.append("<![CDATA[");
			parentStr.append(content);
			parentStr.append("]]>");
		}
		else if(contentType == CONTENT_COMMENT)
		{
			parentStr.append("<!--");
			parentStr.append(XML:encodeText(content));
			parentStr.append("-->");
		}
	}

	// Append child elements (if any).
	void toStringChildElements(String<u8> parentStr, u32 depth)
	{
		if(childElements == null)
			return;

		// do child elements
		for(u64 c=0; c<childElements.size(); c++)
		{
			XMLElement child = childElements[c];
			if(child == null)
				continue;

			child.toString(parentStr, depth + 1);
		}
	}

	// HTML stringify. Handles certain tags (like <script>) with special consideration compared to toString().
	String<u8> toHTML()
	{
		String<u8> s(256);

		toHTML(s, 0);

		return s;
	}

	// Append HTML to parentStr.
	void toHTML(String<u8> parentStr, u32 depth)
	{
		if(startTag != null && endTag != null)
		{
			bool inlineChildContent = false;
			if(childElements != null)
			{
				if(childElements.size() == 1)
				{
					if(childElements[0].startTag == null)
						inlineChildContent = true; // <x>text</text>
				}
				else if(childElements.size() == 0)
					inlineChildContent = true;
			}
			
			parentStr.append(startTag.toString());

			if(inlineChildContent == false)
			{
				parentStr.append(Chars:NEW_LINE);
				toStringAddTabs(parentStr, depth);
			}

			if(startTag.name.compare("script") == true) // script contents must not be encoded etc.
			{
				// add child elements as-is without encoding
				if(childElements != null)
				{
					// do child elements, should only be one for script tags and should be text content
					for(u64 c=0; c<childElements.size(); c++)
					{
						XMLElement child = childElements[c];
						if(child == null)
							continue;

						if(child.content == null)
							continue;
						
						parentStr.append(child.content);
					}
				}
			}
			else
			{
				toStringContent(parentStr); // if any
				toHTMLChildElements(parentStr, depth); // if any

				if(inlineChildContent == false)
				{
					parentStr.append(Chars:NEW_LINE);
					toStringAddTabs(parentStr, depth);
				}
			}

			parentStr.append(endTag.toString());
		}
		else if(startTag != null)
		{
			parentStr.append(startTag.toString()); // i.e. <name />

			// Well formed shouldn't really have content / child elements for single
			// tags (since no containment) but we handle anyways.
			toStringContent(parentStr); // if any
			toHTMLChildElements(parentStr, depth); // if any

			parentStr.append(Chars:NEW_LINE);
			toStringAddTabs(parentStr, depth);
		}
		else if(content != null)
		{
			toStringContent(parentStr);

			// Well formed shouldn't really have child elements for content with no
			// tags (since no containment) but we handle anyways.
			toHTMLChildElements(parentStr, depth); // if any
		}
	}

	// Append child elements (if any) as HTML.
	void toHTMLChildElements(String<u8> parentStr, u32 depth)
	{
		if(childElements == null)
			return;

		// do child elements
		for(u64 c=0; c<childElements.size(); c++)
		{
			XMLElement child = childElements[c];
			if(child == null)
				continue;

			child.toHTML(parentStr, depth + 1);
		}
	}

	// Get direct children that are text content. Does not encode special characters (i.e. < to &lt;).
	String<u8> getChildTextContent()
	{
		if(hasChildren() == false)
			return String<u8>();

		String<u8> s(8);

		// do child elements
		for(u64 c=0; c<childElements.size(); c++)
		{
			XMLElement child = childElements[c];
			if(child.contentType != CONTENT_TEXT)
				continue;

			if(child.content != null)
			{
				s.append(child.content);
			}
		}

		return s;
	}

	// Get direct children that are text content. Does not encode special characters (i.e. < to &lt;).
	String<u8> getChildTextContent(String<u8> defValue)
	{
		String<u8> str = getChildTextContent();
		if(str != null)
			return str;

		return defValue;
	}

	// Assuming this element has a single child element (or no existing element) that is text/comment/CDATA, this sets the text content of that child element.
	void setChildText(String<u8> textVal)
	{
		if(hasChildren() == false)
		{
			XMLElement newTextElem(textVal.clone(), CONTENT_TEXT);
			addChild(newTextElem);
		}
		else
		{
			if(childElements[0].contentType == CONTENT_TEXT || childElements[0].contentType == CONTENT_CDATA || childElements[0].contentType == CONTENT_COMMENT)
			{
				childElements[0].content = textVal.clone();
			}
		}
	}

	// Does this element have child elements?
	bool hasChildren()
	{
		if(childElements == null)
			return false;
		if(childElements.size() == 0)
			return false;

		return true;
	}

	// Number of children.
	u64 getNumChildren()
	{
		if(childElements == null)
			return 0;

		return childElements.size();
	}

	// Add a child element.
	void addChild(XMLElement xmlElem)
	{
		if(childElements == null)
			childElements = ArrayList<XMLElement>(1);

		childElements.add(xmlElem);
	}

	// Add child elements.
	void addChildren(ICollection<XMLElement> xmlElems)
	{
		IIterator<XMLElement> iter = xmlElems.getIterator();
		while(iter.hasNext())
		{
			XMLElement elem = iter.next();
			childElements.add(elem);
		}
	}

	// Get child element by index.
	XMLElement getChild(u64 index)
	{
		if(childElements == null)
			return null;
		
		return childElements[index];
	}

	// Find first child element by tag name. Returns null if not found.
	XMLElement getChild(String<u8> tagName)
	{
		if(childElements == null || tagName == null)
			return null;

		for(u64 r=0; r<childElements.size(); r++)
		{
			XMLElement childElem = childElements[r];
			if(childElem.startTag != null)
			{
				if(childElem.startTag.name != null)
				{
					if(tagName.compare(childElem.startTag.name) == true)
						return childElem;
				}
			}
		}

		return null;
	}

	// Search for all elements matching the name provided.
	ArrayList<XMLElement> getElements(String<u8> tagName)
	{
		ArrayList<XMLElement> elements();
		getElements(tagName, elements);
		return elements;
	}

	// Search for all element matching the name provided.
	void getElements(String<u8> tagName, ArrayList<XMLElement> elementsOut)
	{
		if(startTag == null)
			return;
		
		if(startTag.name.compare(tagName) == true)
			elementsOut.add(this);

		if(childElements == null)
			return;

		for(u64 r=0; r<childElements.size(); r++)
		{
			childElements[r].getElements(tagName, elementsOut);
		}
	}

	// Search for single element matching name/value attribute. If name/value is null, only the other will be compared.
	XMLElement getElementByAttribute(String<u8> name, String<u8> value)
	{
		if(startTag == null)
			return null;

		if(startTag.attributes != null)
		{
			for(u64 a=0; a<startTag.attributes.size(); a++)
			{
				XMLAttribute att = startTag.attributes[a];
				bool match = false;
				if(name != null && att.name != null)
				{
					if(name.compare(att.name) == true)
						match = true;
				}

				if(value != null && att.value != null)
				{
					if(value.compare(att.value) == true)
					{
						if(name == null)
							match = true; // else match will already be true if name matched
					}
					else
						match = false;
				}

				if(match == true)
				{
					return this;
				}
			}
		}

		if(childElements == null)
			return null;

		for(u64 r=0; r<childElements.size(); r++)
		{
			XMLElement foundElem = childElements[r].getElementByAttribute(name, value);
			if(foundElem != null)
				return foundElem;
		}

		return null;
	}

	// Search for elements matching name/value attribute. If name/value is null, only the other will be compared.
	ArrayList<XMLElement> getElementsByAttribute(String<u8> name, String<u8> value)
	{
		ArrayList<XMLElement> elements();
		getElementsByAttribute(name, value, elements);
		return elements;
	}

	// Search for elements matching name/value attribute. If name/value is null, only the other will be compared.
	void getElementsByAttribute(String<u8> name, String<u8> value, ArrayList<XMLElement> elementsOut)
	{
		if(startTag == null)
			return;

		if(startTag.attributes != null)
		{
			for(u64 a=0; a<startTag.attributes.size(); a++)
			{
				XMLAttribute att = startTag.attributes[a];
				bool match = false;
				if(name != null && att.name != null)
				{
					if(name.compare(att.name) == true)
						match = true;
				}

				if(value != null && att.value != null)
				{
					if(name.compare(att.name) == true)
						match = true;
					else
						match = false;
				}

				if(match == true)
				{
					elementsOut.add(this);
					break;
				}
			}
		}

		if(childElements == null)
			return;

		for(u64 r=0; r<childElements.size(); r++)
		{
			childElements[r].getElementsByAttribute(name, value, elementsOut);
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// XMLDoc
////////////////////////////////////////////////////////////////////////////////////////////////////

// Document-Object-Model (DOM) representation of XML/HTML. Partially compliant with the
// "Extensible Markup Language (XML) 1.0" W3C specification for UTF-8 encoded content. See 
// https://www.w3.org/TR/xml. Roots and all branches consist of XMLElement objects. Comment tags can
// be parsed as normal tags or removed as they are parsed.
//
// Supports parsing XML text XMLDoc or serializing XMLDoc to XML text. Optionally can use XMapping
// system to parse/serialize from/to XML directly to/from Pronto objects. Also supports parsing HTML
// (not just XHTML) via the parseHTML method. Use toHTML() when converting documents to string form.
class XMLDoc
{
	ArrayList<XMLElement> roots = null;

	// Empty document.
	void constructor() { }

	// Parse from string.
	void constructor(String<u8> docStr)
	{
		parse(docStr);
	}

	// Release memory.
	void destroy()
	{
		if(roots != null)
		{
			while(roots.size() > 0)
			{
				XMLElement elem = roots.removeLast();
			}

			roots = null;
		}
	}

	// Clone every element.
	XMLDoc clone()
	{
		XMLDoc twin();

		if(this.hasElements())
		{
			twin.roots = ArrayList<XMLElement>(this.roots.size());
			for(u64 e=0; e<this.roots.size(); e++)
			{
				twin.roots.add(this.roots[e].clone());
			}
		}

		return twin;
	}

	// Encode as XML String.
	String<u8> toString()
	{
		String<u8> s(1024);

		if(roots != null)
		{
			for(u64 r=0; r<roots.size(); r++)
			{
				XMLElement root = roots[r];
				if(root != null)
					root.toString(s, 0);
			}
		}

		return s;
	}

	// Encode as HTML String. Handles special tags like <script> contents.
	String<u8> toHTML()
	{
		String<u8> s(1024);

		if(roots != null)
		{
			for(u64 r=0; r<roots.size(); r++)
			{
				XMLElement root = roots[r];
				if(root != null)
					root.toHTML(s, 0);
			}
		}

		return s;
	}

	// Get root element(s) via [index] operator.
	XMLElement get(u64 index)
	{
		if(roots == null)
			return null;
		
		return roots[index];
	}

	// Does this document have any root elements?
	bool hasElements()
	{
		if(roots == null)
			return false;

		if(roots.size() == 0)
			return false;

		return true;
	}

	// Add a root element
	void addElement(XMLElement e)
	{
		if(roots == null)
			roots = ArrayList<XMLElement>();

		roots.add(e);
	}

	// Search for first element-tags matching the name provided, returning content string. Returns null if not found or contains child elements etc.
	String<u8> getElementContent(String<u8> tagName)
	{
		ArrayList<XMLElement> elements = getElements(tagName);

		if(elements.size() == 0)
			return null;

		return elements[0].content;
	}

	// Search for first element-tags matching the name provided, returning content string. Returns null if not found or contains child elements etc.
	String<u8> getElementContent(String<u8> tagName, String<u8> defValue)
	{
		ArrayList<XMLElement> elements = getElements(tagName);

		if(elements.size() == 0)
			return defValue;

		if(elements[0].content != null)
			return elements[0].content;

		return defValue;
	}

	// Search for first element-tags matching the name provided. Get text contents of element as boolean.
	bool getElementContentBoolean(String<u8> tagName, bool defValue)
	{
		String<u8> str = getElementContent(tagName);
		
		if(str == null)
			return defValue;

		return str.parseBoolean(defValue);
	}

	// Search for first element-tags matching the name provided. Get text contents of element as integer.
	i64 getElementContentInteger(String<u8> tagName, i64 defValue)
	{
		String<u8> str = getElementContent(tagName);

		if(str == null)
			return defValue;

		if(str.length() == 0)
			return defValue;

		if(str.isWhitespace() == true)
			return defValue;

		return str.parseInteger();
	}

	// Search for first element-tags matching the name provided. Get text contents of element as floating point value.
	i64 getElementContentFloat(String<u8> tagName, f64 defValue)
	{
		String<u8> str = getElementContent(tagName);

		if(str == null)
			return defValue;

		if(str.length() == 0)
			return defValue;

		if(str.isWhitespace() == true)
			return defValue;

		return str.parseFloat();
	}

	// Search for first element-tags matching the name provided. Returns null if not found.
	XMLElement getElement(String<u8> tagName)
	{
		ArrayList<XMLElement> elements = getElements(tagName);

		if(elements.size() == 0)
			return null;

		return elements[0];
	}

	// Search for all element-tags matching the name provided.
	ArrayList<XMLElement> getElements(String<u8> tagName)
	{
		ArrayList<XMLElement> elements();
		if(roots == null)
			return elements;

		for(u64 r=0; r<roots.size(); r++)
		{
			roots[r].getElements(tagName, elements);
		}

		return elements;
	}

	// Search for elements containing attribute name/value.
	ArrayList<XMLElement> getElementsByAttribute(String<u8> name, String<u8> val)
	{
		ArrayList<XMLElement> elements();
		if(roots == null)
			return elements;

		for(u64 r=0; r<roots.size(); r++)
		{
			roots[r].getElementsByAttribute(name, val, elements);
		}

		return elements;
	}

	// Search for a single element containing a presumably unique attribute name/value.
	XMLElement getElementByAttribute(String<u8> name, String<u8> val)
	{
		if(roots == null)
			return null;

		for(u64 r=0; r<roots.size(); r++)
		{
			XMLElement foundElem = roots[r].getElementByAttribute(name, val);
			if(foundElem != null)
				return foundElem;
		}

		return null;
	}

	// Append error message inclduing line number.
	String<u8> makeErrorMsg(String<u8> xmlStr, u64 charIndex, String<u8> msg)
	{
		String<u8> errMsg(msg.length() + 16);

		u64 lineNum = 1;
		for(u64 c=0; c<charIndex; c++)
		{
			if(xmlStr.chars[c] == Chars:NEW_LINE)
				lineNum++;
		}

		errMsg.append("Error on line ");
		errMsg.append(String<u8>:formatNumber(lineNum));
		errMsg.append(" : ");
		errMsg.append(msg);

		return errMsg;
	}

	// Parse UTF-8 encoded XML document. Comments (i.e. "<!-- -->") will be ignored.
	bool parse(String<u8> s)
	{
		String<u8> errs();
		return parse(s, false, errs);
	}

	// Parse UTF-8 encoded XML document. If you want comments to be parsed and kept in the parse tree, pass true for keepComments.
	bool parse(String<u8> s, bool keepComments)
	{
		String<u8> errs();
		return parse(s, keepComments, errs);
	}

	// Parse UTF-8 encoded XML document.
	bool parse(String<u8> s, bool keepComments, String<u8> errMsgOut)
	{
		this.roots   = ArrayList<XMLElement>();
		if(s == null)
			return false;
		if(s.length() == 0)
			return false;

		XMLElement fakeParentElem();
		i64 parsedToIndex = parseNext(s, keepComments, 0, s.length()-1, fakeParentElem, errMsgOut);
		i64 lastIndex = -1;
		while(parsedToIndex > 0)
		{
			parsedToIndex = parseNext(s, keepComments, parsedToIndex, s.length()-1, fakeParentElem, errMsgOut);
			if(parsedToIndex <= lastIndex)
				break; // done, or failed to make progress
			lastIndex = parsedToIndex;
		}

		if(parsedToIndex < 0)
			return false;

		this.roots = fakeParentElem.childElements;
		fakeParentElem.childElements = null;

		return true;
	}

	// Recursive parse. Returns the character index it parsed to in String s, or -1 for failure.
	i64 parseNext(String<u8> s, bool keepComments, i64 curPos, i64 maxIndex, XMLElement parentElem, String<u8> errMsgOut)
	{
		i64 nextTagStartIndex = s.findNext(Chars:OPEN_ANGLE_BRACKET, curPos, maxIndex);
		if(nextTagStartIndex < 0)
		{
			if(curPos <= maxIndex)
			{
				String<u8> potentialText = s.subString(curPos, maxIndex);
				if(potentialText.findNextNonWhitespace(0) >= 0)
				{
					// not just whitespace
					String<u8> decodedText = XML:decodeText(potentialText);
					XMLElement exElem(decodedText, XMLElement:CONTENT_TEXT);
					parentElem.addChild(exElem);
				}
			}

			return 0; // done
		}

		// 1. CDATA special tag single tag
		// 2. Comment special single tag
		// 3. Normal tags.

		// check if we need a content element (i.e. <tagA> some text... <tagB> </tagB> more text </tagA>)
		if(curPos < nextTagStartIndex)
		{
			if(s.findNextNonWhitespace(curPos, nextTagStartIndex-1) >= 0)
			{
				// not just whitespace
				String<u8> potentialText = s.subString(curPos, nextTagStartIndex-1);
				String<u8> decodedText = XML:decodeText(potentialText);
				XMLElement exElem(decodedText, XMLElement:CONTENT_TEXT);
				parentElem.addChild(exElem);
			}

			curPos = nextTagStartIndex;
		}

		if(s.chars[nextTagStartIndex+1] == Chars:EXCLAMATION)
		{
			if(s.compare(nextTagStartIndex+1, "![CDATA[", 0, 8, true) == true)
			{
				// find end "]]>"
				i64 cdataEndIndex = s.findNext("]]>", nextTagStartIndex + 8, maxIndex);
				if(cdataEndIndex < 0)
				{
					if(errMsgOut != null)
						errMsgOut.append(makeErrorMsg(s, nextTagStartIndex+1, "Cannot find CDATA section end."), "\n");

					return -1;
				}

				String<u8> cdataText = s.subString(nextTagStartIndex + 9, cdataEndIndex-1);
				XMLElement cdataElement(cdataText, XMLElement:CONTENT_CDATA);
				parentElem.addChild(cdataElement);

				curPos = cdataEndIndex+3;

				return curPos;
			}
			else if(s.compare(nextTagStartIndex+1, "!--", 0, 3, true) == true)
			{
				// find end "-->"
				i64 commentEndIndex = s.findNext("-->", nextTagStartIndex + 3, maxIndex);
				if(commentEndIndex < 0)
				{
					if(errMsgOut != null)
						errMsgOut.append(makeErrorMsg(s, nextTagStartIndex+1, "Cannot find comment section end."), "\n");

					return -1;
				}

				// Drop comments?
				if(keepComments == true)
				{
					String<u8> commentText = s.subString(nextTagStartIndex + 4, commentEndIndex-1);
					XMLElement commentElem(XML:decodeText(commentText), XMLElement:CONTENT_COMMENT);
					parentElem.addChild(commentElem);
				}

				curPos = commentEndIndex+3;

				return curPos;
			}
		}
		
		i64 tagEndIndex = s.findNext(Chars:CLOSE_ANGLE_BRACKET, nextTagStartIndex+1, maxIndex);
		if(tagEndIndex < 0)
		{
			if(errMsgOut != null)
				errMsgOut.append(makeErrorMsg(s, nextTagStartIndex+1, "Cannot find end of tag."), "\n");

			return -1;
		}

		curPos = tagEndIndex+1;

		XMLTag nextTag = parseTag(s, nextTagStartIndex, tagEndIndex);
		if(nextTag == null)
		{
			if(errMsgOut != null)
				errMsgOut.append(makeErrorMsg(s, nextTagStartIndex, "Failed to parse tag contents."), "\n");

			return -1;
		}

		// end tag?
		if(nextTag.tagType == XMLTag:TYPE_END)
		{
			// must match parent end tag or it's out of order
			if(parentElem != null)
			{
				if(nextTag.name.compare(parentElem.startTag.name) == true)
				{
					parentElem.endTag = nextTag;
					return tagEndIndex+1; // done
				}
			}

			// else didn't match parent, this end tag is out-of-order
			if(errMsgOut != null)
			{
				String<u8> errMsgEndTag("Found out of order end tag: ");
				errMsgEndTag.append(nextTag.name);
				errMsgOut.append(makeErrorMsg(s, nextTagStartIndex, errMsgEndTag), "\n");
			}

			return -1;
		}

		// single?
		if(nextTag.tagType == XMLTag:TYPE_SINGLE)
		{
			// ok, just add to parent
			XMLElement newElem();
			newElem.startTag = nextTag;
			parentElem.addChild(newElem);

			return tagEndIndex+1; // done 
		}

		// Ok, this is a start tag, find it's end match
		XMLElement curParentElem();
		curParentElem.startTag = nextTag;
		parentElem.addChild(curParentElem);

		// parse child elements until end tag found
		while(curParentElem.endTag == null)
		{
			i64 nextPos = parseNext(s, keepComments, curPos, s.length()-1, curParentElem, errMsgOut);
			if(nextPos < 0)
				return -1; // failed

			if(nextPos <= curPos)
				return -1; // failed to make progress
				
			curPos = nextPos;
		}
		
		return curPos;
	}

	// Parse UTF-8 encoded HTML document. HTML isn't strictly conforming to XML (except hardly used XHTML). This parsing mode can parse most HTML constructs. This can also be used to attempt to parse malformed XML in general, but is about 10x slower.
	bool parseHTML(String<u8> s)
	{
		String<u8> errMsgOut();
		return parseHTML(s, false, errMsgOut);
	}

	// Parse UTF-8 encoded HTML document. HTML isn't strictly conforming to XML (except hardly used XHTML). This parsing mode can parse most HTML constructs. This can also be used to attempt to parse malformed XML in general, but is about 10x slower.
	bool parseHTML(String<u8> s, bool keepComments, String<u8> errMsgOut)
	{
		this.roots = ArrayList<XMLElement>();
		if(s == null)
			return false;
		if(s.length() == 0)
			return false;

		XMLElement fakeParentElem();
		i64 parsedToIndex = parseHTMLNext(s, keepComments, 0, s.length()-1, fakeParentElem, errMsgOut);
		i64 lastIndex = -1;
		while(parsedToIndex > 0)
		{
			parsedToIndex = parseHTMLNext(s, keepComments, parsedToIndex, s.length()-1, fakeParentElem, errMsgOut);
			if(parsedToIndex <= lastIndex)
				break; // done, or failed to make progress
			lastIndex = parsedToIndex;
		}

		if(parsedToIndex < 0)
			return false;

		this.roots = fakeParentElem.childElements;
		fakeParentElem.childElements = null;

		return true;
	}

	// Recursive parse. Returns the character index it parsed to in String s, or -1 for failure.
	i64 parseHTMLNext(String<u8> s, bool keepComments, i64 curPos, i64 maxIndex, XMLElement parentElem, String<u8> errMsgOut)
	{
		i64 nextTagStartIndex = s.findNext(Chars:OPEN_ANGLE_BRACKET, curPos, maxIndex);
		if(nextTagStartIndex < 0)
		{
			if(curPos <= maxIndex)
			{
				String<u8> potentialText = s.subString(curPos, maxIndex);
				if(potentialText.findNextNonWhitespace(0) >= 0)
				{
					// not just whitespace
					XMLElement exElem(XML:decodeText(potentialText), XMLElement:CONTENT_TEXT);
					parentElem.addChild(exElem);
				}
			}

			return 0; // done
		}

		// 1. CDATA special tag single tag
		// 2. Comment special single tag
		// 3. Normal tags.

		// check if we need a content element (i.e. <tagA> some text... <tagB> </tagB> more text </tagA>)
		if(curPos < nextTagStartIndex)
		{
			if(s.findNextNonWhitespace(curPos, nextTagStartIndex-1) >= 0)
			{
				// not just whitespace
				String<u8> potentialText = s.subString(curPos, nextTagStartIndex-1);
				XMLElement exElem(XML:decodeText(potentialText), XMLElement:CONTENT_TEXT);
				parentElem.addChild(exElem);
			}

			curPos = nextTagStartIndex;
		}

		if(s.chars[nextTagStartIndex+1] == Chars:EXCLAMATION)
		{
			if(s.compare(nextTagStartIndex+1, "![CDATA[", 0, 8, true) == true)
			{
				// find end "]]>"
				i64 cdataEndIndex = s.findNext("]]>", nextTagStartIndex + 8, maxIndex);
				if(cdataEndIndex < 0)
				{
					if(errMsgOut != null)
						errMsgOut.append(makeErrorMsg(s, nextTagStartIndex+1, "Cannot find CDATA section end."), "\n");

					return -1;
				}

				String<u8> cdataText = s.subString(nextTagStartIndex + 9, cdataEndIndex-1);
				XMLElement cdataElement(cdataText, XMLElement:CONTENT_CDATA);
				parentElem.addChild(cdataElement);

				curPos = cdataEndIndex+3;

				return curPos;
			}
			else if(s.compare(nextTagStartIndex+1, "!--", 0, 3, true) == true)
			{
				// find end "-->"
				i64 commentEndIndex = s.findNext("-->", nextTagStartIndex + 3, maxIndex);
				if(commentEndIndex < 0)
				{
					if(errMsgOut != null)
						errMsgOut.append(makeErrorMsg(s, nextTagStartIndex+1, "Cannot find comment section end."), "\n");

					return -1;
				}

				// Drop comments?
				if(keepComments == true)
				{
					String<u8> commentText = s.subString(nextTagStartIndex + 4, commentEndIndex-1);
					XMLElement commentElem(XML:decodeText(commentText), XMLElement:CONTENT_COMMENT);
					parentElem.addChild(commentElem);
				}

				curPos = commentEndIndex+3;

				return curPos;
			}
		}
		
		i64 tagEndIndex = s.findNext(Chars:CLOSE_ANGLE_BRACKET, nextTagStartIndex+1, maxIndex);
		if(tagEndIndex < 0)
		{
			if(errMsgOut != null)
				errMsgOut.append(makeErrorMsg(s, nextTagStartIndex+1, "Cannot find end of tag."), "\n");

			return -1;
		}

		curPos = tagEndIndex+1;

		XMLTag nextTag = parseTag(s, nextTagStartIndex, tagEndIndex);
		if(nextTag == null)
		{
			if(errMsgOut != null)
				errMsgOut.append(makeErrorMsg(s, nextTagStartIndex, "Failed to parse tag contents."), "\n");

			return -1;
		}

		// special handling of script tag
		if(nextTag.name.compare("script") == true)
		{
			i64 scriptEndIndex = s.findNext("</script", nextTagStartIndex + 5, maxIndex);
			if(scriptEndIndex < 0)
			{
				if(errMsgOut != null)
					errMsgOut.append(makeErrorMsg(s, nextTagStartIndex, "Failed to find script end tag."), "\n");

				return -1;
			}

			i64 scriptCloseEndIndex = s.findNext(">", scriptEndIndex, maxIndex);
			if(scriptCloseEndIndex < 0)
			{
				if(errMsgOut != null)
					errMsgOut.append(makeErrorMsg(s, scriptEndIndex, "Failed to parse script end tag."), "\n");

				return -1;
			}

			// ok, add script element and add text element (script contents) to script element
			XMLElement scriptElem();
			scriptElem.startTag = nextTag;
			scriptElem.endTag   = parseTag(s, scriptEndIndex, scriptCloseEndIndex);
			parentElem.addChild(scriptElem);

			String<u8> scriptText = s.subString(tagEndIndex + 1, scriptEndIndex-1);
			XMLElement scriptTextElem(scriptText, XMLElement:CONTENT_TEXT);
			scriptElem.addChild(scriptTextElem);

			curPos = scriptCloseEndIndex+1;
			return curPos;
		}

		// end tag?
		if(nextTag.tagType == XMLTag:TYPE_END)
		{
			// must match parent end tag or it's out of order
			if(parentElem != null)
			{
				if(nextTag.name.compare(parentElem.startTag.name) == true)
				{
					parentElem.endTag = nextTag;
					return tagEndIndex+1; // done
				}
			}

			// else didn't match parent, this end tag is out-of-order
			if(errMsgOut != null)
			{
				String<u8> errMsgEndTag("Found out of order end tag: ");
				errMsgEndTag.append(nextTag.name);
				errMsgOut.append(makeErrorMsg(s, nextTagStartIndex, errMsgEndTag), "\n");
			}

			return -1;
		}

		// confirm this tag ends somewhere
		i64 checkEndTagIndex = -1;
		if(nextTag.tagType != XMLTag:TYPE_SINGLE)
		{
			String<u8> tempName("</");
			tempName.append(nextTag.name);
			checkEndTagIndex = s.findNext(tempName, nextTagStartIndex, maxIndex);
		}

		// single?
		if(nextTag.tagType == XMLTag:TYPE_SINGLE || checkEndTagIndex < 0)
		{
			// ok, just add to parent
			XMLElement newElem();
			newElem.startTag = nextTag;
			parentElem.addChild(newElem);

			return tagEndIndex+1; // done 
		}

		// Ok, this is a start tag, find it's end match
		XMLElement curParentElem();
		curParentElem.startTag = nextTag;
		parentElem.addChild(curParentElem);

		// parse child elements until end tag found
		while(curParentElem.endTag == null)
		{
			i64 nextPos = parseHTMLNext(s, keepComments, curPos, s.length()-1, curParentElem, errMsgOut);
			if(nextPos < 0)
				return -1; // failed

			if(nextPos <= curPos)
				return -1; // failed to make progress

			curPos = nextPos;
		}
		
		return curPos;
	}

	// Parse tag. Name, attribtues etc. Assumes s[0] = '<'' and s[length()-1] = '>' of tag.
	XMLTag parseTag(String<u8> s, i64 sStartIndex, i64 sEndIndex)
	{
		XMLTag tag();

		i64 nameStartIndex = s.findNextNonWhitespace(sStartIndex + 1, sEndIndex);
		if(nameStartIndex < 0)
			return null;

		i64 nameEndIndex = s.findNextWhitespace(nameStartIndex, sEndIndex);
		if(nameEndIndex == -1)
			nameEndIndex = sEndIndex-1; // inclusive range
		else
			nameEndIndex--; // inclusive range

		if(nameEndIndex < 0)
			return null;

		i64 tagEndIndex = sEndIndex;
		i64 attributesEndIndex = tagEndIndex-1;

		if(s.chars[nameStartIndex] == Chars:FORWARD_SLASH)
		{
			tag.name    = s.subString(nameStartIndex+1, nameEndIndex);
			tag.tagType = XMLTag:TYPE_END;
		}
		else if(s.chars[tagEndIndex-1] == Chars:FORWARD_SLASH)
		{
			tag.name    = s.subString(nameStartIndex, nameEndIndex);
			tag.tagType = XMLTag:TYPE_SINGLE;
			attributesEndIndex--;
		}
		else
		{
			tag.name    = s.subString(nameStartIndex, nameEndIndex);
			tag.tagType = XMLTag:TYPE_START;
		}

		// tag attributes?
		if((nameEndIndex+1) <= attributesEndIndex)
		{
			String<u8> attributesStr = s.subString(nameEndIndex+1, attributesEndIndex);
			tag.attributes = parseAttributes(attributesStr);
		}

		return tag;
	}

	// Parse attributes from string.
	ArrayList<XMLAttribute> parseAttributes(String<u8> s)
	{
		ArrayList<XMLAttribute> attributes();

		i64 curIndex = 0;
		i64 lastIndex = -1;
		while(curIndex < s.length())
		{
			i64 nameStartIndex = s.findNextNonWhitespace(curIndex);
			if(nameStartIndex < 0)
				break;

			i64 nameEndIndex = s.findNextWhitespace(nameStartIndex);
			nameEndIndex--;
			i64 equalsIndex  = s.findNext(Chars:EQUALS, nameStartIndex);
			if((equalsIndex != -1 && equalsIndex < nameEndIndex) || nameEndIndex < 0)
				nameEndIndex = equalsIndex - 1;
			if(nameEndIndex < 0)
				break;

			curIndex = nameEndIndex+1;

			String<u8> name = s.subString(nameStartIndex, nameEndIndex);
			name.trimWhitespace();

			String<u8> value;
			if(equalsIndex > 0)
			{
				// parse value
				curIndex = equalsIndex+1;

				i64 valStartIndex = s.findNextNonWhitespace(curIndex);
				if(valStartIndex >= 0)
				{
					i64 valEndIndex = -1;
					if(s.chars[valStartIndex] == Chars:DOUBLE_QUOTE)
					{
						valEndIndex = s.findNext(Chars:DOUBLE_QUOTE, valStartIndex+1);
						valEndIndex--; // backtrack off of "
						valStartIndex++; // skip "

						curIndex = valEndIndex+2; // skip quote
					}
					else
					{
						valEndIndex = s.findNextWhitespace(valStartIndex+1);
						valEndIndex--;
						if(valEndIndex < 0)
							valEndIndex = s.length()-1;

						curIndex = valEndIndex+1;
					}

					if(valStartIndex <= valEndIndex)
						value = XML:decodeText(s.subString(valStartIndex, valEndIndex));
				}
			}
			else
				value = String<u8>();

			XMLAttribute attribute(name, value);
			attributes.add(attribute);

			if(curIndex <= lastIndex)
				break; // failed to make progress

			lastIndex = curIndex;
		}

		return attributes;
	}

	// Write the properties of the passed-in object and all of it's connected objects to an XML tree.
	shared XMLDoc objToXML(IObj obj)
	{
		XMapping tempMapping();
		XMLDoc doc = objToXML(obj, tempMapping);
		return doc;
	}

	// Write the properties of the passed-in object and all of it's connected objects to an XML tree.
	shared XMLDoc objToXML(IObj obj, XMapping mapping)
	{
		XMLDoc xmlDoc();

		String<u8> rootClassName = obj.getClassName();
		String<u8> rootXMLName   = rootClassName;
		ProntoType rootClass = ProntoType(rootClassName);
		XClassMapping rootClassMapping = mapping.getClassPronto(rootClass.namespace, rootClass.className);
		if(rootClassMapping != null)
		{
			if(rootClassMapping.mapAs == XPropertyMapping:MAP_AS_EXCLUDED)
				return xmlDoc; // weird, but we follow

			rootXMLName = rootClassMapping.xName;
		}

		XMLElement rootElem(); // root
		rootElem.childElements = ArrayList<XMLElement>();
		rootElem.startTag = XMLTag(XClassMapping:classNameToXName(rootXMLName.clone()), XMLTag:TYPE_START);
		rootElem.endTag   = XMLTag(XClassMapping:classNameToXName(rootXMLName.clone()), XMLTag:TYPE_END);

		xmlDoc.roots = ArrayList<XMLElement>();
		xmlDoc.roots.add(rootElem);

		objOrArrayToXML(obj, mapping, rootElem);

		return xmlDoc;
	}

	// Write the properties of the passed-in object and all of it's connected objects to an XML tree.
	shared void objOrArrayToXML(IObj obj, XMapping mapping, XMLElement parentElement)
	{
		if(obj == null || parentElement == null)
			return;

		String<u8> objClassName = obj.getClassName();
		ProntoType objType = ProntoType(objClassName);

		if(objType.isArray() == true)
		{
			IArray arr = obj;
			if(arr == null)
				return; // weird

			arrayToXML(arr, mapping, parentElement);
		}
		else
		{
			objToXML(obj, mapping, parentElement);
		}
	}

	// Create the elements of the passed-in array and place in parentElement.
	shared void arrayToXML(IArray arr, XMapping mapping, XMLElement parentElement)
	{
		if(arr == null || parentElement == null)
			return;

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
				// Use class name for each element (or xml mapped name).
				IObj elemObj = Array:getElementObj(arr, a);
				if(elemObj == null)
					continue; // skip

				// Array could be IObj[] with each element being different class like String, Cat, Dog etc.
				ProntoType elemType = ProntoType(elemObj.getClassName());

				XClassMapping elemClassMapping = mapping.getClassPronto(elemType.namespace, elemType.className);
				if(elemClassMapping == null)
					elemClassMapping = XClassMapping(elemType.namespace, elemType.className, elemType.className);

				String<u8> tagName = XClassMapping:classNameToXName(elemClassMapping.xName);
				XMLElement elemElem(XMLTag(tagName), XMLTag(tagName));
				elemElem.childElements = ArrayList<XMLElement>();
				parentElement.addChild(elemElem);

				objOrArrayToXML(elemObj, mapping, elemElem);
			}
		}
		else // array of primitives or vectors
		{
			String<u8> valsStr = XMappingUtils:arrayToString(arr, mapping.numFracDigits);
			parentElement.addChild(XMLElement(valsStr, XMLElement:CONTENT_TEXT));
		}
	}

	// Write the class-name element and properties of the passed-in object and all of it's connected objects to the XML tree.
	shared void objToXML(IObj obj, XMapping mapping, XMLElement parentElement)
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
			XMLElement strContentElem(String<u8>(objStr), XMLElement:CONTENT_TEXT);
			parentElement.addChild(strContentElem);
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

			if(propMapping.mapAs == XPropertyMapping:MAP_AS_ATTRIBUTE)
			{
				String<u8> strVal = XMappingUtils:getPropertyAsString(obj, prop.name, mapping.numFracDigits);

				if(strVal != null && parentElement.startTag != null)
				{
					String<u8> attrName = XClassMapping:classNameToXName(propMapping.xName.clone());
					parentElement.startTag.addAttribute(attrName, strVal.clone());
				}

				continue;
			}

			XMLElement curParentElement = parentElement;
			if(propMapping.mapAs != XPropertyMapping:MAP_AS_CHILDREN_ONLY)
			{
				String<u8> tagName = XClassMapping:classNameToXName(propMapping.xName.clone());
				XMLElement tagElem(XMLTag(tagName.clone()), XMLTag(tagName.clone()));
				tagElem.childElements = ArrayList<XMLElement>();

				parentElement.addChild(tagElem);

				curParentElement = tagElem;
			}

			if(prop.type.typeID == Type:OBJ)
			{
				IObj childObj = Class:getPropertyValueObj(obj, prop.name);
				if(childObj != null)
					objOrArrayToXML(childObj, mapping, curParentElement);
			}
			else // primitive scalar or vector
			{
				String<u8> strNum = XMappingUtils:getPropertyAsString(obj, prop.name, mapping.numFracDigits);
				curParentElement.addChild(XMLElement(strNum, XMLElement:CONTENT_TEXT));
			}
		}
	}

	// Read the XML values into a tree of Pronto objects. Pronto will automatically
	// match elements with releveants classes.
	shared ArrayList<IObj> xmlToObj(XMLDoc xmlDoc)
	{
		XMapping mapping(); // default mapping will be filled-in as we go
		return xmlToObj(mapping, xmlDoc);
	}

	// Read the XML values into a tree of Pronto objects. You provide some (or all) possible objects 
	// class names that could be mapped from the XML to Pronto objects and this algorithm determines
	// matches based on XML element names and object class/property names. It's a little bit of
	// dynamic magic.
	shared ArrayList<IObj> xmlToObj(XMapping mapping, XMLDoc xmlDoc)
	{
		ArrayList<IObj> objRoots();
		if(xmlDoc.roots == null)
			return objRoots;

		// Build up a list of all class properties (do it once for efficency)
		for(u64 c=0; c<mapping.classes.size(); c++)
			mapping.classes[c].mapMissingProperties();

		// Process XML document roots
		for(u64 r=0; r<xmlDoc.roots.size(); r++)
		{
			XMLElement xmlElem = xmlDoc.roots[r];
			IObj obj = xmlToObj(mapping, null, xmlElem);
			if(obj != null)
				objRoots.add(obj);
		}

		return objRoots;
	}

	// Process XML element. clsMapping can be null, in which case a class mapping will be auto-selected (if possible).
	shared IObj xmlToObj(XMapping mapping, XClassMapping clsMapping, XMLElement xmlElem)
	{
		if(xmlElem == null)
			return null;

		// pick the best class that matches this element
		if(xmlElem.startTag != null)
		{
			if(clsMapping == null)
			{
				clsMapping = mapping.getClass(xmlElem.startTag.name);
				if(clsMapping == null)
				{
					// try to create a new class mapping
					String<u8> useClassName = XClassMapping:classNameFromXName(xmlElem.startTag.name);
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

			if(clsMapping != null)
			{
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
						if(xmlElem.hasChildren())
						{
							for(u64 c=0; c<xmlElem.childElements.size(); c++)
							{
								IObj childObj = xmlToObj(mapping, null, xmlElem.childElements[c]);
								if(childObj != null)
									tempList.add(childObj);
							}
						}

						// create array
						obj = Class:createArray(clsName, tempList.size());
						IObj[] objs = obj;

						// add objects
						for(u64 a=0; a<tempList.size(); a++)
						{
							objs[a] = tempList[a];
						}

						return obj;
					}
					else // array of primitive scalars/vectors
					{
						if(xmlElem.hasChildren())
						{
							String<u8> arrValsStr = null;
							if(xmlElem.childElements.size() == 1)
							{
								if(xmlElem.childElements[0].content != null)
								{
									arrValsStr = String<u8>(xmlElem.childElements[0].content);
								}
							}

							if(arrValsStr != null)
							{
								IArray arr = XMappingUtils:stringToArray(clsType, arrValsStr);
								return arr;
							}
							else // parse each tag as a single value
							{
								ProntoType elemType = clsType.getElementType();
								u64 arrNumElem = xmlElem.childElements.size();
								if(elemType.numElements > 1)
									arrNumElem /= elemType.numElements;

								IArray arr = Class:createArray(clsType.getFullClassName(), arrNumElem);

								for(u64 c=0; c<xmlElem.childElements.size(); c++)
								{
									XMLElement valTagElem = xmlElem.childElements[c];
									if(valTagElem == null)
										continue;

									String<u8> valStr = null;
									if(valTagElem.content != null)
										valStr = valTagElem.content; // weird, but ok...
									else if(valTagElem.hasChildren() == true)
										valStr = valTagElem.childElements[0].content;

									if(valStr == null)
										continue;
								
									u64 e = c;
									u64 v = 0;
									if(elemType.numElements > 0) // vector
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
				}

				obj = Class:createObj(clsName);
				if(obj == null)
					return null; // wtf

				xmlAttributesToObjProps(mapping, clsMapping, xmlElem, obj);
				xmlChildElementsToObjProps(mapping, clsMapping, xmlElem, obj);
				
				return obj;
			}
		}
		else if(xmlElem.hasChildren() == false)
		{
			if(xmlElem.content != null)
			{
				String<u8> strObj(xmlElem.content);
				return strObj;
			}
			else
			{
				// um?
				return null;
			}
		}

		return null;
	}

	// Map attributes of XMLElement to a pronto object's properties (where match found).
	shared void xmlAttributesToObjProps(XMapping mapping, XClassMapping clsMapping, XMLElement xmlElem, IObj obj)
	{
		if(xmlElem.startTag == null)
			return;

		if(xmlElem.startTag.attributes == null)
			return;

		for(u64 a=0; a<xmlElem.startTag.attributes.size(); a++)
		{
			// find match
			XPropertyMapping propMapping = clsMapping.getProperty(xmlElem.startTag.attributes[a].name);

			if(propMapping == null)
				continue;

			if(propMapping.type == null)
				continue;

			if(propMapping.type.isArray() == true)
			{
				ProntoType elemType = propMapping.type.getElementType();
				if(elemType.typeID == Type:OBJ)
				{
					// this doesn't really make sense
					continue;
				}
			}

			// parse scalar, string or array of integers/floats/vectors (if possible)
			XMappingUtils:setPropertyFromString(obj, propMapping.propName, propMapping.type, xmlElem.startTag.attributes[a].value);
		}
	}

	// Map attributes of XMLElement to a pronto object's properties (where match found).
	shared void xmlChildElementsToObjProps(XMapping mapping, XClassMapping clsMapping, XMLElement xmlElem, IObj obj)
	{
		if(xmlElem.hasChildren() == false)
			return;

		if(clsMapping == null)
			return;

		for(u64 c=0; c<xmlElem.childElements.size(); c++)
		{
			// find match
			XPropertyMapping propMapping = null;
			String<u8> valStr = null;

			XMLElement childElem = xmlElem.childElements[c];
			if(childElem == null)
				continue;

			if(childElem.startTag != null)
			{
				propMapping = clsMapping.getProperty(childElem.startTag.name);
				if(propMapping == null)
					continue; // nothing we can do

				if(propMapping.type != null)
				{
					if(propMapping.type.typeID == Type:OBJ)
					{
						if(propMapping.type.isClass(String<u8>("String<u8>")) == true)
						{
							// handled below
						}
						else // arbitrary object
						{
							XClassMapping propertyClassMapping = mapping.getClass(propMapping.type.className);
							if(propertyClassMapping == null)
								propertyClassMapping = mapping.getClass(childElem.startTag.name);

							if(propertyClassMapping == null)
							{
								// try to create a new class mapping
								IObj unknownObj = Class:createObj(XClassMapping:classNameFromXName(propMapping.type.className));
								if(unknownObj == null)
									unknownObj = Class:createObj(XClassMapping:classNameFromXName(childElem.startTag.name));

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

							if(propertyClassMapping != null)
							{
								IObj parsedPropObj = xmlToObj(mapping, propertyClassMapping, childElem);
								Class:setPropertyValueObj(obj, propMapping.propName, parsedPropObj);
								continue;
							}
						}
					}
				}
			}

			// we didn't parse an object
			if(propMapping == null)
				continue; // nothing we can do

			if(childElem.hasChildren() == true)
			{
				if(childElem.childElements[0].content != null)
					valStr = childElem.childElements[0].content;
			}

			if(valStr != null)
			{
				XMappingUtils:setPropertyFromString(obj, propMapping.propName, propMapping.type, valStr);
			}
		}	
	}
}