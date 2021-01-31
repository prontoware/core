////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// ColorFormat
////////////////////////////////////////////////////////////////////////////////////////////////////

// Constants and utilties for pixel color formats.
class ColorFormat
{
	// RGB integer pixel formats.
	const u8 UNKNOWN  = 0;
	const u8 RGB5A1   = 1; // OpenGL ES 2.0 must support for rendering.
	const u8 RGBA4    = 2; // OpenGL ES 2.0 must support for rendering.
	const u8 RGBA8    = 3; // OpenGL ES 3.0 must support for rendering.
	const u8 R8       = 4; // Single channel

	// RGB floating-point pixel formats.
	const u8 R_F16    = 10; // Single channel
	const u8 R_F24    = 11; // Single channel, only used for depth formats.
	const u8 R_F32    = 12; // Single channel
	const u8 RGBA_F16 = 13;
	const u8 RGBA_F32 = 14;

	// Bytes per pixel for color format?
	shared u8 getPixelSize(u8 format)
	{
		if(format == RGB5A1)
			return 2;
		if(format == RGBA4)
			return 2;
		if(format == RGBA8)
			return 4;
		if(format == R8)
			return 1;

		if(format == R_F16)
			return 2;
		if(format == R_F24)
			return 3;
		if(format == R_F32)
			return 4;
		if(format == RGBA_F16)
			return 8;
		if(format == RGBA_F32)
			return 16;

		return 0; // unknown
	}

