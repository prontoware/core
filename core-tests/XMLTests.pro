////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class XMLEmailTest
{
	String<u8> to;
	String<u8> from;
	String<u8> subject;
	String<u8> body;

	void constructor(String<u8> to, String<u8> from, String<u8> subject, String<u8> body)
	{
		this.to      = to;
		this.from    = from;
		this.subject = subject;
		this.body    = body;
	}
}

class XMLTypesTest
{
	String<u8> name = null;
	u8       a = 0;
	f32      b = 1;
	u32[4]   c = u32(1, 2, 3, 4);
	u32[]    d = null;
	f32[2][] e = null;
	IObj[] children = null;
}

class XMLNestedTest
{
	String<u8> name = null;
	XMLEmailTest email = null;
}

class XMLParsingSimpleTests implements IUnitTest
{
	void run()
	{
		String<u8> str(256);
		str.append("<email>");
		str.append("	<from>mike@prontoware.com</from>");
		str.append("    <to>derek@prontoware.com</to>");
		str.append("    <subject>Fix it!</subject>");
		str.append("    <body>The system is down.&lt;&gt;&apos;&quot;&amp;</body>"); // test decoding chars
		str.append("</email>");

		XMLDoc doc();
		test(doc.parse(str) == true);
		test(doc.roots != null);
		test(doc.roots.size() == 1);

		XMLElement rootElem = doc.roots[0];
		test(rootElem != null);
		test(rootElem.startTag != null && rootElem.endTag != null);
		test(rootElem.startTag.name.compare("email") == true);
		test(rootElem.startTag.tagType == XMLTag:TYPE_START);
		test(rootElem.endTag.name.compare("email") == true);
		test(rootElem.endTag.tagType == XMLTag:TYPE_END);
		test(rootElem.childElements != null);
		test(rootElem.childElements.size() == 4);

		// from field
		test(rootElem.childElements[0].startTag.name.compare("from") == true);
		test(rootElem.childElements[0].childElements != null);
		test(rootElem.childElements[0].childElements.size() == 1);
		test(rootElem.childElements[0].childElements[0].content != null);
		test(rootElem.childElements[0].childElements[0].content.compare("mike@prontoware.com") == true);

		// body field
		test(rootElem.childElements[3].startTag.name.compare("body") == true);
		test(rootElem.childElements[3].childElements != null);
		test(rootElem.childElements[3].childElements.size() == 1);
		test(rootElem.childElements[3].childElements[0].content != null);
		test(rootElem.childElements[3].childElements[0].content.compare("The system is down.<>'\"&") == true);
	}
}

class XMLParsingAttributesTests implements IUnitTest
{
	void run()
	{
		String<u8> str(256);
		str.append("<email numPeople=1 name=\"Mike Sikora\">mike@prontoware.com</email>");
		str.append("<email numPeople=1 name=\"Jess Sikora\">jess@prontoware.com</email endValue=33>");

		XMLDoc doc();
		test(doc.parse(str) == true);
		test(doc.roots != null);
		test(doc.roots.size() == 2);

		XMLElement rootElemA = doc.roots[0];
		test(rootElemA != null);
		test(rootElemA.startTag != null && rootElemA.endTag != null);
		test(rootElemA.startTag.name.compare("email") == true);
		test(rootElemA.childElements != null);
		test(rootElemA.childElements.size() == 1);
		test(rootElemA.startTag.attributes.size() == 2);
		test(rootElemA.endTag.attributes == null);
		test(rootElemA.startTag.attributes[0] != null && rootElemA.startTag.attributes[1] != null);
		test(rootElemA.startTag.attributes[0].name.compare("numPeople") == true);
		test(rootElemA.startTag.attributes[0].value.compare("1") == true);
		test(rootElemA.startTag.attributes[1].name.compare("name") == true);
		test(rootElemA.startTag.attributes[1].value.compare("Mike Sikora") == true);

		XMLElement rootElemB = doc.roots[1];
		test(rootElemB != null);
		test(rootElemB.startTag != null);
		test(rootElemB.startTag.name.compare("email") == true);
		test(rootElemB.startTag.attributes != null);
		test(rootElemB.startTag.attributes.size() == 2);
		test(rootElemB.endTag.attributes != null);
		test(rootElemB.endTag.attributes.size() == 1);
		test(rootElemB.endTag.attributes[0] != null);
		test(rootElemB.endTag.attributes[0].name.compare("endValue") == true);
		test(rootElemB.endTag.attributes[0].value.compare("33") == true);
	}
}

