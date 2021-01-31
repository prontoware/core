////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

// Test transpiling Pronto code to GLSL etc.

// Tests pretty much everything is transpiled. We use the OpenGL reference validation compiler to manually confirm conformance of GLSL output.
class SHADERTESTSVertexShader implements IVertexShader
{
	// Constants
	const bool CONST_BOOL    = false;
	const f32  CONST_FLOAT   = 2.0f;
	const i32  CONST_INTEGER = 99;

	// Uniforms
	Mat2f matrix2x2;
	Mat3f matrix3x3;
	Mat4f matrix4x4;

	// Vertex attributes
	VertexBuffer posBuf;
	VertexBuffer uvBuf;
	VertexBuffer weightsBuf;

	void run(Shader s)
	{
		// scalar primitives
		bool localBool   = false;
		f32 localFloat   = 10.0f * CONST_FLOAT;
		i32 localInteger = 1 + CONST_INTEGER;

		// vectors
		Vec2b b2 = Vec2b(true, false);
		Vec3b b3 = Vec3b(true, false, false);
		Vec4b b4 = Vec4b(true, false, false, true);

		Vec2i i2 = Vec2i(1, 2);
		Vec3i i3 = Vec3i(3, 4, 5);
		Vec4i i4 = Vec4i(6, 7, 8, 9);

		Vec2f f2 = Vec2f(1, 2);
		Vec3f f3 = Vec3f(3, 4, 5);
		Vec4f f4 = Vec4f(6, 7, 8, 9);

		Vec2f res2f = f2 * Vec2f(0, 0);
		Vec3f res3f = f3 - Vec3f(1, 1, 1);
		Vec4f res4f = f4 * Vec4f(2, 3, 4, 5);

		f32 resScalar = res4f.x + res3f[0];

		// matrices
		Mat2f m2x2 = Mat2f(1, 0, 1, 0);
		Mat3f m3x3 = Mat3f(1, 0, 0, 0, 1, 0, 0, 0, 1);
		Mat4f m4x4 = Mat4f(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);

		m2x2 = m2x2 * Mat2f(1, 0, 1, 0);
		m3x3 = m3x3 * Mat3f(1, 0, 0, 0, 1, 0, 0, 0, 1);
		m4x4 = m4x4 * Mat4f(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);

		res2f = Vec2f(0.0f, 0.0f) * m2x2;
		res2f = m2x2 * Vec2f(0.0f, 0.0f);
		res3f = Vec3f(0.0f, 0.0f, 1.0f) * m3x3;
		res3f = m3x3 * Vec3f(0.0f, 0.0f, 1.0f);
		res4f = Vec4f(0.0f, 0.0f, 2.0f, 2.0f) * m4x4;
		res4f = m4x4 * Vec4f(0.0f, 0.0f, 2.0f, 2.0f);

		// vertex attributes
		Vec2f vertexUV   = s.vsInputVertex2f(uvBuf);
		Vec4f vertexPos  = s.vsInputVertex4f(posBuf);
		f32 vertexWeight = s.vsInputVertex1f(weightsBuf);

		// matrix * vector
		Vec4f transformedPos = matrix4x4 * vertexPos;

		// Most of the special functions
		f32 tempF = 0.0f;
		tempF = s.sin(1.0f);
		tempF = s.cos(1.0f);
		tempF = s.tan(1.0f);
		tempF = s.asin(1.0f);
		tempF = s.acos(1.0f);
		tempF = s.atan(1.0f);
		tempF = s.pow(2.0f, 2.0f);
		tempF = s.exp(2.0f);
		tempF = s.exp2(2.0f);
		tempF = s.log(2.0f);
		tempF = s.sqrt(4.0f);
		tempF = s.invSqrt(4.0f);
		tempF = s.abs(-1.0f);
		tempF = s.floor(1.1f);
		tempF = s.ceil(1.4f);
		tempF = s.radians(180.0f);
		tempF = s.degrees(3.14f);
		tempF = s.min(1.0f, 2.0f);
		tempF = s.max(2.0f, 3.0f);
		tempF = s.clamp(2.0f, 0.0f, 1.0f);
		tempF = s.dot(Vec2f(0.0, 1.0), Vec2f(2.0, 3.0));
		tempF = s.dot(Vec3f(0.0, 1.0, 2.0), Vec3f(2.0, 3.0, 4.0));
		tempF = s.dot(Vec4f(0.0, 1.0, 2.0, 3.0), Vec4f(2.0, 3.0, 4.0, 5.0));
		res3f = s.cross(Vec3f(0.0, 1.0, 2.0), Vec3f(2.0, 3.0, 4.0));
		res2f = s.normalize(Vec2f(0, 1));
		res3f = s.normalize(Vec3f(0, 1, 2));
		res4f = s.normalize(Vec4f(0, 1, 2, 3));
		tempF = s.length(Vec2f(0, 1));
		tempF = s.length(Vec3f(0, 1, 2));
		tempF = s.length(Vec4f(0, 1, 2, 3));
		res2f = s.reflect(Vec2f(0, 1), Vec2f(1, 1));
		res3f = s.reflect(Vec3f(0, 1, 2), Vec3f(1, 1, 2));
		res2f = s.refract(Vec2f(0, 1), Vec2f(1, 1), 1.1f);
		res3f = s.refract(Vec3f(0, 1, 2), Vec3f(1, 1, 2), 0.1f);
		res2f = s.step(Vec2f(0, 1), Vec2f(1, 1));
		res3f = s.step(Vec3f(0, 1, 2), Vec3f(1, 1, 2));
		res4f = s.step(Vec4f(0, 1, 2, 4), Vec4f(1, 1, 2, 3));
		res2f = s.smoothStep(Vec2f(0, 1), Vec2f(1, 1), Vec2f(1, 1));
		res3f = s.smoothStep(Vec3f(0, 1, 2), Vec3f(1, 1, 2), Vec3f(1, 1, 1));
		res4f = s.smoothStep(Vec4f(0, 1, 2, 3), Vec4f(1, 1, 2, 3), Vec4f(1, 1, 2, 2));

		// boolean operators
		b2 = s.lessThan(Vec2i(0, 1), Vec2i(2, 2));
		b2 = s.lessThan(Vec2f(0, 1), Vec2f(2, 2));
		b3 = s.lessThan(Vec3i(0, 1, 3), Vec3i(2, 2, 2));
		b3 = s.lessThan(Vec3f(0, 1, 3), Vec3f(2, 2, 2));
		b4 = s.lessThan(Vec4i(0, 1, 3, 4), Vec4i(2, 2, 2, 4));
		b4 = s.lessThan(Vec4f(0, 1, 3, 4), Vec4f(2, 2, 2, 4));

		b2 = s.lessThanEqual(Vec2i(0, 1), Vec2i(2, 2));
		b2 = s.lessThanEqual(Vec2f(0, 1), Vec2f(2, 2));
		b3 = s.lessThanEqual(Vec3i(0, 1, 3), Vec3i(2, 2, 2));
		b3 = s.lessThanEqual(Vec3f(0, 1, 3), Vec3f(2, 2, 2));
		b4 = s.lessThanEqual(Vec4i(0, 1, 3, 4), Vec4i(2, 2, 2, 4));
		b4 = s.lessThanEqual(Vec4f(0, 1, 3, 4), Vec4f(2, 2, 2, 4));

		b2 = s.moreThan(Vec2i(0, 1), Vec2i(2, 2));
		b2 = s.moreThan(Vec2f(0, 1), Vec2f(2, 2));
		b3 = s.moreThan(Vec3i(0, 1, 3), Vec3i(2, 2, 2));
		b3 = s.moreThan(Vec3f(0, 1, 3), Vec3f(2, 2, 2));
		b4 = s.moreThan(Vec4i(0, 1, 3, 4), Vec4i(2, 2, 2, 4));
		b4 = s.moreThan(Vec4f(0, 1, 3, 4), Vec4f(2, 2, 2, 4));

		b2 = s.moreThanEqual(Vec2i(0, 1), Vec2i(2, 2));
		b2 = s.moreThanEqual(Vec2f(0, 1), Vec2f(2, 2));
		b3 = s.moreThanEqual(Vec3i(0, 1, 3), Vec3i(2, 2, 2));
		b3 = s.moreThanEqual(Vec3f(0, 1, 3), Vec3f(2, 2, 2));
		b4 = s.moreThanEqual(Vec4i(0, 1, 3, 4), Vec4i(2, 2, 2, 4));
		b4 = s.moreThanEqual(Vec4f(0, 1, 3, 4), Vec4f(2, 2, 2, 4));

		b2 = s.equal(Vec2i(0, 1), Vec2i(2, 2));
		b2 = s.equal(Vec2f(0, 1), Vec2f(2, 2));
		b3 = s.equal(Vec3i(0, 1, 3), Vec3i(2, 2, 2));
		b3 = s.equal(Vec3f(0, 1, 3), Vec3f(2, 2, 2));
		b4 = s.equal(Vec4i(0, 1, 3, 4), Vec4i(2, 2, 2, 4));
		b4 = s.equal(Vec4f(0, 1, 3, 4), Vec4f(2, 2, 2, 4));

		b2 = s.notEqual(Vec2i(0, 1), Vec2i(2, 2));
		b2 = s.notEqual(Vec2f(0, 1), Vec2f(2, 2));
		b3 = s.notEqual(Vec3i(0, 1, 3), Vec3i(2, 2, 2));
		b3 = s.notEqual(Vec3f(0, 1, 3), Vec3f(2, 2, 2));
		b4 = s.notEqual(Vec4i(0, 1, 3, 4), Vec4i(2, 2, 2, 4));
		b4 = s.notEqual(Vec4f(0, 1, 3, 4), Vec4f(2, 2, 2, 4));

		bool yes = false;
		yes = s.any(b2);
		yes = s.any(b3);
		yes = s.any(b4);
		yes = s.all(b2);
		yes = s.all(b3);
		yes = s.all(b4);

		b2 = s.not(b2);
		b3 = s.not(b3);
		b4 = s.not(b4);

		// if statement
		Vec2f uvMod = vertexUV;
		if(yes == true)
		{
			uvMod = Vec2f(0, 0);
		}

		// for loop - must be compile-time determinate conditional expression
		for(i32 counter=0; counter<4; counter++)
		{
			uvMod = uvMod + Vec2f(0.1f, 0.1f);
		}

		// outputs (varyings)
		s.vsOutputPosition(transformedPos);
		s.vsOutputVarying2f(0, uvMod);
	}
}

