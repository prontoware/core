////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// IPAddress
////////////////////////////////////////////////////////////////////////////////////////////////////

// v4 or v6 IP Address. Not all platforms support v6. TODO fully support v6.
class IPAddress
{
	u8[16] ip; // first four elements "0.1.2.3" for v4 addresses.
	i32 port = -1; // negative values indicate this is not in use (not set)

	// Default 0.0.0.0 address.
	void constructor()
	{
		clear();
	}

	// Set a.b.c.d:port v4 address.
	void constructor(u8 a, u8 b, u8 c, u8 d, i32 port)
	{
		clear();

		this.ip[0] = a;
		this.ip[1] = b;
		this.ip[2] = c;
		this.ip[3] = d;

		this.port = port;
	}

	// Set v4/v6 address.
	void constructor(u8[16] ip)
	{
		clear();

		this.ip = ip;
	}

	// Set v4/v6 address + port.
	void constructor(u8[16] ip, i32 port)
	{
		clear();

		this.ip   = ip;
		this.port = port;
	}

	// Set a.b.c.d:port v4 address or domain:port format.
	void constructor(String<u8> ipStr)
	{
		clear();
		set(ipStr);
	}

	// Clear address/port to 0.0.0.0:-1
	void clear()
	{
		for(u8 i=0; i<16; i++)
			this.ip[i] = 0;

		this.port = -1;
	}

	// Is not 0.0.0.0, which is invalid.
	bool isValid()
	{
		if(ip[0] == 0 && ip[1] == 0 && ip[2] == 0 && ip[3] == 0)
			return false;

		return true;
	}

	// Copy passed-in address
	void copy(IPAddress i)
	{
		for(u8 v=0; v<16; v++)
			this.ip[v] = i.ip[v];

		this.port = i.port;
	}

	// Get IP bytes
	u8[16] getIPBytes()
	{
		return this.ip;
	}

	// 0-65535 range. Use -1 for "unused".
	void setPort(i32 newPort)
	{
		this.port = newPort;
	}

	// 0-65535 range
	i32 getPort()
	{
		return this.port;
	}

	// Parse from string in form "X.X.X.X:port" or "domain:port" etc.
	bool set(String<u8> ipPortStr)
	{
		if(ipPortStr == null)
			return false;

		if(ipPortStr.length() == 0)
			return false;

		if(Chars:isNumeric(ipPortStr.chars[0]) == true)
		{
			// TODO support v6

			String<u8> ipStr   = null; // "X.X.X.X" only
			String<u8> portStr = null;

			i64 colonIndex = ipPortStr.findNext(Chars:COLON, 0);
			if(colonIndex >= 1)
			{
				ipStr   = ipPortStr.subString(0, colonIndex-1);
				portStr = ipPortStr.subString(colonIndex+1, ipPortStr.length()-1);
			}
			else
			{
				ipStr = String<u8>(ipPortStr); // just "X.X.X.X"
			}

			ArrayList<String<u8>> ipNums = ipPortStr.split(Chars:PERIOD, true);
			if(ipNums.size() == 4)
			{
				for(u8 i=0; i<4; i++)
					ip[i] = ipNums[i].parseInteger();
			}
			else
			{
				return false;
			}
			
			if(portStr != null)
			{
				this.port = portStr.parseInteger();
			}
		}
		else // must be domain
		{
			IPAddress ipAddr = Network:resolveDomainToIP(ipPortStr);
			this.copy(ipAddr);
		}

		return true;
	}

	// Returns "X.X.X.X:port" or "X.X.X.X" if port is negative (AKA unused).
	String<u8> toString()
	{
		String<u8> ipStr = toStringIPOnly();
		if(port >= 0)
		{
			ipStr.append(Chars:COLON);
			ipStr.append(String<u8>:formatNumber(port));
		}

		return ipStr;
	}

