////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class CharsTests implements IUnitTest
{
	void run()
	{
		u8 ch = Chars:A;
		test(Chars:toLower(ch) == Chars:a);

		ch = Chars:a;
		test(Chars:toUpper(ch) == Chars:A);

		// default group has none
		CharGroup chGroup = CharGroup();
		test(chGroup.contains(Chars:a) == false);

		chGroup.setToPredefined(CharGroup:WHITESPACE);
		test(chGroup.contains(Chars:SPACE) == true);
		test(chGroup.contains(Chars:A) == false);
	}
}