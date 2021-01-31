////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// ImageRGBA
////////////////////////////////////////////////////////////////////////////////////////////////////

// 8 bits per channel (Red, Green, Blue, and Alpha channels) general image representation. ImageRGBA
// operations are software-based and can be safely used on headless (GPU-deficient) servers etc.
class ImageRGBA implements IImage, IRenderTarget2D, IRenderTexture
{
	const u8 IMG_QUALITY_BEST = 1;
	const u8 IMG_QUALITY_FAST = 2;

	u32[] pixels = null; // RGBA components of pixels
	u32   width  = 0;
	u32   height = 0;

	// Image with no data.
	void constructor() { }

	// Create sized image, pixels could be anything.
	void constructor(u32 width, u32 height)
	{
		this.width  = width;
		this.height = height;
		this.pixels = u32[](width * height);
	}

	// Create solid colored image.
	void constructor(u32 width, u32 height, ColorRGBA fillColor)
	{
		this.width  = width;
		this.height = height;
		this.pixels = u32[](width * height);

		clear(fillColor);
	}

	// From any color format type of data. This object now owns pixelData.
	void constructor(u32 width, u32 height, u8 colorFormat, u8[] pixelData)
	{
		if(colorFormat != ColorFormat:RGBA8)
		{
			UniversalImage uniImg = UniversalImage(width, height, colorFormat, pixelData);
			constructor(uniImg); // eats uniImg etc.
		}
		else
		{
			this.width  = width;
			this.height = height;
			this.pixels = pixelData.reinterpret(Type:U32, 0);
		}
	}

	// Consumes uniImg converting into ImageRGBA. uniImg parameter object deleted.
	void constructor(UniversalImage uniImg)
	{
		consume(uniImg);
	}

	// Consumes NativeImage object.
	void constructor(NativeImage nativeImg)
	{
		if(nativeImg == null)
			return;

		// TODO support formats other than RGBA8 if needed.
		if(nativeImg.format != ColorFormat:RGBA8)
			return;

		this.width  = nativeImg.width;
		this.height = nativeImg.height;
		this.pixels = nativeImg.pixels.reinterpret(Type:U32, 0);

		nativeImg.pixels = null; // stolen by us
	}

	// Copy input image.
	void constructor(ImageRGBA i)
	{
		this.copy(i);
	}

	// Release image data.
	void destroy()
	{
		pixels = null;
	}

	// Copy input image. Resizes this image to match.
	void copy(ImageRGBA i)
	{
		if(i == null)
			return;

		if(i.width == this.width && i.height == this.height)
		{
			/* This is slower on windows platform by about 2x. Other platforms varies.
			u64 numPixels = this.width * this.height;
			if((numPixels % 4) == 0)
			{
				// faster with vectors, tested as ~x faster.

				u32[4][] tempPixelsA = pixels.reinterpret(Type:U32, 4);
				u32[4][] tempPixelsB = i.pixels.reinterpret(Type:U32, 4);

				u64 numCopies = numPixels / 4;
				for(u32 c=0; c<numCopies; c++)
					tempPixelsA[c] = tempPixelsB[c];

				pixels   = tempPixelsA.reinterpret(Type:U32, 0);
				i.pixels = tempPixelsB.reinterpret(Type:U32, 0);
			}
			else
			{*/

			// fast like a C memcpy() optimized per platform etc.
			this.pixels.copy(i.pixels, 0, 0, i.pixels.length());
		}
		else
		{
			// not same size
			this.width  = i.width;
			this.height = i.height;
			this.pixels = u32[](width * height);

			// fast like a memcpy()
			this.pixels.copy(i.pixels, 0, 0, i.pixels.length());
		}
	}

	// Consumes data from uniImg. uniImg data released/stolen.
	void consume(UniversalImage uniImg)
	{
		if(uniImg == null)
			return;

		if(uniImg.getColorFormat() != ColorFormat:RGBA8)
		{
			// convert
			UniversalImage uniImgRGBA8 = uniImg.convertToFormat(ColorFormat:RGBA8);
			u8[] pixelBytes = uniImgRGBA8.pixels;
			uniImgRGBA8.pixels = null; // stolen
			this.pixels = pixelBytes.reinterpret(Type:U32, 0); // permenant conversion
			pixelBytes = null;
		}
		else
		{
			u8[] pixelBytes = uniImg.pixels; // steal
			uniImg.pixels   = null;
			this.pixels     = pixelBytes.reinterpret(Type:U32, 0); // permenant conversion to u32[]
		}

		this.width  = uniImg.width;
		this.height = uniImg.height;

		uniImg.pixels = null;
	}

	// Returns perfect clone of this.
	ImageRGBA clone()
	{
		ImageRGBA img = ImageRGBA(this.width, this.height);

		// fast like a memcpy()
		img.pixels.copy(this.pixels, 0, 0, this.pixels.length());

		return img;
	}

	// Create/wrap an image to be high-performance compatible with this render target. This may simply return the passed-in ImageRGBA object or something else.
	IRenderTexture createTexture(ImageRGBA img)
	{
		return img;
	}

	// Delete/release texture resource.
	void deleteTexture(IRenderTexture texture)
	{
		// do nothing
	}

	// Get texture data as RGBA-32 bit image. Converted from natural color format automatically.
	ImageRGBA getImage()
	{
		return ImageRGBA(this);
	}

	// Get texture data as RGBA-32 bit image. Converted from natural color format automatically. imgOut can be null, but if matches size/format can improve performance.
	ImageRGBA getImage(ImageRGBA imgOut)
	{
		if(imgOut == null)
			return ImageRGBA(this);

		imgOut.copy(this);
		return imgOut;
	}

	// Set texture data from ImageRGBA.
	bool setImage(ImageRGBA imgIn)
	{
		this.copy(imgIn);
		return true;
	}

	// Returns clone of this as a UniversalImage.
	UniversalImage createUniversalImage()
	{
		UniversalImage img = UniversalImage(this.width, this.height, ColorFormat:RGBA8);

		u8[] pixelsBytes = this.pixels.reinterpret(Type:U8, 0); // temporarily interpret array of u32[] as u8[]
		img.setPixelData(pixelsBytes);
		this.pixels = pixelsBytes.reinterpret(Type:U32, 0); // revert

		return img;
	}

	// Recreate the image with new dimensions. 
	void create(u32 width, u32 height)
	{
		if(this.pixels != null)
		{
			if(this.width == width && this.height == height && this.pixels.length() == (4 * width * height))
				return; // already right-size.
		}

		this.width = width;
		this.height = height;
		this.pixels = u32[](width * height);
	}

	// Exact match, dimensions and pixel data.
	bool equals(ImageRGBA img)
	{
		if(this.width != img.width || this.height != img.height)
			return false;

		// compare pixels
		for(u32 y=0; y<this.height; y++)
		{
			for(u32 x=0; x<this.width; x++)
			{
				if(this.pixels[(y * this.width) + x] != img.pixels[(y * this.width) + x])
					return false;
			}
		}

		return true;
	}

	// Get image width in pixels.
	u32 getWidth() { return width; }

	// Get image height in pixels.
	u32 getHeight() { return height; }

	// Width/height.
	f32 getAspectRatio() { return f32(width) / f32(height); }

	// Get pixel format. Always ColorFormat:RGBA8.
	u8 getColorFormat() { return ColorFormat:RGBA8; }