// Test things unique to pixel shader vs to vertex shader.
class SHADERTESTSPixelShader implements IPixelShader
{
	// Constants
	const f32 BRIGHTNESS = 1.0f;

	// Uniforms
	Texture2D   colorTex;
	TextureCube envTex;

	void run(Shader s)
	{
		Vec2f vertexUV  = s.psInputVarying2f(0);
		Vec4f texColor  = s.psSampleTex2D(colorTex, vertexUV);
		Vec4f texColor2 = s.psSampleTex2D(colorTex, vertexUV);
		Vec4f envColor  = s.psSampleTexCube(envTex, Vec3f(vertexUV, 0.0f));

		Vec4f frameBufferPos = s.psGetFramePixelPos();

		s.psOutput(0, texColor + texColor2);
	}
}

class ShaderTests implements IUnitTest
{
	void run()
	{
		if(System:isGraphicalOS() == false)
		{
			//Log:log(String<u8>("ShaderTests - Cannot run tests, OS is not graphical or using headless mode."));
			return; // can't test
		}

		if(System:isGPUAvailable() == false)
		{
			//Log:log(String<u8>("ShaderTests - Cannot run tests, OS is not GPU 3D accelerated."));
			return; // can't test
		}

		testVertexShaderToOpenGL_3_3();
		testVertexShaderToOpenGLES_2_0();
		testPixelShaderToOpenGL_3_3();
		testPixelShaderToOpenGLES_2_0();
	}

