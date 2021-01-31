////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class JSONEmailTest
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

class JSONTypesTest
{
	String<u8> name = null;
	u8       a = 0;
	f32      b = 1;
	u32[4]   c = u32(1, 2, 3, 4);
	u32[]    d = null;
	f32[2][] e = null;
	IObj[] children = null;
}

class JSONNestedTest
{
	String<u8> name = null;
	JSONEmailTest email = null;
}

class JSONParsingObjLiteralTests implements IUnitTest
{
	void run()
	{
		String<u8> str(256);
		str.append("{\"widget\": {\n");
		str.append("    \"debug\": \"on\",\n");
		str.append("    \"window\": {\n");
		str.append("        \"title\": \"Sample Konfabulator Widget\",\n");
		str.append("        \"name\": \"main_window\",\n");
		str.append("        \"width\": 500,\n");
		str.append("        \"height\": 500\n");
		str.append("    },\n");
		str.append("    \"image\": { \n");
		str.append("        \"src\": \"Images/Sun.png\",\n");
		str.append("        \"name\": \"sun1\",\n");
		str.append("        \"hOffset\": 250,\n");
		str.append("        \"vOffset\": 250,\n");
		str.append("        \"alignment\": \"center\"\n");
		str.append("    },\n");
		str.append("    \"text\": {\n");
		str.append("        \"data\": \"Click Here\",\n");
		str.append("        \"size\": 36,\n");
		str.append("        \"style\": \"bold\",\n");
		str.append("        \"name\": \"text1\",\n");
		str.append("        \"hOffset\": 250,\n");
		str.append("        \"vOffset\": 100,\n");
		str.append("        \"alignment\": \"center\",\n");
		str.append("        \"onMouseUp\": \"sun1.opacity = (sun1.opacity / 100) * 90;\"\n");
		str.append("    }\n");
		str.append("}}   \n");

		String<u8> errOut(128);
		JSON jsonObj = JSON:parse(str, errOut);

		test(errOut.length() == 0);

		// root object
		if(jsonObj.name != null)
		{
			test(jsonObj.name.length() == 0);
		}

		test(jsonObj.properties != null);
		test(jsonObj.properties.size() == 1);
		test(jsonObj.hasProperty(String<u8>("widget")) == true);

		// widget object
		JSON widgetObj = jsonObj.getProperty(String<u8>("widget"));
		test(widgetObj.name.compare("widget") == true);
		test(widgetObj.properties.size() == 4);

		// image object
		JSON imageObj = widgetObj.getProperty(String<u8>("image"));
		test(imageObj.name.compare("image") == true);
		test(imageObj.properties.size() == 5);
	}
}

class JSONParsingObjWithArrayTests implements IUnitTest
{
	void run()
	{
		// array parsing

		String<u8> str(128);
		str.append("{\"menu\": {\n");
		str.append("  \"id\": \"file\",\n");
		str.append("  \"value\": \"File\",\n");
		str.append("  \"popup\": {\n");
		str.append("    \"menuitem\": [\n");
		str.append("      {\"value\": \"New\", \"onclick\": \"CreateNewDoc()\"},\n");
		str.append("      {\"value\": \"Open\", \"onclick\": \"OpenDoc()\"},\n");
		str.append("      {\"value\": \"Close\", \"onclick\": \"CloseDoc()\"}\n");
		str.append("    ]\n");
		str.append("  }\n");
		str.append("}}\n");

		String<u8> errOut(128);
		JSON jsonObj = JSON:parse(str, errOut);

		test(errOut.length() == 0);

		if(jsonObj.name != null)
		{
			test(jsonObj.name.length() == 0);
		}

		JSON menuObj = jsonObj.getProperty(String<u8>("menu"));
		test(menuObj.name.compare("menu") == true);
		test(menuObj.properties != null);
		test(menuObj.properties.size() == 3);

		JSON valueObj = menuObj.getProperty(String<u8>("value"));
		test(valueObj.name.compare("value") == true);
		if(valueObj.properties != null) { test(valueObj.properties.size() == 0); }
		test(valueObj.val.compare("File") == true);

		JSON popupObj = menuObj.getProperty(String<u8>("popup"));
		test(popupObj.name.compare("popup") == true);

		JSON menuitemObj = popupObj.getProperty(String<u8>("menuitem"));
		test(menuitemObj.name.compare("menuitem") == true);
		test(menuitemObj.properties != null);
		test(menuitemObj.properties.size() == 3);
	}
}

