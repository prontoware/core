////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class RSAEncryptionTests implements IUnitTest
{
	void run()
	{
        RSAKey key();

		key.generateKey(512);

		BigInt msgA("0xAABBCCDDAABBCCDD"); // 64 bit msg

		BigInt msgEncrypted = key.encrypt(msgA);
		test(msgEncrypted.numUsed >= 2);
		test(msgEncrypted.equals(msgA) == false);

		BigInt msgDecrypted = key.decrypt(msgEncrypted);
		test(msgDecrypted.numUsed == 2);
		test(msgDecrypted.equals(msgA) == true);
	}
}

class RSAEncryption2Tests implements IUnitTest
{
	void run()
	{
        RSAKey key();

		key.generateKey(512);

		BigInt msgA(); // 64 bit msg
		msgA.setFromBytesLittleEndian(u8[](0xA1, 0xB2, 0xC2, 0xD3, 0xE4, 0xF5, 0x66, 0x77));

		BigInt msgEncrypted = key.encrypt(msgA);
		test(msgEncrypted.numUsed >= 2);
		test(msgEncrypted.equals(msgA) == false);

		BigInt msgDecrypted = key.decrypt(msgEncrypted);
		test(msgDecrypted.numUsed == 2);
		test(msgDecrypted.equals(msgA) == true);
	}
}

class RSAPKCS1Tests implements IUnitTest
{
	void run()
	{
		RSAKey key();

		key.generateKey(512);

		u8[] msgA(0xAB, 0xBC, 0xDE, 0xEF, 0x12, 0x34, 0x56, 0x78); // 64 bit msg

		u8[] msgEncrypted = key.encryptPKCS1(msgA);
		test(msgEncrypted != null);
		if(msgEncrypted == null)
			return;

		test(msgEncrypted.length() == 64); // should equal key size bytes because padded etc.
		if(msgEncrypted.length() != 64)
		{
			Log:log("RSAPKCS1Tests failure with key: " + key.toString() + "\n");
			Log:log("RSAPKCS1Tests failure with msgEncrypted: " + ByteArray(msgEncrypted).toHexString() + "\n");
		}

		u8[] msgDecrypted = key.decryptPKCS1(msgEncrypted);
		test(msgDecrypted != null);
		if(msgDecrypted == null)
			return;

		test(msgDecrypted.length() == 8); // returns unpadded data
		for(u64 a=0; a<8; a++)
		{
			test(msgA[a] == msgDecrypted[a]);
		}
	}
}

