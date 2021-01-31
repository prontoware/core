////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

// Each time a fully formed request is made to HTTPServer this listener is called.
class HTTPServerTestHandler implements IHTTPServerRequestHandler
{
	void constructor()
	{

	}

	// Called once per request. Implementer responsible for deleting HTTPRequest.
	void onHTTPRequest(IHTTPClient client, HTTPRequest req, bool sslEnabled)
	{
		HTTPResponse res = HTTPResponse:createWebPage(String<u8>("<html><body>Hello!</body></html>"));
		client.respond(res);
		client.disconnect();
	}

	// Call this regularly to handle async responses (i.e. multiple times per second)
	void update()
	{
		// NOP
	}
}

class URLCreateTests implements IUnitTest
{
	void run()
	{
		String<u8> baseURL("http://www.prontoware.com/");

		ArrayMap<String<u8>, String<u8>> params();
		params.add(String<u8>("name"), String<u8>("Mac James"));

		String<u8> fullURL = URL:create(baseURL, params);
		test(fullURL.compare("http://www.prontoware.com/?name=Mac%20James") == true);
	}
}

class URLParamEncodeTests implements IUnitTest
{
	void run()
	{
		// encode parameters "http://prontoware.com/page.html?fullName=Mac James&" to
		//        "http://prontoware.com/page.html?fullName=Mac%20James" etc.

		String<u8> aOriginal("Mac James");

		String<u8> aEncoded = URL:encodeParameter(aOriginal);
		test(aEncoded.compare("Mac%20James") == true);

		String<u8> aDecoded = URL:decodeParameter(aEncoded);
		test(aDecoded.compare("Mac James") == true);
	}
}

class URLParamParsingTests implements IUnitTest
{
	void run()
	{
		String<u8> urlStr("http://prontoware.com/page.html?a=123&id=cat");

		ArrayMap<String<u8>, String<u8>> params = URL:parseParameters(urlStr, false);
		test(params != null);
		test(params.size() == 2);
		test(params.get(String<u8>("a")) != null);
		test(params.get(String<u8>("a")).parseInteger() == 123);
		test(params.get(String<u8>("id")) != null);
		test(params.get(String<u8>("id")).compare("cat") == true);
	}
}

class URLParamParsingDecodeTests implements IUnitTest
{
	void run()
	{
		// decdode parameters "http://prontoware.com/page.html?fullName=Mac James&id=89" to
		//        "http://prontoware.com/page.html?fullName=Mac%20James" etc.

		String<u8> urlStr("http://prontoware.com/page.html?fullName=Mac James&id=89");

		ArrayMap<String<u8>, String<u8>> params = URL:parseParameters(urlStr, true);
		test(params != null);
		test(params.size() == 2);
		test(params.get(String<u8>("fullName")) != null);
		test(params.get(String<u8>("fullName")).compare("Mac James") == true);

		String<u8> idValStr = params.get(String<u8>("id"));
		test(idValStr != null);

		if(idValStr != null)
			test(idValStr.parseInteger() == 89);
	}
}

class ParseHTTPGetRequestTests implements IUnitTest
{
	void run()
	{
		// Example request from Chrome.

		String<u8> reqText(1024);
		reqText += "GET /pages_contact?name=Mike+Sikora&email=mike%40prontoware.com&phone=6477678899&message=This+is+the+body+text. HTTP/1.1" + "\r\n";
		reqText += "Host: 192.168.1.2:8080" + "\r\n";
		reqText += "Connection: keep-alive" + "\r\n";
		reqText += "Cache-Control: max-age=0" + "\r\n";
		reqText += "Origin: http://192.168.1.2:8080" + "\r\n";
		reqText += "Upgrade-Insecure-Requests: 1" + "\r\n";
		reqText += "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36" + "\r\n";
		reqText += "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" + "\r\n";
		reqText += "DNT: 1" + "\r\n";
		reqText += "Referer: http://192.168.1.2:8080/pages_contact" + "\r\n";
		reqText += "Accept-Encoding: gzip, deflate" + "\r\n";
		reqText += "Accept-Language: en-US,en;q=0.8" + "\r\n";

		HTTPRequest req(reqText);

		test(req.method.compare("GET") == true);
		test(req.getParameters().get("name") != null);
		test(req.getParameters().get("name").compare("Mike Sikora") == true);
	}
}

