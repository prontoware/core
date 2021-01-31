////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Texture2D
////////////////////////////////////////////////////////////////////////////////////////////////////

// A 2D array of pixels held in GPU-accessible memory. 

// Textures can be any dimensions, *however* non power of two textures dimensions have certain
// restrictions including:
// 1. UV Mode must be UV_MOVE_CLAMP (will be enforced).
// 2. Texture filtering must be nearest or linear. No mip-maps.
// Newer GPUs have full NPOT support, but many entry-level OpenGL 2.0 ES GPUs have this more limited
// form of NPOT support.
//
// Read/write operations to textures can be slow depending on the platform and GPU type. If writing
// to a texture frequently be sure to construct with frequentUpdates=true. Also consider using a 
// texture pool (2 or more) and alternating between them. This helps performance by avoiding pipeline
// stalls.
class Texture2D implements ITexture, IImage, IRenderTexture
{
	u64 texHandle  = 0;
	u32 width      = 0;
	u32 height     = 0;
	u8  format     = 0;
	u8  numLevels  = 0;
	u8  uvMode     = Texture:UV_CLAMP;
	u8  filterMode = Texture:FILTER_LINEAR;

	// Allocate memory with texture data set to arbitrary values.
	void constructor(u32 width, u32 height, u8 format, u8 numMipMapLevels)
	{
		if(Math:isPowerOfTwo(width) == true && Math:isPowerOfTwo(height) == true)
			this.numLevels = numMipMapLevels;
		else
			this.numLevels = 1;

		this.texHandle = createTexture2D_native(width, height, format, this.numLevels, false);
		this.width     = width;
		this.height    = height;
		this.format    = format;
	}

	// Allocate memory with texture data set to arbitrary values.
	void constructor(u32 width, u32 height, u8 format, u8 numMipMapLevels, bool frequentUpdates)
	{
		if(Math:isPowerOfTwo(width) == true && Math:isPowerOfTwo(height) == true)
			this.numLevels = numMipMapLevels;
		else
			this.numLevels = 1;

		this.texHandle = createTexture2D_native(width, height, format, this.numLevels, frequentUpdates);
		this.width     = width;
		this.height    = height;
		this.format    = format;
	}

	// Allocate using image for width/height/format and texture data.
	void constructor(ImageRGBA img)
	{
		this.texHandle = createTexture2D_native(img.width, img.height, ColorFormat:RGBA8, 1, false);
		this.width     = img.width;
		this.height    = img.height;
		this.format    = ColorFormat:RGBA8;
		this.numLevels = 1;

		u8[] tempPixels = img.pixels.reinterpret(Type:U8, 0);
		writeTexture2D_native(texHandle, tempPixels, 0);
		img.pixels = tempPixels.reinterpret(Type:U32, 0); // revert

		setFilterMode(this.filterMode);
	}

	// Do not construct via this manually. For use by GPU and render targets.
	void constructor(u64 texHandle, u32 width, u32 height, u8 format)
	{
		this.texHandle = texHandle;
		this.width     = width;
		this.height    = height;
		this.format    = format;
		this.numLevels = 1;
	}

	// Deallocate.
	void destroy()
	{
		if(this.texHandle != 0)
		{
			deleteTexture2D_native(this.texHandle);
			this.texHandle = 0;
		}
	}

	// Was memory allocated successfully?
	bool isValid() { if(this.texHandle == 0) { return false; } return true;}

	// Get width of texture in pixels.
	u32 getWidth() { return width; }

	// Get height of texture in pixels.
	u32 getHeight() { return height; }

	// Get color format of pixels. One of ColorFormat:XXX.
	u8 getColorFormat() { return format; }

	// Get a copy of the underlying pixel data as an array of bytes.
	bool getPixelData(u8[] pixelsDataOut)
	{
		if(pixelsDataOut == null)
			return false;

		if(pixelsDataOut.length() != (width * height * ColorFormat:getPixelSize(format)))
			return false;

		if(readTexture2D_native(texHandle, pixelsDataOut, 0) == false)
			return false;

		return true;
	}

	// Set the pixel data. Must be exact size required to match width * height * pixelByteSize. A copy of the pixelsData parameter may be made.
	bool setPixelData(u8[] pixelsData)
	{
		if(pixelsData == null)
			return false;

		if(pixelsData.length() != (width * height * ColorFormat:getPixelSize(format)))
			return false;

		return writeTexture2D_native(texHandle, pixelsData, 0);
	}

	// Get number of mip map levels. Zero/one indicates no mip map levels.
	u8 getNumMipMapLevels() { return numLevels; }

	// Get uv mode. One of Texture:UV_MODE_REPEAT or Texture:UV_MODE_CLAMP.
	u8 getUVMode() { return this.uvMode; }

