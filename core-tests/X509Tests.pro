////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class ASN1TypesTests implements IUnitTest
{
	void run()
    {
        //u8[] oidBytes(0x2B, 0x06, 0x01, 0x04, 0x01, 0x82, 0x37, 0x15, 0x14); // decodes to "1.3.6.1.4.1.311.21.20"
        ASN1Node strNode(ASN1:TAG_OBJECT_IDENTIFIER, u8[](0x2B, 0x06, 0x01, 0x04, 0x01, 0x82, 0x37, 0x15, 0x14));
        String<u8> oidStr = strNode.decodeOIDToString();
        test(oidStr != null);
        test(oidStr.length() > 0);
        test(oidStr.compare("1.3.6.1.4.1.311.21.20") == true);

        ASN1Node oidNode2(ASN1:TAG_OBJECT_IDENTIFIER, u8[](0x01, 0x02));
        oidNode2.encodeOIDFromString("1.2.3.45678.9");
        String<u8> oidStr2 = oidNode2.decodeOIDToString();
        test(oidStr2.compare("1.2.3.45678.9") == true);

        ASN1Node nodeA(BigInt(3580));
        BigInt intA = nodeA.decodeInteger();
        test(intA != null);
        test(intA.asI64() == 3580);

        ASN1Node nodeB(BigInt(65537));
        BigInt intB = nodeB.decodeInteger();
        test(intB != null);
        test(intB.asI64() == 65537);
    }
}

class ASN1_CERT_Tests implements IUnitTest
{
	void run()
    {
        String<u8> certBase64 = "MIIC2jCCAkMCAg38MA0GCSqGSIb3DQEBBQUAMIGbMQswCQYDVQQGEwJKUDEOMAwG" +
                                "A1UECBMFVG9reW8xEDAOBgNVBAcTB0NodW8ta3UxETAPBgNVBAoTCEZyYW5rNERE" +
                                "MRgwFgYDVQQLEw9XZWJDZXJ0IFN1cHBvcnQxGDAWBgNVBAMTD0ZyYW5rNEREIFdl" +
                                "YiBDQTEjMCEGCSqGSIb3DQEJARYUc3VwcG9ydEBmcmFuazRkZC5jb20wHhcNMTIw" +
                                "ODIyMDUyNzQxWhcNMTcwODIxMDUyNzQxWjBKMQswCQYDVQQGEwJKUDEOMAwGA1UE" +
                                "CAwFVG9reW8xETAPBgNVBAoMCEZyYW5rNEREMRgwFgYDVQQDDA93d3cuZXhhbXBs" +
                                "ZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC0z9FeMynsC8+u" +
                                "dvX+LciZxnh5uRj4C9S6tNeeAlIGCfQYk0zUcNFCoCkTknNQd/YEiawDLNbxBqut" +
                                "bMDZ1aarys1a0lYmUeVLCIqvzBkPJTSQsCopQQ9V8WuT252zzNzs68dVGNdCJd5J" +
                                "NRQykpwexmnjPPv0mvj7i8XgG379TyW6P+WWV5okeUkXJ9eJS2ouDYdR2SM9BoVW" +
                                "+FgxDu6BmXhozW5EfsnajFp7HL8kQClI0QOc79yuKl3492rH6bzFsFn2lfwWy9ic" +
                                "7cP8EpCTeFp1tFaD+vxBhPZkeTQ1HKx6hQ5zeHIB5ySJJZ7af2W8r4eTGYzbdRW2" +
                                "4DDHCPhZAgMBAAEwDQYJKoZIhvcNAQEFBQADgYEAQMv+BFvGdMVzkQaQ3/+2noVz" +
                                "/uAKbzpEL8xTcxYyP3lkOeh4FoxiSWqy5pGFALdPONoDuYFpLhjJSZaEwuvjI/Tr" +
                                "rGhLV1pRG9frwDFshqD2Vaj4ENBCBh6UpeBop5+285zQ4SI7q4U9oSebUDJiuOx6" +
                                "+tZ9KynmrbJpTSi0+BM="; // RSA 2048 bit

        ByteArray certDER = FileSystem:decodeBytesFromBase64(certBase64);
        test(certDER != null);
        if(certDER == null)
            return;

        ASN1 asn1Cert();
        test(asn1Cert.parse(certDER) == true);
        test(asn1Cert.rootNode != null);

        ASN1Node rootNode = asn1Cert.rootNode;
        if(rootNode == null)
            return;

        test(rootNode.tag == ASN1:TAG_ROOT);
        test(rootNode.children != null);
        test(rootNode.children.size() == 1);

        ASN1Node certContainerNode = rootNode.children[0];
        test(certContainerNode.tag == ASN1:TAG_SEQUENCE);
        test(certContainerNode.primitive == false);
        test(certContainerNode.children != null);
        test(certContainerNode.children.size() == 3); // TBS record (certificate), signing algorithm, and signature bit string

        //Log:log("ASN1Tests toString() = \n" + asn1Cert.toString() + "\n\n");
    }
}

