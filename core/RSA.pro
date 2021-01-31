////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// RSAPublicKey
////////////////////////////////////////////////////////////////////////////////////////////////////

// Public part of RSA key only.
class RSAPublicKey
{
    // Two parts
    BigInt n; // p and q are primes, p * q = n
    BigInt e; // exponent

    // Empty (zero) key.
    void constructor()
    {
        this.n = BigInt();
        this.e = BigInt();
    }

    // Construct from components. n is p * q, e is exponent
    void constructor(BigInt n, BigInt e)
    {
        this.n = BigInt(n);
        this.e = BigInt(e);
    }

    // Copy-constructor
    void constructor(RSAPublicKey k)
    {
        this.n = BigInt(k.n);
        this.e = BigInt(k.e);
    }

    // Get key size in bits
    u32 getKeyLength()
    {
        if(n == null)
            return 0;

        return n.getBitLength();
    }

    // String format for humans, two lines.
    String<u8> toString()
    {
        String<u8> s(4096);

        if(n != null)
            s.append("Modulus (base 16): " + n.toString(16) + "\n");
        else
            s.append("Modulus:\n");

        if(e != null)
            s.append("Exponent (base 10): " + e.toString(10)); // traditionally 65537
        else
            s.append("Exponent:");

        return s;
    }

    // Encrypt using PKCS#1 encryption block format. data length must be smaller than RSA key length. This is how RSA is used in the real world (i.e. TLS 1.2). PKCS#1 padding has known vulnerabilities, use OAEP instead where possible.
    u8[] encryptPKCS1(u8[] data)
    {
        // A block type BT, a padding string PS, and the data D shall be
        // formatted into an octet string EB, the encryption block.
        // EB = 00 || BT || PS || 00 || D . 
        // See https://tools.ietf.org/html/rfc2313 for more info.

        u32 keyBytesLen = Math:ceil(getKeyLength() / 8.0);

        if(data == null)
            return null;

        if((data.length()+11) > keyBytesLen)
            return null; // cannot encrypt more data bytes (+11 bytes block format overhead) than key length
    
        u8[] eb(keyBytesLen); // 11 bytes is the minimum for padding and also relatively universal
        eb[0] = 0; // The leading 00 octet ensures that the encryption block, converted to an integer, is less than the modulus.
        eb[1] = 2; // PKCS#1 defines three block formats, 00, 01, and 02. BT=02 is default for encryption (but not signatures).
        u32 numPadBytes = keyBytesLen - (data.length() + 3);
        u64 trueRandomNumber = System:getTrueRandom();
        if(trueRandomNumber == 0)
            trueRandomNumber = u64(System:getTime()) ^ 0xAB56CD01BB931190;
        for(u32 r=0; r<numPadBytes; r++)
        {
            eb[2 + r] = u8(trueRandomNumber >> ((r % 8) * 8));
            if(eb[2 + r] == 0)
                eb[2 + r] = 0x84; // cannot be zero because zero indicates end of padding
        }
        eb[2 + numPadBytes] = 0; // must be zero to indicate end of padding

        for(u64 a=0; a<data.length(); a++)
        {
            eb[2 + numPadBytes + 1 + a] = data[a];
        }

        // encrypt eb and return
        BigInt encryptedInt();
        encryptedInt.setFromBytesBigEndian(eb); // must be set big endian so that 0x00 byte is most significant ensuring N bits fits into RSA key length
        encryptedInt.moduloPower(e, n);

        return RSAPublicKey:leftPadZeros(encryptedInt.asBytesBigEndian(), keyBytesLen);
    }

    // Verify a RSA signature.
    bool verifySignature(BigInt signature, BigInt expectedHash)
    {
        return verifySignature(signature, expectedHash.asBytesBigEndian());
    }

    // Verify a RSA signature. signature and expectedHash must be in big endian order, because we assume PKCS#1 standard for signatures.
    bool verifySignature(u8[] signature, u8[] expectedHash)
    {
        BigInt signatureInt();
        signatureInt.setFromBytesBigEndian(signature); // RSA PKCS #1 standard is big endian
        return verifySignature(signatureInt, expectedHash);
    }

