////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// IImage
////////////////////////////////////////////////////////////////////////////////////////////////////

// Arbitrary-format 1D/2D image. Can represent textures held in private GPU memory.
interface IImage
{
	// Width in pixels.
	u32 getWidth();

	// Height in pixels.
	u32 getHeight();

	// Pixel color format. One of ColorFormat:FORMAT_XXX constants.
	u8 getColorFormat();

	// Get a copy of the underlying pixel data as an array of bytes.
	bool getPixelData(u8[] pixelsDataOut);

	// Set the pixel data. Must be exact size required to match width * height * pixelByteSize. A copy of the pixelsData parameter will be made.
	bool setPixelData(u8[] pixelsData);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// UniversalImage
////////////////////////////////////////////////////////////////////////////////////////////////////

// Implements IImage and allows conversion from one pixel color format to another. Formats supported
// are in ColorFormat.
class UniversalImage implements IImage
{
	u8[]  pixels = null;
	u32   width  = 0;
	u32   height = 0;
	u8    format = ColorFormat:UNKNOWN;

	// Image with no data.
	void constructor() { }

	// Create sized image. Parameter format is one of ColorFormat constants.
	void constructor(u32 width, u32 height, u8 format)
	{
		this.width  = width;
		this.height = height;
		this.format = format;
		this.pixels = u8[](width * height * ColorFormat:getPixelSize(format));
	}

	// Create image while providing backing pixel data. This object now owns pixelData parameter.
	void constructor(u32 width, u32 height, u8 format, u8[] pixelData)
	{
		this.width  = width;
		this.height = height;
		this.format = format;
		this.pixels = pixelData;
	}

	// Copy constructor.
	void constructor(UniversalImage img)
	{
		this.copy(img);
	}

	// Release image data.
	void destroy()
	{
		pixels = null;
	}

	// Clone
	UniversalImage clone()
	{
		if(this.pixels == null || format == ColorFormat:UNKNOWN)
			return null;

		UniversalImage img = UniversalImage(width, height, format);
		img.pixels.copy(this.pixels, 0, 0, this.pixels.length());
		return img;
	}

	// Copy passed-in.
	void copy(UniversalImage img)
	{
		this.width  = img.width;
		this.height = img.height;
		this.format = img.format;
		if(width != 0 && height != 0)
		{
			this.pixels = u8[](width * height * ColorFormat:getPixelSize(format));
			this.pixels.copy(img.pixels, 0, 0, img.pixels.length());
		}
	}

	// Exact match, dimensions and pixel data.
	bool equals(UniversalImage img)
	{
		if(this.width != img.width || this.height != img.height || this.format != img.format)
			return false;

		if(this.pixels == null || img.pixels == null)
			return false;

		if(this.pixels.length() != img.pixels.length())
			return false;

		// compare pixels bytes
		for(u64 b=0; b<this.pixels.length(); b++)
		{
			if(this.pixels[b] != img.pixels[b])
				return false;
		}

		return true;
	}

	// Get image width in pixels.
	u32 getWidth() { return width; }

	// Get image height in pixels.
	u32 getHeight() { return height; }

	// Get pixel format. Always ColorFormat:RGBA8.
	u8 getColorFormat() { return ColorFormat:RGBA8; }

	// Get a copy of the underlying pixel data as an array of bytes.
	bool getPixelData(u8[] pixelsDataOut)
	{
		if(this.pixels == null)
			return false;

		if(pixelsDataOut == null)
			return false;

		if(pixelsDataOut.length() != this.pixels.length())
			return false;

		pixelsDataOut.copy(pixels, 0, 0, pixels.length());

		return true;
	}

	// Set the pixel data. Must be exact size required to match width * height * pixelByteSize. A copy of the pixelsData parameter will be made.
	bool setPixelData(u8[] pixelsData)
	{
		if(this.pixels == null)
			return false;

		if(pixelsData.length() != pixels.length())
			return false;
		
		pixels.copy(pixelsData, 0, 0, pixelsData.length()); // fast like memcopy

		return true;
	}

