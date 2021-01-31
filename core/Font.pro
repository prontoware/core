////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// FontDesc
////////////////////////////////////////////////////////////////////////////////////////////////////

// Font face name etc.
class FontDesc
{
	String<u8> name();

	void constructor(String<u8> name)
	{
		this.name = String<u8>(name);
	}
}

// class FontGlyphChar // built-in type
// {
//     u8  channel; // of image
//	   u16 x;
//     u16 y;
//     u16 width;
//     u16 height;
//     u16 xOffset;
//     u16 yOffset;
//     u16 xAdvance;
//	   u32 char; // UTF 32
// }

////////////////////////////////////////////////////////////////////////////////////////////////////
// Font
////////////////////////////////////////////////////////////////////////////////////////////////////

// A font for rendering text with. Normal usage is to call Font:getFont(...) and let fonts be cached
// behind the scenes.
class Font
{
	// These three font faces are different on each system, but always return something that matches.
	shared String<u8> DEFAULT_FONT_FACE       = "FONT_DEFAULT";       // sans-serif
	shared String<u8> DEFAULT_FONT_FACE_SERIF = "FONT_DEFAULT_SERIF"; // serif
	shared String<u8> DEFAULT_FONT_FACE_FIXED = "FONT_DEFAULT_FIXED"; // fixed character width font (AKA monospaced)
	shared ArrayList<Font> globalCachedFonts();
	
	FontGlyphMap glyphMap;
	ImageRGBA    fontImg; // data stolen from glyphMap.fontImg (NativeImage)

	// Null font, no usable for rendering.
	void constructor()
	{

	}

	// Create font with standard latin charater set.
	void constructor(String<u8> fontName, u16 fontSize)
	{
		create(fontName, fontSize, true, false, false);
	}

	// Create font with standard latin charater set.
	void constructor(String<u8> fontName, u16 fontSize, bool antiAliasing)
	{
		create(fontName, fontSize, antiAliasing, false, false);
	}

	// Create font with standard latin charater set.
	void constructor(String<u8> fontName, u16 fontSize, bool antiAliasing, bool bold, bool italics)
	{
		create(fontName, fontSize, antiAliasing, bold, italics);
	}

	// Create font with standard custom charater set. Specify characters to be available via utf32s.
	void constructor(String<u8> fontName, u16 fontSize, bool antiAliasing, bool bold, bool italics, String<u32> utf32s)
	{
		create(fontName, fontSize, antiAliasing, bold, italics, utf32s);
	}

	// Create font with standard latin charater set.
	void create(String<u8> fontName, u16 fontSize, bool antiAliasing, bool bold, bool italics)
	{
		String<u32> utf32s();

		for(u32 c=0; c<128; c++)
		{
			utf32s.append(c);
		}

		create(fontName, fontSize, antiAliasing, bold, italics, utf32s);
	}

	// Create font with standard custom charater set. Specify characters to be available via utf32s.
	void create(String<u8> fontName, u16 fontSize, bool antiAliasing, bool bold, bool italics, String<u32> utf32s)
	{
		this.glyphMap = NativeImage:genFontGlyphMap(fontName, fontSize, antiAliasing, bold, italics, utf32s);

		this.fontImg = ImageRGBA(glyphMap.fontImg);
		glyphMap.fontImg = null; // stolen
	}

	// Font name. i.e. "Arial".
	String<u8> getName()
	{
		return glyphMap.fontName;
	}

	// Get pixel height of line of text for this font.
	u16 getLineHeight()
	{
		return glyphMap.lineHeight;
	}

	// Offset to base of font (from top of line).
	u16 getLineBase()
	{
		return glyphMap.lineBase;
	}

	// Get font pixel size.
	u16 getSize()
	{
		return glyphMap.fontSize;
	}

	// Is bold?
	bool isBold()
	{
		return glyphMap.bold;
	}

	// Is italics?
	bool isItalics()
	{
		return glyphMap.italics;
	}

	// Get character description. Returns NULL if not mapped in this font.
	FontGlyphChar getCharDesc(u32 charID)
	{
		for(u64 c=0; c<glyphMap.charsMeta.length(); c++)
		{
			if(glyphMap.charsMeta[c].charID == charID)
				return glyphMap.charsMeta[c];
		}

		return null;
	}