class ParseHTTPPostRequestTests implements IUnitTest
{
	void run()
	{
		// Example request from Chrome.

		String<u8> reqText(1024);
		reqText += "POST /pages_contact HTTP/1.1" + "\r\n";
		reqText += "Host: 192.168.1.2:8080" + "\r\n";
		reqText += "Connection: keep-alive" + "\r\n";
		reqText += "Content-Length: 125" + "\r\n";
		reqText += "Cache-Control: max-age=0" + "\r\n";
		reqText += "Origin: http://192.168.1.2:8080" + "\r\n";
		reqText += "Upgrade-Insecure-Requests: 1" + "\r\n";
		reqText += "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36" + "\r\n";
		reqText += "Content-Type: application/x-www-form-urlencoded" + "\r\n";
		reqText += "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" + "\r\n";
		reqText += "DNT: 1" + "\r\n";
		reqText += "Referer: http://192.168.1.2:8080/pages_contact" + "\r\n";
		reqText += "Accept-Encoding: gzip, deflate" + "\r\n";
		reqText += "Accept-Language: en-US,en;q=0.8" + "\r\n";

		reqText += "\r\n"; // break to body

		reqText += "name=Mike+Sikora&email=mike%40prontoware.com&phone=6477175734&message=This+is+the+body+text.%09%09%09%09%09%09%09%09%09%09%09";

		HTTPRequest req(reqText);

		test(req.method.compare("POST") == true);
		test(req.contentType != null);
		test(req.contentType.compare("application/x-www-form-urlencoded") == true);
		test(req.contentLength == 125);
		String<u8> bodyStr(req.body.data, req.body.size());
		test(bodyStr.numChars == 125);
		test(bodyStr.compare("name=Mike+Sikora&email=mike%40prontoware.com&phone=6477175734&message=This+is+the+body+text.%09%09%09%09%09%09%09%09%09%09%09") == true);
		test(req.getParameters().get("name") != null);
		test(req.getParameters().get("name").compare("Mike Sikora") == true);
	}
}

class ParseHTTPReqCookiesTests implements IUnitTest
{
	void run()
	{
		// Example request from Chrome.

		String<u8> reqText(1024);
		reqText += "GET /pages_contact HTTP/1.1" + "\r\n";
		reqText += "Host: 192.168.1.2:8080" + "\r\n";
		reqText += "Origin: http://192.168.1.2:8080" + "\r\n";
		reqText += "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36" + "\r\n";
		reqText += "Content-Type: application/x-www-form-urlencoded" + "\r\n";
		reqText += "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" + "\r\n";
		reqText += "Referer: http://192.168.1.2:8080/pages_contact" + "\r\n";
		reqText += "Accept-Encoding: gzip, deflate" + "\r\n";
		reqText += "Accept-Language: en-US,en;q=0.8" + "\r\n";
		reqText += "Cookie: SID=298; email=mike@prontoware.com; pass=ABCDEF;" + "\r\n";

		HTTPRequest req(reqText);

		test(req.method.compare("GET") == true);
		test(req.getCookie().get("SID") != null);
		test(req.getCookie().get("SID").compare("298") == true);
		test(req.getCookie().get("pass") != null);
		test(req.getCookie().get("pass").compare("ABCDEF") == true);
	}
}