class XMLParsingNestedDupesTests implements IUnitTest
{
	void run()
	{
		String<u8> str(256);
		str.append("<div id=\"1\">");
		str.append("	<div id=\"2\">mike@prontoware.com</div>");
		str.append("    <div id=\"3\">mike@prontoware.com</div>");
		str.append("    <div id=\"4\"/>");
		str.append("</div>");

		XMLDoc doc();
		test(doc.parse(str) == true);
		test(doc.roots != null);
		test(doc.roots.size() == 1);

		XMLElement rootElem = doc.roots[0];
		test(rootElem != null);
		test(rootElem.startTag != null && rootElem.endTag != null);
		test(rootElem.startTag.name != null);
		test(rootElem.startTag.name.compare("div") == true);

		XMLAttribute rootAttrID = rootElem.startTag.getAttribute(String<u8>("id"));
		test(rootAttrID != null);
		test(rootAttrID.value != null);
		test(rootAttrID.value.parseInteger() == 1);
		test(rootElem.hasChildren() == true);
		test(rootElem.childElements.size() == 3);

		XMLElement childDivA = rootElem.childElements[0];
		test(childDivA != null);
		test(childDivA.startTag != null && childDivA.endTag != null);
		test(childDivA.startTag.name != null);
		test(childDivA.startTag.tagType == XMLTag:TYPE_START);
		test(childDivA.startTag.name.compare("div") == true);

		XMLAttribute divAAttrID = childDivA.startTag.getAttribute(String<u8>("id"));
		test(divAAttrID != null);
		test(divAAttrID.value != null);
		test(divAAttrID.value.parseInteger() == 2);

		XMLElement childDivC = rootElem.childElements[2];
		test(childDivC != null);
		test(childDivC.startTag != null && childDivC.endTag == null);
		test(childDivC.startTag.name != null);
		test(childDivC.startTag.tagType == XMLTag:TYPE_SINGLE);
		test(childDivC.startTag.name.compare("div") == true);

		XMLAttribute divCAttrID = childDivC.startTag.getAttribute(String<u8>("id"));
		test(divCAttrID != null);
		test(divCAttrID.value != null);
		test(divCAttrID.value.parseInteger() == 4);
	}
}

class XMLParsingCDATATests implements IUnitTest
{
	void run()
	{
		String<u8> str(256);
		str.append("<email numPeople=1 name=\"Mike Sikora\"><![CDATA[THIS IS CDATA<email></email>]]></email>");
		str.append("<email numPeople=1 name=\"Jess Sikora\">jess@prontoware.com</email endValue=33>");

		XMLDoc doc();
		test(doc.parse(str) == true);
		test(doc.roots != null);
		test(doc.roots.size() == 2);

		XMLElement rootElemA = doc.roots[0];
		test(rootElemA != null);
		test(rootElemA.childElements != null);
		test(rootElemA.childElements.size() == 1);
		test(rootElemA.childElements[0].contentType == XMLElement:CONTENT_CDATA);
		test(rootElemA.childElements[0].content != null);
		test(rootElemA.childElements[0].content.compare("THIS IS CDATA<email></email>") == true);
	}
}

class XMLParsingCommentsIgnoreTests implements IUnitTest
{
	void run()
	{
		String<u8> str(256);
		str.append("<email numPeople=1 name=\"Mike Sikora\"><!-- Comment --></email>");
		str.append("<email numPeople=1 name=\"Jess Sikora\">jess@prontoware.com</email endValue=33>");

		XMLDoc doc();

		test(doc.parse(str, false) == true); // false to ignore comments (not in parse tree)
		test(doc.roots != null);
		test(doc.roots.size() == 2);

		XMLElement rootElemA = doc.roots[0];
		test(rootElemA != null);
		test(rootElemA.childElements == null); // no children (comment), no memory eaten by empty list
	}
}

