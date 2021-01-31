////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class MathRandomFastTests implements IUnitTest
{
	void run()
	{
		RandomFast r(0);

		// i32
		i32 a = r.getI32(1, 8192);
		test(a >= 1 && a <= 8192);

		i32 b = r.getI32(1, 8192);
		test(b >= 1 && b <= 8192);

		i32 c = r.getI32(1, 8192);
		test(c >= 1 && c <= 8192);

		test(a != b && b != c);

		// i64, including negatives
		bool foundNeg = false;
		bool foundOutsideI32 = false;
		for(u32 g=0; g<10000; g++)
		{
			i64 min = i64(Math:U32_MAX) * -2;
			i64 max = i64(Math:U32_MAX) * 2;

			i64 d = r.getI64(min, max);
			if(d < 0)
				foundNeg = true;

			if(d < Math:I32_MIN || d > Math:I32_MAX)
				foundOutsideI32 = true;

			test(d >= min && d <= max);
		}
		
		test(foundNeg == true);
		test(foundOutsideI32 == true);

		// floating-point number
		bool foundF = false;
		for(u32 q=0; q<1000; q++)
		{
			f32 fa = r.getF64(0.0, 1.0);
			test(fa >= 0.0 && fa <= 1.0);

			f32 fb = r.getF64(-1000.0, 1000.0);
			test(fb >= -1000.0 && fb <= 1000.0);

			if(fb < -1.0 || fb > 1.0)
				foundF = true;
		}

		test(foundF == true);
	}
}

class MathMinMaxTests implements IUnitTest
{
	void run()
	{
		test(Math:minMax(0, 10, 11) == 10);
		test(Math:minMax(10, 20, 9) == 10);
	}
}

class MathWrapTests implements IUnitTest
{
	void run()
	{
		test(Math:wrap(0, 10, 11) == 0);
		test(Math:wrap(0, 10, -1) == 10);
		test(Math:wrap(0, 10, -2) == 9);
		test(Math:wrap(0, 10, -9) == 2);
		test(Math:wrap(0, 10, -11) == 0);
		test(Math:wrap(0, 10, -12) == 10);
	}
}

class MathPowTests implements IUnitTest
{
	void run()
	{
		u64 powTwo = 1024;
		test(Math:isPowerOfTwo(powTwo) == true);
		test(Math:isPowerOfTwo(powTwo-1) == false);

		u64 base3 = 3 * 3 * 3;
		test(Math:isPowerOf(base3, 3) == true);
		test(Math:isPowerOf(base3, 4) == false);
	}
}

class MathVec2Tests implements IUnitTest
{
	void run()
	{
		Vec2<f32> a = Vec2<f32>(1.0f, 2.0f);
		test(Math:compare(a.p[0], 1.0f) == true && Math:compare(a.p[1], 2.0f) == true);

		Vec2<f32> b = Vec2<f32>(2.0f, 2.0f);
		a += b;
		test(Math:compare(a.p[0], 3.0f) == true && Math:compare(a.p[1], 4.0f) == true);

		b.set(1.0f, 5.0f);
		b *= 10.0f;
		test(Math:compare(b.p[0], 10.0f) == true && Math:compare(b.p[1], 50.0f) == true);
	}
}

class MathVec3Tests implements IUnitTest
{
	void run()
	{
		Vec3<f32> a = Vec3<f32>(1.0f, 2.0f, 3.0f);
		test(Math:compare(a.p[0], 1.0f) == true && Math:compare(a.p[1], 2.0f) == true && Math:compare(a.p[2], 3.0f) == true);

		Vec3<f32> b = Vec3<f32>(2.0f, 2.0f, 7.0f);
		a += b;
		test(Math:compare(a.p[0], 3.0f) == true && Math:compare(a.p[1], 4.0f) == true && Math:compare(a.p[2], 10.0f) == true);

		b.set(1.0f, 5.0f, 10.0f);
		b *= 10.0f;
		test(Math:compare(b.p[0], 10.0f) == true && Math:compare(b.p[1], 50.0f) == true && Math:compare(b.p[2], 100.0f) == true);
	}
}

class MathVec4Tests implements IUnitTest
{
	void run()
	{
		Vec4<f32> a = Vec4<f32>(1.0f, 2.0f, 3.0f, 1.0f);
		test(Math:compare(a.p[0], 1.0f) == true && Math:compare(a.p[1], 2.0f) == true && Math:compare(a.p[2], 3.0f) == true);

		Vec4<f32> b = Vec4<f32>(2.0f, 2.0f, 7.0f, 1.0f);
		a += b;
		test(Math:compare(a.p[0], 3.0f) == true && Math:compare(a.p[1], 4.0f) == true && Math:compare(a.p[2], 10.0f) == true);

		b.set(1.0f, 5.0f, 10.0f, 1.0f);
		b *= 10.0f;
		test(Math:compare(b.p[0], 10.0f) == true && Math:compare(b.p[1], 50.0f) == true && Math:compare(b.p[2], 100.0f) == true);
	}
}

class MathMatrix4x4Tests implements IUnitTest
{
	void run()
	{
		// Setup
		Vec4<f32> v1     = Vec4<f32>(1.0, 1.0, 1.0, 1.0);
		Vec4<f32> result = Vec4<f32>();

		// Identity matrix by default
		Matrix4x4<f32> iMatrix = Matrix4x4<f32>();
		test(Math:compare(iMatrix.m[0], 1.0) == true && Math:compare(iMatrix.m[5], 1.0) == true && Math:compare(iMatrix.m[10], 1.0) == true && Math:compare(iMatrix.m[15], 1.0) == true);
		test(Math:compare(iMatrix.m[1], 0.0) == true); // everything else 0

		// Translation matrix
		Matrix4x4<f32> translateMatrix = Matrix4x4<f32>();
		translateMatrix.setAsTranslationMatrix(Vec3<f32>(1, 2, 3));
		translateMatrix.mul(v1, result);
		test(result.compare(Vec3<f32>(2, 3, 4)) == true);

		// Scale matrix
		Matrix4x4<f32> scaleMatrix = Matrix4x4<f32>();
		scaleMatrix.setAsScaleMatrix(Vec3<f32>(2, 3, 4));
		scaleMatrix.mul(v1, result);
		test(result.compare(Vec3<f32>(2, 3, 4)) == true);

		// Rotate around arbitrary axis matrix
		v1.set(1.0, 0, 0, 1.0);
		Matrix4x4<f32> rotateMatrix = Matrix4x4<f32>();
		rotateMatrix.setAsRotationMatrix(Vec3<f32>(0.0f, 0.0f, 1.0f), Math:PI * -0.25f);
		rotateMatrix.mul(v1, result);
		test(result.compare(Vec3<f32>(0.7071f, 0.7071f, 0), 0.01f) == true);

		// left hand look at
		v1 = Vec4<f32>(1.0, 0, 0, 1.0);
		Matrix4x4<f32> lookAtMatrix = Matrix4x4<f32>();
		lookAtMatrix.setAsLeftHandedLookAtMatrix(Vec3<f32>(0,0,1), Vec3<f32>(0,0,0), Vec3<f32>(0,1,0));
		lookAtMatrix.mul(v1, result);
		// TODO test
	}
}