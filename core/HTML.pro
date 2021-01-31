////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// HTML
////////////////////////////////////////////////////////////////////////////////////////////////////

// HTML Utilities.
class HTML
{
	shared IMap<u8, String<u8>> htmlTextEncodeMap = null;

	// Initialize maps - one-time event automatically triggered.
	shared void initMaps()
	{
		if(htmlTextEncodeMap != null)
			return;

		htmlTextEncodeMap = ArrayMap<u8, String<u8>>();

		for(u8 ch=0; ch<120; ch++)
		{
			// just do a few select cases that absolutely cannot be in HTML text. " and ' can't be in attribute text
			if(ch == Chars:OPEN_ANGLE_BRACKET || ch == Chars:CLOSE_ANGLE_BRACKET || ch == Chars:AMPERSAND || ch == Chars:SINGLE_QUOTE || ch == Chars:DOUBLE_QUOTE)
			{
				String<u8> str("&#"); // &#NN; or &#NNN; where N is decimal number
				str.append(String<u8>:formatNumber(ch));
				str.append(Chars:SEMI_COLON);

				htmlTextEncodeMap.add(ch, str);
			}
		}
	}

	// Some characters like < need to be encoded to &#60; for HTML since they conflict with XML tag structure etc.
	shared String<u8> encodeHTMLText(String<u8> str)
	{
		initMaps();

		if(str == null)
			return String<u8>();

		String<u8> s(str.numChars);
		for(u64 c=0; c<str.numChars; c++)
		{
			u8 ch = str.chars[c];
			if(htmlTextEncodeMap.contains(ch) == true)
			{
				String<u8> encodingStr = htmlTextEncodeMap.get(ch);
				s.append(encodingStr);
			}
			else
			{
				s.append(ch);
			}
		}

		return s;
	}

	// Some characters like < need to be decoded from &#60; in HTML since they conflict with XML tag structure etc.
	shared String<u8> decodeHTMLText(String<u8> htmlText)
	{
		initMaps();

		if(htmlText == null)
			return String<u8>();

		String<u8> s(htmlText.numChars);
		for(u64 c=0; c<htmlText.numChars; c++)
		{
			u8 ch = htmlText.chars[c];
			if(ch == Chars:AMPERSAND && (c+4) < htmlText.numChars)
			{
				u8 ch1 = htmlText.chars[c+1]; // #
				u8 ch2 = htmlText.chars[c+2];
				u8 ch3 = htmlText.chars[c+3];
				u8 ch4 = htmlText.chars[c+4];

				if(ch1 != Chars:NUMBER || ch2 < Chars:ZERO || ch2 > Chars:NINE || ch3 < Chars:ZERO || ch3 > Chars:NINE)
				{
					s.append(ch);
					continue;
				}

				// some chars are two, some are three digits long
				if(ch4 == Chars:SEMI_COLON)
				{
					u8 n0 = ch2 - Chars:ZERO;
					u8 n1 = ch3 - Chars:ZERO;

					u8 realChar = (n0 * 10) + n1;
					s.append(realChar);

					c += 4; // skip #NN;
				}
				else // 3 digits
				{
					u8 n0 = ch2 - Chars:ZERO;
					u8 n1 = ch3 - Chars:ZERO;
					u8 n2 = ch4 - Chars:ZERO;

					u8 realChar = (n0 * 100) + (n1 * 10) + n2;
					s.append(realChar);

					c += 5; // skip #NNN;
				}
			}
			else
			{
				s.append(ch);
			}
		}

		return s;
	}
}