class XMLParsingCommentsKeepTests implements IUnitTest
{
	void run()
	{
		String<u8> str(256);
		str.append("<email numPeople=1 name=\"Mike Sikora\"><!-- Comment --></email>");
		str.append("<email numPeople=1 name=\"Jess Sikora\">jess@prontoware.com</email endValue=33>");

		XMLDoc doc();
		test(doc.parse(str, true) == true); // true to keep comments, add to parse tree
		test(doc.roots != null);
		test(doc.roots.size() == 2);

		XMLElement rootElemA = doc.roots[0];
		test(rootElemA != null);
		test(rootElemA.childElements != null);
		test(rootElemA.childElements.size() == 1);
		test(rootElemA.childElements[0].contentType == XMLElement:CONTENT_COMMENT);
		test(rootElemA.childElements[0].content != null);
		test(rootElemA.childElements[0].content.compare(" Comment ") == true);
	}
}

class XMLParsingMultiChildrenTests implements IUnitTest
{
	void run()
	{
		String<u8> str(256);
		str.append("<email numPeople=1 name=\"Mike Sikora\">Text 1<!-- Comment X--><b>bold</b>Text 2</email>"); // four children
		str.append("<email numPeople=1 name=\"Jess Sikora\">jess@prontoware.com</email endValue=33>");

		XMLDoc doc();
		test(doc.parse(str, true) == true); // true to keep comments, add to parse tree
		test(doc.roots != null);
		test(doc.roots.size() == 2);

		XMLElement rootElemA = doc.roots[0];
		test(rootElemA != null);
		test(rootElemA.childElements != null);
		test(rootElemA.childElements.size() == 4);

		XMLElement elemTextA    = rootElemA.childElements[0];
		XMLElement elemCommentB = rootElemA.childElements[1];
		XMLElement elemTagC     = rootElemA.childElements[2];
		XMLElement elemTextD    = rootElemA.childElements[3];

		test(elemTextA != null && elemCommentB != null && elemTagC != null && elemTextD != null);
		test(elemTextA.contentType == XMLElement:CONTENT_TEXT);
		test(elemTextA.content != null);
		test(elemTextA.content.compare("Text 1") == true);
		test(elemCommentB.contentType == XMLElement:CONTENT_COMMENT);
		test(elemCommentB.content != null);
		test(elemCommentB.content.compare(" Comment X") == true);
		test(elemTagC.startTag != null && elemTagC.endTag != null);
		test(elemTagC.startTag.name.compare("b") == true);
		test(elemTagC.childElements != null);
		test(elemTagC.childElements.size() == 1);
		test(elemTextD.contentType == XMLElement:CONTENT_TEXT);
		test(elemTextD.content != null);
		test(elemTextD.content.compare("Text 2") == true);
	}
}

class XMLToStringTagsTests implements IUnitTest
{
	void run()
	{
		XMLDoc doc();

		XMLElement rootElem(XMLTag(String<u8>("b"), XMLTag:TYPE_START), XMLTag(String<u8>("b"), XMLTag:TYPE_END));
		rootElem.startTag.addAttribute(String<u8>("nameX"), String<u8>("99"));
		doc.addElement(rootElem);

		String<u8> xmlStr = doc.toString();
		test(xmlStr != null);

		xmlStr.removeAll(Chars:HTAB);
		xmlStr.removeAll(Chars:NEW_LINE);

		test(xmlStr.compare("<b nameX=\"99\"></b>") == true);
	}
}

class XMLToStringComplexTests implements IUnitTest
{
	void run()
	{
		String<u8> str(256);
		str.append("<email encoding=\"UTF-8\">");
		str.append("<from>mike@prontoware.com</from>");
		str.append("<to>derek@prontoware.com</to>");
		str.append("<subject>Fix it!</subject>");
		str.append("<body>The system is down.</body>");
		str.append("<attachment><name>photo.png</name><![CDATA[XQTfFhsq892NCJS]]></attachment>");
		str.append("<!-- End of email -->");
		str.append("</email>");

		XMLDoc doc();
		test(doc.parse(str, true) == true);

		// Comments, CDATA etc.
		String<u8> xmlStr = doc.toString();
		test(xmlStr != null);

		xmlStr.removeAll(Chars:HTAB);
		xmlStr.removeAll(Chars:NEW_LINE);

		test(xmlStr.compare(str) == true);
	}
}