class JSONParsingObjRootArrayTests implements IUnitTest
{
	void run()
	{
		// Test that instead of JSON starting with object literal { it starts with array [, example:
		String<u8> str(128);
		str.append("[\n");
		str.append("    \"element0\",\n");
		str.append("    \"element1\",\n");
		str.append("    {\n");
		str.append("        \"obj\": 22\n");
		str.append("    },\n");
		str.append("    null,\n");
		str.append("    {\n");
		str.append("        \"obj\": null\n");
		str.append("    }\n");
		str.append("]\n");

		String<u8> errOut(128);
		JSON jsonObj = JSON:parse(str, errOut);

		test(jsonObj.isArray() == true);
		test(jsonObj.properties.size() == 5); // 5 including "null"

		JSON element0 = jsonObj.getProperty(0);
		test(element0.val.compare("element0") == true);

		JSON objLitElement2 = jsonObj.getProperty(2);
		test(objLitElement2 != null);
		test(objLitElement2.hasProperty(String<u8>("obj")) == true);
	}
}

class JSONParsingRealWorldJSONTests implements IUnitTest
{
	void run()
	{
		// Test some sample complex real-world JSON parsing.
		String<u8> str(128);
		str.append("{\n");
		str.append("  \"id\": \"ch_16t6BoLKdfmdxTrtl061n4T2\",\n");
		str.append("  \"object\": \"charge\",\n");
		str.append("  \"created\": 1444179222,\n");
		str.append("  \"livemode\": false,\n");
		str.append("  \"paid\": true,\n");
		str.append("  \"status\": \"succeeded\",\n");
		str.append("  \"amount\": 100,\n");
		str.append("  \"currency\": \"cad\",\n");
		str.append("  \"refunded\": false,\n");
		str.append("  \"source\": {\n");
		str.append("    \"id\": \"card_16scyXLKdfmdxQrt3Aihfb8F\",\n");
		str.append("    \"object\": \"card\",\n");
		str.append("    \"last4\": \"4242\",\n");
		str.append("    \"brand\": \"Visa\",\n");
		str.append("    \"funding\": \"credit\",\n");
		str.append("    \"exp_month\": 8,\n");
		str.append("    \"exp_year\": 2016,\n");
		str.append("    \"country\": \"US\",\n");
		str.append("    \"name\": null,\n");
		str.append("    \"address_line1\": null,\n");
		str.append("    \"address_line2\": null,\n");
		str.append("    \"address_city\": null,\n");
		str.append("    \"address_state\": null,\n");
		str.append("    \"address_zip\": null,\n");
		str.append("    \"address_country\": null,\n");
		str.append("    \"cvc_check\": null,\n");
		str.append("    \"address_line1_check\": null,\n");
		str.append("    \"address_zip_check\": null,\n");
		str.append("    \"tokenization_method\": null,\n");
		str.append("    \"dynamic_last4\": null,\n");
		str.append("    \"metadata\": {\n");
		str.append("    },\n");
		str.append("    \"customer\": null\n");
		str.append("  },\n");
		str.append("  \"captured\": true,\n");
		str.append("  \"balance_transaction\": \"txn_16t6QoLKdfmdxTrtSBSXwE4b\",\n");
		str.append("  \"failure_message\": null,\n");
		str.append("  \"failure_code\": null,\n");
		str.append("  \"amount_refunded\": 0,\n");
		str.append("  \"customer\": null,\n");
		str.append("  \"invoice\": null,\n");
		str.append("  \"description\": \"My First Test Charge (created for API docs)\",\n");
		str.append("  \"dispute\": null,\n");
		str.append("  \"metadata\": {\n");
		str.append("  },\n");
		str.append("  \"statement_descriptor\": null,\n");
		str.append("  \"fraud_details\": {\n");
		str.append("  },\n");
		str.append("  \"receipt_email\": null,\n");
		str.append("  \"receipt_number\": null,\n");
		str.append("  \"shipping\": null,\n");
		str.append("  \"destination\": null,\n");
		str.append("  \"application_fee\": null,\n");
		str.append("  \"refunds\": {\n");
		str.append("    \"object\": \"list\",\n");
		str.append("    \"total_count\": 0,\n");
		str.append("    \"has_more\": false,\n");
		str.append("    \"url\": \"/v1/charges/ch_12t6BoLKdfmdxTrtl062n4T7/refunds\",\n");
		str.append("    \"data\": [\n");
		str.append("\n");
		str.append("    ]\n");
		str.append("  }\n");
		str.append("}\n");

		String<u8> errOut(128);
		JSON jsonObj = JSON:parse(str, errOut);
		test(errOut.length() == 0);
		test(jsonObj.isArray() == false);
		test(jsonObj.properties.size() == 28);
	}
}

