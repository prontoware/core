////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// RenderTarget3D
////////////////////////////////////////////////////////////////////////////////////////////////////

// 2D/3D render target.
class RenderTarget3D implements IRenderTarget2D, IRenderTarget3D
{
	const u8 RT_SCREEN = 0;
	const u8 RT_3D     = 1;
	const u8 RT_CUBE   = 2;

	u64 rtHandle  = 0; // native handle
	u8  rtType    = 0; // one of RT_SCREEN, RT_2D, RT_CUBE
	u8  numMRT    = 0; // how many color attachments (for RT_2D only)
	Rectangle2D<u32> viewport = Rectangle2D<u32>(0, 0, 0, 0);
	ITexture[] backingTextures = ITexture[](4); // if this 2D / MRT / Cube render target

	// for 2D rendering via drawImage(), drawText() etc.
	f32 z2DValue = 0.0f; // basically we increase via z2DDelta for each call to drawImage(), drawText() etc.
	f32 z2DDelta = -0.0001f; // lower numbers closer overlap larger numbers

	// for implementing drawImage()
	SpriteRenderer spriteRenderer = null;
	Texture2D tempSpriteTex = null;

	// shape rendering
	ShapeRenderer shapeRenderer = null;

	// font rendering
	ArrayMap<Font, FontTextRenderer> textRenderers();

	// these properties are cached versus always calling native functions
	u32 rtWidth;
	u32 rtHeight;
	f32 rtAspectRatio;
	u8  rtColorFormat;
	u8  rtDepthFormat;
	u8  rtStencilFormat;

	// Do not manually construct this object. Use GPU:createRenderTargetXXX etc.
	void constructor(u64 rtHandle, u8 rtType, u8 numMRT)
	{
		this.rtHandle = rtHandle;
		this.rtType   = rtType;
		this.numMRT   = numMRT;
		this.viewport.setWidth(getWidth());
		this.viewport.setHeight(getHeight());

		for(u8 r=0; r<backingTextures.length(); r++)
			backingTextures[r] = null;

		this.rtWidth         = getRTResolution_native(rtHandle)[0];
		this.rtHeight        = getRTResolution_native(rtHandle)[1];
		this.rtAspectRatio   = f32(this.rtWidth) / f32(this.rtHeight);
		this.rtColorFormat   = getRTColorFormat_native(rtHandle);
		this.rtDepthFormat   = getRTDepthFormat_native(rtHandle);
		this.rtStencilFormat = getRTStencilFormat_native(rtHandle);

		if(rtType == RT_3D)
		{
			for(u8 c=0; c<numMRT; c++)
			{
				u64 texHandle = getRTTexture_native(rtHandle, c);
				backingTextures[c] = Texture2D(texHandle, this.rtWidth, this.rtHeight, this.rtColorFormat);
			}
		}
		else if(rtType == RT_CUBE)
		{
			u64 texHandle = getRTTexture_native(rtHandle, 0);
			backingTextures[0] = TextureCube(texHandle, this.rtWidth, this.rtHeight, this.rtColorFormat);
		}

		shapeRenderer = ShapeRenderer(this, 8192);
	}

	void destroy()
	{
		this.rtHandle = 0;
	}

	// Call to indicate the start of rendering a new frame.
	void beginFrame() { beginFrame(0); }

	// Call to indicate the start of rendering a new frame. cubeMapSide only applies to cube map render targets and is one of Texture:CUBE_XXX.
	void beginFrame(u8 cubeMapSide)
	{
		z2DValue = 0.0f;

		// for window/screen render targets the size could change dynamically between frames (i.e. user resizes window)
		u32[4] rtSize = getRTResolution_native(rtHandle);
		this.rtWidth       = rtSize[0];
		this.rtHeight      = rtSize[1];
		this.viewport.setWidth(rtWidth);
		this.viewport.setHeight(rtHeight);
		this.rtAspectRatio = f32(this.rtWidth) / f32(this.rtHeight);

		beginFrameRT_native(rtHandle, cubeMapSide);
	}

	// Call to indicate the end of rendering of a frame. Will swap backbuffer to frontbuffer etc. as needed.
	void endFrame()
	{
		flush();

		endFrameRT_native(rtHandle);
	}