class XMLSearchingTests implements IUnitTest
{
	void run()
	{
		String<u8> str(256);
		str.append("<email encoding=\"UTF-8\">");
		str.append("<from>mike@prontoware.com</from>");
		str.append("<to>derek@prontoware.com</to>");
		str.append("<subject>Fix it!<needle>stuff</needle></subject>");
		str.append("<body>The system is down.</body>");
		str.append("<attachment><name>photo.png</name><![CDATA[XQTfFhsq892NCJS]]></attachment>");
		str.append("<!-- End of email -->");
		str.append("</email>");

		XMLDoc doc();
		test(doc.parse(str, true) == true);

		// Find <needle>
		ArrayList<XMLElement> needleTags = doc.getElements(String<u8>("needle"));
		test(needleTags.size() == 1);

		XMLElement needleElem = needleTags[0];
		test(needleElem != null);
		test(needleElem.childElements != null);
		test(needleElem.getNumChildren() == 1);
		test(needleElem.childElements.size() == 1);
		test(needleElem.getChild(0) != null);
	}
}

class XMLFromObjEmailTests implements IUnitTest
{
	void run()
	{
		ArrayList<XMLEmailTest> roots();
		roots.add(XMLEmailTest(String<u8>("mike@prontoware.com"), String<u8>("jess@prontoware.com"), String<u8>("test"), String<u8>("This is a test.")));
		roots.add(XMLEmailTest(String<u8>("jess@prontoware.com"), String<u8>("mike@prontoware.com"), String<u8>("reply to test"), String<u8>("Works.")));
		roots.add(XMLEmailTest(String<u8>("emily@prontoware.com"), String<u8>("sara@prontoware.com"), String<u8>("Cake!!!"), String<u8>("In the kitchen!")));

		XMLDoc doc = XMLDoc:objToXML(roots);
		test(doc != null);

		String<u8> xmlStr = doc.toString();
		test(xmlStr.length() >= 10);

		//FileSystem:writeTextFile(String<u8>("testXMLFromObjEmail.xml"), xmlStr);

		xmlStr.removeAll(Chars:HTAB);
		xmlStr.removeAll(Chars:NEW_LINE);

		test(xmlStr.contains("<to>mike@prontoware.com</to><from>jess@prontoware.com</from><subject>test</subject><body>This is a test.</body>") == true);
	}
}

class XMLFromObjTypesTests implements IUnitTest
{
	void run()
	{
		ArrayList<XMLTypesTest> roots();

		XMLTypesTest parent();
		parent.name = String<u8>("Parent");
		parent.children = IObj[](2);

		XMLTypesTest child1();
		child1.name = String<u8>("Child A");
		parent.children[0] = child1;

		XMLTypesTest child2();
		parent.children[1] = child2;

		roots.add(parent);

		XMLDoc doc = XMLDoc:objToXML(roots);
		test(doc != null);

		String<u8> xmlStr = doc.toString();
		test(xmlStr.length() >= 4);

		//FileSystem:writeTextFile(String<u8>("testXMLFromObjTypes.xml"), xmlStr);
	}
}