class ParseHTTPResponseTests implements IUnitTest
{
	void run()
	{
		// Example response.

		String<u8> resHTML();
		resHTML += "<html><body>Hi</body></html>";

		String<u8> resText(1024);
		resText += "HTTP/1.1 200 OK" + "\r\n";
		resText += "Date: Mon, 5 Jun 2017 12:21:13 GMT" + "\r\n";
		resText += "Server: Apache/2.2.14 (Win32)" + "\r\n";
		resText += "Last-Modified: Mon, 5 Jun 2017 12:21:13 GMT" + "\r\n";
		resText += "Content-Length: " + resHTML.length() + "\r\n";
		resText += "Content-Type: text/html" + "\r\n";
		resText += "Connection: Closed" + "\r\n";
		resText += "\r\n"; // body separator
		resText += resHTML;

		HTTPResponse res(resText);

		test(res.httpVersion == HTTP:VERSION_1_1);
		test(res.statusCode == 200);
		test(res.reasonMsg != null);
		test(res.reasonMsg.compare("OK") == true);
		test(res.contentLength == resHTML.length());
		test(res.contentType != null);
		test(res.contentType.compare("text/html") == true);
		test(res.body != null);
		test(res.body.toString().compare(resHTML) == true);
	}
}

class SerializeHTTPResponseTests implements IUnitTest
{
	void run()
	{
		// Construct response.

		HTTPResponse res();
		res.httpVersion = HTTP:VERSION_1_1;
		res.statusCode  = 200;
		res.reasonMsg   = String<u8>("OK");
		res.miscLines.add(String<u8>("Special1: nonstandard"));
		res.miscLines.add(String<u8>("Special2: nonstandard"));

		String<u8> resStr = res.toString();

		test(resStr.contains("HTTP/1.1") == true);
		test(resStr.contains("200 OK") == true);
		test(resStr.contains("Special1: nonstandard") == true);
	}
}

class HTTPConnectionTests implements IUnitTest
{
	void run()
	{
		// Download a webpage.

		HTTPConnection httpConn(String<u8>("google.com"));
		HTTPRequest    httpReq(String<u8>("GET"), String<u8>("google.com:80"), String<u8>("/index.html"));

		test(httpConn.request(httpReq) == true);

		f64 giveUpTime = System:getTime() + 5000.0;
		bool gotResp = false;
		while(System:getTime() < giveUpTime)
		{
			HTTPResponse res = httpConn.getNextResponse();
			if(res != null)
			{
				test(res.rawResponse != null);
				test(res.rawResponse.length() >= 100);
				test(res.rawResponse.contains(String<u8>("Bad Request")) == false && res.rawResponse.contains(String<u8>("bad request")) == false);
				gotResp = true;

				break;
			}
		}

		httpConn.disconnect();

		test(gotResp == true);
	}
}

class HTTPSConnectionTests implements IUnitTest
{
	void run()
	{
		// Download a webpage using TLS (AKA SSL) connection.
		IPAddress ipAddr = Network:resolveDomainToIP("https://www.google.com");

		TCPSocket tcpSocket = TCPSocket();
		tcpSocket.connect(ipAddr);

		TLSClient tlsClient(tcpSocket); // wraps tcpSocket

        f64 maxTime = System:getTime() + 5000.0;
        while(System:getTime() < maxTime && tlsClient.getTLSState() != TLSClient:STATE_APP_DATA)
        {
            tlsClient.update();
        }

		// successful handshake?
		test(tlsClient.getTLSState() == TLSClient:STATE_APP_DATA);
		if(tlsClient.getTLSState() != TLSClient:STATE_APP_DATA)
			return;

		// HTTP request and response... from https://policies.google.com/terms?hl=en-US
		HTTPConnection httpConn(tlsClient);
		HTTPRequest    httpReq(String<u8>("GET"), String<u8>("policies.google.com:443"), String<u8>("/terms?hl=en-US"));

		test(httpConn.request(httpReq) == true);

		f64 giveUpTime = System:getTime() + 5000.0;
		bool gotResp = false;
		while(System:getTime() < giveUpTime)
		{
			HTTPResponse res = httpConn.getNextResponse();
			if(res != null)
			{
				test(res.rawResponse != null);
				test(res.rawResponse.length() >= 100);
				test(res.rawResponse.contains(String<u8>("Bad Request")) == false && res.rawResponse.contains(String<u8>("bad request")) == false);
				test(res.rawResponse.contains(String<u8>("HTTP/1.1 200 OK")));
			
				gotResp = true;

				//Log:log("HTTPSConnectionTests rawResponse = " + res.rawResponse + "\n");

				break;
			}
		}

		httpConn.disconnect();

		test(gotResp == true);

        //tlsClient.disconnect();

		/*

		HTTPConnection httpConn(String<u8>("https://www.google.com"), caCerts);
		HTTPRequest    httpReq(String<u8>("GET"), String<u8>("google.com:443"), String<u8>("/intl/en/policies/terms/"));

		test(httpConn.request(httpReq) == true);

		f64 giveUpTime = System:getTime() + 5000.0;
		bool gotResp = false;
		while(System:getTime() < giveUpTime)
		{
			HTTPResponse res = httpConn.getNextResponse();
			if(res != null)
			{
				test(res.rawResponse != null);
				test(res.rawResponse.length() >= 100);
				test(res.rawResponse.contains(String<u8>("Bad Request")) == false && res.rawResponse.contains(String<u8>("bad request")) == false);

				gotResp = true;

				break;
			}
		}

		httpConn.disconnect();

		test(gotResp == true);
		*/
	}
}

