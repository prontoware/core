////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// IRenderTexture
////////////////////////////////////////////////////////////////////////////////////////////////////

// A directly-renderable image/texture. Created directly using the render target that will utilize
// it. Can represent textures held in private GPU memory etc.
interface IRenderTexture
{
	// Width in pixels.
	u32 getWidth();

	// Height in pixels.
	u32 getHeight();

	// Pixel color format. One of ColorFormat:FORMAT_XXX constants.
	u8 getColorFormat();

	// Get a copy of the underlying pixel data as an array of bytes. pixelsDataOut must be exact size required to match width * height * pixelByteSize.
	bool getPixelData(u8[] pixelsDataOut);

	// Set the pixel data. pixelsData be exact size required to match width * height * pixelByteSize.
	bool setPixelData(u8[] pixelsData);

	// Get texture data as RGBA-32 bit image. Converted from natural color format automatically.
	ImageRGBA getImage();

	// Get texture data as RGBA-32 bit image. Converted from natural color format automatically. imgOut can be null, but if matches size/format can improve performance.
	ImageRGBA getImage(ImageRGBA imgOut);

	// Set texture data from ImageRGBA. May require slow conversion if underlying format is not RGBA 32 bit.
	bool setImage(ImageRGBA imgIn);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// IRenderTarget2D
////////////////////////////////////////////////////////////////////////////////////////////////////

// Something that can be drawn on. 2D drawable area. See ImageRGBA.
interface IRenderTarget2D
{
	// Get the width of the rendering area.
	u32 getWidth();

	// Get the height of the rendering area.
	u32 getHeight();

	// Width / Height.
	f32 getAspectRatio();

	// Get the underlying rendering format. One of Color:FORMAT_XXX.
	u8 getColorFormat();

	// Get a copy of the underlying pixel data as an array of bytes. pixelsDataOut must be at least width * height * ColorFormat:getPixelSize(format) bytes.
	bool getPixelData(u8[] pixelsDataOut);

	// Get the contents of the render target as a 32-bit RGBA image. This method can be slow depending on the underlying implementation.
	ImageRGBA getImageRGBA();

	// Get the contents of the render target as a 32-bit RGBA image using an existing image object. This method can be slow depending on the underlying implementation.
	ImageRGBA getImageRGBA(ImageRGBA imgOut);

	// Create/wrap an image to be high-performance compatible with this render target. This may simply return the passed-in ImageRGBA object or something else.
	IRenderTexture createTexture(ImageRGBA img);

	// Delete/release texture resource.
	void deleteTexture(IRenderTexture texture);

	// Flush any pending rendering operations.
	void flush();

	// Call to indicate the start of rendering a new frame.
	void beginFrame();

	// Call to indicate the end of rendering of a frame. Will swap backbuffer to frontbuffer etc. as needed.
	void endFrame();

	// Set the entire render target area to a single color / depth / stencil value.
	void clear(f32 r, f32 g, f32 b, f32 a, f32 depth, u8 stencil);

	// Draw a texture onto this render target.
	void drawImage(IRenderTexture texture, i32 x, i32 y);

	// Draw an alpha-blended texture onto this render target. Will flush render queue where possible to enable accurate transluency.
	void drawImageBlended(IRenderTexture texture, i32 x, i32 y);

	// Draw text onto this render target using default font.
	void drawText(i32 x, i32 y, String<u8> text, ColorRGBA clr);

	// Draw text onto this render target. Clipped to x/y/width/height rectangle.
	void drawText(Font font, i32 x, i32 y, String<u8> text, ColorRGBA clr);

	// Draw text onto this render target. Clipped to x/y/width/height rectangle.
	void drawText(Font font, i32 x, i32 y, i32 width, i32 height, String<u8> text, ColorRGBA clr);

	// Draw text onto this render target utilizing UTF32 characters. Clipped to x/y/width/height rectangle. Be sure to pass in a font with UTF32 characters mapped.
	void drawText(Font font, i32 x, i32 y, String<u32> text, ColorRGBA clr);

	// Draw text onto this render target utilizing UTF32 characters. Clipped to x/y/width/height rectangle. Be sure to pass in a font with UTF32 characters mapped.
	void drawText(Font font, i32 x, i32 y, i32 width, i32 height, String<u32> text, ColorRGBA clr);