class RSA_PKCS1_ReadFilesTests implements IUnitTest
{
	void run()
	{
		// RSA 2048 bit key
		String<u8> keyFileText = 
		"-----BEGIN RSA PRIVATE KEY-----\n" + 
        "MIIEpQIBAAKCAQEAwHoymP4LUWao6ji8emUxCIwBvl9ilIdGEDpKPhQ/44hzBxdu\n" + 
        "aGVlEqj1c+8UDgZnRZ/vG6j5x483Pn4qSQ7awPwV9PUDTNi0c5vfHT/z5MnqBTKG\n" + 
        "SzX/Da28Czs2QJEzMnrmWKkEZT6zbM4JWPwCudg636pts8O7ed1MeptW7ZpuAyXI\n" + 
        "o2hJH5FEB7b8h9VXLA8abmFJOIWssWHl8dozMKXGOCT+skYgDvgWzY4/HeMe80lm\n" + 
        "cxJHqnvvhH0r4Y18/rom0BUnXhC/EwNtjQO66mHJO/GhMq4aypGz8naAEoa0qH1t\n" + 
        "+xVoqF/Qa7TRyJF9/55V21H3PjlGdojllvwgiwIDAQABAoIBAQCIedzImFFkHXul\n" + 
        "4CbcTkXvPn66Ap4+nJA0T3B3Bhqq9gRBwf56LXL2QTERTDMXIrk1KAr9vNmnA0hz\n" + 
        "mjfXZ536eoQDFXuKkJma46nW7pK75eN2XfXU/Gtlwot0Fz8Hly0LHROZR/ai50uH\n" + 
        "2avNGZvBNK3CC/EPJrkW1rA0u1Ju0/diOSONQBxxgSG1JkyLjtMsDziUCLsX6TdW\n" + 
        "P6R2UVe9l7ofMvInJo45NQTbS5uWASaW/XC3RdyDX0UgYqZ6lyQBXdCq1NWVLeo9\n" + 
        "8Mc68kOyCK4KaovsELh65t84gFUlKuznPN16N1cbyIaP7wPFyPrgtEvzpI/DUyqw\n" + 
        "OraXI9qRAoGBAN++za9tskzv4dSWyNmO+3uvrDj3Woe5dZWGKzq9Kza5S6so45Je\n" + 
        "cKKvzMmCeTo4itbpaNRg6G5nmMOul2QMM7X78LvPTCiPVlZ9WzlBVW12SwALsNB/\n" + 
        "wg7hI0LeSYi8JZlImlEkg5IuhuKVxSfTwCDQznglrBBXaiqHVULIsR7TAoGBANw5\n" + 
        "d2WJGQMO5GuRFLwUkgxj7e5doMK3P3jzrUv1xttJGz/AEW/5U89nHgv7Vgg1ffAf\n" + 
        "2N7c+G2c+PkqSrwTZUyNjiKJ+s+3Uq6M4YqhI9h5AatXBcuAIW6FOEl+hljP0J19\n" + 
        "7HwwNsQTNz9gy0oM5jTiyqlyD2ofTJgbLaBnmhRpAoGBAIGyE35+It2wK4LUiMZ7\n" + 
        "uFEBCt7WmxaTrZIn/MUGxJbrH+6uPAQrVDUpnJauV+Ekx24+THLXXcQprwa3HLB0\n" + 
        "1kDGMsxbJHVaaRyne4qb0Y4rBNyY6jxh4jZH0O3A9nUZQt4wlKs2dEH3UF7lnCwy\n" + 
        "9WrQPu6sP6oVUcgnPIgC15DbAoGBANagTwOutKitV+KZl4qhxaC7t0QrDaUXMI3x\n" + 
        "doBkPPSz8BGWX6gwZwToK3lj7vm7IEzozNSOqLMzW9aB6CoaAQy1nMN+k+jicntZ\n" + 
        "I+qWlze+3uicvDITYwGyZiQCYm6lwlvrQJHb71PyolJrRFSb87OxH/A6EFnNvTk0\n" + 
        "q6f7sEeZAoGANulEMg6Cvy1ILpINoAUEGimIroeAD0wSKAwcDwZGKc1pJBgeWeKC\n" + 
        "erZpD8wk/1xXtznVFbv+nHTbHEFYB66d/z22pUx0ARSxo/OTitVuRy8cIGFZn5Lp\n" + 
        "6E48jL7KMRy2gcu7b+oi2ajOeEDquuKit22/1lr3STonnUXRfc9RatM=\n" + 
        "-----END RSA PRIVATE KEY-----\n";
		
		String<u8> readErrors();
		RSAKey key = RSAKey:readPKCS1(keyFileText, readErrors);

		if(key == null)
			Log:log("RSAPKCS1PrivateKeyFilesTests errors\n" + readErrors);

		test(key != null);
		if(key == null)
			return;

		test(key.e != null);
		test(key.e.equals(BigInt("65537")) == true);

		u8[] msgA(0xAB, 0xBC, 0xDE, 0xEF, 0x12, 0x34, 0x56, 0x78); // 64 bit msg

		u8[] msgEncrypted = key.encryptPKCS1(msgA);
		test(msgEncrypted != null);
		if(msgEncrypted == null)
			return;

		test(msgEncrypted.length() == 256); // should equal key size bytes because padded etc.
		if(msgEncrypted.length() != 256)
		{
			Log:log("RSAPKCS1PrivateKeyFilesTests failure with key: " + key.toString() + "\n");
			Log:log("RSAPKCS1PrivateKeyFilesTests failure with msgEncrypted: " + ByteArray(msgEncrypted).toHexString() + "\n");
		}

		u8[] msgDecrypted = key.decryptPKCS1(msgEncrypted);
		test(msgDecrypted != null);
		if(msgDecrypted == null)
			return;

		test(msgDecrypted.length() == 8); // returns unpadded data
		for(u64 a=0; a<8; a++)
		{
			test(msgA[a] == msgDecrypted[a]);
		}
		
		//Log:log("RSA_PKCS1_ReadFilesTests PKCS#1 file: \n\n" + key.writePKCS1Text() + "\n\n");
	}
}

