////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Email
////////////////////////////////////////////////////////////////////////////////////////////////////

// Represents a simple email. Designed for plain text, but nothing says you can't put HTML in the body.
class Email
{
	String<u8> toEmailAddress();
	String<u8> fromEmailAddress();
	String<u8> title();
	String<u8> body();
	String<u8> attachmentFilename();
	String<u8> base64Attachment();

	// Blank email.
	void constructor() { }

	// Basic email, no attachment.
	void constructor(String<u8> fromEmailAddress, String<u8> toEmailAddress, String<u8> title, String<u8> body)
	{
		this.fromEmailAddress.copy(fromEmailAddress);
		this.toEmailAddress.copy(toEmailAddress);
		this.title.copy(title);
		this.body.copy(body);
		this.attachmentFilename.copy("");
		this.base64Attachment.copy("");
	}

	// Copy constructor
	void constructor(Email e)
	{
		copy(e);
	}

	// Copy
	void copy(Email e)
	{
		this.fromEmailAddress.copy(e.fromEmailAddress);
		this.toEmailAddress.copy(e.toEmailAddress);
		this.title.copy(e.title);
		this.body.copy(e.body);
		this.attachmentFilename.copy(e.attachmentFilename);
		this.base64Attachment.copy(e.base64Attachment);
	}