class XMLFromObjTypesMappingTests implements IUnitTest
{
	void run()
	{
		ArrayList<XMLTypesTest> roots();

		XMLTypesTest parent();
		parent.name = String<u8>("Parent");
		parent.children = IObj[](2);
		u32[] parent.d = u32[](2);
		parent.d[0] = 101;
		parent.d[1] = 102;
		parent.e = f32[2][](2);
		parent.e[0][0] = 1.0f;
		parent.e[0][1] = 2.0f;
		parent.e[1][0] = 10.0f;
		parent.e[1][1] = 20.0f;

		XMLTypesTest child1();
		child1.name = String<u8>("Child A");
		parent.children[0] = child1;

		XMLTypesTest child2();
		parent.children[1] = child2;

		roots.add(parent);

		XMapping xmlMapping();
		xmlMapping.numFracDigits = 4;

		XClassMapping listClsMapping(String<u8>("ArrayList<XMLTypesTest>"), String<u8>("Emails"));
		listClsMapping.addPropertyExcluded(String<u8>("numUsed"), String<u8>("")); // don't output <numUsed>
		listClsMapping.addPropertyChildrenOnly(String<u8>("data"), String<u8>("")); // don't output <data> just children
		xmlMapping.addClass(listClsMapping);

		XClassMapping typeClsMapping(String<u8>("XMLTypesTest"), String<u8>("Email"));
		typeClsMapping.addPropertyAttribute(String<u8>("name"), String<u8>("id")); // attribute, renamed to "id=nameVal"
		xmlMapping.addClass(typeClsMapping);

		XMLDoc doc = XMLDoc:objToXML(roots, xmlMapping);
		test(doc != null);

		String<u8> xmlStr = doc.toString();
		test(xmlStr.length() >= 4);
	}
}

class XMLAutoMappedSimpleTests implements IUnitTest
{
	void run()
	{
		XMLEmailTest emailA(String<u8>("mike@prontoware.com"), String<u8>("jess@prontoware.com"), String<u8>("Donuts in kitchen!"), String<u8>("Come and get them!"));

		XMLDoc emailXMLDoc = XMLDoc:objToXML(emailA);

		XMapping xmlMapping();
		xmlMapping.addClass(XClassMapping(emailA.getClassName()));

		ArrayList<IObj> emailObjs = XMLDoc:xmlToObj(xmlMapping, emailXMLDoc);
		test(emailObjs.size() == 1);

		XMLEmailTest emailB = emailObjs[0];
		test(emailB != null);
		test(emailB.to != null);
		test(emailB.from != null);
		test(emailB.subject != null);
		test(emailB.body != null);
		test(emailB.to.compare(emailA.to) == true);
		test(emailB.from.compare(emailA.from) == true);
		test(emailB.subject.compare(emailA.subject) == true);
		test(emailB.body.compare(emailA.body) == true);
	}
}

class XMLAutoMappedAllTypesTests implements IUnitTest
{
	void run()
	{
		/*
		class XMLTypesTest
		{
			String<u8> name = null;
			u8       a = 0;
			f32      b = 1;
			u32[4]   c = u32(1, 2, 3, 4);
			u32[]    d = null;
			f32[2][] e = null;
			IObj[] children = null;
		}
		*/

		// becomes
		/*
		<XMLTypesTest>
			<c>1, 2, 3, 4</c>
			<e>1.00, 2.00, 3.00, 4.00</e>
			<children></children>
			<d>10, 20</d>
			<name>Mike</name>
			<b>1.02</b>
			<a>31</a>
		</XMLTypesTest>
		*/

		XMLTypesTest rootA();
		rootA.name = String<u8>("Mike");
		rootA.a    = 31;
		rootA.b    = 1.02f;
		rootA.c    = u32(1, 2, 3, 4);
		rootA.d    = u32[](2);
		rootA.d[0] = 10;
		rootA.d[1] = 20;
		rootA.e    = f32[2][](2);
		rootA.e[0] = f32(1.0f, 2.0f);
		rootA.e[1] = f32(3.0f, 4.0f);
		rootA.children = null;

		f32[2] preV0 = f32(1.0f, 2.0f);
		test(rootA.e[0].equals(preV0) == true); // sanity check

		XMLDoc typesXMLDoc = XMLDoc:objToXML(rootA);

		//FileSystem:writeTextFile("testXMLAutoMappedAllTypes.txt", typesXMLDoc.toString());

		XMapping xmlMapping();
		xmlMapping.addClass(XClassMapping(rootA.getClassName()));

		ArrayList<IObj> typesObjs = XMLDoc:xmlToObj(xmlMapping, typesXMLDoc);
		test(typesObjs.size() == 1);

		XMLTypesTest rootB = typesObjs[0];
		test(rootB != null);
		test(rootB.name != null);
		test(rootB.name.compare(rootA.name) == true);
		test(rootB.a == rootA.a);
		test(rootB.b == rootA.b);

		u32[4] cVal = u32(1, 2, 3, 4);
		test(rootB.c.equals(cVal) == true);
		test(rootB.d != null);
		test(rootB.d.length() == 2);
		test(rootB.d[0] == rootA.d[0] && rootB.d[1] == rootA.d[1]);
		test(rootB.e != null);
		test(rootB.e.length() == 2);

		f32[2] v0 = f32(1.0f, 2.0f);
		test(rootB.e[0].equals(v0) == true);

		f32[2] v1 = f32(3.0f, 4.0f);
		test(rootB.e[1].equals(v1) == true);

		// Test that full-circle serialize/deserialize/serialize works
		XMLDoc xmlDoc2 = XMLDoc:objToXML(rootB);
		test(xmlDoc2.toString().compare(typesXMLDoc.toString()) == true);
	}
}

