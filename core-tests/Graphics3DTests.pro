////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// GTEST_VSPosUV
////////////////////////////////////////////////////////////////////////////////////////////////////

// Transform one Vec4f vertex by one matrix. Includes one Vec2f uv coordinate varying.
class GTEST_VSPosUV implements IVertexShader
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

////////////////////////////////////////////////////////////////////////////////////////////////////
// GTEST_ColorTexturePS
////////////////////////////////////////////////////////////////////////////////////////////////////

// Single-textured.
class GTEST_PSTextured implements IPixelShader
{
	// Uniforms
	Texture2D colorTex;

	void run(Shader s)
	{
		Vec2f vertexUV = s.psInputVarying2f(0);
		Vec4f texColor = s.psSampleTex2D(colorTex, vertexUV);

		s.psOutput(0, texColor);
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// GTEST_SpriteRenderer
////////////////////////////////////////////////////////////////////////////////////////////////////

// Render textured quad.
class GTEST_SpriteRenderer
{
	// Shader
	GTEST_VSPosUV    vs();
	GTEST_PSTextured ps();
	GPUProgram gpuProgram;

	Matrix4x4<f32> tempMatrix();
	Matrix4x4<f32> transformMatrix();

	// Create shader etc.
	void constructor()
	{
		GPUProgramSettings gpuSettings();
		gpuSettings.depthTestEnabled = true;
		gpuSettings.depthTestFunc    = GPUProgramSettings:CMP_FUNC_LESS; // CMP_FUNC_LESS is default
		gpuSettings.cullTriMode      = GPUProgramSettings:CULL_CCW; // CCW is default

		gpuProgram = GPUProgram();
		if(gpuProgram.create(gpuSettings, vs, ps) == false)
		{
			test(false);

			//Log:log("Failed to compile GTEST_SpriteRenderer shader program with error(s):\n");
			//Log:log(gpuProgram.getCompileErrors());
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
		vs.posBuf = VertexBuffer(Type:F32, verts.length() * 16, true); // testing frequent updates (dynamic memory) flag as third param.
		vs.posBuf.setData(verts);
		
		f32[] uvs(6 * 2);
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
	}

	// Destroy
	void destroy()
	{
		gpuProgram.destroy();
		gpuProgram = null;
	}

	// Render a sprite at x/y. Position and size in normalized coordinates (-0.5 to 0.5).
	void render(IRenderTarget3D rt, Texture2D tex, f32 x, f32 y, f32 width, f32 height)
	{
		ps.colorTex = tex;

		f32 rtWidth     = rt.getWidth();
		f32 rtHeight    = rt.getHeight();
		f32 aspectRatio = rtWidth / rtHeight;

		transformMatrix.setToIdentity();

		tempMatrix.setAsScaleMatrix(Vec3<f32>(width / aspectRatio, height, 0));
		transformMatrix.mul(tempMatrix);

		tempMatrix.setAsTranslationMatrix(Vec3<f32>(x / aspectRatio, y, 0));
		transformMatrix.mul(tempMatrix);

		for(u8 e=0; e<16; e++)
			vs.matrix[e] = transformMatrix.m[e];

		rt.renderTriangles(gpuProgram, 0, 6); // six vertices = two triangles
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Graphics3DTests
////////////////////////////////////////////////////////////////////////////////////////////////////

// Tests GPU API. Tests do not run on systems that do not have a graphical OS + GPU accleration.
class Graphics3DTests implements IUnitTest
{
	// for all tests
	NativeWindow    window = null;
	IRenderTarget3D rt3D   = null;

	void run()
	{
		if(System:isGraphicalOS() == false)
		{
			//Log:log(String<u8>("Graphics3DTests - Cannot run tests, OS is not graphical or using headless mode."));
			return; // can't test
		}

		if(System:isGPUAvailable() == false)
		{
			//Log:log(String<u8>("Graphics3DTests - Cannot run tests, OS is not GPU 3D accelerated."));
			return; // can't test
		}

		//window = NativeWindow:getDefaultWindow(true, ColorFormat:RGBA8);
		window = NativeWindow:createWindow(true, ColorFormat:RGBA8, Rectangle2D<i32>(0, 0, 512, 512), false, true);
		IRenderTarget2D rt = window.getRenderTarget();
		if(rt.implements(String<u8>("IRenderTarget3D")) == false)
		{
			//Log:log(String<u8>("Graphics3DTests - Cannot run tests, render target from window is not 3D capable."));
			return; // can't test
		}

		rt3D = rt;

		testGPU();
		testVertexBuffer();
		testIndexBuffer();
		testTexture2D();
		testClearRT();
		testRenderSprite();
		testRenderText();
		testRenderShape();
		testRenderLines();

		window.setVisible(false);
		window.destroy();
	}

	void testGPU()
	{
		test(GPU:isTextureFormatUsable(ColorFormat:RGBA4) == true);
		test(GPU:isTextureFormatUsable(ColorFormat:RGB5A1) == true);
	}

	void testVertexBuffer()
	{
		f32[4][] verts(3); // 12 floats, 3 vertices, a triangle.
		verts[0] = f32(0, 1, 0, 1);
		verts[1] = f32(1, 1, 0, 1);
		verts[2] = f32(1, 0, 0, 1);
		VertexBuffer vb(verts);
		test(vb.getSize() == 48); // size in bytes
		test(vb.isValid() == true);
	}

	void testIndexBuffer()
	{
		u16[] indices(3);
		indices[0] = 0;
		indices[1] = 1;
		indices[2] = 2;
		IndexBuffer ib(indices);
		test(ib.getSize() == 6); // size in bytes
		test(ib.isValid() == true);
	}

	void testTexture2D()
	{
		ColorRGBA clr(10, 20, 30, 255);
		ImageRGBA img(128, 64, clr);
		Texture2D tex(img);
		test(tex.isValid() == true);
		test(tex.getWidth() == 128);
		test(tex.getHeight() == 64);
		test(tex.getColorFormat() == ColorFormat:RGBA8);

		//FileSystem:writeFile(String<u8>("img2D.png"), img.encodePNG()); // manual inspection if needed

		// retrieve image from GPU
		UniversalImage uniImg = tex.readImage(0);
		ImageRGBA img2(uniImg);
		//FileSystem:writeFile(String<u8>("tex2D.png"), img2.encodePNG()); // manual inspection if needed

		test(img2.getWidth() == 128);
		test(img2.getHeight() == 64);
		test(img2.getColorFormat() == ColorFormat:RGBA8);
	}

	void testClearRT()
	{
		// black
		rt3D.beginFrame();
		rt3D.clear(0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0); // black

		// have to read image before endFrame() because we can't read front buffer, only back buffer
		UniversalImage uniImg = rt3D.getImage();
		test(uniImg != null);
		test(uniImg.getWidth() >= 1 && uniImg.getHeight() >= 1);
		test(uniImg.pixels[0] == 0);
		test(uniImg.pixels[1] == 0);

		rt3D.endFrame();

		// red
		rt3D.beginFrame();
		rt3D.clear(1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0); // red

		// have to read image before endFrame() because we can't read front buffer, only back buffer
		uniImg = rt3D.getImage();
		test(uniImg != null);
		test(uniImg.getWidth() >= 1 && uniImg.getHeight() >= 1);
		test(uniImg.pixels[0] == 255);

		rt3D.endFrame();
	}

	void testRenderSprite()
	{
		ImageRGBA img(128, 128, ColorRGBA(255, 0, 0, 255));
		Texture2D tex(img);
		test(tex.isValid() == true);

		GTEST_SpriteRenderer spriteRenderer();
		
		rt3D.beginFrame();
		rt3D.clear(0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0); // black
		spriteRenderer.render(rt3D, tex, -10, -10, 20, 20); // 20x the size of the normalized area to make sure sprite covers everything regardless of aspect ratio
		
		// have to read image before endFrame() because we can't read front buffer, only back buffer
		UniversalImage uniImg = rt3D.getImage();
		test(uniImg != null);
		test(uniImg.getWidth() == rt3D.getWidth() && uniImg.getHeight() == rt3D.getHeight());
		test(uniImg.pixels[0] == 255);
		test(uniImg.pixels[1] == 0);

		rt3D.endFrame();
	}

	void testRenderText()
	{
		Font font("Times New Roman", 32, true);
		test(font.fontImg != null);

		FontTextRenderer txtRenderer(rt3D, font, 1024);

		rt3D.beginFrame();
		rt3D.clear(0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0); // black, fully opaque

		f32 nextX = txtRenderer.addString("Hello ", 0, 0, 1000, 1000, 0.1f, ColorRGBAf(1.0f, 1.0f, 1.0f, 1.0f));
		txtRenderer.addString("world!", nextX, 32, 1000, 1000, 0.1f, ColorRGBAf(0.0f, 1.0f, 0.0f, 1.0f));

		txtRenderer.render();

		// have to read image before endFrame() because we can't read front buffer, only back buffer
		ImageRGBA img = rt3D.getImageRGBA();

		test(img != null);

		img.clearChannel(ColorRGBA:CHANNEL_ALPHA, 255);

		//if(FileSystem:writeFile("TestRenderText.png", img.encodePNG()) == false)

		rt3D.endFrame();
	}

	void testRenderShape()
	{
		ShapeRenderer shapeRenderer(rt3D, 8192);
		
		rt3D.beginFrame();
		rt3D.clear(0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0); // black, fully opaque

		shapeRenderer.addRectangle(0, 0, 100, 100, 0.2, ColorRGBAf(0.0f, 0.0f, 1.0f, 1.0f));
		shapeRenderer.addRectangle(10, 10, 10, 10, 0.1, ColorRGBAf(0.0f, 1.0f, 0.0f, 1.0f));

		shapeRenderer.render();

		// have to read image before endFrame() because we can't read front buffer, only back buffer
		ImageRGBA img = rt3D.getImageRGBA();
		test(img != null);

		//img.clearChannel(ColorRGBA:CHANNEL_ALPHA, 255);
		//if(FileSystem:writeFile("testRenderShape.png", img.encodePNG()) == false)

		test(img.testPixel(0, 0, 0, 0, 255, 255) == true); // 1st rect top-left
		test(img.testPixel(10, 10, 0, 255, 0, 255) == true); // 2nd rect top-left
		test(img.testPixel(19, 19, 0, 255, 0, 255) == true); // 2nd rect bottom-right
		test(img.testPixel(20, 20, 0, 0, 255, 255) == true); // 1st rect after bottom-right of 2nd rect

		rt3D.endFrame();
	}

	void testRenderLines()
	{
		// lines
		rt3D.beginFrame();
		rt3D.clear(1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 0); // white, fully opaque

		Line2D<i32> lineA(0, 0, 100, 100);
		rt3D.drawLine(lineA, 1, ColorRGBA(0,0,0,255));

		Line2D<i32> lineB(10, 0, 10, 100);
		rt3D.drawLine(lineB, 4, ColorRGBA(255,0,0,255));

		Line2D<i32> lineC(100, 0, 0, 100);
		rt3D.drawLine(lineC, 4, ColorRGBA(0,255,0,255));

		Line2D<i32> lineD(0, 50, 100, 50);
		rt3D.drawLine(lineD, 4, ColorRGBA(0,0,255,255));

		ImageRGBA imgA = rt3D.getImageRGBA(); // have to get before swap, because we can't read front buffer, only back buffer

		rt3D.endFrame();

		test(imgA != null);

		//FileSystem:writeFile(String<u8>("RT3D_drawLine.png"), imgA.encodePNG());

		test(imgA.testPixel(0, 0, 0, 0, 0, 255) == true);
		test(imgA.testPixel(2, 2, 0, 0, 0, 255) == true);
		test(imgA.testPixel(99, 99, 0, 0, 0, 255) == true);
		test(imgA.testPixel(10, 20, 255, 0, 0, 255) == true);
		test(imgA.testPixel(11, 20, 255, 0, 0, 255) == true);
		test(imgA.testPixel(0, 50, 0, 0, 255, 255) == true);
	}
}