	// Clear fields to empty.
	void reset()
	{
		this.toEmailAddress.copy("");
		this.fromEmailAddress.copy("");
		this.title.copy("");
		this.body.copy("");
		this.attachmentFilename.copy("");
		this.base64Attachment.copy("");
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// SMTPConnection
////////////////////////////////////////////////////////////////////////////////////////////////////

// Send email messages to server using Simple Mail Transfer Protocol (SMTP) with optional
// authentication and TLS usage.
class SMTPConnection
{
	const u32 STATE_DISCONNECTED      = 0;
	const u32 STATE_CONNECTING        = 1;
	const u32 STATE_SENT_HELO_WAIT    = 2; // sent HELO/EHLO, waiting for response
	const u32 STATE_SENT_AUTH_WAIT    = 3; // sent AUTH, waiting for response
	const u32 STATE_SENT_AUTH2_WAIT   = 4; // sent username/password, waiting for response
	const u32 STATE_CONNECTED         = 5; // ready to send mail to server

	const u32 SEND_STATE_NULL            = 0; // not sending
	const u32 SEND_STATE_WAIT_MAIL_FROM  = 1;
	const u32 SEND_STATE_WAIT_RECV_TO    = 2;
	const u32 SEND_STATE_WAIT_DATA       = 3;
	const u32 SEND_STATE_WAIT_ATTACHMENT = 4; // optional step
	const u32 SEND_STATE_WAIT_END        = 5;

	const u32 WAIT_RESP_TIME = 10000; // wait for response from server after we sent command

	ISocket     socket = null; // multi-threaded so I/O is async
	IPAddress   ip();           // to SMTP server
	String<u8>  domain();       // i.e. proceduraltech.com
	String<u8>  username();     // for security auth
	String<u8>  password();     // for security auth
	bool        useTLS = false; // use TLS

	// State
	u32  state         = STATE_DISCONNECTED; // state of SMTP 
	bool gotResponse   = false; // got response from server for current operation?
	f64  waitUntilTime = 0;     // wait until this time (for response lines from server) before proceeding with next command
	u32  curRecvLine   = 0;     // index into recvLines (if == recvLines.size() no new lines)
	ArrayList<String<u8>> recvLines(); // we removed /r/n from each line end
	String<u8>            recvBuf();  // text based protocol

	// Email state - sending an email. We have to do this because it can take the server forever to respond to us
	ArrayList<Email> sendQueue();
	Email curEmail   = null;
	u32   emailState = SEND_STATE_NULL;

	String<u8> lastErrorMsg = null; // if there was an error connecting, logging in, etc.
	
	// Unconnected.
	void constructor()
	{
		this.socket        = null;
		this.username      = String<u8>("");
		this.password      = String<u8>("");
		this.domain        = String<u8>("");
		this.state         = STATE_DISCONNECTED;
		this.curRecvLine   = 0;
		this.emailState    = SEND_STATE_NULL;
	}

	// Auto disconnects.
	void destroy()
	{
		disconnect(); // if we haven't already
	}

	// Returns null if no error, otherwise human readable error message.
	String<u8> getLastError()
	{
		return lastErrorMsg;
	}

	// Connect to a SMTP server.
	// Examples for parameters:
	// ip="smtp.gmail.com:587"
	// domain="gmail.com"
	// username="dave123"
	// password="password"
	// Gmail TLS port is 587 (smtp.gmail.com:587 for TLS via STARTTLS, or 465 for SSL, or 25 for SSL). 
	bool connect(IPAddress ip, String<u8> domain, String<u8> username, String<u8> password)
	{
		disconnect(); // in case of existing connection

		this.recvLines.clear();
		this.recvBuf.clear();

		this.ip            = ip;
		this.domain        = domain;
		this.username      = username;
		this.password      = password;
		this.curRecvLine   = 0;
		this.emailState    = SEND_STATE_NULL;
		this.useTLS        = false;
		reconnect();

		return true;
	}

	// Connect to a SMTPS server. Assumes TLS handshake occurs at connection, rather than after STARTTLS command.
	// Examples for parameters:
	// ip="smtp.gmail.com:587"
	// domain="gmail.com"
	// username="dave123"
	// password="password"
	// Gmail TLS port is 587 (smtp.gmail.com:587 for TLS, or smtp.gmail.com:465 for SSL, or aspmx.l.google.com:25 for SMTP plain text). 
	bool connectTLS(IPAddress ip, String<u8> domain, String<u8> username, String<u8> password)
	{
		disconnect(); // in case of existing connection

		this.recvLines.clear();
		this.recvBuf.clear();

		this.ip            = ip;
		this.username      = username;
		this.password      = password;
		this.domain        = domain;
		this.curRecvLine   = 0;
		this.emailState    = SEND_STATE_NULL;
		this.useTLS        = true;
		reconnect();

		return true;
	}

	// Attempt reconnection.
	void reconnect()
	{
		disconnect(); // in case of existing connection

		TCPSocket tcpSocket();
		tcpSocket.connect(ip);

		if(this.useTLS == true)
			this.socket = TLSClient(tcpSocket);
		else
			this.socket = tcpSocket;

		this.state  = STATE_CONNECTING;
	}

	// Returns one of STATE_DISCONNECTED, STATE_CONNECTING etc.
	u8 getState()
	{
		return this.state;
	}

	// If the send queue is empty and we finished sending last message this returns true.
	bool isIdle()
	{
		if(this.state == STATE_CONNECTED && this.sendQueue.size() == 0 && this.emailState == SEND_STATE_NULL)
			return true;

		return false;
	}

	// Send a simple email - many SMTP servers cap the body string length at 200 KB or less
	bool sendEmail(Email email)
	{
		if(socket == null)
			return false;

		sendQueue.add(email);

		return true;
	}

	// Disconnect from server.
	void disconnect()
	{
		if(socket != null)
		{
			sendLine(String<u8>("QUIT"));

			socket.disconnect();
			socket = null;

			state = STATE_DISCONNECTED;
		}
	}

	// Are we connected and ready to send email?
	bool isReadyToSendEmail()
	{
		if(state == STATE_CONNECTED)
			return true;

		return false;
	}

	// Tries to send waiting emails etc. Call reqularly.
	void update()
	{
		if(socket == null)
			return;

		if(socket.getState() == SocketState:CONNECTING)
			return; // wait...

		if(state == STATE_CONNECTED && socket.getState() != SocketState:CONNECTED)
		{
			if(lastErrorMsg == null)
				lastErrorMsg = String<u8>("Mail server disconnected us while we were trying to send mail.");

			state = STATE_DISCONNECTED;

			return;
		}

		if(waitUntilTime != 0)
		{
			if(waitUntilTime > System:getTime())
			{
				// waiting...
				updateRecv();
				if(gotResponse == true)
				{
					f64 remainingTime = waitUntilTime - System:getTime();
					if(remainingTime > 1000)
						waitUntilTime = System:getTime() + 900; // once server starts responding we don't want to wait forever
				}

				return;
			}
			else
			{
				waitUntilTime = 0;
			}
		}

		if(socket.getState() == SocketState:CONNECTED)
		{
			if(state == STATE_CONNECTING)
			{
				sendHello();
			}
			else if(state == STATE_SENT_HELO_WAIT)
			{
				if(this.username.length() > 0)
				{
					sendAuthPlain();

					return;
				}
				else
				{
					state = STATE_CONNECTED;
				}
			}
			else if(state == STATE_SENT_AUTH_WAIT)
			{
				sendPlainUserPassBase64();
			}
			else if(state == STATE_SENT_AUTH2_WAIT)
			{
				state = STATE_CONNECTED;
				recvBuf.clear();
			}
			else if(state == STATE_CONNECTED)
			{
				updateSendingEmail();
			}
		}
		else
		{
			if(state != STATE_CONNECTING && state != STATE_SENT_HELO_WAIT)
				state = STATE_DISCONNECTED;
		}
	}

	// Called by update() to send next email in queue.
	void updateSendingEmail()
	{
		/* Example
		MAIL FROM:<rui.jm.silva@company.com>
		250 2.1.0 rui.jm.silva@company.com....Sender OK
		RCPT TO:<someone@company.com>
		250 2.1.5 someone@company.com
		DATA
		354 Start mail input; end with .
		SUBJECT: SMTP Test
		Just a test message, please ignore.
		.
		250 2.6.0 Queued mail for delivery
		QUIT*/

		if(socket == null)
			return;

		if(socket.getState() != SocketState:CONNECTED)
		{
			if(lastErrorMsg == null)
				lastErrorMsg = String<u8>("Mail server disconnected us while we were trying to send mail.");

			return;
		}

		if(waitUntilTime != 0)
		{
			if(waitUntilTime > System:getTime())
			{
				// waiting...
				updateRecv();
				if(gotResponse == true)
				{
					f64 remainingTime = waitUntilTime - System:getTime();
					if(remainingTime > 1000)
						waitUntilTime = System:getTime() + 900; // once server starts responding we don't want to wait forever
				}

				return;
			}
			else
			{
				waitUntilTime = 0;
				if(gotResponse == false)
				{
					disconnect(); // server never responded in timely manner
					lastErrorMsg = String<u8>("Mail server timed out. No response provided in timely manner.");
					return;
				}
			}
		}

		if(emailState == SEND_STATE_NULL)
		{
			if(sendQueue.size() == 0)
			{
				return;
			}
			else
			{
				curEmail = sendQueue.remove(0);
				//Log:log("SMTPConnection.update() Removing next email from queue with subject: " + curEmail.title + " to SMTP server at IP: " + ip.toString());
			}
		}

		if(emailState == SEND_STATE_NULL)
		{
			sendLine("MAIL FROM:<" + curEmail.fromEmailAddress + ">");

			// wait for server response
			emailState    = SEND_STATE_WAIT_MAIL_FROM;
			gotResponse   = false;
			waitUntilTime = System:getTime() + WAIT_RESP_TIME;

			return;
		}

		if(emailState == SEND_STATE_WAIT_MAIL_FROM && gotResponse == true)
		{
			sendLine("RCPT TO:<" + curEmail.toEmailAddress + ">");

			// wait for server response
			emailState    = SEND_STATE_WAIT_RECV_TO;
			gotResponse   = false;
			waitUntilTime = System:getTime() + WAIT_RESP_TIME;

			return;
		}

		if(emailState == SEND_STATE_WAIT_RECV_TO && gotResponse == true)
		{
			sendLine("DATA");

			// wait for server response
			emailState    = SEND_STATE_WAIT_DATA;
			gotResponse   = false;
			waitUntilTime = System:getTime() + WAIT_RESP_TIME;

			return;
		}

		if(emailState == SEND_STATE_WAIT_DATA && gotResponse == true)
		{
			if(curEmail.base64Attachment.length() == 0)
			{
				sendLine("SUBJECT: " + curEmail.title + "\r\n" + curEmail.body);

				// end msg
				sendLine("\r\n.\r\n", false);
			}
			else
			{
				/* Example
				From: John Doe <example@example.com>
				MIME-Version: 1.0
				Content-Type: multipart/mixed;
				boundary="XXXXboundary text"

				This is a multipart message in MIME format.

				--XXXXboundary text
				Content-Type: text/plain

				this is the body text

				--XXXXboundary text
				Content-Type: text/plain;
				Content-Disposition: attachment;
				filename="test.txt"

				this is the attachment text

				--XXXXboundary text--
				*/

				String<u8> s(1024);
				s += "SUBJECT: " + curEmail.title + "\r\n";
				s += "MIME-Version: 1.0;\r\n";
				s += "Content-Type: multipart/mixed;\r\n";
				s += "boundary=\"XXX_XXX_XXX\";\r\n";
				s += "\r\nThis is MIME email, you should not see this.\r\n\r\n";

				// body
				s += "--XXX_XXX_XXX\r\n";
				s += "Content-Type: text/plain;\r\n";
				s += "\r\n";
				s += curEmail.body;
				s += "\r\n";
				s += "\r\n";

				// attachment
				s += "--XXX_XXX_XXX\r\n";
				s += "Content-Type: text/plain;\r\n";
				s += "Content-Disposition: attachment;\r\n";
				s += "filename=\"" + curEmail.attachmentFilename + "\"\r\n";
				s += "\r\n";
				s += curEmail.base64Attachment;
				s += "\r\n";

				// end
				s += "--XXX_XXX_XXX--\r\n";

				sendLine(s);

				// end msg
				sendLine("\r\n.\r\n", false);
			}

			// wait for server response
			emailState    = SEND_STATE_WAIT_END;
			gotResponse   = false;
			waitUntilTime = System:getTime() + WAIT_RESP_TIME;

			return;
		}

		if(emailState == SEND_STATE_WAIT_END)
		{
			curEmail.reset();
			emailState = SEND_STATE_NULL; // next email
		}
	}

	// Send hello msg.
	void sendHello()
	{
		sendLine("EHLO " + domain); // EHLO is extened version, but for example, smtp.gmail.com requires HELO to be sent first.

		state         = STATE_SENT_HELO_WAIT;
		gotResponse   = false;
		waitUntilTime = System:getTime() + WAIT_RESP_TIME;
	}

	// Send AUTH PLAIN msg.
	void sendAuthPlain()
	{
		sendLine("AUTH PLAIN");

		state         = STATE_SENT_AUTH_WAIT;
		gotResponse   = false;
		waitUntilTime = System:getTime() + WAIT_RESP_TIME;
	}

	// Send username and password encoded in plain mode msg.
	void sendPlainUserPassBase64()
	{
		// AUTH PLAIN userID\0username\0userpass where userID == username normally.
		String<u8> userAndPass(username);
		userAndPass.append(Chars:NULL_CHAR);
		userAndPass.append(username);
		userAndPass.append(Chars:NULL_CHAR);
		userAndPass.append(password);

		String<u8> userAndPassBase64 = FileSystem:encodeBytesToBase64(ByteArray(userAndPass));

		sendLine(userAndPassBase64);

		state         = STATE_SENT_AUTH2_WAIT;
		gotResponse   = false;
		waitUntilTime = System:getTime() + WAIT_RESP_TIME;
	}

	// SMTP is text line based protocol, hence.
	void sendLine(String<u8> line)
	{
		sendLine(line, true);
	}

	// SMTP is text line based protocol, hence.
	void sendLine(String<u8> line, bool addNewLineChars)
	{
		if(addNewLineChars == true)
		{
			line += "\r\n";
		}

		socket.send(line.chars, line.numChars);
	}

	// Accept one or more responses from server. Does not block.
	void updateRecv()
	{
		// give our recv string lots of buffer space to recv more data
		if(recvBuf.chars == null)
			recvBuf.resize(1024);

		if((recvBuf.numChars + 8192) > recvBuf.chars.length())
		{
			recvBuf.resize(recvBuf.numChars + 8192 + 1);
		}

		// get any new recv'd bytes, append them to string recv buffer
		i32 numCharsRecv = socket.receive(recvBuf.chars, recvBuf.numChars);
		if(numCharsRecv > 0)
		{
			recvBuf.numChars += numCharsRecv;
			gotResponse = true;
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// SMTPSender
////////////////////////////////////////////////////////////////////////////////////////////////////

// Sends emails to a SMTP server. Will reconnect and try again until all messages in queue are sent.
class SMTPSender
{
	SMTPConnection   smtpConn;
	ArrayList<Email> sendQueue();
	f64 keepAliveTime = 90000; // so we don't waste all sorts of time reconnecting, in milliseconds
	f64 doNotDisconnectUntil;

	// Construct and connect to SMTP server with a single email user account.
	void constructor(IPAddress ip, String<u8> emailAddress, String<u8> username, String<u8> password)
	{
		this.smtpConn = SMTPConnection();
		this.smtpConn.connect(ip, emailAddress, username, password);
		this.doNotDisconnectUntil = System:getTime() + keepAliveTime;
	}

	// Construct and connect to SMTPS server with a single email user account.
	void constructor(IPAddress ip, String<u8> emailAddress, String<u8> username, String<u8> password)
	{
		this.smtpConn = SMTPConnection();
		this.smtpConn.connectTLS(ip, emailAddress, username, password);
		this.doNotDisconnectUntil = System:getTime() + keepAliveTime;
	}

	void destroy()
	{
		if(smtpConn != null)
			smtpConn.disconnect();

		smtpConn = null;
	}

	// Queue an email to be sent.
	void sendEmail(Email email)
	{
		sendQueue.add(email);
	}

	// Continues send attempts etc. Call regularly to pump queue.
	void update()
	{
		smtpConn.update();

		if(sendQueue.size() == 0 && System:getTime() > doNotDisconnectUntil)
		{
			if(smtpConn.isReadyToSendEmail() == true)
			{
				//Log:log("EmailSystem.update() sendQueue.size() == 0, disconnecting for now.");
				smtpConn.disconnect();
			}

			return;
		}

		if(smtpConn.getState() == SMTPConnection:STATE_DISCONNECTED)
		{
			//Log:log("EmailSystem.update() sendQueue.size() > 0, reconnecting...");
			smtpConn.reconnect();
		}

		if(smtpConn.isReadyToSendEmail() == true)
		{
			while(sendQueue.size() > 0)
			{
				this.doNotDisconnectUntil = System:getTime() + keepAliveTime;

				Email email = sendQueue.remove(0);

				if(email.attachmentFilename.length() == 0)
				{
					//Log:log("EmailSystem.update() sending simple mail with title: " + email.title);
					smtpConn.sendEmail(email);
				}
				else
				{
					//Log:log("EmailSystem.update() sending complex mail with attachment: " + email.title);
					smtpConn.sendEmail(email);
				}
			}
		}
	}
}