////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class TLSClientConnectTests implements IUnitTest
{
	void run()
    {
        IPAddress ipAddr = Network:resolveDomainToIP("https://www.google.com"); // 
		//IPAddress ipAddr("127.0.0.1:14337"); // https://localhost:4433/

        //Log:log("\nTLSClientConnectTests ip = " + ipAddr.toString() + "\n");

		TCPSocket tcpSocket = TCPSocket();
		tcpSocket.connect(ipAddr);

		TLSClient tlsClient(tcpSocket); // wraps tcpSocket

        f64 maxTime = System:getTime() + 5000.0;
        while(System:getTime() < maxTime) // && tlsClient.getTLSState() != TLSClient:STATE_APP_DATA)
        {
            tlsClient.update();
        }

        //Log:log("\nTLSClientConnectTests tlsClient.state = " + tlsClient.getTLSStateName() + "\n");

        // successful handshake?
        test(tlsClient.getTLSState() == TLSClient:STATE_APP_DATA);

        if(tlsClient.getTLSState() == TLSClient:STATE_APP_DATA)
        {
            // send basic HTTPS request, get response etc.
            String<u8> reqStr("GET / HTTP/1.1\r\nHost: www.google.com\r\n\r\n");
            tlsClient.send(reqStr.chars, reqStr.numChars); // minimal GET request
        }

        u8[] resp(8192);
        resp[0] = 0;

        maxTime = System:getTime() + 5000.0;
        u64 respNumBytes = 0;
        while(System:getTime() < maxTime && respNumBytes == 0)
        {
            //tlsClient.update(); // receive calls update implicitly
            respNumBytes = tlsClient.receive(resp);
        }

        test(respNumBytes > 100);
        String<u8> respStr(resp, respNumBytes);
        test(respStr.contains("HTTP/1.1 200 OK") == true);

        //Log:log("\nTLSClientConnectTests HTTP response = " + String<u8>(resp, respNumBytes) + "\n");

        tlsClient.disconnect();
    }
}

class TLSServerTests implements IUnitTest
{
	void run()
	{
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

        RSAKey privateKey = RSAKey:readPKCS1(privateKeyPEM);
        X509Certificate serverCert();
        serverCert.readCertificate(endEntityPEM);
		//ArrayList<ByteArray> certFiles = X509Certificate:decodePEMCertificates(endEntityPEM); // we only include one file, but we could include the Root cert above too (optional)
        ArrayList<ByteArray> certFiles = X509Certificate:decodePEMCertificates(endEntityPEM + "\n" + prontoRootCertPEM); // include root too test
		test(certFiles.size() == 2);

		X509Certificate rootCert();
        rootCert.readCertificate(prontoRootCertPEM);
		//Log:log("TLSServerTests root cert:\n" + rootCert.toString());

		// TCP sockets that are bound don't become available again immediately (on Windows OS). This is a problem because we
		// run the unit tests twice quickly (i.e. byte code and x86), hence random port.
		
		RandomFast rand = RandomFast(System:getTime());
		IPAddress localIP = IPAddress(127, 0, 0, 1, 3026 + rand.getI32(1, 60000)); 

		TCPSocket serverListenSocket = TCPSocket();
		serverListenSocket.listen(localIP);
		test(serverListenSocket.socketHandle != 0);

		f64 giveUpTime = System:getTime() + 5000.0;
		while(System:getTime() < giveUpTime && serverListenSocket.getState() != SocketState:CONNECTED) { }
		test(serverListenSocket.getState() == SocketState:CONNECTED);

		TCPSocket clientTCP = TCPSocket();
		clientTCP.connect(localIP);
        test(clientTCP.socketHandle != 0);
        TLSClient clientTLSSocket(clientTCP);

		giveUpTime = System:getTime() + 5000.0;
		while(System:getTime() < giveUpTime && clientTLSSocket.getState() != SocketState:CONNECTED) { }
		test(clientTLSSocket.getState() != SocketState:CONNECT_FAILED);
		test(clientTLSSocket.getState() == SocketState:CONNECTED);

        TLSServer serverTLSSocket = null;
		giveUpTime = System:getTime() + 8000.0;
		while(System:getTime() < giveUpTime)
		{
			TCPSocket serverClientSocket = serverListenSocket.accept();
			if(serverClientSocket != null)
			{
				serverTLSSocket = TLSServer(serverClientSocket, null, privateKey, serverCert, certFiles);
				break;
			}
		}
		test(serverTLSSocket != null);

		// wait for handshake etc.
		giveUpTime = System:getTime() + 5000.0;
		while(System:getTime() < giveUpTime && serverTLSSocket.getTLSState() != TLSServer:STATE_APP_DATA)
		{
			clientTLSSocket.update();
			serverTLSSocket.update();
		}
		test(serverTLSSocket.getTLSState() == TLSServer:STATE_APP_DATA);
		
		if(serverTLSSocket.getTLSState() == TLSServer:STATE_APP_DATA)
		{
			// send some data from server to client
			u8[] sendBuffer = u8[](256);
			sendBuffer[0] = Chars:h;
			sendBuffer[1] = Chars:i;

			test(serverTLSSocket.send(sendBuffer, 2) == true);

			u8[] recvBuffer = u8[](256);
			for(u64 r=0; r<256; r++)
				recvBuffer[r] = 0;

			giveUpTime = System:getTime() + 3000.0;
			u32 numRecv = 0;
			while(System:getTime() < giveUpTime && numRecv == 0)
			{
				numRecv = clientTLSSocket.receive(recvBuffer);
			}

			test(numRecv == 2);
			test(recvBuffer[0] == Chars:h && recvBuffer[1] == Chars:i);
			test(recvBuffer[2] == 0);
		}

		clientTLSSocket.disconnect();
		serverTLSSocket.disconnect();
		serverListenSocket.disconnect();
	}
}