class XMLAutoMappedNestedObjsTests implements IUnitTest
{
	void run()
	{
		/*
		class XMLNestedTest
		{
			String<u8> name = null;
			XMLEmailTest email = null;
		}
		*/

		// becomes
		/*
		<XMLNestedTest>
			<name>Parent</name>
			<email>
				<to>jane@prontoware.com</to>
				<from>basic@gmail.com</from>
				<subject>c</subject>
				<body>d</body>
			</email>
		</XMLNestedTest>
		*/

		XMLNestedTest rootA();
		rootA.name  = String<u8>("Parent");
		rootA.email = XMLEmailTest(String<u8>("jane@prontoware.com"), String<u8>("basic@gmail.com"), String<u8>("c"), String<u8>("d"));

		XMapping xmlMapping();
		xmlMapping.addClass(XClassMapping(rootA.getClassName()));
		xmlMapping.addClass(XClassMapping(rootA.email.getClassName()));

		XMLDoc nestedXMLDoc = XMLDoc:objToXML(rootA);
		
		ArrayList<IObj> outObjs = XMLDoc:xmlToObj(xmlMapping, nestedXMLDoc);
		test(outObjs.size() == 1);

		XMLNestedTest rootB = outObjs[0];
		test(rootB != null);
		test(rootB.name != null);
		test(rootB.name.compare(rootA.name) == true);
		test(rootB.email != null);
		test(rootB.email.to != null);
		test(rootB.email.to.compare("jane@prontoware.com") == true);
		test(rootB.email.from != null);
		test(rootB.email.from.compare("basic@gmail.com") == true);
	}
}

class XMLAutoMappedArrayOfObjsTests implements IUnitTest
{
	void run()
	{
		XMLEmailTest[] emailsA(2);
		emailsA[0] = XMLEmailTest(String<u8>("jane@prontoware.com"), String<u8>("sandy@gmail.com"), String<u8>("c"), String<u8>("d"));
		emailsA[1] = XMLEmailTest(String<u8>("sam@prontoware.com"), String<u8>("adam@gmail.com"), String<u8>("e"), String<u8>("f"));

		// becomes
		/*
		<XMLEmailTest[]>
			<XMLEmailTest>
				<to>jane@prontoware.com</to>
				<from>sandy@gmail.com</from>
				<subject>c</subject>
				<body>d</body>
			</XMLEmailTest>
			<XMLEmailTest>
				<to>sam@prontoware.com</to>
				<from>adam@gmail.com</from>
				<subject>e</subject>
				<body>f</body>
			</XMLEmailTest>
		</XMLEmailTest[]>
		*/

		XMapping xmlMapping();
		xmlMapping.addClass(XClassMapping(emailsA.getClassName())); // XMLEmailTest[]
		xmlMapping.addClass(XClassMapping(emailsA[1].getClassName())); // XMLEmailTest

		XMLDoc arrXMLDoc = XMLDoc:objToXML(emailsA);

		ArrayList<IObj> outObjs = XMLDoc:xmlToObj(xmlMapping, arrXMLDoc);

		test(outObjs.size() == 1);

		XMLEmailTest[] emailsB = outObjs[0];
		test(emailsB != null);
		test(emailsB.length() == 2);
		test(emailsB[0] != null && emailsB[1] != null);

		XMLEmailTest email0 = emailsB[0];
		test(email0 != null);
		test(email0.to != null);
		test(email0.to.compare("jane@prontoware.com") == true);
	}
}

