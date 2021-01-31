////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

// For logging AES results etc.
class AESTestUtils
{
    shared u8[32] vec32u8(u8[] a)
    {
        u8[32] x;
        for(u32 i=0; i<a.length(); i++)
            x[i] = a[i];
        return x;
    }

    shared String<u8> bytesToHexString(u8[] bytes)
    {
        if(bytes == null)
            return "";

        String<u8> s(bytes.length() * 4);

        for(u64 b=0; b<bytes.length(); b++)
        {
            s.append(String<u8>:formatNumberHex(bytes[b]));
            s.append(" ");
        }

        return s;
    }

    shared String<u8> u32ToHexString(u32[] nums)
    {
        if(nums == null)
            return "";

        String<u8> s(nums.length() * 4);

        for(u64 b=0; b<nums.length(); b++)
        {
            s.append(String<u8>:formatNumberHex(nums[b]));
            s.append(" ");
        }

        return s;
    }

    shared String<u8> u8v4ToHexString(u8[4][] nums)
    {
        if(nums == null)
            return "";

        String<u8> s(nums.length() * 4);

        for(u64 b=0; b<nums.length(); b++)
        {
            for(u64 v=0; v<4; v++)
            {
                s.append(String<u8>:formatNumberHex(nums[b][v]));
                s.append(" ");
            }
        }

        return s;
    }

    shared String<u8> u32v4ToHexString(u32[4][] nums)
    {
        if(nums == null)
            return "";

        String<u8> s(nums.length() * 4);

        for(u64 b=0; b<nums.length(); b++)
        {
            for(u64 v=0; v<4; v++)
            {
                s.append(String<u8>:formatNumberHex(nums[b][v]));
                s.append(" ");
            }
        }

        return s;
    }
}

class AES128_ECB_Tests implements IUnitTest
{
	void run()
	{
        u8[16] key = u8(0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10); // hex 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 10
        u8[] plainText(0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20); // hex 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F 20
        u8[] validatedSecretText(0xD7, 0x21, 0xA0, 0xF1, 0x94, 0x23, 0x18, 0x22, 0xF3, 0x98, 0x70, 0x6D, 0xD1, 0xFF, 0xF2, 0xB7); // from online calculator
        u8[] secretText = plainText.clone();

        AES encrypter = AES(key); // 128 bit key, ECB mode
        encrypter.encrypt(secretText, secretText.length());
        test(secretText != null);
        if(secretText == null)
            return;

        test(plainText.length() == secretText.length());
        test(secretText.length() == validatedSecretText.length());
        for(u64 v=0; v<secretText.length(); v++)
        {
            test(secretText[v] == validatedSecretText[v]);
        }

        AES decrypter = AES(key); // 128 bit key, ECB mode
        decrypter.decrypt(secretText, secretText.length());
        test(secretText != null);
        if(secretText == null)
            return;

        test(plainText.length() == secretText.length());
        for(u64 b=0; b<plainText.length(); b++)
        {
            test(plainText[b] == secretText[b]);
            if(plainText[b] != secretText[b])
                break;
        }
    }
}

class AES256_ECB_Tests implements IUnitTest
{
	void run()
	{
        u8[32] key = AESTestUtils:vec32u8(u8[](0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10,
                                  0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20)); // 0102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F20
        u8[] plainText(0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20); // 1112131415161718191A1B1C1D1E1F20
        u8[] validatedSecretText(0xD2, 0xE9, 0x49, 0xFE, 0xBF, 0xE1, 0x8D, 0x5C, 0xA3, 0x4C, 0xFC, 0x1A, 0x26, 0xF8, 0x51, 0x5B); // from online calculator
        u8[] secretText = plainText.clone();

        AES encrypter = AES(key); // 256 bit key, ECB mode
        encrypter.encrypt(secretText, secretText.length());
        test(secretText != null);
        if(secretText == null)
            return;

        test(plainText.length() == secretText.length());
        test(secretText.length() == validatedSecretText.length());
        for(u64 v=0; v<secretText.length(); v++)
        {
            test(secretText[v] == validatedSecretText[v]);
        }

        AES decrypter = AES(key); // 256 bit key, ECB mode
        decrypter.decrypt(secretText, secretText.length());
        test(secretText != null);
        if(secretText == null)
            return;

        test(plainText.length() == secretText.length());
        for(u64 b=0; b<plainText.length(); b++)
        {
            test(plainText[b] == secretText[b]);
            if(plainText[b] != secretText[b])
                break;
        }
    }
}

