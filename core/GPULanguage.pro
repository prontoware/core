////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Vec2f
////////////////////////////////////////////////////////////////////////////////////////////////////

// Shader primitive boolean vector. This is a stand-in representation, some functions/methods are
// not implemented.
class Vec2b
{
	bool x;
	bool y;

	void constructor()
	{
		this.x = false;
		this.y = false;
	}

	void constructor(bool x, bool y)
	{
		this.x = x;
		this.y = y;
	}

	void constructor(Vec2b v)
	{
		this.x = v.x;
		this.y = v.y;
	}

	// Overload [] operator
	bool get(u64 index)
	{
		if(index == 0)
			return x;
		else if(index == 1)
			return y;

		return false;
	}

	// Overload [] operator
	void set(u64 index, bool val)
	{
		if(index == 0)
			x = val;
		else if(index == 1)
			y = val;
	}

	// Overload +
	Vec2b add(Vec2b v)
	{
		return Vec2b(this.x + v.x, this.y + v.y);
	}

	// Overload -
	Vec2b subtract(Vec2b v)
	{
		return Vec2b(this.x - v.x, this.y - v.y);
	}

	// Overload *
	Vec2b multiply(Vec2b v)
	{
		return Vec2b(this.x * v.x, this.y * v.y);
	}

	// Overload /
	Vec2b divide(Vec2b v)
	{
		return Vec2b(this.x / v.x, this.y / v.y);
	}
}

// Shader primitive floating-point vector. This is a stand-in representation, some functions/methods are
// not implemented.
class Vec2f
{
	f32 x;
	f32 y;

	void constructor()
	{
		this.x = 0.0f;
		this.y = 0.0f;
	}

	void constructor(f32 x, f32 y)
	{
		this.x = x;
		this.y = y;
	}

	void constructor(Vec2f v)
	{
		this.x = v.x;
		this.y = v.y;
	}

	// Overload [] operator
	f32 get(u64 index)
	{
		if(index == 0)
			return x;
		else if(index == 1)
			return y;

		return 0;
	}

	// Overload [] operator
	void set(u64 index, f32 val)
	{
		if(index == 0)
			x = val;
		else if(index == 1)
			y = val;
	}

	// Overload + scalar
	Vec2f add(f32 v)
	{
		return Vec2f(this.x + v, this.y + v);
	}

	// Overload - scalar
	Vec2f subtract(f32 v)
	{
		return Vec2f(this.x - v, this.y - v);
	}

	// Overload * scalar
	Vec2f multiply(f32 v)
	{
		return Vec2f(this.x * v, this.y * v);
	}

	// Overload / scalar
	Vec2f divide(f32 v)
	{
		return Vec2f(this.x / v, this.y / v);
	}

	// Overload +
	Vec2f add(Vec2f v)
	{
		return Vec2f(this.x + v.x, this.y + v.y);
	}

	// Overload -
	Vec2f subtract(Vec2f v)
	{
		return Vec2f(this.x - v.x, this.y - v.y);
	}

	// Overload *
	Vec2f multiply(Vec2f v)
	{
		return Vec2f(this.x * v.x, this.y * v.y);
	}

	// Overload * matrix
	Vec2f multiply(Mat2f m)
	{
		return Vec2f(); // TODO
	}

	// Overload /
	Vec2f divide(Vec2f v)
	{
		return Vec2f(this.x / v.x, this.y / v.y);
	}
}

// Shader primitive integer vector. This is a stand-in representation, some functions/methods are
// not implemented.
class Vec2i
{
	i32 x;
	i32 y;

	void constructor()
	{
		this.x = 0;
		this.y = 0;
	}

	void constructor(i32 x, i32 y)
	{
		this.x = x;
		this.y = y;
	}

	void constructor(Vec2i v)
	{
		this.x = v.x;
		this.y = v.y;
	}

	// Overload [] operator
	i32 get(u64 index)
	{
		if(index == 0)
			return x;
		else if(index == 1)
			return y;

		return 0;
	}

	// Overload [] operator
	void set(u64 index, i32 val)
	{
		if(index == 0)
			x = val;
		else if(index == 1)
			y = val;
	}

	// Overload + scalar
	Vec2i add(i32 v)
	{
		return Vec2i(this.x + v, this.y + v);
	}

	// Overload - scalar
	Vec2i subtract(i32 v)
	{
		return Vec2i(this.x - v, this.y - v);
	}

	// Overload * scalar
	Vec2i multiply(i32 v)
	{
		return Vec2i(this.x * v, this.y * v);
	}

	// Overload / scalar
	Vec2i divide(i32 v)
	{
		return Vec2i(this.x / v, this.y / v);
	}

	// Overload +
	Vec2i add(Vec2i v)
	{
		return Vec2i(this.x + v.x, this.y + v.y);
	}

	// Overload -
	Vec2i subtract(Vec2i v)
	{
		return Vec2i(this.x - v.x, this.y - v.y);
	}

	// Overload *
	Vec2i multiply(Vec2i v)
	{
		return Vec2i(this.x * v.x, this.y * v.y);
	}