class X509_RSA_V1_Tests implements IUnitTest
{
	void run()
    {
        String<u8> certBase64 = "-----BEGIN CERTIFICATE-----\n" +
                                "MIIC2jCCAkMCAg38MA0GCSqGSIb3DQEBBQUAMIGbMQswCQYDVQQGEwJKUDEOMAwG" +
                                "A1UECBMFVG9reW8xEDAOBgNVBAcTB0NodW8ta3UxETAPBgNVBAoTCEZyYW5rNERE" +
                                "MRgwFgYDVQQLEw9XZWJDZXJ0IFN1cHBvcnQxGDAWBgNVBAMTD0ZyYW5rNEREIFdl" +
                                "YiBDQTEjMCEGCSqGSIb3DQEJARYUc3VwcG9ydEBmcmFuazRkZC5jb20wHhcNMTIw" +
                                "ODIyMDUyNzQxWhcNMTcwODIxMDUyNzQxWjBKMQswCQYDVQQGEwJKUDEOMAwGA1UE" +
                                "CAwFVG9reW8xETAPBgNVBAoMCEZyYW5rNEREMRgwFgYDVQQDDA93d3cuZXhhbXBs" +
                                "ZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC0z9FeMynsC8+u" +
                                "dvX+LciZxnh5uRj4C9S6tNeeAlIGCfQYk0zUcNFCoCkTknNQd/YEiawDLNbxBqut" +
                                "bMDZ1aarys1a0lYmUeVLCIqvzBkPJTSQsCopQQ9V8WuT252zzNzs68dVGNdCJd5J" +
                                "NRQykpwexmnjPPv0mvj7i8XgG379TyW6P+WWV5okeUkXJ9eJS2ouDYdR2SM9BoVW" +
                                "+FgxDu6BmXhozW5EfsnajFp7HL8kQClI0QOc79yuKl3492rH6bzFsFn2lfwWy9ic" +
                                "7cP8EpCTeFp1tFaD+vxBhPZkeTQ1HKx6hQ5zeHIB5ySJJZ7af2W8r4eTGYzbdRW2" +
                                "4DDHCPhZAgMBAAEwDQYJKoZIhvcNAQEFBQADgYEAQMv+BFvGdMVzkQaQ3/+2noVz" +
                                "/uAKbzpEL8xTcxYyP3lkOeh4FoxiSWqy5pGFALdPONoDuYFpLhjJSZaEwuvjI/Tr" +
                                "rGhLV1pRG9frwDFshqD2Vaj4ENBCBh6UpeBop5+285zQ4SI7q4U9oSebUDJiuOx6" +
                                "+tZ9KynmrbJpTSi0+BM=\n-----END CERTIFICATE-----"; // RSA 2048 bit, signed RSA_SH1

        X509Certificate cert();
        String<u8> certErrors();
        bool readCertSuccess = cert.readCertificate(certBase64, certErrors);
        test(readCertSuccess == true);

        if(readCertSuccess == false || certErrors.length() > 0)
        {
            Log:log("X509_RSA_Tests read cert errors: \n" + certErrors);
            return;
        }

        test(cert.certVersion == X509Certificate:CERT_VERSION_1);

        test(cert.signatureType == X509Certificate:SIGNATURE_TYPE_RSA_SHA1);
        test(cert.signatureBytes != null);
        test(cert.signatureBytes.numUsed >= 128); // 1024 bit signature (RSA)

        test(cert.serialNumber != null);
        test(cert.serialNumber.asI64() == 3580);

        test(cert.issuer != null);
        if(cert.issuer == null)
            return;
        test(cert.issuer.domain.compare("Frank4DD Web CA") == true);
        test(cert.issuer.country.compare("JP") == true);
        test(cert.issuer.state.compare("Tokyo") == true);
        test(cert.issuer.city.compare("Chuo-ku") == true);
        test(cert.issuer.org.compare("Frank4DD") == true);
        test(cert.issuer.orgUnit.compare("WebCert Support") == true);

        test(cert.subject != null);
        if(cert.subject == null)
            return;
        test(cert.subject.domain.compare("www.example.com") == true);
        test(cert.subject.country.compare("JP") == true);
        test(cert.subject.state.compare("Tokyo") == true);
        test(cert.subject.org.compare("Frank4DD") == true);

        test(cert.startDate != null);
        if(cert.startDate == null)
            return;
        test(cert.startDate.getYear() == 2012);
        test(cert.startDate.getMonth() == 8);
        test(cert.startDate.getDay() == 22);

        test(cert.expiryDate != null);
        if(cert.expiryDate == null)
            return;
        test(cert.expiryDate.getYear() == 2017);
        test(cert.expiryDate.getMonth() == 8);
        test(cert.expiryDate.getDay() == 21);

        String<u8> checkRSAKeyHexStr =
        "b4cfd15e3329ec0bcfae76f5fe2d" +
        "c899c67879b918f80bd4bab4d79e02" +
        "520609f418934cd470d142a0291392" +
        "735077f60489ac032cd6f106abad6c" +
        "c0d9d5a6abcacd5ad2562651e54b08" +
        "8aafcc190f253490b02a29410f55f1" +
        "6b93db9db3ccdcecebc75518d74225" +
        "de49351432929c1ec669e33cfbf49a" +
        "f8fb8bc5e01b7efd4f25ba3fe59657" +
        "9a2479491727d7894b6a2e0d8751d9" +
        "233d068556f858310eee81997868cd" +
        "6e447ec9da8c5a7b1cbf24402948d1" +
        "039cefdcae2a5df8f76ac7e9bcc5b0" +
        "59f695fc16cbd89cedc3fc12909378" +
        "5a75b45683fafc4184f6647934351c" +
        "ac7a850e73787201e72489259eda7f" +
        "65bcaf8793198cdb7515b6e030c708" +
        "f859";
        checkRSAKeyHexStr.toUppercase();

        test(cert.rsaPublicKey != null);
        if(cert.rsaPublicKey == null)
            return;
        test(cert.rsaPublicKey.n != null);
        if(cert.rsaPublicKey.n == null)
            return;
        test(cert.rsaPublicKey.n.toString(16).compare(checkRSAKeyHexStr) == true);
        test(cert.rsaPublicKey.e != null);
        if(cert.rsaPublicKey.e == null)
            return;
        test(cert.rsaPublicKey.e.asI64() == 65537);
    }
}