class JSONToTextTests implements IUnitTest
{
	void run()
	{
		// Go from text to JSON object back to text, then back to JSON object agian.
		String<u8> str(256);
		str.append("{\"widget\": {\n");
		str.append("    \"debug\": \"on\",\n");
		str.append("    \"window\": {\n");
		str.append("        \"title\": \"Sample Konfabulator Widget\",\n");
		str.append("        \"name\": \"main_window\",\n");
		str.append("        \"width\": 500,\n");
		str.append("        \"height\": 500\n");
		str.append("    },\n");
		str.append("    \"image\": { \n");
		str.append("        \"src\": \"Images/Sun.png\",\n");
		str.append("        \"name\": \"sun1\",\n");
		str.append("        \"hOffset\": 250,\n");
		str.append("        \"vOffset\": 250,\n");
		str.append("    },\n");
		str.append("    \"text\": {\n");
		str.append("        \"data\": \"Click Here\",\n");
		str.append("        \"size\": 36,\n");
		str.append("    }\n");
		str.append("}}   \n");

		String<u8> errOut(128);
		JSON jsonObj = JSON:parse(str, errOut);
		test(errOut.length() == 0);

		JSON widgetObj = jsonObj.getProperty(String<u8>("widget"));

		test(widgetObj.isArray() == false);
		test(widgetObj.properties.size() == 4);

		String<u8> jsonText = jsonObj.toString(); // root obj
		test(jsonText.length() != 0);

		JSON jsonObj2 = JSON:parse(jsonText, errOut);
		test(errOut.length() == 0);

		test(jsonObj2.isArray() == false);
	}
}

class JSONFromObjEmailTests implements IUnitTest
{
	void run()
	{
		/* Should be JSON output:
		"ArrayList(JSONEmailTest)": 
		{
			"data": 
			[
				"JSONEmailTest": 
				{
					"to": "mike@prontoware.com",
					"from": "jess@prontoware.com",
					"subject": "test",
					"body": "This is a test."
				},
				"JSONEmailTest": 
				{
					"to": "jess@prontoware.com",
					"from": "mike@prontoware.com",
					"subject": "reply to test",
					"body": "Works."
				},
				"JSONEmailTest": 
				{
					"to": "emily@prontoware.com",
					"from": "sara@prontoware.com",
					"subject": "Cake!!!",
					"body": "In the kitchen!"
				}
			],
			"numUsed": 3
		}
		*/

		ArrayList<JSONEmailTest> roots();
		roots.add(JSONEmailTest(String<u8>("mike@prontoware.com"), String<u8>("jess@prontoware.com"), String<u8>("test"), String<u8>("This is a test.")));
		roots.add(JSONEmailTest(String<u8>("jess@prontoware.com"), String<u8>("mike@prontoware.com"), String<u8>("reply to test"), String<u8>("Works.")));
		roots.add(JSONEmailTest(String<u8>("emily@prontoware.com"), String<u8>("sara@prontoware.com"), String<u8>("Cake!!!"), String<u8>("In the kitchen!")));

		JSON doc = JSON:objToJSON(roots);
		test(doc != null);

		String<u8> jsonStr = doc.toString();
		test(jsonStr.length() >= 10);

		//FileSystem:writeTextFile(String<u8>("testJSONFromObjEmail.json"), jsonStr);

		jsonStr.removeAll(Chars:HTAB);
		jsonStr.removeAll(Chars:NEW_LINE);

		test(jsonStr.contains("\"ArrayList(JSONEmailTest)\":") == true);
		test(jsonStr.contains("\"to\": \"jess@prontoware.com\",") == true);
	}
}

