////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Chars
////////////////////////////////////////////////////////////////////////////////////////////////////

// Global set of ASCII constants, plus char utility methods
class Chars
{
	// control
	const u8 NULL_CHAR = 0;
	const u8 START_HEADING = 1;
	const u8 START_TEXT = 2;
	const u8 END_TEXT = 3;
	const u8 END_TRANSMISSION = 4;
	const u8 ENQUIRY = 5;
	const u8 ACKNOWLEDGMENT = 6;
	const u8 BELL = 7;
	const u8 BACK_SPACE = 8;
	const u8 HTAB = 9;
	const u8 NEW_LINE = 10; // AKA \n
	const u8 VTAB = 11;
	const u8 FORM_FEED = 12;
	const u8 RETURN = 13; // AKA \r
	const u8 SHIFT_OUT = 14;
	const u8 SHIFT_IN = 15;
	const u8 DATA_LINE_ESCAPE = 16;
	const u8 DEVICE_CTRL_1 = 17;
	const u8 DEVICE_CTRL_2 = 18;
	const u8 DEVICE_CTRL_3 = 19;
	const u8 DEVICE_CTRL_4 = 20;
	const u8 NEGATIVE_ACKNOWLEDGEMENT = 21;
	const u8 SYNCHRONOUS_IDLE = 22;
	const u8 END_TRANSMIT_BLOCK = 23;
	const u8 CANCEL = 24;
	const u8 END_OF_MEDIUM = 25;
	const u8 SUBSTITUTE = 26;
	const u8 ESCAPE = 27;
	const u8 FILE_SEPARATOR = 28;
	const u8 GROUP_SEPARATOR = 29;
	const u8 RECORD_SEPARATOR = 30;
	const u8 UNIT_SEPARATOR = 31;

	// printable
	const u8 SPACE = 32;
	const u8 EXCLAMATION = 33;
	const u8 DOUBLE_QUOTE = 34;
	const u8 NUMBER = 35;
	const u8 DOLLAR = 36;
	const u8 PERCENT = 37;
	const u8 AMPERSAND = 38;
	const u8 SINGLE_QUOTE = 39;
	const u8 OPEN_PARENTHESIS = 40;
	const u8 CLOSE_PARENTHESIS = 41;
	const u8 ASTERISK = 42;
	const u8 PLUS = 43;
	const u8 COMMA = 44;
	const u8 HYPHEN = 45;
	const u8 PERIOD = 46;
	const u8 FORWARD_SLASH = 47;

	// numbers
	const u8 ZERO  = 48;
	const u8 ONE   = 49;
	const u8 TWO   = 50;
	const u8 THREE = 51;
	const u8 FOUR  = 52;
	const u8 FIVE  = 53;
	const u8 SIX   = 54;
	const u8 SEVEN = 55;
	const u8 EIGHT = 56;
	const u8 NINE  = 57;

	const u8 COLON = 58;
	const u8 SEMI_COLON = 59;
	const u8 OPEN_ANGLE_BRACKET = 60;
	const u8 EQUALS = 61;
	const u8 CLOSE_ANGLE_BRACKET = 62;
	const u8 QUESTION = 63;
	const u8 AT = 64;

	// upper case
	const u8 A = 65;
	const u8 B = 66;
	const u8 C = 67;
	const u8 D = 68;
	const u8 E = 69;
	const u8 F = 70;
	const u8 G = 71;
	const u8 H = 72;
	const u8 I = 73;
	const u8 J = 74;
	const u8 K = 75;
	const u8 L = 76;
	const u8 M = 77;
	const u8 N = 78;
	const u8 O = 79;
	const u8 P = 80;
	const u8 Q = 81;
	const u8 R = 82;
	const u8 S = 83;
	const u8 T = 84;
	const u8 U = 85;
	const u8 V = 86;
	const u8 W = 87;
	const u8 X = 88;
	const u8 Y = 89;
	const u8 Z = 90;

	const u8 OPEN_SQUARE_BRACKET = 91;
	const u8 BACK_SLASH = 92;
	const u8 CLOSE_SQUARE_BRACKET = 93;
	const u8 CARET = 94;
	const u8 UNDERSCORE = 95;
	const u8 GRAVE = 96;

	// lower case
	const u8 a = 97;
	const u8 b = 98;
	const u8 c = 99;
	const u8 d = 100;
	const u8 e = 101;
	const u8 f = 102;
	const u8 g = 103;
	const u8 h = 104;
	const u8 i = 105;
	const u8 j = 106;
	const u8 k = 107;
	const u8 l = 108;
	const u8 m = 109;
	const u8 n = 110;
	const u8 o = 111;
	const u8 p = 112;
	const u8 q = 113;
	const u8 r = 114;
	const u8 s = 115;
	const u8 t = 116;
	const u8 u = 117;
	const u8 v = 118;
	const u8 w = 119;
	const u8 x = 120;
	const u8 y = 121;
	const u8 z = 122;