	// Get a copy of the underlying pixel data as an array of bytes. pixelsDataOut must be at least width * height * ColorFormat:getPixelSize(format) bytes.
	bool getPixelData(u8[] pixelsDataOut)
	{
		if(pixelsDataOut.length() < width * height * 4)
			return false;

		u8[] pixelsBytes = pixels.reinterpret(Type:U8, 0); // temporarily interpret array of u32[] as u8[]
		pixelsDataOut.copy(pixelsBytes, 0, 0, pixelsBytes.length()); // fast like memcopy
		this.pixels = pixelsBytes.reinterpret(Type:U32, 0); // revert

		return true;
	}

	// Set the pixel data. Must be exact size required to match width * height * pixelByteSize. A copy of the pixelsData parameter will be made.
	bool setPixelData(u8[] pixelsData)
	{
		if(pixelsData.length() != (width * height * 4))
			return false;
		
		u8[] pixelsBytes = pixels.reinterpret(Type:U8, 0); // temporarily interpret array of u32[] as u8[]
		pixelsBytes.copy(pixelsData, 0, 0, pixelsData.length()); // fast like memcopy
		this.pixels = pixelsBytes.reinterpret(Type:U32, 0); // revert

		return true;
	}

	// Get the contents of the render target as a 32-bit RGBA image. This method can be slow depending on the underlying implementation. (for IRenderTarget2D)
	ImageRGBA getImageRGBA()
	{
		return ImageRGBA(this);
	}

	// Get the contents of the render target as a 32-bit RGBA image using an existing image object. This method can be slow depending on the underlying implementation. (for IRenderTarget2D)
	ImageRGBA getImageRGBA(ImageRGBA img)
	{
		if(img == null)
			return getImageRGBA();

		img.copy(this);
		return img;
	}

	// Set the entire contents of the render target using a 32-bit RGBA image. Returns false if failed to render / unsupported by render target. This method can be slow depending on the underlying implementation. (for IRenderTarget2D)
	bool setImageRGBA(ImageRGBA img)
	{
		this.copy(img);
		return true;
	}

	// Flush any pending rendering operations.
	void flush()
	{
		// Noop.
	}

	// Call to indicate the start of rendering a new frame.
	void beginFrame()
	{
		// Noop.
	}

	// Call to indicate the end of rendering of a frame. Will swap backbuffer to frontbuffer etc. as needed.
	void endFrame()
	{
		// Noop.
	}

	// Set the entire render target area to a single color / depth / stencil value.
	void clear(f32 r, f32 g, f32 b, f32 a, f32 depth, u8 stencil)
	{
		ColorRGBAf clr(r, g, b, a);
		clear(ColorRGBA(clr));
	}

	// Invert individual color channel. One of ColorRGBA:CHANNEL_XXX.
	void invertChannel(u32 channel)
	{
		u8[] pixelsBytes = pixels.reinterpret(Type:U8, 0); // temporarily interpret array of u32[] as u8[]
		for(u32 y=0; y<this.height; y++)
		{
			for(u32 x=0; x<this.width; x++)
			{
				u8 clrComponent = pixelsBytes[(((y * this.width) + x) * 4) + channel];
				pixelsBytes[(((y * this.width) + x) * 4) + channel] = 255 - clrComponent;
			}
		}
		this.pixels = pixelsBytes.reinterpret(Type:U32, 0); // revert
	}

	// Invert RGB and optionally alpha.
	void invert(bool invertAlpha)
	{
		invertChannel(ColorRGBA:CHANNEL_RED);
		invertChannel(ColorRGBA:CHANNEL_GREEN);
		invertChannel(ColorRGBA:CHANNEL_BLUE);
		if(invertAlpha == true)
			invertChannel(ColorRGBA:CHANNEL_ALPHA);
	}

	// Mirror the image along the horizontal axis.
	void flipVertical()
	{
		u32 tempColor;
		for(u32 y=0; y<(this.height / 2) ; y++)
		{
			for(u32 x=0; x<this.width; x++)
			{
				tempColor = this.pixels[(y * this.width) + x];
				this.pixels[(y * this.width) + x] = this.pixels[(((this.height - 1) - y) * this.width) + x];
				this.pixels[(((this.height - 1) - y) * this.width) + x] = tempColor;
			}
		}
	}

	// Mirror the image along the vertical axis.
	void flipHorizontal()
	{
		u32 tempColor;
		for(u32 y=0; y<this.height; y++)
		{
			for(u32 x=0; x<(this.width / 2) ; x++)
			{
				tempColor = this.pixels[(y * this.width) + x];
				this.pixels[(y * this.width) + x] = this.pixels[(y * this.width) + ((this.width - 1) - x)];
				this.pixels[(y * this.width) + ((this.width - 1) - x)] = tempColor;
			}
		}
	}

	// Clear the entire image to a solid color.
	void clear(ColorRGBA color)
	{
		fillRect(0, 0, width, height, color);

		/*
		u64 numPixels = this.width * this.height;

		u32 clrU32 = color.getU32();
		if((numPixels % 4) == 0)
		{
			// faster with vectors, tested as ~2.9x faster.
			u32[4] clrVec = u32(clrU32, clrU32, clrU32, clrU32);

			u32[4][] tempPixels = pixels.reinterpret(Type:U32, 4);

			u64 numCopies = numPixels / 4;
			for(u32 c=0; c<numCopies; c++)
				tempPixels[c] = clrVec;

			pixels = tempPixels.reinterpret(Type:U32, 0);
		}
		else
		{
			for(u32 y=0; y<this.height; y++)
			{
				for(u32 x=0; x<this.width; x++)
				{
					this.pixels[(y * this.width) + x] = clrU32;
				}
			}
		}*/
	}

	// Clear a single color channel to a single value.
	void clearChannel(u8 channel, u8 clr)
	{
		u8[] pixelsBytes = pixels.reinterpret(Type:U8, 0); // temporarily interpret array of u32[] as u8[]
		for(u32 y=0; y<this.height; y++)
		{
			for(u32 x=0; x<this.width; x++)
			{
				pixelsBytes[(((y * this.width) + x) * 4) + channel] = clr;
			}
		}
		this.pixels = pixelsBytes.reinterpret(Type:U32, 0); // revert
	}

	// Returns true if pixel exactly matches color (including alpha).
	bool comparePixel(u32 x, u32 y, ColorRGBA color)
	{
		if(x >= this.width || y >= this.height)
			return false;
		
		if(this.pixels[(y * this.width) + x] == color.getU32())
			return true;

		return false;
	}

	// Set single pixel's color.
	void setPixel(u32 x, u32 y, u32 colorInt)
	{
		this.pixels[(y * this.width) + x] = colorInt;
	}

	// Set single pixel's color.
	void setPixel(u32 x, u32 y, ColorRGBA color)
	{
		this.pixels[(y * this.width) + x] = color.getU32();
	}

	// Get single pixel's color as unsigned integer RGBA.
	u32 getPixel(u32 x, u32 y)
	{
		return pixels[((y * this.width) + x)];
	}

	// Get single pixel's color.
	void getPixel(u32 x, u32 y, ColorRGBA colorOut)
	{
		colorOut.set(pixels[((y * this.width) + x)]);
	}

	// Get single pixel's color with clamp (false) or wrap mode (true) for pixels out of x/y bounds.
	void getPixel(i32 x, i32 y, bool useWrapMode, ColorRGBA colorOut)
	{
		// wrap
		u32 wx = Math:wrap(0, width-1, x);
		u32 wy = Math:wrap(0, height-1, y);

		if(useWrapMode == false) // clamp
		{
			wx = Math:minMax(0, width-1, x);
			wy = Math:minMax(0, height-1, y);
		}

		getPixel(wx, wy, colorOut);
	}