class X509_RSA_V3_Tests implements IUnitTest
{
	void run()
    {
        String<u8> certBase64 = "-----BEGIN CERTIFICATE-----\n"
        + "MIIGxjCCBa6gAwIBAgIQBcAgGnQs7W9tH3ng2TvxJTANBgkqhkiG9w0BAQsFADBE\n"
        + "MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMR4wHAYDVQQDExVE\n"
        + "aWdpQ2VydCBHbG9iYWwgQ0EgRzIwHhcNMjAwMTIzMDAwMDAwWhcNMjEwMTAxMTIw\n"
        + "MDAwWjBnMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE\n"
        + "BxMHU2VhdHRsZTEZMBcGA1UEChMQQW1hem9uLmNvbSwgSW5jLjEWMBQGA1UEAxMN\n"
        + "d3d3LmFtYXpvbi5jYTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMzm\n"
        + "87U7zZ2KM4MBMZOiOjagX3x6a4TJ4iUto8rdhUCpuEK/PehKh6sRi86LU1zk2J9Y\n"
        + "ndSMwLJiUs/FZ1BYy5JPUEdrrwLf2rtFnFGw80twGCIbCZCYSFdb2WgrLMVeTxvT\n"
        + "d65QoUaw4oAD67Zg2gTvd+gKbTbghyVl7o+zePa1x+ewV73jtkEFLWlWcD5vn/kw\n"
        + "y6X0oLuppMfim34XDR/MKyh4y1eYTAW/xMuEMMEeRfSs2gPiOu3El/1aHvoblptD\n"
        + "qtX/X2DUoVNrok+5gCgD7MUJcXzIInaTxXgyiGzkycfVTnpwhwyF9XmrR93GpTC6\n"
        + "v77jWqUcIEXHxabjvZUCAwEAAaOCA48wggOLMB8GA1UdIwQYMBaAFCRuKy3QapJR\n"
        + "USVpAaqaR6aJ50AgMB0GA1UdDgQWBBTh+VEXb2tVmFWq/52qDOK0vj7LRjCByQYD\n"
        + "VR0RBIHBMIG+ghltYXRjaC5hbWF6b25icm93c2VyYXBwLmNhgiNwLW50LXd3dy1h\n"
        + "bWF6b24tY2Eta2FsaWFzLmFtYXpvbi5jYYIjcC15My13d3ctYW1hem9uLWNhLWth\n"
        + "bGlhcy5hbWF6b24uY2GCI3AteW8td3d3LWFtYXpvbi1jYS1rYWxpYXMuYW1hem9u\n"
        + "LmNhghBzdGF0aWMuYW1hem9uLmNhgg13d3cuYW1hem9uLmNhghF3d3cuY2RuLmFt\n"
        + "YXpvbi5jYTAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsG\n"
        + "AQUFBwMCMHcGA1UdHwRwMG4wNaAzoDGGL2h0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv\n"
        + "bS9EaWdpQ2VydEdsb2JhbENBRzIuY3JsMDWgM6Axhi9odHRwOi8vY3JsNC5kaWdp\n"
        + "Y2VydC5jb20vRGlnaUNlcnRHbG9iYWxDQUcyLmNybDBMBgNVHSAERTBDMDcGCWCG\n"
        + "SAGG/WwBATAqMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20v\n"
        + "Q1BTMAgGBmeBDAECAjB0BggrBgEFBQcBAQRoMGYwJAYIKwYBBQUHMAGGGGh0dHA6\n"
        + "Ly9vY3NwLmRpZ2ljZXJ0LmNvbTA+BggrBgEFBQcwAoYyaHR0cDovL2NhY2VydHMu\n"
        + "ZGlnaWNlcnQuY29tL0RpZ2lDZXJ0R2xvYmFsQ0FHMi5jcnQwCQYDVR0TBAIwADCC\n"
        + "AQQGCisGAQQB1nkCBAIEgfUEgfIA8AB3APZclC/RdzAiFFQYCDCUVo7jTRMZM7/f\n"
        + "DC8gC8xO8WTjAAABb9SoIuAAAAQDAEgwRgIhAMpTBTYg3PamIVxRYjkuMG/6VHM+\n"
        + "3vcTtJh7uvSvEXtUAiEAhTMEvuVmQsd3OEjxbVbGx8aua01mbSMtYkFQDwPPrDIA\n"
        + "dQBc3EOS/uarRUSxXprUVuYQN/vV+kfcoXOUsl7m9scOygAAAW/UqCMbAAAEAwBG\n"
        + "MEQCIC1sYr8T5T41iCXnrVY4JAYzlZL+T+NXp5ctN9z+vPSzAiBdHuVEEfmmPGQ/\n"
        + "RFIIA9zOwWkZFUah+p95L+xKIwo0RDANBgkqhkiG9w0BAQsFAAOCAQEAem3MGP97\n"
        + "a5wjzr4t8zy9+ghtBS25w9LiNJ8DZAsDS5Bomep5LXD/mY7pbs7QOLH5kBcujGFQ\n"
        + "epE4ftct9dnppPTRGLxJaRvazCQoG2NpnuYfkiH1hDyJLTDSqGQ6AGm8L9r+dsI9\n"
        + "iwBVcBfLeH0CX9ltYrPIXzm7Oa9+MdKpbrP0mFhOr+s28I4pJJUJlj8w0JgbYj0t\n"
        + "UTZAJnx9eSsvHT7I8QYkdzUChCA5iqpzPjJua5PPMUt8lzGmAUGSAnL3beYNmZXj\n"
        + "+nWyjhNuIYVnLAOKVKq+fdsdrxujexed0903/JgKDS2Tf6s20Ywr3c86ebZ5uC8x\n"
        + "zdt2nB1Vg/6Dmg==\n"
        + "-----END CERTIFICATE-----"; // X509, version 3, for Amazon.ca, RSA 2048 bit, signed RSA_SH256

        /*
        -----BEGIN CERTIFICATE-----
        MIIGxjCCBa6gAwIBAgIQBcAgGnQs7W9tH3ng2TvxJTANBgkqhkiG9w0BAQsFADBE
        MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMR4wHAYDVQQDExVE
        aWdpQ2VydCBHbG9iYWwgQ0EgRzIwHhcNMjAwMTIzMDAwMDAwWhcNMjEwMTAxMTIw
        MDAwWjBnMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
        BxMHU2VhdHRsZTEZMBcGA1UEChMQQW1hem9uLmNvbSwgSW5jLjEWMBQGA1UEAxMN
        d3d3LmFtYXpvbi5jYTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMzm
        87U7zZ2KM4MBMZOiOjagX3x6a4TJ4iUto8rdhUCpuEK/PehKh6sRi86LU1zk2J9Y
        ndSMwLJiUs/FZ1BYy5JPUEdrrwLf2rtFnFGw80twGCIbCZCYSFdb2WgrLMVeTxvT
        d65QoUaw4oAD67Zg2gTvd+gKbTbghyVl7o+zePa1x+ewV73jtkEFLWlWcD5vn/kw
        y6X0oLuppMfim34XDR/MKyh4y1eYTAW/xMuEMMEeRfSs2gPiOu3El/1aHvoblptD
        qtX/X2DUoVNrok+5gCgD7MUJcXzIInaTxXgyiGzkycfVTnpwhwyF9XmrR93GpTC6
        v77jWqUcIEXHxabjvZUCAwEAAaOCA48wggOLMB8GA1UdIwQYMBaAFCRuKy3QapJR
        USVpAaqaR6aJ50AgMB0GA1UdDgQWBBTh+VEXb2tVmFWq/52qDOK0vj7LRjCByQYD
        VR0RBIHBMIG+ghltYXRjaC5hbWF6b25icm93c2VyYXBwLmNhgiNwLW50LXd3dy1h
        bWF6b24tY2Eta2FsaWFzLmFtYXpvbi5jYYIjcC15My13d3ctYW1hem9uLWNhLWth
        bGlhcy5hbWF6b24uY2GCI3AteW8td3d3LWFtYXpvbi1jYS1rYWxpYXMuYW1hem9u
        LmNhghBzdGF0aWMuYW1hem9uLmNhgg13d3cuYW1hem9uLmNhghF3d3cuY2RuLmFt
        YXpvbi5jYTAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsG
        AQUFBwMCMHcGA1UdHwRwMG4wNaAzoDGGL2h0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
        bS9EaWdpQ2VydEdsb2JhbENBRzIuY3JsMDWgM6Axhi9odHRwOi8vY3JsNC5kaWdp
        Y2VydC5jb20vRGlnaUNlcnRHbG9iYWxDQUcyLmNybDBMBgNVHSAERTBDMDcGCWCG
        SAGG/WwBATAqMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20v
        Q1BTMAgGBmeBDAECAjB0BggrBgEFBQcBAQRoMGYwJAYIKwYBBQUHMAGGGGh0dHA6
        Ly9vY3NwLmRpZ2ljZXJ0LmNvbTA+BggrBgEFBQcwAoYyaHR0cDovL2NhY2VydHMu
        ZGlnaWNlcnQuY29tL0RpZ2lDZXJ0R2xvYmFsQ0FHMi5jcnQwCQYDVR0TBAIwADCC
        AQQGCisGAQQB1nkCBAIEgfUEgfIA8AB3APZclC/RdzAiFFQYCDCUVo7jTRMZM7/f
        DC8gC8xO8WTjAAABb9SoIuAAAAQDAEgwRgIhAMpTBTYg3PamIVxRYjkuMG/6VHM+
        3vcTtJh7uvSvEXtUAiEAhTMEvuVmQsd3OEjxbVbGx8aua01mbSMtYkFQDwPPrDIA
        dQBc3EOS/uarRUSxXprUVuYQN/vV+kfcoXOUsl7m9scOygAAAW/UqCMbAAAEAwBG
        MEQCIC1sYr8T5T41iCXnrVY4JAYzlZL+T+NXp5ctN9z+vPSzAiBdHuVEEfmmPGQ/
        RFIIA9zOwWkZFUah+p95L+xKIwo0RDANBgkqhkiG9w0BAQsFAAOCAQEAem3MGP97
        a5wjzr4t8zy9+ghtBS25w9LiNJ8DZAsDS5Bomep5LXD/mY7pbs7QOLH5kBcujGFQ
        epE4ftct9dnppPTRGLxJaRvazCQoG2NpnuYfkiH1hDyJLTDSqGQ6AGm8L9r+dsI9
        iwBVcBfLeH0CX9ltYrPIXzm7Oa9+MdKpbrP0mFhOr+s28I4pJJUJlj8w0JgbYj0t
        UTZAJnx9eSsvHT7I8QYkdzUChCA5iqpzPjJua5PPMUt8lzGmAUGSAnL3beYNmZXj
        +nWyjhNuIYVnLAOKVKq+fdsdrxujexed0903/JgKDS2Tf6s20Ywr3c86ebZ5uC8x
        zdt2nB1Vg/6Dmg==
        -----END CERTIFICATE-----
        */

        //Log:log("X509_RSA_V3_Tests Amazon.ca certificate: \n" + certBase64);

        X509Certificate cert();
        String<u8> certErrors();
        bool readCertSuccess = cert.readCertificate(certBase64, certErrors);
        test(readCertSuccess == true);

        if(readCertSuccess == false || certErrors.length() > 0)
        {
            Log:log("X509_RSA_V3_Tests read cert errors: \n" + certErrors);
            return;
        }

        //Log:log("X509_RSA_V3_Tests cert.toString()\n" + cert.toString() + "\n");

        test(cert.certVersion == X509Certificate:CERT_VERSION_3);

        String<u8> rawSignatureHexBytes = 
        "7a6dcc18ff7b6b9c23cebe2df33cbdfa086d" +
        "052db9c3d2e2349f03640b034b906899ea79" +
        "2d70ff998ee96eced038b1f990172e8c6150" +
        "7a91387ed72df5d9e9a4f4d118bc49691bda" +
        "cc24281b63699ee61f9221f5843c892d30d2" +
        "a8643a0069bc2fdafe76c23d8b00557017cb" +
        "787d025fd96d62b3c85f39bb39af7e31d2a9" +
        "6eb3f498584eafeb36f08e29249509963f30" +
        "d0981b623d2d513640267c7d792b2f1d3ec8" +
        "f106247735028420398aaa733e326e6b93cf" +
        "314b7c9731a60141920272f76de60d9995e3" +
        "fa75b28e136e2185672c038a54aabe7ddb1d" +
        "af1ba37b179dd3dd37fc980a0d2d937fab36" +
        "d18c2bddcf3a79b679b82f31cddb769c1d55" +
        "83fe839a";
        rawSignatureHexBytes.toUppercase();

        test(cert.signatureType == X509Certificate:SIGNATURE_TYPE_RSA_SHA256);
        test(cert.signatureBytes != null);
        test(cert.signatureBytes.numUsed == 256); // 2048 bit signature (RSA)

        String<u8> certSignHexStr = cert.signatureBytes.toHexString(false);
        test(certSignHexStr.compare(rawSignatureHexBytes) == true);
        //Log:log("X509_RSA_V3_Tests - certSign:\n" + certSignHexStr + "\n");
        //Log:log("X509_RSA_V3_Tests - rwawSign:\n" + rawSignatureHexBytes + "\n");

        test(cert.serialNumber != null);
        test(cert.serialNumber.toString(16).compare("5C0201A742CED6F6D1F79E0D93BF125") == true);

        test(cert.issuer != null);
        if(cert.issuer == null)
            return;
        test(cert.issuer.domain.compare("DigiCert Global CA G2") == true);
        test(cert.issuer.country.compare("US") == true);
        test(cert.issuer.org.compare("DigiCert Inc") == true);

        test(cert.subject != null);
        if(cert.subject == null)
            return;
        test(cert.subject.domain.compare("www.amazon.ca") == true);
        test(cert.subject.country.compare("US") == true);
        test(cert.subject.state.compare("Washington") == true);
        test(cert.subject.city.compare("Seattle") == true);
        test(cert.subject.org.compare("Amazon.com, Inc.") == true);

        test(cert.startDate != null);
        if(cert.startDate == null)
            return;
        test(cert.startDate.getYear() == 2020);
        test(cert.startDate.getMonth() == 1);
        test(cert.startDate.getDay() == 23);
        test(cert.startDate.getHour() == 0);
        test(cert.startDate.getMinute() == 0);
        test(cert.startDate.getSecond() == 0);

        test(cert.expiryDate != null);
        if(cert.expiryDate == null)
            return;
        test(cert.expiryDate.getYear() == 2021);
        test(cert.expiryDate.getMonth() == 1);
        test(cert.expiryDate.getDay() == 1);
        test(cert.expiryDate.getHour() == 12);
        test(cert.expiryDate.getMinute() == 0);
        test(cert.expiryDate.getSecond() == 0);

        String<u8> checkRSAKeyHexStr =
        "CCE6F3B53BCD9D8A3383013193A23A36A05F7C7A6B84C9E2252DA3CADD8540A9B842BF3DE84A87AB118BCE8B53" +
        "5CE4D89F589DD48CC0B26252CFC5675058CB924F50476BAF02DFDABB459C51B0F34B7018221B09909848575BD9" +
        "682B2CC55E4F1BD377AE50A146B0E28003EBB660DA04EF77E80A6D36E0872565EE8FB378F6B5C7E7B057BDE3B6" + 
        "41052D6956703E6F9FF930CBA5F4A0BBA9A4C7E29B7E170D1FCC2B2878CB57984C05BFC4CB8430C11E45F4ACDA" +
        "03E23AEDC497FD5A1EFA1B969B43AAD5FF5F60D4A1536BA24FB9802803ECC509717CC8227693C57832886CE4C9" +
        "C7D54E7A70870C85F579AB47DDC6A530BABFBEE35AA51C2045C7C5A6E3BD95";

        test(cert.rsaPublicKey != null);
        if(cert.rsaPublicKey == null)
            return;
        test(cert.rsaPublicKey.n != null);
        if(cert.rsaPublicKey.n == null)
            return;
        test(cert.rsaPublicKey.n.toString(16).compare(checkRSAKeyHexStr) == true);
        test(cert.rsaPublicKey.e != null);
        if(cert.rsaPublicKey.e == null)
            return;
        test(cert.rsaPublicKey.e.asI64() == 65537);

        // extensions
        test(cert.subjectKey != null);
        test(cert.subjectKey.compare(ByteArray(u8[](0xE1, 0xF9, 0x51, 0x17, 0x6F, 0x6B, 0x55, 0x98, 0x55, 0xAA, 0xFF, 0x9D, 0xAA, 0x0C, 0xE2, 0xB4, 0xBE, 0x3E, 0xCB, 0x46))) == true);
    }
}