	// Returns "X.X.X.X"
	String<u8> toStringIPOnly()
	{
		String<u8> ipStr = String<u8>(16);

		for(u8 i=0; i<4; i++)
		{
			ipStr.append(String<u8>:formatNumber(ip[i]));
			if(i != 3)
				ipStr.append(Chars:PERIOD);
		}

		return ipStr;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// SocketState
////////////////////////////////////////////////////////////////////////////////////////////////////

// Constants used by ISocket to indicate connection status.
class SocketState
{
	const u8 NO_ATTEMPT         = 1; // Socket hasn't been used yet.
	const u8 CONNECTING         = 2; // In process of connecting (TCP only).
	const u8 CONNECTED          = 3; // Assigned source/destination IPs. For TCP, actually got ACK response.
	const u8 CONNECT_FAILED     = 4; // Failed to connect (TCP only).
	const u8 DISCONNECTED       = 5; // Failed to send/recv or we closed connection or destination closed connection.
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// ISocket
////////////////////////////////////////////////////////////////////////////////////////////////////

// Interface to a TCP/UDP socket.
interface ISocket
{
	// Get address we are bound to (local machine). Applies for all sockets.
	IPAddress getSourceIP();

	// Get address we are connected to. Does not apply for TCP listen() sockets.
	IPAddress getDestinationIP();

	// Connecting, Disconnected etc. See SocketState for values.
	u8 getState();

	// Send data via socket.
	bool send(u8[] data, u32 numBytes);

	// Send data via socket.
	bool send(u8[] data, u32 dataStartIndex, u32 numBytes);

	// Send data via socket. toIP parameter applies to UDP only, ignored by TCP.
	bool send(u8[] data, u32 numBytes, IPAddress toIP);

	// Send data via socket. toIP parameter applies to UDP only, ignored by TCP.
	bool send(u8[] data, u32 dataStartIndex, u32 numBytes, IPAddress toIP);

	// Receive data from socket.
	u32 receive(u8[] data);

	// Receive data from socket.
	u32 receive(u8[] data, u32 dataStartIndex);

	// Receive data from socket. outIP parameter applies to UDP only, ignored by TCP.
	u32 receive(u8[] data, IPAddress outIP);

	// Receive data from socket. outIP parameter applies to UDP only, ignored by TCP.
	u32 receive(u8[] data, u32 dataStartIndex, IPAddress outIP);

	// Ensure socket processes buffers etc. Depending on implementation may do nothing.
	void update();

	// Disconnect socket from destination.
	void disconnect();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// TCPSocket
////////////////////////////////////////////////////////////////////////////////////////////////////

// Standard TCP socket with berkeley-sockets style functionality. Non-blocking for all operations.
// For TLS (AKA SSL) usage see TLSClient and TLSServer which wrap this.
class TCPSocket implements ISocket
{
	u64 socketHandle; // handle to native socket, not valid until call to connect() or listen()
	IPAddress srcIP = null; // cached
	IPAddress desIP = null; // cached

	// No socket allocated until connect() or listen() called.
	void constructor()
	{
		this.socketHandle = 0;
	}

	// For existing sockets.
	void constructor(u64 existingSocketHandle)
	{
		this.socketHandle = existingSocketHandle;
	}

	// Destroys socket.
	void destroy()
	{
		Network:socketDisconnect_native(this.socketHandle);
		Network:socketDestroy_native(this.socketHandle);
		this.socketHandle = 0;
		srcIP = null;
		desIP = null;
	}

	// Connect as client to server. getState() will return STATE_CONNECTING until connection success or failure.
	void connect(IPAddress desIP)
	{
		if(this.socketHandle != 0)
			this.destroy();

		this.socketHandle = Network:socketConnect_native(desIP.ip, desIP.port);
	}

	// Open a local listening port (act as server). getState() will return STATE_CONNECTING until connection success or failure.
	void listen(IPAddress srcIP)
	{
		if(this.socketHandle != 0)
			this.destroy();

		this.socketHandle = Network:socketListen_native(srcIP.ip, srcIP.port);
	}

	// After calling listen() call this to accept new connections. Returns null if no new connection.
	ISocket accept()
	{
		u64 newSocketHandle = Network:socketAccept_native(this.socketHandle);
		if(newSocketHandle == 0)
			return null;

		return TCPSocket(newSocketHandle);
	}

	// Get address we are bound to (local machine). Applies for all sockets.
	IPAddress getSourceIP()
	{
		if(srcIP == null)
			srcIP = IPAddress(Network:socketGetSrcIP_native(this.socketHandle));

		return srcIP;
	}

	// Get address we are connected to. Does not apply for TCP listen() sockets.
	IPAddress getDestinationIP()
	{
		if(desIP == null)
			desIP = IPAddress(Network:socketGetDesIP_native(this.socketHandle));

		return desIP;
	}

	// Connecting, Disconnected etc. See SocketState for values.
	u8 getState()
	{
		return Network:socketGetState_native(this.socketHandle);
	}

	// Send data via socket.
	bool send(u8[] data, u32 numBytes)
	{
		return send(data, 0, numBytes);
	}

	// Send data via socket.
	bool send(u8[] data, u32 dataStartIndex, u32 numBytes)
	{
		return Network:socketSend_native(this.socketHandle, data, dataStartIndex, numBytes);
	}

	// Send data from socket. toIP parameter applies to UDP only, ignored by TCP.
	bool send(u8[] data, u32 numBytes, IPAddress toIP)
	{
		return send(data, 0, numBytes);
	}

	// Send data from socket. toIP parameter applies to UDP only, ignored by TCP.
	bool send(u8[] data, u32 dataStartIndex, u32 numBytes, IPAddress toIP)
	{
		return send(data, dataStartIndex, numBytes);
	}

	// Receive data from socket. Returns number of bytes received, written into data parameter.
	u32 receive(u8[] data)
	{
		return receive(data, 0);
	}

	// Receive data from socket. Returns number of bytes received, written into data parameter.
	u32 receive(u8[] data, u32 dataStartIndex)
	{
		return Network:socketRecv_native(this.socketHandle, data, dataStartIndex);
	}

	// Receive data from socket. outIP parameter applies to UDP only, ignored by TCP.
	u32 receive(u8[] data, IPAddress outIP)
	{
		return receive(data, 0);
	}

	// Receive data from socket. outIP parameter applies to UDP only, ignored by TCP.
	u32 receive(u8[] data, u32 dataStartIndex, IPAddress outIP)
	{
		return receive(data, dataStartIndex);
	}

	// Implements ISocket interface, does nothing.
	void update()
	{

	}

	// Disconnect socket from destination.
	void disconnect()
	{
		Network:socketDisconnect_native(this.socketHandle);
		Network:socketDestroy_native(this.socketHandle);
		this.socketHandle = 0;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// UDPSocket
////////////////////////////////////////////////////////////////////////////////////////////////////

// Standard UDP socket with berkeley-sockets style functionality. Non-blocking for all operations.
class UDPSocket implements ISocket
{
	u64 socketHandle; // handle to native socket, not valid until call to listen()
	u8[]  tempIPBytes = u8[](16);
	i32[] tempPort    = i32[](1);
	IPAddress srcIP = null; // cached
	IPAddress tempIP();

	// No socket allocated until listen() called.
	void constructor()
	{
		this.socketHandle = 0;
	}

	// Destroys socket.
	void destroy()
	{
		Network:socketDestroy_native(this.socketHandle);
		this.socketHandle = 0;
		srcIP = null;
	}

	// Open (bind) a local listening port. getState() will return STATE_CONNECTING until connection success or failure.
	void listen(IPAddress srcIP)
	{
		if(this.socketHandle != 0)
			this.destroy();

		this.socketHandle = Network:udpSocketListen_native(srcIP.ip, srcIP.port);
	}

	// Get address we are bound to (local machine). Applies for all sockets.
	IPAddress getSourceIP()
	{
		if(srcIP == null)
			srcIP = IPAddress(Network:socketGetSrcIP_native(this.socketHandle));

		return srcIP;
	}

	// Get address we are connected to. Does not apply for UDP sockets.
	IPAddress getDestinationIP()
	{
		return null;
	}

	// Connecting, Disconnected etc. See SocketState for values.
	u8 getState()
	{
		return Network:socketGetState_native(this.socketHandle);
	}

	// Send data via socket.
	bool send(u8[] data, u32 numBytes)
	{
		assert(false); // must call "send(u8[] data, u32 numBytes, IPAddress toIP)" for UDP
		return false;
	}

	// Send data via socket.
	bool send(u8[] data, u32 dataStartIndex, u32 numBytes)
	{
		assert(false); // must call "send(u8[] data, u32 numBytes, IPAddress toIP)" for UDP
		return false;
	}

	// Send data via socket.
	bool send(u8[] data, u32 numBytes, IPAddress toIP)
	{
		return send(data, 0, numBytes, toIP);
	}

	// Send data via socket.
	bool send(u8[] data, u32 dataStartIndex, u32 numBytes, IPAddress toIP)
	{
		return Network:udpSocketSend_native(this.socketHandle, data, dataStartIndex, numBytes, toIP.ip, toIP.port);
	}

	// Receive data from socket. Returns number of bytes received, written into data parameter.
	u32 receive(u8[] data)
	{
		u32 numRecv = receive(data, 0, tempIP);
		return numRecv;
	}

	// Receive data from socket. Returns number of bytes received, written into data parameter.
	u32 receive(u8[] data, u32 dataStartIndex)
	{
		u32 numRecv = receive(data, dataStartIndex, tempIP);
		return numRecv;
	}

	// Receive data from socket. Returns number of bytes received, written into data parameter. ipOut contains where data came from.
	u32 receive(u8[] data, IPAddress ipOut)
	{
		return receive(data, 0, ipOut);
	}

	// Receive data from socket. Returns number of bytes received, written into data parameter. ipOut contains where data came from.
	u32 receive(u8[] data, u32 dataStartIndex, IPAddress ipOut)
	{
		u32 numBytes = Network:udpSocketRecv_native(this.socketHandle, data, dataStartIndex, tempIPBytes, tempPort);
		ipOut.port = tempPort[0];
		for(u8 i=0; i<16; i++)
			ipOut.ip[i] = tempIPBytes[i];
		return numBytes;
	}

	// Implements ISocket interface, does nothing.
	void update()
	{

	}

	// Disconnect socket from source (AKA unbind socket).
	void disconnect()
	{
		Network:socketDisconnect_native(this.socketHandle);
		Network:socketDestroy_native(this.socketHandle);
		this.socketHandle = 0;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Network
////////////////////////////////////////////////////////////////////////////////////////////////////

// Access to the native OS TCP/UDP socket networking.
//
// Note we are "extending" the built-in Network class. This just means that the Network class 
// basics are built-in to the language, but some helper functions live here.
class Network
{
	// Get list of all available IP addresses for this device.
	shared ArrayList<IPAddress> getHostIPs()
	{
		ArrayList<IPAddress> ips = ArrayList<IPAddress>();

		u8[16][] ipVecs = Network:getHostIPs_native();
		for(u64 i=0; i<ipVecs.length(); i++)
		{
			IPAddress ipAddr = IPAddress(ipVecs[i]);
			ips.add(ipAddr);
		}

		return ips;
	}

	// Resolve hostname / URL to IP address. This is the more robust/general version of resolveHostToIP().
	// Examples:
	// "prontoware.com" to "1.2.3.4"
	// "prontoware.com:8080" to "1.2.3.4:8080"
	// "http://prontoware.com" to "1.2.3.4:80"
	// "http://www.prontoware.com" to "1.2.3.4:80"
	// "https://prontoware.com" to "1.2.3.4:443"
	shared IPAddress resolveDomainToIP(String<u8> domainURL)
	{
		if(domainURL == null)
			return IPAddress();

		if(domainURL.length() == 0)
			return IPAddress();

		String<u8> modURL(domainURL);

		i32 port = 80;
		if(modURL.beginsWith("https://"))
		{
			port = 443;
			modURL = modURL.subString(8, modURL.length()-1);
		}
		else if(modURL.beginsWith("http://"))
		{
			modURL = modURL.subString(7, modURL.length()-1);
		}
		else if(modURL.beginsWith("ftp://"))
		{
			modURL = modURL.subString(6, modURL.length()-1);
			port = 21; // command port
		}

		if(modURL.beginsWith("www."))
		{
			modURL = modURL.subString(4, modURL.length()-1);
		}

		// find slash in "google.com/pages" etc. only want "google.com"
		i64 slashIndex = modURL.findNext(Chars:FORWARD_SLASH, 0);
		if(slashIndex >= 0)
		{
			modURL = modURL.subString(0, slashIndex-1);
		}

		// i.e. google.com:8080
		i64 colonIndex = modURL.findNext(Chars:COLON, 0);
		if(colonIndex >= 0)
		{
			String<u8> portStr = modURL.subString(colonIndex+1, modURL.length()-1);
			if(portStr != null)
				port = portStr.parseInteger();

			modURL = modURL.subString(0, colonIndex-1); // remove port
			if(modURL == null)
				modURL = String<u8>();
		}

		IPAddress ipAddr = Network:resolveHostToIP(modURL);

		if(ipAddr.port < 0)
			ipAddr.port = port;

		return ipAddr;
	}

	// Resolve hostname to IP address. Does not handle domain prefixes etc.
	// Examples:
	// "prontoware.com" to "1.2.3.4".
	// "1.2.3.4" to "1.2.3.4".
	shared IPAddress resolveHostToIP(String<u8> hostStr)
	{
		String<u8> ipStr = resolveHostToIP_native(hostStr);
		return IPAddress(ipStr);
	}
}