	// Get the width of the rendering area.
	u32 getWidth()
	{
		return this.rtWidth;
	}

	// Get the height of the rendering area.
	u32 getHeight()
	{
		return this.rtHeight;
	}

	// Get the width/height.
	f32 getAspectRatio()
	{
		return this.rtAspectRatio;
	}

	// Get viewport area. Rendering outside of viewport is clipped.
	Rectangle2D<u32> getViewport()
	{
		return viewport;
	}

	// Set viewport. Rendering outside of viewport is clipped.
	bool setViewport(u32 x, u32 y, u32 width, u32 height)
	{
		return setRTViewport_native(rtHandle, x, y, width, height);
	}

	// Get the underlying rendering format. One of ColorFormat:RGBA4, ColorFormat:RGB4A1, ColorFormat:RGBA8, ColorFormat:RGBA_F16, ColorFormat:RGBA_F32, or ColorFormat:UNKNOWN if not in-use.
	u8 getColorFormat()
	{
		return this.rtColorFormat;
	}

	// Get the underlying depth format. One of ColorFormat:R_F16, ColorFormat:R_F24, or ColorFormat:R_F32 or ColorFormat:UNKNOWN if not in-use.
	u8 getDepthFormat()
	{
		return this.rtDepthFormat;
	}

	// Get the underlying stencil format. One of ColorFormat:R_8 or ColorFormat:UNKNOWN if not in-use.
	u8 getStencilFormat()
	{
		return this.rtStencilFormat;
	}

	// Create/wrap an image to be high-performance compatible with this render target. This may simply return the passed-in ImageRGBA object or something else.
	IRenderTexture createTexture(ImageRGBA img)
	{
		return Texture2D(img);
	}

	// Get the texture backing up this target. Onscreen render targets do not normally have backing textures and this will return
	// null. 2D render targets return a Texture2D. Cube map render targets return a TextureCube. Use mrtIndex to choose one texture
	// of a multiple-render-target.
	ITexture getTexture(u8 mrtIndex)
	{
		if(mrtIndex >= backingTextures.length())
			return null;

		return backingTextures[mrtIndex];
	}

	// Get a copy of the underlying pixel data as an array of bytes. pixelsDataOut must be at least width * height * ColorFormat:getPixelSize(format) bytes. This tends to be slow. The image data will start with the bottom/left corner of the RT (i.e. display).
	bool getPixelData(u8[] pixelsDataOut)
	{
		flush();
		return readPixelsRT_native(rtHandle, pixelsDataOut);
	}
	
	// Get a copy of the rendered image data. This tends to be slow. Returns null if data not available. The image data will start with the bottom/left corner of the RT (i.e. display).
	UniversalImage getImage()
	{
		flush();

		UniversalImage uniImg(getWidth(), getHeight(), getColorFormat());
		if(getPixelData(uniImg.pixels) == false)
			return null;

		return uniImg;
	}

	// Get a copy of the rendered image data. Image data will start at top/left corner of render target (AKA display).
	ImageRGBA getImageRGBA()
	{
		ImageRGBA img(getImage());
		img.flipVertical();
		return img;
	}

	// Get the contents of the render target as a 32-bit RGBA image using an existing image object. This method can be slow depending on the underlying implementation.
	ImageRGBA getImageRGBA(ImageRGBA img)
	{
		if(rtHandle == 0)
			return img;

		if(img.getWidth() != getWidth() && img.getHeight() != getHeight())
		{
			img.resize(getWidth(), getHeight());
		}

		flush();

		if(getColorFormat() == ColorFormat:RGBA8) // we can do direct copy
		{
			u8[] pixelsBytes = img.pixels.reinterpret(Type:U8, 0); // temporarily interpret array of u32[] as u8[]
			readPixelsRT_native(rtHandle, pixelsBytes);
			img.pixels = pixelsBytes.reinterpret(Type:U32, 0); // revert
		}
		else
		{
			// need conversion etc.
			UniversalImage uniImg = getImage();
			if(uniImg == null)
				return false;

			img.consume(uniImg);
		}

		img.flipVertical();

		return true;
	}