	// Test a pixel's color matches passed-in value.
	bool testPixel(u32 x, u32 y, u8 r, u8 g, u8 b, u8 a)
	{
		if(x >= this.width || y >= this.height)
			return false;

		if(ColorRGBA:packRGBA(r, g, b, a) == pixels[((y * this.width) + x)])
			return true;

		return false;
	}

	// Test a pixel's color matches passed-in value.
	bool testPixel(u32 x, u32 y, ColorRGBA clr)
	{
		if(x >= this.width || y >= this.height)
			return false;

		if(clr.getU32() == pixels[((y * this.width) + x)])
			return true;

		return false;
	}

	// Draw line, clipped.
	void drawLine(Line2D<i32> line, u32 thickness, ColorRGBA color)
	{
		drawLine(line[0], line[1], line[2], line[3], thickness, color);
	}

	// Draw a line. Clipped.
	void drawLine(i32 x0, i32 y0, i32 x1, u32 y1, u32 thickness, ColorRGBA color)
	{
		// Bresenham's line algorithm
		if(thickness <= 1)
		{	
			u32 clrU32 = color.getU32();

			bool steep = false;
			if(Math:abs(y1 - y0) > Math:abs(x1 - x0))
				steep = true;

			if(steep)
			{
				i32 temp = x0;
				x0 = y0;
				y0 = temp;

				temp = x1;
				x1 = y1;
				y1 = temp;
			}

			if(x0 > x1)
			{
				i32 temp = x0;
				x0 = x1;
				x1 = temp;

				temp = y0;
				y0 = y1;
				y1 = temp;
			}

			f32 dx = x1 - x0;
			f32 dy = Math:abs(y1 - y0);

			f32 error = dx / 2.0f;

			i32 yStep = -1;
			if(y0 < y1)
				yStep = 1;

			i32 y = y0;
			i32 maxX = x1;

			for(i32 x=x0; x<maxX; x++)
			{
				if(steep)
				{
					i32 px = y; // x/y swap intentional
					i32 py = x;
					if(px >= 0 && px < this.width && py >= 0 && py < this.height)
						this.pixels[(py * this.width) + px] = clrU32;
				}
				else
				{
				    i32 px = x;
					i32 py = y;
					if(px >= 0 && px < this.width && py >= 0 && py < this.height)
						this.pixels[(py * this.width) + px] = clrU32;
				}

				error -= dy;
				if(error < 0)
				{
				    y += yStep;
				    error += dx;
				}
			}
		}
		else
		{
			Vec2<f32> v0(x0, y0);
			Vec2<f32> v1(x1, y1);

			if(x0 > x1) // swap to keep order consistent for clockwise purposes
			{
				v0.p = f32(x1, y1);
				v1.p = f32(x0, y0);
			}

			Vec2<f32> dir = v1 - v0; // we know dir.x is positive (or zero) which is useful for generating clockwise triangles
			dir.normalize();

			Vec2<f32> perpDir(dir);
			perpDir.perpendicular(); // now we know dir.y is positive (or zero) which is useful for generating clockwise triangles

			// left points
			Vec2<f32> p0 = v0 + (perpDir * (thickness * -0.5f)); // low-y (top screen)
			Vec2<f32> p1 = v0 + (perpDir * (thickness * 0.5f));  // high-y

			// right points
			Vec2<f32> p2 = v1 + (perpDir * (thickness * -0.5f)); // low-y (top screen)
			Vec2<f32> p3 = v1 + (perpDir * (thickness * 0.5f));  // high-y

			/* This is more accurrate but much slower:
			Polygon2D<i32> poly();

			poly.pts.add(Vec2<i32>(p0[0], p0[1]));
			poly.pts.add(Vec2<i32>(p1[0], p1[1]));
			poly.pts.add(Vec2<i32>(p3[0], p3[1])); // order important, p3 before p2
			poly.pts.add(Vec2<i32>(p2[0], p2[1]));

			fillPolygon(poly, color);*/

			Polygon2D<i32> triA();
			triA.pts.add(i32(p0[0], p0[1]));
			triA.pts.add(i32(p1[0], p1[1]));
			triA.pts.add(i32(p3[0], p3[1])); // order important, p3 before p2
			fillTriangle(triA, color);

			Polygon2D<i32> triB();
			triB.pts.add(i32(p3[0], p3[1])); // order important, p3 before p2
			triB.pts.add(i32(p2[0], p2[1]));
			triB.pts.add(i32(p0[0], p0[1]));
			fillTriangle(triB, color);
		}
	}

	// Draw (outline) a rectangle. Outline is internal to rectangle shape. Clipped.
	void drawRect(Rectangle2D<i32> rect, u32 thickness, ColorRGBA color)
	{
		drawRect(rect[0], rect[1], rect.getWidth(), rect.getHeight(), thickness, color);
	}

	// Draw (outline) a rectangle. Outline is internal to rectangle shape. Clipped.
	void drawRect(i32 x, i32 y, u32 rectWidth, u32 rectHeight, u32 thickness, ColorRGBA color)
	{
		fillRect(x, y, rectWidth, thickness, color); // horizontal top
		fillRect(x, y + rectHeight - thickness, rectWidth, thickness, color); // horizontal bottom
		fillRect(x, y, thickness, rectHeight, color); // vertical left
		fillRect(x + rectWidth - thickness, y, thickness, rectHeight, color); // vertical right
	}

	// Fill a rectangular area of the image with a solid color. Clipped.
	void fillRect(Rectangle2D<i32> rect, ColorRGBA color)
	{
		fillRect(rect[0], rect[1], rect.getWidth(), rect.getHeight(), color);
	}

	// Fill a rectangular area of the image with a solid color. Clipped.
	void fillRect(i32 x, i32 y, u32 rectWidth, u32 rectHeight, ColorRGBA color)
	{
		if(x >= width || y >= height)
			return; // nothing visible

		i32[6] clip = clipToRect(x, y, rectWidth, rectHeight);

		if(clip[4] <= 0 || clip[5] <= 0)
			return; // fully clipped

		// fill the first row of rect pixel-by-pixel, then copy that row to all others for perf
		u32 srcStart = 0;

		u32 clrU32 = color.getU32();
		for(u32 py=clip[3]; py<(clip[3] + 1); py++) // just do one row
		{
			srcStart = (py * this.width) + clip[2];

			for(u32 px=clip[2]; px<(clip[2] + clip[4]); px++)
			{
				this.pixels[(py * this.width) + px] = clrU32;
			}
		}

		for(py=clip[3]; py<(clip[3] + clip[5]); py++)
		{
			this.pixels.copy(this.pixels, srcStart, (py * this.width) + clip[2], clip[4]);
		}
	}

	// Fill a triangle
	void fillTriangle(Polygon2D<i32> poly, ColorRGBA color)
	{
		if(poly.pts.size() != 3)
			return;

		Rectangle2D<i32> polyBounds = poly.getBounds();

		i32[] minXs = i32[](polyBounds.getHeight() + 1);
		i32[] maxXs = i32[](polyBounds.getHeight() + 1);
		for(u32 y=0; y<polyBounds.getHeight(); y++)
		{
			minXs[y] = this.width-1;
			maxXs[y] = 0;
		}

		// draw all three lines, determing min/max Xs
		traceLineXBounds(poly.pts[0][0], poly.pts[0][1], poly.pts[1][0], poly.pts[1][1], polyBounds.getMinY(), minXs, maxXs);
		traceLineXBounds(poly.pts[1][0], poly.pts[1][1], poly.pts[2][0], poly.pts[2][1], polyBounds.getMinY(), minXs, maxXs);
		traceLineXBounds(poly.pts[2][0], poly.pts[2][1], poly.pts[0][0], poly.pts[0][1], polyBounds.getMinY(), minXs, maxXs);

		// scan line fill
		u32 clrU32 = color.getU32();
		for(y=0; y<polyBounds.getHeight(); y++)
		{
			for(i32 x=minXs[y]; x<=maxXs[y]; x++)
			{
				i32 px = x;
				i32 py = polyBounds.getMinY() + y;

				this.pixels[(py * this.width) + px] = clrU32;
			}
		}
	}

