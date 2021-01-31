////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// ASN1Node
////////////////////////////////////////////////////////////////////////////////////////////////////

// ASN.1 (Abstract Syntax Notation) is effectively a tree data structure.
class ASN1Node
{
    bool primitive   = false; // bit 6 of the identifier byte (primitive or constructed)
    u8   tagClass    = 0;     // bits 7-8 of the identifier byte
    u8   tag         = 0;     // bits 1-5 of the identifier byte
    u8[] allData     = null;  // includes tag ID, tag length bytes
    u8[] data        = null;  // could be OID value, string value etc. (doesn't include tagID/tag length bytes)
    bool bitStringAddByte = true; // can be set to false if bit string already has encoded meta start byte
    ArrayList<ASN1Node> children();

    void constructor()
    {

    }

    // Encode a primitive integer
    void constructor(BigInt number)
    {
        this.tag       = ASN1:TAG_INTEGER;
        this.primitive = true;
        this.tagClass  = ASN1:CLASS_UNIVERSAL;

        this.encodeInteger(number);
    }

    // Encode calendar date time
    void constructor(CalendarDateTime dateTime)
    {
        this.tag       = ASN1:TAG_UTC_TIME;
        this.primitive = true;
        this.tagClass  = ASN1:CLASS_UNIVERSAL;

        this.encodeUTCTime(dateTime);
    }

    // Encode raw data.
    void constructor(u8 tagID, u8[] data)
    {
        this.tag       = tagID;
        this.primitive = true;
        this.tagClass  = ASN1:CLASS_UNIVERSAL;
        this.data      = data.clone();
    }

    // Construct primitive without data.
    void constructor(u8 tagID)
    {
        this.tag       = tagID;
        this.primitive = true;
        this.tagClass  = ASN1:CLASS_UNIVERSAL;
    }

    // Construct primitive without data.
    void constructor(u8 tagID, bool primitive, u8 tagClass)
    {
        this.tag       = tagID;
        this.primitive = primitive;
        this.tagClass  = tagClass;
    }

    // Construct primitive with data.
    void constructor(u8 tagID, u8[] primitiveData)
    {
        this.tag       = tagID;
        this.primitive = true;
        this.tagClass  = ASN1:CLASS_UNIVERSAL;

        this.data = u8[](primitiveData.length());
        for(u64 d=0; d<this.data.length(); d++)
            this.data[d] = primitiveData[d];
    }

    // Construct primitive with data.
    void constructor(u8 tagID, ByteArray primitiveData)
    {
        this.tag       = tagID;
        this.primitive = true;
        this.tagClass  = ASN1:CLASS_UNIVERSAL;

        this.data = u8[](primitiveData.numUsed);
        for(u64 d=0; d<this.data.length(); d++)
            this.data[d] = primitiveData.data[d];
    }

    // Construct primitive with string data.
    void constructor(u8 tagID, String<u8> primitiveData)
    {
        this.tag       = tagID;
        this.primitive = true;
        this.tagClass  = ASN1:CLASS_UNIVERSAL;

        this.data = u8[](primitiveData.numChars);
        for(u64 d=0; d<this.data.length(); d++)
            this.data[d] = primitiveData.chars[d];
    }

    // Write to binary representation (includes all child elements).
    ByteArray write()
    {
        ByteArray b();

        // first, write children
        ArrayList<ByteArray> childData();
        for(u64 c=0; c<this.children.size(); c++)
        {
            ASN1Node childNode = this.children[c];
            childData.add(childNode.write());
        }

        // write ourselves
        if(this.primitive == false || (childData.size() != 0 && data == null)) // we can weird primitives that BIT_STRING or OCTET_STRING that the contents are effectively another DER file.
        {
            u64 childrenLen = 0;
            for(u64 c=0; c<childData.size(); c++)
                childrenLen += childData[c].size();

            if(tag == ASN1:TAG_BIT_STRING && bitStringAddByte == true) // bit strings have a kinda-meta byte at the start that specifies how many "unused" bits are in the string. We always put zero
            {
                u8   tagByte   = ASN1Node:createTagByte(this.tag, this.primitive, this.tagClass);
                u8[] tagLenArr = ASN1Node:createTagLength(1 + childrenLen); // + 1 for bit string meta byte

                b.writeU8(tagByte);
                b.write(tagLenArr);
                b.writeU8(0); // bit string meta byte, 0 unused bytes
                for(u64 c=0; c<childData.size(); c++)
                    b.write(childData[c]);
            }
            else
            {
                u8   tagByte   = ASN1Node:createTagByte(this.tag, this.primitive, this.tagClass);
                u8[] tagLenArr = ASN1Node:createTagLength(childrenLen);

                b.writeU8(tagByte);
                b.write(tagLenArr);
                for(u64 c=0; c<childData.size(); c++)
                    b.write(childData[c]);
            }
        }
        else // primitive
        {
            assert(this.tag != ASN1:TAG_SEQUENCE && this.tag != ASN1:TAG_SET);
            assert(childData.size() == 0);

            u8 tagByte = ASN1Node:createTagByte(this.tag, this.primitive, this.tagClass);
            b.writeU8(tagByte);

            if(data != null)
            {
                if(tag == ASN1:TAG_BIT_STRING && bitStringAddByte == true) // bit strings have a kinda-meta byte at the start that specifies how many "unused" bits are in the string. We always put zero
                {
                    u8[] tagLenArr = ASN1Node:createTagLength(data.length() + 1);
                    b.write(tagLenArr);
                    b.writeU8(0); // zero unused bits
                    b.write(this.data);
                }
                else
                {
                    u8[] tagLenArr = ASN1Node:createTagLength(data.length());
                    b.write(tagLenArr);
                    b.write(this.data);
                }
            }
            else
            {
                b.writeU8(0);
            }
        }

        b.index = 0;
        return b;
    }

    // Add child node
    void addChild(ASN1Node node)
    {
        assert(this != null);
        assert(this.children != null);
        //assert(this.children.data != null);

        this.children.add(node);
    }

    // Create tag byte from components.
    shared u8 createTagByte(u8 tagID, bool primitive, u8 tagClass)
    {
        u8 constructed = 1;
        if(primitive == true)
            constructed = 0;

        return ((tagID & 0b00011111) | ((constructed << 5) & 0b00100000) | ((tagClass << 6) & 0b11000000));
    }

    // Create tag length.
    shared u8[] createTagLength(u64 tagLen)
    {
        // Length octets. There are two forms: short (for lengths between 0 and 127), and long definite (for lengths between 0 and 2^1008 -1).
        // Short form. One octet. Bit 8 has value "0" and bits 7-1 give the length.
        // Long form. Two to 127 octets. Bit 8 of first octet has value "1" and bits 7-1 give the number of additional length octets. Second 
        // and following octets give the length, base 256, most significant digit first. 

        if(tagLen <= 127)
        {
            u8[] lenArr(1);
            lenArr[0] = tagLen;
            return lenArr;
        }

        u64 tempLen = tagLen;
        u64 numLenBytes = 0;
        while(tempLen > 0)
        {
            tempLen = tempLen >>  8;
            numLenBytes++;
        }

        // encode big endian number
        u8[] lenArr(numLenBytes + 1);
        lenArr[0] = 0b10000000 | numLenBytes;
        tempLen = tagLen;
        for(i64 b=lenArr.length()-1; b>=1; b--) // big endian encoding
        {
            lenArr[b] = 0x00000000000000FF & tempLen;
            tempLen = tempLen >> 8;
        }

        return lenArr;
    }

    // Search for OID "key/value" pair.
    String<u8> getOIDStringValue(String<u8> oidStr, ASN1Node parentNode)
    {
        return getOIDStringValue(oidStr, null);
    }

    // Search for OID node, then return it's parent node.
    ASN1Node getOIDNodeParent(String<u8> oidStr, ASN1Node parentNode)
    {
        if(tag == ASN1:TAG_OBJECT_IDENTIFIER)
        {
            String<u8> checkOIDStr = this.decodeOIDToString();
            if(checkOIDStr.compare(oidStr) == true)
            {
                return parentNode;
            }
        }

        // check children
        for(u64 c=0; c<children.size(); c++)
        {
            ASN1Node foundNode = children[c].getOIDNodeParent(oidStr, this);
            if(foundNode != null)
                return foundNode;
        }

        return null;
    }

    // Search for OID "key/value" pair. For simple cases where OID string node is first, then it's sibling has the value.
    ASN1Node getOIDNodeValue(String<u8> oidStr, ASN1Node parentNode)
    {
        if(tag == ASN1:TAG_OBJECT_IDENTIFIER)
        {
            String<u8> checkOIDStr = this.decodeOIDToString();
            if(checkOIDStr.compare(oidStr) == true)
            {
                if(parentNode != null)
                {
                    if(parentNode.children.size() >= 2)
                    {
                        ASN1Node valNode = parentNode.children[1];
                        return valNode;
                    }
                }
            }
        }

        // check children
        for(u64 c=0; c<children.size(); c++)
        {
            ASN1Node foundNode = children[c].getOIDNodeValue(oidStr, this);
            if(foundNode != null)
                return foundNode;
        }

        return null;
    }

    // Search for OID "key/value" pair as string.
    String<u8> getOIDStringValue(String<u8> oidStr, ASN1Node parentNode)
    {
        ASN1Node valNode = this.getOIDNodeValue(oidStr, parentNode);

        if(valNode == null)
            return "";

        return String<u8>(valNode.data);
    }

    // Decode a integer from data bytes.
    BigInt decodeInteger()
    {
        u8[] bytes = this.data;

        if(bytes == null)
            return BigInt();

        if(bytes.length() == 0)
            return BigInt();

        BigInt n();
        n.sign = 0;

        // first byte could be special "0" to indicate positive value

        u64 firstByteIndex = 0;
        if(bytes[0] == 0)
        {
            n.sign = 1;
            firstByteIndex++; // skip
        }
        else
        {
            // could be negative or positive, check first bit high bit
            if((bytes[0] & 0b10000000) != 0)
            {
                n.sign = -1; // negative
                bytes[0] = bytes[0] & 0b01111111; // we'll revert this before returning
            }
            else
                n.sign = 1; // positive
        }
        
        for(u64 i=firstByteIndex; i<bytes.length(); i++)
        {
            // this is slow but easy
            n.shiftLeft(8);
            n.add(i32(bytes[i]));
        }

        // revert first byte to original form 
        if(n.sign == -1)
            bytes[0] = bytes[0] | 0b10000000;

        return n;
    }

    // Encode an integer value to this node
    void encodeInteger(BigInt i)
    {
        u8[] numAsBytes = i.asBytesBigEndian();
        if(numAsBytes.length() == 0)
        {
            this.data = u8[](1);
            
            if(i.isNegative() == true)
                this.data[0] = 0b10000000;
            else
                this.data[0] = 0;

            return;
        }

        if(i.isPositive() == true)
        {
            if((numAsBytes[0] & 0b10000000) > 0)
            {
                this.data = u8[](numAsBytes.length() + 1);
                this.data[0] = 0; // need extra zero byte to indicate positive value
                for(u64 c=0; c<numAsBytes.length(); c++)
                    this.data[1 + c] = numAsBytes[c];
            }
            else
            {
                this.data = u8[](numAsBytes.length());
                for(u64 c=0; c<numAsBytes.length(); c++)
                    this.data[c] = numAsBytes[c];
            }
        }
        else
        {
            this.data = u8[](numAsBytes.length() + 1);
            this.data[0] = 0b10000000; // indicates negative value
            for(u64 c=0; c<numAsBytes.length(); c++)
                this.data[1 + c] = numAsBytes[c];
        }   
    }

    // Decode UTC time, example "170821052741Z" where format is YYMMDDhhmmssTZ
    CalendarDateTime decodeUTCTime()
    {
        String<u8> s = String<u8>(this.data);

        if(s.length() < 12)
            return CalendarDateTime();

        String<u8> yearStr   = s.subString(0, 1);
        String<u8> monthStr  = s.subString(2, 3);
        String<u8> dayStr    = s.subString(4, 5);
        String<u8> hourStr   = s.subString(6, 7);
        String<u8> minuteStr = s.subString(8, 9);
        String<u8> secondStr = s.subString(10, 11);

        // UTCTime values take the form of either "YYMMDDhhmm[ss]Z" or "YYMMDDhhmm[ss](+|-)hhmm". The first form indicates (by the literal letter "Z")
        // UTC time. The second form indicates a time that differs from UTC by plus or minus the hours and minutes represented by the final "hhmm".
        // These forms differ from GeneralizedTime in several notable ways: the year is represented by two digits rather than four, fractional seconds 
        // cannot be represented (note that seconds are still optional), and values not ending with either a literal "Z" or the form "(+|-)hhmm" are not permitted. 

        i16 timeZoneOffset = 0;
        if(s.length() >= 14)
        {
            String<u8> tzStr = s.subString(12, 13);
            timeZoneOffset = tzStr.parseInteger() * 60; // * 60 because timeZoneOffset in minutes, not hours
        }

        // void constructor(i16 year, i16 month, i16 day, i16 hour, i16 minute, i16 second, i16 timeZoneOffset)
        return CalendarDateTime(2000 + yearStr.parseInteger(), monthStr.parseInteger(), dayStr.parseInteger(), hourStr.parseInteger(), minuteStr.parseInteger(), secondStr.parseInteger(), timeZoneOffset);
    }