class XMLAutoMappedMappingTests implements IUnitTest
{
	void run()
	{
		ArrayList<XMLEmailTest> emailsA(2);
		emailsA.add(XMLEmailTest(String<u8>("jane@prontoware.com"), String<u8>("sandy@gmail.com"), String<u8>("c"), String<u8>("d")));
		emailsA.add(XMLEmailTest(String<u8>("sam@prontoware.com"), String<u8>("adam@gmail.com"), String<u8>("e"), String<u8>("f")));

		// becomes
		/*
		<ArrayList(XMLEmailTest)>
			<data>
				<XMLEmailTest>
					<to>jane@prontoware.com</to>
					<from>sandy@gmail.com</from>
					<subject>c</subject>
					<body>d</body>
				</XMLEmailTest>
				<XMLEmailTest>
					<to>sam@prontoware.com</to>
					<from>adam@gmail.com</from>
					<subject>e</subject>
					<body>f</body>
				</XMLEmailTest>
			</data>
			<numUsed>2</numUsed>
		</ArrayList(XMLEmailTest)>
		*/

		XMLDoc arrXMLDoc = XMLDoc:objToXML(emailsA);
		ArrayList<IObj> outObjs = XMLDoc:xmlToObj(arrXMLDoc);
		test(outObjs.size() == 1);
		test(outObjs[0] != null);

		ArrayList<XMLEmailTest> emailsB = outObjs[0];
		test(emailsB != null);
		test(emailsB.size() == 2);
		test(emailsB[0] != null && emailsB[1] != null);

		XMLEmailTest email0 = emailsB[0];
		test(email0 != null);
		test(email0.to != null);
		test(email0.to.compare("jane@prontoware.com") == true);

		XMLDoc arrXMLDoc2 = XMLDoc:objToXML(emailsB);
		test(arrXMLDoc.toString().compare(arrXMLDoc2.toString()) == true);
	}
}

class XMLParseHTMLTests implements IUnitTest
{
	void run()
	{
		String<u8> str(256);
		str.append("<!doctype html>");  // single tag, no end tag
		str.append("<html>");
		str.append("<head>");
		str.append("<link rel=\"stylesheet\" href=\"site.css\" />"); // indicated single tag
		str.append("</head>");
		str.append("<body>");
		str.append("<script>for(var x=0; x<10; x++) { }</script>"); // x < 10 can screw up strict XML parsing
		str.append("<br>"); // no end tag, no <br /> etc.
		str.append("HELLO!");
		str.append("</body>");
		str.append("</html>");

		XMLDoc doc();

		String<u8> errorsStr();
		test(doc.parseHTML(str, true, errorsStr) == true);
		test(doc.roots != null);
		test(doc.roots.size() == 2);

		XMLElement rootElem = doc.roots[0];
		test(rootElem != null);
	}
}

class XMLToHTMLStringTests implements IUnitTest
{
	void run()
	{
		// scripts don't conform to strict XML so x < 10 can screw up parsing as well as quotes and & characters
		String<u8> scriptContents = "var abc = 10; for(var x=0; x<10; x++) { if(x == 0 && abc == 10) { var str = \"val: \" + x; } }";

		String<u8> str(256);
		str.append("<!doctype html>");  // single tag, no end tag
		str.append("<html>");
		str.append("<head>");
		str.append("<link rel=\"stylesheet\" href=\"site.css\" />"); // indicated single tag
		str.append("</head>");
		str.append("<body>");
		str.append("<script>"); 
		str.append(scriptContents);
		str.append("</script>");
		str.append("<br>"); // no end tag, no <br /> etc.
		str.append("HELLO!");
		str.append("</body>");
		str.append("</html>");

		XMLDoc doc();

		String<u8> errorsStr();
		test(doc.parseHTML(str, true, errorsStr) == true);
		test(doc.roots != null);
		test(doc.roots.size() == 2);

		XMLElement rootElem = doc.roots[0];
		test(rootElem != null);

		String<u8> htmlStr = doc.toHTML();
		test(htmlStr.contains(scriptContents) != false);
	}
}