    // Verify a RSA signature. expectedHash must be in big endian order, because we assume PKCS#1 standard for signatures.
    bool verifySignature(BigInt signature, u8[] expectedHash)
    {
        if(expectedHash.length() == 0)
            return false; // this is clearly a bug

        BigInt result(signature);
        result.moduloPower(e, n);

        u8[] unsignedHash = result.asBytesLittleEndian(); // little endian to big endian handles farther down when we reverse bytes
        if(unsignedHash == null || expectedHash == null)
            return false;

        // unsignedHash might be missing leading zeros. AKA it's possible the real hash has multiple leading zero bytes...unlikely, but possible.
        // So zero pad unsignedHash to match length of expected hash.
        if(unsignedHash.length() < expectedHash.length())
        {
            u8[] unpaddedHash = unsignedHash;
            unsignedHash = u8[](expectedHash.length()); // all bytes zero by default

            for(u64 i=0; i<unpaddedHash.length(); i++)
            {
                unsignedHash[i] = unpaddedHash[i];
            }
        }

        // unsignedHash must be same size, remove leading extraneous bytes
        if(unsignedHash.length() > expectedHash.length())
        {
            u8[] oldHash = unsignedHash;
            unsignedHash = u8[](expectedHash.length());

            for(u64 i=0; i<expectedHash.length(); i++)
                unsignedHash[i] = oldHash[i];
        }

        // BigInt is little endian, reverse hash result to big endian to match PKCS #1 standard
        u8[] rHash = u8[](unsignedHash.length());
        for(u64 i=0; i<unsignedHash.length(); i++)
            rHash[i] = unsignedHash[unsignedHash.length() - (i + 1)];
        unsignedHash = rHash;

        // sanity check
        if(unsignedHash.length() != expectedHash.length())
            return false;

        // check hash values match
        for(u64 i=0; i<unsignedHash.length(); i++)
        {
            if(unsignedHash[i] != expectedHash[i])
                return false;
        }

        return true;
    }