	void testVertexShaderToOpenGL_3_3()
	{
		String<u8> errorsOut(8192);
		String<u8> vsSrc = GPU:compileVertexShaderToSource(SHADERTESTSVertexShader(), GPU:API_OPENGL_CR_3_3, errorsOut);
		if(errorsOut.length() > 0)
		{
			vsSrc.append("\n\n\nErrors\n\n");
			vsSrc.append(errorsOut);

			FileSystem:writeTextFile(String<u8>("SHADERTESTSVertexShaderGL_3_3.txt"), vsSrc);

			test(false);
		}

		//FileSystem:writeTextFile(String<u8>("vs.vert"), vsSrc); // comment out except for testing
	}

	void testVertexShaderToOpenGLES_2_0()
	{
		String<u8> errorsOut(8192);
		String<u8> vsSrc = GPU:compileVertexShaderToSource(SHADERTESTSVertexShader(), GPU:API_OPENGL_ES_2_0, errorsOut);
		if(errorsOut.length() > 0)
		{
			vsSrc.append("\n\n\nErrors\n\n");
			vsSrc.append(errorsOut);

			FileSystem:writeTextFile(String<u8>("SHADERTESTSVertexShaderES_2_0.txt"), vsSrc);

			test(false);
		}

		//FileSystem:writeTextFile(String<u8>("vses.vert"), vsSrc); // comment out except for testing
	}

	void testPixelShaderToOpenGL_3_3()
	{
		String<u8> errorsOut(8192);
		String<u8> psSrc = GPU:compilePixelShaderToSource(SHADERTESTSPixelShader(), GPU:API_OPENGL_CR_3_3, true, errorsOut);
		if(errorsOut.length() > 0)
		{
			psSrc.append("\n\n\nErrors\n\n");
			psSrc.append(errorsOut);

			FileSystem:writeTextFile(String<u8>("SHADERTESTSPixelShaderGL_3_3.txt"), psSrc);

			test(false);
		}

		//FileSystem:writeTextFile(String<u8>("ps.frag"), psSrc); // comment out except for testing
	}

	void testPixelShaderToOpenGLES_2_0()
	{
		String<u8> errorsOut(8192);
		String<u8> psSrc = GPU:compilePixelShaderToSource(SHADERTESTSPixelShader(), GPU:API_OPENGL_ES_2_0, true, errorsOut);
		if(errorsOut.length() > 0)
		{
			psSrc.append("\n\n\nErrors\n\n");
			psSrc.append(errorsOut);

			FileSystem:writeTextFile(String<u8>("SHADERTESTSPixelShaderES_2_0.txt"), psSrc);

			test(false);
		}

		//FileSystem:writeTextFile(String<u8>("pses.frag"), psSrc); // comment out except for testing
	}
}