class RSA_PKCS1_WriteFilesTests implements IUnitTest
{
	void run()
	{
		// Generate RSA key
		RSAKey key();
		key.generateKey(512); 

		ByteArray keyFile = key.writePKCS1();

		test(keyFile != null);
		if(keyFile == null)
			return;

		test(keyFile.size() > 128); // 512 bit key is 512 + 256 + 256 bits minimum file (for p/q/n of RSA key)

		String<u8> base64Key = key.writePKCS1Text();
		test(base64Key != null);
		test(base64Key.contains("-----BEGIN RSA PRIVATE KEY-----\n") == true);
		test(base64Key.contains("-----END RSA PRIVATE KEY-----\n") == true);

		String<u8> readErrors();
		RSAKey key2 = RSAKey:readPKCS1(keyFile, readErrors);

		if(key2 == null)
		{
			test(key2 != null);
			Log:log("RSA_PKCS1_WriteFilesTests key2 readErrors \n" + readErrors + "\n");
			return;
		}

		test(key.p.equals(key2.p) == true);
		test(key.q.equals(key2.q) == true);
		test(key.n.equals(key2.n) == true);
		test(key.e.equals(key2.e) == true);
		test(key.d.equals(key2.d) == true);

		// Test parsing base64 encoded version
		RSAKey key3 = RSAKey:readPKCS1(base64Key, readErrors);

		if(key3 == null)
		{
			test(key3 != null);
			Log:log("RSA_PKCS1_WriteFilesTests key3 readErrors \n" + readErrors + "\n");
			return;
		}

		test(key.p.equals(key3.p) == true);
		test(key.q.equals(key3.q) == true);
		test(key.n.equals(key3.n) == true);
		test(key.e.equals(key3.e) == true);
		test(key.d.equals(key3.d) == true);
	}
}

class RSASignatureTests implements IUnitTest
{
	void run()
	{
		RSAKey key();
		key.generateKey(512);

		BigInt hashForSigning("0xAABBCCDDAABBCCDDABCDEFABACADAEAF"); // our stand-in 128 bit hash
		u8[] signedHash = key.sign(hashForSigning);

		test(signedHash != null);
		if(signedHash == null)
			return;

		u64 keyNumBytes = Math:ceil(key.getKeyLength() / 8.0);

		test(signedHash.length() == keyNumBytes); // padding PKCS#1
		if(signedHash.length() != keyNumBytes)
		{
			Log:log("RSASignatureTests failure with key: " + key.toString() + "\n");
			Log:log("RSASignatureTests failure with keyNumBytes: " + String<u8>:formatNumber(keyNumBytes) + "\n");
			Log:log("RSASignatureTests failure with signedHash: " + ByteArray(signedHash).toHexString() + "\n");
		}

		RSAPublicKey rsaPublicKey = key.getPublicKey();

		test(rsaPublicKey.verifySignature(signedHash, hashForSigning.asBytesLittleEndian()) == true);
		test(rsaPublicKey.verifySignature(signedHash, signedHash) == false);
	}
}