    // Decode UTC time, example "170821052741Z" where format is YYMMDDhhmmssTZ
    void encodeUTCTime(CalendarDateTime dateTime)
    {
        this.data = u8[](13);

        CalendarDateTime dt(dateTime);

        // always write GMT date/time
        u8 year  = dt.getYearGMT() - 2000; // 0 to 99
        u8 month = dt.getMonthGMT();  // 1 to 12
        u8 day   = dt.getDayGMT();    // 1 to 31
        u8 hour  = dt.getHourGMT();   // 0 to 23
        u8 min   = dt.getMinuteGMT(); // 0 to 59
        u8 sec   = dt.getSecondGMT(); // 0 to 59
        //i16 tz   = dt.getTimeZoneOffset(); // -1440 to 1440 timezone offset in minutes.

        writeCalendar2Digits(data, 0, year);
        writeCalendar2Digits(data, 2, month);
        writeCalendar2Digits(data, 4, day);

        writeCalendar2Digits(data, 6,  hour);
        writeCalendar2Digits(data, 8,  min);
        writeCalendar2Digits(data, 10, sec);

        this.data[12] = Chars:Z; // indicate UTC+00 time
    }

    // Write calendar year/month/day/hour/min/sec into b.
    void writeCalendar2Digits(u8[] b, u32 bIndex, u8 val)
    {
        if(val < 10)
        {
            b[bIndex]   = Chars:ZERO;
            b[bIndex+1] = Chars:ZERO + val;
        }
        else
        {
            u8 tens = val / 10;
            u8 ones = val - (tens * 10);

            b[bIndex]   = Chars:ZERO + tens;
            b[bIndex+1] = Chars:ZERO + ones;
        }
    }

    // Decode a OID from bytes to string form, i.e. bytes "2b 06 01 04 01 82 37 15 14" is "1.3.6.1.4.1.311.21.20"
    String<u8> decodeOIDToString()
    {
        u8[] bytes = this.data;

        if(bytes == null)
            return "";

        if(bytes.length() == 0)
            return "";

        String<u8> s(bytes.length() * 4);

        // first byte represents two numbers with bizarre encoding because I guess "efficiency" reasons :-|
        u32 num1 = bytes[0] / 40;
        u32 num2 = bytes[0] - (num1 * 40);

        s.append(String<u8>:formatNumber(num1));
        s.append(Chars:PERIOD);
        s.append(String<u8>:formatNumber(num2));

        // now each byte is a single number 0 to 127 inclusive, or is the high bit is set it's a multi-byte number
        u64 multiByteNum = 0; // theoretically ASN1 supports numbers larger than 64 bits, but we don't support and it shouldn't come up in real world for OIDs
        for(u64 i=1; i<bytes.length(); i++)
        {
            u8 nextByte = bytes[i];
            if(multiByteNum == 0)
            {
                if((nextByte & 0b10000000) == 0) // value is less than or equal to 127
                {
                    s.append(Chars:PERIOD);
                    s.append(String<u8>:formatNumber(nextByte));
                }
                else // multi-byte number
                {
                    multiByteNum = nextByte & 0b01111111; // drop top bit
                }
            }
            else // "add" next byte to bigNum
            {
                multiByteNum = multiByteNum << 7;
                multiByteNum |= (nextByte & 0b01111111);

                if((nextByte & 0b10000000) == 0) // last byte of multi-byte number
                {
                    s.append(Chars:PERIOD);
                    s.append(String<u8>:formatNumber(multiByteNum));

                    multiByteNum = 0;
                }
            }
        }

        return s;
    }

    // Decode a OID from bytes to string form, i.e. bytes "2b 06 01 04 01 82 37 15 14" is "1.3.6.1.4.1.311.21.20"
    void encodeOIDFromString(String<u8> str)
    {
        assert(str != null);
        if(str == null)
            return;
        
        ArrayList<String<u8>> numsStrs = str.split(Chars:PERIOD);
        ArrayList<u64> nums();
        for(u64 i=0; i<numsStrs.size(); i++)
            nums.add(numsStrs[i].parseInteger());

        if(nums.size() == 0)
            return;

        if(nums.size() == 1)
        {
            this.data = u8[](1);
            this.data[0] = nums[0] * 40;
            return;
        }
        
        ByteArray oidBytes();

        // first byte represents two numbers with bizarre encoding because I guess "efficiency" reasons :-|
        //u32 num1 = bytes[0] / 40;
        //u32 num2 = bytes[0] - (num1 * 40);
        oidBytes.writeU8((nums[0] * 40) | nums[1]);

        for(u64 n=2; n<nums.size(); n++)
        {
            u64 num = nums[n]; // theoretically ASN1 supports numbers larger than 64 bits, but we don't support and it shouldn't come up in real world for OIDs

            if(num <= 127)
            {
                oidBytes.writeU8(num);
            }
            else // multi-byte needed
            {
                u64 numBytesNeeded = 0;
                u8[10] bits; // ceil(64 / 7) = 10
                while(num > 0)
                {
                    bits[numBytesNeeded] = u8(num) & 0b01111111;
                    num = num >> 7;
                    numBytesNeeded++;
                }

                for(i64 b=numBytesNeeded-1; b>=0; b--) // reverse order because big endian
                {
                    if(b != 0)
                        oidBytes.writeU8(0b10000000 | bits[b]);
                    else
                        oidBytes.writeU8(bits[b]); // indicate end of multi-byte number because high bit is zero
                }
            }
        }

        this.data = oidBytes.toArray();
    }