class JSONFromObjTypesTests implements IUnitTest
{
	void run()
	{
		/*
		"ArrayList(JSONTypesTest)": 
		{
			"data": 
			[
				"JSONTypesTest": 
				{
					"c": [ 1, 2, 3, 4 ],
					"e": [ 10.00, 20.00, 30.00, 40.00 ],
					"children": 
					[
						"JSONTypesTest": 
						{
							"c": [ 1, 2, 3, 4 ],
							"name": "Child A",
							"b": 1.00,
							"a": 0
						},
						"JSONTypesTest": 
						{
							"c": [ 1, 2, 3, 4 ],
							"b": 1.00,
							"a": 0
						}
					],
					"d": [ 7, 8, 9 ],
					"name": "Parent",
					"b": 1.00,
					"a": 0
				}
			],
			"numUsed": 1
		}
		*/

		ArrayList<JSONTypesTest> roots();

		JSONTypesTest parent();
		parent.name = String<u8>("Parent");
		parent.children = IObj[](2);
		parent.d = u32[](3);
		parent.d[0] = 7;
		parent.d[1] = 8;
		parent.d[2] = 9;
		parent.e = f32[2][](2);
		parent.e[0] = f32(10.0f, 20.0f);
		parent.e[1] = f32(30.0f, 40.0f);

		JSONTypesTest child1();
		child1.name = String<u8>("Child A");
		parent.children[0] = child1;

		JSONTypesTest child2();
		parent.children[1] = child2;

		roots.add(parent);

		JSON doc = JSON:objToJSON(roots);
		test(doc != null);

		String<u8> jsonStr = doc.toString();
		test(jsonStr.length() >= 4);

		jsonStr.removeAll(Chars:HTAB);
		jsonStr.removeAll(Chars:NEW_LINE);
		jsonStr.removeAll(Chars:SPACE);

		test(jsonStr.contains("\"ArrayList(JSONTypesTest)\":{\"data\":[\"JSONTypesTest\":{") == true);
		test(jsonStr.contains("\"d\":[7,8,9]") == true);
		test(jsonStr.contains("\"e\":[10.00,20.00,30.00,40.00],") == true);
	}
}