	const u8 OPEN_BRACE   = 123;
	const u8 VERTICAL_BAR = 124;
	const u8 CLOSE_BRACE  = 125;
	const u8 TILDE        = 126;
	const u8 DELETE_CHAR  = 127;

	// Convert char (number/byte) to uppercase.
	shared u8 toUpper(u8 ch)
	{
		// Lowercase
		if(ch >= a && ch <= 122)
			return ch - 32;

		return ch;
	}

	// Convert char (number/byte) to lowercase.
	shared u8 toLower(u8 ch)
	{
		// Upper case
		if(ch >= 65 && ch <= 90)
			return ch + 32;

		return ch;
	}

	// Convert char hex (s) digit to number.
	shared u8 hexToNumber(u8 ch)
	{
		//48 - 57 are 0 - 9 chars
		if(ch >= 48 && ch <= 57)
			return ch - 48;

		//65 - 70 are A - F chars
		if(ch >= 65 && ch <= 70)
			return 10 + (ch - 65);

		//97 - 102 are a - f chars
		if(ch >= 97 && ch <= 102)
			return 10 + (ch - 97);

		return -1; //error
	}

	// Convert number (0-15) to hex char.
	shared u8 numberToHex(i32 val)
	{
		if(val <= 9)
			return val + 48;

		if(val <= 15)
			return (val - 10) + 65;

		return Chars:Z; //error
	}

	// Pass in the ASCII value for one of \\, \n, \r etc. get the second "char"
	shared u8 escapableCharLetter(i32 ch)
	{
		if(ch == Chars:BACK_SLASH)
			return Chars:BACK_SLASH;

		if(ch == Chars:NEW_LINE)
			return Chars:n;

		if(ch == Chars:RETURN)
			return Chars:r;

		if(ch == Chars:HTAB)
			return Chars:t;

		if(ch == Chars:VTAB)
			return Chars:v;

		if(ch == Chars:SINGLE_QUOTE)
			return Chars:SINGLE_QUOTE;

		if(ch == Chars:DOUBLE_QUOTE)
			return Chars:DOUBLE_QUOTE;

		return 0;
	}

	// All ASCII characters >= 0 && <= 127
	shared bool isASCII(u8 ch)
	{
		if(ch >= 0 && ch <= 127)
			return true;

		return false;
	}

	// Whitepsace
	shared bool isWhitespace(u8 ch)
	{
		if(ch == Chars:SPACE || ch == Chars:HTAB || ch == Chars:RETURN || ch == Chars:NEW_LINE || ch == Chars:VTAB || ch == Chars:FORM_FEED)
			return true;

		return false;
	}

	// All control characters - includes whitespace, seperators etc.  ASCII values 0 to 31 inclusive.
	shared bool isControl(u8 ch)
	{
		if(ch >= 0 && ch <= 32)
			return true;

		return false;
	}

	// All upper and lower case letters.
	shared bool isAlpha(u8 ch)
	{
		//Upper case
		if(ch >= 65 && ch <= 90)
			return true;

		//Lowercase
		if(ch >= 97 && ch <= 122)
			return true;

		return false;
	}

	// All numeric digits (0 - 9).
	shared bool isNumeric(u8 ch)
	{
		if(ch >= 48 && ch <= 57)
			return true;

		return false;
	}

	// All upper and lower case letters and all numeric digits (0 - 9).
	shared bool isAlphaNumeric(u8 ch)
	{
		//Upper case
		if(ch >= 65 && ch <= 90)
			return true;

		//Lowercase
		if(ch >= 97 && ch <= 122)
			return true;

		//Numbers 0 - 9
		if(ch >= 48 && ch <= 57)
			return true;

		return false;
	}

	// All numeric digits (0 - 9) + ABCDEF / abcdef.
	shared bool isHex(u8 ch)
	{
		//48 - 57 are 0 - 9 chars
		if(ch >= 48 && ch <= 57)
			return true;

		//65 - 70 are A - F chars
		if(ch >= 65 && ch <= 70)
			return true;

		//97 - 102 are a - f chars
		if(ch >= 97 && ch <= 102)
			return true;

		return false;
	}

	// All numeric digits (0 - 9) as well as: . + -
	shared bool isNumber(u8 ch)
	{
		if(ch >= 48 && ch <= 57)
			return true;

		if(ch == Chars:PERIOD || ch == Chars:PLUS || ch == Chars:HYPHEN)
			return true;

		return false;
	}

	// Standard "acceptable" user input includes:
	// -Alpha: A to Z, a to z
	// -Numeric : 0 to 9
	// -Punctuation : , .; : ' " etc.
	shared bool isUserInput(u8 ch)
	{
		//Upper case
		if(ch >= 65 && ch <= 90)
			return true;

		//Lowercase
		if(ch >= 97 && ch <= 122)
			return true;

		//Numeric
		if(ch >= 48 && ch <= 57)
			return true;

		//Punctuation: Space, Exclamation, Double Quote, Dollar, etc.
		if(ch >= 32 && ch <= 47)
			return true;

		//Brackets, grave etc.
		if(ch >= 91 && ch <= 96)
			return true;

		//Brace, grave etc.
		if(ch >= 123 && ch <= 126)
			return true;

		return false;
	}

