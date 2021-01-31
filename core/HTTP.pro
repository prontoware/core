////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// MIME
////////////////////////////////////////////////////////////////////////////////////////////////////

// MIME type utilties.
class MIME
{
	// Get MIME type (i.e. 'text/plain') from file type (i.e. ".txt"). Covers many web-appropriate types.
	shared String<u8> byFileExtension(String<u8> fileExt)
	{
		String<u8> ext = String<u8>(fileExt);
		ext.toLowercase();

		// images
		if(ext == "gif")
			return String<u8>("image/gif");
		if(ext == "jpg")
			return String<u8>("image/jpeg");
		if(ext == "jpeg")
			return String<u8>("image/jpeg");
		if(ext == "png")
			return String<u8>("image/png");
		if(ext == "bmp")
			return String<u8>("image/bmp");
		if(ext == "ico")
			return String<u8>("image/x-icon");

		// mesh
		if(ext == "obj")
			return String<u8>("mesh/obj");

		// video
		if(ext == "mpg")
			return String<u8>("video/mpeg");
		if(ext == "mpeg")
			return String<u8>("video/mpeg");
		if(ext == "avi")
			return String<u8>("video/avi");
		if(ext == "mp4")
			return String<u8>("video/mp4");
		if(ext == "wmv")
			return String<u8>("video/x-ms-wmv");
		if(ext == "webm")
			return String<u8>("video/webm");

		// audio
		if(ext == "mp3")
			return String<u8>("audio/mp3");
		if(ext == "ogg")
			return String<u8>("audio/ogg");
		if(ext == "wav")
			return String<u8>("audio/wav");

		// documents
		if(ext == "txt" || ext == "text" || ext == "plain")
			return String<u8>("text/plain");
		if(ext == "csv")
			return String<u8>("text/csv");
		if(ext == "css")
			return String<u8>("text/css");
		if(ext == "html")
			return String<u8>("text/html");
		if(ext == "xml")
			return String<u8>("text/xml");
		if(ext == "js")
			return String<u8>("text/javascript");

		// application
		if(ext == "pdf")
			return String<u8>("application/pdf");
		if(ext == "exe")
			return String<u8>("application/x-msdownload");

		return String<u8>("unknown/unknown");
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// URL
////////////////////////////////////////////////////////////////////////////////////////////////////

// Utilities for dealing with URLs.
class URL
{
	// Create a URL from a base string and a map of parameters. Parameters will be encoded (special chars converted to %FF).
	shared String<u8> create(String<u8> urlBase, IMap<String<u8>, String<u8>> params)
	{
		String<u8> s(urlBase.length()*2);

		s.append(urlBase);
		s.append(Chars:QUESTION);
		s.append(encodeParameters(params));

		return s;
	}

	// Parse key/value pairs of URL. i.e. "domain.com/?x=7&dog=cat". Automatically decodes parameters special characters (i.e. from %20 to space char).
	shared IMap<String<u8>, String<u8>> parseParameters(String<u8> url)
	{
		return parseParameters(url, true);
	}

	// Parse key/value pairs of URL. i.e. "domain.com/?x=7&dog=cat". decodeParams=true will decode parameters special characters (i.e. from %20 to space char).
	shared IMap<String<u8>, String<u8>> parseParameters(String<u8> url, bool decodeParams)
	{
		IMap<String<u8>, String<u8>> params = ArrayMap<String<u8>, String<u8>>();
		if(url == null)
			return params;

		String<u8> s(url);

		// find the ? where params start?
		i64 questionMarkIndex = url.findNext(Chars:QUESTION, 0);
		if(questionMarkIndex < 0)
		{
			// check if there is an equals sign anywhere, in which case we assume whole string is parameters
			i64 firstEqualsMarkIndex = url.findNext(Chars:EQUALS, 0);
			if(firstEqualsMarkIndex < 0)
				return params; // nothing to parse
		}
		else
		{
			s = url.subString(questionMarkIndex+1, url.length()-1);
		}

		// replace all + with spaces which is alternate to encoding spaces with %20
		s.replaceAll(Chars:PLUS, Chars:SPACE);

		ArrayList<String<u8>> pairStrings = s.split(Chars:AMPERSAND, true);
		for(u32 p=0; p<pairStrings.size(); p++)
		{
			String<u8> e = pairStrings[p];

			String<u8> name = null;
			String<u8> val  = null;

			if(e.contains(Chars:EQUALS) == true)
			{
				// name + value
				ArrayList<String<u8>> splitParam = e.split(Chars:EQUALS, false);
				if(splitParam.size() == 0)
				{
					assert(false); // ?
				}
				else if(splitParam.size() == 1)
				{
					name = splitParam[0];
					val  = String<u8>("");
				}
				else if(splitParam.size() == 2)
				{
					name = splitParam[0];
					val  = splitParam[1];
				}
				else
				{
					// wtf, just use the first two values
					name = splitParam[0];
					val  = splitParam[1];
				}
			}
			else
			{
				// name but no value
				name = e;
				val  = String<u8>("");
			}

			if(name != null && val != null)
			{
				if(decodeParams == true)
					params.add(decodeParameter(name), decodeParameter(val));
				else
					params.add(name, val);
			}
		}

		return params;
	}

	// URLs parameters (names/values) cannot contain ASCII characters other than A-Z, a-z, 0-9 and _-+ etc. This encodes all other characters to %FF where space would be %20 etc.
	shared String<u8> encodeParameter(String<u8> nameOrVal)
	{
		String<u8> s(nameOrVal.length());

		for(u64 c=0; c<nameOrVal.numChars; c++)
		{
			if((nameOrVal.chars[c] >= Chars:A && nameOrVal.chars[c] <= Chars:Z) || (nameOrVal.chars[c] >= Chars:a && nameOrVal.chars[c] <= Chars:z) || (nameOrVal.chars[c] >= Chars:ZERO && nameOrVal.chars[c] <= Chars:NINE) ||
			   nameOrVal.chars[c] == Chars:UNDERSCORE || nameOrVal.chars[c] == Chars:HYPHEN || nameOrVal.chars[c] == Chars:PLUS)
			{
				s.append(nameOrVal.chars[c]);
			}
			else
			{
				// encode
				s.append(Chars:PERCENT);
				s.append(String<u8>:formatNumberHex(nameOrVal.chars[c]));
			}
		}

		return s;
	}
 
	// Decode each parameter. URLs parameters (names/values) cannot contain ASCII characters other than A-Z, a-z, 0-9 and _-+ etc. This encodes all other characters to %FF where space would be %20 etc.
	shared String<u8> decodeParameter(String<u8> nameOrVal)
	{
		String<u8> s(nameOrVal.length());

		for(u64 c=0; c<nameOrVal.numChars; c++)
		{
			if(nameOrVal.chars[c] != Chars:PERCENT)
			{
				s.append(nameOrVal.chars[c]);
			}
			else
			{
				if((c+2) < nameOrVal.numChars)
				{
					u8 c0 = nameOrVal.chars[c+1];
					u8 c1 = nameOrVal.chars[c+2];

					u8 cv0 = 0;
					if(c0 >= Chars:ZERO && c0 <= Chars:NINE)
						cv0 = c0 - Chars:ZERO;
					else if(c0 >= Chars:A && c0 <= Chars:F)
						cv0 = (c0 - Chars:A) + 10;
					else
						cv0 = 0;

					u8 cv1 = 0;
					if(c1 >= Chars:ZERO && c1 <= Chars:NINE)
						cv1 = c1 - Chars:ZERO;
					else if(c1 >= Chars:A && c1 <= Chars:F)
						cv1 = (c1 - Chars:A) + 10;
					else
						cv1 = 0;

					u8 ch = (cv0 * 16) + cv1;
					s.append(ch);

					c += 2; // skip %20 etc.
				}
				else
				{
					// invalid encoding, so we just do our best
					s.append(nameOrVal.chars[c]);
				}
			}
		}

		return s;
	}

	// Encode url paramters. URLs parameters (names/values) cannot contain ASCII characters other than A-Z, a-z, 0-9 and _-+ etc. This encodes all other characters to %FF where space would be %20 etc.
	shared String<u8> encodeParameters(IMap<String<u8>, String<u8>> params)
	{
		String<u8> s(params.size() * 16);

		IIterator<String<u8>> iter = params.getIterator();
		while(iter.hasNext())
		{
			String<u8> key = iter.next();
			String<u8> val = params.get(key);

			s.append(encodeParameter(key));
			s.append(Chars:EQUALS);
			s.append(encodeParameter(val));

			if(iter.hasNext() == true)
				s.append(Chars:AMPERSAND);
		}

		return s;
	}

	// Decode url paramters. URLs parameters (names/values) cannot contain ASCII characters other than A-Z, a-z, 0-9 and _-+ etc. This encodes all other characters to %FF where space would be %20 etc.
	shared IMap<String<u8>, String<u8>> decodeParameters(IMap<String<u8>, String<u8>> params)
	{
		IMap<String<u8>, String<u8>> map = ArrayMap<String<u8>, String<u8>>();

		IIterator<String<u8>> iter = params.getIterator();
		while(iter.hasNext())
		{
			String<u8> key = iter.next();
			String<u8> val = params.get(key);

			map.add(decodeParameter(key), decodeParameter(val));
		}

		return map;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// HTTP
////////////////////////////////////////////////////////////////////////////////////////////////////

// Constants for HTTP request/response.
class HTTP
{
	const u32 VERSION_1_0 = 0;
	const u32 VERSION_1_1 = 1;
	const u32 VERSION_2_0 = 2;

	// status codes - info
	const u32 STATUS_CONTINUE            = 100;
	const u32 STATUS_SWITCHING_PROTOCOLS = 101;

	// status codes - success
	const u32 STATUS_OK                   = 200;
	const u32 STATUS_CREATED              = 201;
	const u32 STATUS_ACCEPTED             = 202;
	const u32 STATUS_NON_AUTHORITIVE_INFO = 203;
	const u32 STATUS_NO_CONTENT           = 204;
	const u32 STATUS_RESET_CONTENT        = 205;
	const u32 STATUS_PARTIAL_CONTENT      = 206;

	// status codes - redirection
	const u32 STATUS_MULTI_CHOICES = 300;
	const u32 STATUS_MOVED_PERM    = 301;
	const u32 STATUS_FOUND         = 302; // ambigious

	// status codes - error
	const u32 STATUS_BAD_REQUEST        = 400;
	const u32 STATUS_UNAUTHORIZED       = 401;
	const u32 STATUS_PAYMENT_NEEDED     = 402;
	const u32 STATUS_FORBIDDEN          = 403;
	const u32 STATUS_NOT_FOUND          = 404;
	const u32 STATUS_METHOD_NOT_ALLOWED = 405;
	const u32 STATUS_NOT_ACCEPTABLE     = 406; // "accept: " not compatible
	const u32 STATUS_PROXY_REQUIRED     = 407;
	const u32 STATUS_REQUEST_TIMEOUT    = 408;

	shared String<u8> METHOD_GET("GET");
	shared String<u8> METHOD_HEAD("HEAD");
	shared String<u8> METHOD_POST("POST");
	shared String<u8> METHOD_PUT("PUT");
	shared String<u8> METHOD_DELETE("DELETE");
	shared String<u8> METHOD_TRACE("TRACE");
	shared String<u8> METHOD_OPTIONS("OPTIONS");
	shared String<u8> METHOD_CONNECT("CONNECT");
	shared String<u8> METHOD_PATCH("PATCH");
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// HTTPRequest
////////////////////////////////////////////////////////////////////////////////////////////////////

// Representation of client HTTP request (parsed from text stream)
class HTTPRequest
{
	String<u8> rawRequest(); // the original request text as recv'd from the client
	
	// request line
	String<u8> method(); // one of METHOD_XXX
	String<u8> url();
	IMap<String<u8>, String<u8>> urlParams    = ArrayMap<String<u8>, String<u8>>(); // ?name=val&name=val etc.
	IMap<String<u8>, String<u8>> cookieParams = ArrayMap<String<u8>, String<u8>>(); // name=value1 etc.
	u32    httpVersion; // one of HTTP_VERSION_

	// header field lines - not all http 1.1 here
	bool   keepAlive;               // Connection: keep-alive
	bool   upgradeConnection;       // Connection: upgrade 
	u32    contentLength;           // of body in bytes
	String<u8> accept();            // file types accepted
	String<u8> acceptEncoding();    // gzip, deflate etc.
	String<u8> contentType();       // of body
	String<u8> host();              // required, i.e. "en.wikipedia.org:80"
	String<u8> referer();           // url of web page user came from
	String<u8> userAgent();         // i.e. "Mozilla-5.1"
	String<u8> upgrade();           // i.e. "upgrade"
	String<u8> authUsername();      // for basic authorization which looks like "Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
	String<u8> authPassword();      // 
	ArrayList<String<u8>> miscLines(); // misc. lines we don't specifcally handle

	// body
	ByteArray body();

	// Empty request.
	void constructor()
	{
		initRequest();
	}

	// Basic request defined by raw text.
	void constructor(String<u8> reqText)
	{
		initRequest();
		parse(reqText);
	}

	// Basic post/put request.
	void constructor(String<u8> method, String<u8> host, String<u8> url)
	{
		initRequest();

		this.method = method;
		this.host   = host;
		this.url    = url;
		this.contentType = String<u8>("text/html");

		if(method.compare(HTTP:METHOD_POST) == true)
		{
			contentType = String<u8>("application/x-www-form-urlencoded");
		}
	}

	// Basic post/put request with parameters.
	void constructor(String<u8> method, String<u8> host, String<u8> url, ArrayMap<String<u8>, String<u8>> urlParams)
	{
		initRequest();

		this.method    = method;
		this.host      = host;
		this.url       = url;
		this.urlParams = urlParams;
		this.contentType = String<u8>("text/html");

		if(method.compare(HTTP:METHOD_POST) == true)
		{
			contentType = String<u8>("application/x-www-form-urlencoded");
		}
	}

	// Copy passed-in.
	void copy(HTTPRequest r)
	{
		this.rawRequest = String<u8>(r.rawRequest);
		
		// request line
		this.method = String<u8>(r.method);
		this.url    = String<u8>(r.url);
		this.httpVersion = r.httpVersion;

		// header field lines - not all http 1.1 here
		this.keepAlive         = r.keepAlive;
		this.upgradeConnection = r.upgradeConnection;
		this.contentLength     = r.contentLength;
		this.accept            = String<u8>(r.accept);
		this.acceptEncoding    = String<u8>(r.acceptEncoding);
		this.contentType       = String<u8>(r.contentType);
		this.host              = String<u8>(r.host);
		this.userAgent         = String<u8>(r.userAgent);
		this.upgrade           = String<u8>(r.upgrade);
		this.referer           = String<u8>(r.referer);
		this.authUsername      = String<u8>(r.authUsername);
		this.authPassword      = String<u8>(r.authPassword);

		this.cookieParams.clear();
		this.cookieParams.addAll(r.cookieParams);

		this.miscLines.clear();
		this.miscLines.addAll(r.miscLines);

		// body
		this.body = ByteArray(r.body);
	}

	// Get request key/value parameters.
	IMap<String<u8>, String<u8>> getParameters() { return urlParams; }

	// Get cookie key/value pairs.
	IMap<String<u8>, String<u8>> getCookie() { return cookieParams; }

	// Generate the request to send to the server (from internal values).
	String<u8> generateRequestString()
	{
		/* Example
		GET /docs/index.html HTTP/1.1
		Host: www.test101.com
		Accept: image/gif, image/jpeg
		Accept-Language: en-us
		Accept-Encoding : gzip, deflate
		User-Agent : Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)
		(blank line)
		*/

		String<u8> s("");

		s.append(method); // GET etc.
		s.append(" ");
		s.append(url);
		if(urlParams.size() > 0)
		{
			if(method.compare(HTTP:METHOD_POST))
			{
				// stuff url params in body
				contentType = String<u8>("application/x-www-form-urlencoded");

				String<u8> urlParamStr = URL:encodeParameters(urlParams);

				body.resize(urlParamStr.length());
				body.numUsed = urlParamStr.length();
				for(i32 c=0; c<urlParamStr.length(); c++)
					body.data[c] = urlParamStr.chars[c];
			}
			else // i.e. method == HTTP:METHOD_GET
			{
				s.append("?");

				String<u8> urlParamStr = URL:encodeParameters(urlParams);
				s.append(urlParamStr);
			}
		}
		s.append(" "); // after path/url

		if(httpVersion == HTTP:VERSION_1_1)
			s.append("HTTP/1.1");
		else if(httpVersion == HTTP:VERSION_2_0)
			s.append("HTTP/2.0");
		else 
			s.append("HTTP/1.0");
		s.append("\r\n");

		// header lines

		s.append("Content-Length: ");
		s.append(String<u8>:formatNumber(body.numUsed));
		s.append("\r\n");

		s.append("Content-Type: ");
		s.append(contentType);
		s.append("\r\n");

		// Host: en.wikipedia.org:80
		s.append("Host: ");
		s.append(host);
		s.append("\r\n");

		// Cookie: 
		s.append("Cookie: ");
		s.append(generateCookieString());
		s.append("\r\n");

		// Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
		if(authUsername.length() > 0 || authPassword.length() > 0)
		{
			// 1 Username and password are combined into a string "username:password".Note that username cannot contain the ":" character.[9]
			// 2 The resulting string is then encoded using the RFC2045-MIME variant of Base64, except not limited to 76 char/line[10]
			// 3 The authorization method and a space i.e. "Basic " is then put before the encoded string.

			String<u8> combinedUserPass(authUsername);
			combinedUserPass.append(Chars:COLON);
			combinedUserPass.append(authPassword);

			String<u8> combinedUserPassBase64 = FileSystem:encodeBytesToBase64(ByteArray(combinedUserPass));

			s.append("Authorization: Basic ");
			s.append(combinedUserPassBase64);
			s.append("\r\n");
		}

		for(u64 m=0; m<miscLines.size(); m++)
		{
			String<u8> miscLine = miscLines[m];
			s.append(miscLine);
			s.append("\r\n");
		}

		// body seperator (dual \r\n total, but first set comes from above)
		s.append("\r\n");

		// body data
		s.append(body.data, body.numUsed);

		return s;
	}

	// Generate cookie string form pairs.
	String<u8> generateCookieString()
	{
		String<u8> cookieStr(64);

		IIterator<String<u8>> cIter = cookieParams.getIterator();
		while(cIter.hasNext())
		{
			String<u8> cName = cIter.next();
			String<u8> cVal  = cookieParams.get(cName);

			cookieStr += cName + "=" + cVal + ";";
			if(cIter.hasNext())
				cookieStr += " ";
		}

		return cookieStr;
	}

	// Parse from passed-in request raw text.
	bool parse(String<u8> reqText)
	{
		this.rawRequest.copy(reqText);

		String<u8> headerText(128);

		// look for end of header
		i32 endOfHeaderEmptyLine = rawRequest.findNext(String<u8>("\r\n\r\n"), 0);
		if(endOfHeaderEmptyLine > 0)
		{
			headerText = rawRequest.subString(0, endOfHeaderEmptyLine-1); 
		}
		else
		{
			headerText.copy(rawRequest);
		}

		headerText.removeAll(Chars:RETURN); // useless
		ArrayList<String<u8>> headerLines = headerText.split(Chars:NEW_LINE, true);
		if(headerLines.size() == 0)
			return false;

		// first, parse request line
		if(parseReqLine(headerLines[0]) == false)
			return false; // required!

		// all other lines are optional "request header fields"
		for(u32 i=1; i<headerLines.size(); i++) // 1 to skip request line
		{
			parseHeaderFieldLine(headerLines[i]);
		}

		// body
		i32 startOfBodyIndex = endOfHeaderEmptyLine + 4; // skip \r\n\r\n
		if(contentLength > 0)
		{
			i32 remainingByteLen = reqText.length() - startOfBodyIndex;

			if(contentLength != remainingByteLen)
				contentLength = remainingByteLen;

			body.resize(remainingByteLen);
			body.numUsed = remainingByteLen;
			for(u32 b=0; b<remainingByteLen; b++)
			{
				i32 bIndex = startOfBodyIndex + b;
				if(bIndex >= reqText.length())
					continue;

				body.data[b] = reqText.chars[bIndex];
			}
		}

		// Post method - extract values from body of request
		if(method.compare(HTTP:METHOD_POST) && contentType.compare(String<u8>("application/x-www-form-urlencoded")))
		{
			// Examples
			//
			// POST / HTTP/1.1
			// Host: foo.com
			// Content-Type : application/x-www-form-urlencoded
			// Content-Length : 13
			//
			// say=Hi&to=Mom
			//

			// POST / HTTP/1.1
			// Host: 192.168.1.2
			// Connection : keep-alive
			// Content-Length : 155
			// Cache-Control : max-age = 0
			// Accept : text/html, application/xhtml+xml, application/xml; q = 0.9, image/webp, */*;q=0.8
			// Origin: https://192.168.1.2
			// Upgrade-Insecure-Requests: 1
			// User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36
			// Content-Type: application/x-www-form-urlencoded
			// DNT: 1
			// Referer: https://192.168.1.2/?xia182=addedituserform
			// Accept-Encoding: gzip, deflate
			// Accept-Language: en-US,en;q=0.8
			// xia182=addedituseraction&lickey=&maxseats=1&email=mike%40proceduraltech.com&firstname=Mike&lastname=Sikora&company=test&expiresdate=2016-10-02+20%3A48%3A51

			// add these to URL params list
			String<u8> paramsStr(body.data, body.numUsed);

			// %20 to space char etc.
			//URL:decodeURL(paramsStr); // paramsStr.decodeURL();

			// params
			IMap<String<u8>, String<u8>> newParams = URL:parseParameters(paramsStr, true);
			urlParams.addAll(newParams);

			//LOGMSG1("HTTPRequest:parse() method is post, content is x-www-form-urlencoded. Parsed Body String<u8>:\n", body.convertToString().createSTDCopy().c_str());
			//LOGMSG1("HTTPRequest:parse() method is post, content is x-www-form-urlencoded. Decoded Body String<u8>:\n", paramsStr.createSTDCopy().c_str());
			//LOGMSG1("HTTPRequest:parse() method is post, content is x-www-form-urlencoded. Parsed Params:\n", getURLParamsHumanString().createSTDCopy().c_str());
			//LOGMSG1("HTTPRequest:parse() method is post, content is x-www-form-urlencoded. Raw request:\n", rawRequest.createSTDCopy().c_str());
		}
		else if(method.compare(HTTP:METHOD_POST) && contentType.compare(String<u8>("text/plain")))
		{
			// add these to URL params list
			String<u8> paramsStr(body.data, body.numUsed); // body.convertToString();

			// + to space char etc.
			paramsStr.replaceAll(Chars:PLUS, Chars:SPACE);

			// params
			IMap<String<u8>, String<u8>> newParams = URL:parseParameters(paramsStr, true);
			urlParams.addAll(newParams);

			//LOGMSG1("HTTPRequest:parse() method is post, content is MIME:TextPlain. Parsed Params:\n", getURLParamsHumanString().createSTDCopy().c_str());
		}
		else if(method.compare(HTTP:METHOD_POST) && contentType.compare(String<u8>("multipart/form-data")))
		{
			// enctype="multipart/form-data"

			// UGH
			//WARN1("HTTPRequest:parse() method is post, but content is unsupported MIME:MultiPartFormData! Raw request:\n", rawRequest.createSTDCopy().c_str());
		}
		else if(method == HTTP:METHOD_POST)
		{
			//WARN1("HTTPRequest:parse() method is post, but content is unsupported mime type! Raw request:\n", rawRequest.createSTDCopy().c_str());
		}

		return true;
	}

	// Parse the request line, i.e. "GET /path/file.png HTTP/1.0"
	bool parseReqLine(String<u8> reqLine)
	{
		// request line, examples:
		// GET /food/img.png HTTP/1.0

		// parse method (GET, POST etc.)
		ArrayList<String<u8>> methods = getMethods();
		String<u8> curLine(reqLine);
		for(u32 m=0; m<methods.size(); m++)
		{
			String<u8> checkMethod(methods[m]);
			String<u8> checkMethodSpace(checkMethod); // + " ";
			checkMethodSpace.append(Chars:SPACE);

			if(curLine.beginsWith(checkMethodSpace, false) == true)
			{
				curLine = curLine.subString(checkMethodSpace.length(), curLine.length()-1);
				this.method = checkMethod;
				break;
			}
		}

		// parse path (AKA URL)
		i32 httpVerStart = curLine.findNext(String<u8>(" HTTP/"), 0);
		if(httpVerStart >= 0)
		{
			url = curLine.subString(0, httpVerStart-1);

			// parse HTTP version
			if(curLine.contains(String<u8>("HTTP/1.0")) == true)
				httpVersion = HTTP:VERSION_1_0;
			if(curLine.contains(String<u8>("HTTP/1.1")) == true)
				httpVersion = HTTP:VERSION_1_1;
			if(curLine.contains(String<u8>("HTTP/2")) == true)
				httpVersion = HTTP:VERSION_2_0;
		}
		else
		{
			// no http version ... assume 1.0
			url = String<u8>(curLine);
			httpVersion = HTTP:VERSION_1_0;
		}

		// %20 to space char etc.
		//URL:decodeURL(url); //url.decodeURL();

		// params
		urlParams = URL:parseParameters(url);

		// remove params from url
		i32 urlQIndex = url.findNext(Chars:QUESTION, 0);
		if(urlQIndex >= 0)
		{
			url = url.subString(0, urlQIndex-1);
		}

		return true;
	}

	// Parse a header field line
	bool parseHeaderFieldLine(String<u8> line)
	{
		String<u8> lowLine(line);
		lowLine.toLowercase();

		// Accept: text/plain
		String<u8> acceptName("accept:");
		if(lowLine.beginsWith(acceptName) == true)
		{
			accept = lowLine.subString(acceptName.length(), lowLine.length()-1);
			return true;
		}

		// Connection: keep-alive | Connection: Upgrade
		String<u8> connectionName("connection:");
		if(lowLine.beginsWith(connectionName) == true)
		{
			if(lowLine.contains("keep-alive") == true)
				keepAlive = true;

			if(lowLine.contains("upgrade") == true)
				upgradeConnection = true;

			return true;
		}

		// Content-Length: 348
		String<u8> contentLengthName("content-length:");
		if(lowLine.beginsWith(contentLengthName) == true)
		{
			String<u8> numStr = lowLine.subString(contentLengthName.length(), lowLine.length()-1);
			contentLength = numStr.parseInteger();
			return true;
		}

		// Content-Type: application/x-www-form-urlencoded
		String<u8> contentTypeName("content-type:");
		if(lowLine.beginsWith(contentTypeName) == true)
		{
			contentType = lowLine.subString(contentTypeName.length(), lowLine.length()-1);
			contentType.trimWhitespace();
			return true;
		}

		// Host: en.wikipedia.org:80
		String<u8> hostName("host:");
		if(lowLine.beginsWith(hostName, false) == true)
		{
			host = lowLine.subString(hostName.length(), lowLine.length()-1);
			sanitizeLine(host);
			return true;
		}

		// Cookie: name=value; name2=value2; name3=value3
		String<u8> cookieName("cookie:");
		if(lowLine.beginsWith(cookieName) == true)
		{
			String<u8> cookie = line.subString(cookieName.length(), line.length()-1);

			ArrayList<String<u8>> cookiePairs = cookie.split(Chars:SEMI_COLON, true);
			for(u64 c=0; c<cookiePairs.size(); c++)
			{
				String<u8> cStr = cookiePairs[c];

				i64 equalsIndex = cStr.findNext(Chars:EQUALS, 0);
				if(equalsIndex < 0)
					cookieParams.add(String<u8>(cStr), String<u8>(""));
				else
					cookieParams.add(cStr.subString(0, equalsIndex-1), cStr.subString(equalsIndex+1, cStr.length()-1));
			}

			return true;
		}

		// Referer: http://en.wikipedia.org/wiki/Main_Page
		String<u8> refererName("referer:");
		if(lowLine.beginsWith(refererName) == true)
		{
			referer = lowLine.subString(refererName.length(), lowLine.length()-1);
			sanitizeLine(referer);
			return true;
		}

		// User-Agent: Mozilla/5.0
		String<u8> userAgentName("user-agent:");
		if(lowLine.beginsWith(userAgentName) == true)
		{
			userAgent = lowLine.subString(userAgentName.length(), lowLine.length()-1);
			sanitizeLine(userAgent);
			return true;
		}

		// Upgrade: HTTP/2.0, SHTTP/1.3, IRC/6.9, RTA/x11
		String<u8> upgradeName("upgrade:");
		if(lowLine.beginsWith(upgradeName) == true)
		{
			upgrade = lowLine.subString(upgradeName.length(), lowLine.length()-1);
			sanitizeLine(userAgent);
			return true;
		}

		String<u8> modLine(line);
		modLine.removeAll("\r\n");
		miscLines.add(modLine);

		return true;
	}

	// Medicore line sanatization.
	void sanitizeLine(String<u8> line)
	{
		line.trimWhitespace();

		// Sanitize request lines (i.e. remove hacker type BS)
		if(line.contains(".exe") || line.contains(".bat") || line.contains("perl ") || line.contains("C:\\")|| line.contains("c:\\"))
			line.numChars = 0;

		if(line.contains("..")) // i.e. ..\     xxx
			line.numChars = 0;
	}

	// Return all HTTP methods.
	ArrayList<String<u8>> getMethods()
	{
		ArrayList<String<u8>> methods();
		methods.add(String<u8>(HTTP:METHOD_GET));
		methods.add(String<u8>(HTTP:METHOD_POST));
		methods.add(String<u8>(HTTP:METHOD_DELETE));
		methods.add(String<u8>(HTTP:METHOD_HEAD));
		methods.add(String<u8>(HTTP:METHOD_PATCH));
		methods.add(String<u8>(HTTP:METHOD_OPTIONS));
		methods.add(String<u8>(HTTP:METHOD_PUT));
		methods.add(String<u8>(HTTP:METHOD_TRACE));
		methods.add(String<u8>(HTTP:METHOD_CONNECT));
		return methods;
	}

	// Reset parameters etc.
	void initRequest()
	{
		this.rawRequest.clear();
		
		// request line
		this.method.clear();
		this.url.clear();
		this.httpVersion = HTTP:VERSION_1_1;

		// header field lines - not all http 1.1 here
		this.accept.clear();
		this.acceptEncoding .clear();
		this.keepAlive         = false;
		this.upgradeConnection = false;
		this.contentLength     = 0;
		this.contentType.clear();
		this.host.clear();
		this.userAgent.clear();
		this.upgrade.clear();
		this.referer.clear();
		this.authUsername.clear();
		this.authPassword.clear();
		this.miscLines.clear();

		// body
		this.body.numUsed = 0;
	}

	// For debugging/logging.
	String<u8> getURLParamsHumanString()
	{
		String<u8> s(128);

		IIterator<String<u8>> iter = urlParams.getIterator();
		while(iter.hasNext())
		{
			String<u8> key = iter.next();
			String<u8> val = urlParams.get(key);

			s.append(key);
			s.append("=");
			s.append(val);

			if(iter.hasNext())
				s.append(",");
		}

		return s;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// HTTPResponse
////////////////////////////////////////////////////////////////////////////////////////////////////

// Representation of server HTTP response
class HTTPResponse
{
	String<u8> rawResponse(); // the original response text as recv'd from the server

	// status line
	u32    statusCode;
	String<u8> reasonMsg(); // one of HTTP:METHOD_XXX
	u32    httpVersion; // one of HTTP_VERSION_

	// header field lines - not all http 1.1 here
	u32        contentLength;          // of body in bytes
	String<u8> contentType();          // of body
	String<u8> contentDisposition();   // Content-Disposition: attachment; filename=<file name.ext>
	String<u8> upgrade();              // i.e. "upgrade"
	String<u8> server();               // name for server, i.e. "Apache-1.0"
	bool   curDateTime;                // write "Date: Fri, 09 Mar 01:01:01 GMT" ?
	bool   lastModTime;                // write current date as well (help stop caching)
	bool   connectionClose;            // going to close as soon as finished sending?
	ArrayList<String<u8>> miscLines(); // misc. lines we don't specifcally handle
	
	// body
	ByteArray body();

	// Empty response.
	void constructor()
	{
		initResponse();
	}

	// Response from raw response text.
	void constructor(String<u8> responseStr)
	{
		initResponse();
		parse(responseStr);
	}

	// Release content.
	void destroy()
	{
		rawResponse = null;
		reasonMsg = null;
		contentType = null;
		contentDisposition = null;
		upgrade = null;
		server = null;
		body = null;
		miscLines = null;
	}

	// Copy passed-in.
	void copy(HTTPResponse r)
	{
		this.statusCode  = r.statusCode;
		this.reasonMsg   = String<u8>(r.reasonMsg);
		this.httpVersion = r.httpVersion;

		this.contentLength      = r.contentLength;
		this.contentType        = String<u8>(r.contentType);
		this.contentDisposition = String<u8>(r.contentDisposition);
		this.upgrade            = String<u8>(r.upgrade);
		this.server             = String<u8>(r.server);
		this.connectionClose    = r.connectionClose;
		this.curDateTime        = r.curDateTime;
		this.lastModTime        = r.lastModTime;

		this.miscLines.clear();
		this.miscLines.addAll(r.miscLines);

		this.body = ByteArray(r.body);
	}

	// Set as empty response.
	void initResponse()
	{
		this.statusCode  = HTTP:STATUS_OK;
		this.reasonMsg.clear();
		this.httpVersion = HTTP:VERSION_1_0;

		this.contentLength      = 0;
		this.contentType        = String<u8>("text/plain"); // MIME:TextPlain;
		this.contentDisposition.clear();
		this.upgrade.clear();
		this.server.clear();
		this.connectionClose    = false;
		this.curDateTime        = true;
		this.lastModTime        = true;
		this.miscLines.clear();

		this.body.numUsed = 0;
	}

	// Parse raw response text.
	bool parse(String<u8> resText)
	{
		this.rawResponse = String<u8>(resText);

		String<u8> headerText;

		// look for end of header
		i32 endOfHeaderEmptyLine = rawResponse.findNext(String<u8>("\r\n\r\n"), 0);
		if(endOfHeaderEmptyLine > 0)
		{
			headerText = rawResponse.subString(0, endOfHeaderEmptyLine-1);
		}
		else
		{
			headerText = rawResponse;
		}

		headerText.removeAll(Chars:RETURN); // useless
		ArrayList<String<u8>> headerLines = headerText.split(Chars:NEW_LINE, true);
		if(headerLines.size() == 0)
			return false;

		// first, parse request line
		if(parseFirstResponseLine(headerLines[0]) == false)
			return false; // required!

		// all other lines are optional "response header fields"
		for(u32 i=1; i<headerLines.size(); i++) // 1 to skip first response line already parsed
		{
			parseHeaderFieldLine(headerLines[i]);
		}

		// body
		i32 startOfBodyIndex = endOfHeaderEmptyLine + 4; // skip \r\n\r\n
		if(contentLength > 0)
		{
			i32 remainingByteLen = resText.length() - startOfBodyIndex;
			if(remainingByteLen != contentLength)
				contentLength = remainingByteLen;
			
			body.resize(contentLength);
			body.numUsed = contentLength;
			for(u32 b=0; b<contentLength; b++)
			{
				i32 bIndex = startOfBodyIndex + b;
				if(bIndex >= resText.length())
					break;

				body.data[b] = resText.chars[bIndex];
			}
		}

		return true;
	}

	// Parse first response line
	bool parseFirstResponseLine(String<u8> resLine)
	{
		// first response line, examples:
		// HTTP/1.1 200 OK

		ArrayList<String<u8>> strs = resLine.split(Chars:SPACE, true);

		bool parseOK = true;

		// parse HTTP version
		httpVersion = HTTP:VERSION_1_0;
		if(strs.size() > 0)
		{
			strs[0].toLowercase();

			if(strs[0].contains("http/1.0") == true)
				httpVersion = HTTP:VERSION_1_0;
			else if(strs[0].contains("http/1.1") == true)
				httpVersion = HTTP:VERSION_1_1;
			else if(strs[0].contains("http/2") == true)
				httpVersion = HTTP:VERSION_2_0;
			else
				parseOK = false;
		}

		if(strs.size() > 1)
		{
			i64 checkCode = strs[1].parseInteger();
			if(checkCode < 0)
			{
				statusCode = 0;
				parseOK = false;
			}
			else
				statusCode = checkCode;
		}

		if(strs.size() > 2)
		{
			reasonMsg = strs[2];
		}

		return parseOK;
	}

	// Parse other response lines
	bool parseHeaderFieldLine(String<u8> line)
	{
		String<u8> lowLine = line;
		lowLine.toLowercase();

		// Content-Length: 348
		String<u8> contentLengthName("content-length:");
		if(lowLine.beginsWith(contentLengthName) == true)
		{
			String<u8> numStr = lowLine.subString(contentLengthName.length(), lowLine.length()-1);
			contentLength = numStr.parseInteger();
			return true;
		}

		// Content-Type: application/x-www-form-urlencoded
		String<u8> contentTypeName("content-type:");
		if(lowLine.beginsWith(contentTypeName) == true)
		{
			contentType = lowLine.subString(contentTypeName.length(), lowLine.length()-1);
			contentType.trimWhitespace();
			return true;
		}

		// Upgrade: HTTP/2.0, SHTTP/1.3, IRC/6.9, RTA/x11
		String<u8> upgradeName("upgrade:");
		if(lowLine.beginsWith(upgradeName) == true)
		{
			upgrade = lowLine.subString(upgradeName.length(), lowLine.length()-1);
			return true;
		}

		String<u8> modLine(line);
		modLine.removeAll("\r\n");
		miscLines.add(modLine); // not specifcally handled.

		return true;
	}

	// Attach file.
	void setContentDispositionToEXE(String<u8> filename)
	{
		//String<u8> contentDisposition; // Content-Disposition: attachment; filename=<file name.ext>
		this.contentDisposition = String<u8>("attachment; filename=");
		this.contentDisposition.append(filename);
	}

	// Generate reponse as text.
	String<u8> toString()
	{
		return generateResponseString();
	}

	// Generate reponse as text.
	String<u8> generateResponseString()
	{
		String<u8> s(1024);

		// status line
		// HTTP/1.1 200 OK

		if(httpVersion == HTTP:VERSION_1_1)
			s.append("HTTP/1.1");
		else if(httpVersion == HTTP:VERSION_2_0)
			s.append("HTTP/2.0");
		else 
			s.append("HTTP/1.0");

		s.append(" ");
		s.append(String<u8>:formatNumber(statusCode));
		s.append(" ");
		s.append(reasonMsg);
		s.append("\r\n");

		// header lines

		s.append("Content-Length: ");
		s.append(String<u8>:formatNumber(body.numUsed));
		s.append("\r\n");

		s.append("Content-Type: ");
		s.append(contentType);
		s.append("\r\n");

		if(contentDisposition.length() > 0)
		{
			s.append("Content-Disposition: ");
			s.append(contentDisposition);
			s.append("\r\n");
		}
		
		if(upgrade.length() > 0)
		{
			s.append("Upgrade: ");
			s.append(upgrade);
			s.append("\r\n");
		}

		if(curDateTime == true)
		{
			DateTime dt();
			//s += "Date: Fri, 18 Sep 2015 07:01:10 GMT";
			s.append("Date: ");
			s.append(dt.getCalendar().toRFC1123String());
			s.append("\r\n");
		}

		if(lastModTime == true)
		{
			DateTime dt();
			//s += "Last-Modified: Fri, 18 Sep 2015 07:01:10 GMT";
			s.append("Last-Modified: ");
			s.append(dt.getCalendar().toRFC1123String());
			s.append("\r\n");
		}

		s.append("Server: ");
		s.append(server);
		s.append("\r\n");
		
		if(connectionClose == true)
		{
			s.append("Connection: close");
			s.append("\r\n");
		}

		for(u64 m=0; m<miscLines.size(); m++)
		{
			String<u8> miscLine = miscLines[m];
			s.append(miscLine);
			s.append("\r\n");
		}

		// body break line
		s.append("\r\n");

		// body data
		s.append(body.data, body.numUsed);

		return s;
	}

	// Create HTML webpage response.
	shared HTTPResponse createWebPage(String<u8> html)
	{
		HTTPResponse res();

		res.httpVersion   = HTTP:VERSION_1_1;
		res.statusCode    = HTTP:STATUS_OK;
		res.contentType   = String<u8>("text/html"); // MIME:TextHTML;
		res.contentLength = html.length();

		res.body.numUsed = 0;
		res.body.write(html.chars, html.numChars);

		return res;
	}

	// Create file reponse. File type determined by extension.
	shared HTTPResponse createFile(String<u8> filepath)
	{
		String<u8> mimeStr = MIME:byFileExtension(FileSystem:getFileExtension(filepath));
		if(mimeStr.compare("unknown/unknown"))
			return HTTPResponse();

		return createFile(filepath, mimeStr);
	}

	// Create file reponse.
	shared HTTPResponse createFile(String<u8> filepath, String<u8> mime)
	{
		if(FileSystem:getFileInfo(filepath).exists == false)
			return HTTPResponse();

		HTTPResponse res();

		res.body.numUsed = 0;
		if(FileSystem:readFile(filepath, res.body) == false)
			return HTTPResponse();

		res.httpVersion   = HTTP:VERSION_1_1;
		res.statusCode    = HTTP:STATUS_OK;
		res.contentType   = String<u8>(mime);
		res.contentLength = res.body.numUsed;

		if(mime.compare("application/x-msdownload"))
			res.setContentDispositionToEXE(FileSystem:getFilename(filepath, false));

		return res;
	}

	// Create file reponse.
	shared HTTPResponse createFile(ByteArray fileData, String<u8> mime)
	{
		HTTPResponse res();
		if(fileData == null)
			return res;

		res.body.copy(fileData);
		res.httpVersion   = HTTP:VERSION_1_1;
		res.statusCode    = HTTP:STATUS_OK;
		res.contentType   = String<u8>(mime);
		res.contentLength = res.body.numUsed;

		return res;
	}

	// Create JSON response.
	shared HTTPResponse createJSON(JSON jsonObj)
	{
		HTTPResponse res();

		String<u8> jsonStr = jsonObj.toString();

		res.httpVersion   = HTTP:VERSION_1_1;
		res.statusCode    = HTTP:STATUS_OK;
		res.contentType   = String<u8>("application/json");
		res.contentLength = jsonStr.length();

		res.body.numUsed = 0;
		res.body.write(jsonStr.chars, jsonStr.numChars);

		return res;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// IHTTPClient
////////////////////////////////////////////////////////////////////////////////////////////////////

// An HTTP client connection interface.
interface IHTTPClient
{
	// Get client IP.
	IPAddress getClientIP();

	// How many requests has the user sent so far?
	u32 getNumRequests();

	// Is this connection marked "keep-alive" ?
	bool isKeepAlive();

	// Get how long this connection has been alive
	f64 getConnectedTime();

	// Is client still connected?
	bool isConnected();

	// Disconnect.
	void disconnect();

	// Returns null if none waiting, otherwise you own HTTPRequest object now.
	HTTPRequest getNextRequest();

	// Respond - we own response object now.
	bool respond(HTTPResponse response);

	// Normally called by HTTPServer - checks for new requests.
	void update();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// HTTPClient
////////////////////////////////////////////////////////////////////////////////////////////////////

// An HTTP client connection (wraps TCPSocket). Represents a client from the server's perspective.
class HTTPClient implements IHTTPClient
{
	String<u8> partialReqStr(); // partial request - waiting for whole message
	ISocket socket; // connection to client
	ArrayList<HTTPRequest> requests(); // queue of requests from client
	f64  connectTime; // when connection was established
	bool keepAlive;
	u32  numRequestsHandled;
	u32  maxBufferSize;

	// Construct client from TCP connection. One megabyte default recv buffer.
	void constructor(ISocket socket)
	{
		this.constructor(socket, 1024 * 1024); // ONE MB
	}

	// Construct client from TCP connection.
	void constructor(ISocket socket, u32 maxRecvSizeBytes)
	{
		this.socket             = socket;
		this.keepAlive          = false;
		this.maxBufferSize      = maxRecvSizeBytes;
		this.connectTime        = System:getTime();
		this.numRequestsHandled = 0;
		this.partialReqStr.resize(maxBufferSize);
	}

	// Deletes any left-over requests.
	void destroy()
	{
		while(requests.size() > 0)
		{
			HTTPRequest req = requests.removeLast();
		}

		disconnect();
		socket = null;
	}

	// How many requests has the user sent so far?
	u32 getNumRequests() { return numRequestsHandled; }

	// Is this connection marked "keep-alive" ?
	bool isKeepAlive() { return keepAlive; }

	// Get how long this connection has been alive in milliseconds.
	f64 getConnectedTime() { return (System:getTime() - connectTime); }

	// Is client still connected?
	bool isConnected()
	{
		if(socket == null)
			return false;

		if(socket.getState() == SocketState:DISCONNECTED || socket.getState() == SocketState:CONNECT_FAILED)
			return false;

		return true;
	}

	// Returns null if none waiting, otherwise caller owns returned HTTPRequest object now.
	HTTPRequest getNextRequest()
	{
		update();

		if(requests.size() == 0)
			return null;

		numRequestsHandled++;

		HTTPRequest req = requests.remove(0);
		return req;
	}

	// Disconnects client.
	void disconnect()
	{
		if(socket == null)
			return;

		socket.disconnect();
	}

	// Respond - HTTPClient owns response object now.
	bool respond(HTTPResponse response)
	{
		if(response == null)
			return false;

		if(socket == null)
			return false;

		if(socket.getState() != SocketState:CONNECTING && socket.getState() != SocketState:CONNECTED)
			return false;

		String<u8> resStr = response.generateResponseString();

		if(socket.send(resStr.chars, resStr.numChars) == false)
			return false;

		// should we auto disconnect now?
		if(keepAlive == false || response.connectionClose == true)
			disconnect();

		return true;
	}

	// Normally called by HTTPServer - checks for new requests
	void update()
	{
		if(socket == null)
			return;

		socket.update();

		TLSServer tlsSock = socket;

		if(socket.getState() != SocketState:CONNECTING && socket.getState() != SocketState:CONNECTED)
			return;

		u32 numRecv = socket.receive(partialReqStr.chars, partialReqStr.numChars);
		if(numRecv > 0)
		{
			// update data used
			partialReqStr.numChars += numRecv;

			// check if we have a whole request
			i32 firstBodyBreak = partialReqStr.findNext("\r\n\r\n", 0);
			if(firstBodyBreak > 0)
			{
				String<u8> contentLenName("Content-Length:");
				i32 bodyContentLenIndex = partialReqStr.findNext(contentLenName, 0);
				if(bodyContentLenIndex > 0)
				{
					if(bodyContentLenIndex > firstBodyBreak)
					{
						// error, bail
						socket.disconnect();
						return;
					}
					
					i32 bodyContentLenEndIndex = partialReqStr.findNext("\r\n", bodyContentLenIndex);
					i32 bodyContentLen = 0;
					if(bodyContentLenEndIndex > 0)
					{
						String<u8> bodyContentLenStr = partialReqStr.subString(bodyContentLenIndex + contentLenName.length(), bodyContentLenEndIndex-1);
						bodyContentLen = bodyContentLenStr.parseInteger();
					}

					if(bodyContentLen > 0)
					{
						String<u8> newReqStr = partialReqStr.subString(0, firstBodyBreak + 4 + bodyContentLen);
						HTTPRequest newReq(newReqStr);
						requests.add(newReq);

						// discard used text
						partialReqStr = partialReqStr.subString(firstBodyBreak + 4 + bodyContentLen, partialReqStr.length()-1);
					}
					else
					{
						// no body
						String<u8> newReqStr = partialReqStr.subString(0, firstBodyBreak + 3);
						HTTPRequest newReq(newReqStr);
						requests.add(newReq);

						// discard used text
						partialReqStr = partialReqStr.subString(firstBodyBreak + 4, partialReqStr.length()-1);
					}
				}
				else
				{
					// must be no body
					String<u8> newReqStr = partialReqStr.subString(0, firstBodyBreak + 3);
					HTTPRequest newReq(newReqStr);
					requests.add(newReq);

					// discard used text
					partialReqStr = partialReqStr.subString(firstBodyBreak + 4, partialReqStr.length()-1);
				}
			}
		}

		// keep lots of space for additions

		if(partialReqStr == null)
			partialReqStr = String<u8>(maxBufferSize);

		if(partialReqStr.chars == null)
			partialReqStr.resize(maxBufferSize);

		if(partialReqStr.chars.length() < maxBufferSize)
			partialReqStr.resize(maxBufferSize);

		// check if latest HTTPRequest says "keep-alive"
		if(requests.size() > 0)
		{
			this.keepAlive = requests.getLast().keepAlive;
		}
	}

	// Get client IP
	IPAddress getClientIP()
	{
		if(socket == null)
			return IPAddress();

		return socket.getDestinationIP();
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// WebsocketClient
////////////////////////////////////////////////////////////////////////////////////////////////////

// A websocket client connection - TODO.
class WebsocketClient
{

}

////////////////////////////////////////////////////////////////////////////////////////////////////
// IHTTPServerRequestHandler
////////////////////////////////////////////////////////////////////////////////////////////////////

// Each time a fully formed request is made to HTTPServer this listener is called.
interface IHTTPServerRequestHandler
{
	// Called once per request. Implementer responsible for deleting HTTPRequest.
	void onHTTPRequest(IHTTPClient client, HTTPRequest req, bool tlsEnabled);

	// Call this regularly to handle async responses (i.e. multiple times per second)
	void update();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// HTTPServer
////////////////////////////////////////////////////////////////////////////////////////////////////

// A simple multi-thread HTTP server. Each TCP connection gets its own thread. It recieves
// the request, parses it, returns it to the main thread. The main thread than creates the
// response, sends it back to the child who then sends it to the client and closes the
// connection.
class HTTPServer
{
	const u32 DEFAULT_RECV_BUF_SIZE        = 1048576; // 1 MB
	const u32 DEFAULT_MAX_CONCURRENT_CONNS = 32;

	TCPSocket                 listenSocket;   // listens for incomming connections
	ArrayList<HTTPClient>     connections();  // established connections
	IHTTPServerRequestHandler reqHandler;     // each time we have a fully recv HTTP request we call this to handle it
	String<u8> hostDomain(); // i.e. prontoware.com
	u32    maxConcurrentConns = 32;
	u32    maxBufferSize      = 1024;

	// For TLS (HTTPS)
	RSAKey               privateKey = null; // RSA private key that matches serverCert public key
	X509Certificate      serverCert = null; // parsed server end-entity certificate
	ArrayList<ByteArray> certFiles  = null; // this is all the server certs in binary DER format (X509) in-order with server end-entity cert last

	f64 MAX_HTTP_KEEP_ALIVE_TIME = 1000.0 * 60.0 * 10.0; // 10 minutes

	// Statistics
	u64 statsNumConnections = 0; // number of connections attempted

	// Unconnected server. Call startHTTP() or startHTTPS() to begin.
	void constructor()
	{
		this.listenSocket       = null;
		this.reqHandler         = null;
		this.hostDomain         = String<u8>("");
		this.maxConcurrentConns = 0;
	}

	// Release memory
	void destroy()
	{
		stop();
		listenSocket = null;
	}

	// Get socket backing this server for listening to new connections. Can be null if not connected.
	ISocket getSocket()
	{
		return listenSocket;
	}

	// Get server IP/port.
	IPAddress getServerIP()
	{
		if(listenSocket == null)
			return IPAddress();

		return listenSocket.getSourceIP();
	}

	// Start running an HTTP server on specified ip/port. If ipAddr is null will be auto choosen. If port is zero it will be auto choosen too (80).
	bool startHTTP(IHTTPServerRequestHandler reqHandler, IPAddress ipAddr, u32 port, String<u8> hostDomain)
	{
		if(listenSocket != null)
			stop();

		this.reqHandler         = reqHandler;
		this.hostDomain         = hostDomain;
		this.maxConcurrentConns = DEFAULT_MAX_CONCURRENT_CONNS;
		this.maxBufferSize      = DEFAULT_RECV_BUF_SIZE;

		// find ip that isn't local loop back
		ArrayList<IPAddress> ips = Network:getHostIPs();
		IPAddress ipToUse(127, 0, 0, 1, port);
		for(u64 i=0; i<ips.size(); i++)
		{
			IPAddress checkIP = ips[i];
			if(checkIP.getIPBytes()[0] == 127)
				continue;

			ipToUse = checkIP;
			ipToUse.setPort(port);
		}

		this.listenSocket = TCPSocket();
		this.listenSocket.listen(ipToUse);

		return true;
	}

	// Start running an HTTPS server on specified ip/port. If ipAddr is null will be auto choosen. If port is zero it will be auto choosen too (443). serverCertsPEM should be in-order with root first, end-entity cert last.
	bool startHTTPS(IHTTPServerRequestHandler reqHandler, IPAddress ipAddr, u32 port, String<u8> hostDomain, String<u8> serverCertsPEM, String<u8> serverKeyPEM)
	{
		if(startHTTP(reqHandler, ipAddr, port, hostDomain) == false)
			return false;

		this.privateKey = RSAKey:readPKCS1(serverKeyPEM);
		if(this.privateKey == null)
			return false; // failed to read private key

		this.certFiles = X509Certificate:decodePEMCertificates(serverCertsPEM);
		if(certFiles == null)
			return false; // failed to decode PEM certs
		if(certFiles.size() == 0)
			return false; // failed to find any certs (need at least end-entity cert)

		// try to parse server cert file
		this.serverCert = X509Certificate();
		if(this.serverCert.readCertificate(certFiles.getLast()) == false)
			return false; // failed to read server end-entity certificate file

		return true;
	}

	// Stop running the HTTP server.
	void stop()
	{
		while(connections.size() > 0)
		{
			HTTPClient client = connections.removeLast();
			client.disconnect();
		}

		if(listenSocket != null)
			listenSocket.disconnect();
		listenSocket = null;
	}

	// Update - call frequently to push requests out.
	void update()
	{
		if(listenSocket == null)
			return;

		// accept new HTTP clients
		TCPSocket newTCPSocket = listenSocket.accept();
		while(newTCPSocket != null)
		{
			// TLS mode ?
			ISocket newSocket = newTCPSocket;
			if(this.serverCert != null)
				newSocket = TLSServer(newTCPSocket, null, this.privateKey, this.serverCert, this.certFiles);
			
			HTTPClient newHTTPClient(newSocket, maxBufferSize);
			connections.add(newHTTPClient);

			statsNumConnections++;

			// another?
			newTCPSocket = listenSocket.accept();
		}

		// Update and hand requests out from existing client connections etc.
		for(u32 c=0; c<connections.size(); c++)
		{
			connections[c].update();

			HTTPRequest req = connections[c].getNextRequest();
			if(req != null)
			{
				bool tlsEnabled = false;
				if(serverCert != null)
					tlsEnabled = true;

				reqHandler.onHTTPRequest(connections[c], req, tlsEnabled);
			}
		}

		// Remove disconnected clients
		for(i32 x=0; x<connections.size(); x++)
		{
			if(connections[x].isConnected() == true)
				continue;

			HTTPClient deadClient = connections.remove(x);
			deadClient.disconnect();

			x--; // don't skip next
		}

		// Disconnect really old connections
		for(i32 r=0; r<connections.size(); r++)
		{
			HTTPClient checkConn = connections[r];
			assert(checkConn != null);

			if(checkConn.getConnectedTime() > MAX_HTTP_KEEP_ALIVE_TIME)
			{
				connections.remove(r);
				checkConn.disconnect();
				r--; // don't skip next
			}
		}

		// check for too many connections
		if(connections.size() > maxConcurrentConns)
		{
			while(connections.size() > maxConcurrentConns)
			{
				// find oldest and disconnect
				i32 killConnIndex = -1;
				for(u32 q=0; q<connections.size(); q++)
				{
					HTTPClient checkConn2 = connections[q];

					if(killConnIndex == -1)
					{
						killConnIndex = q;
					}
					else
					{
						if(checkConn2.getConnectedTime() > connections[killConnIndex].getConnectedTime())
						{
							killConnIndex = q;
						}
					}
				}

				if(killConnIndex != -1)
				{
					HTTPClient killConn = connections.remove(killConnIndex);
					killConn.disconnect();
				}
			}
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// HTTPConnection
////////////////////////////////////////////////////////////////////////////////////////////////////

// A connection to an HTTP/HTTPS server. Use this to connect to an HTTP server make HTTP requests
// and receive HTTP responses. This allows you to download webpages, images, files etc.
class HTTPConnection
{
	const u32 DEFAULT_MAX_RECV_SIZE = 8388608; // 8 MB

	String<u8> partialResStr(1024); // partial response - waiting for whole message
	ISocket socket; // connection
	ArrayList<HTTPResponse> responses(); // queue of responses from server - only more than one when keepAlive=true
	f64  connectTime; // when connection was established
	bool keepAlive;
	u32  maxBufferSize;

	// Unconnected.
	void constructor()
	{
		this.socket = null;
	}

	// Make requests via already connected socket.
	void constructor(ISocket socket)
	{
		connect(socket, DEFAULT_MAX_RECV_SIZE);
	}

	// Connect to a HTTP server via domain. Examples: "prontoware.com", "http://prontoware.com", "192.168.1.1:8080".
	void constructor(String<u8> domainURL)
	{
		connect(domainURL);
	}

	// Drop requests etc.
	void destroy()
	{
		while(responses.size() > 0)
		{
			HTTPResponse res = responses.removeLast();
		}

		socket.disconnect();
		socket = null;
	}

	// Connect to a HTTP server. Examples: "prontoware.com", "192.168.1.1:8080".
	void connect(String<u8> domainURL)
	{
		IPAddress ipAddr = Network:resolveDomainToIP(domainURL);
		
		TCPSocket tcpSocket = TCPSocket();
		tcpSocket.connect(ipAddr);

		connect(tcpSocket, DEFAULT_MAX_RECV_SIZE);
	}

	// Make requests via already connected TCP socket.
	void connect(ISocket socket, u32 maxRecvSizeBytes)
	{
		this.socket        = socket;
		this.maxBufferSize = maxRecvSizeBytes;
		this.keepAlive     = false;
		this.connectTime   = System:getTime();
		this.partialResStr.resize(maxBufferSize);
	}

	// Set maximum acceptable response size.
	void setMaxResponseSize(u32 size)
	{
		this.maxBufferSize = size;
		this.partialResStr.resize(size);
	}

	// Is this connection marked "keep-alive" ?
	bool isKeepAlive() { return keepAlive; }

	// Get how long this connection has been alive
	f64 getConnectedTime() { return (System:getTime() - connectTime); }

	// Get number of responses waiting to be processed
	u32 getNumResponses() { return responses.size(); }

	// Get HTTP server IP.
	IPAddress getServerIP()
	{
		return socket.getDestinationIP();
	}

	// Is client still connected?
	bool isConnected()
	{
		if(socket == null)
			return false;

		if(socket.getState() == SocketState:DISCONNECTED || socket.getState() == SocketState:CONNECT_FAILED)
			return false;

		return true;
	}

	// Disconnect
	void disconnect()
	{
		if(socket != null)
			socket.disconnect();
	}

	// Returns null if none waiting, otherwise you own HTTPRequest object now.
	HTTPResponse getNextResponse()
	{
		update();

		if(responses.size() == 0)
			return null;

		HTTPResponse res = responses.remove(0);

		return res;
	}

	// Make a GET/POST etc. request to the server.
	bool request(HTTPRequest request)
	{
		if(request == null)
			return false;

		if(socket == null)
			return false;

		String<u8> reqStr = request.generateRequestString();

		if(socket.send(reqStr.chars, reqStr.numChars) == false)
			return false;

		// now we wait until update finds a complete response...

		return true;
	}

	// Call frequently - checks for new requests.
	void update()
	{
		if(socket == null)
			return;

		if(this.isConnected() == false)
			return;

		if(partialResStr == null)
		{
			assert(false);
			return;
		}

		u32 numRecv = socket.receive(partialResStr.chars, partialResStr.numChars);
		if(numRecv > 0)
		{
			// update data used
			partialResStr.numChars += numRecv;

			// check if we have a whole response
			i32 firstBodyBreak = partialResStr.findNext("\r\n\r\n", 0);
			if(firstBodyBreak > 0)
			{
				String<u8> contentLenName("Content-Length:");
				i32 bodyContentLenIndex = partialResStr.findNext(contentLenName, 0);
				if(bodyContentLenIndex > 0)
				{
					if(bodyContentLenIndex > firstBodyBreak)
					{
						// error, bail
						socket.disconnect();
						return;
					}

					i32 bodyContentLenEndIndex = partialResStr.findNext("\r\n", bodyContentLenIndex);
					i32 bodyContentLen = 0;
					if(bodyContentLenEndIndex > 0)
					{
						String<u8> bodyContentLenStr = partialResStr.subString(bodyContentLenIndex + contentLenName.length(), bodyContentLenEndIndex-1);
						bodyContentLen = bodyContentLenStr.parseInteger();
					}

					if(bodyContentLen > 0)
					{
						String<u8> newResStr = partialResStr.subString(0, firstBodyBreak + 4 + bodyContentLen);
						HTTPResponse newRes(newResStr);
						responses.add(newRes);

						// discard used text
						partialResStr = partialResStr.subString(firstBodyBreak + 4 + bodyContentLen, partialResStr.length()-1);
					}
					else
					{
						// no body
						String<u8> newResStr = partialResStr.subString(0, firstBodyBreak + 3);
						HTTPResponse newRes(newResStr);
						responses.add(newRes);

						// discard used text
						partialResStr = partialResStr.subString(firstBodyBreak + 4, partialResStr.length()-1);
					}
				}
				else
				{
					// must be no body
					String<u8> newResStr = partialResStr.subString(0, firstBodyBreak + 3);
					HTTPResponse newRes(newResStr);
					responses.add(newRes);

					// discard used text
					partialResStr = partialResStr.subString(firstBodyBreak + 4, partialResStr.length()-1);
				}
			}
		}

		// keep lots of space for additions
		if(partialResStr == null)
			partialResStr = String<u8>(10);
		else if(partialResStr.chars == null)
			partialResStr.resize(10);

		// keep lots of space for additions
		if(partialResStr.chars.length() < maxBufferSize)
			partialResStr.resize(maxBufferSize);
	}
}