class AES128_CBC_Tests implements IUnitTest
{
	void run()
	{
        u8[16] key = u8(0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10); // 0102030405060708090A0B0C0D0E0F10
        u8[16] iv = u8(0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7, 0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF, 0x10); // initialization vector for CBC mode - A1A2A3A4A5A6A7A8A9AAABACADAEAF10

        // plain text data is 48 bytes total so that we test three blocks (start, middle, end) since CBC depends on previous blocks
        // 1112131415161718191A1B1C1D1E1F20404142434445464748494A4B4C4D4E4F5061728394A5B6C7D8E9FA4B4C4D4E4F
        u8[] plainText(0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20,
                       0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F,
                       0x50, 0x61, 0x72, 0x83, 0x94, 0xA5, 0xB6, 0xC7, 0xD8, 0xE9, 0xFA, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F);

        u8[] secretText = plainText.clone();
        
        // from online calculator CD43182AB69BBC3350EBC8B6C44D4229E24F938C46B190F22292F35D5BFA7CB633A0D2467D514DD1337E89B5E9000018
        u8[] validatedSecretText(0xCD, 0x43, 0x18, 0x2A, 0xB6, 0x9B, 0xBC, 0x33, 0x50, 0xEB, 0xC8, 0xB6, 0xC4, 0x4D, 0x42, 0x29,
                                 0xE2, 0x4F, 0x93, 0x8C, 0x46, 0xB1, 0x90, 0xF2, 0x22, 0x92, 0xF3, 0x5D, 0x5B, 0xFA, 0x7C, 0xB6,
                                 0x33, 0xA0, 0xD2, 0x46, 0x7D, 0x51, 0x4D, 0xD1, 0x33, 0x7E, 0x89, 0xB5, 0xE9, 0x00, 0x00, 0x18);

        AES encrypter = AES(key, iv); // 128 bit key, CBC mode
        encrypter.encrypt(secretText, secretText.length());
        test(secretText != null);
        if(secretText == null)
            return;

        test(plainText.length() == secretText.length());
        test(secretText.length() == validatedSecretText.length());
        for(u64 v=0; v<secretText.length(); v++)
        {
            test(secretText[v] == validatedSecretText[v]);
        }

        AES decrypter = AES(key, iv); // decrypter needs to start with same IV for the first block
        decrypter.decrypt(secretText, secretText.length());
        test(secretText != null);
        if(secretText == null)
            return;

        test(plainText.length() == secretText.length());
        for(u64 b=0; b<plainText.length(); b++)
        {
            test(plainText[b] == secretText[b]);
            if(plainText[b] != secretText[b])
                break;
        }
    }
}

class AES256_CBC_Tests implements IUnitTest
{
	void run()
	{
        u8[32] key = AESTestUtils:vec32u8(u8[](0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10,
                        0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20)); // 0102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F20
        u8[16] iv  = u8(0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10); // initialization vector for CBC mode
        u8[] plainText(0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20);
        u8[] validatedSecretText(0x99, 0xC5, 0x6D, 0x65, 0xB7, 0xFA, 0xC1, 0xF8, 0xEC, 0x7F, 0xFC, 0xA5, 0xB3, 0x88, 0x36, 0x7B); // from online calculator
        u8[] secretText = plainText.clone();

        AES encrypter = AES(key, iv); // 256 bit key, CBC mode
        encrypter.encrypt(secretText, secretText.length());
        test(secretText != null);
        if(secretText == null)
            return;

        test(plainText.length() == secretText.length());
        test(secretText.length() == validatedSecretText.length());
        for(u64 v=0; v<secretText.length(); v++)
        {
            test(secretText[v] == validatedSecretText[v]);
        }

        AES decrypter = AES(key, iv); // 256 bit key
        decrypter.decrypt(secretText, secretText.length());
        test(secretText != null);
        if(secretText == null)
            return;

        test(plainText.length() == secretText.length());
        for(u64 b=0; b<plainText.length(); b++)
        {
            test(plainText[b] == secretText[b]);
            if(plainText[b] != secretText[b])
                break;
        }
    }
}