    shared ASN1Node createOIDNode(String<u8> oid)
    {
        ASN1Node n(ASN1:TAG_OBJECT_IDENTIFIER);
        n.encodeOIDFromString(oid);
        return n;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// ASN1
////////////////////////////////////////////////////////////////////////////////////////////////////

// Partial ASN.1 (Abstract Syntax Notation) DER parser. Just enough to support X509 certificates for
// TLS applications. This represents the ASN.1 tree root (AKA document).
class ASN1
{
    // ASN1 SCOPE
    const u8 CLASS_UNIVERSAL   = 0;
    const u8 CLASS_APPLICATION = 1;
    const u8 CONTEXT_SPECIFIC  = 2;
    const u8 PRIVATE           = 3;

    // ASN1 TAG TYPES (INCOMPLETE LIST)
    const u8 TAG_BER                  = 0;
    const u8 TAG_BOOLEAN              = 1;
    const u8 TAG_INTEGER              = 2;
    const u8 TAG_BIT_STRING           = 3;
    const u8 TAG_OCTET_STRING         = 4;
    const u8 TAG_NULL                 = 5;
    const u8 TAG_OBJECT_IDENTIFIER    = 6;
    const u8 TAG_OBJECT_DESCRIPTOR    = 7;
    const u8 TAG_INSTANCE_OF_EXTERNAL = 8;
    const u8 TAG_REAL                 = 9;
    const u8 TAG_ENUMERATED           = 10;
    const u8 TAG_EMBEDDED_PPV         = 11;
    const u8 TAG_UTF8_STRING          = 12;
    const u8 TAG_RELATIVE_OID         = 13;
    const u8 TAG_SEQUENCE             = 16; // Ordered set
    const u8 TAG_SET                  = 17; // Unordered set
    const u8 TAG_NUMERIC_STRING       = 18;
    const u8 TAG_PRINTABLE_STRING     = 19;
    const u8 TAG_TELETEX_STRING       = 20;
    const u8 TAG_T61_STRING           = 20;
    const u8 TAG_VIDEOTEX_STRING      = 21;
    const u8 TAG_IA5_STRING           = 22;
    const u8 TAG_UTC_TIME             = 23;
    const u8 TAG_GENERALIZED_TIME     = 24;
    const u8 TAG_GRAPHIC_STRING       = 25;
    const u8 TAG_VISIBLE_STRING       = 26;
    const u8 TAG_ISO64_STRING         = 26;
    const u8 TAG_GENERAL_STRING       = 27;
    const u8 TAG_UNIVERSAL_STRING     = 28;
    const u8 TAG_CHARACTER_STRING     = 29;
    const u8 TAG_BMP_STRING           = 30;

    // these exist soley for implementation, not part of ASN.1 standard
    const u8 TAG_UNDEFINED = 254;
    const u8 TAG_ROOT = 255;

    ASN1Node rootNode = null;
    String<u8> parseErrors();

    void constructor()
    {

    }

    // Parse ASN.1 DER into in-memory tree representation.
    bool parse(ByteArray b)
    {
        parseErrors.clear();

        if(b == null)
            return false;

        if(b.data == null)
            return false;

        rootNode = ASN1Node();
        rootNode.tag = TAG_ROOT;
        bool res = parseChildNodes(b, b.numUsed-1, rootNode, 1);

        return res;
    }

    // Parse a child nodes and then any of their children recursively.
    bool parseChildNodes(ByteArray b, u64 maxBIndex, ASN1Node parentNode, u32 level)
    {
        // Decent intro to ASN.1 http://luca.ntop.org/Teaching/Appunti/asn1.html
        // We only handle DER encoding of ASN.1 here, which is a subset of BER encoding.
        // DER Restrictions:
        // 1. Length must use minimum representation (i.e. one byte for 0 to 127 length strings etc.).
        // 2. Simple string types must use definite-length encoding.
        // 3. Strucutred types: the constructed definite-length method must be used.

        while(b.index <= maxBIndex)
        {
            u64 tagIDIndex = b.index;

            u8 tagByte = b.readU8();
            u8 tagID   = tagByte & 0b00011111;
            bool tagPrimitive = true;
            if((tagByte & 0b00100000) > 0)
                tagPrimitive = false;

            // If all bits 5-1 all are 1 then this tag is encoding tags > 31. X509 certificates do not usually need these types, but we read them anyways...
            if((tagByte & 0b00011111) == 0b00011111)
            {
                /* we don't handle
                // > 31 tag id, read multi-byte
                tag = 0;
                while(b.data[b.index] & 0x80)
                {
                    tag = tag << 8;
                    tag |= b.readU8() & 0x7F;
                }*/

                parseErrors.append("ERROR unsupported tag > 31");
                return false;
            }

            u8  tagLenByte = b.readU8();
            u64 tagLen = 0;

            // Length octets. There are two forms: short (for lengths between 0 and 127), and long definite (for lengths between 0 and 2^1008 -1).
            // Short form. One octet. Bit 8 has value "0" and bits 7-1 give the length.
            // Long form. Two to 127 octets. Bit 8 of first octet has value "1" and bits 7-1 give the number of additional length octets. Second 
            // and following octets give the length, base 256, most significant digit first. 
            if(tagLenByte & 0b10000000)
            {
                u8 numLenBytes = tagLenByte & 0b01111111;

                for(u8 q=0; q<numLenBytes; q++)
                {
                    tagLen = tagLen << 8;
                    tagLen |= b.readU8();
                }
            }
            else
                tagLen = tagLenByte;

            if((b.index + tagLen) > b.numUsed) // clearly too large
            {
                parseErrors.append("ERROR: too-larger tagLen: " + String<u8>:formatNumber(tagLen) + " b.index=" + String<u8>:formatNumber(b.index) + " b.numUsed = " + String<u8>:formatNumber(b.numUsed) + "\n");
                return false;
            }

            u8 bitsPadding = 0;
            if(tagID == TAG_BIT_STRING)
            {
                // "In a primitive encoding, the first contents octet gives the number of bits by which 
                // the length of the bit string is less than the next multiple of eight (this is called the "number of unused bits")"

                if(tagPrimitive == true)
                {
                    bitsPadding = b.readU8(); // bit string first byte specified padding for non-multiple of 8 bit string. 
                    
                    // Shouldn't matter for X509 certificates, should always be zero, or if used (i.e. 2047 bits) for big endian it should be zero filled so we don't have to do anything.

                    tagLen--; // we don't include this byte in bit string
                }
                // else no padding byte assumed
            }

            u64 childStartIndex = b.index;

            ASN1Node node();
            node.primitive = tagPrimitive;
            node.tagClass  = (tagByte & 0xC0) >> 6;
            node.tag       = tagID;

            // all data including header
            node.allData = u8[]((b.index - tagIDIndex) + tagLen);
            b.index = tagIDIndex;
            b.read(node.allData.length(), node.allData); // copy data

            // data without header bytes
            b.index = childStartIndex;
            node.data = u8[](tagLen);
            b.read(tagLen, node.data); // copy data

            parentNode.children.add(node);

            if(tagID == TAG_BIT_STRING && bitsPadding != 0)
            {
                // we don't need to do anything because the highest bits (end of bit string) are just zeros (ignored)
            }

            if(node.primitive == false)
            {
                // Read child nodes
                b.index = childStartIndex;
                if(parseChildNodes(b, childStartIndex + tagLen - 1, node, level + 1) == false)
                    return false;
            }

            // Read next child component node if any data left...
        }

        return true;
    }

    // Get string name for tagName id
    shared String<u8> getTagNameStr(u8 id)
    {
        if(id == TAG_BER) return "BER";
        if(id == TAG_BOOLEAN) return "BOOLEAN";
        if(id == TAG_INTEGER) return "INTEGER";
        if(id == TAG_BIT_STRING) return "BIT STRING";
        if(id == TAG_OCTET_STRING) return "OCTET STRING";
        if(id == TAG_NULL) return "NULL";
        if(id == TAG_OBJECT_IDENTIFIER) return "OBJECT IDENTIFIER";
        if(id == TAG_OBJECT_IDENTIFIER) return "ObjectDescriptor";
        if(id == TAG_INSTANCE_OF_EXTERNAL) return "INSTANCE OF, EXTERNAL";
        if(id == TAG_REAL) return "REAL";
        if(id == TAG_ENUMERATED) return "ENUMERATED";
        if(id == TAG_EMBEDDED_PPV) return "EMBEDDED PPV";
        if(id == TAG_UTF8_STRING) return "UTF8String";
        if(id == TAG_RELATIVE_OID) return "RELATIVE-OID";
        if(id == TAG_SEQUENCE) return "SEQUENCE, SEQUENCE OF";
        if(id == TAG_SET) return "SET, SET OF";
        if(id == TAG_NUMERIC_STRING) return "NumericString";
        if(id == TAG_PRINTABLE_STRING) return "PrintableString";
        if(id == TAG_TELETEX_STRING) return "TeletexString, T61String";
        if(id == TAG_VIDEOTEX_STRING) return "VideotexString";
        if(id == TAG_IA5_STRING) return "IA5String";
        if(id == TAG_UTC_TIME) return "UTCTime";
        if(id == TAG_GENERALIZED_TIME) return "GeneralizedTime";
        if(id == TAG_GRAPHIC_STRING) return "GraphicString";
        if(id == TAG_VISIBLE_STRING) return "VisibleString, ISO64String";
        if(id == TAG_GENERAL_STRING) return "GeneralString";
        if(id == TAG_UNIVERSAL_STRING) return "UniversalString";
        if(id == TAG_CHARACTER_STRING) return "CHARACTER STRING";
        if(id == TAG_BMP_STRING) return "BMPString";

        if(id == TAG_ROOT) return "ROOT"; // this is not a real ASN1 tag, it's just for our implementation
        if(id == TAG_UNDEFINED) return "UNDEFINED"; // this is not a real ASN1 tag, it's just for our implementation

        return "BAD_VAL";
    }

    // This provides a string representation of the ASN.1 parsed DER file.
    String<u8> toString()
    {
        String<u8> s(2048);

        toString(s, rootNode, 0);

        return s;
    }

    // This provides a string representation of the ASN.1 node (and any children).
    void toString(String<u8> s, ASN1Node node, u32 level)
    {
        if(node == null)
            return;

        for(u32 d=0; d<level; d++)
            s.append("\t");

        if(node.tagClass == CLASS_UNIVERSAL)
        {
            String<u8> tagNameID = ASN1:getTagNameStr(node.tag);
            s.append("TN: " + tagNameID);
        }
        else if(node.tagClass == CLASS_APPLICATION)
        {
            s.append("CLASS_APPLICATION");
        }
        else if(node.tagClass == CONTEXT_SPECIFIC)
        {
            s.append("CONTEXT_SPECIFIC");
        }
        else if(node.tagClass == PRIVATE)
        {
            s.append("PRIVATE");
        }
        else
        {
            s.append("UNKNOWN TAG_CLASS: " + String<u8>:formatNumber(node.tagClass));
        }

        if(node.primitive == false)
        {
            s.append(" (CONSTRUCTED) ");
        }
        else
        {
            s.append(" (PRIMITIVE) ");
        }

        s.append(" [len=");
        if(node.data != null)
            s.append(String<u8>:formatNumber(node.data.length()));
        else
            s.append("0");
        s.append("] ");
        
        if(node.tag == TAG_NUMERIC_STRING || node.tag == TAG_PRINTABLE_STRING || node.tag == TAG_TELETEX_STRING || 
            node.tag == TAG_VIDEOTEX_STRING || node.tag == TAG_IA5_STRING || node.tag == TAG_UTC_TIME || 
            node.tag == TAG_GENERALIZED_TIME || node.tag == TAG_GRAPHIC_STRING || node.tag == TAG_VISIBLE_STRING || 
            node.tag == TAG_GENERAL_STRING || node.tag == TAG_UNIVERSAL_STRING || node.tag == TAG_CHARACTER_STRING || 
            node.tag == TAG_BMP_STRING || node.tag == TAG_UTF8_STRING)
        {
            if(node.data != null)
                s.append(String<u8>(node.data));
            else
                s.append("NULL_DATA");
        }

        if(node.tag == TAG_OBJECT_IDENTIFIER)
        {
            if(node.data != null)
            {
                s.append("OID: " + node.decodeOIDToString());
            }
            else
            {
                s.append("OID_NO_DATA");
            }
        }

        if(node.tag == TAG_INTEGER)
        {
            if(node.data != null)
            {
                s.append("INT: " + node.decodeInteger().toString());
            }
            else
            {
                s.append("INT_NO_DATA");
            }
        }
        
        s.append(Chars:NEW_LINE);

        if(node.children == null)
            return;

        for(u64 c=0; c<node.children.size(); c++)
        {
            ASN1Node childNode = node.children[c];
            toString(s, childNode, level + 1);
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// X509Name
////////////////////////////////////////////////////////////////////////////////////////////////////

// A named entity in a certificate. The certificate issuer (certificate authority, AKA CA) and
// the user (certificate subject, AKA the domain owner) are named entities.
class X509Name
{
    String<u8> domain(); // AKA common name field
    String<u8> country();
    String<u8> state();    // state or provience
    String<u8> city();     // "local"
    String<u8> org();      // company name etc.
    String<u8> orgUnit();  // company unit name, specific to company

    // Empty name
    void constructor()
    {

    }

    // All field initialization
    void constructor(String<u8> domain, String<u8> country, String<u8> state, String<u8> city, String<u8> org, String<u8> orgUnit)
    {
        this.domain  = String<u8>(domain);
        this.country = String<u8>(country);
        this.state   = String<u8>(state);
        this.city    = String<u8>(city);
        this.org     = String<u8>(org);
        this.orgUnit = String<u8>(orgUnit);
    }

    // All field initialization
    void constructor(X509Name n)
    {
        this.domain  = String<u8>(n.domain);
        this.country = String<u8>(n.country);
        this.state   = String<u8>(n.state);
        this.city    = String<u8>(n.city);
        this.org     = String<u8>(n.org);
        this.orgUnit = String<u8>(n.orgUnit);
    }

    // All six fields, one per line.
    String<u8> toString()
    {
        String<u8> s();

        s.append("Domain: " + domain + "\n");
        s.append("Country: " + country + "\n");
        s.append("State: " + state + "\n");
        s.append("City: " + city + "\n");
        s.append("Organization: " + org + "\n");
        s.append("OrgUnit: " + orgUnit);

        return s;
    }

    X509Name clone()
    {
        return X509Name(this.domain, this.country, this.state, this.city, this.org, this.orgUnit);
    }

    // Create ASN tree for this for X509 name.
    ASN1Node createASN1Node()
    {
        ASN1Node root(ASN1:TAG_SEQUENCE, false, ASN1:CLASS_UNIVERSAL);

        ASN1Node countryNode = createASN1OIDStrNode(u8[](0x55, 0x04, 0x06), country);
        root.children.add(countryNode);

        ASN1Node stateNode = createASN1OIDStrNode(u8[](0x55, 0x04, 0x08), state);
        root.children.add(stateNode);

        ASN1Node cityNode = createASN1OIDStrNode(u8[](0x55, 0x04, 0x07), city);
        root.children.add(cityNode);

        ASN1Node orgNode = createASN1OIDStrNode(u8[](0x55, 0x04, 0x0A), org);
        root.children.add(orgNode);

        ASN1Node orgUnitNode = createASN1OIDStrNode(u8[](0x55, 0x04, 0x0B), orgUnit);
        root.children.add(orgUnitNode);

        ASN1Node commonNode = createASN1OIDStrNode(u8[](0x55, 0x04, 0x03), domain);
        root.children.add(commonNode);

        return root;
    }

    // Create ASN tree for a oid+string this for X509.
    ASN1Node createASN1OIDStrNode(u8[] oid, String<u8> str)
    {
        ASN1Node setNode(ASN1:TAG_SET, false, ASN1:CLASS_UNIVERSAL);

        ASN1Node seqNode(ASN1:TAG_SEQUENCE, false, ASN1:CLASS_UNIVERSAL);
        setNode.children.add(seqNode);

        ASN1Node oidNode(ASN1:TAG_OBJECT_IDENTIFIER, oid);
        seqNode.children.add(oidNode);
        
        ASN1Node strNode(ASN1:TAG_PRINTABLE_STRING, str);
        seqNode.children.add(strNode);

        return setNode;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// X509Certificate
////////////////////////////////////////////////////////////////////////////////////////////////////

// X.509 certificates representation. Can read and parse PEM files and DER files directly. (.pem, 
// .crt, .cert etc.). Note that this class is really only designed to deal with typical X509 
// certificates used with TLS (AKA SSL, HTTPS). Atypical certificate types or extensions are not 
// supported.
class X509Certificate
{
    // X509 certificate format version
    const u8 CERT_VERSION_1 = 0; // default
    const u8 CERT_VERSION_2 = 1; // exteremely uncommon, we don't support explicitly
    const u8 CERT_VERSION_3 = 2; // supported (not all extensions)

    // X509 Signing algorithm - WIP to support ECC etc. Basic RSA/SHA combos supported 
    const u8 SIGNATURE_TYPE_NULL           = 0; // unknown/error
    const u8 SIGNATURE_TYPE_RSA_SHA1       = 1;
    const u8 SIGNATURE_TYPE_RSA_SHA224     = 2;
    const u8 SIGNATURE_TYPE_RSA_SHA256     = 3;
    const u8 SIGNATURE_TYPE_RSA_SHA384     = 4;
    const u8 SIGNATURE_TYPE_RSA_SHA512     = 5;
    const u8 SIGNATURE_TYPE_DSA_SHA1       = 6;
    const u8 SIGNATURE_TYPE_DSA_SHA224     = 7;
    const u8 SIGNATURE_TYPE_DSA_SHA256     = 8;
    const u8 SIGNATURE_TYPE_ECDSA_SHA1     = 9;
    const u8 SIGNATURE_TYPE_ECDSA_SHA224   = 10;
    const u8 SIGNATURE_TYPE_ECDSA_SHA256   = 11;
    const u8 SIGNATURE_TYPE_ECDSA_SHA384   = 12;
    const u8 SIGNATURE_TYPE_ECDSA_SHA512   = 13;
    const u8 SIGNATURE_TYPE_UNSUPPORTED    = 255;

    // Public key type
    const u8 PUBLIC_KEY_TYPE_NULL  = 0; // unknown/error
    const u8 PUBLIC_KEY_TYPE_RSA   = 1; // Rivest–Shamir–Adleman
    const u8 PUBLIC_KEY_TYPE_DSA   = 2; // Digital Signature Algorithm
    const u8 PUBLIC_KEY_TYPE_ECDSA = 3; // Elliptic Curve Digital Signature Algorithm
    
    // Version 1 and 3 fields
    u8   certVersion    = CERT_VERSION_1; // v1=0, v2=1, v3=2
    u8   signatureType  = SIGNATURE_TYPE_NULL;
    ByteArray signatureBytes = null;
    BigInt serialNumber(); // Unique id of this certificate, used for checking for revoked certificates normally
    X509Name issuer();     // Certificate authority (CA)
    X509Name subject();    // Certificate creator (i.e. domain owner) or Certificate Authority (CA) if this is a root certificate
    CalendarDateTime startDate();  // start of validity period
    CalendarDateTime expiryDate(); // end of validity period
    RSAPublicKey   rsaPublicKey   = null; // RSA public key
    DSAPublicKey   dsaPublicKey   = null; // DSA public key
    ECDSAPublicKey ecdsaPublicKey = null; // ECDSA public key

    // Version 3 fields (extensions, we don't try to handle all of them)
    ByteArray authorityKey(); // unique id of authority (rather than just using common name)
    ByteArray subjectKey();   // unique id of subject (rather than just using common name)
    ArrayList<String<u8>> subjectAltDomains(); // additional domains certified by this certificate
    bool rootCert = false; // is this a certificate authority (CA) root certificate that can be used to sign other certificates?
    
    // File/hash
    ByteArray certFile = null; // if not null, DER encoded certificate file.
    ByteArray tbsRecordBytes = null; // DER encoded part of file that has certificate record. This is the part that is hash-signature checked
    u8[] tbsRecordHash = null; // if not null, hash of DER encoded TBS record certificate bytes (not the whole cert file, but the inner part not including signature)

    // Empty certificate.
    void constructor()
    {

    }

    // Copy constructor.
    void constructor(X509Certificate c)
    {
        this.certVersion = c.certVersion;
        this.signatureType = c.signatureType;
        this.signatureBytes = ByteArray(c.signatureBytes);
        this.serialNumber   = BigInt(c.serialNumber);
        this.issuer         = X509Name(c.issuer);
        this.subject        = X509Name(c.subject);
        this.startDate      = CalendarDateTime(c.startDate);
        this.expiryDate     = CalendarDateTime(c.expiryDate);

        if(c.rsaPublicKey != null)
            this.rsaPublicKey = RSAPublicKey(c.rsaPublicKey);
        if(c.dsaPublicKey != null)
            this.dsaPublicKey = DSAPublicKey(c.dsaPublicKey);
        if(c.ecdsaPublicKey != null)
            this.ecdsaPublicKey = ECDSAPublicKey(c.ecdsaPublicKey);

        if(c.authorityKey != null)
            this.authorityKey = ByteArray(c.authorityKey);
        if(c.subjectKey != null)
            this.subjectKey = ByteArray(c.subjectKey);

        for(u64 s=0; s<c.subjectAltDomains.size(); s++)
            this.subjectAltDomains.add(String<u8>(c.subjectAltDomains[s]));

        this.rootCert = c.rootCert;

        if(c.certFile != null)
            this.certFile = ByteArray(c.certFile);
        if(c.tbsRecordBytes != null)
            this.tbsRecordBytes = ByteArray(c.tbsRecordBytes);
        if(c.tbsRecordHash != null)
            this.tbsRecordHash = c.tbsRecordHash.clone();
    }

    // Get RSA public key (if available).
    RSAPublicKey getRSAPublicKey()
    {
        return this.rsaPublicKey;
    }

    // All fields, one per line.
    String<u8> toString()
    {
        String<u8> s();

        // Version 1 and 3 fields

        s.append("Version: " + String<u8>:formatNumber(certVersion + 1) + "\n");
        s.append("Signature Type: " + getSignatureTypeString(signatureType) + "\n");
        if(signatureBytes != null)
            s.append("Signature: " + signatureBytes.toHexString(false) + "\n");

        s.append("Serial: " + serialNumber.toString(10) + "\n");

        String<u8> issuerStr = issuer.toString();
        issuerStr.replaceAll("\n", "\n\t");
        s.append("Issuer:\n\t" + issuerStr + "\n");

        String<u8> subjectStr = subject.toString();
        subjectStr.replaceAll("\n", "\n\t");
        s.append("Subject:\n\t" + subjectStr + "\n");

        s.append("Start Date: " + startDate.toString() + "\n");
        s.append("Expiry Date: " + expiryDate.toString() + "\n");

        if(this.rsaPublicKey != null)
        {
            String<u8> rsaStr = rsaPublicKey.toString();
            rsaStr.replaceAll("\n", "\n\t");
            s.append("RSA Public Key:\n\t" + rsaStr + "\n");
        }
        else if(this.dsaPublicKey != null)
        {
            String<u8> dsaStr = dsaPublicKey.toString();
            dsaStr.replaceAll("\n", "\n\t");
            s.append("DSA public key type, key:\n\t" + dsaStr + "\n");
        }
        else if(this.ecdsaPublicKey != null)
        {
            String<u8> ecdsaStr = ecdsaPublicKey.toString();
            ecdsaStr.replaceAll("\n", "\n\t");
            s.append("ECDSA public key type, key:\n\t" + ecdsaStr + "\n");
        }
        else
        {
            s.append("Unknown Public Key Type!" + "\n");
        }

        // Version 3 fields
        if(this.rootCert == false)
            s.append("Subject Type: End-Entity\n");
        else
            s.append("Subject Type: Certificate Authority\n");

        if(authorityKey != null)
            s.append("Authority Key: " + authorityKey.toHexString(false) + "\n");

        if(subjectKey != null)
            s.append("Subject Key: " + subjectKey.toHexString(false) + "\n");

        s.append("Subject Alternate Domains:\n");
        for(u64 d=0; d<subjectAltDomains.size(); d++)
        {
            s.append("\t" + subjectAltDomains[d] + "\n");
        }

        return s;
    }

    // Is this certificate an end-entity (AKA a website, software provider etc.).
    bool isEndEntity()
    {
        if(rootCert == false)
            return true;

        return false;
    }

    // Is this certificate date valid for the current time?
    bool isDateValid()
    {
        DateTime currentDateTime();

        // datetime within range check
        if(currentDateTime.withinRange(startDate, expiryDate) == true)
            return true;

        return false;
    }

    // Used for verifying signature. Can return null if we can't calculate etc.
    u8[] getTBSRecordHash()
    {
        if(tbsRecordBytes == null)
            return null;

        if(this.tbsRecordHash == null)
        {
            if(this.signatureType == SIGNATURE_TYPE_RSA_SHA1)
            {
                this.tbsRecordHash = Hashing:hash(tbsRecordBytes, Hashing:HASH_SHA1);
            }
            else if(this.signatureType == SIGNATURE_TYPE_RSA_SHA256)
            {
                this.tbsRecordHash = Hashing:hash(tbsRecordBytes, Hashing:HASH_SHA256);
            }
        }
        
        return this.tbsRecordHash;
    }

    // Signature string name for constant
    String<u8> getSignatureTypeString(u8 signType)
    {
        if(signType == SIGNATURE_TYPE_RSA_SHA1)
            return "RSA SHA1";
        if(signType == SIGNATURE_TYPE_RSA_SHA224)
            return "RSA SHA224";
        if(signType == SIGNATURE_TYPE_RSA_SHA256)
            return "RSA SHA256";
        if(signType == SIGNATURE_TYPE_RSA_SHA384)
            return "RSA SHA384";
        if(signType == SIGNATURE_TYPE_RSA_SHA512)
            return "RSA SHA512";

        if(signType == SIGNATURE_TYPE_DSA_SHA1)
            return "DSA SHA1";
        if(signType == SIGNATURE_TYPE_DSA_SHA224)
            return "DSA SHA224";
        if(signType == SIGNATURE_TYPE_DSA_SHA256)
            return "DSA SHA256";

        if(signType == SIGNATURE_TYPE_ECDSA_SHA1)
            return "ECDSA SHA1";
        if(signType == SIGNATURE_TYPE_ECDSA_SHA224)
            return "ECDSA SHA224";
        if(signType == SIGNATURE_TYPE_ECDSA_SHA256)
            return "ECDSA SHA256";
        if(signType == SIGNATURE_TYPE_ECDSA_SHA384)
            return "ECDSA SHA384";
        if(signType == SIGNATURE_TYPE_ECDSA_SHA512)
            return "ECDSA SHA512";

        return "UNKNOWN";
    }

    // Public key type name for constant
    String<u8> getPublicKeyTypeString(u8 pubKeyType)
    {
        if(pubKeyType == PUBLIC_KEY_TYPE_RSA)
            return "RSA";
        if(pubKeyType == PUBLIC_KEY_TYPE_DSA)
            return "DSA";
        if(pubKeyType == PUBLIC_KEY_TYPE_ECDSA)
            return "ECDSA";

        return "UNKNOWN";
    }

    // Write certificate to base 64 text (of DER file) signed with an RSA private key.
    String<u8> writeSignedCertificateBase64(RSAKey issuerKey)
    {
        String<u8> s(2048);

        ByteArray b = writeSignedCertificateFile(issuerKey);
        if(b == null)
            return s;

        s += "-----BEGIN CERTIFICATE-----\n";

        String<u8> b64Str = FileSystem:encodeBytesToBase64(b);
        b64Str.insertRegular(80, Chars:NEW_LINE);
        s += b64Str;

        s += "-----END CERTIFICATE-----\n";

        return s;
    }

    // Write certificate to DER file signed with an RSA private key.
    ByteArray writeSignedCertificateFile(RSAKey issuerKey)
    {
        if(issuerKey == null)
            return null;

        bool primitive   = true;
        bool constructed = false;

        // Construct ASN1 tree of nodes that represents file.
        ASN1Node rootSeqNode(ASN1:TAG_SEQUENCE, constructed, ASN1:CLASS_UNIVERSAL);

        // First level down has 3 children

        // TBS Certificate
        ASN1Node certNode = createCertNode();
        rootSeqNode.addChild(certNode);

        // generate signature of tbs cert node
        ByteArray tbsCert = certNode.write();
        if(signatureType == SIGNATURE_TYPE_RSA_SHA1)
        {
            u8[] hashVal = Hashing:hash(tbsCert.toArray(), Hashing:HASH_SHA1);
            this.signatureBytes = ByteArray(issuerKey.sign(hashVal));
        }
        else if(signatureType == SIGNATURE_TYPE_RSA_SHA256)
        {
            u8[] hashVal = Hashing:hash(tbsCert.toArray(), Hashing:HASH_SHA256);
            this.signatureBytes = ByteArray(issuerKey.sign(hashVal));
        }
        else
        {
            assert(false); // unsupported hash signature type
            return null;
        }

        // Signature type
        ASN1Node signAlgoNode(ASN1:TAG_SEQUENCE, constructed, ASN1:CLASS_UNIVERSAL);
        rootSeqNode.addChild(signAlgoNode);
        if(signatureType == SIGNATURE_TYPE_RSA_SHA1)
            signAlgoNode.addChild(ASN1Node:createOIDNode("1.2.840.113549.1.1.5"));
        else if(signatureType == SIGNATURE_TYPE_RSA_SHA256)
            signAlgoNode.addChild(ASN1Node:createOIDNode("1.2.840.113549.1.1.11"));
        else
        {
            assert(false); // unsupported hash signature type
            return null;
        }
        signAlgoNode.addChild(ASN1Node(ASN1:TAG_NULL));

        // Signature bytes
        ASN1Node signBitsNode(ASN1:TAG_BIT_STRING, signatureBytes.clone());
        rootSeqNode.addChild(signBitsNode);
        
        ByteArray b = rootSeqNode.write();
        return b;
    }

    // Create ASN1 node
    ASN1Node createCertNode()
    {
        bool primitive   = true;
        bool constructed = false;

        ASN1Node certNode(ASN1:TAG_SEQUENCE, constructed, ASN1:CLASS_UNIVERSAL);

        // Version
        ASN1Node versionParentNode(ASN1:TAG_BER, constructed, ASN1:CONTEXT_SPECIFIC); // very weird one
        certNode.addChild(versionParentNode);
        versionParentNode.addChild(ASN1Node(BigInt(CERT_VERSION_3))); // version 3 is all we support, no reason to support v1 or v2
        certNode.addChild(ASN1Node(BigInt(this.serialNumber)));

        // Signature type
        ASN1Node signAlgoSeqNode(ASN1:TAG_SEQUENCE, constructed, ASN1:CLASS_UNIVERSAL);
        certNode.addChild(signAlgoSeqNode);
        String<u8> signOIDStr = X509Certificate:getOIDForSignatureType(this.signatureType);
        ASN1Node signOIDNode = ASN1Node:createOIDNode(signOIDStr);
        signAlgoSeqNode.addChild(signOIDNode);
        signAlgoSeqNode.addChild(ASN1Node(ASN1:TAG_NULL));
        
        // Issuer
        certNode.addChild(this.issuer.createASN1Node());

        // Valid time range
        ASN1Node timeSeqNode(ASN1:TAG_SEQUENCE, constructed, ASN1:CLASS_UNIVERSAL);
        certNode.addChild(timeSeqNode);
        timeSeqNode.addChild(ASN1Node(this.startDate));
        timeSeqNode.addChild(ASN1Node(this.expiryDate));

        // Subject to
        certNode.addChild(this.subject.createASN1Node());

        // Public Key
        ASN1Node pubKeySeqNode(ASN1:TAG_SEQUENCE, constructed, ASN1:CLASS_UNIVERSAL);
        certNode.addChild(pubKeySeqNode);
        ASN1Node pubKeySignSeqNode(ASN1:TAG_SEQUENCE, constructed, ASN1:CLASS_UNIVERSAL);
        pubKeySeqNode.addChild(pubKeySignSeqNode);
        if(this.rsaPublicKey != null)
        {
            pubKeySignSeqNode.addChild(ASN1Node:createOIDNode("1.2.840.113549.1.1.1"));
            pubKeySignSeqNode.addChild(ASN1Node(ASN1:TAG_NULL));

            ASN1Node pubKeyBitsNode(ASN1:TAG_BIT_STRING, primitive, ASN1:CLASS_UNIVERSAL);
            pubKeySeqNode.addChild(pubKeyBitsNode);

            ASN1Node bitsSeqNode(ASN1:TAG_SEQUENCE, constructed, ASN1:CLASS_UNIVERSAL);
            pubKeyBitsNode.addChild(bitsSeqNode);

            bitsSeqNode.addChild(ASN1Node(rsaPublicKey.n));
            bitsSeqNode.addChild(ASN1Node(rsaPublicKey.e));
        }
        else if(this.dsaPublicKey != null)
        {
            pubKeySignSeqNode.addChild(ASN1Node:createOIDNode("1.2.840.10040.4.1"));
            pubKeySignSeqNode.addChild(ASN1Node(ASN1:TAG_NULL));

            assert(false); // TODO
        }
        else if(this.ecdsaPublicKey != null)
        {
            pubKeySignSeqNode.addChild(ASN1Node:createOIDNode("1.2.840.10045.2.1"));
            pubKeySignSeqNode.addChild(ASN1Node(ASN1:TAG_NULL));

            assert(false); // TODO
        }
        else
        {
            assert(false); // ?
        }

        // we support the four most common (and important) cert v3 extensions

        ASN1Node extsRootNode(ASN1:TAG_BIT_STRING, constructed, ASN1:CONTEXT_SPECIFIC); // very weird one
        extsRootNode.bitStringAddByte = false;
        certNode.addChild(extsRootNode);

        ASN1Node extsSeqNode(ASN1:TAG_SEQUENCE, constructed, ASN1:CLASS_UNIVERSAL);
        extsRootNode.addChild(extsSeqNode);

        // authority key extension
        if(this.authorityKey != null)
        {
            ASN1Node authorityKeySeqNode(ASN1:TAG_SEQUENCE, constructed, ASN1:CLASS_UNIVERSAL);
            extsSeqNode.addChild(authorityKeySeqNode);
            authorityKeySeqNode.addChild(ASN1Node:createOIDNode("2.5.29.35"));
            ASN1Node authorityValRootNode(ASN1:TAG_OCTET_STRING);
            authorityKeySeqNode.addChild(authorityValRootNode);
            ASN1Node authorityValRootSeqNode(ASN1:TAG_SEQUENCE, constructed, ASN1:CLASS_UNIVERSAL);
            authorityValRootNode.addChild(authorityValRootSeqNode);
            authorityValRootSeqNode.addChild(ASN1Node(ASN1:TAG_NULL, this.authorityKey.toArray()));
        }

        // subject key extension
        if(this.subjectKey != null)
        {
            ASN1Node subjectKeySeqNode(ASN1:TAG_SEQUENCE, constructed, ASN1:CLASS_UNIVERSAL);
            extsSeqNode.addChild(subjectKeySeqNode);
            subjectKeySeqNode.addChild(ASN1Node:createOIDNode("2.5.29.14"));
            subjectKeySeqNode.addChild(ASN1Node(ASN1:TAG_OCTET_STRING, this.subjectKey.toArray()));
        }

        // subject alt names extension
        ASN1Node altNamesRootNode(ASN1:TAG_SEQUENCE, constructed, ASN1:CLASS_UNIVERSAL);
        extsSeqNode.addChild(altNamesRootNode);
        altNamesRootNode.addChild(ASN1Node:createOIDNode("2.5.29.17"));
        ASN1Node altNamesOctNode(ASN1:TAG_OCTET_STRING); // subject alt names is like another DER file (so infuriating!)
        altNamesRootNode.addChild(altNamesOctNode);
        ASN1Node altNamesSeqNode(ASN1:TAG_SEQUENCE, constructed, ASN1:CLASS_UNIVERSAL);
        altNamesOctNode.addChild(altNamesSeqNode);
        for(u64 a=0; a<subjectAltDomains.size(); a++)
            altNamesSeqNode.addChild(ASN1Node(ASN1:TAG_OCTET_STRING, subjectAltDomains[a].toArray()));

        // "Basic Constraints" (2.5.29.19) identifies if the subject of certificates is a CA who is allowed to issue child certificates.
        // "Key Usage" (2.5.29.15) defines what can be done with the key contained in the certificate. Examples of usage are: ciphering, signature, signing certificates, signing CRLs.

        // basic constraints
        ASN1Node basicRootNode(ASN1:TAG_SEQUENCE, constructed, ASN1:CLASS_UNIVERSAL);
        extsSeqNode.addChild(basicRootNode);
        basicRootNode.addChild(ASN1Node:createOIDNode("2.5.29.19"));
        u8[] basicBoolArr(1);
        basicBoolArr[0] = 0;
        if(this.rootCert == true)
            basicBoolArr[0] = 0xFF; // fucking DER files use 255 for true
        basicRootNode.addChild(ASN1Node(ASN1:TAG_BOOLEAN, basicBoolArr));
        ASN1Node basicParentNode(ASN1:TAG_OCTET_STRING);
        basicRootNode.addChild(basicParentNode);
        ASN1Node basicBitsSeqNode(ASN1:TAG_SEQUENCE, constructed, ASN1:CLASS_UNIVERSAL);
        basicParentNode.addChild(basicBitsSeqNode);
        u8[] basicBool2Arr(1);
        basicBool2Arr[0] = 0;
        if(this.rootCert == true)
            basicBool2Arr[0] = 0xFF; // fucking DER files use 255 for true
        ASN1Node basicBitsSeqBoolNode(ASN1:TAG_BOOLEAN, basicBool2Arr);
        basicBitsSeqNode.addChild(basicBitsSeqBoolNode);

        // key usage extension
        ASN1Node keyUsageRootNode(ASN1:TAG_SEQUENCE, constructed, ASN1:CLASS_UNIVERSAL);
        extsSeqNode.addChild(keyUsageRootNode);
        keyUsageRootNode.addChild(ASN1Node:createOIDNode("2.5.29.15"));
        u8[] keyBoolArr(1);
        keyBoolArr[0] = 0;
        if(this.rootCert == true)
            keyBoolArr[0] = 0xFF; // fucking DER files use 255 for true
        keyUsageRootNode.addChild(ASN1Node(ASN1:TAG_BOOLEAN, keyBoolArr));
        ASN1Node keyUsageParentNode(ASN1:TAG_OCTET_STRING);
        keyUsageRootNode.addChild(keyUsageParentNode);
        ASN1Node keyUsageBitsNode(ASN1:TAG_BIT_STRING);
        keyUsageParentNode.addChild(keyUsageBitsNode);

        // The key usage bits are complex, have been repurposed by some and are ignored by
        // others. It's important to avoid anything but standard usage patterns here! So
        // we qualify all keys as subject or issuer.
        //
        // -- key usage extension OID and syntax
        // KeyUsage ::= BIT STRING {
        // digitalSignature        (0),
        // nonRepudiation          (1),  -- recent editions of X.509 have renamed this bit to contentCommitment
        // keyEncipherment         (2),
        // dataEncipherment        (3),
        // keyAgreement            (4),
        // keyCertSign             (5),
        // cRLSign                 (6),
        // encipherOnly            (7),
        // decipherOnly            (8) }
        //
        // So, for your BIT STRING: 03 02 01 06 decodes as such:
        // 03: a BIT STRING. [TAG]
        // 02: the value consists in the next two bytes. [LENGTH OF DATA]
        // 01: first value byte; for a BIT STRING, it means that you shall ignore exactly 1 bit in the last value byte. [BYTE 1 of value even tho its really meta info...]
        // 06: the bits themselves. [BYTE 2 of value]

        keyUsageBitsNode.data = u8[](2); // theoretically we could use up to 3 bytes because there are 9 flag bits available...
        keyUsageBitsNode.bitStringAddByte = false;
        if(this.rootCert == false)
        {
            // SUBJECT certificate
            keyUsageBitsNode.data[0] = 5; // 5 bits unused in next byte
            keyUsageBitsNode.data[1] = 0b10100000; // only first three bits used for digitalSignature(true) nonRepudiation(false) and keyEncipherment(true).
        }
        else // certificate authority certificate
        {
            // ISSUER certificate (AKA Certificate Authority / Root Authority)
            keyUsageBitsNode.data[0] = 1; // 1 bits unused in next byte
            keyUsageBitsNode.data[1] = 0b00000110; // only first seven bits used
        }

        // TODO consider supporting certificate revocation lists

        return certNode;
    }

    // Write certificate to base 64 text (of DER file).
    String<u8> writeCertificateBase64()
    {
        String<u8> s(2048);

        ByteArray b = certFile;
        if(b == null)
            return s;

        s += "-----BEGIN CERTIFICATE-----\n";

        String<u8> b64Str = FileSystem:encodeBytesToBase64(b);
        b64Str.insertRegular(80, Chars:NEW_LINE);
        s += b64Str;

        s += "-----END CERTIFICATE-----\n";

        return s;
    }

    // Read certificate from PEM text base64-encoded. Only reads one certificate. Use readCertificates() for multiple certificates in a single text file.
    bool readCertificate(String<u8> base64Text)
    {
        String<u8> errorsOut();
        return readCertificate(base64Text, errorsOut);
    }

    // Read certificate from PEM text base64-encoded. Only reads one certificate. Use readCertificates() for multiple certificates in a single text file.
    bool readCertificate(String<u8> base64Text, String<u8> errorsOut)
    {
        ArrayList<ByteArray> derFiles = decodePEMCertificates(base64Text);
        if(derFiles.size() == 0)
        {
            errorsOut.append("ERROR: No certificates found.\n");
            return false;
        }

        if(derFiles.size() > 1)
        {
            errorsOut.append("ERROR: More than one certificate found. Use readCertificates() for multiple certificates in a single text file.\n");
            return false;
        }

        if(readCertificate(derFiles[0], errorsOut) == false)
            return false;

        return true;
    }

    // Read certificate from binary file (ASN.1 DER format).
    bool readCertificate(ByteArray derFile)
    {
        String<u8> errorsOut();
        return readCertificate(derFile, errorsOut);
    }

    // Read certificate from binary file (ASN.1 DER format).
    bool readCertificate(ByteArray derFile, String<u8> errorsOut)
    {
        /* Format of ASN.1 encoded certificate.
        Certificate:
        Data:
            Version: 3 (0x2)
            Serial Number:
                04:00:00:00:00:01:44:4e:f0:42:47
            Signature Algorithm: sha256WithRSAEncryption
            Issuer: C=BE, O=GlobalSign nv-sa, OU=Root CA, CN=GlobalSign Root CA
            Validity
                Not Before: Feb 20 10:00:00 2014 GMT
                Not After : Feb 20 10:00:00 2024 GMT
            Subject: C=BE, O=GlobalSign nv-sa, CN=GlobalSign Organization Validation CA - SHA256 - G2
            Subject Public Key Info:
                Public Key Algorithm: rsaEncryption
                    Public-Key: (2048 bit)
                    Modulus:
                        00:c7:0e:6c:3f:23:93:7f:cc:70:a5:9d:20:c3:0e:
                        ...
                    Exponent: 65537 (0x10001)
            X509v3 extensions:
                X509v3 Key Usage: critical
                    Certificate Sign, CRL Sign
                X509v3 Basic Constraints: critical
                    CA:TRUE, pathlen:0
                X509v3 Subject Key Identifier:
                    96:DE:61:F1:BD:1C:16:29:53:1C:C0:CC:7D:3B:83:00:40:E6:1A:7C
                X509v3 Certificate Policies:
                    Policy: X509v3 Any Policy
                    CPS: https://www.globalsign.com/repository/

                X509v3 CRL Distribution Points:

                    Full Name:
                    URI:http://crl.globalsign.net/root.crl

                Authority Information Access:
                    OCSP - URI:http://ocsp.globalsign.com/rootr1

                X509v3 Authority Key Identifier:
                    keyid:60:7B:66:1A:45:0D:97:CA:89:50:2F:7D:04:CD:34:A8:FF:FC:FD:4B

        Signature Algorithm: sha256WithRSAEncryption
            46:2a:ee:5e:bd:ae:01:60:37:31:11:86:71:74:b6:46:49:c8:
            ...
        */

        ASN1 asn();
        if(asn.parse(derFile) == false)
        {
            errorsOut.append("ERROR: Failed to parse DER file.\n" + asn.parseErrors);
            return false;
        }

        if(asn.rootNode == null)
        {
            errorsOut.append("ERROR: No root node after parsing DER file.\n");
            return false;
        }

        if(asn.rootNode.children.size() == 0) 
        {
            errorsOut.append("ERROR: Root of parsed DER file has no children.\n");
            return false;
        }

        // Some files have an extra root sequence node, some don't.
        ASN1Node signedNode = asn.rootNode;
        if(signedNode.children.size() == 1) 
        {
            signedNode = asn.rootNode.children[0]; // must be extra root node, keep going
        }

        // signed node should have exactly three children:
        // 1. actual certificate node
        // 2. the signature algorithm node
        // 3. the bitstring signature node

        if(signedNode.children.size() != 3)
        {
            errorsOut.append("ERROR: ASN1 root doesn't have three child nodes (certificate, signining algo, bitstring for signature) but rather " +
                             String<u8>:formatNumber(signedNode.children.size()) + " children.\n");
            return false;
        }

        ASN1Node certNode     = signedNode.children[0];
        ASN1Node signAlgoNode = signedNode.children[1];
        ASN1Node signBitsNode = signedNode.children[2];

        this.certFile       = derFile;
        this.tbsRecordBytes = ByteArray(certNode.allData);

        if(readCertNode(certNode, errorsOut) == false)
            return false;

        if(readSignatureNodes(signAlgoNode, signBitsNode, errorsOut) == false)
            return false;

        return true;
    }

    // Read certificate (TBSCert) node
    bool readCertNode(ASN1Node certNode, String<u8> errorsOut)
    {
        // at least 6 nodes, but possibly more because of extensions (for version_3)
        if(certNode.children.size() < 6)
        {
            errorsOut.append("ERROR: ASN1 TBSCert node doesn't at least 6 child nodes (version (optional), serial, signAlgo, issuer, validDates, subject, subjectKey) but rather " +
                             String<u8>:formatNumber(certNode.children.size()) + " children.\n");
            return false;
        }

        u64 nextChildNodeIndex = 0;

        if(certNode.children[nextChildNodeIndex].tag != ASN1:TAG_INTEGER)
        {
            // this is probably a version 3 (or super rare version 2) certificate where this is an empty BER tag holding the integer tag (fucking ASN1 weirdness)
            if(certNode.children[nextChildNodeIndex].children.size() > 0)
            {
                if(certNode.children[nextChildNodeIndex].children[0].tag == ASN1:TAG_INTEGER)
                {
                    BigInt versionBig = certNode.children[nextChildNodeIndex].children[0].decodeInteger();
                    this.certVersion = CERT_VERSION_1;
                    if(versionBig != null)
                        this.certVersion = versionBig.asI64();

                    nextChildNodeIndex++;
                }
                else
                {
                    errorsOut.append("ERROR: ASN1 TBSCert child[0] node is not integer type and has no children. Doesn't conform to version 1 or version 3 certificate type.\n");
                    return false;
                }
            }
            else
            {
                errorsOut.append("ERROR: ASN1 TBSCert child[0] node is not integer type. Needs to be for version or serial number.\n");
                return false;
            }
        }
        else
        {
            // probably serial number, but could be version
            if(certNode.children[nextChildNodeIndex+1].tag == ASN1:TAG_INTEGER) // two integer nodes in a row, first must be version
            {
                BigInt versionBig = certNode.children[nextChildNodeIndex].decodeInteger();
                this.certVersion = CERT_VERSION_1;
                if(versionBig != null)
                    this.certVersion = versionBig.asI64();

                nextChildNodeIndex++;
            }
        }

        if(certNode.children[nextChildNodeIndex].tag == ASN1:TAG_INTEGER)
        {
            // this has to be a version 1 certificate where serial number is first
            this.serialNumber = certNode.children[nextChildNodeIndex].decodeInteger();

            nextChildNodeIndex++;
        }
        else
        {
            errorsOut.append("ERROR: ASN1 TBSCert child[0 or 1] node is not integer type. Missing serial number.\n");
            return false;
        }

        if(this.serialNumber == null)
            this.serialNumber = BigInt(0);

        // signature algorithm
        ASN1Node signAlgoSeqNode = certNode.children[nextChildNodeIndex];
        if(signAlgoSeqNode.tag != ASN1:TAG_SEQUENCE || signAlgoSeqNode.children.size() == 0)
        {
            errorsOut.append("ERROR: ASN1 TBSCert child[" + String<u8>:formatNumber(nextChildNodeIndex) + 
                             "] should be signatureAlgorithm node which should be tag=sequence, but its not. Tag id: " + 
                                 String<u8>:formatNumber(signAlgoSeqNode.tag) + "\n");
            return false;
        }

        if(signAlgoSeqNode.children.size() < 1)
        {
            errorsOut.append("ERROR: ASN1 TBSCert signAlgo seq node has no children.\n");
            return false;
        }

        String<u8> signAlgoOIDStr = signAlgoSeqNode.children[0].decodeOIDToString();
        this.signatureType = X509Certificate:getSignatureTypeForOID(signAlgoOIDStr);
        if(this.signatureType == X509Certificate:SIGNATURE_TYPE_NULL)
        {
            errorsOut.append("ERROR: Signature algorithm unsupported, OID: " + signAlgoOIDStr + "\n");
            return false;
        }

        nextChildNodeIndex++;

        // Issuer
        this.issuer = readNameNode(certNode.children[nextChildNodeIndex], errorsOut);
        if(this.issuer == null)
            return false;

        nextChildNodeIndex++;
        
        // Valid period
        ASN1Node datesSeqNode = certNode.children[nextChildNodeIndex];
        if(datesSeqNode.tag == ASN1:TAG_SEQUENCE)
        {
            if(datesSeqNode.children.size() == 2)
            {
                if(datesSeqNode.children[0].data != null)
                {
                    //String<u8> dateFromStr = String<u8>(datesSeqNode.children[0].data);
                    //this.startDate = ASN1Node:decodeUTCTime(dateFromStr);

                    this.startDate = datesSeqNode.children[0].decodeUTCTime();
                }

                if(datesSeqNode.children[1].data != null)
                {
                    //String<u8> dateToStr = String<u8>(datesSeqNode.children[1].data);
                    //this.expiryDate = ASN1Node:decodeUTCTime(dateToStr);

                    this.expiryDate = datesSeqNode.children[1].decodeUTCTime();
                }
            }
        }

        nextChildNodeIndex++;

        // Subject
        this.subject = readNameNode(certNode.children[nextChildNodeIndex], errorsOut);
        if(this.subject == null)
            return false;

        nextChildNodeIndex++;

        // public key node
        if(nextChildNodeIndex >= certNode.children.size())
        {
            errorsOut.append("ERROR: Missing public key node, we ran out of child nodes in certNode.\n");
            return false;
        }

        ASN1Node pubKeySeqNode = certNode.children[nextChildNodeIndex];
        if(pubKeySeqNode.children.size() != 2)
        {
            errorsOut.append("ERROR: Public key node (sequence) doesn't have 2 child nodes.\n");
            return false;
        }

        ASN1Node pubKeyTypeNode = pubKeySeqNode.children[0];
        String<u8> pubKeyOID = null;
        if(pubKeyTypeNode.tag == ASN1:TAG_SEQUENCE)
        {
            if(pubKeyTypeNode.children.size() > 0)
                pubKeyOID = pubKeyTypeNode.children[0].decodeOIDToString();
        }
        else
        {
            pubKeyOID = pubKeyTypeNode.decodeOIDToString();
        }

        u8 publicKeyType = PUBLIC_KEY_TYPE_NULL;
        if(pubKeyOID != null)
        {
            if(pubKeyOID.compare("1.2.840.113549.1.1.1") == true)
            {
                // RSA encryption
                publicKeyType = PUBLIC_KEY_TYPE_RSA;
            }
            else if(pubKeyOID.compare("1.2.840.10040.4.1") == true)
            {
                // Digital Secure Algorithm
                publicKeyType = PUBLIC_KEY_TYPE_DSA;
            }
            else if(pubKeyOID.compare("1.2.840.10045.2.1") == true)
            {
                // Elliptic Curve Digital Secure Algorithm
                publicKeyType = PUBLIC_KEY_TYPE_ECDSA;
            }
            else
            {
                publicKeyType = PUBLIC_KEY_TYPE_NULL;
                errorsOut.append("ERROR: Public key node encryption type unsupported, OID: " + pubKeyOID + "\n");
                return false;
            }
        }

        // Different public key types need different parsing
        if(publicKeyType == PUBLIC_KEY_TYPE_RSA)
        {
            this.rsaPublicKey = RSAPublicKey();

            ASN1Node pubKeyBitsNode = pubKeySeqNode.children[1];
            if(pubKeyBitsNode.tag == ASN1:TAG_BIT_STRING)
            {
                ASN1 pubKeyASN();
                if(pubKeyASN.parse(ByteArray(pubKeyBitsNode.data)) == false)
                {
                    errorsOut.append("ERROR: Failed to parse bit string to ASN for public key.\n");
                    return false;
                }

                // pubKeyASN rootNode->SeqNode->Int1 and Int2 child nodes
                if(pubKeyASN.rootNode == null)
                {
                    errorsOut.append("ERROR: Failed to parse bit string (no root node) to ASN for public key.\n");
                    return false;
                }

                if(pubKeyASN.rootNode.children.size() == 0)
                {
                    errorsOut.append("ERROR: Public key root node has no children (no seq node).\n");
                    return false;
                }

                ASN1Node pubKeySeqNode = pubKeyASN.rootNode.children[0];
                if(pubKeySeqNode.tag != ASN1:TAG_SEQUENCE)
                {
                    errorsOut.append("ERROR: Public key seq node...not tagged as sequence, tag: " + String<u8>:formatNumber(pubKeySeqNode.tag) + "\n");
                    return false;
                }

                if(pubKeySeqNode.children.size() == 2)
                {
                    if(pubKeySeqNode.children[0].tag == ASN1:TAG_INTEGER)
                    {
                        this.rsaPublicKey.n = pubKeySeqNode.children[0].decodeInteger();
                    }

                    if(pubKeySeqNode.children[1].tag == ASN1:TAG_INTEGER)
                    {
                        this.rsaPublicKey.e = pubKeySeqNode.children[1].decodeInteger();
                    }
                }
                else
                {
                    errorsOut.append("ERROR: Public key seq node doesn't have two children, but: " + String<u8>:formatNumber(pubKeySeqNode.children.size()) + "\n");
                    return false;
                }
            }
            else
            {
                errorsOut.append("ERROR: Public key node key is not bitstring, tag: " + String<u8>:formatNumber(pubKeyBitsNode.tag) + "\n");
                return false;
            }
        }
        else if(publicKeyType == PUBLIC_KEY_TYPE_DSA)
        {
            this.dsaPublicKey = DSAPublicKey();
        }
        else if(publicKeyType == PUBLIC_KEY_TYPE_ECDSA)
        {
            this.ecdsaPublicKey = ECDSAPublicKey();

            // need to figure out named elliptic curve
            String<u8> namedCurveOID = null;
            if(pubKeyTypeNode.tag == ASN1:TAG_SEQUENCE)
            {
                if(pubKeyTypeNode.children.size() >= 2)
                    namedCurveOID = pubKeyTypeNode.children[1].decodeOIDToString();
            }

            if(namedCurveOID == null)
            {
                errorsOut.append("ERROR: ECDSA missing named elliptic curve OID!\n");
                return false;
            }

            u8 namedCurveID = ECC:CURVE_NULL;
            if(namedCurveOID.compare("1.2.840.10045.3.1.7") == true) // SECP256R1
            {
                this.ecdsaPublicKey.curveID = ECC:CURVE_SECP256R1;
            }
            else if(namedCurveOID.compare("1.3.132.0.34") == true) // SECP384R1
            {
                this.ecdsaPublicKey.curveID = ECC:CURVE_SECP384R1;
            }
            else
            {
                errorsOut.append("ERROR: Unknown named elliptic curve OID: " +  namedCurveOID + "\n");
                return false;
            }

            ASN1Node pubKeyBitsNode = pubKeySeqNode.children[1];
            if(pubKeyBitsNode.data == null)
            {
                errorsOut.append("ERROR: ECDSA key x/y missing data!\n");
                return false;
            }

            u64 halfKeyNumBytes = pubKeyBitsNode.data.length() / 2;

            // pubKeyBitsNode is just a bit string that contains two numbers, X, Y.
            u64 halfKeyU32s = (halfKeyNumBytes / 4) + 1;
            u32[] xParam(halfKeyU32s);
            for(u64 q=0; q<halfKeyU32s; q++)
            {
                u32 v = 0;
                u32 i = (q * 4) + 0;

                if(i < pubKeyBitsNode.data.length())
                    v = (v << 8) | u32(pubKeyBitsNode.data[i]);
                i++;
                if(i < pubKeyBitsNode.data.length())
                    v = (v << 8) | u32(pubKeyBitsNode.data[i]);
                i++;
                if(i < pubKeyBitsNode.data.length())
                    v = (v << 8) | u32(pubKeyBitsNode.data[i]);
                i++;
                if(i < pubKeyBitsNode.data.length())
                    v = (v << 8) | u32(pubKeyBitsNode.data[i]);

                xParam[q] = v;
            }

            u32[] yParam(halfKeyU32s);
            for(u64 q=0; q<halfKeyU32s; q++)
            {
                u32 v = 0;
                u32 i = halfKeyNumBytes + (q * 4) + 0;

                if(i < pubKeyBitsNode.data.length())
                    v = (v << 8) | u32(pubKeyBitsNode.data[i]);
                i++;
                if(i < pubKeyBitsNode.data.length())
                    v = (v << 8) | u32(pubKeyBitsNode.data[i]);
                i++;
                if(i < pubKeyBitsNode.data.length())
                    v = (v << 8) | u32(pubKeyBitsNode.data[i]);
                i++;
                if(i < pubKeyBitsNode.data.length())
                    v = (v << 8) | u32(pubKeyBitsNode.data[i]);

                yParam[q] = v;
            }

            ecdsaPublicKey.x = BigInt();
            ecdsaPublicKey.x.numbers = xParam;
            ecdsaPublicKey.x.setNumUsed();

            ecdsaPublicKey.y = BigInt();
            ecdsaPublicKey.y.numbers = yParam;
            ecdsaPublicKey.y.setNumUsed();
        }
        else
        {
            // else it's a public key type we don't know about, should not get to this point!
            errorsOut.append("ERROR: Public key type unknown, cannot parse public key.\n");
            return false;
        }
        nextChildNodeIndex++;

        if(this.certVersion == CERT_VERSION_3)
        {
            ASN1Node nextNode = certNode.children[nextChildNodeIndex];

            ASN1Node authorityKeyParentNode = nextNode.getOIDNodeParent("2.5.29.35", null);
            if(authorityKeyParentNode != null)
            {
                i64 authorityChildIndex = -1; // into parent node
                for(u64 c=0; c<authorityKeyParentNode.children.size(); c++)
                {
                    if(authorityKeyParentNode.children[c].tag == ASN1:TAG_OBJECT_IDENTIFIER)
                    {
                        String<u8> checkOID = authorityKeyParentNode.children[c].decodeOIDToString();
                        if("2.5.29.35".compare(checkOID) == true)
                        {
                            authorityChildIndex = c;
                            break;
                        }
                    }
                }

                if(authorityChildIndex >= 0 && (authorityChildIndex+1) < authorityKeyParentNode.children.size())
                {
                    // next node should be value branch - which is a seperate ASN1 DER file effectively.
                    ASN1Node authorityValRootNode = authorityKeyParentNode.children[authorityChildIndex+1];
                    ASN1 authASN1();
                    if(authASN1.parse(ByteArray(authorityValRootNode.data)) == true)
                    {
                        ASN1Node authLeafNode = authASN1.rootNode;
                        while(authLeafNode.children.size() > 0)
                            authLeafNode = authLeafNode.children[0];

                        this.authorityKey = ByteArray(authLeafNode.data);
                    }
                }
            }

            ASN1Node subjectKeyParentNode = nextNode.getOIDNodeParent("2.5.29.14", null);
            if(subjectKeyParentNode != null)
            {
                if(subjectKeyParentNode.children.size() > 1)
                {
                    ASN1Node subjectKeyValNode = subjectKeyParentNode.children[1];
                    if(subjectKeyValNode.data != null)
                    {
                        // next node should be value branch - which can be a seperate ASN1 DER file effectively.
                        ASN1 subjectKeyASN1();
                        if(subjectKeyASN1.parse(ByteArray(subjectKeyValNode.data)) == true)
                        {
                            ASN1Node subKeyLeafNode = subjectKeyASN1.rootNode;
                            while(subKeyLeafNode.children.size() > 0)
                                subKeyLeafNode = subKeyLeafNode.children[0];

                            this.subjectKey = ByteArray(subKeyLeafNode.data);
                        }
                        else // data is the key
                        {
                            this.subjectKey = ByteArray(subjectKeyValNode.data);
                        }
                    }
                }
            }

            ASN1Node subjectAltsParentNode = nextNode.getOIDNodeParent("2.5.29.17", null);
            if(subjectAltsParentNode != null)
            {
                if(subjectAltsParentNode.children.size() > 1)
                {
                    ASN1Node subjectAltsValNode = subjectAltsParentNode.children[1];
                    if(subjectAltsValNode.data != null)
                    {
                        // next node should be value branch - which is a seperate ASN1 DER file effectively.
                        ASN1 subjectAltsASN1();
                        if(subjectAltsASN1.parse(ByteArray(subjectAltsValNode.data)) == true)
                        {
                            ASN1Node subAltsSeqNode = subjectAltsASN1.rootNode;
                            while(subAltsSeqNode.children.size() > 0)
                            {
                                if(subAltsSeqNode.tag == ASN1:TAG_SEQUENCE)
                                    break;

                                subAltsSeqNode = subAltsSeqNode.children[0];
                            }

                            if(subAltsSeqNode.tag == ASN1:TAG_SEQUENCE)
                            {
                                for(u64 c=0; c<subAltsSeqNode.children.size(); c++)
                                {
                                    this.subjectAltDomains.add(String<u8>(subAltsSeqNode.children[c].data));
                                }
                            }
                        }
                    }
                }
            }

            // "Basic Constraints" (2.5.29.19) identifies if the subject of certificates is a CA who is allowed to issue child certificates.
            ASN1Node basicConstraintsNode = nextNode.getOIDNodeParent("2.5.29.19", null);
            if(basicConstraintsNode != null)
            {
                if(basicConstraintsNode.children.size() >= 2)
                {
                    ASN1Node caBoolNode = basicConstraintsNode.children[1];
                    if(caBoolNode.tag == ASN1:TAG_BOOLEAN)
                    {
                        this.rootCert = false;
                        if(caBoolNode.data != null)
                        {
                            if(caBoolNode.data.length() == 1)
                            {
                                if(caBoolNode.data[0] > 0)
                                {
                                    this.rootCert = true;
                                }
                            }
                        }
                    }
                }
            }

            // "Key Usage" (2.5.29.15) defines what can be done with the key contained in the certificate. Examples of usage are: ciphering, signature, signing certificates, signing CRLs.
            ASN1Node keyUsageNode = nextNode.getOIDNodeParent("2.5.29.15", null);
            if(keyUsageNode != null)
            {
                if(keyUsageNode.children.size() >= 2)
                {
                    ASN1Node signBoolNode = keyUsageNode.children[1];
                    if(signBoolNode.tag == ASN1:TAG_BOOLEAN)
                    {
                        if(signBoolNode.data != null)
                        {
                            if(signBoolNode.data.length() == 1)
                            {
                                if(signBoolNode.data[0] > 0)
                                {
                                    //this.signsOtherCerts = true; // not the same as CA certificate
                                }
                            }
                        }
                    }
                }
            }
        }

        return true;
    }

    // Return signature ID for OID string
    shared u8 getSignatureTypeForOID(String<u8> signAlgoOIDStr)
    {
        if(signAlgoOIDStr.compare("1.2.840.113549.1.1.5") == true) // RSA with SHA1
        {
            return X509Certificate:SIGNATURE_TYPE_RSA_SHA1;
        }
        else if(signAlgoOIDStr.compare("1.2.840.113549.1.1.14") == true) // RSA with SHA224
        {
            return X509Certificate:SIGNATURE_TYPE_RSA_SHA224;
        }
        else if(signAlgoOIDStr.compare("1.2.840.113549.1.1.11") == true) // RSA with SHA256
        {
            return X509Certificate:SIGNATURE_TYPE_RSA_SHA256;
        }
        else if(signAlgoOIDStr.compare("1.2.840.113549.1.1.12") == true) // RSA with SHA384
        {
            return X509Certificate:SIGNATURE_TYPE_RSA_SHA384;
        }
        else if(signAlgoOIDStr.compare("1.2.840.113549.1.1.13") == true) // RSA with SHA512
        {
            return X509Certificate:SIGNATURE_TYPE_RSA_SHA512;
        }
        else if(signAlgoOIDStr.compare("1.2.840.10040.4.3") == true) // DSA with SHA1
        {
            return X509Certificate:SIGNATURE_TYPE_DSA_SHA1;
        }
        else if(signAlgoOIDStr.compare("2.16.840.1.101.3.4.3.1") == true) // DSA with SHA224
        {
            return X509Certificate:SIGNATURE_TYPE_DSA_SHA224;
        }
        else if(signAlgoOIDStr.compare("2.16.840.1.101.3.4.3.2") == true) // DSA with SHA256
        {
            return X509Certificate:SIGNATURE_TYPE_DSA_SHA256;
        }
        else if(signAlgoOIDStr.compare("1.2.840.10045.4.1") == true) // ECDSA with SHA1
        {
            return X509Certificate:SIGNATURE_TYPE_ECDSA_SHA1;
        }
        else if(signAlgoOIDStr.compare("1.2.840.10045.4.3.1") == true) // ECDSA with SHA224
        {
            return X509Certificate:SIGNATURE_TYPE_ECDSA_SHA224;
        }
        else if(signAlgoOIDStr.compare("1.2.840.10045.4.3.2") == true) // ECDSA with SHA256
        {
            return X509Certificate:SIGNATURE_TYPE_ECDSA_SHA256;
        }
        else if(signAlgoOIDStr.compare("1.2.840.10045.4.3.3") == true) // ECDSA with SHA384
        {
            return X509Certificate:SIGNATURE_TYPE_ECDSA_SHA384;
        }
        else if(signAlgoOIDStr.compare("1.2.840.10045.4.3.4") == true) // ECDSA with SHA512
        {
            return X509Certificate:SIGNATURE_TYPE_ECDSA_SHA512;
        }
        
        // we don't support
        return X509Certificate:SIGNATURE_TYPE_NULL;
    }

    // Return OID String for signature type.
    shared String<u8> getOIDForSignatureType(u8 signType)
    {
        if(signType == X509Certificate:SIGNATURE_TYPE_RSA_SHA1) // RSA with SHA1
        {
            return "1.2.840.113549.1.1.5";
        }
        else if(signType == X509Certificate:SIGNATURE_TYPE_RSA_SHA224) // RSA with SHA224
        {
            return "1.2.840.113549.1.1.14";
        }
        else if(signType == X509Certificate:SIGNATURE_TYPE_RSA_SHA256) // RSA with SHA256
        {
            return "1.2.840.113549.1.1.11";
        }
        else if(signType == X509Certificate:SIGNATURE_TYPE_RSA_SHA384) // RSA with SHA384
        {
            return "1.2.840.113549.1.1.12";
        }
        else if(signType == X509Certificate:SIGNATURE_TYPE_RSA_SHA512) // RSA with SHA512
        {
            return "1.2.840.113549.1.1.13";
        }
        else if(signType == X509Certificate:SIGNATURE_TYPE_DSA_SHA1) // DSA with SHA1
        {
            return "1.2.840.10040.4.3";
        }
        else if(signType == X509Certificate:SIGNATURE_TYPE_DSA_SHA224) // DSA with SHA224
        {
            return "2.16.840.1.101.3.4.3.1";
        }
        else if(signType == X509Certificate:SIGNATURE_TYPE_DSA_SHA256) // DSA with SHA256
        {
            return "2.16.840.1.101.3.4.3.2";
        }
        else if(signType == X509Certificate:SIGNATURE_TYPE_ECDSA_SHA1) // ECDSA with SHA1
        {
            return "1.2.840.10045.4.1";
        }
        else if(signType == X509Certificate:SIGNATURE_TYPE_ECDSA_SHA224) // ECDSA with SHA224
        {
            return "1.2.840.10045.4.3.1";
        }
        else if(signType == X509Certificate:SIGNATURE_TYPE_ECDSA_SHA256) // ECDSA with SHA256
        {
            return "1.2.840.10045.4.3.2";
        }
        else if(signType == X509Certificate:SIGNATURE_TYPE_ECDSA_SHA384) // ECDSA with SHA384
        {
            return "1.2.840.10045.4.3.3";
        }
        else if(signType == X509Certificate:SIGNATURE_TYPE_ECDSA_SHA512) // ECDSA with SHA512
        {
            return "1.2.840.10045.4.3.4";
        }
        
        // we don't support
        return "";
    }

    // Read RSA/DSA/ECDSA signature.
    bool readSignatureNodes(ASN1Node signAlgoNode, ASN1Node signBitsNode, String<u8> errorsOut)
    {
        if(signAlgoNode.tag == ASN1:TAG_SEQUENCE) // this is normal
        {
            if(signAlgoNode.children.size() > 0)
                signAlgoNode = signAlgoNode.children[0];
        }

        if(signAlgoNode.tag == ASN1:TAG_OBJECT_IDENTIFIER)
        {
            String<u8> signAlgoOIDStr = signAlgoNode.decodeOIDToString();
            this.signatureType = X509Certificate:getSignatureTypeForOID(signAlgoOIDStr);
            if(this.signatureType == X509Certificate:SIGNATURE_TYPE_NULL)
            {
                errorsOut.append("ERROR: ASN1 algorithm signature type we don't understand, OID: " + signAlgoOIDStr + ".\n");
                return false;
            }
        }
        else
        {
            errorsOut.append("ERROR: ASN1 algorithm signature node isn't object id, tag: " + String<u8>:formatNumber(signAlgoNode.tag) + ".\n");
            return false;
        }

        // signature bits
        signatureBytes = ByteArray(signBitsNode.data);
        if(signatureBytes == null)
        {
            errorsOut.append("ERROR: ASN1 signature bits missing!?\n");
            return false;
        }

        return true;
    }

    // Read issuer / subject fields like name, address etc.
    X509Name readNameNode(ASN1Node nameNode, String<u8> errorsOut)
    {
        if(nameNode == null)
            return null;

        // The name fields are unordered, optional etc.
        X509Name n();

        n.domain  = nameNode.getOIDStringValue("2.5.4.3", null);
        n.country = nameNode.getOIDStringValue("2.5.4.6", null);
        n.state   = nameNode.getOIDStringValue("2.5.4.8", null);
        n.city    = nameNode.getOIDStringValue("2.5.4.7", null);
        n.org     = nameNode.getOIDStringValue("2.5.4.10", null);
        n.orgUnit = nameNode.getOIDStringValue("2.5.4.11", null);

        return n;
    }

    // For text files of certificates (in base64 encoding). Returns all certificates as ASN.1 DER binary files.
    shared ArrayList<ByteArray> decodePEMCertificates(String<u8> textIn)
    {
        /* Example 2048 bit RSA
        -----BEGIN CERTIFICATE-----
        MIIC2jCCAkMCAg38MA0GCSqGSIb3DQEBBQUAMIGbMQswCQYDVQQGEwJKUDEOMAwG
        A1UECBMFVG9reW8xEDAOBgNVBAcTB0NodW8ta3UxETAPBgNVBAoTCEZyYW5rNERE
        MRgwFgYDVQQLEw9XZWJDZXJ0IFN1cHBvcnQxGDAWBgNVBAMTD0ZyYW5rNEREIFdl
        YiBDQTEjMCEGCSqGSIb3DQEJARYUc3VwcG9ydEBmcmFuazRkZC5jb20wHhcNMTIw
        ODIyMDUyNzQxWhcNMTcwODIxMDUyNzQxWjBKMQswCQYDVQQGEwJKUDEOMAwGA1UE
        CAwFVG9reW8xETAPBgNVBAoMCEZyYW5rNEREMRgwFgYDVQQDDA93d3cuZXhhbXBs
        ZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC0z9FeMynsC8+u
        dvX+LciZxnh5uRj4C9S6tNeeAlIGCfQYk0zUcNFCoCkTknNQd/YEiawDLNbxBqut
        bMDZ1aarys1a0lYmUeVLCIqvzBkPJTSQsCopQQ9V8WuT252zzNzs68dVGNdCJd5J
        NRQykpwexmnjPPv0mvj7i8XgG379TyW6P+WWV5okeUkXJ9eJS2ouDYdR2SM9BoVW
        +FgxDu6BmXhozW5EfsnajFp7HL8kQClI0QOc79yuKl3492rH6bzFsFn2lfwWy9ic
        7cP8EpCTeFp1tFaD+vxBhPZkeTQ1HKx6hQ5zeHIB5ySJJZ7af2W8r4eTGYzbdRW2
        4DDHCPhZAgMBAAEwDQYJKoZIhvcNAQEFBQADgYEAQMv+BFvGdMVzkQaQ3/+2noVz
        /uAKbzpEL8xTcxYyP3lkOeh4FoxiSWqy5pGFALdPONoDuYFpLhjJSZaEwuvjI/Tr
        rGhLV1pRG9frwDFshqD2Vaj4ENBCBh6UpeBop5+285zQ4SI7q4U9oSebUDJiuOx6
        +tZ9KynmrbJpTSi0+BM=
        -----END CERTIFICATE-----
        */

        ArrayList<ByteArray> certDERFiles();

        i64 nextCertStartIndex = textIn.findNext("BEGIN CERTIFICATE", 0);
        i64 nextCertEndIndex   = 0;
        while(nextCertStartIndex != -1)
        {
            nextCertStartIndex = textIn.findNext(Chars:NEW_LINE, nextCertStartIndex);
            nextCertEndIndex   = textIn.findNext("END CERTIFICATE", nextCertStartIndex);

            if(nextCertEndIndex == -1)
                return certDERFiles;

            nextCertEndIndex = textIn.findPrev(Chars:NEW_LINE, nextCertEndIndex);

            String<u8> certBase64Str = textIn.subString(nextCertStartIndex, nextCertEndIndex-1);
            certBase64Str.trimWhitespace();

            ByteArray derFile = FileSystem:decodeBytesFromBase64(certBase64Str);
            if(derFile != null)
                certDERFiles.add(derFile);

            nextCertStartIndex = textIn.findNext("BEGIN CERTIFICATE", nextCertEndIndex);
        }

        return certDERFiles;
    }

    // Read one or more certificates from PEM-encoded (text file) format (base64 encoding of ASN.1 DER).
    shared ArrayList<X509Certificate> readCertificates(String<u8> certsPEM)
    {
        ArrayList<ByteArray> certDERFiles = X509Certificate:decodePEMCertificates(certsPEM);
        ArrayList<X509Certificate> certs();
        for(u64 c=0; c<certDERFiles.size(); c++)
        {
            X509Certificate cert();
            if(cert.readCertificate(certDERFiles[c]) == false)
                return null;

            certs.add(cert);
        }

        return certs;
    }

    // Read one or more certificates from PEM-encoded (text file) format (base64 encoding of ASN.1 DER).
    shared ArrayList<X509Certificate> readCertificates(String<u8> certsPEM, String<u8> errorsOut)
    {
        ArrayList<ByteArray> certDERFiles = X509Certificate:decodePEMCertificates(certsPEM);
        ArrayList<X509Certificate> certs();
        for(u64 c=0; c<certDERFiles.size(); c++)
        {
            X509Certificate cert();
            if(cert.readCertificate(certDERFiles[c], errorsOut) == false)
                return null;

            certs.add(cert);
        }

        return certs;
    }

    // Read one or more certificates from binary file (ASN.1 DER format) or PEM-encoded (text file) format (base64 encoding of ASN.1 DER).
    shared ArrayList<X509Certificate> readCertificates(ByteArray file, String<u8> errorsOut)
    {
        if(errorsOut == null)
            errorsOut = String<u8>();

        ArrayList<X509Certificate> certs();
        if(file == null)
            return certs;
        if(file.numUsed == 0)
            return certs;

        ArrayList<ByteArray> derFiles();

        String<u8> textFile = file.toString();
        if(textFile != null)
        {
            if(textFile.contains("BEGIN CERTIFICATE") == true)
            {
                // assume text file of PEM encoded
                derFiles = decodePEMCertificates(textFile);
            }
            else
            {
                derFiles.add(file);
            }
        }
        else
        {
            derFiles.add(file);
        }

        // read/parse each certificate
        for(u64 f=0; f<derFiles.size(); f++)
        {
            X509Certificate cert();
            if(cert.readCertificate(derFiles[f], errorsOut) == true)
            {
                if(cert != null)
                    certs.add(cert);
            }
        }

        return certs;
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
// X509TrustStore
////////////////////////////////////////////////////////////////////////////////////////////////////

// Contains trusted root certificates and intermediates, used to validate end-use X509 certificates,
// such as those used by individual organizations to secure websites, sign software etc.
class X509TrustStore
{
    ArrayList<X509Certificate> rootCerts(); // these are Certificate Authorities etc.

    // Empty trust store.
    void constructor()
    {

    }

    // Load default root certificates (true).
    void constructor(bool loadDefaultRootCerts)
    {
        if(loadDefaultRootCerts == true)
        {
            addDefaultRootCerts();
        }
    }

    // Root certificates are not signed (or self-signed). They are trusted to sign other certificates.
    bool addRootCert(String<u8> certPEM)
    {
        return this.addRootCerts(certPEM);
    }

    // Root certificates are not signed (or self-signed). They are trusted to sign other certificates.
    bool addRootCert(ByteArray certDER)
    {
        X509Certificate newCertX = X509Certificate();
        if(newCertX.readCertificate(certDER) == false)
            return false;

        addRootCert(newCertX);
        return true;
    }

    // Root certificates are not signed (or self-signed). They are trusted to sign other certificates.
    void addRootCert(X509Certificate cert)
    {
        this.rootCerts.add(cert);
    }

    // Root certificates are not signed (or self-signed). They are trusted to sign other certificates.
    void addRootCerts(ArrayList<X509Certificate> certs)
    {
        this.rootCerts.addAll(certs);
    }

    // Root certificates are not signed (or self-signed). They are trusted to sign other certificates.
    bool addRootCerts(String<u8> certsPEM)
    {
        ArrayList<X509Certificate> newCerts = X509Certificate:readCertificates(certsPEM);
        if(newCerts == null)
            return false;
        if(newCerts.size() == 0)
            return false;

        addRootCerts(newCerts);

        return true;
    }

    // Add default root certificates. This is a small selection of root certificates to trust in regards
    // to TLS (HTTPS) etc. It is neither exhaustive nor guaranteed to be up to date.
    void addDefaultRootCerts()
    {
        u8[] certsFileContents = HVM:getPackageFile("CertificateAuthorityCerts.txt");
        if(certsFileContents == null)
            return;

        String<u8> certsPEM(certsFileContents);

        String<u8> readErrorsStr();
        ArrayList<X509Certificate> caCerts = X509Certificate:readCertificates(certsPEM, readErrorsStr);
        if(caCerts == null)
            return;
        
        rootCerts.addAll(caCerts);
    }

    // Get a root/intermediate by matching DER binary file.
    X509Certificate getTrustedCertByFile(ByteArray certDERFile)
    {
        if(certDERFile == null)
            return null;

        for(u64 r=0; r<rootCerts.size(); r++)
        {
            if(rootCerts[r].certFile == null)
                continue;

            if(rootCerts[r].certFile.compare(certDERFile) == true)
                return rootCerts[r];
        }

        return null;
    }

    // Get a root/intermediate by matching DER binary file.
    X509Certificate getTrustedCertBySubjectKey(ByteArray subjectKey)
    {
        if(subjectKey == null)
            return null;

        for(u64 r=0; r<rootCerts.size(); r++)
        {
            if(rootCerts[r].subjectKey == null)
                continue;

            if(rootCerts[r].subjectKey.compare(subjectKey) == true)
                return rootCerts[r];
        }

        return null;
    }

    // Validate a certificate chain against the current root/intermediate certificates. Server certificate must be first in list. Returns true if certificate valid.
    bool validateCertChain(ArrayList<X509Certificate> certChain)
    {
        String<u8> msgs();
        return validateCertChain(certChain, msgs);
    }

    // Validate a certificate chain against the current root/intermediate certificates. Server certificate must be first in list. Returns true if certificate valid.
    bool validateCertChain(ArrayList<X509Certificate> certChain, String<u8> errorsOut)
    {
        if(certChain.size() == 0)
        {
            errorsOut.append("No certificates in certificate chain!");
            return false;
        }

        // check each certificate is signed by the one above, then check last one is in the root store or signed by one of the roots/intermediates
        for(u64 c=1; c<certChain.size(); c++)
        {
            X509Certificate childCert  = certChain[c-1];
            X509Certificate parentCert = certChain[c];

            // child cert must have valid dates
            if(childCert.isDateValid() == false)
            {
                errorsOut.append("Certificate is expired (date range invalid).");
                return false;
            }

            if(childCert.tbsRecordBytes == null)
            {
                errorsOut.append("Certificate missing valid TBSCertificate bytes.");
                return false;
            }

            u8[] childHash = childCert.getTBSRecordHash();
            if(childHash == null)
            {
                errorsOut.append("Unable to calculate child TBSCertificate hash.");
                return false;
            }

            // parentCert certificate must be able to sign child certificates
            if(parentCert.rootCert == false)
            {
                errorsOut.append("Certificate in chain cannot be used to sign other certificates.");
                return false;
            }

            // decrypt the signature from the child certificate using the public RSA key from the parent
            if(parentCert.rsaPublicKey == null)
            {
                errorsOut.append("Missing RSA public key for parent certificate.");
                return false;
            }

            // critical signature check
            if(parentCert.rsaPublicKey.verifySignature(childCert.signatureBytes.toArray(), childHash) == false)
            {
                errorsOut.append("RSA public key signature verification check failed.");
                return false;
            }
        }

        X509Certificate lastCert = certChain.getLast();
        if(getTrustedCertByFile(lastCert.certFile) != null)
            return true; // last certificate is trusted certificate

        // find certificate that could sign this
        if(getTrustedCertBySubjectKey(lastCert.authorityKey) != null)
            return true;

        errorsOut.append("No trusted root/intermediate certificate found that could verify this certificate chain.");
        return false; // no root/intermediate trusted
    }
}