	// Escapable characters
	// -Backslash: \\
	// -Newline: \n
	// -Return: \r
	// -Tab: \t
	// -Vertical tab :
	// -Quote : '
	// -Double Quote : "
	shared bool isEscapable(u8 ch)
	{
		if(ch == Chars:BACK_SLASH)
			return true;

		if(ch == Chars:NEW_LINE || ch == Chars:RETURN)
			return true;

		if(ch == Chars:HTAB || ch == Chars:VTAB)
			return true;

		if(ch == Chars:SINGLE_QUOTE || ch == Chars:DOUBLE_QUOTE)
			return true;

		return false;
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// CharGroup
///////////////////////////////////////////////////////////////////////////////////////////////////

// A group of character types. For example, you could have a group of all "whitespace"
// characters. Some groups are statically predefined here. Also there are shared utility
// methods for combining groups, doing the inverse (not in group) etc.
// ASCII / UTF8 only.
class CharGroup
{
	//Some predefined groups
	const u8 ALL          = 1; //all ASCII
	const u8 WHITESPACE   = 2; //all whitespace
	const u8 CONTROL      = 3; //all control characters
	const u8 ALPHA        = 4; //all lower/upper case
	const u8 NUMERIC      = 5; //all digits
	const u8 NUMBERS      = 6; //0 to 9 and . + -
	const u8 ALPHANUMERIC = 7; //all lower/upper case + digits
	const u8 HEX          = 8; //digits + abcdef
	const u8 USERINPUT    = 9; //upper/lower + numbers + punctuation
	const u8 ESCAPALBE    = 10; //\n \r \t etc.

	u8[] chars = u8[](256); // group of chars
	
	// Default group has no characters.
	void constructor()
	{
		for(i32 c=0; c<256; c++)
			chars[c] = false;
	}

	// One of ALL, WHITESPACE, CONTROL, ALPHA etc.
	void constructor(u8 preDefinedSet)
	{
		setToPredefined(preDefinedSet);
	}

	void setToPredefined(u8 preDefinedSet)
	{
		if(preDefinedSet == ALL)
		{
			for(i32 c = 0; c<256; c++)
				chars[c] = Chars:isASCII(c);
		}
		else if(preDefinedSet == WHITESPACE)
		{
			for(i32 c = 0; c<256; c++)
				chars[c] = Chars:isWhitespace(c);
		}
		else if(preDefinedSet == CONTROL)
		{
			for(i32 c = 0; c<256; c++)
				chars[c] = Chars:isControl(c);
		}
		else if(preDefinedSet == ALPHA)
		{
			for(i32 c = 0; c<256; c++)
				chars[c] = Chars:isAlpha(c);
		}
		else if(preDefinedSet == NUMERIC)
		{
			for(i32 c = 0; c<256; c++)
				chars[c] = Chars:isNumeric(c);
		}
		else if(preDefinedSet == NUMBERS)
		{
			for(i32 c = 0; c<256; c++)
				chars[c] = Chars:isNumber(c);
		}
		else if(preDefinedSet == ALPHANUMERIC)
		{
			for(i32 c = 0; c<256; c++)
				chars[c] = Chars:isAlphaNumeric(c);
		}
		else if(preDefinedSet == HEX)
		{
			for(i32 c = 0; c<256; c++)
				chars[c] = Chars:isHex(c);
		}
		else if(preDefinedSet == USERINPUT)
		{
			for(i32 c = 0; c<256; c++)
				chars[c] = Chars:isUserInput(c);
		}
		else if(preDefinedSet == ESCAPALBE)
		{
			for(i32 c = 0; c<256; c++)
				chars[c] = Chars:isEscapable(c);
		}
		else
		{
			for(i32 c = 0; c<256; c++)
				chars[c] = false;
		}
	}

	// Create CharGroup with one of the predefined sets.
	shared CharGroup createPredefinedSet(u8 setID)
	{
		CharGroup g = CharGroup();
		g.setToPredefined(setID);
		return g;
	}

	void copy(CharGroup obj)
	{
		for(i32 c=0; c<256; c++)
			chars[c] = obj.chars[c];
	}

	// Add a single char to this group
	void add(u8 newCh)
	{
		chars[newCh] = true;
	}

	// Add a set of chars to this group
	void add(CharGroup group)
	{
		for(i32 c=0; c<256; c++)
			chars[c] = group.contains(c);
	}

	// Remove a single char from this group
	void remove(u8 newCh)
	{
		chars[newCh] = false;
	}

	// Invert - chars NOT in group.
	void invert()
	{
		for(i32 c=0; c<256; c++)
			chars[c] = !chars[c];
	}

	// Returns true if this char is part of the group.
	bool contains(u8 ch)
	{
		if(ch >= 256)
			return false;

		if(chars[ch] == true)
			return true;

		return false;
	}
}