	// Calculate the width of a string of characters rendered using this font in pixels.
	i32 getStringWidth(String<u8> str, u64 startCharIndex, u64 endCharIndex)
	{
		if(str == null)
			return 0;

		if(str.length() == 0)
			return 0;

		if(endCharIndex >= str.length())
			endCharIndex = str.length()-1;

		i32 totalWidth = 0;
		for(u64 c=startCharIndex; c<=endCharIndex; c++)
		{
			u32 charID = str[c];
			FontGlyphChar charGlyph = getCharDesc(charID);
			if(charGlyph == null)
				continue;

			totalWidth += charGlyph.xAdvance;
		}

		return totalWidth;
	}

	// Calculate the width of a string of characters rendered using this font in pixels.
	i32 getStringWidth(String<u8> str)
	{
		if(str == null)
			return 0;

		if(str.length() == 0)
			return 0;

		return getStringWidth(str, 0, str.numChars-1);
	}

	// Calculate the width of a string of characters rendered using this font in pixels.
	i32 getStringWidth(String<u32> str, u64 startCharIndex, u64 endCharIndex)
	{
		if(str == null)
			return 0;

		if(str.length() == 0)
			return 0;

		if(endCharIndex >= str.length())
			endCharIndex = str.length()-1;
		
		i32 totalWidth = 0;
		for(u64 c=startCharIndex; c<=endCharIndex; c++)
		{
			u32 charID = str[c];
			FontGlyphChar charGlyph = getCharDesc(charID);
			if(charGlyph == null)
				continue;

			totalWidth += charGlyph.xAdvance;
		}

		return totalWidth;
	}

	// Calculate the width of a string of characters rendered using this font in pixels.
	i32 getStringWidth(String<u32> str)
	{
		if(str == null)
			return 0;

		if(str.length() == 0)
			return 0;
		
		return getStringWidth(str, 0, str.numChars-1);
	}


	// Glyphs.
	ImageRGBA getGlyphImage()
	{
		return fontImg;
	}

	// Get all fonts available on this system.
	shared IList<FontDesc> getAvailableFonts()
	{
		ArrayList<FontDesc> allFonts();

		String<u8>[] fontNames = NativeImage:getAvailableFonts();
		for(u64 f=0; f<fontNames.length(); f++)
			allFonts.add(FontDesc(fontNames[f]));

		return allFonts;
	}

	// Get default face font name, always sans-serif style face.
	shared String<u8> getDefaultName()
	{
		return String<u8>(DEFAULT_FONT_FACE);
	}

	// Get default face font name with serif-style font face.
	shared String<u8> getDefaultSerifName()
	{
		return String<u8>(DEFAULT_FONT_FACE_SERIF);
	}

	// Get default face font name with fixed width characters.
	shared String<u8> getDefaultFixedName()
	{
		return String<u8>(DEFAULT_FONT_FACE_FIXED);
	}

	// Get default face font, always sans-serif style face.
	Font createDefault(u16 fontSize)
	{
		return Font(DEFAULT_FONT_FACE, fontSize);
	}

	// Get default face font, with serif-style font face.
	Font createDefaultSerif(u16 fontSize)
	{
		return Font(DEFAULT_FONT_FACE_SERIF, fontSize);
	}

	// Get default face font fixed width characters.
	Font createDefaultFixed(u16 fontSize)
	{
		return Font(DEFAULT_FONT_FACE_FIXED, fontSize);
	}

	// Get a font. If the font doesn't exist in the cache it is created.
	shared Font getFont(String<u8> fontFace, u16 fontSize)
	{
		return getFont(fontFace, fontSize, false, false);
	}

	// Get a font. If the font doesn't exist in the cache it is created.
	shared Font getFont(String<u8> fontFace, u16 fontSize, bool bold, bool italics)
	{
		if(fontFace == null)
			fontFace = String<u8>(DEFAULT_FONT_FACE);

		if(fontFace.length() == 0)
			fontFace = String<u8>(DEFAULT_FONT_FACE);

		for(u64 f=0; f<globalCachedFonts.size(); f++)
		{
			if(globalCachedFonts[f].glyphMap.fontSize != fontSize)
				continue;

			if(globalCachedFonts[f].glyphMap.bold != bold)
				continue;

			if(globalCachedFonts[f].glyphMap.italics != italics)
				continue;

			if(globalCachedFonts[f].glyphMap.fontName.compare(fontFace) == false)
				continue;

			return globalCachedFonts[f];
		}

		Font newFont(fontFace, fontSize, true, bold, italics);
		globalCachedFonts.add(newFont);

		return newFont;
	}
}