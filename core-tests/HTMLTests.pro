////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class HTMLTextEncodeTests implements IUnitTest
{
	void run()
	{
		String<u8> originalText("The template interface ICollection<A> represents...");

		String<u8> htmlSafeText = HTML:encodeHTMLText(originalText);
		test(htmlSafeText.compare("The template interface ICollection&#60;A&#62; represents...") == true);

		String<u8> revertText = HTML:decodeHTMLText(htmlSafeText);
		test(revertText.compare(originalText) == true);
	}
}