class AES128_CTR_Tests implements IUnitTest
{
	void run()
	{
        u8[16] key = u8(0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10);
        u64 counterStart = 99;

        // plain text data is 48 bytes total so that we test three blocks (start, middle, end) since CBC depends on previous blocks
        // 1112131415161718191A1B1C1D1E1F20404142434445464748494A4B4C4D4E4F5061728394A5B6C7D8E9FA4B4C4D4E4F
        u8[] plainText(0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20,
                       0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F,
                       0x50, 0x61, 0x72, 0x83, 0x94, 0xA5, 0xB6, 0xC7, 0xD8, 0xE9, 0xFA, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F);

         // from online calculator
        u8[] validatedSecretText(0x9E, 0x59, 0x6C, 0x62, 0x34, 0x95, 0x24, 0x4D, 0x2E, 0x59, 0x8B, 0xC6, 0xA7, 0x73, 0xBD, 0x4F,
                                 0x59, 0xEE, 0x64, 0xA2, 0x38, 0xB6, 0xDE, 0x2F, 0x38, 0xE7, 0x8A, 0x48, 0x31, 0xD2, 0x05, 0xD8,
                                 0x2C, 0xB6, 0xDE, 0x76, 0xD8, 0xC5, 0x0B, 0x40, 0x1F, 0xDE, 0xFA, 0x69, 0xC8, 0xCA, 0xDB, 0xED);
                                 
        u8[] secretText = plainText.clone();

        AES encrypter = AES(key, counterStart); // 128 bit key, CTR mode
        encrypter.encrypt(secretText, secretText.length());
        test(secretText != null);
        if(secretText == null)
            return;

        test(plainText.length() == secretText.length());
        test(secretText.length() == validatedSecretText.length());
        for(u64 v=0; v<secretText.length(); v++)
        {
            test(secretText[v] == validatedSecretText[v]);
        }

        AES decrypter = AES(key, counterStart); // decrypter needs to start with same counter value
        decrypter.decrypt(secretText, secretText.length());
        test(secretText != null);
        if(secretText == null)
            return;

        test(plainText.length() == secretText.length());
        for(u64 b=0; b<plainText.length(); b++)
        {
            test(plainText[b] == secretText[b]);
            if(plainText[b] != secretText[b])
                break;
        }
    }
}

class AES256_CTR_Tests implements IUnitTest
{
	void run()
	{
        u8[32] key = AESTestUtils:vec32u8(u8[](0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10,
                        0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20)); // 0102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F20
        u64 counterStart = 99;
        u8[] plainText(0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20);
        u8[] validatedSecretText(0xD9, 0x40, 0x9A, 0x14, 0xF4, 0x10, 0xE4, 0xFA, 0xA9, 0xE0, 0x84, 0x7B, 0xEC, 0x9B, 0x4C, 0x0C); // from online calculator

        u8[] secretText = plainText.clone();

        AES encrypter = AES(key, counterStart); // 256 bit key
        encrypter.encrypt(secretText, secretText.length());
        test(secretText != null);
        if(secretText == null)
            return;

        test(plainText.length() == secretText.length());
        test(secretText.length() == validatedSecretText.length());
        for(u64 v=0; v<secretText.length(); v++)
        {
            test(secretText[v] == validatedSecretText[v]);
        }

        AES decrypter = AES(key, counterStart); // decrypter needs to start with same counter value
        decrypter.decrypt(secretText, secretText.length());
        test(secretText != null);
        if(secretText == null)
            return;

        test(plainText.length() == secretText.length());
        for(u64 b=0; b<plainText.length(); b++)
        {
            test(plainText[b] == secretText[b]);
            if(plainText[b] != secretText[b])
                break;
        }
    }
}

class AES128_ECB_PerfTests implements IUnitTest
{
	void run()
	{
        u8[16] key = u8(0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10);
        u8[] plainText(1024 * 1024); // 1 MB
        for(u64 p=0; p<plainText.length(); p++)
            plainText[p] = p;
        u8[] modText = plainText.clone();

        AES encrypter = AES(key); // 128 bit key

        f64 startTime = System:getTime();
        encrypter.encrypt(modText, modText.length());
        f64 execTime = System:getTime() - startTime;

        test(modText != null);
        if(modText == null)
            return;

        test(plainText.length() == modText.length());

        Log:log("AES128_ECB_PerfTests encrypt MB/s: " + String<u8>:formatNumber(1.0 / (execTime / 1000.0)) + "\n");

        AES decrypter = AES(key); // 128 bit key, ECB mode

        startTime = System:getTime();
        decrypter.decrypt(modText, modText.length());
        execTime = System:getTime() - startTime;

        Log:log("AES128_ECB_PerfTests decrypt MB/s: " + String<u8>:formatNumber(1.0 / (execTime / 1000.0)) + "\n");

        test(modText != null);
        if(modText == null)
            return;

        test(plainText.length() == modText.length());
        for(u64 b=0; b<plainText.length(); b++)
        {
            test(plainText[b] == modText[b]);
            if(plainText[b] != modText[b])
                break;
        }
    }
}