class JSONAutoMappedSimpleTests implements IUnitTest
{
	void run()
	{
		/*
		"JSONEmailTest": 
		{
			"to": "mike@prontoware.com",
			"from": "jess@prontoware.com",
			"subject": "Donuts in kitchen!",
			"body": "Come and get them!"
		}
		*/

		JSONEmailTest emailA(String<u8>("mike@prontoware.com"), String<u8>("jess@prontoware.com"), String<u8>("Donuts in kitchen!"), String<u8>("Come and get them!"));

		JSON emailJSON = JSON:objToJSON(emailA);

		//Log:log(emailJSON.toString());

		XMapping jsonMapping();
		jsonMapping.addClass(XClassMapping(emailA.getClassName()));

		ArrayList<IObj> emailObjs = JSON:jsonToObj(jsonMapping, emailJSON);

		test(emailObjs.size() == 1);

		JSONEmailTest emailB = emailObjs[0];
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

class JSONAutoMappedAllTypesTests implements IUnitTest
{
	void run()
	{
		/*
		"JSONTypesTest": 
		{
			"c": [ 1, 2, 3, 4 ],
			"e": [ 1.00, 2.00, 3.00, 4.00 ],
			"d": [ 10, 20 ],
			"name": "Mike",
			"b": 1.02,
			"a": 31
		}
		*/

		JSONTypesTest rootA();
		rootA.name = String<u8>("Mike");
		rootA.a    = 31;
		rootA.b    = 1.02f;
		rootA.c    = u32(1, 2, 3, 4);
		rootA.d    = u32[](2);
		rootA.d[0] = 10;
		rootA.d[1] = 20;
		rootA.e    = f32[2][](2);
		rootA.e[0] = f32(11.0f, 12.0f);
		rootA.e[1] = f32(13.0f, 14.0f);
		rootA.children = null;

		JSON typesJSON = JSON:objToJSON(rootA);

		XMapping jsonMapping();
		jsonMapping.addClass(XClassMapping(rootA.getClassName()));

		ArrayList<IObj> typesObjs = JSON:jsonToObj(jsonMapping, typesJSON);

		test(typesObjs.size() == 1);

		JSONTypesTest rootB = typesObjs[0];
		test(rootB != null);

		//JSON typesJSON2 = JSON:objToJSON(rootB);
		//Log:log("\ntestJSONAutoMappedAllTypes() JSONv2:\n");
		//Log:log(typesJSON2.toString());

		test(rootB.name != null);
		test(rootB.name.compare(rootA.name) == true);
		test(rootB.a == rootA.a);
		test(rootB.b == rootA.b);
		test(rootB.c.equals(rootA.c) == true);
		test(rootB.d != null);
		test(rootB.d.length() == 2);
		test(rootB.d[0] == rootA.d[0] && rootB.d[1] == rootA.d[1]);
		test(rootB.e != null);
		test(rootB.e.length() == 2);

		f32[2] v0 = f32(11.0f, 12.0f);
		test(rootB.e[0].equals(v0) == true);

		f32[2] v1 = f32(13.0f, 14.0f);
		test(rootB.e[1].equals(v1) == true);

		// Test that full-circle serialize/deserialize/serialize works
		JSON jsonDoc3 = JSON:objToJSON(rootB);
		test(jsonDoc3.toString().compare(typesJSON.toString()) == true);
	}
}

class JSONAutoMappedNestedObjsTests implements IUnitTest
{
	void run()
	{
		/*
		class JSONNestedTest
		{
			String<u8> name = null;
			JSONEmailTest email = null;
		}
		*/

		// becomes
		/*
		"JSONNestedTest": 
		{
			"name": "Parent",
			"email": 
			{
				"to": "jane@prontoware.com",
				"from": "basic@gmail.com",
				"subject": "c",
				"body": "d"
			}
		}
		*/

		JSONNestedTest rootA();
		rootA.name  = String<u8>("Parent");
		rootA.email = JSONEmailTest(String<u8>("jane@prontoware.com"), String<u8>("basic@gmail.com"), String<u8>("c"), String<u8>("d"));

		XMapping jsonMapping();
		jsonMapping.addClass(XClassMapping(rootA.getClassName()));
		jsonMapping.addClass(XClassMapping(rootA.email.getClassName()));

		JSON nestedJSON = JSON:objToJSON(rootA);

		//Log:log("\ntestJSONAutoMappedNestedObjs() JSON:\n");
		//Log:log(nestedJSON.toString());
		
		ArrayList<IObj> outObjs = JSON:jsonToObj(jsonMapping, nestedJSON);

		test(outObjs.size() == 1);

		JSONNestedTest rootB = outObjs[0];
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

class JSONAutoMappedArrayOfObjs implements IUnitTest
{
	void run()
	{
		JSONEmailTest[] emailsA(2);
		emailsA[0] = JSONEmailTest(String<u8>("jane@prontoware.com"), String<u8>("sandy@gmail.com"), String<u8>("c"), String<u8>("d"));
		emailsA[1] = JSONEmailTest(String<u8>("sam@prontoware.com"), String<u8>("adam@gmail.com"), String<u8>("e"), String<u8>("f"));

		// becomes
		/*
		"JSONEmailTest[]": 
		[
			"JSONEmailTest": 
			{
				"to": "jane@prontoware.com",
				"from": "sandy@gmail.com",
				"subject": "c",
				"body": "d"
			},
			"JSONEmailTest": 
			{
				"to": "sam@prontoware.com",
				"from": "adam@gmail.com",
				"subject": "e",
				"body": "f"
			}
		]
		*/

		XMapping jsonMapping();
		jsonMapping.addClass(XClassMapping(emailsA.getClassName())); // JSONEmailTest[]
		jsonMapping.addClass(XClassMapping(emailsA[1].getClassName())); // JSONEmailTest

		JSON arrJSON = JSON:objToJSON(emailsA);

		//Log:log("\ntestJSONAutoMappedArrayOfObjs() JSON:\n");
		//Log:log(arrJSON.toString());

		ArrayList<IObj> outObjs = JSON:jsonToObj(jsonMapping, arrJSON);

		test(outObjs.size() == 1);

		JSONEmailTest[] emailsB = outObjs[0];
		test(emailsB != null);
		test(emailsB.length() == 2);
		test(emailsB[0] != null && emailsB[1] != null);

		JSONEmailTest email0 = emailsB[0];
		test(email0 != null);
		test(email0.to != null);
		test(email0.to.compare("jane@prontoware.com") == true);
	}
}