	// How many channels per pixel in this format?
	shared u8 getNumChannels(u8 format)
	{
		if(format == RGB5A1)
			return 4;
		if(format == RGBA4)
			return 4;
		if(format == RGBA8)
			return 4;
		if(format == R8)
			return 1;

		if(format == R_F16)
			return 1;
		if(format == R_F32)
			return 1;
		if(format == RGBA_F16)
			return 4;
		if(format == RGBA_F32)
			return 4;

		return 0; // unknown
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// ColorRGBA
////////////////////////////////////////////////////////////////////////////////////////////////////

// 32 bit color divided into 8 bits per channel. Red, Green, Blue, and Alpha channels. Values range
// from 0 to 255 (full intensity).
class ColorRGBA
{
	const u8 CHANNEL_RED   = 0;
	const u8 CHANNEL_GREEN = 1;
	const u8 CHANNEL_BLUE  = 2;
	const u8 CHANNEL_ALPHA = 3;

	u8[4] rgba; // vector of RGBA channels

	// Black by default.
	void constructor()
	{
		rgba[CHANNEL_RED]   = 0;
		rgba[CHANNEL_GREEN] = 0;
		rgba[CHANNEL_BLUE]  = 0;
		rgba[CHANNEL_ALPHA] = 0;
	}

	// Set RGB, alpha assumed to be 255.
	void constructor(u8 r, u8 g, u8 b)
	{
		this.rgba[CHANNEL_RED]   = r;
		this.rgba[CHANNEL_GREEN] = g;
		this.rgba[CHANNEL_BLUE]  = b;
		this.rgba[CHANNEL_ALPHA] = 255;
	}

	// Set all four channels.
	void constructor(u8 r, u8 g, u8 b, u8 a)
	{
		this.rgba[CHANNEL_RED]   = r;
		this.rgba[CHANNEL_GREEN] = g;
		this.rgba[CHANNEL_BLUE]  = b;
		this.rgba[CHANNEL_ALPHA] = a;
	}

	// Copy passed-in.
	void constructor(ColorRGBA clr)
	{
		copy(clr);
	}

	// Copy passed-in.
	void constructor(ColorRGBAf clr)
	{
		copy(clr);
	}

	// Copy all four channels.
	void copy(ColorRGBA c)
	{
		this.rgba[CHANNEL_RED]   = c.rgba[CHANNEL_RED];
		this.rgba[CHANNEL_GREEN] = c.rgba[CHANNEL_GREEN];
		this.rgba[CHANNEL_BLUE]  = c.rgba[CHANNEL_BLUE];
		this.rgba[CHANNEL_ALPHA] = c.rgba[CHANNEL_ALPHA];
	}

	// Copy all four channels.
	void copy(ColorRGBAf c)
	{
		this.rgba[CHANNEL_RED]   = Math:minMax(0, 255, Math:round(c.rgba[CHANNEL_RED] * 255.0f));
		this.rgba[CHANNEL_GREEN] = Math:minMax(0, 255, Math:round(c.rgba[CHANNEL_GREEN] * 255.0f));
		this.rgba[CHANNEL_BLUE]  = Math:minMax(0, 255, Math:round(c.rgba[CHANNEL_BLUE] * 255.0f));
		this.rgba[CHANNEL_ALPHA] = Math:minMax(0, 255, Math:round(c.rgba[CHANNEL_ALPHA] * 255.0f));
	}

	// Return exact copy.
	ColorRGBA clone()
	{
		ColorRGBA c = ColorRGBA();
		c.rgba[CHANNEL_RED]   = this.rgba[CHANNEL_RED];
		c.rgba[CHANNEL_GREEN] = this.rgba[CHANNEL_GREEN];
		c.rgba[CHANNEL_BLUE]  = this.rgba[CHANNEL_BLUE];
		c.rgba[CHANNEL_ALPHA] = this.rgba[CHANNEL_ALPHA];
		return c;
	}

	// Equality check.
	bool equals(ColorRGBA clr)
	{
		for(u8 c=0; c<4; c++)
		{
			if(this.rgba[c] != clr.rgba[c])
				return false;
		}

		return true;
	}

	// Overrides [] operator to get color by channel.
	u8 get(u64 rgbaIndex)
	{
		return this.rgba[rgbaIndex];
	}

	// Overrides [] operator to set color by channel
	void set(u64 rgbaIndex, u8 colorChannelVal)
	{
		this.rgba[rgbaIndex] = colorChannelVal;
	}

	// Get red channel. 0 to 255.
	u8 getRed()   { return rgba[CHANNEL_RED]; }

	// Get green channel. 0 to 255.
	u8 getGreen() { return rgba[CHANNEL_GREEN]; }

	// Get blue channel. 0 to 255.
	u8 getBlue()  { return rgba[CHANNEL_BLUE]; }

	// Get alpha channel. 0 to 255.
	u8 getAlpha() { return rgba[CHANNEL_ALPHA]; }

	// Set red channel. 0 to 255.
	void setRed(u8 r)   { rgba[CHANNEL_RED] = r; }

	// Set green channel. 0 to 255.
	void setGreen(u8 g) { rgba[CHANNEL_GREEN] = g; }

	// Set blue channel. 0 to 255.
	void setBlue(u8 b)  { rgba[CHANNEL_BLUE] = b; }

	// Set alpha channel. 0 to 255.
	void setAlpha(u8 a) { rgba[CHANNEL_ALPHA] = a; }

	// Set all four channels
	void set(u8 r, u8 g, u8 b, u8 a)
	{
		this.rgba[CHANNEL_RED]   = r;
		this.rgba[CHANNEL_GREEN] = g;
		this.rgba[CHANNEL_BLUE]  = b;
		this.rgba[CHANNEL_ALPHA] = a;
	}

	// Set all four channels
	void set(u32 c)
	{
		this.rgba[CHANNEL_ALPHA] = (0xFF000000 & c) >> 24;
		this.rgba[CHANNEL_BLUE]  = (0x00FF0000 & c) >> 16;
		this.rgba[CHANNEL_GREEN] = (0x0000FF00 & c) >> 8;
		this.rgba[CHANNEL_RED]   = (0x000000FF & c);
	}

	// Get all four channels combined into u32 value in RGBA format. Red in bits 24 thru 31.
	u32 getU32()
	{
		u32 c = 0;

		u32 r = rgba[CHANNEL_RED];
		u32 g = rgba[CHANNEL_GREEN];
		u32 b = rgba[CHANNEL_BLUE];
		u32 a = rgba[CHANNEL_ALPHA];

		c |= (a << 24);
		c |= (b << 16);
		c |= (g <<  8);
		c |= r;

		return c;
	}

	// R:# G:# B:# A:#
	String<u8> toString()
	{
		String<u8> s = String<u8>(16);

		s.append("r: ");
		s.append(String<u8>:formatNumber(rgba[CHANNEL_RED]));
		s.append("g: ");
		s.append(String<u8>:formatNumber(rgba[CHANNEL_GREEN]));
		s.append("b: ");
		s.append(String<u8>:formatNumber(rgba[CHANNEL_BLUE]));
		s.append("a: ");
		s.append(String<u8>:formatNumber(rgba[CHANNEL_ALPHA]));

		return s;
	}

	// Returns "RRGGBBAA". Always 8 characters long.
	String<u8> toHexString()
	{
		String<u8> rgbaStr = String<u8>(8);

		String<u8> rStr = String<u8>:formatNumberHex(rgba[CHANNEL_RED]);
		rgbaStr.append(rStr);

		String<u8> gStr = String<u8>:formatNumberHex(rgba[CHANNEL_GREEN]);
		rgbaStr.append(gStr);

		String<u8> bStr = String<u8>:formatNumberHex(rgba[CHANNEL_BLUE]);
		rgbaStr.append(bStr);

		String<u8> aStr = String<u8>:formatNumberHex(rgba[CHANNEL_ALPHA]);
		rgbaStr.append(aStr);

		return rgbaStr;
	}

	// Parse "RRGGBBAA" with optional "#" or "0x" prefix. Can parse RGB with missing alpha.
	void parseHexString(String<u8> s)
	{
		if(s.beginsWith("#") == true)
			s = s.subString(1, s.length()-1);
		else if(s.beginsWith("0x") == true)
			s = s.subString(2, s.length()-1);
		else
			s = String<u8>(s);

		if(s.length() >= 6)
		{
			String<u8> rStr = s.subString(0, 1);
			this.rgba[CHANNEL_RED] = rStr.parseHex();

			String<u8> gStr = s.subString(2, 3);
			this.rgba[CHANNEL_GREEN] = gStr.parseHex();

			String<u8> bStr = s.subString(4, 5);
			this.rgba[CHANNEL_BLUE] = bStr.parseHex();
		}

		if(s.length() >= 8)
		{
			String<u8> aStr = s.subString(6, 7);
			this.rgba[CHANNEL_ALPHA] = aStr.parseHex();
		}
		else
		{
			this.rgba[CHANNEL_ALPHA] = 255;
		}
	}

	// Pack 8 bit color channel values into 32 bit value.
	shared u32 packRGBA(u32 r, u32 g, u32 b, u32 a)
	{
		u32 c = 0;

		c |= (a << 24);
		c |= (b << 16);
		c |= (g <<  8);
		c |= r;

		return c;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// ColorRGBAf
////////////////////////////////////////////////////////////////////////////////////////////////////

// 128 bit color divided into 32 bits floating-point number per channel. Red, Green, Blue, and
// Alpha channels. Values range from 0.0 to 1.0 (full intensity).
class ColorRGBAf
{
	const u8 CHANNEL_RED   = 0;
	const u8 CHANNEL_GREEN = 1;
	const u8 CHANNEL_BLUE  = 2;
	const u8 CHANNEL_ALPHA = 3;

	f32[4] rgba; // vector of RGBA channels

	// Black by default.
	void constructor()
	{
		rgba[CHANNEL_RED]   = 0.0f;
		rgba[CHANNEL_GREEN] = 0.0f;
		rgba[CHANNEL_BLUE]  = 0.0f;
		rgba[CHANNEL_ALPHA] = 0.0f;
	}

	// Set RGB, alpha assumed to be 255.
	void constructor(f32 r, f32 g, f32 b)
	{
		this.rgba[CHANNEL_RED]   = r;
		this.rgba[CHANNEL_GREEN] = g;
		this.rgba[CHANNEL_BLUE]  = b;
		this.rgba[CHANNEL_ALPHA] = 1.0f;
	}

	// Set all four channels.
	void constructor(f32 r, f32 g, f32 b, f32 a)
	{
		this.rgba[CHANNEL_RED]   = r;
		this.rgba[CHANNEL_GREEN] = g;
		this.rgba[CHANNEL_BLUE]  = b;
		this.rgba[CHANNEL_ALPHA] = a;
	}

	// Copy passed-in color.
	void constructor(ColorRGBA clr)
	{
		copy(clr);
	}

	// Copy passed-in color.
	void constructor(ColorRGBAf clr)
	{
		copy(clr);
	}

	// Copy all four channels.
	void copy(ColorRGBAf c)
	{
		this.rgba[CHANNEL_RED]   = c.rgba[CHANNEL_RED];
		this.rgba[CHANNEL_GREEN] = c.rgba[CHANNEL_GREEN];
		this.rgba[CHANNEL_BLUE]  = c.rgba[CHANNEL_BLUE];
		this.rgba[CHANNEL_ALPHA] = c.rgba[CHANNEL_ALPHA];
	}

	// Copy all four channels.
	void copy(ColorRGBA c)
	{
		this.rgba[CHANNEL_RED]   = Math:minMax(0.0f, 1.0f, c.rgba[CHANNEL_RED] / 255.0f);
		this.rgba[CHANNEL_GREEN] = Math:minMax(0.0f, 1.0f, c.rgba[CHANNEL_GREEN] / 255.0f);
		this.rgba[CHANNEL_BLUE]  = Math:minMax(0.0f, 1.0f, c.rgba[CHANNEL_BLUE] / 255.0f);
		this.rgba[CHANNEL_ALPHA] = Math:minMax(0.0f, 1.0f, c.rgba[CHANNEL_ALPHA] / 255.0f);
	}

	// Return exact copy.
	ColorRGBAf clone()
	{
		ColorRGBAf c = ColorRGBAf();
		c.rgba[CHANNEL_RED]   = this.rgba[CHANNEL_RED];
		c.rgba[CHANNEL_GREEN] = this.rgba[CHANNEL_GREEN];
		c.rgba[CHANNEL_BLUE]  = this.rgba[CHANNEL_BLUE];
		c.rgba[CHANNEL_ALPHA] = this.rgba[CHANNEL_ALPHA];
		return c;
	}

	// Equality check.
	bool equals(ColorRGBAf clr)
	{
		for(u8 c=0; c<4; c++)
		{
			if(this.rgba[c] != clr.rgba[c])
				return false;
		}

		return true;
	}

	// Overrides [] operator to get color by channel.
	f32 get(u64 index)
	{
		return this.rgba[index];
	}

	// Overrides [] operator to set color by channel
	void set(u64 rgbaIndex, f32 colorChannelVal)
	{
		this.rgba[rgbaIndex] = colorChannelVal;
	}

	// Get red channel. 0 to 1.0.
	f32 getRed() { return rgba[CHANNEL_RED]; }

	// Get green channel. 0 to 1.0.
	f32 getGreen() { return rgba[CHANNEL_GREEN]; }

	// Get blue channel. 0 to 1.0.
	f32 getBlue() { return rgba[CHANNEL_BLUE]; }

	// Get alpha channel. 0 to 1.0.
	f32 getAlpha() { return rgba[CHANNEL_ALPHA]; }

	// Set red channel. 0 to 1.0.
	void setRed(f32 r)   { rgba[CHANNEL_RED] = r; }

	// Set green channel. 0 to 1.0.
	void setGreen(f32 g) { rgba[CHANNEL_GREEN] = g; }

	// Set blue channel. 0 to 1.0.
	void setBlue(f32 b)  { rgba[CHANNEL_BLUE] = b; }

	// Set alpha channel. 0 to 1.0.
	void setAlpha(f32 a) { rgba[CHANNEL_ALPHA] = a; }

	// Set all four channels
	void set(f32 r, f32 g, f32 b, f32 a)
	{
		this.rgba[CHANNEL_RED]   = r;
		this.rgba[CHANNEL_GREEN] = g;
		this.rgba[CHANNEL_BLUE]  = b;
		this.rgba[CHANNEL_ALPHA] = a;
	}
	
	// R:# G:# B:# A:#
	String<u8> toString()
	{
		String<u8> s = String<u8>(16);

		s.append("r: ");
		s.append(String<u8>:formatNumber(rgba[CHANNEL_RED], 3));
		s.append("g: ");
		s.append(String<u8>:formatNumber(rgba[CHANNEL_GREEN], 3));
		s.append("b: ");
		s.append(String<u8>:formatNumber(rgba[CHANNEL_BLUE], 3));
		s.append("a: ");
		s.append(String<u8>:formatNumber(rgba[CHANNEL_ALPHA], 3));

		return s;
	}

	// Blend passed-in color with this color using passed-in constant alpha.
	void blend(ColorRGBAf clr, f32 clrAlpha)
	{
		f32 srcAlpha = clrAlpha;
		f32 desAlpha = 1.0f - srcAlpha;

		f32 r = (this.rgba[CHANNEL_RED]   * desAlpha) + (clr.rgba[CHANNEL_RED]   * srcAlpha);
		f32 g = (this.rgba[CHANNEL_GREEN] * desAlpha) + (clr.rgba[CHANNEL_GREEN] * srcAlpha);
		f32 b = (this.rgba[CHANNEL_BLUE]  * desAlpha) + (clr.rgba[CHANNEL_BLUE]  * srcAlpha);

		this.rgba[CHANNEL_RED]   = r;
		this.rgba[CHANNEL_GREEN] = g;
		this.rgba[CHANNEL_BLUE]  = b;
		this.rgba[CHANNEL_ALPHA] = 1.0;
	}

	// Blend passed-in color with this color using passed-in color's alpha.
	void blendSrc(ColorRGBAf srcColor)
	{
		blend(srcColor, srcColor.rgba[CHANNEL_ALPHA]);
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// AnimatedColor
////////////////////////////////////////////////////////////////////////////////////////////////////

// Animated color interpolation between two colors. 
class AnimatedColor
{
	ColorRGBAf startColor(0,0,0,1);
	ColorRGBAf endColor(1,1,1,1);
	ColorRGBAf curColor();
	ColorRGBA  curColorInt();
	u8  direction    = 0;   // interpolation direction, 0 = torwards endColor
	f64 halfLoopTime = 500; // in milliseconds, to go from start to end color
	f64 startTime    = 0;

	// Construct animated interpolated color timer.
	void constructor()
	{
		// noop
	}

	// Construct animated interpolated color timer.
	void constructor(ColorRGBAf start, ColorRGBAf end, f64 halfLoopTime)
	{
		this.startColor.copy(start);
		this.endColor.copy(end);
		this.halfLoopTime = halfLoopTime;
		this.startTime    = System:getTime();
	}

	// Construct animated interpolated color timer.
	void constructor(ColorRGBA start, ColorRGBA end, f64 halfLoopTime)
	{
		this.startColor.copy(start);
		this.endColor.copy(end);
		this.halfLoopTime = halfLoopTime;
		this.startTime    = System:getTime();
	}

	// Setup animated interpolated color timer.
	void setup(ColorRGBAf start, ColorRGBAf end, f64 halfLoopTime)
	{
		this.startColor.copy(start);
		this.endColor.copy(end);
		this.halfLoopTime = halfLoopTime;
		this.startTime    = System:getTime();
	}

	// Setup animated interpolated color timer.
	void setup(ColorRGBA start, ColorRGBA end, f64 halfLoopTime)
	{
		this.startColor.copy(start);
		this.endColor.copy(end);
		this.halfLoopTime = halfLoopTime;
		this.startTime    = System:getTime();
	}

	// Restart time.
	void restart()
	{
		this.startTime = System:getTime();
	}

	// Get current color.
	ColorRGBAf getColor()
	{
		f64 elapsedTime = System:getTime() - startTime;
		while(elapsedTime > halfLoopTime)
		{
			elapsedTime = 0;
			startTime = System:getTime();

			if(direction == 0)
				direction = 1;
			else
				direction = 0;
		}

		ColorRGBAf start = startColor;
		ColorRGBAf end   = endColor;

		if(direction == 1) // towards startColor (reverse)
		{
			start = endColor;
			end   = startColor;
		}

		f64 ratio = elapsedTime / halfLoopTime;

		for(u32 c=0; c<4; c++)
			curColor[c] = Math:minMax(0.0f, 1.0f, start[c] + ((end[c] - start[c]) * ratio));

		return curColor;
	}

	// Get current color.
	ColorRGBA getColorInt()
	{
		curColorInt.copy(getColor());
		return curColorInt;
	}
}