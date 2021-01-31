////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class IPAddressV4Tests implements IUnitTest
{
	void run()
	{
		IPAddress ipAddr = IPAddress();
		test(ipAddr.ip[0] == 0 && ipAddr.ip[1] == 0 && ipAddr.ip[2] == 0 && ipAddr.ip[3] == 0);
		test(ipAddr.port <= 0);

		ipAddr.set(String<u8>("23.44.192.8"));
		test(ipAddr.ip[0] == 23 && ipAddr.ip[1] == 44 && ipAddr.ip[2] == 192 && ipAddr.ip[3] == 8);
		test(ipAddr.port <= 0);

		ipAddr.set(String<u8>("1.2.3.4:1990"));
		test(ipAddr.ip[0] == 1 && ipAddr.ip[1] == 2 && ipAddr.ip[2] == 3 && ipAddr.ip[3] == 4);
		test(ipAddr.port == 1990);
		test(ipAddr.toString().compare(String<u8>("1.2.3.4:1990")) == true);
	}
}

class NetworkTests implements IUnitTest
{
	void run()
	{
		ArrayList<IPAddress> hostIPs = Network:getHostIPs();
		test(hostIPs.size() != 0);
		IPAddress ip0 = hostIPs[0];
		test(ip0.isValid() == true);

		IPAddress googleIP = Network:resolveHostToIP(String<u8>("google.com"));
		test(googleIP != null);
		test(googleIP.isValid() == true);
	}
}

class TCPSocketTests implements IUnitTest
{
	void run()
	{
		// TCP sockets that are bound don't become available again immediately, but we run unit tests twice quickly (i.e. byte code and x86), hence random port.
		RandomFast rand = RandomFast(System:getTime());
		IPAddress localIP = IPAddress(127, 0, 0, 1, 4025 + rand.getI32(1, 60000));

		TCPSocket serverListenSocket = TCPSocket();
		serverListenSocket.listen(localIP);
		test(serverListenSocket.socketHandle != 0);

		f64 giveUpTime = System:getTime() + 3000.0;
		while(System:getTime() < giveUpTime && serverListenSocket.getState() != SocketState:CONNECTED) { }
		test(serverListenSocket.getState() == SocketState:CONNECTED);

		TCPSocket clientSocket = TCPSocket();
		clientSocket.connect(localIP);
		test(clientSocket.socketHandle != 0);

		giveUpTime = System:getTime() + 3000.0;
		while(System:getTime() < giveUpTime && clientSocket.getState() != SocketState:CONNECTED) { }
		test(clientSocket.getState() != SocketState:CONNECT_FAILED);
		test(clientSocket.getState() == SocketState:CONNECTED);

		ISocket serverClientSocket = serverListenSocket.accept();
		giveUpTime = System:getTime() + 3000.0;
		while(System:getTime() < giveUpTime && serverClientSocket == null)
		{
			serverClientSocket = serverListenSocket.accept();
		}
		test(serverClientSocket != null);

		giveUpTime = System:getTime() + 3000.0;
		while(System:getTime() < giveUpTime && serverClientSocket.getState() != SocketState:CONNECTED)
		{
			// wait... for status to say connected
		}
		test(serverClientSocket.getState() == SocketState:CONNECTED);
		test(clientSocket.getState() == SocketState:CONNECTED);
		
		// send some data from server to client
		u8[] sendBuffer = u8[](256);
		sendBuffer[0] = Chars:h;
		sendBuffer[1] = Chars:i;

		test(serverClientSocket.send(sendBuffer, 2) == true);

		u8[] recvBuffer = u8[](256);
		for(u64 r=0; r<256; r++)
			recvBuffer[r] = 0;

		giveUpTime = System:getTime() + 3000.0;
		u32 numRecv = 0;
		while(System:getTime() < giveUpTime && numRecv == 0)
		{
			numRecv = clientSocket.receive(recvBuffer);
		}

		test(serverClientSocket.getState() == SocketState:CONNECTED);
		test(clientSocket.getState() == SocketState:CONNECTED);
		test(numRecv == 2);
		test(recvBuffer[0] == Chars:h && recvBuffer[1] == Chars:i);
		test(recvBuffer[2] == 0);

		clientSocket.disconnect();
		serverClientSocket.disconnect();
		serverListenSocket.disconnect();
	}
}

class UDPSocketTests implements IUnitTest
{
	void run()
	{
		IPAddress ipA = IPAddress(127, 0, 0, 1, 15781);
		IPAddress ipB = IPAddress(127, 0, 0, 1, 15782);

		UDPSocket socketA = UDPSocket();
		socketA.listen(ipA);
		test(socketA.socketHandle != 0);

		f64 giveUpTime = System:getTime() + 2000.0;
		while(System:getTime() < giveUpTime && socketA.getState() != SocketState:CONNECTED) { }
		test(socketA.getState() == SocketState:CONNECTED);

		UDPSocket socketB = UDPSocket();
		socketB.listen(ipB);
		test(socketB.socketHandle != 0);

		giveUpTime = System:getTime() + 2000.0;
		while(System:getTime() < giveUpTime && socketB.getState() != SocketState:CONNECTED) { }
		test(socketB.getState() == SocketState:CONNECTED);
		
		// send some data from A to B
		u8[] sendBuffer = u8[](256);
		sendBuffer[0] = Chars:h;
		sendBuffer[1] = Chars:i;

		test(socketA.send(sendBuffer, 2, ipB) == true);

		u8[] recvBuffer = u8[](256);
		for(u64 r=0; r<256; r++)
			recvBuffer[r] = 0;

		giveUpTime = System:getTime() + 3000.0;
		u32 numRecv = 0;
		IPAddress fromIP = IPAddress();
		while(System:getTime() < giveUpTime && numRecv == 0)
		{
			numRecv = socketB.receive(recvBuffer, fromIP);
		}

		test(numRecv == 2);
		test(recvBuffer[0] == Chars:h && recvBuffer[1] == Chars:i);
		test(recvBuffer[2] == 0);

		socketA.disconnect();
		socketB.disconnect();
	}
}