	// Trace line, recording min/max X. Used by fillTriangle().
	void traceLineXBounds(i32 x0, i32 y0, i32 x1, i32 y1, i32 minY, i32[] minXs, i32[] maxXs)
	{
		bool steep = false;
		if(Math:abs(y1 - y0) > Math:abs(x1 - x0))
			steep = true;

		if(steep)
		{
			i32 temp = x0;
			x0 = y0;
			y0 = temp;

			temp = x1;
			x1 = y1;
			y1 = temp;
		}

		if(x0 > x1)
		{
			i32 temp = x0;
			x0 = x1;
			x1 = temp;

			temp = y0;
			y0 = y1;
			y1 = temp;
		}

		f32 dx = x1 - x0;
		f32 dy = Math:abs(y1 - y0);

		f32 error = dx / 2.0f;

		i32 yStep = -1;
		if(y0 < y1)
			yStep = 1;

		i32 y = y0;
		i32 maxX = x1;

		for(i32 x=x0; x<maxX; x++)
		{
			if(steep)
			{
				i32 px = y; // x/y swap intentional
				i32 py = x;
				if(px >= 0 && px < this.width && py >= 0 && py < this.height)
				{
					i32 i = py - minY;
					if(i >= 0 && i < minXs.length())
					{
						if(px < minXs[i])
							minXs[i] = px;

						if(px > maxXs[i])
							maxXs[i] = px;
					}
				}
			}
			else
			{
			    i32 px = x;
				i32 py = y;
				if(px >= 0 && px < this.width && py >= 0 && py < this.height)
				{
					i32 i = py - minY;
					if(i >= 0 && i < minXs.length())
					{
						if(px < minXs[i])
							minXs[i] = px;

						if(px > maxXs[i])
							maxXs[i] = px;
					}
				}
			}

			error -= dy;
			if(error < 0)
			{
			    y += yStep;
			    error += dx;
			}
		}
	}

	// Draw (outline) a polygon. Clipped.
	void drawPolygon(Polygon2D<i32> poly, u32 thickness, ColorRGBA color)
	{
		if(poly.pts.size() < 3)
			return; // not even a triangle

		// draw lines
		for(u64 p=1; p<poly.pts.size(); p++)
		{
			i32 x0 = poly.pts[p-1][0];
			i32 y0 = poly.pts[p-1][1];
			i32 x1 = poly.pts[p][0];
			i32 y1 = poly.pts[p][1];

			drawLine(x0, y0, x1, y1, thickness, color);
		}

		u64 lpi = poly.pts.size()-1;

		// did they included an explicit close point (same as start)?
		if(poly.pts[0][0] != poly.pts[lpi][0] || poly.pts[0][1] != poly.pts[lpi][1])
		{
			// nope
			drawLine(poly.pts[0][0], poly.pts[0][1], poly.pts[lpi][0], poly.pts[lpi][1], thickness, color);
		}
	}

	// Fill an arbitrary polygon. Polygon can be convex or concave, but with no holes or overlapping edges. Clipped.
	void fillPolygon(Polygon2D<i32> poly, ColorRGBA color)
	{
		u32 clrU32 = color.getU32();

		Rectangle2D<i32> polyBounds = poly.getBounds();

		// constrain rasterization area to image area (clipping)
		if(polyBounds.getMinX() < 0)
			polyBounds.setMinX(0);
		if(polyBounds.getMaxX() >= this.width)
			polyBounds.setMaxX(this.width-1);
		if(polyBounds.getMinY() < 0)
			polyBounds.setMinY(0);
		if(polyBounds.getMaxY() >= this.height)
			polyBounds.setMaxY(this.height-1);

		// TODO faster scanline rendering

		i32 minY = polyBounds.getMinY();
		i32 maxY = polyBounds.getMaxY();

		i32 minX = polyBounds.getMinX();
		i32 maxX = polyBounds.getMaxX();

		// check each pixel in the bounding area of the polygon
		i32[2] pt;
		for(i32 py=minY; py<=maxY; py++)
		{
			for(i32 px=minX; px<=maxX; px++)
			{
				pt[0] = px;
				pt[1] = py;
				if(poly.contains(pt) == false)
					continue; // not inside polygon

				this.pixels[(py * this.width) + px] = clrU32;
			}
		}
	}

	// Clips rectangle to this image area. Returns srcX/srcY/desX/desY/desWidth/desHeight
	i32[6] clipToRect(i32 x, i32 y, i32 w, i32 h)
	{
		// partial clipping checks
		i32 desX = x;
		i32 srcX = 0;
		i32 desWidth = w;
		if(desX < 0)
		{
			srcX = -1 * desX;
			desWidth -= srcX;
			desX = 0;
		}

		if((desX + desWidth) >= this.width)
		{
			desWidth -= (desX + desWidth) - this.width;
		}

		i32 desY = y;
		i32 srcY = 0;
		i32 desHeight = h;
		if(desY < 0)
		{
			srcY = -1 * desY;
			desHeight -= srcY;
			desY = 0;
		}

		if((desY + desHeight) >= this.height)
		{
			desHeight -= (desY + desHeight) - this.height;
		}

		i32[6] clip = i32(srcX, srcY, desX, desY, desWidth, desHeight);

		assert((clip[2]) >= 0);
		assert((clip[3]) >= 0);
		assert((clip[2] + clip[4]) <= this.width);
		assert((clip[3] + clip[5]) <= this.height);

		return clip;
	}

	// Copy the passed-in image onto this image. Clipped.
	void drawImage(IRenderTexture imgRGBA, i32 x, i32 y)
	{
		ImageRGBA img = imgRGBA;
		if(img == null)
			return;

		// full clipping checks
		if(x >= width || y >= height)
			return; // nothing visible

		if((x + img.width) <= 0 || (y + img.height) <= 0)
			return; // nothing visible

		i32[6] clip = clipToRect(x, y, img.width, img.height);

		if(clip[4] <= 0 || clip[5] <= 0)
			return; // fully clipped

		for(i32 py=0; py<clip[5]; py++)
		{
			for(i32 px=0; px<clip[4]; px++)
			{
				i32 sx = clip[0] + px;
				i32 sy = clip[1] + py;

				i32 dx = clip[2] + px;
				i32 dy = clip[3] + py;

				this.pixels[(dy * this.width) + dx] = img.pixels[(sy * img.width) + sx];
			}
		}
	}

	// Draw a portion of the passed-in image onto this image. Clipped.
	void drawImage(ImageRGBA img, i32 desX, i32 desY, i32 srcX, i32 srcY, u32 srcWidth, u32 srcHeight)
	{
		// TODO optimize clipping
		for(u32 y=0; y<srcHeight; y++)
		{
			for(u32 x=0; x<srcWidth; x++)
			{
				u32 dx = desX + x;
				u32 dy = desY + y;

				if(dx < 0 || dx >= this.width || dy < 0 || dy >= this.height)
					continue;

				u32 sx = srcX + x;
				u32 sy = srcY + y;

				if(sx < 0 || sx >= img.width || sy < 0 || sy >= img.height)
					continue;

				u32 srcClr = img.pixels[(sy * img.width) + sx];
				this.pixels[(dy * this.width) + dx] = srcClr;
			}
		}
	}

