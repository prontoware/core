////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class SMTPTests implements IUnitTest
{
	void run()
	{
		// Gmail notes:
		// aspmx.l.google.com:25 - port 25 is blocked by many ISPs
		// smtp.gmail.com:465 - TCP connection assumed to start with SSL/TLS handshake
		// smtp.gmail.com:587 - TCP connection plain text, then use STARTTLS command

		// Fill in values for these if you want to test
		String<u8> emailIPStr(""); // i.e. "smtp.gmail.com:465" - 465 is gmail port for SSLV3/TLS, 587 is TLS via STARTTLS. 25 for plain SMTP.
		String<u8> emailDomain(""); // i.e.  "prontoware.com"
		String<u8> emailUsername(""); // i.e. "mike@prontoware.com"
		String<u8> emailPassword("");

		if(emailIPStr.length() == 0)
			return; // can't test

		IPAddress smtpServerIP(emailIPStr);

		//Log:log("SMTP IP: " + smtpServerIP.toString());

		SMTPConnection smtpConn();
		smtpConn.connectTLS(smtpServerIP, emailDomain, emailUsername, emailPassword);

		f64 waitTill = System:getTime() + 5000;
		while(smtpConn.socket.getState() == SocketState:CONNECTING && System:getTime() < waitTill)
		{
			// connecting...
		}

		// constructor(String<u8> fromEmailAddress, String<u8> toEmailAddress, String<u8> title, String<u8> body)
		Email email("mike@prontoware.com", "mike@nomcode.com", "Test from Pronto SMTP Connection", "Unit tests. SMTPTests.testSMTPSendMail()");
		test(smtpConn.sendEmail(email) == true);

		f64 timeMax = System:getTime() + 60000;
		bool everConnected = false;
		while(System:getTime() < timeMax)
		{
			if(smtpConn.socket != null)
			{
				if(smtpConn.socket.getState() == SocketState:CONNECTED)
					everConnected = true;
			}

			smtpConn.update();
			if(smtpConn.isIdle() == true)
				break; // done sending all messages
		}

		if(everConnected == false)
		{
			if(smtpConn.getLastError() != null)
				Log:log("SMTP error: " + smtpConn.getLastError());

			test(false);
		}

		if(smtpConn.isIdle() == false)
		{
			if(smtpConn.getLastError() != null)
				Log:log("SMTP error: " + smtpConn.getLastError());

			smtpConn.disconnect();
			test(false); // didn't finish sending!
		}

		if(smtpConn.getLastError() != null)
		{
			Log:log("SMTP error: " + smtpConn.getLastError());
			smtpConn.disconnect();
			test(false);
		}

		smtpConn.disconnect();
	}
}