class AES256_ECB_PerfTests implements IUnitTest
{
	void run()
	{
        u8[32] key = AESTestUtils:vec32u8(u8[](0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10,
                                  0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20));
        u8[] plainText(1024 * 1024); // 1 MB
        for(u64 p=0; p<plainText.length(); p++)
            plainText[p] = p;

        u8[] modText = plainText.clone();

        AES encrypter = AES(key); // 256 bit key

        f64 startTime = System:getTime();
        encrypter.encrypt(modText, modText.length());
        f64 execTime = System:getTime() - startTime;

        test(modText != null);
        if(modText == null)
            return;

        test(plainText.length() == modText.length());

        Log:log("AES256_ECB_PerfTests encrypt MB/s: " + String<u8>:formatNumber(1.0 / (execTime / 1000.0)) + "\n");

        AES decrypter = AES(key); // 256 bit key, ECB mode

        startTime = System:getTime();
        decrypter.decrypt(modText, modText.length());
        execTime = System:getTime() - startTime;

        Log:log("AES256_ECB_PerfTests decrypt MB/s: " + String<u8>:formatNumber(1.0 / (execTime / 1000.0)) + "\n");

        test(modText != null);
        if(modText == null)
            return;

        test(plainText.length() == modText.length());
        for(u64 b=0; b<plainText.length(); b++)
        {
            test(plainText[b] == modText[b]);
            if(plainText[b] != modText[b])
                break;
        }
    }
}

class AES128_CBC_PerfTests implements IUnitTest
{
	void run()
	{
        u8[16] key = u8(0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10);
        u8[16] iv  = u8(0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10);
        u8[] plainText(1024 * 1024); // 1 MB
        for(u64 p=0; p<plainText.length(); p++)
            plainText[p] = p;

        u8[] modText = plainText.clone();

        AES encrypter = AES(key, iv); // 128 bit key, CBC mode

        f64 startTime = System:getTime();
        encrypter.encrypt(modText, modText.length());
        f64 execTime = System:getTime() - startTime;

        test(modText != null);
        if(modText == null)
            return;

        test(plainText.length() == modText.length());

        Log:log("AES128_CBC_PerfTests encrypt MB/s: " + String<u8>:formatNumber(1.0 / (execTime / 1000.0)) + "\n");

        AES decrypter = AES(key, iv); // 128 bit key, CBC mode

        startTime = System:getTime();
        decrypter.decrypt(modText, modText.length());
        execTime = System:getTime() - startTime;

        Log:log("AES128_CBC_PerfTests decrypt MB/s: " + String<u8>:formatNumber(1.0 / (execTime / 1000.0)) + "\n");

        test(modText != null);
        if(modText == null)
            return;

        test(plainText.length() == modText.length());
        for(u64 b=0; b<plainText.length(); b++)
        {
            test(plainText[b] == modText[b]);
            if(plainText[b] != modText[b])
                break;
        }
    }
}

class AES256_CBC_PerfTests implements IUnitTest
{
	void run()
	{
        u8[32] key = AESTestUtils:vec32u8(u8[](0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10,
                                  0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20));
        u8[16] iv  = u8(0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10);
        u8[] plainText(1024 * 1024); // 1 MB
        for(u64 p=0; p<plainText.length(); p++)
            plainText[p] = p;

        u8[] modText = plainText.clone();

        AES encrypter = AES(key, iv); // 256 bit key, CBC mode

        f64 startTime = System:getTime();
        encrypter.encrypt(modText, modText.length());
        f64 execTime = System:getTime() - startTime;

        test(modText != null);
        if(modText == null)
            return;

        test(plainText.length() == modText.length());

        Log:log("AES256_CBC_PerfTests encrypt MB/s: " + String<u8>:formatNumber(1.0 / (execTime / 1000.0)) + "\n");

        AES decrypter = AES(key, iv); // 256 bit key, CBC mode

        startTime = System:getTime();
        decrypter.decrypt(modText, modText.length());
        execTime = System:getTime() - startTime;

        Log:log("AES256_CBC_PerfTests decrypt MB/s: " + String<u8>:formatNumber(1.0 / (execTime / 1000.0)) + "\n");

        test(modText != null);
        if(modText == null)
            return;

        test(plainText.length() == modText.length());
        for(u64 b=0; b<plainText.length(); b++)
        {
            test(plainText[b] == modText[b]);
            if(plainText[b] != modText[b])
                break;
        }
    }
}