	// Draw image blended using passed-in images alpha.
	void drawImageBlended(IRenderTexture imgRGBA, i32 x, i32 y)
	{
		ImageRGBA img = imgRGBA;
		if(img == null)
			return;

		drawImageBlended(img, x, y, 0, 0, img.width, img.height);
	}

	// Draw portion of passed-in image blended using passed-in images alpha.
	void drawImageBlended(ImageRGBA img, i32 desX, i32 desY, i32 srcX, i32 srcY, u32 srcWidth, u32 srcHeight)
	{
		ColorRGBAf srcClr = ColorRGBAf();
		ColorRGBAf desClr = ColorRGBAf();
		u8[] srcBytes = img.pixels.reinterpret(Type:U8, 0); // temporarily interpret array of u32[] as u8[]
		u8[] desBytes = pixels.reinterpret(Type:U8, 0); // temporarily interpret array of u32[] as u8[]

		for(u32 y=0; y<srcHeight; y++)
		{
			for(u32 x=0; x<srcWidth; x++)
			{
				u32 dx = desX + x;
				u32 dy = desY + y;

				if(dx < 0 || dx >= this.width || dy < 0 || dy >= this.height)
					continue;

				u32 sx = srcX + x;
				u32 sy = srcY + y;

				if(sx < 0 || sx >= img.width || sy < 0 || sy >= img.height)
					continue;

				f32 srcR = srcBytes[(((sy * img.width) + sx) * 4) + 0] / 255.0f;
				f32 srcG = srcBytes[(((sy * img.width) + sx) * 4) + 1] / 255.0f;
				f32 srcB = srcBytes[(((sy * img.width) + sx) * 4) + 2] / 255.0f;
				f32 srcA = srcBytes[(((sy * img.width) + sx) * 4) + 3] / 255.0f;

				f32 desR = desBytes[(((dy * this.width) + dx) * 4) + 0] / 255.0f;
				f32 desG = desBytes[(((dy * this.width) + dx) * 4) + 1] / 255.0f;
				f32 desB = desBytes[(((dy * this.width) + dx) * 4) + 2] / 255.0f;

				srcClr.set(srcR, srcG, srcB, srcA);
				desClr.set(desR, desG, desB, 1.0f);
				desClr.blendSrc(srcClr);

				u8 iDesR = Math:minMax(0, 255, desClr.rgba[0] * 255);
				u8 iDesG = Math:minMax(0, 255, desClr.rgba[1] * 255);
				u8 iDesB = Math:minMax(0, 255, desClr.rgba[2] * 255);

				desBytes[(((dy * this.width) + dx) * 4) + 0] = iDesR;
				desBytes[(((dy * this.width) + dx) * 4) + 1] = iDesG;
				desBytes[(((dy * this.width) + dx) * 4) + 2] = iDesB;
			}
		}

		img.pixels  = srcBytes.reinterpret(Type:U32, 0); // revert
		this.pixels = desBytes.reinterpret(Type:U32, 0); // revert
	}

	// Draw portion of passed-in image blended using passed-in alpha constant for all pixels.
	void drawImageBlended(ImageRGBA img, i32 desX, i32 desY, i32 srcX, i32 srcY, u32 srcWidth, u32 srcHeight, f32 srcAlphaConstant)
	{
		ColorRGBAf srcClr = ColorRGBAf();
		ColorRGBAf desClr = ColorRGBAf();
		u8[] srcBytes = img.pixels.reinterpret(Type:U8, 0); // temporarily interpret array of u32[] as u8[]
		u8[] desBytes = pixels.reinterpret(Type:U8, 0); // temporarily interpret array of u32[] as u8[]

		for(u32 y=0; y<srcHeight; y++)
		{
			for(u32 x=0; x<srcWidth; x++)
			{
				u32 dx = desX + x;
				u32 dy = desY + y;

				if(dx < 0 || dx >= this.width || dy < 0 || dy >= this.height)
					continue;

				u32 sx = srcX + x;
				u32 sy = srcY + y;

				if(sx < 0 || sx >= img.width || sy < 0 || sy >= img.height)
					continue;

				f32 srcR = srcBytes[(((sy * img.width) + sx) * 4) + 0] / 255.0f;
				f32 srcG = srcBytes[(((sy * img.width) + sx) * 4) + 1] / 255.0f;
				f32 srcB = srcBytes[(((sy * img.width) + sx) * 4) + 2] / 255.0f;

				f32 desR = desBytes[(((dy * this.width) + dx) * 4) + 0] / 255.0f;
				f32 desG = desBytes[(((dy * this.width) + dx) * 4) + 1] / 255.0f;
				f32 desB = desBytes[(((dy * this.width) + dx) * 4) + 2] / 255.0f;

				srcClr.set(srcR, srcG, srcB, srcAlphaConstant);
				desClr.set(desR, desG, desB, 1.0f);
				desClr.blendSrc(srcClr);

				u8 iDesR = Math:minMax(0, 255, desClr.rgba[0] * 255);
				u8 iDesG = Math:minMax(0, 255, desClr.rgba[1] * 255);
				u8 iDesB = Math:minMax(0, 255, desClr.rgba[2] * 255);

				desBytes[(((dy * this.width) + dx) * 4) + 0] = iDesR;
				desBytes[(((dy * this.width) + dx) * 4) + 1] = iDesG;
				desBytes[(((dy * this.width) + dx) * 4) + 2] = iDesB;
			}
		}

		img.pixels  = srcBytes.reinterpret(Type:U32, 0); // revert
		this.pixels = desBytes.reinterpret(Type:U32, 0); // revert
	}

	// Draw portion of passed-in image using the alpha to determine the intensity of the final color solid color.
	void drawImageAlphaColored(ImageRGBA img, i32 desX, i32 desY, i32 srcX, i32 srcY, u32 srcWidth, u32 srcHeight, ColorRGBA clr)
	{
		ColorRGBAf srcClr = ColorRGBAf();
		ColorRGBAf desClr = ColorRGBAf();
		u8[] srcBytes = img.pixels.reinterpret(Type:U8, 0); // temporarily interpret array of u32[] as u8[]
		u8[] desBytes = pixels.reinterpret(Type:U8, 0); // temporarily interpret array of u32[] as u8[]

		srcClr.copy(clr);
		for(u32 y=0; y<srcHeight; y++)
		{
			for(u32 x=0; x<srcWidth; x++)
			{
				u32 dx = desX + x;
				u32 dy = desY + y;

				if(dx < 0 || dx >= this.width || dy < 0 || dy >= this.height)
					continue;

				u32 sx = srcX + x;
				u32 sy = srcY + y;

				if(sx < 0 || sx >= img.width || sy < 0 || sy >= img.height)
					continue;

				f32 srcA = srcBytes[(((sy * img.width) + sx) * 4) + 3] / 255.0f;

				f32 desR = desBytes[(((dy * this.width) + dx) * 4) + 0] / 255.0f;
				f32 desG = desBytes[(((dy * this.width) + dx) * 4) + 1] / 255.0f;
				f32 desB = desBytes[(((dy * this.width) + dx) * 4) + 2] / 255.0f;

				desClr.set(desR, desG, desB, 1.0f);
				desClr.blend(srcClr, srcA);

				u8 iDesR = Math:minMax(0, 255, desClr.rgba[0] * 255);
				u8 iDesG = Math:minMax(0, 255, desClr.rgba[1] * 255);
				u8 iDesB = Math:minMax(0, 255, desClr.rgba[2] * 255);

				desBytes[(((dy * this.width) + dx) * 4) + 0] = iDesR;
				desBytes[(((dy * this.width) + dx) * 4) + 1] = iDesG;
				desBytes[(((dy * this.width) + dx) * 4) + 2] = iDesB;
			}
		}

		img.pixels  = srcBytes.reinterpret(Type:U32, 0); // revert
		this.pixels = desBytes.reinterpret(Type:U32, 0); // revert
	}