	// Overload /
	Vec2i divide(Vec2i v)
	{
		return Vec2i(this.x / v.x, this.y / v.y);
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Vec3f
////////////////////////////////////////////////////////////////////////////////////////////////////

// Shader primitive boolean vector. This is a stand-in representation, some functions/methods are
// not implemented.
class Vec3b
{
	bool x;
	bool y;
	bool z;

	void constructor()
	{
		this.x = false;
		this.y = false;
		this.z = false;
	}

	void constructor(bool x, bool y, bool z)
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}

	void constructor(Vec2b v, bool z)
	{
		this.x = v.x;
		this.y = v.y;
		this.z = z;
	}

	void constructor(Vec3b v)
	{
		this.x = v.x;
		this.y = v.y;
		this.z = v.z;
	}

	// Overload [] operator
	bool get(u64 index)
	{
		if(index == 0)
			return x;
		else if(index == 1)
			return y;
		else if(index == 2)
			return z;

		return false;
	}

	// Overload [] operator
	void set(u64 index, bool val)
	{
		if(index == 0)
			x = val;
		else if(index == 1)
			y = val;
		else if(index == 2)
			z = val;
	}

	// Overload +
	Vec3b add(Vec3b v)
	{
		return Vec3b(this.x + v.x, this.y + v.y, this.z + v.z);
	}

	// Overload -
	Vec3b subtract(Vec3b v)
	{
		return Vec3b(this.x - v.x, this.y - v.y, this.z - v.z);
	}

	// Overload *
	Vec3b multiply(Vec3b v)
	{
		return Vec3b(this.x * v.x, this.y * v.y, this.z * v.z);
	}

	// Overload /
	Vec3b divide(Vec3b v)
	{
		return Vec3b(this.x / v.x, this.y / v.y, this.z / v.z);
	}
}

// Shader primitive floating-point vector.
class Vec3f
{
	f32 x;
	f32 y;
	f32 z;

	void constructor()
	{
		this.x = 0.0f;
		this.y = 0.0f;
		this.z = 0.0f;
	}

	void constructor(f32 x, f32 y, f32 z)
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}

	void constructor(Vec2f v, f32 z)
	{
		this.x = v.x;
		this.y = v.y;
		this.z = z;
	}

	void constructor(Vec3f v)
	{
		this.x = v.x;
		this.y = v.y;
		this.z = v.z;
	}

	// Overload [] operator
	f32 get(u64 index)
	{
		if(index == 0)
			return x;
		else if(index == 1)
			return y;
		else if(index == 2)
			return z;

		return 0;
	}

	// Overload [] operator
	void set(u64 index, f32 val)
	{
		if(index == 0)
			x = val;
		else if(index == 1)
			y = val;
		else if(index == 2)
			z = val;
	}

	// Overload + scalar
	Vec3f add(f32 v)
	{
		return Vec3f(this.x + v, this.y + v, this.z + v);
	}

	// Overload - scalar
	Vec3f subtract(f32 v)
	{
		return Vec3f(this.x - v, this.y - v, this.z - v);
	}

	// Overload * scalar
	Vec3f multiply(f32 v)
	{
		return Vec3f(this.x * v, this.y * v, this.z * v);
	}

	// Overload / scalar
	Vec3f divide(f32 v)
	{
		return Vec3f(this.x / v, this.y / v, this.z / v);
	}

	// Overload +
	Vec3f add(Vec3f v)
	{
		return Vec3f(this.x + v.x, this.y + v.y, this.z + v.z);
	}

	// Overload -
	Vec3f subtract(Vec3f v)
	{
		return Vec3f(this.x - v.x, this.y - v.y, this.z - v.z);
	}

	// Overload *
	Vec3f multiply(Vec3f v)
	{
		return Vec3f(this.x * v.x, this.y * v.y, this.z * v.z);
	}

	// Overload * matrix
	Vec3f multiply(Mat3f m)
	{
		return Vec3f(); // TODO
	}

	// Overload /
	Vec3f divide(Vec3f v)
	{
		return Vec3f(this.x / v.x, this.y / v.y, this.z / v.z);
	}
}

// Shader primitive integer vector. This is a stand-in representation, some functions/methods are
// not implemented.
class Vec3i
{
	i32 x;
	i32 y;
	i32 z;

	void constructor()
	{
		this.x = 0;
		this.y = 0;
		this.z = 0;
	}

