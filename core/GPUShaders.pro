////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

// Stock GPU shaders etc.

////////////////////////////////////////////////////////////////////////////////////////////////////
// RendererUtils
////////////////////////////////////////////////////////////////////////////////////////////////////

// Some misc. utilities for implementing renderers.
class RendererUtils
{
	// Transform a point from independent "reading-order" aspect-ratio space (where 0,0 is top left origin, and bottom-right is width=aspectRatio, height=1) to GPU device coordinates.
	shared f32[2] readCoordToDevice(f32 x, f32 y, f32 rtAspectRatio)
	{
		f32 tx = ((x / rtAspectRatio) * 2.0f) - 1.0f;
		f32 ty = (( (1.0f - y)) * 2.0f) - 1.0f;

		return f32(tx, ty);
	}

	// Transform a rectangle from independent "reading-order" aspect-ratio space (where 0,0 is top left origin, and bottom-right is width=aspectRatio, height=1) to GPU device coordinates.
	shared f32[4] readCoordToDevice(f32 x, f32 y, f32 width, f32 height, f32 rtAspectRatio)
	{
		f32 tx = ((x / rtAspectRatio) * 2.0f) - 1.0f;
		f32 ty = (( (1.0f - y)) * 2.0f) - 1.0f;
		f32 tw = ((width / rtAspectRatio) * 2.0f);
		f32 th = (height * 2.0f);

		return f32(tx, ty, tw, th);
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// SpriteRenderer
////////////////////////////////////////////////////////////////////////////////////////////////////

// Set texture on sprite pixel shader.
interface ISpritePS
{
	// Set texture on sprite pixel shader.
	void setTexture(Texture2D colorTex);
}

// Transform one Vec4f vertex by one matrix. Includes one Vec2f uv coordinate varying.
class SpriteRendererVS implements IVertexShader
{
	// Uniforms
	Mat4f matrix();

	// Vertex attributes
	VertexBuffer posBuf;
	VertexBuffer uvBuf;

	void run(Shader s)
	{
		Vec4f vertexPos    = s.vsInputVertex4f(posBuf);
		Vec4f transformPos = matrix * vertexPos;
		s.vsOutputPosition(transformPos);

		Vec2f vertexUV = s.vsInputVertex2f(uvBuf);
		s.vsOutputVarying2f(0, vertexUV);
	}
}

// Single-textured.
class SpriteRendererPS implements IPixelShader, ISpritePS
{
	// Uniforms
	Texture2D colorTex;

	void run(Shader s)
	{
		Vec2f vertexUV = s.psInputVarying2f(0);
		Vec4f texColor = s.psSampleTex2D(colorTex, vertexUV);
		s.psOutput(0, texColor);
	}

	// Implements ISpritePS
	void setTexture(Texture2D ct)
	{
		this.colorTex = ct;
	}
}

// Single-textured, blended using texture alpha.
class SpriteRendererAlphaPS implements IPixelShader, ISpritePS
{
	// Uniforms
	Texture2D colorTex;

	void run(Shader s)
	{
		Vec2f vertexUV = s.psInputVarying2f(0);
		Vec4f texColor = s.psSampleTex2D(colorTex, vertexUV);
		s.psOutput(0, texColor);
	}

	// Implements ISpritePS
	void setTexture(Texture2D ct)
	{
		this.colorTex = ct;
	}
}

// Render textured quad with optional blending. Used for rendering full screen image (i.e. upload ImageRGBA contents to GPU frame buffer) etc.
class SpriteRenderer
{
	// Shader
	SpriteRendererVS vs();
	ISpritePS spritePS = null;
	GPUProgram gpuProgram;

	Matrix4x4<f32> tempMatrix();
	Matrix4x4<f32> transformMatrix();

	// Create shader etc. Supports alpha blending by default.
	void constructor()
	{
		constructor(true);
	}

	// Create shader etc. alphaBlending=true to support translucency, false to turn off (with performance benefit).
	void constructor(bool alphaBlending)
	{
		IPixelShader ps = null;

		if(alphaBlending == false)
			ps = SpriteRendererPS();
		else
			ps = SpriteRendererAlphaPS();

		spritePS = ps;

		GPUProgramSettings gpuSettings();
		gpuSettings.depthTestEnabled = true;
		gpuSettings.depthTestFunc    = GPUProgramSettings:CMP_FUNC_LESS; // CMP_FUNC_LESS is default
		gpuSettings.cullTriMode      = GPUProgramSettings:CULL_CCW; // CCW is default

		if(alphaBlending == true)
		{
			gpuSettings.blendEnabled = true;
			gpuSettings.blendFunc    = GPUProgramSettings:BLEND_FUNC_SRC_ALPHA;
		}

		gpuProgram = GPUProgram();
		if(gpuProgram.create(gpuSettings, vs, ps) == false)
		{
			Log:log("Failed to compile SpriteRenderer shaders with error(s):\n");
			Log:log(gpuProgram.getCompileErrors());
		}

		f32 pq =  1.0f; // quad size
		f32 nq =  0.0f; // quad size

		f32[4][] verts(6);
		verts[0] = f32(nq, pq, 0, 1);
		verts[1] = f32(pq, pq, 0, 1);
		verts[2] = f32(pq, nq, 0, 1);
		verts[3] = f32(pq, nq, 0, 1);
		verts[4] = f32(nq, nq, 0, 1);
		verts[5] = f32(nq, pq, 0, 1);
		vs.posBuf = VertexBuffer(verts);
		
		f32[] uvs(12); // always rendering entire sprite area
		uvs[0] = 0; // x
		uvs[1] = 0; // y
		uvs[2] = 1; // x
		uvs[3] = 0; // y
		uvs[4] = 1; // x
		uvs[5] = 1; // y
		uvs[6]  = 1; // x
		uvs[7]  = 1; // y
		uvs[8]  = 0; // x
		uvs[9]  = 1; // y
		uvs[10] = 0; // x
		uvs[11] = 0; // y
		vs.uvBuf = VertexBuffer(uvs);

		spritePS.setTexture(null); // set dynamically in render()
	}

	// Release GPU resources.
	void destroy()
	{
		if(gpuProgram != null)
		{
			gpuProgram.destroy();
			gpuProgram = null;
		}
	}

	// Render a sprite at x/y pixel position where 0,0 is top-left of screen or window and bottom-right is rt-width,rt-height.
	void render(IRenderTarget3D rt, Texture2D spriteTex, f32 x, f32 y, f32 width, f32 height, f32 depthZ)
	{
		f32 rtWidth  = rt.getWidth();
		f32 rtHeight = rt.getHeight();

		transformMatrix.setToIdentity();

		tempMatrix.setAsScaleMatrix(Vec3<f32>( ((width / rtWidth) * 2), ((height / rtHeight) * 2), 0));
		transformMatrix.mul(tempMatrix);

		// y + height offsets start of sprite to zero in normalized
		// f32 transY = (y - height) + (rtHeight / 2);
		f32 transY = ((-1 * y) - height) + (rtHeight / 2);

		tempMatrix.setAsTranslationMatrix(Vec3<f32>( ((x / rtWidth) * 2) - 1.0, (( transY / rtHeight) * 2), depthZ));
		transformMatrix.mul(tempMatrix);

		for(u8 e=0; e<16; e++)
			vs.matrix[e] = transformMatrix.m[e];

		spritePS.setTexture(spriteTex); // ps.colorTex = spriteTex;

		rt.renderTriangles(gpuProgram, 0, 6); // six vertices = two triangles
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// FontTextRenderer
////////////////////////////////////////////////////////////////////////////////////////////////////

// Transform one Vec4f vertex by one matrix using indices.
class FontTextRendererVS implements IVertexShader
{
	// Uniforms
	Mat4f matrix();

	// Vertex attributes
	IndexBuffer  indexBuf;
	VertexBuffer posBuf;
	VertexBuffer colorBuf; // rgba
	VertexBuffer uvBuf;    // into glyph texture

	void run(Shader s)
	{
		Vec4f vertexPos = s.vsInputVertex4f(posBuf);
		vertexPos = matrix * vertexPos;
		s.vsOutputPosition(vertexPos);

		Vec2f vertexUV = s.vsInputVertex2f(uvBuf);
		s.vsOutputVarying2f(0, vertexUV);

		Vec4f vertexColor = s.vsInputVertex4f(colorBuf);
		s.vsOutputVarying4f(1, vertexColor);
	}
}

// Render text character.
class FontTextRendererPS implements IPixelShader
{
	// Uniforms
	Texture2D fontGlyphTex;

	void run(Shader s)
	{
		Vec2f vertexUV   = s.psInputVarying2f(0);
		Vec4f glyphColor = s.psSampleTex2D(fontGlyphTex, vertexUV);
		Vec4f color      = s.psInputVarying4f(1);
		color[3] = glyphColor[0]; // using red channel for alpha (from glyph texture)
		s.psOutput(0, color);
	}
}

// Render text with a single Font.
class FontTextRenderer
{
	// Shader
	FontTextRendererVS vs();
	FontTextRendererPS ps();
	GPUProgram gpuProgram;

	Matrix4x4<f32> tempMatrix();
	Matrix4x4<f32> transformMatrix();

	IRenderTarget3D rt; // needed for width/height to make text pixel-perfect

	// Data
	Font font;
	u32 maxChars;
	u32 numUsedChars; // how many used
	f32[4][] posData;
	f32[4][] colorData;
	f32[2][] uvData;

	// Create shader etc. maxCharacters is used for max text characters that can be rendered in one go. maxCharacters must be less than/equal to 10000.
	void constructor(IRenderTarget3D rt, Font font, u32 maxCharacters)
	{
		if(maxCharacters > 10000)
			maxCharacters = 10000; // 16 bit indices means we can only do up to 65k vertices

		this.rt           = rt;
		this.font         = font;
		this.maxChars     = maxCharacters;
		this.numUsedChars = 0;

		GPUProgramSettings gpuSettings();
		gpuSettings.depthTestEnabled = true;
		gpuSettings.depthTestFunc    = GPUProgramSettings:CMP_FUNC_LESS; // CMP_FUNC_LESS is default
		gpuSettings.cullTriMode      = GPUProgramSettings:CULL_CCW; // GPUProgramSettings:CULL_CCW; // CCW is default
		gpuSettings.blendEnabled     = true;
		gpuSettings.blendFunc        = GPUProgramSettings:BLEND_FUNC_SRC_ALPHA;

		gpuProgram = GPUProgram();
		if(gpuProgram.create(gpuSettings, vs, ps) == false)
		{
			Log:log("Failed to compile FontTextRenderer shader program with error(s):\n");
			Log:log(gpuProgram.getCompileErrors());
		}

		createBuffers();

		ps.fontGlyphTex = Texture2D(font.fontImg);
		ps.fontGlyphTex.setFilterMode(Texture:FILTER_NEAREST);
	}

	// Destroy
	void destroy()
	{
		if(gpuProgram != null)
		{
			gpuProgram.destroy();
			gpuProgram = null;
		}

		vs = null;
		ps = null;
		rt = null;
	}

	// Create sized buffers.
	void createBuffers()
	{
		u16[] indicesData(6 * maxChars); // 2 triangles each * 3 vertices per triangle * number of characters
		for(u32 c=0; c<maxChars; c++)
		{
			indicesData[(c * 6) + 0] = (c * 4) + 0;
			indicesData[(c * 6) + 1] = (c * 4) + 1;
			indicesData[(c * 6) + 2] = (c * 4) + 2;

			indicesData[(c * 6) + 3] = (c * 4) + 2;
			indicesData[(c * 6) + 4] = (c * 4) + 3;
			indicesData[(c * 6) + 5] = (c * 4) + 0;
		}
		vs.indexBuf = IndexBuffer(indicesData, false); // indices don't change

		this.posData = f32[4][](maxChars);
		vs.posBuf    = VertexBuffer(maxChars * 4 * 16, true); // true because regular dynamic updates to data

		this.uvData = f32[2][](maxChars);
		vs.uvBuf    = VertexBuffer(maxChars * 4 * 8, true);

		this.colorData = f32[4][](maxChars);
		vs.colorBuf    = VertexBuffer(maxChars * 4 * 16, true); // true because regular dynamic updates to data
	}

	// Update buffers. Upload user data to GPU buffers.
	void updateBuffers()
	{
		// update only the range in-use.
		vs.posBuf.setData(posData, 0, numUsedChars * 4);
		vs.colorBuf.setData(colorData, 0, numUsedChars * 4);
		vs.uvBuf.setData(uvData, 0, numUsedChars * 4);
	}

	// Reset used characters, clearning any string data.
	void clearBuffers()
	{
		numUsedChars = 0;
	}

	// Add a UTF8 string to be rendered starting at x/y pixel position. Clipped to width/height. Returns x position where text ends.
	f32 addString(String<u8> str, f32 x, f32 y, f32 width, f32 height, f32 z, ColorRGBAf clr)
	{
		f32 tx = (x / rt.getWidth()) * rt.getAspectRatio();
		f32 ty = y / rt.getHeight();
		f32 tw = (width / rt.getWidth()) * rt.getAspectRatio();
		f32 th = height / rt.getHeight();

		f32 newX = addStringDeviceCoords(str, tx, ty, tw, th, z, clr);

		newX = (newX / rt.getAspectRatio()) * rt.getWidth();

		return newX;
	}

	// Add a UTF32 string to be rendered starting at x/y pixel position. Clipped to width/height. Returns x position where text ends.
	f32 addString(String<u32> str, f32 x, f32 y, f32 width, f32 height, f32 z, ColorRGBAf clr)
	{
		f32 tx = (x / rt.getWidth()) * rt.getAspectRatio();
		f32 ty = y / rt.getHeight();
		f32 tw = (width / rt.getWidth()) * rt.getAspectRatio();
		f32 th = height / rt.getHeight();

		f32 newX = addStringDeviceCoords(str, tx, ty, tw, th, z, clr);

		newX = (newX / rt.getAspectRatio()) * rt.getWidth();

		return newX;
	}

	// Add a UTF8 string to be rendered starting at x/y position. Uses independent reading-order coordinates. Returns x position where text ends.
	f32 addStringDeviceCoords(String<u8> str, f32 x, f32 y, f32 width, f32 height, f32 z, ColorRGBAf clr)
	{
		f32 curX = x;
		f32 curY = y;
		for(u64 c=0; c<str.length(); c++)
		{
			u8 ch = str[c];

			if(ch == Chars:NEW_LINE)
			{
				curX  = x;
				curY += font.getLineHeight();
			}

			//if(curY + font.getLineHeight() > (y + height))
			//	return curX;

			f32 oldX = curX;
			curX = addCharacterDeviceCoords(ch, curX, curY, z, clr);
			if(curX >= (x + width))
			{
				numUsedChars--;
				return oldX;
			}
		}

		return curX;
	}

	// Add a UTF32 string to be rendered starting at x/y position. Uses independent reading-order coordinates. Returns x position where text ends.
	f32 addStringDeviceCoords(String<u32> str, f32 x, f32 y, f32 width, f32 height, f32 z, ColorRGBAf clr)
	{
		f32 curX = x;
		f32 curY = y;
		for(u64 c=0; c<str.length(); c++)
		{
			u32 ch = str[c];

			if(ch == Chars:NEW_LINE)
			{
				curX  = x;
				curY += font.getLineHeight();
			}

			//if(curY + font.getLineHeight() > (y + height))
			//	return curX;

			f32 oldX = curX;
			curX = addCharacterDeviceCoords(ch, curX, curY, z, clr);
			if(curX >= (x + width))
			{
				numUsedChars--;
				return oldX;
			}
		}

		return curX;
	}

	// Add a UTF32 character to be rendered. Uses independent reading-order coordinates. Returns x position where text ends.
	f32 addCharacterDeviceCoords(u32 charID, f32 x, f32 y, f32 z, ColorRGBAf clr)
	{
		if((numUsedChars + 1) >= maxChars)
		{
			Log:log("FontTextRenderer.addCharacter() too many characters!");
			return 0.0f;
		}

		f32 aspectRatio = rt.getAspectRatio();
		f32[2] transXY = RendererUtils:readCoordToDevice(x, y, aspectRatio);

		f32 curX = transXY[0];
		f32 curY = transXY[1];
		f32 curZ = z;
		
		FontGlyphChar chDesc = font.getCharDesc(charID);
		if(chDesc == null)
		{
			Log:log("FontTextRenderer.addCharacter() no mapping for charID: " + charID);
			return 0.0f;
		}

		f32 x0 = curX; // left
		f32 x1 = curX + ((f32(chDesc.width) / f32(rt.getWidth())) * 2); // right

		f32 y0 = curY; // top
		f32 y1 = curY - ((f32(chDesc.height) / f32(rt.getHeight())) * 2); // bottom

		u32 baseVIndex = (numUsedChars * 4);

		posData[baseVIndex + 0] = f32(x0, y0, curZ, 1);
		posData[baseVIndex + 1] = f32(x1, y0, curZ, 1);
		posData[baseVIndex + 2] = f32(x1, y1, curZ, 1);
		posData[baseVIndex + 3] = f32(x0, y1, curZ, 1);

		colorData[baseVIndex + 0] = clr.rgba;
		colorData[baseVIndex + 1] = clr.rgba;
		colorData[baseVIndex + 2] = clr.rgba;
		colorData[baseVIndex + 3] = clr.rgba;

		f32 u0 = f32(chDesc.x) / f32(font.getGlyphImage().getWidth()); // left
		f32 u1 = f32(chDesc.x + chDesc.width) / f32(font.getGlyphImage().getWidth()); // right
		f32 v0 = (f32(chDesc.y) / f32(font.getGlyphImage().getHeight())); // top (0,0)
		f32 v1 = (f32(chDesc.y + chDesc.height) / f32(font.getGlyphImage().getHeight())); // bottom
		
		uvData[baseVIndex + 0] = f32(u0, v0);
		uvData[baseVIndex + 1] = f32(u1, v0);
		uvData[baseVIndex + 2] = f32(u1, v1);
		uvData[baseVIndex + 3] = f32(u0, v1);

		numUsedChars++;

		f32 newX = x + ( (f32(chDesc.xAdvance) / f32(rt.getWidth())) ) * aspectRatio ; // spacing between characters included in xAdvance in 0->1 space
		return newX;
	}

	// Render all currently set characters.
	void render()
	{
		if(numUsedChars == 0)
			return;

		updateBuffers();

		f32 rtWidth     = rt.getWidth();
		f32 rtHeight    = rt.getHeight();
		f32 aspectRatio = rtWidth / rtHeight;

		transformMatrix.setToIdentity();

		for(u8 e=0; e<16; e++)
			vs.matrix[e] = transformMatrix.m[e];

		rt.renderTriangles(gpuProgram, 0, numUsedChars * 6); // six vertices = two triangles
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// ShapeRenderer
////////////////////////////////////////////////////////////////////////////////////////////////////

// Transform one Vec4f vertex by one matrix. Includes one Vec2f uv coordinate varying.
class ShapeRendererVS implements IVertexShader
{
	// Uniforms
	Mat4f matrix();

	// Vertex attributes
	VertexBuffer posBuf;
	VertexBuffer colorBuf; // rgba

	void run(Shader s)
	{
		Vec4f vertexPos    = s.vsInputVertex4f(posBuf);
		Vec4f transformPos = matrix * vertexPos;
		s.vsOutputPosition(transformPos);

		Vec4f vertexColor = s.vsInputVertex4f(colorBuf);
		s.vsOutputVarying4f(0, vertexColor);
	}
}

// Colored per vertex.
class ShapeRendererPS implements IPixelShader
{
	void run(Shader s)
	{
		Vec4f vertexColor = s.psInputVarying4f(0);
		s.psOutput(0, vertexColor);
	}
}

// Render colored 2D shapes. Shape colors set per vertex and supporting translucency.
class ShapeRenderer
{
	// Shader
	ShapeRendererVS vs();
	ShapeRendererPS ps();
	GPUProgram gpuProgram;
	IRenderTarget3D rt;

	Matrix4x4<f32> tempMatrix();
	Matrix4x4<f32> transformMatrix();

	u32 maxVerts;
	u32 numUsedVerts; // how many used
	f32[4][] posData;
	f32[4][] colorData;

	// Create shader etc.
	void constructor(IRenderTarget3D rt, u32 maxVertices)
	{
		this.rt           = rt;
		this.maxVerts     = maxVertices;
		this.numUsedVerts = 0;

		GPUProgramSettings gpuSettings();
		gpuSettings.depthTestEnabled = true;
		gpuSettings.depthTestFunc    = GPUProgramSettings:CMP_FUNC_LESS; // CMP_FUNC_LESS is default
		gpuSettings.cullTriMode      = GPUProgramSettings:CULL_NONE; // GPUProgramSettings:CULL_CCW; // GPUProgramSettings:CULL_CCW; // CCW is default
		gpuSettings.blendEnabled     = true;
		gpuSettings.blendFunc        = GPUProgramSettings:BLEND_FUNC_SRC_ALPHA;

		gpuProgram = GPUProgram();
		if(gpuProgram.create(gpuSettings, vs, ps) == false)
		{
			Log:log("Failed to compile ShapeRenderer shader program with error(s):\n");
			Log:log(gpuProgram.getCompileErrors());
		}

		createBuffers();
	}

	// Release program.
	void destroy()
	{
		if(gpuProgram != null)
		{
			gpuProgram.destroy();
			gpuProgram = null;
		}
		vs = null;
		ps = null;
		rt = null;
	}

	// Create sized buffers.
	void createBuffers()
	{
		this.posData = f32[4][](maxVerts);
		vs.posBuf    = VertexBuffer(maxVerts * 1 * 16, true); // true because regular dynamic updates to data

		this.colorData = f32[4][](maxVerts);
		vs.colorBuf    = VertexBuffer(maxVerts * 1 * 16, true);
	}

	// Update buffers. Upload user data to GPU buffers.
	void updateBuffers()
	{
		// update only the range in-use.
		vs.posBuf.setData(posData, 0, numUsedVerts * 4);
		vs.colorBuf.setData(colorData, 0, numUsedVerts * 4);
	}

	// Reset used vertices, clearing any set shapes.
	void clearBuffers()
	{
		numUsedVerts = 0;
	}

	// Check if triangle is clockwise in pixel space (0,0 to N,M)
	bool isTriClockwiseInPixelSpace(f32 x0, f32 y0, f32 x1, f32 y1, f32 x2, f32 y2)
	{
		f32 sign = (x0 - x2) * (y1 - y2) - (x1 - x2) * (y0 - y2);
		if(sign < 0.0f)
			return false;

		return true;
	}

	// Add triangle using pixel coordinates where origin is top-left of render target. Pass-in as clockwise ordering. CCW is clipped.
	void addTriangle(f32 x0, f32 y0, f32 x1, f32 y1, f32 x2, f32 y2, f32 z, ColorRGBAf clr)
	{
		if((numUsedVerts+3) >= maxVerts)
			return;

		if(isTriClockwiseInPixelSpace(x0, y0, x1, y1, x2, y2) == false)
		{
			// swap
			f32 tx = x0;
			f32 ty = y0;

			x0 = x1;
			y0 = y1;

			x1 = tx;
			y1 = ty;
		}

		f32[2] xy0 = rt.pixelToDeviceCoord(x0, y0);
		f32[2] xy1 = rt.pixelToDeviceCoord(x1, y1);
		f32[2] xy2 = rt.pixelToDeviceCoord(x2, y2);

		// triangles, clockwise ordering
		this.posData[numUsedVerts + 0] = f32(xy0[0], xy0[1], z, 1);
		this.posData[numUsedVerts + 1] = f32(xy2[0], xy2[1], z, 1); // CW in pixelspace is CCW in device coordinates, hence swap
		this.posData[numUsedVerts + 2] = f32(xy1[0], xy1[1], z, 1);
		this.colorData[numUsedVerts + 0] = clr.rgba;
		this.colorData[numUsedVerts + 1] = clr.rgba;
		this.colorData[numUsedVerts + 2] = clr.rgba;
		
		//Log:log("addTriangle() xyz: " + String<u8>:formatNumber(xy0[0]) + ", "  + String<u8>:formatNumber(xy0[1]) + ", "  + String<u8>:formatNumber(z));

		numUsedVerts += 3;
	}

	// Add rectangle using pixel coordinates where origin is top-left of render target.
	void addRectangle(f32 x, f32 y, f32 width, f32 height, f32 z, ColorRGBAf clr)
	{
		if((numUsedVerts+6) >= maxVerts)
			return;

		f32[4] t = rt.pixelToDeviceCoord(x, y, width, height);

		f32 tx = t[0];
		f32 ty = t[1];
		f32 tw = t[2];
		f32 th = t[3];

		// two triangles, clockwise ordering
		this.posData[numUsedVerts + 0] = f32(tx, ty, z, 1);
		this.posData[numUsedVerts + 1] = f32(tx + tw, ty, z, 1);
		this.posData[numUsedVerts + 2] = f32(tx + tw, ty - th, z, 1);
		this.colorData[numUsedVerts + 0] = clr.rgba;
		this.colorData[numUsedVerts + 1] = clr.rgba;
		this.colorData[numUsedVerts + 2] = clr.rgba;
		numUsedVerts += 3;

		this.posData[numUsedVerts + 0] = f32(tx + tw, ty - th, z, 1);
		this.posData[numUsedVerts + 1] = f32(tx, ty - th, z, 1);
		this.posData[numUsedVerts + 2] = f32(tx, ty, z, 1);
		this.colorData[numUsedVerts + 0] = clr.rgba;
		this.colorData[numUsedVerts + 1] = clr.rgba;
		this.colorData[numUsedVerts + 2] = clr.rgba;
		numUsedVerts += 3;
	}

	// Add line using pixel coordinates where origin is top-left of render target.
	void addLine(f32 x0, f32 y0, f32 x1, f32 y1, f32 thickness, f32 z, ColorRGBAf clr)
	{
		Vec2<f32> v0(x0, y0);
		Vec2<f32> v1(x1, y1);

		if(x0 > x1) // swap to keep order consistent for clockwise purposes
		{
			v0.set(x1, y1);
			v1.set(x0, y0);
		}

		Vec2<f32> dir = v1 - v0; // we know dir.x is positive (or zero) which is useful for generating clockwise triangles
		dir.normalize();

		Vec2<f32> perpDir(dir); 
		perpDir.perpendicular(); // now we know dir.y is positive (or zero) which is useful for generating clockwise triangles

		// left points
		Vec2<f32> p0 = v0 + (perpDir * (thickness * -0.5f));  // low-y (top screen)
		Vec2<f32> p1 = v0 + (perpDir * (thickness * 0.5f)); // high-y

		// right points
		Vec2<f32> p2 = v1 + (perpDir * (thickness * -0.5f));  // low-y (top screen)
		Vec2<f32> p3 = v1 + (perpDir * (thickness * 0.5f)); // high-y

		// point order important - needs to be clockwise in screen space
		addTriangle(p1[0], p1[1], p0[0], p0[1], p2[0], p2[1], z, clr);
		addTriangle(p2[0], p2[1], p3[0], p3[1], p1[0], p1[1], z, clr);
	}

	// Render all currently set shapes.
	void render()
	{
		if(numUsedVerts == 0)
			return;

		updateBuffers();

		transformMatrix.setToIdentity();
		for(u8 e=0; e<16; e++)
			vs.matrix[e] = transformMatrix.m[e];

		rt.renderTriangles(gpuProgram, 0, numUsedVerts);
	}
}