	// Draw rectangle outline onto this render target.
	void drawRect(Rectangle2D<i32> rect, u32 thickness, ColorRGBA color);

	// Draw filled rectangle onto this render target.
	void fillRect(Rectangle2D<i32> rect, ColorRGBA color);

	// Draw a polygon outline onto this render target.
	void drawPolygon(Polygon2D<i32> polygon, u32 thickness, ColorRGBA color);

	// Draw a filled polygon onto this render target.
	void fillPolygon(Polygon2D<i32> polygon, ColorRGBA color);

	// Draw line
	void drawLine(Line2D<i32> line, u32 thickness, ColorRGBA color);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// FPSCounter
////////////////////////////////////////////////////////////////////////////////////////////////////

// Utility for tracking frames-per-second statistics. Tracks both average FPS and worst 1% FPS.
class FPSCounter
{
	f64 windowTime = 1000.0; // milliseconds
	f64 startTime  = 0.0;    // of current window
	f64 lastFrameStartTime = 0.0;
	ArrayList<f64> frameTimes(); // we record the time of each frame so we can calculate slowest 1% frame rates etc.

	// previous window statistics
	f64 prevFrameElapsedTime = 0;
	ArrayList<f64> prevFrameTimes();

	// Default window of 1 second
	void constructor()
	{
		this.windowTime = 1000.0;
	}

	// Custom window in seconds.
	void constructor(f64 windowSeconds)
	{
		this.windowTime = 1000.0 * windowSeconds;
	}

	// As "FPS: N.M"
	String<u8> toString()
	{
		String<u8> s = "FPS: ";
		s += String<u8>:formatNumber(getAvgFPS(), 1);

		return s;
	}

	// Check to reset window
	void checkToResetWindow()
	{
		if(getElapsedTime() > windowTime)
		{
			prevFrameTimes.clear();

			// copy current to prev
			for(u64 f=0; f<frameTimes.size(); f++)
			{
				prevFrameTimes.add(frameTimes[f]);
			}
			prevFrameTimes.sort();

			// this can be slightly different from window 
			prevFrameElapsedTime = getElapsedTime();

			// we have saved data set, move on
			this.startTime = System:getTime();
			this.frameTimes.clear();
		}
	}

	// Get elapsed time from start time.
	f64 getElapsedTime()
	{
		f64 elapsedTime = System:getTime() - startTime;
		return elapsedTime;
	}

	// Mark frame rendered.
	void frameRendered()
	{
		// we can't really count the first frame rendered because we don't know when it started.
		if(prevFrameTimes.size() == 0 && lastFrameStartTime <= 0.1)
		{
			lastFrameStartTime = System:getTime();
			startTime = System:getTime(); // start of window
			return;
		}

		f64 timeOfFrame = System:getTime() - lastFrameStartTime;
		lastFrameStartTime = System:getTime();
		frameTimes.add(timeOfFrame);

		checkToResetWindow();
	}

	// Get average frames-per-second using previous data set, or if there is no previous, current partial set.
	f64 getAvgFPS()
	{
		if(prevFrameTimes.size() == 0 || prevFrameElapsedTime < 1.0)
		{
			f64 curElapsedTime = getElapsedTime();
			if(frameTimes.size() == 0 || curElapsedTime < 1.0)
				return 0.0;

			f64 curFPS = (frameTimes.size() / (curElapsedTime / 1000.0));
			return curFPS;
		}

		f64 prevFPS = (prevFrameTimes.size() / (prevFrameElapsedTime / 1000.0));
		return prevFPS;
	}

	// Get the average of the worst 1% frames. Only calculated for previous window data set, otherwise returns 0 if not available yet.
	f64 getWorst1PercentAvgFPS()
	{
		if(prevFrameTimes.size() == 0)
			return 0.0;

		i64 numBadFrames = prevFrameTimes.size() / 100;
		if(numBadFrames < 1)
			numBadFrames = 1;

		f64 totalTime = 0;
		for(i64 f=(prevFrameTimes.size() - numBadFrames); f<prevFrameTimes.size(); f++)
		{
			totalTime += prevFrameTimes[f];
		}

		f64 avgFPS = numBadFrames / (totalTime / 1000.0);
		return avgFPS;
	}
}