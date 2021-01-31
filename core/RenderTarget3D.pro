////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Texture
////////////////////////////////////////////////////////////////////////////////////////////////////

// Constants and utility functions for all texture types.
class Texture
{
	const u8 TYPE_2D   = 0; // 2D texture map
	const u8 TYPE_CUBE = 1; // cube map (six sides)

	// UV mapping modes.
	const u8 UV_CLAMP  = 0; // Default for Pronto, clamp UV coordinates to valid range (0,0) to (1,1).
	const u8 UV_REPEAT = 1; // Repeat texture coordinates (wrap) - default for WebGL, OpenGL ES etc. Texture must have power-of-two dimensions.

	// Texture filitering options. Nearest and linear options supported on all platforms.
	const u8 FILTER_NEAREST            = 0; // Single sample.
	const u8 FILTER_LINEAR             = 1; // Four samples from original texture.
	const u8 FILTER_LINEAR_MIPMAP      = 2; // Four * 2 samples from 2 mipmap levels. Texture must have power-of-two dimensions.
	const u8 FILTER_ANISOTROPIC_MIPMAP = 3; // FILTER_LINEAR_MIPMAP + anisotropic filtering. Texture must have power-of-two dimensions.
	
	// Cube map faces indexes.
	const u8 CUBE_X_POS = 0;
	const u8 CUBE_X_NEG = 1;
	const u8 CUBE_Y_POS = 2;
	const u8 CUBE_Y_NEG = 3;
	const u8 CUBE_Z_POS = 4;
	const u8 CUBE_Z_NEG = 5;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// ITexture
////////////////////////////////////////////////////////////////////////////////////////////////////

// Interface to a 2D texture, cube map etc.
interface ITexture
{
	// Get width of texture in pixels.
	u32 getWidth();

	// Get height of texture in pixels.
	u32 getHeight();

	// Get color format of pixels. One of ColorFormat:XXX.
	u8 getColorFormat();

	// Get number of mip map levels. Zero/one indicates no mip map levels.
	u8 getNumMipMapLevels();

	// Release memory
	void destroy();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// IRenderTarget3D
////////////////////////////////////////////////////////////////////////////////////////////////////

// Render target. 3D drawable. Supports all methods of IRenderTarget2D.
interface IRenderTarget3D
{
	// Call to indicate the start of rendering a new frame.
	void beginFrame();

	// Call to indicate the start of rendering a new frame. cubeMapSide only applies to cube map render targets and is one of Texture:CUBE_XXX.
	void beginFrame(u8 cubeMapSide);

	// Call to indicate the end of rendering of a frame. Will swap backbuffer to frontbuffer etc. as needed.
	void endFrame();

	// Get the width of the rendering area.
	u32 getWidth();

	// Get the height of the rendering area.
	u32 getHeight();

	// Width / Height.
	f32 getAspectRatio();

	// Get viewport (in pixels).
	Rectangle2D<u32> getViewport();

	// Set viewport (in pixels).
	bool setViewport(u32 x, u32 y, u32 width, u32 height);

	// Get the underlying rendering format. One of ColorFormat:RGBA4, ColorFormat:RGB4A1, ColorFormat:RGBA8, ColorFormat:RGBA_F16, ColorFormat:RGBA_F32, or ColorFormat:UNKNOWN if not in-use.
	u8 getColorFormat();

	// Get the underlying depth format. One of ColorFormat:R_F16, ColorFormat:R_F24, ColorFormat:R_F32, or ColorFormat:UNKNOWN if not in-use.
	u8 getDepthFormat();

	// Get the underlying stencil format. One of ColorFormat:R_8, or ColorFormat:UNKNOWN if not in-use.
	u8 getStencilFormat();

	// Get the texture backing up this target. Onscreen render targets do not normally have backing textures and this will return
	// null. 2D render targets return a Texture2D. Cube map render targets return a TextureCube. Use mrtIndex to choose one texture
	// of a multiple-render-target.
	ITexture getTexture(u8 mrtIndex);

	// Get a copy of the underlying pixel data as an array of bytes. pixelsDataOut must be at least width * height * ColorFormat:getPixelSize(format) bytes. This tends to be slow. The image data will start with the bottom/left corner of the RT (i.e. display).
	bool getPixelData(u8[] pixelsDataOut);

	// Get a copy of the rendered image data. This tends to be slow. Returns null if data not available. The image data will start with the bottom/left corner of the RT (i.e. display).
	UniversalImage getImage();

	// Get the contents of the render target as a 32-bit RGBA image. This method can be slow depending on the underlying implementation.
	ImageRGBA getImageRGBA();

	// Get the contents of the render target as a 32-bit RGBA image using an existing image object. This method can be slow depending on the underlying implementation.
	ImageRGBA getImageRGBA(ImageRGBA img);

	// Create/wrap an image to be high-performance compatible with this render target. This may simply return the passed-in ImageRGBA object or something else.
	IRenderTexture createTexture(ImageRGBA img);

	// Delete/release texture resource.
	void deleteTexture(IRenderTexture texture);
	
	// Flush any pending rendering operations.
	void flush();

	// Set the entire render target area to a single color / depth / stencil value.
	void clear(f32 r, f32 g, f32 b, f32 a, f32 depth, u8 stencil);

	// Render triangles.
	bool renderTriangles(GPUProgram shaderProgram, u32 startIndex, u32 numVertices);

	// Draw an texture onto this render target.
	void drawImage(IRenderTexture texture, i32 x, i32 y);

	// Draw an alpha-blended texture onto this render target. Will flush render queue where possible to enable accurate transluency.
	void drawImageBlended(IRenderTexture texture, i32 x, i32 y);

	// Draw text onto this render target using default font.
	void drawText(i32 x, i32 y, String<u8> text, ColorRGBA clr);

	// Draw text onto this render target.
	void drawText(Font font, i32 x, i32 y, i32 width, i32 height, String<u8> text, ColorRGBA clr);

	// Draw text onto this render target utilizing UTF32 characters. Be sure to pass in a font with UTF32 characters mapped.
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

	// Transform a point from "reading-order" pixel space (where 0,0 is top-left origin) to GPU device coordinates (0,0 is center of screen, -1 to +1 extents, basically a cartesian system).
	f32[2] pixelToDeviceCoord(f32 x, f32 y);

	// Transform a rectangle from "reading-order" pixel space (where 0,0 is top-left origin) to GPU device coordinates (0,0 is center of screen, -1 to +1 extents, basically a cartesian system).
	f32[4] pixelToDeviceCoord(f32 x, f32 y, f32 width, f32 height);
}