    // Left pad with zero bytes. Returns original array if no padding needed.
    shared u8[] leftPadZeros(u8[] bytes, u64 minNumBytes)
    {
        // BigInt doesn't return leading zeroes, so we have to pad manually from left
        u8[] result = bytes;

        if(result.length() < minNumBytes)
        {
            u8[] tempRes = result;
            result = u8[](minNumBytes);

            u64 numLeadingZeros = minNumBytes - tempRes.length();

            for(u64 z=0; z<numLeadingZeros; z++)
                result[z] = 0;

            for(u64 y=0; y<tempRes.length(); y++)
                result[numLeadingZeros + y] = tempRes[y];
        }

        return result;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// RSAKey
////////////////////////////////////////////////////////////////////////////////////////////////////

// RSA key generation, encryption and decryption. Public + private key components.
class RSAKey
{
    const u64 PUBLIC_E = 65537; // Useful for all public keys

    // RSA components
    BigInt p();      // prime number 1, used to make keys
    BigInt q();      // prime number 2, used to make keys
    BigInt n();      // public key (part A). n = p * q. Factorizing n to find p and q is computationally difficult. This is what makes RSA work.
    BigInt d();      // private key calculated from p, q, and e. For a given n and e, there is a unique number d.
    BigInt e(65537); // public key (part B)

    // Empty key
    void constructor()
    {
        // default null key
    }

    // Construct from components. p and q are large primes, e is the exponent (65537 in most applications).
    void constructor(BigInt p, BigInt q, BigInt e)
    {
        this.p = BigInt(p);
        this.q = BigInt(q);
        this.e = BigInt(e);

        computeCachedNandD();
    }

    // Copy-constructor.
    void constructor(RSAKey k)
    {
        this.p = BigInt(k.p);
        this.q = BigInt(k.q);
        this.n = BigInt(k.n);
        this.d = BigInt(k.d);
        this.e = BigInt(k.e);
    }

    // String format for humans, two lines.
    String<u8> toString()
    {
        String<u8> s(4096);

        if(p != null)
            s.append("Prime P: " + p.toString(16) + "\n");
        else
            s.append("Prime P:\n");

        if(q != null)
            s.append("Prime Q: " + q.toString(16) + "\n");
        else
            s.append("Prime Q:\n");

        if(d != null)
            s.append("D: " + d.toString(16) + "\n");
        else
            s.append("D:\n");

        if(n != null)
            s.append("Modulus (base 16): " + n.toString(16) + "\n");
        else
            s.append("Modulus:\n");

        if(e != null)
            s.append("Exponent (base 10): " + e.toString(10)); // traditionally 65537
        else
            s.append("Exponent:");

        return s;
    }

    // Generate public/private key pair. P and Q are randomly generated primes. Uses e=65537 by default.
    void generateKey(u32 keyBitsLen)
    {
        generateKey(keyBitsLen, BigInt(65537));
    }

    // Generate public/private key pair. P and Q are randomly generated primes, e chosen by you.
    void generateKey(u32 keyBitsLen, BigInt e)
    {
        u32 halfKeyBitsLen = keyBitsLen / 2;

        this.p = BigInt:randomProbablePrime(halfKeyBitsLen);
        this.q = BigInt:randomProbablePrime(halfKeyBitsLen);
        this.e = BigInt(e);

        this.n.copy(p);
        this.n.multiply(q);

        while(n.getBitLength() < keyBitsLen)
        {
            // try regenerating smaller half of key until we get a big enough result
            if(this.p.lessThan(this.q))
                this.p = BigInt:randomProbablePrime(halfKeyBitsLen);
            else
                this.q = BigInt:randomProbablePrime(halfKeyBitsLen);

            this.n.copy(p);
            this.n.multiply(q);
        }

        computeCachedNandD();
    }

    // Compute n and d from p/q/e values.
    void computeCachedNandD()
    {
        this.n.copy(p);
        this.n.multiply(q);

        BigInt p1(p);
        p1.subtract(1);
        BigInt q1(q);
        q1.subtract(1);

        BigInt n1();
        n1.copy(p1);
        n1.multiply(q1);

        // Generate public/private exponents
        // e chosen
        d.copy(e);
        d.modInv(n1);
    }

    // Get key size in bits
    u32 getKeyLength()
    {
        if(n == null)
            return 0;

        return n.getBitLength();
    }

    // Get copy of public key (n and e).
    RSAPublicKey getPublicKey()
    {
        return RSAPublicKey(n, e);
    }

    // Encrypt message. Msg must be number 0 ... N where N is the product of p and q.  RSA encryption without a padding scheme (PKCS1 or OAEP) should not be used in the real world.
    BigInt encrypt(BigInt msg)
    {
        BigInt result(msg);
        result.moduloPower(e, n);
        return result;
    }

    // Encrypt using PKCS#1 encryption block format. data length must be smaller than RSA key length. This is how RSA is used in the real world (i.e. TLS 1.2). PKCS#1 padding has known vulnerabilities, use OAEP instead where possible.
    u8[] encryptPKCS1(u8[] data)
    {
        // A block type BT, a padding string PS, and the data D shall be
        // formatted into an octet string EB, the encryption block.
        // EB = 00 || BT || PS || 00 || D . 
        // See https://tools.ietf.org/html/rfc2313 for more info.

        u32 keyBytesLen = Math:ceil(getKeyLength() / 8.0);

        if(data == null)
            return null;

        if((data.length()+11) > keyBytesLen)
            return null; // cannot encrypt more data bytes (+11 bytes block format overhead) than key length
    
        u8[] eb(keyBytesLen); // 11 bytes is the minimum for padding and also relatively universal
        eb[0] = 0; // The leading 00 octet ensures that the encryption block, converted to an integer, is less than the modulus.
        eb[1] = 2; // PKCS#1 defines three block formats, 00, 01, and 02. BT=02 is default for encryption (but not signatures).
        u32 numPadBytes = keyBytesLen - (data.length() + 3);
        u64 trueRandomNumber = System:getTrueRandom();
        if(trueRandomNumber == 0)
            trueRandomNumber = u64(System:getTime()) ^ 0xAB56CD01BB931190;
        for(u32 r=0; r<numPadBytes; r++)
        {
            eb[2 + r] = u8(trueRandomNumber >> ((r % 8) * 8));
            if(eb[2 + r] == 0)
                eb[2 + r] = 0x84; // cannot be zero because zero indicates end of padding
        }
        eb[2 + numPadBytes] = 0; // must be zero to indicate end of padding

        for(u64 a=0; a<data.length(); a++)
        {
            eb[2 + numPadBytes + 1 + a] = data[a];
        }

        // encrypt eb and return
        BigInt encryptedInt();
        encryptedInt.setFromBytesBigEndian(eb); // must be set big endian so that 0x00 byte is most significant ensuring N bits fits into RSA key length
        encryptedInt.moduloPower(e, n);

        return RSAPublicKey:leftPadZeros(encryptedInt.asBytesBigEndian(), keyBytesLen);
    }

    // Decrypt message. Decrypted msg will be number 0 ... N where N is the product of p and q. RSA encryption without a padding scheme (PKCS1 or OAEP) should not be used in the real world.
    BigInt decrypt(BigInt msg)
    {
        BigInt result(msg);
        result.moduloPower(d, n);
        return result;
    }

    // Decrypt using PKCS#1 encryption block format. data length must be smaller than RSA key length. This is how RSA is used in the real world (i.e. TLS 1.2). PKCS#1 padding has known vulnerabilities, use OAEP instead where possible.
    u8[] decryptPKCS1(u8[] data)
    {
        // A block type BT, a padding string PS, and the data D shall be
        // formatted into an octet string EB, the encryption block.
        // EB = 00 || BT || PS || 00 || D . 
        // See https://tools.ietf.org/html/rfc2313 for more info.
        // BT = 01, 02 are decoded same way and are compatible with PEM RSA encryption of content-encryption keys and message digests as described in RFC 1423.

        if(data == null)
            return null;

        if(data.length() < 11)
            return null; // can't be valid

        // decrypt
        BigInt encryptedInt();
        encryptedInt.setFromBytesBigEndian(data); 
        encryptedInt.moduloPower(d, n); // decrypt
        u8[] eb = encryptedInt.asBytesBigEndian();

        test(eb != null);
        if(eb == null)
            return null;

        test(eb.length() >= 11);
        if(eb.length() < 11)
            return null;

        //if(eb[0] != 0) // BigInt doesn't have leading zeros
        //    return null; // not properly formatted

        if(eb[0] != 1 && eb[0] != 2) // block types we support, rest are no-go
            return null;

        // skip over FF bytes (bt=1) or random bytes (bt=2) until zero
        u64 curByteIndex = 2;
        while(curByteIndex < eb.length())
        {
            if(eb[curByteIndex] == 0)
                break;

            curByteIndex++;
        }

        if(curByteIndex >= eb.length())
            return null; // no data to decrypt

        u8[] retData(eb.length() - (curByteIndex + 1));
        for(u64 a=0; a<retData.length(); a++)
            retData[a] = eb[curByteIndex + 1 + a];

        return retData;
    }

    // Make a signature. This uses the private key to encrypt.
    u8[] sign(BigInt msg)
    {
        return sign(msg.asBytesLittleEndian());
    }

    // Make an RSA signature. This uses the private key to encrypt.
    u8[] sign(u8[] data)
    {
        // A block type BT, a padding string PS, and the data D shall be
        // formatted into an octet string EB, the encryption block.
        // EB = 00 || BT || PS || 00 || D . 
        // See https://tools.ietf.org/html/rfc2313 for more info.

        u32 keyBytesLen = Math:ceil(getKeyLength() / 8.0);

        if(data == null)
            return null;

        if((data.length()+11) > keyBytesLen)
            return null; // cannot encrypt more data bytes (+11 bytes block format overhead) than key length
    
        u8[] eb(keyBytesLen); // 11 bytes is the minimum for padding and also relatively universal
        eb[0] = 0; // The leading 00 octet ensures that the encryption block, converted to an integer, is less than the modulus.
        eb[1] = 1; // PKCS#1 defines three block formats, 00, 01, and 02. 01 and 02 differ only in the padding values (FF vs random bytes). 01 is the defacto standard for signatures.
        u32 numPadBytes = keyBytesLen - (data.length() + 3);
        for(u32 r=0; r<numPadBytes; r++)
        {
            eb[2 + r] = 0xFF;
        }
        eb[2 + numPadBytes] = 0; // must be zero to indicate end of padding

        for(u64 a=0; a<data.length(); a++)
        {
            eb[2 + numPadBytes + 1 + a] = data[a];
        }

        // sign eb and return
        BigInt encryptedInt();
        encryptedInt.setFromBytesBigEndian(eb); // must be set big endian so that 0x00 byte is most significant ensuring N bits fits into RSA key length
        encryptedInt.moduloPower(d, n);

        u8[] result = RSAPublicKey:leftPadZeros(encryptedInt.asBytesBigEndian(), keyBytesLen); // BigInt doesn't return leading zeroes, so we have to pad manually from left

        return result;
    }

    // Read RSA private key from PKCS#1 binary DER-encoded file. Only reads one key per file.
    shared RSAKey readPKCS1(ByteArray derFile)
    {
        String<u8> errorsStr();
        return readPKCS1(derFile, errorsStr);
    }

    // Read RSA private key from PKCS#1 binary DER-encoded file. Only reads one key per file.
    shared RSAKey readPKCS1(ByteArray derFile, String<u8> errorsOut)
    {
        ASN1 asn();
        if(asn.parse(derFile) == false)
        {
            errorsOut.append("ERROR: Failed to parse DER file.\n" + asn.parseErrors);
            return null;
        }

        //Log:log("RSAKey.readPKCS1() asn: \n" + asn.toString());

        // root node must be sequence
        ASN1Node rootNode = asn.rootNode;

        if(rootNode == null)
        {
            errorsOut.append("ERROR: No root node after parsing DER file.\n");
            return null;
        }

        // our ASN1 implementation has TAG_ROOT for root normally, the real first node is it's children[0]
        if(rootNode.tag != ASN1:TAG_SEQUENCE) 
        {
            // should be one child which is TAG_SEQUENCE
            if(rootNode.children.size() > 0)
            {
                rootNode = rootNode.children[0];
            }
            else
            {
                errorsOut.append("ERROR: Root node is not a sequence and has no children.\n");
                return null;
            }

            if(rootNode.tag != ASN1:TAG_SEQUENCE)
            {
                errorsOut.append("ERROR: Root node is not a sequence!.\n");
                return null;
            }
        }

        if(rootNode.children.size() < 9) 
        {
            errorsOut.append("ERROR: Root of parsed DER file has too few children.\n");
            return null;
        }

        /*
            Version ::= INTEGER { two-prime(0), multi(1) }
            (CONSTRAINED BY
            {-- version must be multi if otherPrimeInfos present --})

        RSAPrivateKey ::= SEQUENCE {
            version           Version,
            modulus           INTEGER,  -- n
            publicExponent    INTEGER,  -- e
            privateExponent   INTEGER,  -- d
            prime1            INTEGER,  -- p
            prime2            INTEGER,  -- q
            exponent1         INTEGER,  -- d mod (p-1)
            exponent2         INTEGER,  -- d mod (q-1)
            coefficient       INTEGER,  -- (inverse of q) mod p
            otherPrimeInfos   OtherPrimeInfos OPTIONAL
        }
        */

        // skip version node
        ASN1Node versionNode         = rootNode.children[0];
        ASN1Node modulusNode         = rootNode.children[1];
        ASN1Node publicExponentNode  = rootNode.children[2];
        ASN1Node privateExponentNode = rootNode.children[3];
        ASN1Node prime1Node          = rootNode.children[4];
        ASN1Node prime2Node          = rootNode.children[5];
        ASN1Node exponent1Node       = rootNode.children[6];
        ASN1Node exponent2Node       = rootNode.children[7];
        ASN1Node coefficientNode     = rootNode.children[8];

        // An RSA private key must define a public exponent e, and two primes p and q. Everything else can be reasonably
        // calculated from these three values.
        BigInt n1   = modulusNode.decodeInteger();
        BigInt e1   = publicExponentNode.decodeInteger();
        BigInt d1   = privateExponentNode.decodeInteger();
        BigInt p1   = prime1Node.decodeInteger();
        BigInt q1   = prime2Node.decodeInteger();
        BigInt q1   = prime2Node.decodeInteger();
        BigInt crtP = exponent1Node.decodeInteger();
        BigInt crtQ = exponent2Node.decodeInteger();
        BigInt crtC = coefficientNode.decodeInteger();
        
        if(e1.isZero() == true || e1.isNegative() == true)
        {
            errorsOut.append("Private key public exponent E is clearly not valid (zero/negative).");
            return null;
        }

        if(p1.isZero() == true || p1.isNegative() == true)
        {
            errorsOut.append("Private key Prime P is clearly not valid (zero/negative).");
            return null;
        }

        if(q1.isZero() == true || q1.isNegative() == true)
        {
            errorsOut.append("Private key Prime Q is clearly not valid (zero/negative).");
            return null;
        }

        RSAKey key(p1, q1, e1);

        if(key.n.equals(n1) == false)
        {
            errorsOut.append("Private key N (public modulus, AKA public key) does not compute to p * q!");
            return null;
        }

        if(key.d.equals(d1) == false)
        {
            errorsOut.append("Private key D does not computed value!");
            return null;
        }

        if(key.d.equals(d1) == false)
        {
            errorsOut.append("Private key D does not computed value!");
            return null;
        }

        if(key.calcCRTExpP().equals(crtP) == false)
        {
            errorsOut.append("Private key CRT_P does not computed value!");
            return null;
        }

        if(key.calcCRTExpQ().equals(crtQ) == false)
        {
            errorsOut.append("Private key CRT_Q does not computed value!");
            return null;
        }

        if(key.calcCRTCoefficient().equals(crtC) == false)
        {
            errorsOut.append("Private key CRT_C does not computed value!");
            return null;
        }

        return key;
    }

    // Read RSA private key from PKCS#1 PEM text base64-encoded. Only reads one key per file.
    shared RSAKey readPKCS1(String<u8> base64Text)
    {
        String<u8> errorsStr();
        return readPKCS1(base64Text, errorsStr);
    }

    // Read RSA private key from PKCS#1 PEM text base64-encoded. Only reads one key per file.
    shared RSAKey readPKCS1(String<u8> base64Text, String<u8> errorsOut)
    {
        ArrayList<ByteArray> derFiles = decodePKCS1PEMKeys(base64Text);
        if(derFiles.size() == 0)
        {
            errorsOut.append("ERROR: No certificates found.\n");
            return null;
        }

        if(derFiles.size() > 1)
        {
            errorsOut.append("ERROR: More than one certificate found. Use readCertificates() for multiple certificates in a single text file.\n");
            return null;
        }

        return readPKCS1(derFiles[0], errorsOut);
    }

    // For text files of certificates (in base64 encoding). Returns all private key files as ASN.1 DER binary files.
    shared ArrayList<ByteArray> decodePKCS1PEMKeys(String<u8> textIn)
    {
        /* Example RSA Private key PEM
        -----BEGIN RSA PRIVATE KEY-----
        MIIEpQIBAAKCAQEAwHoymP4LUWao6ji8emUxCIwBvl9ilIdGEDpKPhQ/44hzBxdu
        aGVlEqj1c+8UDgZnRZ/vG6j5x483Pn4qSQ7awPwV9PUDTNi0c5vfHT/z5MnqBTKG
        SzX/Da28Czs2QJEzMnrmWKkEZT6zbM4JWPwCudg636pts8O7ed1MeptW7ZpuAyXI
        o2hJH5FEB7b8h9VXLA8abmFJOIWssWHl8dozMKXGOCT+skYgDvgWzY4/HeMe80lm
        cxJHqnvvhH0r4Y18/rom0BUnXhC/EwNtjQO66mHJO/GhMq4aypGz8naAEoa0qH1t
        +xVoqF/Qa7TRyJF9/55V21H3PjlGdojllvwgiwIDAQABAoIBAQCIedzImFFkHXul
        4CbcTkXvPn66Ap4+nJA0T3B3Bhqq9gRBwf56LXL2QTERTDMXIrk1KAr9vNmnA0hz
        mjfXZ536eoQDFXuKkJma46nW7pK75eN2XfXU/Gtlwot0Fz8Hly0LHROZR/ai50uH
        2avNGZvBNK3CC/EPJrkW1rA0u1Ju0/diOSONQBxxgSG1JkyLjtMsDziUCLsX6TdW
        P6R2UVe9l7ofMvInJo45NQTbS5uWASaW/XC3RdyDX0UgYqZ6lyQBXdCq1NWVLeo9
        8Mc68kOyCK4KaovsELh65t84gFUlKuznPN16N1cbyIaP7wPFyPrgtEvzpI/DUyqw
        OraXI9qRAoGBAN++za9tskzv4dSWyNmO+3uvrDj3Woe5dZWGKzq9Kza5S6so45Je
        cKKvzMmCeTo4itbpaNRg6G5nmMOul2QMM7X78LvPTCiPVlZ9WzlBVW12SwALsNB/
        wg7hI0LeSYi8JZlImlEkg5IuhuKVxSfTwCDQznglrBBXaiqHVULIsR7TAoGBANw5
        d2WJGQMO5GuRFLwUkgxj7e5doMK3P3jzrUv1xttJGz/AEW/5U89nHgv7Vgg1ffAf
        2N7c+G2c+PkqSrwTZUyNjiKJ+s+3Uq6M4YqhI9h5AatXBcuAIW6FOEl+hljP0J19
        7HwwNsQTNz9gy0oM5jTiyqlyD2ofTJgbLaBnmhRpAoGBAIGyE35+It2wK4LUiMZ7
        uFEBCt7WmxaTrZIn/MUGxJbrH+6uPAQrVDUpnJauV+Ekx24+THLXXcQprwa3HLB0
        1kDGMsxbJHVaaRyne4qb0Y4rBNyY6jxh4jZH0O3A9nUZQt4wlKs2dEH3UF7lnCwy
        9WrQPu6sP6oVUcgnPIgC15DbAoGBANagTwOutKitV+KZl4qhxaC7t0QrDaUXMI3x
        doBkPPSz8BGWX6gwZwToK3lj7vm7IEzozNSOqLMzW9aB6CoaAQy1nMN+k+jicntZ
        I+qWlze+3uicvDITYwGyZiQCYm6lwlvrQJHb71PyolJrRFSb87OxH/A6EFnNvTk0
        q6f7sEeZAoGANulEMg6Cvy1ILpINoAUEGimIroeAD0wSKAwcDwZGKc1pJBgeWeKC
        erZpD8wk/1xXtznVFbv+nHTbHEFYB66d/z22pUx0ARSxo/OTitVuRy8cIGFZn5Lp
        6E48jL7KMRy2gcu7b+oi2ajOeEDquuKit22/1lr3STonnUXRfc9RatM=
        -----END RSA PRIVATE KEY-----
        */

        ArrayList<ByteArray> certDERFiles();

        i64 nextCertStartIndex = textIn.findNext("BEGIN RSA PRIVATE KEY", 0);
        i64 nextCertEndIndex   = 0;
        while(nextCertStartIndex != -1)
        {
            nextCertStartIndex = textIn.findNext(Chars:NEW_LINE, nextCertStartIndex);
            nextCertEndIndex   = textIn.findNext("END RSA PRIVATE KEY", nextCertStartIndex);

            if(nextCertEndIndex == -1)
                return certDERFiles;

            nextCertEndIndex = textIn.findPrev(Chars:NEW_LINE, nextCertEndIndex);

            String<u8> certBase64Str = textIn.subString(nextCertStartIndex, nextCertEndIndex-1);
            certBase64Str.trimWhitespace();

            ByteArray derFile = FileSystem:decodeBytesFromBase64(certBase64Str);
            if(derFile != null)
                certDERFiles.add(derFile);

            nextCertStartIndex = textIn.findNext("BEGIN RSA PRIVATE KEY", nextCertEndIndex);
        }

        return certDERFiles;
    }

    // Write RSA private key to PKCS#1 binary DER file.
    ByteArray writePKCS1()
    {
        bool primitive = true;
        bool constructed = false;

        /*
            Version ::= INTEGER { two-prime(0), multi(1) }
            (CONSTRAINED BY
            {-- version must be multi if otherPrimeInfos present --})

        RSAPrivateKey ::= SEQUENCE {
            version           Version,
            modulus           INTEGER,  -- n
            publicExponent    INTEGER,  -- e
            privateExponent   INTEGER,  -- d
            prime1            INTEGER,  -- p
            prime2            INTEGER,  -- q
            exponent1         INTEGER,  -- d mod (p-1)
            exponent2         INTEGER,  -- d mod (q-1)
            coefficient       INTEGER,  -- (inverse of q) mod p
            otherPrimeInfos   OtherPrimeInfos OPTIONAL
        }
        */

        // Construct ASN1 tree of nodes that represents file.
        ASN1Node seqNode(ASN1:TAG_SEQUENCE, constructed, ASN1:CLASS_UNIVERSAL);

        ASN1Node versionNode(BigInt(0)); // version 0 is all we support
        seqNode.addChild(versionNode);

        ASN1Node modulusNode(BigInt(this.n));
        seqNode.addChild(modulusNode);

        ASN1Node pubExpNode(BigInt(this.e));
        seqNode.addChild(pubExpNode);

        ASN1Node privExpNode(BigInt(this.d));
        seqNode.addChild(privExpNode);

        ASN1Node prime1Node(BigInt(this.p));
        seqNode.addChild(prime1Node);

        ASN1Node prime2Node(BigInt(this.q));
        seqNode.addChild(prime2Node);

        ASN1Node e1Node(calcCRTExpP()); // we don't use, but we calculate for the file
        seqNode.addChild(e1Node);

        ASN1Node e2Node(calcCRTExpQ()); // we don't use, but we calculate for the file
        seqNode.addChild(e2Node);

        ASN1Node coefficientNode(calcCRTCoefficient()); // we don't use, but we calculate for the file
        seqNode.addChild(coefficientNode);

        ByteArray b = seqNode.write();
        return b;
    }

    // Write RSA private key to PKCS#1 PEM formatted text file.
    String<u8> writePKCS1Text()
    {
        ByteArray derFile = writePKCS1();

        String<u8> base64 = FileSystem:encodeBytesToBase64(derFile);

        String<u8> base64Formatted();
        while(true)
        {
            if(base64.length() <= 80)
            {
                base64Formatted.append(base64);
                base64Formatted.append("\n");
                break;
            }
            else
            {
                String<u8> lineStr = base64.subString(0, 79);
                base64.remove(0, 79); // 79 inclusive index
                base64Formatted.append(lineStr);
                base64Formatted.append("\n");
            }
        }

        String<u8> text();
        text.append("-----BEGIN RSA PRIVATE KEY-----\n");
        text.append(base64Formatted);
        text.append("-----END RSA PRIVATE KEY-----\n");

        return text;
    }

    // For chinese remainder thereom (CRT) usage.
    BigInt calcCRTExpP()
    {
        // d mod (p-1)
        BigInt ex(this.d);
        BigInt temp1(p);
        temp1.subtract(BigInt(1));
        ex.modulo(temp1);
        return ex;
    }

    // For chinese remainder thereom (CRT) usage.
    BigInt calcCRTExpQ()
    {
        // d mod (q-1)
        BigInt ex(this.d);
        BigInt temp1(q);
        temp1.subtract(BigInt(1));
        ex.modulo(temp1);
        return ex;
    }

    // For chinese remainder thereom (CRT) usage.
    BigInt calcCRTCoefficient()
    {
        // (inverse of q) mod p
        BigInt qInv(q);
        qInv.modInv(p);
        return qInv;
    }
}