	// Create/wrap an image to be high-performance compatible with this render target. This may simply return the passed-in ImageRGBA object.
	IRenderTexture createTexture(ImageRGBA img)
	{
		return Texture2D(img);
	}

	// Delete/release texture resource.
	void deleteTexture(IRenderTexture texture)
	{
		Texture2D tex2D = texture;
		if(tex2D != null)
		{
			tex2D.destroy();
		}
	}

	// Flush any pending rendering operations.
	void flush()
	{
		if(shapeRenderer != null)
		{
			shapeRenderer.render();
			shapeRenderer.clearBuffers();
		}

		// text rendered last because of transparent pixels (blending onto shapes)
		for(u64 t=0; t<textRenderers.size(); t++)
		{
			FontTextRenderer textRenderer = textRenderers.getValueByIndex(t);
			textRenderer.render();
			textRenderer.clearBuffers();
		}
	}

	// Set the entire render target area to a single color / depth value.
	void clear(f32 r, f32 g, f32 b, f32 a, f32 depth, u8 stencil)
	{
		clearRT_native(rtHandle, r, g, b, a, depth, stencil);
	}

	// Render to the provided render target using a custom shader program. Geometry can be indexed or not, determined by use of index buffers in shader program.
	bool renderTriangles(GPUProgram shaderProgram, u32 startIndex, u32 numVertices)
	{
		return renderTriangles_native(rtHandle, shaderProgram, startIndex, numVertices);
	}

	// Draw an texture onto this render target.
	void drawImage(IRenderTexture texture2D, i32 x, i32 y)
	{
		if(spriteRenderer == null)
			spriteRenderer = SpriteRenderer(true);

		Texture2D tex = texture2D;
		if(tex == null)
		{
			Log:logLimit("WARN: GPU.drawImage() texture2D parameter is not a Texture2D object, low performance warning! Use IRenderTarget2D.createTexture(ImageRGBA img)!" + HVM:getStackTrace(), 1);

			// warn and try to get image
			ImageRGBA img = texture2D;
			if(img != null)
			{
				if(img.pixels == null)
					return;

				if(tempSpriteTex == null)
					tempSpriteTex = Texture2D(img);

				if(tempSpriteTex.getWidth() == img.getWidth() && tempSpriteTex.getHeight() == img.getHeight())
				{
					tempSpriteTex.writeImage(img, 0); // no need to create new texture, same dimensions
				}
				else
				{
					tempSpriteTex.destroy();
					tempSpriteTex = Texture2D(img);
				}

				spriteRenderer.render(this, tempSpriteTex, x, y, img.getWidth(), img.getHeight(), z2DValue);
			}
			else // what is this?
			{
				Log:logLimit("WARN: GPU.drawImage() texture2D parameter is unknown implementation! Not rendered." + HVM:getStackTrace(), 1);
			}
		}
		else
		{
			spriteRenderer.render(this, tex, x, y, tex.getWidth(), tex.getHeight(), z2DValue);
		}
		
		z2DValue += z2DDelta;
	}

	// Draw an alpha-blended texture onto this render target. Will flush render queue where possible to enable accurate transluency.
	void drawImageBlended(IRenderTexture texture, i32 x, i32 y)
	{
		flush(); // for back-to-front order-accurate blending

		drawImage(texture, x, y);
	}

	// Draw text onto this render target using default font.
	void drawText(i32 x, i32 y, String<u8> text, ColorRGBA color)
	{
		Font defFont = Font:getFont("", 16);
		drawText(defFont, x, y, 8192, 8192, text, color);
	}

	// Draw text onto this render target using specified font.
	void drawText(Font font, i32 x, i32 y, String<u8> text, ColorRGBA color)
	{
		drawText(font, x, y, getWidth() - x, getHeight() - y, text, color);
	}

	// Draw text onto this render target. Clipped to rectangle x/y/width/height.
	void drawText(Font font, i32 x, i32 y, i32 width, i32 height, String<u8> text, ColorRGBA color)
	{
		// check if we have renderer for this font yet
		FontTextRenderer textRenderer = textRenderers.get(font);
		if(textRenderer == null)
		{
			textRenderer = FontTextRenderer(this, font, 8192);
			textRenderers.add(font, textRenderer);
		}

		textRenderer.addString(text, x, y, width, height, z2DValue, ColorRGBAf(color));
		z2DValue += z2DDelta;
	}