	void constructor(i32 x, i32 y, i32 z)
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}

	void constructor(Vec2i v, i32 z)
	{
		this.x = v.x;
		this.y = v.y;
		this.z = z;
	}

	void constructor(Vec3i v)
	{
		this.x = v.x;
		this.y = v.y;
		this.z = v.z;
	}

	// Overload [] operator
	i32 get(u64 index)
	{
		if(index == 0)
			return x;
		else if(index == 1)
			return y;
		else if(index == 2)
			return z;

		return 0;
	}

	// Overload [] operator
	void set(u64 index, i32 val)
	{
		if(index == 0)
			x = val;
		else if(index == 1)
			y = val;
		else if(index == 2)
			z = val;
	}

	// Overload + scalar
	Vec3i add(i32 v)
	{
		return Vec3i(this.x + v, this.y + v, this.z + v);
	}

	// Overload - scalar
	Vec3i subtract(i32 v)
	{
		return Vec3i(this.x - v, this.y - v, this.z - v);
	}

	// Overload * scalar
	Vec3i multiply(i32 v)
	{
		return Vec3i(this.x * v, this.y * v, this.z * v);
	}

	// Overload / scalar
	Vec3i divide(i32 v)
	{
		return Vec3i(this.x / v, this.y / v, this.z / v);
	}

	// Overload +
	Vec3i add(Vec3i v)
	{
		return Vec3i(this.x + v.x, this.y + v.y, this.z + v.z);
	}

	// Overload -
	Vec3i subtract(Vec3i v)
	{
		return Vec3i(this.x - v.x, this.y - v.y, this.z - v.z);
	}

	// Overload *
	Vec3i multiply(Vec3i v)
	{
		return Vec3i(this.x * v.x, this.y * v.y, this.z * v.z);
	}

	// Overload /
	Vec3i divide(Vec3i v)
	{
		return Vec3i(this.x / v.x, this.y / v.y, this.z / v.z);
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Vec4f
////////////////////////////////////////////////////////////////////////////////////////////////////

// Shader primitive boolean vector. This is a stand-in representation, some functions/methods are
// not implemented.
class Vec4b
{
	bool x;
	bool y;
	bool z;
	bool w;

	void constructor()
	{
		this.x = false;
		this.y = false;
		this.z = false;
		this.w = false;
	}

	void constructor(bool x, bool y, bool z, bool w)
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	void constructor(Vec3b v, bool w)
	{
		this.x = v.x;
		this.y = v.y;
		this.z = v.z;
		this.w = w;
	}

	void constructor(Vec4b v)
	{
		this.x = v.x;
		this.y = v.y;
		this.z = v.z;
		this.w = v.w;
	}

	// Overload [] operator
	bool get(u64 index)
	{
		if(index == 0)
			return x;
		else if(index == 1)
			return y;
		else if(index == 2)
			return z;
		else if(index == 3)
			return w;

		return false;
	}

	// Overload [] operator
	void set(u64 index, bool val)
	{
		if(index == 0)
			x = val;
		else if(index == 1)
			y = val;
		else if(index == 2)
			z = val;
		else if(index == 3)
			w = val;
	}

	// Overload +
	Vec4b add(Vec4b v)
	{
		return Vec4b(this.x + v.x, this.y + v.y, this.z + v.z, this.w + v.w);
	}

	// Overload -
	Vec4b subtract(Vec4b v)
	{
		return Vec4b(this.x - v.x, this.y - v.y, this.z - v.z, this.w - v.w);
	}

	// Overload *
	Vec4b multiply(Vec4b v)
	{
		return Vec4b(this.x * v.x, this.y * v.y, this.z * v.z, this.w * v.w);
	}

	// Overload /
	Vec4b divide(Vec4b v)
	{
		return Vec4b(this.x / v.x, this.y / v.y, this.z / v.z, this.w / v.w);
	}
}

// Shader primitive floating-point vector. This is a stand-in representation, some functions/methods are
// not implemented.
class Vec4f
{
	f32 x;
	f32 y;
	f32 z;
	f32 w;

	void constructor()
	{
		this.x = 0.0f;
		this.y = 0.0f;
		this.z = 0.0f;
		this.w = 0.0f;
	}

	void constructor(f32 x, f32 y, f32 z, f32 w)
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	void constructor(Vec3f v, f32 w)
	{
		this.x = v.x;
		this.y = v.y;
		this.z = v.z;
		this.w = w;
	}

	void constructor(Vec4f v)
	{
		this.x = v.x;
		this.y = v.y;
		this.z = v.z;
		this.w = v.w;
	}

	// Overload [] operator
	f32 get(u64 index)
	{
		if(index == 0)
			return x;
		else if(index == 1)
			return y;
		else if(index == 2)
			return z;
		else if(index == 3)
			return w;

		return 0;
	}

	// Overload [] operator
	void set(u64 index, f32 val)
	{
		if(index == 0)
			x = val;
		else if(index == 1)
			y = val;
		else if(index == 2)
			z = val;
		else if(index == 3)
			w = val;
	}

	// Overload + scalar
	Vec4f add(f32 v)
	{
		return Vec4f(this.x + v, this.y + v, this.z + v, this.w + v);
	}

	// Overload - scalar
	Vec4f subtract(f32 v)
	{
		return Vec4f(this.x - v, this.y - v, this.z - v, this.w - v);
	}

	// Overload * scalar
	Vec4f multiply(f32 v)
	{
		return Vec4f(this.x * v, this.y * v, this.z * v, this.w * v);
	}

	// Overload / scalar
	Vec4f divide(f32 v)
	{
		return Vec4f(this.x / v, this.y / v, this.z / v, this.w / v);
	}

	// Overload +
	Vec4f add(Vec4f v)
	{
		return Vec4f(this.x + v.x, this.y + v.y, this.z + v.z, this.w + v.w);
	}

	// Overload -
	Vec4f subtract(Vec4f v)
	{
		return Vec4f(this.x - v.x, this.y - v.y, this.z - v.z, this.w - v.w);
	}

	// Overload *
	Vec4f multiply(Vec4f v)
	{
		return Vec4f(this.x * v.x, this.y * v.y, this.z * v.z, this.w * v.w);
	}

	// Overload * matrix
	Vec4f multiply(Mat4f m)
	{
		return Vec4f(); // TODO
	}

	// Overload /
	Vec4f divide(Vec4f v)
	{
		return Vec4f(this.x / v.x, this.y / v.y, this.z / v.z, this.w / v.w);
	}
}

// Shader primitive integer vector. This is a stand-in representation, some functions/methods are
// not implemented.
class Vec4i
{
	i32 x;
	i32 y;
	i32 z;
	i32 w;

	void constructor()
	{
		this.x = 0.0f;
		this.y = 0.0f;
		this.z = 0.0f;
		this.w = 0.0f;
	}

	void constructor(i32 x, i32 y, i32 z, i32 w)
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	void constructor(Vec3i v, i32 w)
	{
		this.x = v.x;
		this.y = v.y;
		this.z = v.z;
		this.w = w;
	}

	void constructor(Vec4i v)
	{
		this.x = v.x;
		this.y = v.y;
		this.z = v.z;
		this.w = v.w;
	}

	// Overload [] operator
	i32 get(u64 index)
	{
		if(index == 0)
			return x;
		else if(index == 1)
			return y;
		else if(index == 2)
			return z;
		else if(index == 3)
			return w;

		return 0;
	}

	// Overload [] operator
	void set(u64 index, i32 val)
	{
		if(index == 0)
			x = val;
		else if(index == 1)
			y = val;
		else if(index == 2)
			z = val;
		else if(index == 3)
			w = val;
	}

	// Overload + scalar
	Vec4i add(i32 v)
	{
		return Vec4i(this.x + v, this.y + v, this.z + v, this.w + v);
	}

	// Overload - scalar
	Vec4i subtract(i32 v)
	{
		return Vec4i(this.x - v, this.y - v, this.z - v, this.w - v);
	}

	// Overload * scalar
	Vec4i multiply(i32 v)
	{
		return Vec4i(this.x * v, this.y * v, this.z * v, this.w * v);
	}

	// Overload / scalar
	Vec4i divide(i32 v)
	{
		return Vec4i(this.x / v, this.y / v, this.z / v, this.w / v);
	}

	// Overload +
	Vec4i add(Vec4i v)
	{
		return Vec4i(this.x + v.x, this.y + v.y, this.z + v.z, this.w + v.w);
	}

	// Overload -
	Vec4i subtract(Vec4i v)
	{
		return Vec4i(this.x - v.x, this.y - v.y, this.z - v.z, this.w - v.w);
	}

	// Overload *
	Vec4i multiply(Vec4i v)
	{
		return Vec4i(this.x * v.x, this.y * v.y, this.z * v.z, this.w * v.w);
	}

	// Overload /
	Vec4i divide(Vec4i v)
	{
		return Vec4i(this.x / v.x, this.y / v.y, this.z / v.z, this.w / v.w);
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Mat2f
////////////////////////////////////////////////////////////////////////////////////////////////////

// Shader primitive matrix 2x2. This is a stand-in representation, some functions/methods are
// not implemented.
class Mat2f
{
	f32[] m = f32[](4);

	void constructor()
	{
		for(u8 x=0; x<m.length(); x++)
			m[x] = 0.0f;
	}

	void constructor(f32 m0, f32 m1, f32 m2, f32 m3)
	{
		this.m[0]  = m0;
		this.m[1]  = m1;

		this.m[2]  = m2;
		this.m[3]  = m3;
	}

	void constructor(Mat3f mat)
	{
		for(u8 x=0; x<m.length(); x++)
			m[x] = mat.m[x];
	}

	// Overload [] operator
	f32 get(u64 index)
	{
		return m[index];
	}

	// Overload [] operator
	void set(u64 index, f32 val)
	{
		m[index] = val;
	}

	// Overload *
	Vec2f multiply(Vec2f v)
	{
		return Vec2f();
	}

	// Overload *
	Mat2f multiply(Mat2f m)
	{
		return Mat2f();
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Mat3f
////////////////////////////////////////////////////////////////////////////////////////////////////

// Shader primitive matrix 3x3. This is a stand-in representation, some functions/methods are
// not implemented.
class Mat3f
{
	f32[] m = f32[](9);

	void constructor()
	{
		for(u8 x=0; x<m.length(); x++)
			m[x] = 0.0f;
	}

	void constructor(f32 m0, f32 m1, f32 m2, f32 m3, f32 m4, f32 m5, f32 m6, f32 m7, f32 m8)
	{
		this.m[0]  = m0;
		this.m[1]  = m1;
		this.m[2]  = m2;

		this.m[3]  = m3;
		this.m[4]  = m4;
		this.m[5]  = m5;

		this.m[6]  = m6;
		this.m[7]  = m7;
		this.m[8]  = m8;
	}

	void constructor(Mat2f mat)
	{
		for(u8 x=0; x<m.length(); x++)
			m[x] = 0.0f;

		this.m[0]  = mat.m[0];
		this.m[1]  = mat.m[1];

		this.m[3]  = mat.m[2];
		this.m[4]  = mat.m[3];
	}

	void constructor(Mat3f mat)
	{
		for(u8 x=0; x<m.length(); x++)
			m[x] = mat.m[x];
	}

	// Overload [] operator
	f32 get(u64 index)
	{
		return m[index];
	}

	// Overload [] operator
	void set(u64 index, f32 val)
	{
		m[index] = val;
	}

	// Overload *
	Vec3f multiply(Vec3f v)
	{
		return Vec3f();
	}

	// Overload *
	Mat3f multiply(Mat3f m)
	{
		return Mat3f();
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Mat4f
////////////////////////////////////////////////////////////////////////////////////////////////////

// Shader primitive matrix 4x4. This is a stand-in representation, some functions/methods are
// not implemented.
class Mat4f
{
	f32[] m = f32[](16);

	void constructor()
	{
		for(u8 x=0; x<m.length(); x++)
			m[x] = 0.0f;
	}

	void constructor(f32 m0, f32 m1, f32 m2, f32 m3, f32 m4, f32 m5, f32 m6, f32 m7, f32 m8, f32 m9, f32 m10, f32 m11, f32 m12, f32 m13, f32 m14, f32 m15)
	{
		this.m[0]  = m0;
		this.m[1]  = m1;
		this.m[2]  = m2;
		this.m[3]  = m3;

		this.m[4]  = m4;
		this.m[5]  = m5;
		this.m[6]  = m6;
		this.m[7]  = m7;

		this.m[8]  = m8;
		this.m[9]  = m9;
		this.m[10] = m10;
		this.m[11] = m11;

		this.m[12] = m12;
		this.m[13] = m13;
		this.m[14] = m14;
		this.m[15] = m15;
	}

	void constructor(Mat2f mat)
	{
		for(u8 x=0; x<m.length(); x++)
			m[x] = 0.0f;

		this.m[0]  = mat.m[0];
		this.m[1]  = mat.m[1];

		this.m[4]  = mat.m[2];
		this.m[5]  = mat.m[3];
	}

	void constructor(Mat3f mat)
	{
		for(u8 x=0; x<m.length(); x++)
			m[x] = 0.0f;

		this.m[0]  = mat.m[0];
		this.m[1]  = mat.m[1];
		this.m[2]  = mat.m[2];

		this.m[4]  = mat.m[3];
		this.m[5]  = mat.m[4];
		this.m[6]  = mat.m[5];

		this.m[8]  = mat.m[6];
		this.m[9]  = mat.m[7];
		this.m[10] = mat.m[8];
	}

	void constructor(Mat4f mat)
	{
		for(u8 x=0; x<m.length(); x++)
			m[x] = mat.m[x];
	}

	// Overload [] operator
	f32 get(u64 index)
	{
		return m[index];
	}

	// Overload [] operator
	void set(u64 index, f32 val)
	{
		m[index] = val;
	}

	// Overload *
	Vec4f multiply(Vec4f v)
	{
		return Vec4f();
	}

	// Overload *
	Mat4f multiply(Mat4f m)
	{
		return Mat4f();
	}

	// Get matrix row as vector.
	f32[4] getRow(u8 index)
	{
		f32[4] v;

		for(u8 i=0; i<4; i++)
			v[i] = m[(index * 4) + i];

		return v;
	}

	// 4x4 string representation with two digits after decimal
	String<u8> toString()
	{
		return toString(2);
	}

	// 4x4 string representation
	String<u8> toString(u8 numDecDigits)
	{
		String<u8> s = String<u8>();

		Vec4<f32> tempVec = Vec4<f32>();

		for(u8 r=0; r<4; r++)
		{
			tempVec.p = getRow(r);
			String<u8> vecStr = tempVec.toString(numDecDigits);
			s.append(vecStr);
			s.append(Chars:NEW_LINE);
		}

		return s;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Shader
////////////////////////////////////////////////////////////////////////////////////////////////////

// Functions supported within shaders. Extends built-in class.
class Shader
{
	/* OpenGL ES 2.0 hardware only supports floats as inputs :-/
	// Get vertex attribute.
	bool vsInputVertex1b(VertexBuffer buf)
	{
		return 0;
	}

	// Get vertex attribute.
	Vec2b vsInputVertex2b(VertexBuffer buf)
	{
		return Vec2i();
	}

	// Get vertex attribute.
	Vec3b vsInputVertex3b(VertexBuffer buf)
	{
		return Vec3i();
	}

	// Get vertex attribute.
	Vec4b vsInputVertex4b(VertexBuffer buf)
	{
		return Vec4i();
	}

	// Get vertex attribute.
	i32 vsInputVertex1i(VertexBuffer buf)
	{
		return 0;
	}

	// Get vertex attribute.
	Vec2i vsInputVertex2i(VertexBuffer buf)
	{
		return Vec2i();
	}

	// Get vertex attribute.
	Vec3i vsInputVertex3i(VertexBuffer buf)
	{
		return Vec3i();
	}

	// Get vertex attribute.
	Vec4i vsInputVertex4i(VertexBuffer buf)
	{
		return Vec4i();
	}*/

	// Get vertex attribute.
	f32 vsInputVertex1f(VertexBuffer buf)
	{
		return 0.0f;
	}

	// Get vertex attribute.
	Vec2f vsInputVertex2f(VertexBuffer buf)
	{
		return Vec2f();
	}

	// Get vertex attribute.
	Vec3f vsInputVertex3f(VertexBuffer buf)
	{
		return Vec3f();
	}

	// Get vertex attribute.
	Vec4f vsInputVertex4f(VertexBuffer buf)
	{
		return Vec4f();
	}

	// Output the 3D position from the vertex shader.
	void vsOutputPosition(Vec4f vec)
	{
		// TODO
	}

	// Output the a varying vector (like a UV coordinate) from the vertex shader. index should be a numerical constant.
	void vsOutputVarying1f(u8 index, f32 val)
	{
		// TODO
	}

	// Output the a varying vector (like a UV coordinate) from the vertex shader. index should be a numerical constant.
	void vsOutputVarying2f(u8 index, Vec2f vec)
	{
		// TODO
	}

	// Output the a varying vector (like a UV coordinate) from the vertex shader. index should be a numerical constant.
	void vsOutputVarying3f(u8 index, Vec3f vec)
	{
		// TODO
	}

	// Output the a varying vector (like a UV coordinate) from the vertex shader. index should be a numerical constant.
	void vsOutputVarying4f(u8 index, Vec4f vec)
	{
		// TODO
	}

	// Get the a varying vector (like a UV coordinate) from the vertex shader. index should be a numerical constant.
	f32 psInputVarying1f(u8 index)
	{
		return 0.0f;
	}

	// Get the a varying vector (like a UV coordinate) from the vertex shader. index should be a numerical constant.
	Vec2f psInputVarying2f(u8 index)
	{
		return Vec2f();
	}

	// Get the a varying vector (like a UV coordinate) from the vertex shader. index should be a numerical constant.
	Vec3f psInputVarying3f(u8 index)
	{
		return Vec3f();
	}

	// Get the a varying vector (like a UV coordinate) from the vertex shader. index should be a numerical constant.
	Vec4f psInputVarying4f(u8 index)
	{
		return Vec4f();
	}

	// Output from pixel shader. renderTargetIndex must be a numerical literal and must be zero if the GPU does not support MRT.
	void psOutput(u8 renderTargetIndex, Vec4f data)
	{

	}

	// Get the coordinates of the pixel being written in the framebuffer (from pixel shader only).
	Vec4f psGetFramePixelPos()
	{
		return Vec4f(0,0,0,0);
	}

	// Sample a 2D texture.
	Vec4f psSampleTex2D(Texture2D tex, Vec2f uv)
	{
		return Vec4f();
	}

	// Sample a cube texture map.
	Vec4f psSampleTexCube(TextureCube tex, Vec3f uvw)
	{
		return Vec4f();
	}

	// Dot product vector by vector
	f32 dot(Vec2f vecA, Vec2f vecB)
	{
		// TODO
		return 1.0f;
	}

	// Dot product vector by vector
	f32 dot(Vec3f vecA, Vec3f vecB)
	{
		// TODO
		return 1.0f;
	}

	// Dot product vector by vector
	f32 dot(Vec4f vecA, Vec4f vecB)
	{
		// TODO
		return 1.0f;
	}

	// Cross product vector by vector
	Vec3f cross(Vec3f vecA, Vec3f vecB)
	{
		// TODO
		return vecA;
	}

	// Normalize vector to have length of 1.
	Vec2f normalize(Vec2f vecA)
	{
		// TODO
		return vecA;
	}

	// Normalize vector to have length of 1.
	Vec3f normalize(Vec3f vecA)
	{
		// TODO
		return vecA;
	}

	// Normalize vector to have length of 1.
	Vec4f normalize(Vec4f vecA)
	{
		// TODO
		return vecA;
	}

	// Length of vector.
	f32 length(Vec2f vecA)
	{
		// TODO
		return 0.0f;
	}

	// Length of vector.
	f32 length(Vec3f vecA)
	{
		// TODO
		return 0.0f;
	}

	// Length of vector.
	f32 length(Vec4f vecA)
	{
		// TODO
		return 0.0f;
	}

	// Return maximum of two values.
	f32 max(f32 a, f32 b)
	{
		// TODO
		return a;
	}

	// Return minimum of two values.
	f32 min(f32 a, f32 b)
	{
		// TODO
		return a;
	}

	// Degrees to radians
	f32 radians(f32 a)
	{
		return 0.0; // TODO
	}

	// Radians to degrees
	f32 degrees(f32 a)
	{
		return 0.0; // TODO
	}

	// In radians
	f32 sin(f32 a)
	{
		return 0.0; // TODO
	}

	// In radians
	f32 cos(f32 a)
	{
		return 0.0; // TODO
	}

	// In radians
	f32 tan(f32 a)
	{
		return 0.0; // TODO
	}

	// In radians
	f32 asin(f32 a)
	{
		return 0.0; // TODO
	}

	// In radians
	f32 acos(f32 a)
	{
		return 0.0; // TODO
	}

	// In radians
	f32 atan(f32 a)
	{
		return 0.0; // TODO
	}

	// X to Y
	f32 pow(f32 x, f32 powY)
	{
		return 0.0; // TODO
	}

	// eY
	f32 exp(f32 y)
	{
		return 0.0; // TODO
	}

	// log(y)
	f32 log(f32 y)
	{
		return 0.0; // TODO
	}

	// 2 to the Y
	f32 exp2(f32 y)
	{
		return 0.0; // TODO
	}

	// square root
	f32 sqrt(f32 x)
	{
		return 0.0; // TODO
	}

	// inverse square root
	f32 invSqrt(f32 x)
	{
		return 0.0; // TODO
	}

	// Absolute value
	f32 abs(f32 x)
	{
		return 0.0; // TODO
	}

	// Absolute value
	i32 abs(i32 x)
	{
		return 0; // TODO
	}

	// Floot, nearest integer
	f32 floor(f32 x)
	{
		return 0.0; // TODO
	}

	// Floot, nearest integer
	f32 ceil(f32 x)
	{
		return 0.0; // TODO
	}

	// Moduluo, nearest integer
	i32 mod(i32 x, i32 y)
	{
		return 0; // TODO
	}

	// min/max combo
	f32 clamp(f32 x, f32 minVal, f32 maxVal)
	{
		return 0.0; // TODO
	}

	// min/max combo
	i32 clamp(i32 x, i32 minVal, i32 maxVal)
	{
		return 0; // TODO
	}

	// linear blend of x and y
	f32 mix(f32 x, f32 y, f32 balance)
	{
		return 0; // TODO
	}

	// Reflect vector
	Vec2f reflect(Vec2f vec, Vec2f normal)
	{
		return vec; // TODO
	}

	// Reflect vector
	Vec3f reflect(Vec3f vec, Vec3f normal)
	{
		return vec; // TODO
	}

	// Refract vector
	Vec2f refract(Vec2f rayDir, Vec2f surfaceNormal, f32 refractIndex)
	{
		return rayDir; // TODO
	}

	// Refract vector
	Vec3f refract(Vec3f rayDir, Vec3f surfaceNormal, f32 refractIndex)
	{
		return rayDir; // TODO
	}

	// Return a vector pointing in the same direction as another.
	Vec2f faceForward(Vec2f orientateVec, Vec2f incidentVec, Vec2f referenceVec)
	{
		return orientateVec;
	}

	// Return a vector pointing in the same direction as another.
	Vec3f faceForward(Vec3f orientateVec, Vec3f incidentVec, Vec3f referenceVec)
	{
		return orientateVec;
	}

	// a < b
	Vec2b lessThan(Vec2f a, Vec2f b)
	{
		return Vec2b(0, 0);
	}

	// a < b
	Vec2b lessThan(Vec2i a, Vec2i b)
	{
		return Vec2b(0, 0);
	}

	// a < b
	Vec3b lessThan(Vec3f a, Vec3f b)
	{
		return Vec3b(0, 0, 0);
	}

	// a < b
	Vec3b lessThan(Vec3i a, Vec3i b)
	{
		return Vec3b(0, 0, 0);
	}

	// a < b
	Vec4b lessThan(Vec4f a, Vec4f b)
	{
		return Vec4b(0, 0, 0, 0);
	}

	// a < b
	Vec4b lessThan(Vec4i a, Vec4i b)
	{
		return Vec4b(0, 0, 0, 0);
	}

	// a <= b
	Vec2b lessThanEqual(Vec2f a, Vec2f b)
	{
		return Vec2b(0, 0);
	}

	// a <= b
	Vec2b lessThanEqual(Vec2i a, Vec2i b)
	{
		return Vec2b(0, 0);
	}

	// a <= b
	Vec3b lessThanEqual(Vec3f a, Vec3f b)
	{
		return Vec3b(0, 0, 0);
	}

	// a <= b
	Vec3b lessThanEqual(Vec3i a, Vec3i b)
	{
		return Vec3b(0, 0, 0);
	}

	// a <= b
	Vec4b lessThanEqual(Vec4f a, Vec4f b)
	{
		return Vec4b(0, 0, 0, 0);
	}

	// a <= b
	Vec4b lessThanEqual(Vec4i a, Vec4i b)
	{
		return Vec4b(0, 0, 0, 0);
	}

	// a > b
	Vec2b moreThan(Vec2f a, Vec2f b)
	{
		return Vec2b(0, 0);
	}

	// a > b
	Vec2b moreThan(Vec2i a, Vec2i b)
	{
		return Vec2b(0, 0);
	}

	// a > b
	Vec3b moreThan(Vec3f a, Vec3f b)
	{
		return Vec3b(0, 0, 0);
	}

	// a > b
	Vec3b moreThan(Vec3i a, Vec3i b)
	{
		return Vec3b(0, 0, 0);
	}

	// a > b
	Vec4b moreThan(Vec4f a, Vec4f b)
	{
		return Vec4b(0, 0, 0, 0);
	}

	// a > b
	Vec4b moreThan(Vec4i a, Vec4i b)
	{
		return Vec4b(0, 0, 0, 0);
	}

	// a >= b
	Vec2b moreThanEqual(Vec2f a, Vec2f b)
	{
		return Vec2b(0, 0);
	}

	// a >= b
	Vec2b moreThanEqual(Vec2i a, Vec2i b)
	{
		return Vec2b(0, 0);
	}

	// a >= b
	Vec3b moreThanEqual(Vec3f a, Vec3f b)
	{
		return Vec3b(0, 0, 0);
	}

	// a >= b
	Vec3b moreThanEqual(Vec3i a, Vec3i b)
	{
		return Vec3b(0, 0, 0);
	}

	// a >= b
	Vec4b moreThanEqual(Vec4f a, Vec4f b)
	{
		return Vec4b(0, 0, 0, 0);
	}

	// a >= b
	Vec4b moreThanEqual(Vec4i a, Vec4i b)
	{
		return Vec4b(0, 0, 0, 0);
	}

	// a == b
	Vec2b equal(Vec2b a, Vec2b b)
	{
		return Vec2b(0, 0);
	}

	// a == b
	Vec2b equal(Vec2f a, Vec2f b)
	{
		return Vec2b(0, 0);
	}

	// a == b
	Vec2b equal(Vec2i a, Vec2i b)
	{
		return Vec2b(0, 0);
	}

	// a == b
	Vec3b equal(Vec3b a, Vec3b b)
	{
		return Vec3b(0, 0, 0);
	}

	// a == b
	Vec3b equal(Vec3f a, Vec3f b)
	{
		return Vec3b(0, 0, 0);
	}

	// a == b
	Vec3b equal(Vec3i a, Vec3i b)
	{
		return Vec3b(0, 0, 0);
	}

	// a == b
	Vec4b equal(Vec4b a, Vec4b b)
	{
		return Vec4b(0, 0, 0, 0);
	}

	// a == b
	Vec4b equal(Vec4f a, Vec4f b)
	{
		return Vec4b(0, 0, 0, 0);
	}

	// a == b
	Vec4b equal(Vec4i a, Vec4i b)
	{
		return Vec4b(0, 0, 0, 0);
	}

	// a != b
	Vec2b notEqual(Vec2b a, Vec2b b)
	{
		return Vec2b(0, 0);
	}

	// a != b
	Vec2b notEqual(Vec2f a, Vec2f b)
	{
		return Vec2b(0, 0);
	}

	// a != b
	Vec2b notEqual(Vec2i a, Vec2i b)
	{
		return Vec2b(0, 0);
	}

	// a != b
	Vec3b notEqual(Vec3b a, Vec3b b)
	{
		return Vec3b(0, 0, 0);
	}

	// a != b
	Vec3b notEqual(Vec3f a, Vec3f b)
	{
		return Vec3b(0, 0, 0);
	}

	// a != b
	Vec3b notEqual(Vec3i a, Vec3i b)
	{
		return Vec3b(0, 0, 0);
	}

	// a != b
	Vec4b notEqual(Vec4b a, Vec4b b)
	{
		return Vec4b(0, 0, 0, 0);
	}

	// a != b
	Vec4b notEqual(Vec4f a, Vec4f b)
	{
		return Vec4b(0, 0, 0, 0);
	}

	// a != b
	Vec4b notEqual(Vec4i a, Vec4i b)
	{
		return Vec4b(0, 0, 0, 0);
	}

	// Returns true if any component is true
	bool any(Vec2b a)
	{
		return false;
	}

	// Returns true if any component is true
	bool any(Vec3b a)
	{
		return false;
	}

	// Returns true if any component is true
	bool any(Vec4b a)
	{
		return false;
	}

	// Returns true if all components are true
	bool all(Vec2b a)
	{
		return false;
	}

	// Returns true if all components are true
	bool all(Vec3b a)
	{
		return false;
	}

	// Returns true if all components are true
	bool all(Vec4b a)
	{
		return false;
	}

	// Logical complement
	Vec2b not(Vec2b a)
	{
		return a;
	}

	// Logical complement
	Vec3b not(Vec3b a)
	{
		return a;
	}

	// Logical complement
	Vec4b not(Vec4b a)
	{
		return a;
	}

	// 0 if x < edge, else 1
	f32 step(f32 edge, f32 x)
	{
		return 0.0f;
	}

	// 0 if x < edge, else 1
	Vec2f step(Vec2f edge, Vec2f x)
	{
		return edge;
	}

	// 0 if x < edge, else 1
	Vec3f step(Vec3f edge, Vec3f x)
	{
		return edge;
	}

	// 0 if x < edge, else 1
	Vec4f step(Vec4f edge, Vec4f x)
	{
		return edge;
	}

	// 0 if x < edge, else 1
	f32 smoothStep(f32 edge0, f32 edge1, f32 x)
	{
		return 0.0f;
	}

	// Clip and smooth
	Vec2f smoothStep(Vec2f edge0, Vec2f edge1, Vec2f x)
	{
		return edge0;
	}

	// Clip and smooth
	Vec3f smoothStep(Vec3f edge0, Vec3f edge1, Vec3f x)
	{
		return edge0;
	}

	// Clip and smooth
	Vec4f smoothStep(Vec4f edge0, Vec4f edge1, Vec4f x)
	{
		return edge0;
	}
}

/*
// Implement this for vertex shader. Built-in.
interface IVertexShader
{
	// Run vertex shader for a single vertex. State retrieved/stored in s parameter.
	void run(Shader s);
}

// Implement this for pixel shader. Built-in.
interface IPixelShader
{
	// Run vertex shader for a single vertex. State retrieved/stored in s parameter.
	void run(Shader s);
}
*/

////////////////////////////////////////////////////////////////////////////////////////////////////
// GPUProgramSettings
////////////////////////////////////////////////////////////////////////////////////////////////////

// When creating a GPU program many settings are determined at creation time. These "fixed" settings
// cannot be changed in a GPU program after creation. Extends built-in class.
class GPUProgramSettings
{
	const u8 CMP_FUNC_NONE    = 0; // nothing passes
	const u8 CMP_FUNC_ALL     = 1; // everything passes
	const u8 CMP_FUNC_LESS    = 2;
	const u8 CMP_FUNC_LESS_EQ = 3;
	const u8 CMP_FUNC_MORE    = 4;
	const u8 CMP_FUNC_MORE_EQ = 5;
	const u8 CMP_FUNC_EQ      = 6;
	const u8 CMP_FUNC_NOT_EQ  = 7;

	const u8 CULL_NONE = 0;
	const u8 CULL_CW   = 1; // cull clock-wise front facing triangles
	const u8 CULL_CCW  = 2; // cull counter-clock-wise front facing triangles

	const u8 BLEND_FUNC_SRC_ALPHA = 0; // use the newly rendered pixels' alpha component

	const u8 STENCIL_OP_KEEP     = 0;
	const u8 STENCIL_OP_ZERO     = 1;
	const u8 STENCIL_OP_REPLACE  = 2;
	const u8 STENCIL_OP_INC      = 3;
	const u8 STENCIL_OP_INC_WRAP = 4;
	const u8 STENCIL_OP_DEC      = 5;
	const u8 STENCIL_OP_DEC_WRAP = 6;
	const u8 STENCIL_OP_INVERT   = 7;

	const u8 SHADER_PRECISION_LOW    = 0; // approx  8 bits
	const u8 SHADER_PRECISION_MEDIUM = 1; // approx 16 bits
	const u8 SHADER_PRECISION_HIGH   = 2; // approx 32 bits

	//bool depthTestEnabled; // depth test on/off
	//u8   depthTestFunc;    // one of CMP_FUNC_XXX
	//bool depthTestWrite;   // write depth values

	//u8 cullTriMode;

	//bool blendEnabled; // blend rendered pixels with existing pixels using blend func
	//u8   blendFunc;

	//bool stencilEnabled; // stencil test on/off
	//u8   stencilFunc;    // one of CMP_FUNC_XXX
	//u8   stencilRefVal;  // 
	//u8   stencilMask;    // AND'd to value

	//u8 stencilFailOp;
	//u8 stencilPassDepthFailOp;
	//u8 stencilDepthPassOp;

	//u8 vertexShaderPrecision;
	//u8 pixelShaderPrecision;

	// Default is cull CCW triangles, depth test on with func less, blend disabled, stencil disabled.
	void constructor()
	{
		this.depthTestEnabled = true;
		this.depthTestFunc    = CMP_FUNC_LESS;
		this.depthTestWrite   = true;

		this.cullTriMode = CULL_CCW;

		this.blendEnabled = false;
		this.blendFunc    = BLEND_FUNC_SRC_ALPHA;

		this.stencilEnabled = false;
		this.stencilFunc    = CMP_FUNC_LESS;    
		this.stencilRefVal  = 1;
		this.stencilMask    = 1;

		this.stencilFailOp          = STENCIL_OP_KEEP;
		this.stencilPassDepthFailOp = STENCIL_OP_KEEP;
		this.stencilDepthPassOp     = STENCIL_OP_KEEP;

		this.vertexShaderPrecision = SHADER_PRECISION_HIGH;
		this.pixelShaderPrecision  = SHADER_PRECISION_MEDIUM;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// GPUProgram
////////////////////////////////////////////////////////////////////////////////////////////////////

// Defines a complete rendering "program". All GPU pipeline state is baked together into a program.
// This allows quick switching between multiple GPU programs allowing for faster draw calls.
// Baked-in:
// - Vertex and pixel shader with bindings to create shader program.
// - Fixed pipeline values (cull mode, blending options etc.)
//
// Extends built-in class.
class GPUProgram
{
	//u64 programHandle = 0; // native handle
	//IVertexShader vertexShader = null;
	//IPixelShader  pixelShader  = null;
	//String<u8> compileErrors(1024);
	//GPUProgramSettings settings;

	// Uninitialized to start.
	void constructor()
	{
		this.pixelShader   = null;
		this.vertexShader  = null;
		this.compileErrors = String<u8>(1024);
	}

	// Releases vertex/pixel shaders resources.
	void destroy()
	{
		if(this.programHandle != 0)
		{
			deleteGPUProgram_native(this.programHandle);
			this.programHandle = 0;
		}
	}

	// Compile, link etc. GPUProgram owns vs/ps objects now. Returns true for no errors.
	bool create(GPUProgramSettings settings, IVertexShader vertexShader, IPixelShader pixelShader)
	{
		this.vertexShader = vertexShader;
		this.pixelShader  = pixelShader;

		this.programHandle = compileGPUProgram_native(settings, vertexShader, pixelShader, compileErrors);
		if(compileErrors.length() > 0)
		{
			this.programHandle = 0;
			return false;
		}

		return true;
	}

	// Get compile errors
	String<u8> getCompileErrors() { return compileErrors; }
}