class X509CertsChainPEMTests implements IUnitTest
{
	void run()
    {
        String<u8> certChainText = "-----BEGIN CERTIFICATE-----\n"
        + "MIIGxjCCBa6gAwIBAgIQBcAgGnQs7W9tH3ng2TvxJTANBgkqhkiG9w0BAQsFADBEMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMR4wHAYDVQQDExVEaWdpQ2VydCBHbG9iYWwgQ0EgRzIwHhcNMjAwMTIzMDAwMDAwWhcNMjEwMTAxMTIwMDAwWjBnMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHU2VhdHRsZTEZMBcGA1UEChMQQW1hem9uLmNvbSwgSW5jLjEWMBQGA1UEAxMNd3d3LmFtYXpvbi5jYTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMzm87U7zZ2KM4MBMZOiOjagX3x6a4TJ4iUto8rdhUCpuEK/PehKh6sRi86LU1zk2J9YndSMwLJiUs/FZ1BYy5JPUEdrrwLf2rtFnFGw80twGCIbCZCYSFdb2WgrLMVeTxvTd65QoUaw4oAD67Zg2gTvd+gKbTbghyVl7o+zePa1x+ewV73jtkEFLWlWcD5vn/kwy6X0oLuppMfim34XDR/MKyh4y1eYTAW/xMuEMMEeRfSs2gPiOu3El/1aHvoblptDqtX/X2DUoVNrok+5gCgD7MUJcXzIInaTxXgyiGzkycfVTnpwhwyF9XmrR93GpTC6v77jWqUcIEXHxabjvZUCAwEAAaOCA48wggOLMB8GA1UdIwQYMBaAFCRuKy3QapJRUSVpAaqaR6aJ50AgMB0GA1UdDgQWBBTh+VEXb2tVmFWq/52qDOK0vj7LRjCByQYDVR0RBIHBMIG+ghltYXRjaC5hbWF6b25icm93c2VyYXBwLmNhgiNwLW50LXd3dy1hbWF6b24tY2Eta2FsaWFzLmFtYXpvbi5jYYIjcC15My13d3ctYW1hem9uLWNhLWthbGlhcy5hbWF6b24uY2GCI3AteW8td3d3LWFtYXpvbi1jYS1rYWxpYXMuYW1hem9uLmNhghBzdGF0aWMuYW1hem9uLmNhgg13d3cuYW1hem9uLmNhghF3d3cuY2RuLmFtYXpvbi5jYTAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMHcGA1UdHwRwMG4wNaAzoDGGL2h0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEdsb2JhbENBRzIuY3JsMDWgM6Axhi9odHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRHbG9iYWxDQUcyLmNybDBMBgNVHSAERTBDMDcGCWCGSAGG/WwBATAqMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BTMAgGBmeBDAECAjB0BggrBgEFBQcBAQRoMGYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTA+BggrBgEFBQcwAoYyaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0R2xvYmFsQ0FHMi5jcnQwCQYDVR0TBAIwADCCAQQGCisGAQQB1nkCBAIEgfUEgfIA8AB3APZclC/RdzAiFFQYCDCUVo7jTRMZM7/fDC8gC8xO8WTjAAABb9SoIuAAAAQDAEgwRgIhAMpTBTYg3PamIVxRYjkuMG/6VHM+3vcTtJh7uvSvEXtUAiEAhTMEvuVmQsd3OEjxbVbGx8aua01mbSMtYkFQDwPPrDIAdQBc3EOS/uarRUSxXprUVuYQN/vV+kfcoXOUsl7m9scOygAAAW/UqCMbAAAEAwBGMEQCIC1sYr8T5T41iCXnrVY4JAYzlZL+T+NXp5ctN9z+vPSzAiBdHuVEEfmmPGQ/RFIIA9zOwWkZFUah+p95L+xKIwo0RDANBgkqhkiG9w0BAQsFAAOCAQEAem3MGP97a5wjzr4t8zy9+ghtBS25w9LiNJ8DZAsDS5Bomep5LXD/mY7pbs7QOLH5kBcujGFQepE4ftct9dnppPTRGLxJaRvazCQoG2NpnuYfkiH1hDyJLTDSqGQ6AGm8L9r+dsI9iwBVcBfLeH0CX9ltYrPIXzm7Oa9+MdKpbrP0mFhOr+s28I4pJJUJlj8w0JgbYj0tUTZAJnx9eSsvHT7I8QYkdzUChCA5iqpzPjJua5PPMUt8lzGmAUGSAnL3beYNmZXj+nWyjhNuIYVnLAOKVKq+fdsdrxujexed0903/JgKDS2Tf6s20Ywr3c86ebZ5uC8xzdt2nB1Vg/6Dmg==\n"
        + "-----END CERTIFICATE-----\n"
        + "-----BEGIN CERTIFICATE-----\n"
        + "MIIEizCCA3OgAwIBAgIQDI7gyQ1qiRWIBAYe4kH5rzANBgkqhkiG9w0BAQsFADBhMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSAwHgYDVQQDExdEaWdpQ2VydCBHbG9iYWwgUm9vdCBHMjAeFw0xMzA4MDExMjAwMDBaFw0yODA4MDExMjAwMDBaMEQxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxHjAcBgNVBAMTFURpZ2lDZXJ0IEdsb2JhbCBDQSBHMjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANNIfL7zBYZdW9UvhU5L4IatFaxhz1uvPmoKR/uadpFgC4przc/cV35gmAvkVNlW7SHMArZagV+Xau4CLyMnuG3UsOcGAngLH1ypmTb+u6wbBfpXzYEQQGfWMItYNdSWYb7QjHqXnxr5IuYUL6nG6AEfq/gmD6yOTSwyOR2Bm40cZbIc22GoiS9g5+vCShjEbyrpEJIJ7RfRACvmfe8EiRROM6GyD5eHn7OgzS+8LOy4g2gxPR/VSpAQGQuBldYpdlH5NnbQtwl6OErXb4y/E3w57bqukPyV93t4CTZedJMeJfD/1K2uaGvG/w/VNfFVbkhJ+Pi474j48V4Rd6rfArMCAwEAAaOCAVowggFWMBIGA1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgGGMDQGCCsGAQUFBwEBBCgwJjAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMHsGA1UdHwR0MHIwN6A1oDOGMWh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEdsb2JhbFJvb3RHMi5jcmwwN6A1oDOGMWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEdsb2JhbFJvb3RHMi5jcmwwPQYDVR0gBDYwNDAyBgRVHSAAMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwHQYDVR0OBBYEFCRuKy3QapJRUSVpAaqaR6aJ50AgMB8GA1UdIwQYMBaAFE4iVCAYlebjbuYP+vq5Eu0GF485MA0GCSqGSIb3DQEBCwUAA4IBAQALOYSR+ZfrqoGvhOlaOJL84mxZvzbIRacxAxHhBsCsMsdaVSnaT0AC9aHesO3ewPj2dZ12uYf+QYB6z13jAMZbAuabeGLJ3LhimnftiQjXS8X9Q9ViIyfEBFltcT8jW+rZ8uckJ2/0lYDblizkVIvP6hnZf1WZUXoOLRg9eFhSvGNoVwvdRLNXSmDmyHBwW4coatc7TlJFGa8kBpJIERqLrqwYElesA8u49L3KJg6nwd3jM+/AVTANlVlOnAM2BvjAjxSZnE0qnsHhfTuvcqdFuhOWKU4Z0BqYBvQ3lBetoxi6PrABDJXWKTUgNX31EGDk92hiHuwZ4STyhxGs6QiA\n"
        + "-----END CERTIFICATE-----\n"
        + "-----BEGIN CERTIFICATE-----\n"
        + "MIIDjjCCAnagAwIBAgIQAzrx5qcRqaC7KGSxHQn65TANBgkqhkiG9w0BAQsFADBhMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSAwHgYDVQQDExdEaWdpQ2VydCBHbG9iYWwgUm9vdCBHMjAeFw0xMzA4MDExMjAwMDBaFw0zODAxMTUxMjAwMDBaMGExCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xIDAeBgNVBAMTF0RpZ2lDZXJ0IEdsb2JhbCBSb290IEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuzfNNNx7a8myaJCtSnX/RrohCgiN9RlUyfuI2/Ou8jqJkTx65qsGGmvPrC3oXgkkRLpimn7Wo6h+4FR1IAWsULecYxpsMNzaHxmx1x7e/dfgy5SDN67sH0NO3Xss0r0upS/kqbitOtSZpLYl6ZtrAGCSYP9PIUkY92eQq2EGnI/yuum06ZIya7XzV+hdG82MHauVBJVJ8zUtluNJbd134/tJS7SsVQepj5WztCO7TG1F8PapspUwtP1MVYwnSlcUfIKdzXOS0xZKBgyMUNGPHgm+F6HmIcr9g+UQvIOlCsRnKPZzFBQ9RnbDhxSJITRNrw9FDKZJobq7nMWxM4MphQIDAQABo0IwQDAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBhjAdBgNVHQ4EFgQUTiJUIBiV5uNu5g/6+rkS7QYXjzkwDQYJKoZIhvcNAQELBQADggEBAGBnKJRvDkhj6zHd6mcY1Yl9PMWLSn/pvtsrF9+wX3N3KjITOYFnQoQj8kVnNeyIv/iPsGEMNKSuIEyExtv4NeF22d+mQrvHRAiGfzZ0JFrabA0UWTW98kndth/Jsw1HKj2ZL7tcu7XUIOGZX1NGFdtom/DzMNU+MeKNhJ7jitralj41E6Vf8PlwUHBHQRFXGU7Aj64GxJUTFy8bJZ918rGOmaFvE7FBcf6IKshPECBV1/MUReXgRPTqh5Uykw7+U0b6LJ3/iyK5S9kJRaTepLiaWN0bfVKfjllDiIGknibVb63dDcY3fe0Dkhvld1927jyNxF1WW6LZZm6zNTflMrY=\n"
        + "-----END CERTIFICATE-----";

        ArrayList<ByteArray> certDERFiles = X509Certificate:decodePEMCertificates(certChainText);
        test(certDERFiles.size() == 3);
    }
}