	// Sample a set of pixels equally. Area will be clipped.
	void sampleAvg(ColorRGBA sampleOut, i32 x, i32 y, u32 areaWidth, u32 areaHeight)
	{
		u8[] pixelsBytes = pixels.reinterpret(Type:U8, 0); // temporarily interpret array of u32[] as u8[]
		u32 numSamples = 0;
		u32 r = 0;
		u32 g = 0;
		u32 b = 0;
		u32 a = 0;
		for(i32 py=y; py<(y+areaHeight); py++)
		{
			for(i32 px=x; px<(x+areaWidth); px++)
			{
				if(px < 0 || px >= width || py < 0 || py >= height)
					continue; // out of bounds

				numSamples++;

				r += pixelsBytes[(((py * this.width) + px) * 4) + 0];
				g += pixelsBytes[(((py * this.width) + px) * 4) + 1];
				b += pixelsBytes[(((py * this.width) + px) * 4) + 2];
				a += pixelsBytes[(((py * this.width) + px) * 4) + 3];
			}
		}
		this.pixels = pixelsBytes.reinterpret(Type:U32, 0); // revert

		if(numSamples == 0)
			sampleOut.set(0, 0, 0, 0);
		else
			sampleOut.set(r / numSamples, g / numSamples, b / numSamples, a / numSamples); // rounding would be more accurate
	}

	// Sample a set of pixels by weighted average. Weights array length must equal areaWidth * areaHeight. Sample area will be wrapped.
	void sampleAvgWeighted(ColorRGBA sampleOut, i32 x, i32 y, u32 areaWidth, u32 areaHeight, f32[16] weightsArray)
	{
		u8[] pixelsBytes = pixels.reinterpret(Type:U8, 0); // temporarily interpret array of u32[] as u8[]
		f32 r = 0.0f;
		f32 g = 0.0f;
		f32 b = 0.0f;
		f32 a = 0.0f;
		for(i32 py=y; py<(y+areaHeight); py++)
		{
			for(i32 px=x; px<(x+areaWidth); px++)
			{
				i32 wx = px - x;
				i32 wy = py - y;
				f32 weightFactor = weightsArray[(wy * areaWidth) + wx];

				u32 wrapX = Math:wrap(0, this.width-1, px);
				u32 wrapY = Math:wrap(0, this.height-1, py);

				r += (pixelsBytes[(((wrapY * this.width) + wrapX) * 4) + 0] / 255.0f) * weightFactor;
				g += (pixelsBytes[(((wrapY * this.width) + wrapX) * 4) + 1] / 255.0f) * weightFactor;
				b += (pixelsBytes[(((wrapY * this.width) + wrapX) * 4) + 2] / 255.0f) * weightFactor;
				a += (pixelsBytes[(((wrapY * this.width) + wrapX) * 4) + 3] / 255.0f) * weightFactor;
			}
		}
		this.pixels = pixelsBytes.reinterpret(Type:U32, 0); // revert

		u32 rInt = r * 255;
		sampleOut.rgba[0] = Math:minMax(0, 255, rInt);

		u32 gInt = g * 255;
		sampleOut.rgba[1] = Math:minMax(0, 255, gInt);

		u32 bInt = b * 255;
		sampleOut.rgba[2] = Math:minMax(0, 255, bInt);

		u32 aInt = a * 255;
		sampleOut.rgba[3] = Math:minMax(0, 255, aInt);
	}

	// Resize while preserving aspect ratio. High-quality sampling.
	ImageRGBA resize(u32 newWidth)
	{
		f32 newWidthF   = newWidth;
		f32 aspectRatio = height / newWidthF;
		u32 newHeight   = Math:roundToInt(newWidth * aspectRatio);

		return resize(newWidth, newHeight, IMG_QUALITY_BEST);
	}

	// Resize while preserving aspect ratio using high-quality or low-quality sampling. imgQuality should be one of IMG_QUALITY_FAST or IMG_QUALITY_BEST.
	ImageRGBA resize(u32 newWidth, u8 imgQuality)
	{
		f32 newWidthF   = newWidth;
		f32 aspectRatio = height / newWidthF;
		u32 newHeight   = Math:roundToInt(newWidth * aspectRatio);

		return resize(newWidth, newHeight, imgQuality);
	}

	// Resize this image using high-quality sampling.
	ImageRGBA resize(u32 newWidth, u32 newHeight)
	{
		return resize(newWidth, newHeight, IMG_QUALITY_BEST);
	}

	// Resize this image using high-quality or low-quality sampling. imgQuality should be one of IMG_QUALITY_FAST or IMG_QUALITY_BEST.
	ImageRGBA resize(u32 newWidth, u32 newHeight, u8 imgQuality)
	{
		if(imgQuality == IMG_QUALITY_FAST)
			return resizeFast(newWidth, newHeight);
		
		return resizeHQ(newWidth, newHeight);
	}