class XMLParsePerformanceTests implements IUnitTest
{
	void run()
	{
		u8[] xmlDataFileContents = HVM:getPackageFile("XMLTestDataLarge.xml");
        test(xmlDataFileContents != null);

		String<u8> xmlStr(xmlDataFileContents);
		test(xmlStr.length() > 8192);

		// parse
		f64 startTime = System:getTime();

		HVM:startPerfProfiling();
		HVM:startMemoryProfiling();

		XMLDoc xmlDoc();
		String<u8> errMsgOut();
		if(xmlDoc.parse(xmlStr, true, errMsgOut) == false)
		{
			test(false);
			return;
		}

		if(errMsgOut.length() > 0)
		{
			//Log:log("testXMLParsePerformance() Errors from parsing: ");
			//Log:log(errMsgOut);
			test(false);
			return;
		}

		f64 parseTime = System:getTime() - startTime;

		HVM:stopPerfProfiling();

		startTime = System:getTime();
		String<u8> xmlStr2 = xmlDoc.toString();
		f64 toStringTime = System:getTime() - startTime;

		xmlDoc = null; // release memory

		HVM:stopMemoryProfiling();

		String<u8> xmlReport = HVM:getPerfProfilingReport();
		//Log:log("__TEST", "XML Parse Performance Test, profiling: \n" + xmlReport + "\n");

		// Stats String
		String<u8> statsStr();
		statsStr.append("XML Parse Performance Test," + String<u8>(" Parse time: ") + String<u8>:formatNumber(parseTime / 1000.0) + " seconds\n");
		Log:log("__TEST", statsStr);

		String<u8> xmlMemoryReport = HVM:getMemoryProfilingReport();
		//Log:log("XML Parse Performance Test, Memory profiling: \n" + xmlMemoryReport);
	}
}

class XMLPackageToXMLDescTests implements IUnitTest
{
	void run()
	{
		ByteArray fileData = FileSystem:readFile("fill-in/pronto-core_0.2.0.pp");
		if(fileData == null)
			return; // OK, optional

		if(fileData.size() == 0)
			return; // Um, OK

		//VM:runGC();
		//Log:log("Ran GC 1!");

		String<u8> xmlStr = getPackageXMLDesc(fileData.data, fileData.size());

		//FileSystem:writeTextFile(String<u8>("pronto-core-desc.xml"), xmlStr);

		// parse and re-stringify so it's formatted
		f64 startTime = System:getTime();
		XMLDoc xmlDoc();
		String<u8> errMsgOut();
		test(xmlDoc.parse(xmlStr, true, errMsgOut) == true);
		test(errMsgOut.length() == 0);
		f64 parseTime = System:getTime() - startTime;

		//VM:runGC();
		//Log:log("Ran GC 2!");

		/*
		startTime = System:getTime();
		XMLDoc htmlDoc();
		if(htmlDoc.parseHTML(xmlStr, true, errMsgOut) == false)
			return 5;
		if(errMsgOut.length() > 0)
		{
			Log:log("Errors from html parsing: ");
			Log:log(errMsgOut);
			return 6;
		}
		f64 parseHTMLTime = System:getTime() - startTime;*/

		startTime = System:getTime();
		String<u8> xmlStr2 = xmlDoc.toString();
		f64 toStringTime = System:getTime() - startTime;

		// Stats String
		String<u8> statsStr();
		statsStr.append("XML Pkg Parse Perf Test:");
		statsStr.append("\n\nParse time: ");
		statsStr.append(String<u8>:formatNumber(parseTime / 1000.0));
		//statsStr.append("\n\nParse as HTML time: ");
		//statsStr.append(String<u8>:formatNumber(parseHTMLTime / 1000.0));
		statsStr.append("\nStringify time: ");
		statsStr.append(String<u8>:formatNumber(toStringTime / 1000.0));
		Log:log(statsStr);

		//VM:runGC();
		//Log:log("Ran GC 3!");

		//FileSystem:writeTextFile(String<u8>("pronto-core-desc-parsed.xml"), xmlStr2);
	}
}