	// Set uv mode. One of Texture:UV_MODE_REPEAT or Texture:UV_MODE_CLAMP. Non-power-of-two dimension textures only support UV_MODE_CLAMP.
	void setUVMode(u8 uvMode)
	{
		if(Math:isPowerOfTwo(width) == false || Math:isPowerOfTwo(height) == false)
			return;
			
		this.uvMode = uvMode;
		setTextureUVMode_native(texHandle, this.uvMode);
	}

	// Get texture filtering mode. One of Texture:FILTER_NEAREST etc.
	u8 getFilterMode()
	{
		return this.filterMode;
	}

	// Set texture filtering mode. One of Texture:FILTER_NEAREST etc. Non-power-of-two dimension textures only support nearest/linear.
	void setFilterMode(u8 filterMode)
	{
		if(Math:isPowerOfTwo(width) == false || Math:isPowerOfTwo(height) == false || numLevels <= 1)
		{
			// only nearest/linear supported
			if(filterMode == Texture:FILTER_NEAREST || filterMode == Texture:FILTER_LINEAR)
				this.filterMode = filterMode;
		}
		else
		{
			this.filterMode = filterMode;
		}

		setTextureFilterMode_native(texHandle, this.filterMode);
	}

	// Get texture data as RGBA-32 bit image. Converted from natural color format automatically.
	ImageRGBA getImage()
	{
		return getImage(null);
	}

	// Get texture data as RGBA-32 bit image. Converted from natural color format automatically. imgOut can be null, but if matches size/format can improve performance.
	ImageRGBA getImage(ImageRGBA imgOut)
	{
		UniversalImage uniImg = readImage(0);
		if(uniImg == null)
			return null;

		if(imgOut != null)
		{
			imgOut.consume(uniImg);
			return imgOut;
		}

		return ImageRGBA(uniImg);
	}

	// Set texture data from ImageRGBA. May require slow conversion if underlying format is not RGBA 32 bit.
	bool setImage(ImageRGBA imgIn)
	{
		return writeImage(imgIn, 0);
	}

	// Get textures image data. May be slow. May return null if unsupported by this GPU/platform.
	UniversalImage readImage(u8 mipMapLevel)
	{
		UniversalImage uniImg = UniversalImage(width, height, format);

		if(readTexture2D_native(texHandle, uniImg.pixels, mipMapLevel) == false)
			return null;

		return uniImg;
	}

	// Get textures image data. Faster than readImage() that returns image because you provide pre-allocated image memory. uniImg must be matching format and width/height to this texture + level.
	bool readImage(u8 mipMapLevel, UniversalImage uniImg)
	{
		if(uniImg == null)
			return false;

		if(uniImg.getWidth() != this.width || uniImg.getHeight() != this.height || uniImg.getColorFormat() != this.format)
			return false;

		if(readTexture2D_native(texHandle, uniImg.pixels, mipMapLevel) == false)
			return false;

		return true;
	}

	// Set textures image data. Returns false if uniImg doesn't match exact dimensions/color format of texture.
	bool writeImage(UniversalImage uniImg, u8 mipMapLevel)
	{
		return writeTexture2D_native(texHandle, uniImg.pixels, mipMapLevel);
	}