	// Resize this image using high-quality resizing.
	ImageRGBA resizeHQ(u32 newWidth, u32 newHeight)
	{
		if(newWidth == this.width && newHeight == this.height)
			return clone();

		ImageRGBA img = ImageRGBA(newWidth, newHeight);

		f32 fWidth      = width;
		f32 fHeight     = height;
		f32 fNewWidth   = newWidth;
		f32 fNewHeight  = newHeight;
		f32 widthScale  = newWidth  / fWidth;
		f32 heightScale = newHeight / fHeight;

		// 9 scenarios for weighting the sampling within a pixel
		// Imagine a single pixel broken into 9 equal sub regions:
		//
		// | NW | N | NE |
		// | W  | C | E  |     - NESW labeling
		// | SW | S | SE |
		//
		// Depending on where our rotated pixel lands in the final
		// pixel we use one of 9 sampling weights sets.

		f32 min8 = 0.02500000f; // 0.2 / 8
		f32 min7 = 0.02857142f; // 0.2 / 7
		f32 min5 = 0.04000000f; // 0.2 / 5

		f32 maxW = 0.8f; // center
		f32 haf1 = 0.3f; // half maxW (for direct adjacent cases)
		f32 haf2 = 0.5f; // half maxW (for direct adjacent cases)
		f32 qur1 = 0.1f; // quarter maxW (for diagonal cases)
		f32 qur2 = 0.5f; // quarter maxW (for diagonal cases)

		f32[16] cWeights = f32(min8, min8, min8, min8, maxW, min8, min8, min8, min8, 0, 0, 0, 0, 0, 0, 0);

		// direct sides
		f32[16] nWeights = f32(min7, haf1, min7, min7, haf2, min7, min7, min7, min7, 0, 0, 0, 0, 0, 0, 0);
		f32[16] sWeights = f32(min7, min7, min7, min7, haf2, min7, min7, haf1, min7, 0, 0, 0, 0, 0, 0, 0);
		f32[16] eWeights = f32(min7, min7, min7, min7, haf2, haf1, min7, min7, min7, 0, 0, 0, 0, 0, 0, 0);
		f32[16] wWeights = f32(min7, min7, min7, haf1, haf2, min7, min7, min7, min7, 0, 0, 0, 0, 0, 0, 0);

		// diagonals
		f32[16] neWeights = f32(min5, qur1, qur1, min5, qur2, qur1, min5, min5, min5, 0, 0, 0, 0, 0, 0, 0);
		f32[16] seWeights = f32(min5, min5, min5, min5, qur2, qur1, min5, qur1, qur1, 0, 0, 0, 0, 0, 0, 0);
		f32[16] swWeights = f32(min5, min5, min5, qur1, qur2, min5, qur1, qur1, min5, 0, 0, 0, 0, 0, 0, 0);
		f32[16] nwWeights = f32(qur2, qur1, min5, qur1, qur1, min5, min5, min5, min5, 0, 0, 0, 0, 0, 0, 0);

		// Array of vectors, indexable as "2D" array
		f32[16][] weightsArray = f32[16][](9);
		weightsArray[0] = nwWeights;
		weightsArray[1] = nWeights;
		weightsArray[2] = neWeights;
		weightsArray[3] = wWeights;
		weightsArray[4] = cWeights;
		weightsArray[5] = eWeights;
		weightsArray[6] = swWeights;
		weightsArray[7] = sWeights;
		weightsArray[8] = seWeights;

		ColorRGBA tmpClr = ColorRGBA();

		// special case for performance/quality (i.e. mip maps)
		if(newWidth == (this.width/2) && newHeight == (this.height/2))
		{
			for(i32 py=0; py<newHeight; py++)
			{
				for(i32 px=0; px<newWidth; px++)
				{
					sampleAvg(tmpClr, px * 2, py * 2, 2, 2);
					img.pixels[(py * newWidth) + px] = tmpClr.getU32();
				}
			}
		}
		else if(newWidth == (this.width/3) && newHeight == (this.height/3))
		{
			for(i32 py=0; py<newHeight; py++)
			{
				for(i32 px=0; px<newWidth; px++)
				{
					sampleAvg(tmpClr, (px * 3), (py * 3), 3, 3);
					img.pixels[(py * newWidth) + px] = tmpClr.getU32();
				}
			}
		}
		else if(newWidth == (this.width/4) && newHeight == (this.height/4))
		{
			for(i32 py=0; py<newHeight; py++)
			{
				for(i32 px=0; px<newWidth; px++)
				{
					sampleAvg(tmpClr, (px * 4), (py * 4), 4, 4);
					img.pixels[(py * newWidth) + px] = tmpClr.getU32();
				}
			}
		}
		else if(widthScale > 0.5f && widthScale < 1.0f) // less than 2x pixels to sample, hardest case to make look great
		{
			for(i32 py=0; py<newHeight; py++)
			{
				for(i32 px=0; px<newWidth; px++)
				{
					// 3x3 array where we sample 1 to 9 pixels (i.e. 1x1, 2x2, or 3x3)
					f32 centerSrcX = ((px + 0.5f) / fNewWidth)  * fWidth;
					f32 centerSrcY = ((py + 0.5f) / fNewHeight) * fHeight;

					// floor to inside to pixel
					i32 sampleX = Math:floor(centerSrcX);
					i32 sampleY = Math:floor(centerSrcY);

					// fractional pixel space (0.00001 to 0.99999 range)
					f32 fracX = centerSrcX - sampleX;
					f32 fracY = centerSrcY - sampleY;

					// determine which of 9 spaces inside pixel this point is within
					i32 wxIndex = Math:floor(fracX * 3.0f); // 0, 1, or 2
					i32 wyIndex = Math:floor(fracY * 3.0f); // 0, 1, or 2

					assert(wxIndex >= 0 && wxIndex <= 2);
					assert(wyIndex >= 0 && wyIndex <= 2);

					// get the right weights
					f32[16] weightsVec = weightsArray[(wyIndex * 3) + wxIndex];

					// magic
					sampleAvgWeighted(tmpClr, sampleX-1, sampleY-1, 3, 3, weightsVec);
					img.pixels[(py * newWidth) + px] = tmpClr.getU32();
				}
			}
		}
		else // original HQ algorithm
		{
			// By calculating the ideal sample size we are effectively dynamically switching between
			// nearest point, bilinear, cubic etc. sampling modes.
			i32 sampleWidth      = Math:max(1, Math:roundToInt(1.0f / widthScale));
			i32 sampleHeight     = Math:max(1, Math:roundToInt(1.0f / heightScale));
			i32 sampleHalfWidth  = Math:max(0, (sampleWidth / 2));
			i32 sampleHalfHeight = Math:max(0, (sampleHeight / 2));

			for(i32 py=0; py<newHeight; py++)
			{
				for(i32 px=0; px<newWidth; px++)
				{
					i32 srcX = Math:minMax(0, this.width-1, Math:roundToInt(px / fNewWidth) * this.width);
					i32 srcY = Math:minMax(0, this.height-1, Math:roundToInt(py / fNewHeight) * this.height);

					sampleAvg(tmpClr, srcX - sampleHalfWidth, srcY - sampleHalfHeight, sampleWidth, sampleHeight);

					img.pixels[(py * newWidth) + px] = tmpClr.getU32();
				}
			}
		}

		return img;
	}

	// Resize this image using low-quality fast resizing (nearest point sampling).
	ImageRGBA resizeFast(u32 newWidth, u32 newHeight)
	{
		// Nearest point
		i32 sampleWidth      = 1;
		i32 sampleHeight     = 1;
		i32 sampleHalfWidth  = 0;
		i32 sampleHalfHeight = 0;

		ImageRGBA img = ImageRGBA(newWidth, newHeight);

		f32 newWidthF  = newWidth;
		f32 newHeightF = newHeight;
		i32 maxX       = width - 1;
		i32 maxY       = height - 1;
		for(i32 y=0; y<newHeight; y++)
		{
			for(i32 x=0; x<newWidth; x++)
			{
				i32 srcX = Math:minMax(0, maxX, Math:roundToInt((x / newWidthF) * width));
				i32 srcY = Math:minMax(0, maxY, Math:roundToInt((y / newHeightF) * height));

				img.pixels[(y * newWidth) + x] = this.pixels[(srcY * width) + srcX];
			}
		}

		return img;
	}

	// Fill image with checker board pattern.
	void fillCheckerBoard(u32 sqSize, ColorRGBA color0, ColorRGBA color1)
	{
		ColorRGBA  curColor       = color0;
		ColorRGBA  startLineColor = color0;
		
		for(u32 py=0; py<this.height; py += sqSize)
		{
			startLineColor = curColor;
			for(u32 px=0; px<this.width; px += sqSize)
			{
				this.fillRect(px, py, sqSize, sqSize, curColor);
				
				if(curColor == color0)
					curColor = color1;
				else
					curColor = color0;
			}
			
			if(curColor == startLineColor)
			{
				if(curColor == color0)
					curColor = color1;
				else
					curColor = color0;
			}
		}
	}

	// Draw text onto this render target using default font.
	void drawText(i32 x, i32 y, String<u8> text, ColorRGBA clr)
	{
		Font defFont = Font:getFont("", 16);
		drawText(defFont, x, y, 10000, 10000, text, clr);
	}