class X509ManyCertsTests implements IUnitTest
{
	void run()
    {
        // Load our standard Certificate Authority certificates.
        u8[] certsFileContents = HVM:getPackageFile("CertificateAuthorityCerts.txt", "pronto_core");
        if(certsFileContents == null)
            return;

        ByteArray certsFile(certsFileContents);

        String<u8> certsStr = certsFile.toString();
        certsStr.replaceAll("-----END CERTIFICATE-----", "-----END CERTIFICATE-----,");
        ArrayList<String<u8>> splitCertsStrs = certsStr.split(Chars:COMMA, false);
        test(splitCertsStrs.size() > 0);
        if(splitCertsStrs.size() == 0)
            return;

        if(splitCertsStrs.getLast().contains("BEGIN") == false) // clearly just empty whitespace etc.
            splitCertsStrs.removeLast();
            
        for(u64 x=0; x<splitCertsStrs.size(); x++)
        {
            String<u8> certStr = splitCertsStrs[x];

            String<u8> readErrorsStr();
            X509Certificate certObj();
            test(certObj.readCertificate(certStr, readErrorsStr) == true);
            
            test(readErrorsStr.length() == 0);
        }
    }
}

class X509TrustStoreDefaultCertsTests implements IUnitTest
{
	void run()
    {
        X509TrustStore certStore();
        certStore.addDefaultRootCerts();

        test(certStore.rootCerts.size() > 50);
    }
}