class AES128_CTR_PerfTests implements IUnitTest
{
	void run()
	{
        u8[16] key = u8(0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10);
        u64 counterStart = 99;
        u8[] plainText(1024 * 1024); // 1 MB
        for(u64 p=0; p<plainText.length(); p++)
            plainText[p] = p;

        u8[] modText = plainText.clone();

        AES encrypter = AES(key, counterStart); // 128 bit key, CTR mode

        f64 startTime = System:getTime();
        encrypter.encrypt(modText, modText.length());
        f64 execTime = System:getTime() - startTime;

        test(modText != null);
        if(modText == null)
            return;

        test(plainText.length() == modText.length());

        Log:log("AES128_CTR_PerfTests encrypt MB/s: " + String<u8>:formatNumber(1.0 / (execTime / 1000.0)) + "\n");

        AES decrypter = AES(key, counterStart); // 128 bit key, CTR mode

        startTime = System:getTime();
        decrypter.decrypt(modText, modText.length());
        execTime = System:getTime() - startTime;

        Log:log("AES128_CTR_PerfTests decrypt MB/s: " + String<u8>:formatNumber(1.0 / (execTime / 1000.0)) + "\n");

        test(modText != null);
        if(modText == null)
            return;

        test(plainText.length() == modText.length());
        for(u64 b=0; b<plainText.length(); b++)
        {
            test(plainText[b] == modText[b]);
            if(plainText[b] != modText[b])
                break;
        }
    }
}

class AES256_CTR_PerfTests implements IUnitTest
{
	void run()
	{
        u8[32] key = AESTestUtils:vec32u8(u8[](0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10,
                                  0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20));
        u64 counterStart = 99;
        u8[] plainText(1024 * 1024); // 1 MB
        for(u64 p=0; p<plainText.length(); p++)
            plainText[p] = p;

        u8[] modText = plainText.clone();

        AES encrypter = AES(key, counterStart); // 256 bit key, CTR mode

        f64 startTime = System:getTime();
        encrypter.encrypt(modText, modText.length());
        f64 execTime = System:getTime() - startTime;

        test(modText != null);
        if(modText == null)
            return;

        test(plainText.length() == modText.length());

        Log:log("AES256_CTR_PerfTests encrypt MB/s: " + String<u8>:formatNumber(1.0 / (execTime / 1000.0)) + "\n");

        AES decrypter = AES(key, counterStart); // 256 bit key, CTR mode

        startTime = System:getTime();
        decrypter.decrypt(modText, modText.length());
        execTime = System:getTime() - startTime;

        Log:log("AES256_CTR_PerfTests decrypt MB/s: " + String<u8>:formatNumber(1.0 / (execTime / 1000.0)) + "\n");

        test(modText != null);
        if(modText == null)
            return;

        test(plainText.length() == modText.length());
        for(u64 b=0; b<plainText.length(); b++)
        {
            test(plainText[b] == modText[b]);
            if(plainText[b] != modText[b])
                break;
        }
    }
}

class PKCS7Tests implements IUnitTest
{
	void run()
	{
        u8[] data(0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E); // 14 bytes long

        u8[] paddedData = PKCS7:pad(data, 16); // 16 for AES block size etc.
        test(paddedData != null);
        if(paddedData == null)
            return;
        test(paddedData.length() == 16);

        u8[] unpaddedData = PKCS7:unpad(paddedData, 16);
        test(unpaddedData != null);
        if(unpaddedData == null)
            return;
        test(unpaddedData.length() == 14);
        
        for(u64 a=0; a<data.length(); a++)
        {
            test(data[a] == unpaddedData[a]);
        }

        // Now with ByteArray
        ByteArray data2(data);
        test(data2.size() == 14);

        PKCS7:pad(data2, 16); // 16 for AES block size etc.
        test(data2.size() == 16);

        PKCS7:unpad(data2, 16);
        test(data2.size() == 14);
        
        for(u64 a=0; a<data2.size(); a++)
        {
            test(data2[a] == unpaddedData[a]);
        }
    }
}