class HTTPServerTests implements IUnitTest
{
	void run()
	{
		// Server webpage up via HTTP.
		HTTPServer httpServer();

		// TCP sockets that are bound don't become available again immediately after unbind() call on windows etc., but 
		// we run unit tests twice quickly (i.e. byte code and x86), hence random port needed.
		RandomFast rand = RandomFast(System:getTime());
		i32 randPort = 3026 + rand.getI32(1, 60000);

		HTTPServerTestHandler serverHandler();
		httpServer.startHTTP(serverHandler, null, randPort, String<u8>(""));

		f64 giveUpTime = System:getTime() + 5000.0;
		while(httpServer.getSocket().getState() != SocketState:CONNECTED && System:getTime() < giveUpTime)
		{
			// wait...
		}

		test(httpServer.getSocket().getState() == SocketState:CONNECTED);

		bool gotResp = false;

		HTTPConnection httpConn(httpServer.getServerIP().toString());
		HTTPRequest    httpReq(String<u8>("GET"), httpServer.getServerIP().toString(), String<u8>("/index.html"));
		test(httpConn.request(httpReq) == true);

		giveUpTime = System:getTime() + 10000.0;
		while(System:getTime() < giveUpTime)
		{
			httpServer.update();
			Thread:sleep(1);

			HTTPResponse res = httpConn.getNextResponse();
			if(res != null)
			{
				test(res.rawResponse != null);
				test(res.rawResponse.length() >= 100);
				test(res.rawResponse.contains(String<u8>("Hello!")) == true);

				gotResp = true;

				break;
			}
		}

		test(httpServer.getSocket() != null);
		test(httpServer.getSocket().getState() == SocketState:CONNECTED);
		test(httpConn.socket != null);
		test(httpConn.socket.getState() != SocketState:CONNECTING);
		//test(gotResp == true); // TODO fix

		httpConn.disconnect();

		httpServer.stop();
	}
}

class HTTPSServerTests implements IUnitTest
{
	void run()
	{
		for(u64 x=0; x<10; x++)
			oneRun();
	}