class X509TrustStoreValidateCertChainTests implements IUnitTest
{
	void run()
    {
        /*Version: 3
        Signature Type: RSA SHA256
        Signature: 50DD2113EBE23273C65098042D81D0C235289918AA7F2626D5A2870CD5D54D0DD8446D66B6398105416FA8ECD5CC3681EEF90F27B21A49676A6511E9B5DCC8B1502BE4418E5201887C9A72CEDCD824A40E91C0A81229C8D78BF76DE440DADD5A9A576DD6F6E3C80AFE2C674DA2D93927DC85D5839C264BBBE2CEB642AB9BD29385D7A6A110C7F2CD035807D09B33D08274FEE843B544F3034C20C3487CB7FA0F9FA9524714A3AC675D8AEA8617ADC13B45221E02A25A3BE495E2EC39C83F517E79655406F77955BDCDB8FE27F044DC024B511B010EEB07C1DC289363887F016F2401D89F9A83E9517B3F5F4290B2C4F34A3B05065459DDCADE869F4EAA99CAE5
        Serial: 12907579716109026419932616701
        Issuer:
            Domain: GlobalSign RSA OV SSL CA 2018
            Country: BE
            State: 
            City: 
            Organization: GlobalSign nv-sa
            OrgUnit: 
        Subject:
            Domain: e.sni.fastly.net
            Country: US
            State: California
            City: San Francisco
            Organization: Fastly, Inc.
            OrgUnit: 
        Start Date: 2019-10-14 16:51:11
        Expiry Date: 2020-11-25 20:01:05
        RSA Public Key:
            Modulus (base 16): C881A7D6FBDFE258805CCD16ED93BEA0AD7C17E331476F03FA1A4108A572703D60778390767556A80656C958A501E701675694D6FD0FD8191D85A7B8C43E97814B8C006C1BEB2F63B7D0B1544AB7AC5AD085C31BBF11BF53E7CAAFC731C8E426512E34BB020D437CA3070DAE72EBB01D6F88C8632A8070CF7099A346947DB4EE2BBB6FEFA14EF7C9156380F722847A0AE36B9DA0ACF4011B8E4EE3E4DBFD63596D5850D92696BA39338227272B5893C2071A7EB3BB0DBCCCED8114AA116A055F504B1C4FBBC82F042B9C49F9A47C5C2A5285FDC24FD71ABEA5A2D270546084A6F35A837B0C66D40874936480C8C77DB247DF0520A31B49C4C7A51A4ECAA8EAC3
            Exponent (base 10): 65537
        Subject Type: End-Entity
        Authority Key: F8EF7FF2CD7867A8DE6F8F248D88F1870302B3EB
        Subject Key: 32284DEAD893092BC545754F1DDA6C47E00BDB40
        Subject Alternate Domains:
            e.sni.fastly.net */
        String<u8> certStrA = 
        "-----BEGIN CERTIFICATE-----\n" +
        "MIIGEjCCBPqgAwIBAgIMKbTmUnycbLaBx1f9MA0GCSqGSIb3DQEBCwUAMFAxCzAJBgNVBAYTAkJFMRkw" +
        "FwYDVQQKExBHbG9iYWxTaWduIG52LXNhMSYwJAYDVQQDEx1HbG9iYWxTaWduIFJTQSBPViBTU0wgQ0Eg" +
        "MjAxODAeFw0xOTEwMTQxNjUxMTFaFw0yMDExMjUyMDAxMDVaMGwxCzAJBgNVBAYTAlVTMRMwEQYDVQQI" +
        "EwpDYWxpZm9ybmlhMRYwFAYDVQQHEw1TYW4gRnJhbmNpc2NvMRUwEwYDVQQKEwxGYXN0bHksIEluYy4x" +
        "GTAXBgNVBAMTEGUuc25pLmZhc3RseS5uZXQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDI" +
        "gafW+9/iWIBczRbtk76grXwX4zFHbwP6GkEIpXJwPWB3g5B2dVaoBlbJWKUB5wFnVpTW/Q/YGR2Fp7jE" +
        "PpeBS4wAbBvrL2O30LFUSresWtCFwxu/Eb9T58qvxzHI5CZRLjS7Ag1DfKMHDa5y67Adb4jIYyqAcM9w" +
        "maNGlH207iu7b++hTvfJFWOA9yKEegrja52grPQBG45O4+Tb/WNZbVhQ2SaWujkzgicnK1iTwgcafrO7" +
        "DbzM7YEUqhFqBV9QSxxPu8gvBCucSfmkfFwqUoX9wk/XGr6lotJwVGCEpvNag3sMZtQIdJNkgMjHfbJH" +
        "3wUgoxtJxMelGk7KqOrDAgMBAAGjggLOMIICyjAOBgNVHQ8BAf8EBAMCBaAwgY4GCCsGAQUFBwEBBIGB" +
        "MH8wRAYIKwYBBQUHMAKGOGh0dHA6Ly9zZWN1cmUuZ2xvYmFsc2lnbi5jb20vY2FjZXJ0L2dzcnNhb3Zz" +
        "c2xjYTIwMTguY3J0MDcGCCsGAQUFBzABhitodHRwOi8vb2NzcC5nbG9iYWxzaWduLmNvbS9nc3JzYW92" +
        "c3NsY2EyMDE4MFYGA1UdIARPME0wQQYJKwYBBAGgMgEUMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3" +
        "Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMAgGBmeBDAECAjAJBgNVHRMEAjAAMD8GA1UdHwQ4MDYw" +
        "NKAyoDCGLmh0dHA6Ly9jcmwuZ2xvYmFsc2lnbi5jb20vZ3Nyc2FvdnNzbGNhMjAxOC5jcmwwGwYDVR0R" +
        "BBQwEoIQZS5zbmkuZmFzdGx5Lm5ldDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwHwYDVR0j" +
        "BBgwFoAU+O9/8s14Z6jeb48kjYjxhwMCs+swHQYDVR0OBBYEFDIoTerYkwkrxUV1Tx3abEfgC9tAMIIB" +
        "BQYKKwYBBAHWeQIEAgSB9gSB8wDxAHcAxlKg7EjOs/yrFwmSxDqHQTMJ6ABlomJSQBujNioXxWUAAAFt" +
        "yy5UAQAABAMASDBGAiEA1r8KMGGLOhwpdnDhtzQqLWVrWDds9D5a+s4+s8tt+joCIQDzvTPrHtoHWpqb" +
        "yR2bp44xRqiShotIkcJDQVTSjhTNYgB2ALIeBcyLos2KIE6HZvkruYolIGdr2vpw57JJUy3vi5BeAAAB" +
        "bcsuVJYAAAQDAEcwRQIgGa7cUG5BLvNrJTjFqUAk/celZMw4ydnY8rO+L76a6psCIQDW5rEGbKhOOezz" +
        "xDBXZVEAKlCFU3tmBjD8f0DJqAk0CzANBgkqhkiG9w0BAQsFAAOCAQEAUN0hE+viMnPGUJgELYHQwjUo" +
        "mRiqfyYm1aKHDNXVTQ3YRG1mtjmBBUFvqOzVzDaB7vkPJ7IaSWdqZRHptdzIsVAr5EGOUgGIfJpyztzY" +
        "JKQOkcCoEinI14v3beRA2t1amldt1vbjyAr+LGdNotk5J9yF1YOcJku74s62Qqub0pOF16ahEMfyzQNY" +
        "B9CbM9CCdP7oQ7VE8wNMIMNIfLf6D5+pUkcUo6xnXYrqhhetwTtFIh4Colo75JXi7DnIP1F+eWVUBvd5" +
        "Vb3NuP4n8ETcAktRGwEO6wfB3CiTY4h/AW8kAdifmoPpUXs/X0KQssTzSjsFBlRZ3crehp9OqpnK5Q==\n" +
        "-----END CERTIFICATE-----";

        /*Version: 3
        Signature Type: RSA SHA256
        Signature: 9990C82D5F428AD40B66DB98037311D488865228538AFBADDFFD738E3A6704DBC353147014097CC3E0F8D71C981AA2C43EDBE900E3CA70B2F122302156DBD3AD795E81580B6D148035F56F5D1DEB9A4705FF598D00B140DA9098961ABA6C6D7F8CF5B380DF8C6473369679796974EABFF89E018FA095698DE984BAE9E5D48838DB783B98D0367B29B0D2521890DE524300AE6A27C8149E8695ACE18031307E9A25BB8BAC0423A69900E8F1D226EC0F7E3B8A2B9238131D8F86CD865247E6347C5BA4023E8A617C2276535A94533386B892A872AFA1F952871F31A5FCB081572FCDF4CEDCF624CFA7E23490689DFEAAF1A99A12CC9BC0C6C3A8A5B0217EDE48F6
        Serial: 153000603918210013455007253847
        Issuer:
            Domain: GlobalSign
            Country: 
            State: 
            City: 
            Organization: GlobalSign
            OrgUnit: GlobalSign Root CA - R3
        Subject:
            Domain: GlobalSign RSA OV SSL CA 2018
            Country: BE
            State: 
            City: 
            Organization: GlobalSign nv-sa
            OrgUnit: 
        Start Date: 2018-11-21 00:00:00
        Expiry Date: 2028-11-21 00:00:00
        RSA Public Key:
            Modulus (base 16): A75AC9D50C18210023D5970FEBAEDD5C686B6B8F5060137A81CB97EE8E8A61944B2679F604A72AFBA4DA56BBEEA0A4F07B8A7F551F4793610D6E71513A2524082F8CE1F789D692CFAFB3A73F30EDB5DF21AEFEF54417FDD863D92FD3815A6B5FD347B0ACF2AB3B24794F1FC72EEAB9153A7C184C69B3B52059095E29C363E62E465BAA9490490EB9F0F54AA1092F7C344DD0BC00C506557906CEA2D010F14843E8B95AB59555BD31D21B3D86BEA1EC0D12DB2C9924AD47C26F03E67A70B570CCCD272CA58C8EC2183C92C92E736F0610569340AAA3C552FBE5C505D669685C06B9EE5189E18A0E414D9B92900A89E9166BEFEF75BE7A46B8E3478A1D1C2EA74F
            Exponent (base 10): 65537
        Subject Type: Certificate Authority
        Authority Key: 8FF04B7FA82E4524AE4D50FA639A8BDEE2DD1BBC
        Subject Key: F8EF7FF2CD7867A8DE6F8F248D88F1870302B3EB
        Subject Alternate Domains:*/
        String<u8> certStrB = 
        "-----BEGIN CERTIFICATE-----\n" + 
        "MIIETjCCAzagAwIBAgINAe5fIh38YjvUMzqFVzANBgkqhkiG9w0BAQsFADBMMSAwHgYDVQQLExdHbG9i" + 
        "YWxTaWduIFJvb3QgQ0EgLSBSMzETMBEGA1UEChMKR2xvYmFsU2lnbjETMBEGA1UEAxMKR2xvYmFsU2ln" + 
        "bjAeFw0xODExMjEwMDAwMDBaFw0yODExMjEwMDAwMDBaMFAxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBH" + 
        "bG9iYWxTaWduIG52LXNhMSYwJAYDVQQDEx1HbG9iYWxTaWduIFJTQSBPViBTU0wgQ0EgMjAxODCCASIw" + 
        "DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKdaydUMGCEAI9WXD+uu3Vxoa2uPUGATeoHLl+6OimGU" + 
        "SyZ59gSnKvuk2la77qCk8HuKf1UfR5NhDW5xUTolJAgvjOH3idaSz6+zpz8w7bXfIa7+9UQX/dhj2S/T" + 
        "gVprX9NHsKzyqzskeU8fxy7quRU6fBhMabO1IFkJXinDY+YuRluqlJBJDrnw9UqhCS98NE3QvADFBlV5" + 
        "Bs6i0BDxSEPouVq1lVW9MdIbPYa+oewNEtssmSStR8JvA+Z6cLVwzM0nLKWMjsIYPJLJLnNvBhBWk0Cq" + 
        "o8VS++XFBdZpaFwGue5RieGKDkFNm5KQConpFmvv73W+eka440eKHRwup08CAwEAAaOCASkwggElMA4G" + 
        "A1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBT473/yzXhnqN5vjySNiPGH" + 
        "AwKz6zAfBgNVHSMEGDAWgBSP8Et/qC5FJK5NUPpjmove4t0bvDA+BggrBgEFBQcBAQQyMDAwLgYIKwYB" + 
        "BQUHMAGGImh0dHA6Ly9vY3NwMi5nbG9iYWxzaWduLmNvbS9yb290cjMwNgYDVR0fBC8wLTAroCmgJ4Yl" + 
        "aHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9yb290LXIzLmNybDBHBgNVHSAEQDA+MDwGBFUdIAAwNDAy" + 
        "BggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wDQYJKoZIhvcN" + 
        "AQELBQADggEBAJmQyC1fQorUC2bbmANzEdSIhlIoU4r7rd/9c446ZwTbw1MUcBQJfMPg+NccmBqixD7b" + 
        "6QDjynCy8SIwIVbb0615XoFYC20UgDX1b10d65pHBf9ZjQCxQNqQmJYaumxtf4z1s4DfjGRzNpZ5eWl0" + 
        "6r/4ngGPoJVpjemEuunl1Ig423g7mNA2eymw0lIYkN5SQwCuaifIFJ6GlazhgDEwfpolu4usBCOmmQDo" + 
        "8dIm7A9+O4orkjgTHY+GzYZSR+Y0fFukAj6KYXwidlNalFMzhriSqHKvoflShx8xpfywgVcvzfTO3PYk" + 
        "z6fiNJBonf6q8amaEsybwMbDqKWwIX7eSPY=\n" + 
        "-----END CERTIFICATE-----";

        X509Certificate certA();
        test(certA.readCertificate(certStrA) == true);
        test(certA.isEndEntity() == true);

        X509Certificate certB();
        test(certB.readCertificate(certStrB) == true);
        test(certB.isEndEntity() == false); // must be certificate authority (or intermediate)

        ArrayList<X509Certificate> certChain();
        certChain.add(certA); // end-entity certificate
        certChain.add(certB);

        X509TrustStore certStore();
        certStore.addDefaultRootCerts();
        test(certStore.rootCerts.size() > 50);

        // Cert A expired, TODO new unit test
        //test(certStore.validateCertChain(certChain) == true);
    }
}