	// Convert from current pixel format to another.
	UniversalImage convertToFormat(u8 toFormat)
	{
		UniversalImage img = UniversalImage(width, height, toFormat);

		// TODO reinterprting byte array as vectors could really speed this up for some conversions, but will also require writing about 10x code.

		f32 r;
		f32 g;
		f32 b;
		f32 a;

		u16 rU16;
		u16 gU16;
		u16 bU16;
		u16 aU16;

		u32 rU32;
		u32 gU32;
		u32 bU32;
		u32 aU32;

		u16 p16;
		u32 p32;

		for(u32 y=0; y<height; y++)
		{
			for(u32 x=0; x<width; x++)
			{
				// convert current format to f32 per channel
				if(this.format == ColorFormat:RGB5A1)
				{
					p16 = ByteIO:readU16(pixels, ((y * width) + x) * 2);
					r = (p16  & 0b0000000000011111) / 32.0f;
					g = ((p16 & 0b0000001111100000) >> 5)  / 32.0f;
					b = ((p16 & 0b0111110000000000) >> 10) / 32.0f;
					a = ((p16 & 0b1000000000000000) >> 15) / 1.0f;
				}
				else if(this.format == ColorFormat:RGBA4)
				{
					p16 = ByteIO:readU16(pixels, ((y * width) + x) * 2);
					r = (p16  & 0b0000000000001111) / 16.0f;
					g = ((p16 & 0b0000000011110000) >> 4)  / 16.0f;
					b = ((p16 & 0b0000111100000000) >> 8)  / 16.0f;
					a = ((p16 & 0b1111000000000000) >> 12) / 16.0f;
				}
				else if(this.format == ColorFormat:RGBA8)
				{
					p32 = ByteIO:readU32(pixels, ((y * width) + x) * 4);
					r = (p32  & 0b00000000000000000000000011111111) / 256.0f;
					g = ((p32 & 0b00000000000000001111111100000000) >> 8)   / 256.0f;
					b = ((p32 & 0b00000000111111110000000000000000) >> 16)  / 256.0f;
					a = ((p32 & 0b11111111000000000000000000000000) >> 24)  / 256.0f;
				}
				else if(this.format == ColorFormat:R8)
				{
					r = ByteIO:readU8(pixels, (y * width) + x) / 256.0f;
					g = r;
					b = r;
					a = 1.0f;
				}
				else if(this.format == ColorFormat:R_F16)
				{
					r = ByteIO:readF16(pixels, ((y * width) + x) * 2);
					g = r;
					b = r;
					a = 1.0f;
				}
				else if(this.format == ColorFormat:R_F32)
				{
					r = ByteIO:readF32(pixels, ((y * width) + x) * 4);
					g = r;
					b = r;
					a = 1.0f;
				}
				else if(this.format == ColorFormat:RGBA_F16)
				{
					r = ByteIO:readF16(pixels, (((y * width) + x) * 8) + 0);
					g = ByteIO:readF16(pixels, (((y * width) + x) * 8) + 2);
					b = ByteIO:readF16(pixels, (((y * width) + x) * 8) + 4);
					a = ByteIO:readF16(pixels, (((y * width) + x) * 8) + 6);
				}
				else if(this.format == ColorFormat:RGBA_F32)
				{
					r = ByteIO:readF32(pixels, (((y * width) + x) * 16) + 0);
					g = ByteIO:readF32(pixels, (((y * width) + x) * 16) + 4);
					b = ByteIO:readF32(pixels, (((y * width) + x) * 16) + 8);
					a = ByteIO:readF32(pixels, (((y * width) + x) * 16) + 12);
				}

				// convert f32 values to destination format
				if(toFormat == ColorFormat:RGB5A1)
				{
					rU16 = Math:round(r * 32.0f);
					gU16 = Math:round(g * 32.0f);
					gU16 = gU16 << 5;
					bU16 = Math:round(b * 32.0f);
					bU16 = bU16 << 10;
					aU16 = Math:round(a * 32.0f);
					aU16 = aU16 << 15;

					ByteIO:writeU16(img.pixels, ((y * width) + x) * 2, rU16 | gU16 | bU16 | aU16);
				}
				else if(toFormat == ColorFormat:RGBA4)
				{
					rU16 = Math:round(r * 16.0f);
					gU16 = Math:round(g * 16.0f);
					gU16 = gU16 << 4;
					bU16 = Math:round(b * 16.0f);
					bU16 = bU16 << 8;
					aU16 = Math:round(a * 16.0f);
					aU16 = aU16 << 12;

					ByteIO:writeU16(img.pixels, ((y * width) + x) * 2, rU16 | gU16 | bU16 | aU16);
				}
				else if(toFormat == ColorFormat:RGBA8)
				{
					rU32 = Math:round(r * 256.0f);
					gU32 = Math:round(g * 256.0f);
					gU32 = gU32 << 8;
					bU32 = Math:round(b * 256.0f);
					bU32 = bU32 << 16;
					aU32 = Math:round(a * 256.0f);
					aU32 = aU32 << 24;

					ByteIO:writeU32(img.pixels, ((y * width) + x) * 4, rU32 | gU32 | bU32 | aU32);
				}
				else if(toFormat == ColorFormat:R8)
				{
					u8 r8 = Math:round(r * 256.0f);
					ByteIO:writeU8(img.pixels, (y * width) + x, r8);
				}
				else if(toFormat == ColorFormat:R_F16)
				{
					ByteIO:writeF16(img.pixels, (((y * width) + x) * 2), r);
				}
				else if(toFormat == ColorFormat:R_F32)
				{
					ByteIO:writeF32(img.pixels, (((y * width) + x) * 4), r);
				}
				else if(toFormat == ColorFormat:RGBA_F16)
				{
					ByteIO:writeF16(img.pixels, (((y * width) + x) * 8) + 0, r);
					ByteIO:writeF16(img.pixels, (((y * width) + x) * 8) + 2, g);
					ByteIO:writeF16(img.pixels, (((y * width) + x) * 8) + 4, b);
					ByteIO:writeF16(img.pixels, (((y * width) + x) * 8) + 6, a);
				}
				else if(toFormat == ColorFormat:RGBA_F32)
				{
					ByteIO:writeF32(img.pixels, (((y * width) + x) * 16) + 0,  r);
					ByteIO:writeF32(img.pixels, (((y * width) + x) * 16) + 4,  g);
					ByteIO:writeF32(img.pixels, (((y * width) + x) * 16) + 8,  b);
					ByteIO:writeF32(img.pixels, (((y * width) + x) * 16) + 12, a);
				}
			}
		}

		return img;
	}
}