	// Set textures image data at specified level. Size/color-format conversion will be done automatically if needed but can be very slow.
	bool writeImage(ImageRGBA img, u8 mipMapLevel)
	{
		if(img == null)
			return false;

		u32 lvlWidth  = this.width;
		u32 lvlHeight = this.height;
		if(mipMapLevel != 0)
		{
			// calculate needed width/height
			for(u32 lvl=0; lvl<mipMapLevel; lvl++)
			{
				lvlWidth  /= 2;
				lvlHeight /= 2;
			}
		}

		bool retVal = false;
		if(img.getWidth() == lvlWidth && img.getHeight() == lvlHeight && this.format == ColorFormat:RGBA8) // exact match, nice
		{
			u8[] tempPixels = img.pixels.reinterpret(Type:U8, 0); // temporary borrow of data
			retVal = writeTexture2D_native(texHandle, tempPixels, mipMapLevel);
			img.pixels = tempPixels.reinterpret(Type:U32, 0); // revert
		}
		else
		{
			// some resize/conversion needed
			ImageRGBA useImg = img;
			if(img.getWidth() != lvlWidth || img.getHeight() != lvlHeight)
			{
				useImg = ImageRGBA(img);
				useImg.resize(lvlWidth, lvlHeight);
			}

			if(this.format == ColorFormat:RGBA8)
			{
				u8[] tempPixels = useImg.pixels.reinterpret(Type:U8, 0); // temporary borrow of data
				retVal = writeTexture2D_native(texHandle, tempPixels, mipMapLevel);
				useImg.pixels = tempPixels.reinterpret(Type:U32, 0); // revert
			}
			else
			{
				// need format conversion
				UniversalImage uniImg = useImg.createUniversalImage();
				uniImg.convertToFormat(this.format);
				retVal = writeImage(uniImg, mipMapLevel);
			}
		}

		return retVal;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// TextureCube
////////////////////////////////////////////////////////////////////////////////////////////////////

// A cube map texture. Has six faces (effectively six 2D textures). Cube texture dimensions must be
// equal (width == height). Read/write operations to textures can be slow depending on the platform
// and GPU type. 
class TextureCube implements ITexture
{
	u64 texHandle  = 0;
	u32 width      = 0;
	u32 height     = 0;
	u8  format     = 0;
	u8  numLevels  = 0;
	u8  filterMode = Texture:FILTER_NEAREST;

	// Allocate texture. widthHeight must be power-of-two if using mip maps.
	void constructor(u32 widthHeight, u8 format, u8 numMipMapLevels)
	{
		if(Math:isPowerOfTwo(width) == true && Math:isPowerOfTwo(height) == true)
			this.numLevels = numMipMapLevels;
		else
			this.numLevels = 0;

		this.texHandle = createTextureCube_native(width, height, format, this.numLevels, false);
		this.width     = widthHeight;
		this.height    = widthHeight;
		this.format    = format;
		this.numLevels = numMipMapLevels;
	}

	// Allocate texture. widthHeight must be power-of-two if using mip maps.
	void constructor(u32 widthHeight, u8 format, u8 numMipMapLevels, bool frequentUpdates)
	{
		if(Math:isPowerOfTwo(width) == true && Math:isPowerOfTwo(height) == true)
			this.numLevels = numMipMapLevels;
		else
			this.numLevels = 0;

		this.texHandle = createTextureCube_native(width, height, format, this.numLevels, frequentUpdates);
		this.width     = widthHeight;
		this.height    = widthHeight;
		this.format    = format;
		this.numLevels = numMipMapLevels;
	}

	// Do not construct via this manually. For use by GPU and render targets.
	void constructor(u64 texHandle, u32 widthHeight, u8 format)
	{
		this.texHandle = texHandle;
		this.width     = widthHeight;
		this.height    = widthHeight;
		this.format    = format;
		this.numLevels = 0;
	}

	// Deallocate.
	void destroy()
	{
		if(this.texHandle != 0)
		{
			deleteTexture2D_native(this.texHandle);
			this.texHandle = 0;
		}
	}

	// Was memory allocated successfully?
	bool isValid() { if(this.texHandle == 0) { return false; } return true;}

	// Get width of texture in pixels.
	u32 getWidth() { return width; }

	// Get height of texture in pixels.
	u32 getHeight() { return height; }

	// Get format of texture. One of ColorFormat:XXX.
	u8 getColorFormat() { return format; }

	// Get number of mip map levels. Zero/one indicates no mip map levels.
	u8 getNumMipMapLevels() { return numLevels; }

	// Get uv mode. Always CLAMP for cube map.
	u8 getUVMode() { return Texture:UV_CLAMP; }

	// Set uv mode. Unused by cube map.
	void setUVMode(u8 uvMode) { }

	// Get texture filtering mode. One of Texture:FILTER_NEAREST etc.
	u8 getFilterMode() { return this.filterMode; }

	// Set texture filtering mode. One of Texture:FILTER_NEAREST etc. Must be FILTER_NEAREST or FILTER_LINEAR or non-power-of-two dimension textures.
	void setFilterMode(u8 filterMode)
	{
		if(Math:isPowerOfTwo(width) == false || Math:isPowerOfTwo(height) == false || numLevels <= 1)
		{
			// only nearest/linear supported
			if(filterMode == Texture:FILTER_NEAREST || filterMode == Texture:FILTER_LINEAR)
				this.filterMode = filterMode;
		}
		else
		{
			this.filterMode = filterMode;
		}

		this.filterMode = filterMode;
		setTextureFilterMode_native(texHandle, filterMode);
	}

	// Get textures image data. May be slow. May return null if unsupported by this GPU/platform.
	UniversalImage readImage(u8 mipMapLevel, u8 faceIndex)
	{
		UniversalImage uniImg = UniversalImage(width, height, format);

		if(readTextureCube_native(texHandle, uniImg.pixels, mipMapLevel, faceIndex) == false)
			return null;

		return uniImg;
	}

	// Set textures image data. May return null if unsupported by this GPU/platform.
	bool writeImage(UniversalImage uniImg, u8 mipMapLevel, u8 faceIndex)
	{
		return writeTextureCube_native(texHandle, uniImg.pixels, mipMapLevel, faceIndex);
	}
}