	// Draw text onto this render target utilizing UTF32 characters. Be sure to pass in a font with UTF32 characters mapped.
	void drawText(Font font, i32 x, i32 y, String<u32> text, ColorRGBA color)
	{
		drawText(font, x, y, getWidth() - x, getHeight() - y, text, color);
	}

	// Draw text onto this render target utilizing UTF32 characters. Be sure to pass in a font with UTF32 characters mapped.
	void drawText(Font font, i32 x, i32 y, i32 width, i32 height, String<u32> text, ColorRGBA color)
	{
		// check if we have renderer for this font yet
		FontTextRenderer textRenderer = textRenderers.get(font);
		if(textRenderer == null)
		{
			textRenderer = FontTextRenderer(this, font, 8192);
			textRenderers.add(font, textRenderer);
		}

		textRenderer.addString(text, x, y, width, height, z2DValue, ColorRGBAf(color));
		z2DValue += z2DDelta;
	}

	// Draw rectangle outline onto this render target.
	void drawRect(Rectangle2D<i32> rect, u32 thickness, ColorRGBA color)
	{
		if(rect == null)
			return;

		fillRect(Rectangle2D<i32>(rect[0], rect[1], rect.getWidth(), thickness), color); // horizontal top
		fillRect(Rectangle2D<i32>(rect[0], rect[1] + rect.getHeight() - thickness, rect.getWidth(), thickness), color); // horizontal bottom
		fillRect(Rectangle2D<i32>(rect[0], rect[1], thickness, rect.getHeight()), color); // vertical left
		fillRect(Rectangle2D<i32>(rect[0] + rect.getWidth() - thickness, rect[1], thickness, rect.getHeight()), color); // vertical right
	}

	// Draw filled rectangle onto this render target.
	void fillRect(Rectangle2D<i32> rect, ColorRGBA color)
	{
		if(rect == null)
			return;

		shapeRenderer.addRectangle(rect.getMinX(), rect.getMinY(), rect.getWidth(), rect.getHeight(), z2DValue, ColorRGBAf(color));
		z2DValue += z2DDelta;
	}

	// Draw a polygon outline onto this render target.
	void drawPolygon(Polygon2D<i32> polygon, u32 thickness, ColorRGBA color)
	{
		if(polygon == null)
			return;
		if(polygon.pts.size() < 3)
			return;

		for(u64 p=0; p<polygon.pts.size(); p++)
		{
			i32[2] p0 = polygon.pts[p];
			i32[2] p1;
			if((p+1) < (polygon.pts.size()))
				p1 = polygon.pts[p + 1];
			else
				p1 = polygon.pts[0];

			shapeRenderer.addLine(p0[0], p0[1], p1[0], p1[1], thickness, z2DValue, ColorRGBAf(color));
		}

		z2DValue += z2DDelta;
	}

	// Draw a filled polygon onto this render target.
	void fillPolygon(Polygon2D<i32> polygon, ColorRGBA color)
	{
		if(polygon == null)
			return;
		if(polygon.pts.size() < 3)
			return;

		ArrayList<Polygon2D<i32>> tris = polygon.triangulate();
		for(u64 t=0; t<tris.size(); t++)
		{
			Polygon2D<i32> tri = tris[t];
			shapeRenderer.addTriangle(tri.pts[0][0], tri.pts[0][1], tri.pts[1][0], tri.pts[1][1], tri.pts[2][0], tri.pts[2][1], z2DValue, ColorRGBAf(color));
		}

		z2DValue += z2DDelta;
	}

	// Draw line, clipped.
	void drawLine(Line2D<i32> line, u32 thickness, ColorRGBA color)
	{
		if(line == null)
			return;

		shapeRenderer.addLine(line[0], line[1], line[2], line[3], thickness, z2DValue, ColorRGBAf(color));
		z2DValue += z2DDelta;
	}