	// Render text using a font. Clipped to image.
	void drawText(Font font, i32 x, i32 y, String<u8> text, ColorRGBA clr)
	{
		drawText(font, x, y, this.width - x, this.height - y, text, clr);
	}

	// Render text using a font, clipped to x/y/width/height rect.
	void drawText(Font font, i32 x, i32 y, i32 width, i32 height, String<u8> text, ColorRGBA clr)
	{
		i32[2] curXY = i32(x, y);
		i32 maxX = x + width;
		i32 maxY = y + height;

		for(u32 c=0; c<text.length(); c++)
		{
			u32 charID = text.chars[c];
			curXY = drawChar(font, curXY[0], curXY[1], maxX, maxY, charID, clr);
		}
	}

	// Render text using a font. Clipped to image.
	void drawText(Font font, i32 x, i32 y, String<u32> text, ColorRGBA clr)
	{
		drawText(font, x, y, this.width - x, this.height - y, text, clr);
	}

	// Draw text onto this render target utilizing UTF32 characters. Be sure to pass in a font with UTF32 characters mapped.
	void drawText(Font font, i32 x, i32 y, i32 width, i32 height, String<u32> text, ColorRGBA clr)
	{
		i32[2] curXY = i32(x, y);
		i32 maxX = x + width;
		i32 maxY = y + height;

		for(u32 c=0; c<text.length(); c++)
		{
			u32 charID = text.chars[c];
			curXY = drawChar(font, curXY[0], curXY[1], maxX, maxY, charID, clr);
		}
	}

	// Draw character onto this render target utilizing UTF32 characters. Returns next x/y coordinate.
	i32[2] drawChar(Font font, i32 x, i32 y, i32 maxX, i32 maxY, u32 charID, ColorRGBA clr)
	{
		if(font == null || clr == null)
			return i32(x, y);
		
		i32 curX = x;
		i32 curY = y;

		if(maxX > this.width)
			maxX = this.width;

		if(maxY > this.height)
			maxY = this.height;

		if(charID == Chars:NEW_LINE)
		{
			curX = x;
			curY += font.glyphMap.lineHeight;
			return i32(curX, curY);
		}

		FontGlyphChar chDesc = font.getCharDesc(charID);
		if(chDesc == null)
			return i32(curX, curY);

		u32 srcX = chDesc.x;
		u32 srcY = chDesc.y;

		for(u32 py=0; py<chDesc.height; py++)
		{
			for(u32 px=0; px<chDesc.width; px++)
			{
				srcX = chDesc.x + px;
				srcY = chDesc.y + py;

				i32 desX = curX + px;
				i32 desY = curY + py;

				// clipping
				if(desX < 0 || desX >= maxX || desY < 0 || desY >= maxY)
					continue;

				u32 srcIntensity = font.fontImg.pixels[(srcY * font.fontImg.width) + srcX];
				srcIntensity = (srcIntensity & 0x0000FF00) >> 8;

				if(srcIntensity <= 1)
					continue;

				u32 curColor = this.pixels[(desY * this.width) + desX];

				f32 intensityF = srcIntensity / 255.0f;
				f32 invIntensityF = 1.0f - intensityF;

				u32 desR = (clr.rgba[0] * intensityF) + (((curColor & 0x000000FF) ) * invIntensityF);
				u32 desG = (clr.rgba[1] * intensityF) + (((curColor & 0x0000FF00) >> 8) * invIntensityF);
				u32 desB = (clr.rgba[2] * intensityF) + (((curColor & 0x00FF0000) >> 16) * invIntensityF);
				u32 desA = 255;

				u32 clrInt = 0;

				clrInt |= (desA << 24);
				clrInt |= (desB << 16);
				clrInt |= (desG <<  8);
				clrInt |= desR;

				this.pixels[(desY * this.width) + desX] = clrInt;
			}
		}
		curX += chDesc.xAdvance;

		return i32(curX, curY);
	}

	// Create a series of 1/4 resolution versions of this image. Does not include this image object in chain.
	ArrayList<ImageRGBA> createMipMaps(u32 fullResolutionWidth, u32 fullResolutionHeight, u32 numImages)
	{
		ArrayList<ImageRGBA> imgs = ArrayList<ImageRGBA>(numImages);

		// does the original image need to be resized?
		ImageRGBA startImg = null;
		if(width != fullResolutionWidth || height != fullResolutionHeight)
		{
			startImg = resizeHQ(fullResolutionWidth, fullResolutionHeight);
		}
		else
		{
			startImg = clone();
		}
		
		// first image in mip map chain
		imgs.add(startImg);

		// mip maps exactly half
		ImageRGBA lastImg = startImg;
		for(u32 m=0; m<(numImages-1); m++)
		{
			u32 curWidth  = lastImg.width / 2;
			u32 curHeight = lastImg.height / 2;
			if(curWidth < 1 || curHeight < 1)
				break;

			ImageRGBA newImg = lastImg.resizeHQ(curWidth, curHeight);
			imgs.add(newImg);

			lastImg = newImg;
		}

		return imgs;
	}

	// Decode PNG file data held in memory to an ImageRGBA object.
	shared ImageRGBA decodePNG(ByteArray data)
	{
		NativeImage nativeImg = NativeImage:decodePNG(data.data, 0, data.size());
		return convertFromNativeImage(nativeImg);
	}

	// Encode this image to a PNG file in memory.
	ByteArray encodePNG()
	{
		// temporary native image
		NativeImage nativeImg = NativeImage();
		nativeImg.width  = this.width;
		nativeImg.height = this.height;
		nativeImg.pixels = this.pixels.reinterpret(Type:U8, 0);  // temporary borrow of data
		nativeImg.format = ColorFormat:RGBA8;

		u8[] pngFileBytes = nativeImg.encodePNG();
		this.pixels = nativeImg.pixels.reinterpret(Type:U32, 0); // revert
		nativeImg.pixels = null;

		return ByteArray(pngFileBytes, pngFileBytes.length());
	}

	// Decode JPEG file data held in memory to an ImageRGBA object.
	shared ImageRGBA decodeJPEG(ByteArray data)
	{
		NativeImage nativeImg = NativeImage:decodeJPEG(data.data, 0, data.size());
		return convertFromNativeImage(nativeImg);
	}

	// Encode this image to a JPEG file in memory. jpegQuality is 1 to 100 where 100 is best image quality, but largest file size.
	ByteArray encodeJPEG(u8 jpegQuality)
	{
		// temporary native image
		NativeImage nativeImg = NativeImage();
		nativeImg.width  = this.width;
		nativeImg.height = this.height;
		nativeImg.pixels = this.pixels.reinterpret(Type:U8, 0); // temporary borrow of data
		nativeImg.format = ColorFormat:RGBA8;

		u8[] jpegFileBytes = nativeImg.encodeJPEG(jpegQuality);
		this.pixels = nativeImg.pixels.reinterpret(Type:U32, 0); // revert
		nativeImg.pixels = null;

		return ByteArray(jpegFileBytes, jpegFileBytes.length());
	}

	// Convert NativeImage to ImageRGBA.
	shared ImageRGBA convertFromNativeImage(NativeImage nativeImg)
	{
		if(nativeImg == null)
			return null;

		// TODO support formats other than RGBA8 if needed.
		if(nativeImg.format != ColorFormat:RGBA8)
			return null;

		ImageRGBA img = ImageRGBA();
		img.width  = nativeImg.width;
		img.height = nativeImg.height;
		img.pixels = nativeImg.pixels.reinterpret(Type:U32, 0);

		nativeImg.pixels = null; // stolen by us

		return img;
	}
}