	void oneRun()
	{
		// Server webpage up via HTTP using TLS/SSL encrypted sockets.

		String<u8> prontoRootCertPEM(); // Pronto generated self-signed root ("Certificate Authority") certificate
		prontoRootCertPEM = "-----BEGIN CERTIFICATE-----\n";
		prontoRootCertPEM += "MIIDvDCCAqSgAwIBAgIRANHIhWlPPHPQ6AWBV3C254owDQYJKoZIhvcNAQELBQAwdTEPMA0GA1UEBhMG\n";
		prontoRootCertPEM += "Q2FuYWRhMRAwDgYDVQQIEwdPbnRhcmlvMRAwDgYDVQQHEwdUb3JvbnRvMRgwFgYDVQQKEw9Qcm9udG93\n";
		prontoRootCertPEM += "YXJlIEluYy4xCzAJBgNVBAsTAkNBMRcwFQYDVQQDEw5wcm9udG93YXJlLmNvbTAeFw0yMDAxMDEwMTAx\n";
		prontoRootCertPEM += "MDFaFw0zMDAxMDEwMTAxMDFaMHUxDzANBgNVBAYTBkNhbmFkYTEQMA4GA1UECBMHT250YXJpbzEQMA4G\n";
		prontoRootCertPEM += "A1UEBxMHVG9yb250bzEYMBYGA1UEChMPUHJvbnRvd2FyZSBJbmMuMQswCQYDVQQLEwJDQTEXMBUGA1UE\n";
		prontoRootCertPEM += "AxMOcHJvbnRvd2FyZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCmZWdRI112GxXF\n";
		prontoRootCertPEM += "h6wHsXIn5YqPw/jtLfuWBJxMG8df4FIqwmHDo7+Fw1tPhpMZlH4LIjhQ6GYjJvpNPuGmb9XyI8tzHjhT\n";
		prontoRootCertPEM += "dprktQ+FNjsxbHXKotiq6c5GHqtQx0eLWoQH2epll92suwS+1DA9tc7KIvW0x1uSQ3czeiQq6pbqUqK7\n";
		prontoRootCertPEM += "uTjP0ySF7du30wJnrGg76pwa8dLRbFWQt/1FZXhNCI4qB6lJejZ+gUePiJDNHolmeooPMntWGNWqks+p\n";
		prontoRootCertPEM += "muc/voE9bIyz+4OL44GL+hf5jUeAMiIrwJzuUDnmJSbryZrQ4InOJwhEb65GJlrNMbAZ+Hq+fEy99EfO\n";
		prontoRootCertPEM += "+R21HowRAgMBAAGjRzBFMBcGA1UdDgQQUFJPTlRPQ0EwAAAAAAAAATAJBgNVHREEAjAAMA8GA1UdEwEB\n";
		prontoRootCertPEM += "/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMA0GCSqGSIb3DQEBCwUAA4IBAQB8EYyLjcS6mrhdbeTr0DRD\n";
		prontoRootCertPEM += "Vkj6NKkhqIyuz3vuKPMsfLqTIJELCIc95oEQnTGfe1LBHx6XsFLZbbWmVLsKRXKyRlFLZ3QWHRbIg8Ns\n";
		prontoRootCertPEM += "BQSYegbyTMumBQ6BW6j9BhYpmHrVbrPFVKLUHQzoOa+wiXYN039Q6shU4DLvBjzvRhZUzxhOwgycbpcW\n";
		prontoRootCertPEM += "txuWo9NFEkZ6E0tiX2C43er7ubRjZ3fWYWGR/bzf4H9a3Y4Z0G2eDtOb9gn3ejC0dD60/uWk0JUd8E54\n";
		prontoRootCertPEM += "ne1wj+pbqKCFsTd5wr7CHm6y36NJ8O7lccOXjco/iaZvdBTXnOgIR1MFel/ncBuLtrnU+C7InGT3Pf9Z\n";
		prontoRootCertPEM += "-----END CERTIFICATE-----";

		// We add this to the global trust store (temporary for unit tests thread existance ONLY). Then the client can properly validate the cert below.
		test(TLS:getTrustStore().addRootCert(prontoRootCertPEM) == true);

		String<u8> endEntityPEM(); // Pronto generated QA certificate, signed by the above root certificate
		endEntityPEM = "-----BEGIN CERTIFICATE-----\n";
		endEntityPEM += "MIID2DCCAsCgAwIBAgIQM6XpA/tk+wWAEFGZD6RPfDANBgkqhkiG9w0BAQsFADB1MQ8wDQYDVQQGEwZD\n";
		endEntityPEM += "YW5hZGExEDAOBgNVBAgTB09udGFyaW8xEDAOBgNVBAcTB1Rvcm9udG8xGDAWBgNVBAoTD1Byb250b3dh\n";
		endEntityPEM += "cmUgSW5jLjELMAkGA1UECxMCQ0ExFzAVBgNVBAMTDnByb250b3dhcmUuY29tMB4XDTIwMDEwMTAxMDEw\n";
		endEntityPEM += "MVoXDTMwMDEwMTAxMDEwMVowdTEPMA0GA1UEBhMGQ2FuYWRhMRAwDgYDVQQIEwdPbnRhcmlvMRAwDgYD\n";
		endEntityPEM += "VQQHEwdUb3JvbnRvMRgwFgYDVQQKEw9Qcm9udG93YXJlIEluYy4xCzAJBgNVBAsTAlFBMRcwFQYDVQQD\n";
		endEntityPEM += "Ew5wcm9udG93YXJlLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJVOBB07N3s56oji\n";
		endEntityPEM += "rhMkf+70TqW4CaD3tlbVp0MwtszUG0MzvIIizDrOUtqS8kbaYgYNr3BCOXdXVpf9Az2ge6XZ9fgTynqN\n";
		endEntityPEM += "JsQmkyIcLcIBVhx7wkes4/Kk4T7LOzROul+XKfd4ghid5rvaREGTcLLlQ9P7NpTDa9LJbEJDHNOzNVtg\n";
		endEntityPEM += "qFwQxY5hcN6pO1LNB0FlppPZbxSgIy7XqLpgatBRexbWQjZyort3QKmP6qnVbzJursSwlZoeGvhJpk0p\n";
		endEntityPEM += "TSeryYWNJrMqZNBgjC62EftYfAx795E17nO8BLkv2kuBXqAGlUIDcpQeERxMb3RZFaonkvcBQ/NLAJBg\n";
		endEntityPEM += "vhcsX9kCAwEAAaNkMGIwGwYDVR0jBBQwEgUQUFJPTlRPQ0EwAAAAAAAAATAXBgNVHQ4EEFBST05UT1FB\n";
		endEntityPEM += "MAAAAAAAAAEwCQYDVR0RBAIwADAPBgNVHRMBAQAEBTADAQEAMA4GA1UdDwEBAAQEAwIFoDANBgkqhkiG\n";
		endEntityPEM += "9w0BAQsFAAOCAQEAlmlI1u09u6SQtRvEfKLBgKz6uBbCcr8l2XxmY2bbwRjV7wHRi/CbHyZVOdY7kRKW\n";
		endEntityPEM += "m44XkL2Lp1FgpLNihRdWMnXNeuLeShXh0deeB9Dt+jUJi+59L0qcsd5oowwVcW/MErO39HC14YCWUCwy\n";
		endEntityPEM += "Dg7nneKlHgDd9ntTGxkgcuOx60ssJbaF4E934Xs7C2qDTkGImqzicHgv5PbS8YkVD6PlfLwDFKLjmAxn\n";
		endEntityPEM += "60R0ABmkpEykZcYPGTCO+7lVLfT9ChX/OW9ANkZJMw2DZFhuGEDW9rXa46HemKy5/5UEKD8o/2PQ5pOo\n";
		endEntityPEM += "G4SKcAryvzpKEyTzDf+YKnYMU619/eaJ3l5Jiw==\n";
		endEntityPEM += "-----END CERTIFICATE-----";

		String<u8> privateKeyPEM(); // Pronto generated QA certificate private key, matches above.
		privateKeyPEM = "-----BEGIN RSA PRIVATE KEY-----\n";
		privateKeyPEM += "MIIEowIBAAKCAQEAlU4EHTs3eznqiOKuEyR/7vROpbgJoPe2VtWnQzC2zNQbQzO8giLMOs5S2pLyRtpi\n";
		privateKeyPEM += "Bg2vcEI5d1dWl/0DPaB7pdn1+BPKeo0mxCaTIhwtwgFWHHvCR6zj8qThPss7NE66X5cp93iCGJ3mu9pE\n";
		privateKeyPEM += "QZNwsuVD0/s2lMNr0slsQkMc07M1W2CoXBDFjmFw3qk7Us0HQWWmk9lvFKAjLteoumBq0FF7FtZCNnKi\n";
		privateKeyPEM += "u3dAqY/qqdVvMm6uxLCVmh4a+EmmTSlNJ6vJhY0msypk0GCMLrYR+1h8DHv3kTXuc7wEuS/aS4FeoAaV\n";
		privateKeyPEM += "QgNylB4RHExvdFkVqieS9wFD80sAkGC+Fyxf2QIDAQABAoIBABtizQRjmUCkFe33zkA6oLC+5TImeLWq\n";
		privateKeyPEM += "2ipBVEXRyKX3feysr7YbFeTvdWkcLQ5r/jDoD7cCnrHSNlL4mMCUEDoSqbhQQQKLo4G1JaXLD2WXgykE\n";
		privateKeyPEM += "VlV5U/Js5dfzxS9KBYuFGbCHzS0gwXLRjVWN6s0VmoRmftN4qO1n/tCEqOP3omXcf+t9qBmqJAW9dX28\n";
		privateKeyPEM += "v6pIrMr51naQie0ZBj1lOqkKk48C+xBuqHGRqOQFLQkTVS3q24fAfs3POnv0xZtIJ4+nLqovAfk0bB6q\n";
		privateKeyPEM += "SRyFcXG1sjeT4s2p9jGAokrZ1dtuutS8GMfKeRsluVX9NgL4YnqSo4b9LjLSK9+4cMkEffUCgYEAxqrd\n";
		privateKeyPEM += "lZLQ8PnOJNqZ0jJiiofPQGFCDKVF8LECyeK3IIHk2MZzT3hMdTa3IC7IJVW5rM5Z+flj9D+udcRZXPsC\n";
		privateKeyPEM += "NCWCLGBIYDlZpaqWUiH+Xg4hZQxFmg7AMd2mDEL3jyhXQYWzFTGEQL0TZLou3VXosiB+20e7ycZ4lL8R\n";
		privateKeyPEM += "gkJkdwsCgYEAwGRWkbtv7PUgaUzs0ieWbwfoPQS6PKA6DQ+Pwe9KOTMpDIFFUuK931CHxIevMagB0LfG\n";
		privateKeyPEM += "DOILAVl0r6022X5/CFEBjJc7GoFuVKTlxG+E/2WI9Bc7MP03Jous/D3+3T50HKVOSwSxhPzo4zSYG7rv\n";
		privateKeyPEM += "c+/FbCfKw+xfR6NNpaQ9wysCgYB1ieXrdp9z0vfpygOz3ud6OnueBWzEeov0qWWS+DWMYA17S34xiGUD\n";
		privateKeyPEM += "/ElAGy2DGULvQG7vfGNswLiBKJgOcNuO6ponkxd/Bq9JWrHxCfeqwgVz+Vy8lvmTByYUnxJEeoOVWnrn\n";
		privateKeyPEM += "kRJEExmEQLs1bHxt1tf2+GvcJzZ0Gs9LF+jEnQKBgG6dQeioC8IBbZEdWUu61xMfSLdMcIdK2BWKTO0D\n";
		privateKeyPEM += "13jroT4/VMxC8Ufj1St5l5DFN8X44zWlAQ7Vj/Exdce2ovL1IB7lFGY45GZmKHS4aY8toYA1myKfc4YF\n";
		privateKeyPEM += "6H9eZZpuvfN6V3lqSWZcwslfA9VttR7DTI7SkhHzZRSbH5mMxLXhAoGBAJe81hBou+ylm9uWRqlZ7lDl\n";
		privateKeyPEM += "/Ya4+jNgrkEKQbIqhywpcmfxFl8hdCUlJkoT4rv5x8lWKayZLkEmwqY8GvdoIWRP4GMJE0ydexYQTV8w\n";
		privateKeyPEM += "fTUkHDWxfDjPWp1g0D6gav3T4OYbigIu/HlfiBAQTb+7tJPE+Qoj5PEO4emUcBQlVgI4\n";
		privateKeyPEM += "-----END RSA PRIVATE KEY-----";

		X509Certificate rootCert();
		rootCert.readCertificate(prontoRootCertPEM);
		//Log:log("HTTPSServerTests rootCert\n" + rootCert.toString() + "\n");

		X509Certificate endCert();
		endCert.readCertificate(endEntityPEM);
		//Log:log("HTTPSServerTests endEntityCert\n" + endCert.toString() + "\n");

		HTTPServer httpServer();

		// TCP sockets that are bound don't become available again immediately after unbind() call on windows etc., but 
		// we run unit tests twice quickly (i.e. byte code and x86), hence random port needed.
		RandomFast rand = RandomFast(System:getTime());

		for(u64 t=0; t<3; t++)
		{
			i32 randPort = 3026 + rand.getI32(1, 60000);

			HTTPServerTestHandler serverHandler();
			httpServer.startHTTPS(serverHandler, null, randPort, String<u8>("prontoware.com"), endEntityPEM, privateKeyPEM);

			f64 giveUpTime = System:getTime() + 1000.0;
			while(httpServer.getSocket().getState() != SocketState:CONNECTED && System:getTime() < giveUpTime)
			{
				// wait...
			}
			
			if(httpServer.getSocket().getState() != SocketState:CONNECTED)
			{
				// This happens very occassionally
				Log:log("HTTPServer could not get connection on random port: " + String<u8>:formatNumber(randPort) + "! Trying another...\n");
				httpServer = HTTPServer();
			}
			else
			{
				break; // got good port
			}
		}

		test(httpServer.getSocket().getState() == SocketState:CONNECTED);

		TCPSocket clientTCP();
		clientTCP.connect(httpServer.getServerIP());
		TLSClient clientTLS(clientTCP);
		ISocket clientSocket = clientTLS;

		HTTPConnection httpConn(clientSocket);
		HTTPRequest    httpReq(String<u8>("GET"), httpServer.getServerIP().toString(), String<u8>("/index.html"));

		test(httpConn.request(httpReq) == true);

		String<u8> infoLog();

		TLSServer serverClientSocket = null;

		u8 lastClientTLSState = 0;
		u8 lastServerTLSState = 0;
		bool gotResp = false;
		giveUpTime = System:getTime() + 5000.0;
		while(System:getTime() < giveUpTime)
		{
			httpServer.update();
			clientSocket.update();

			u8 tlsState = clientTLS.getTLSState();
			if(lastClientTLSState != tlsState)
			{
				lastClientTLSState = tlsState;
				infoLog += "HTTPSServerTests client TLS state = " + clientTLS.getTLSStateName() + "\n";
			}

			HTTPClient serverConn = null;
			if(httpServer.connections.size() > 0)
				serverConn = httpServer.connections[0];

			if(serverConn != null)
			{
				serverClientSocket = serverConn.socket;
				u8 tlsState = serverClientSocket.getTLSState();
				if(lastServerTLSState != tlsState)
				{
					lastServerTLSState = tlsState;
					infoLog += "HTTPSServerTests server TLS state = " + serverClientSocket.getTLSStateName() + "\n";
				}
			}

			HTTPResponse res = httpConn.getNextResponse();
			if(res != null)
			{
				test(res.rawResponse != null);
				test(res.rawResponse.length() >= 100);
				test(res.rawResponse.contains(String<u8>("Hello!")) == true);

				gotResp = true;

				break;
			}
		}

		test(serverClientSocket != null);
		//if(serverClientSocket != null)
		//{
			//Log:log("\nHTTPSServerTests serverClientSocket.statsTotalRecv: " + serverClientSocket.statsTotalRecv + "\n");
		//}

		//Log:log("\nHTTPSServerTests httpServer.statsNumConnections: " + httpServer.statsNumConnections + "\n");

		test(httpServer.getSocket() != null);
		test(httpServer.getSocket().getState() == SocketState:CONNECTED);

		test(httpConn.socket != null);
		test(httpConn.socket.getState() != SocketState:CONNECTING);

		test(httpServer.statsNumConnections == 1);

		httpConn.disconnect();

		httpServer.stop();

		test(gotResp == true);
		if(gotResp == false)
		{
			Log:log("\nHTTPSServerTests failure, info: \n" + infoLog + "\n\n");
		}
	}
}