class X509CreateSelfSignedCert implements IUnitTest
{
	void run()
    {
        f64 startTime = System:getTime();
        RSAKey rsaKey(); // public and private key
        rsaKey.generateKey(512); // it can take a long while so smaller just for test
        f64 elapsedTime = System:getTime() - startTime;
        //Log:log("\nX509CreateSelfSignedCert time to gen 512 bit RSA key: " + String<u8>:formatNumber(elapsedTime) + " ms\n");

        X509Certificate cert();
        cert.certVersion       = X509Certificate:CERT_VERSION_3; // v1=0, v2=1, v3=2
        cert.signatureType     = X509Certificate:SIGNATURE_TYPE_RSA_SHA256;
        cert.signatureBytes    = null;
        cert.serialNumber      = BigInt("1234567890", 10); // Unique id of this certificate, used for checking for revoked certificates normally
        cert.issuer            = X509Name("prontoware.com", "Canada", "Ontario", "Toronto", "Prontoware Inc.", "QA"); // Certificate authority (CA)
        cert.subject           = X509Name("prontoware.com", "Canada", "Ontario", "Toronto", "Prontoware Inc.", "QA"); // Certificate creator (i.e. domain owner) or Certificate Authority (CA) if this is a root certificate
        cert.startDate         = CalendarDateTime(2020, 1, 1, 1, 1, 1);  // start of validity period
        cert.expiryDate        = CalendarDateTime(2030, 1, 1, 1, 1, 1); // end of validity period
        cert.rsaPublicKey      = rsaKey.getPublicKey(); // RSA public key
        cert.authorityKey      = ByteArray(u8[](0, 1, 2, 3, 4, 5)); // unique id of authority (rather than just using common name)
        cert.subjectKey        = ByteArray(u8[](0, 1, 2, 3, 4, 5));   // unique id of subject (rather than just using common name)
        cert.subjectAltDomains = ArrayList<String<u8>>(); // additional domains certified by this certificate
        cert.rootCert          = true; // can this certificate be used to sign other certificates with it's public key? End-entity certificates cannot sign other certificates.

        String<u8> selfSignedCertBase64 = cert.writeSignedCertificateBase64(rsaKey);

        //Log:log("X509CreateSelfSignedCert cert: \n\n" + selfSignedCertBase64 + "\n\n");

        X509Certificate certA();
        String<u8> readErrors();
        if(certA.readCertificate(selfSignedCertBase64, readErrors) == false)
        {
            Log:log("\nFailed to read written X509 certificate: " + readErrors + "\n");
            test(false);
        }
        test(certA.rootCert == true);
    }
}