	// Transform a point from "reading-order" pixel space (where 0,0 is top-left origin) to GPU device coordinates (0,0 is center of screen, -1 to +1 extents, basically a cartesian system).
	f32[2] pixelToDeviceCoord(f32 x, f32 y)
	{
		f32 tx = ((x / rtWidth) * 2.0f) - 1.0f;
		f32 ty = (( (rtHeight - y) / rtHeight) * 2.0f) - 1.0f;

		return f32(tx, ty);
	}

	// Transform a rectangle from "reading-order" pixel space (where 0,0 is top-left origin) to GPU device coordinates (0,0 is center of screen, -1 to +1 extents, basically a cartesian system).
	f32[4] pixelToDeviceCoord(f32 x, f32 y, f32 width, f32 height)
	{
		f32 tx = ((x / rtWidth) * 2.0f) - 1.0f;
		f32 ty = (( (rtHeight - y) / rtHeight) * 2.0f) - 1.0f;
		f32 tw = ((width / rtWidth) * 2.0f);
		f32 th = ((height / rtHeight) * 2.0f);

		return f32(tx, ty, tw, th);
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// GPU
////////////////////////////////////////////////////////////////////////////////////////////////////

// Create and manage resources on the GPU, render targets etc.
class GPU
{
	// Used for manual shader languages version etc. Usually only needed for debugging.
	const u8 API_UNKNOWN       = 0; // not graphics etc.
	const u8 API_OPENGL_ES_2_0 = 1; // 2.0 ES profile + floating point textures extension etc.
	const u8 API_OPENGL_CR_3_3 = 2; // full core profile ("desktop OpenGL") 3.3

	// Create an offscreen rendering target to a 2D texture. Can include up to four identical color format texture outputs for
	// multi-render-target (MRT) rendering. Note that not all GPUs support MRT or all color formats. The closest match will be
	// selected automatically if possible.
	shared IRenderTarget3D createRenderTarget3D(u32 width, u32 height, u8 colorFormat, u8 numColorTextures, bool depth, bool stencil)
	{
		u64 rtHandle = create3DRT_native(width, height, colorFormat, numColorTextures, depth, stencil);
		RenderTarget3D rt(rtHandle, RenderTarget3D:RT_3D, numColorTextures);
		return rt;
	}

	// Create an offscreen rendering target to a cube texture. Note that not all GPUs support MRT or all color formats. The closest 
	// match will be selected automatically if possible.
	shared IRenderTarget3D createRenderTargetCube(u32 width, u32 height, u8 colorFormat, bool depth, bool stencil)
	{
		u64 rtHandle = createCubeRT_native(width, height, colorFormat, depth, stencil); 
		RenderTarget3D rt(rtHandle, RenderTarget3D:RT_CUBE, 1);
		return rt;
	}

	// Turn vsync on/off. May not be supported on all platforms.
	shared void setVSync(bool enabled)
	{
		setVSync_native(enabled);
	}

	// Generally returns a string containing the GPU name (i.e. "Geforce 980 Ti") and maker (i.e. "NVIDIA") although exact info available varies by platform.
	shared String<u8> getGPUInfoString()
	{
		return gpuGetInfoString_native();
	}

	// Does this GPU support the passed-in texture format for rendering to and using as a texture? format is one of ColorFormat:XXX.
	shared bool isTextureFormatUsable(u8 format)
	{
		return gpuTextureFormatUsable_native(format);
	}

	// Compile IVertexShader implementor into one of several native shader language source code. outputLanguage one of API_OPENGL_ES_2_0 or API_OPENGL_FL_3_3.
	shared String<u8> compileVertexShaderToSource(IVertexShader vs, u8 outputLanguage, String<u8> errorsOut)
	{
		errorsOut.resize(8192);
		return compileVertexShaderToSource_native(vs, outputLanguage, errorsOut);
	}

	// Compile IVertexShader implementor into one of several native shader language source code. outputLanguage one of API_OPENGL_ES_2_0 or API_OPENGL_FL_3_3.
	shared String<u8> compilePixelShaderToSource(IPixelShader ps, u8 outputLanguage, bool useHighPrecision, String<u8> errorsOut)
	{
		errorsOut.resize(8192);
		return compilePixelShaderToSource_native(ps, outputLanguage, useHighPrecision, errorsOut);
	}
}