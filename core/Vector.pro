////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Vec2
////////////////////////////////////////////////////////////////////////////////////////////////////

// Two dimensional vector. Designed for use with cartesian 2D coordinate systems. Template type must
// be numerical primitive.
class Vec2<A>
{
	A[2] p;

	// Construct zero vector.
	void constructor()
	{
		zero();
	}

	// Construct vector from x/y.
	void constructor(A[2] xy)
	{
		p = xy;
	}

	// Construct vector from x/y.
	void constructor(A x, A y)
	{
		p[0] = x;
		p[1] = y;
	}

	// Construct vector by copying passed-in.
	void constructor(Vec2<A> vec)
	{
		p[0] = vec.p[0];
		p[1] = vec.p[1];
	}

	// Construct vector by copying passed-in.
	void constructor(Vec3<A> vec)
	{
		p[0] = vec.p[0];
		p[1] = vec.p[1];
	}

	// Construct vector by copying passed-in.
	void constructor(Vec4<A> vec)
	{
		p[0] = vec.p[0];
		p[1] = vec.p[1];
	}

	// Copy passed-in vector. z = 0.
	void copy(Vec2<A> vec)
	{
		p[0] = vec.p[0];
		p[1] = vec.p[1];
	}

	// Copy passed-in vector.
	void copy(Vec3<A> vec)
	{
		p[0] = vec.p[0];
		p[1] = vec.p[1];
	}

	// Copy passed-in vector.
	void copy(Vec4<A> vec)
	{
		p[0] = vec.p[0];
		p[1] = vec.p[1];
	}

	// Copy from array.
	void copyFrom(A[] arr, u64 index)
	{
		p[0] = arr[index + 0];
		p[1] = arr[index + 1];
	}

	// Copy to an array.
	void copyTo(A[] arr, u64 index)
	{
		arr[index + 0] = p[0];
		arr[index + 1] = p[1];
	}

	// Set all vector components to zero.
	void zero()
	{
		p[0] = 0;
		p[1] = 0;
	}

	// Set all four components of vector.
	void set(A x, A y)
	{
		p[0] = x;
		p[1] = y;
	}

	// Get component. Overloads [] operator for this class.
	A get(u64 index)
	{
		return p[index];
	}

	// Set component. Overloads [] operator (assignments) for this class.
	void set(u64 index, A val)
	{
		p[index] = val;
	}

	// Values separated by single space.
	String<u8> toString() { return toString(2); }

	// Values separated by single space.
	String<u8> toString(u8 numDecDigits)
	{
		String<u8> s = String<u8>(16);

		s.append(String<u8>:formatNumber(p[0], numDecDigits));
		s.append(Chars:SPACE);
		s.append(String<u8>:formatNumber(p[1], numDecDigits));

		return s;
	}

	// Compare the x and y values of this vector to the values of a passed-in Vec2, accounting for small variations.
	bool compare(Vec2<A> vec) { return compare(vec, 0.1); }

	// Compare the x and y values of this vector to the values of a passed-in Vec2, accounting for small variations.
	bool compare(Vec2<A> vec, A maxTolerance)
	{
		for(u8 c=0; c<2; c++)
		{
			if(Math:compare(p[c], vec[c], maxTolerance) == false)
				return false;
		}

		return true;
	}

	// Both components zero?
	bool isZero()
	{
		if(p[0] == 0 && p[1] == 0)
			return true;

		return false;
	}

	// The distance from the origin to the vector's end point. AKA magnitude.
	A length()
	{
		A len = Math:sqrt((p[0]*p[0]) + (p[1]*p[1]));
		return len;
	}

	// Makes x/y length (AKA magnitude) equal one.
	void normalize()
	{
		A len = length();
		if(Math:compare(len, 0) == true)
			return; // nothing we can do

		A invLen = 1.0 / len;
		p[0] *= invLen;
		p[1] *= invLen;
	}

	// Inverts x/y.
	void invert()
	{
		p[0] *= -1;
		p[1] *= -1;
	}

	// Swap x,y.
	void perpendicular()
	{
		A t = p[0];
		p[0] = -1 * p[1];
		p[1] = t;
	}

	// Dot product. Related to angle between these vectors.
	A dot(Vec2<A> vec)
	{
		return (p[0] * vec.p[0]) + (p[1] * vec.p[1]);
	}

	// operator overload, this + vec
	Vec2<A> add(Vec2<A> vec)
	{
		return Vec2<A>(this.p + vec.p);
	}

	// operator overload
	Vec2<A> add(A s)
	{
		return Vec2<A>(this.p[0] + s, this.p[1] + s);
	}

	// operator overload
	Vec2<A> subtract(Vec2<A> vec)
	{
		return Vec2<A>(this.p - vec.p);
	}

	// operator overload
	Vec2<A> subtract(A s)
	{
		return Vec2<A>(this.p[0] - s, this.p[1] - s);
	}

	// operator overload
	Vec2<A> multiply(Vec2<A> vec)
	{
		return Vec2<A>(this.p * vec.p);
	}

	// operator overload
	Vec2<A> multiply(A s)
	{
		return Vec2<A>(this.p[0] * s, this.p[1] * s);
	}

	// operator overload
	Vec2<A> divide(Vec2<A> vec)
	{
		return Vec2<A>(this.p / vec.p);
	}

	// operator overload
	Vec2<A> divide(A s)
	{
		return Vec2<A>(this.p[0] / s, this.p[1] / s);
	}

	// Shortest angle between this and passed-in vector.
	A angleBetweenVectors(Vec2<A> v2)
	{
		Vec2<A> a = Vec2<A>(this);
		a.normalize();

		Vec2<A> b = Vec2<A>(v2);
		b.normalize();

		// if they are the same, return zero (ensures we don't return PI)
		return Math:atan2Clockwise(a[0], a[1]) - Math:atan2Clockwise(b[0], b[1]);
	}

	// Interpolate between between this and another point.
	Vec2<A> interpolate(Vec2<A> vEnd, f32 interp)
	{
		Vec2<A> v(this);

		v[0] += ((vEnd[0] - v[0]) * interp);
		v[1] += ((vEnd[1] - v[1]) * interp);

		return v;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Vec3
////////////////////////////////////////////////////////////////////////////////////////////////////

// Three dimensional vector. Designed for use with cartesian 3D coordinate systems. Template type
// must be numerical primitive.
class Vec3<A>
{
	A[3] p;

	// Construct zero vector.
	void constructor()
	{
		zero();
	}

	// Construct vector from x/y/z.
	void constructor(A[3] xyz)
	{
		p = xyz;
	}

	// Construct vector from x/y/z.
	void constructor(A x, A y, A z)
	{
		p[0] = x;
		p[1] = y;
		p[2] = z;
	}

	// Construct vector. z = 0, w = 1.
	void constructor(Vec2<A> vec)
	{
		p[0] = vec.p[0];
		p[1] = vec.p[1];
		p[2] = 0;
	}

	// Construct vector. w = 1.
	void constructor(Vec3<A> vec)
	{
		p[0] = vec.p[0];
		p[1] = vec.p[1];
		p[2] = vec.p[2];
	}

	// Construct zero vector.
	void constructor(Vec4<A> vec)
	{
		p[0] = vec.p[0];
		p[1] = vec.p[1];
		p[2] = vec.p[2];
	}

	// Copy passed-in vector. z = 0.
	void copy(Vec2<A> vec)
	{
		p[0] = vec.p[0];
		p[1] = vec.p[1];
		p[2] = 0;
	}

	// Copy passed-in vector.
	void copy(Vec3<A> vec)
	{
		p[0] = vec.p[0];
		p[1] = vec.p[1];
		p[2] = vec.p[2];
	}

	// Copy passed-in vector.
	void copy(Vec4<A> vec)
	{
		p[0] = vec.p[0];
		p[1] = vec.p[1];
		p[2] = vec.p[2];
	}

	// Copy from array.
	void copyFrom(A[] arr, u64 index)
	{
		p[0] = arr[index + 0];
		p[1] = arr[index + 1];
		p[2] = arr[index + 2];
	}

	// Copy to an array.
	void copyTo(A[] arr, u64 index)
	{
		arr[index + 0] = p[0];
		arr[index + 1] = p[1];
		arr[index + 2] = p[2];
	}

	// Set all vector components to zero.
	void zero()
	{
		p[0] = 0;
		p[1] = 0;
		p[2] = 0;
	}

	// Set all four components of vector.
	void set(A x, A y, A z)
	{
		p[0] = x;
		p[1] = y;
		p[2] = z;
	}

	// Get component. Overloads [] operator for this class.
	A get(u64 index)
	{
		return p[index];
	}

	// Set component. Overloads [] operator (assignments) for this class.
	void set(u64 index, A val)
	{
		p[index] = val;
	}

	// Values separated by single space.
	String<u8> toString() { return toString(2); }

	// Values separated by single space.
	String<u8> toString(u8 numDecDigits)
	{
		String<u8> s = String<u8>(16);

		s.append(String<u8>:formatNumber(p[0], numDecDigits));
		s.append(Chars:SPACE);
		s.append(String<u8>:formatNumber(p[1], numDecDigits));
		s.append(Chars:SPACE);
		s.append(String<u8>:formatNumber(p[2], numDecDigits));

		return s;
	}

	// Compare the x, y, and z values of this vector to the values of a passed-in Vec3, accounting for small variations.
	bool compare(Vec3<A> vec) { return compare(vec, 0.1); }

	// Compare the x, y, and z values of this vector to the values of a passed-in Vec3, accounting for small variations.
	bool compare(Vec3<A> vec, A maxTolerance)
	{
		for(u8 c=0; c<3; c++)
		{
			if(Math:compare(p[c], vec[c], maxTolerance) == false)
				return false;
		}

		return true;
	}

	// The distance from the origin to the vector's end point. AKA magnitude. Ignores w component
	A length()
	{
		A len = Math:sqrt((p[0]*p[0]) + (p[1]*p[1]) + (p[2]*p[2]));
		return len;
	}

	// Distance from this to another point.
	A distanceTo(Vec3<A> pt)
	{
		A x = pt[0] - p[0];
		A y = pt[1] - p[1];
		A z = pt[2] - p[2];
		A len = Math:sqrt((x*x) + (y*y) + (z*z));
		return len;
	}

	// Same as distanceTo but without the squareroot, so returned value is dist*dist.
	A distanceToSquared(Vec3<A> pt)
	{
		A x = pt[0] - p[0];
		A y = pt[1] - p[1];
		A z = pt[2] - p[2];
		A lenSq = ((x*x) + (y*y) + (z*z));
		return lenSq;
	}

	// Makes x/y/z length (AKA magnitude) equal one. Ignores w component.
	void normalize()
	{
		A len = length();
		if(Math:compare(len, 0) == true)
			return; // nothing we can do

		A invLen = 1.0 / len;
		p[0] *= invLen;
		p[1] *= invLen;
		p[2] *= invLen;
	}

	// Inverts x/y/z. Works like Vec3.normalize(). Ignores w component.
	void invert()
	{
		p[0] *= -1;
		p[1] *= -1;
		p[2] *= -1;
	}

	// Dot product. Related to angle between these vectors. Ignores w component.
	A dot(Vec3<A> vec)
	{
		return (p[0] * vec.p[0]) + (p[1] * vec.p[1]) + (p[2] * vec.p[2]);
	}

	// Crosses passed-in vector with this. Ignores w component
	void cross(Vec3<A> vec)
	{
		A x = p[1] * vec.p[2] - p[2] * vec.p[1];
		A y = p[2] * vec.p[0] - p[0] * vec.p[2];
		A z = p[0] * vec.p[1] - p[1] * vec.p[0];

		p[0] = x;
		p[1] = y;
		p[2] = z;
	}

	// operator overload
	Vec3<A> add(Vec3<A> vec)
	{
		return Vec3<A>(this.p + vec.p);
	}

	// operator overload
	Vec3<A> add(A s)
	{
		return Vec3<A>(this.p[0] + s, this.p[1] + s, this.p[2] + s);
	}

	// this + scalars
	Vec3<A> add(A x, A y, A z)
	{
		return Vec3<A>(this.p[0] + x, this.p[1] + y, this.p[2] + z);
	}

	// operator overload
	Vec3<A> subtract(Vec3<A> vec)
	{
		return Vec3<A>(this.p - vec.p);
	}

	// operator overload
	Vec3<A> subtract(A s)
	{
		return Vec3<A>(this.p[0] - s, this.p[1] - s, this.p[2] - s);
	}

	// this - scalars
	Vec3<A> subtract(A x, A y, A z)
	{
		return Vec3<A>(this.p[0] - x, this.p[1] - y, this.p[2] - z);
	}

	// operator overload
	Vec3<A> multiply(Vec3<A> vec)
	{
		return Vec3<A>(this.p * vec.p);
	}

	// operator overload
	Vec3<A> multiply(A s)
	{
		return Vec3<A>(this.p[0] * s, this.p[1] * s, this.p[2] * s);
	}

	// this * scalars
	Vec3<A> multiply(A x, A y, A z)
	{
		return Vec3<A>(this.p[0] * x, this.p[1] * y, this.p[2] * z);
	}

	// operator overload
	Vec3<A> divide(Vec3<A> vec)
	{
		return Vec3<A>(this.p / vec.p);
	}

	// operator overload
	Vec3<A> divide(A s)
	{
		return Vec3<A>(this.p[0] / s, this.p[1] / s, this.p[2] / s);
	}

	// this / scalar
	Vec3<A> divide(A x, A y, A z)
	{
		return Vec3<A>(this.p[0] / x, this.p[1] / y, this.p[2] / z);
	}

	// Interpolate between between this and another point.
	Vec3<A> interpolate(Vec3<A> vEnd, f32 interp)
	{
		Vec3<A> v(this); // this + ((vEnd - (*this)) * interp);

		v[0] += ((vEnd[0] - v[0]) * interp);
		v[1] += ((vEnd[1] - v[1]) * interp);
		v[2] += ((vEnd[2] - v[2]) * interp);

		return v;
	}

	// Normalize
	shared Vec3<A> normalize(Vec3<A> a)
	{
		Vec3<A> b(a);
		b.normalize();
		return b;
	}

	// Are three points collinear?
	shared bool areCollinear(Vec3<A> v1, Vec3<A> v2, Vec3<A> v3)
	{
		// ||(a-b)x(b-c)|| = 0 - see http://mathworld.wolfram.com/Collinear.html
		//var crossVal = (v1 - v2).Cross((v2 - v3)).LengthSquared();

		Vec3<A> tempV1 = v1 - v2;

		Vec3<A> tempV2 = v2 - v3;

		tempV1.cross(tempV2);
		f32 crossValue = tempV1.length();

		if(Math:compare(crossValue, 0.0f, 0.0000001f) == true)
			return true;

		return false;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Vec4
////////////////////////////////////////////////////////////////////////////////////////////////////

// Four dimensional vector. Designed for use with cartesian 3D coordinate systems, so w component is 
// treated special. Template type must be numerical primitive.
class Vec4<A>
{
	A[4] p; // four components of vector in a Pronto SIMD vector.

	// Construct zero vector.
	void constructor()
	{
		zero();
	}

	// Construct vector from x/y/z.
	void constructor(A[4] xyzw)
	{
		p = xyzw;
	}

	// Construct vector from x/y/z/w.
	void constructor(A x, A y, A z, A w)
	{
		p[0] = x;
		p[1] = y;
		p[2] = z;
		p[3] = w;
	}

	// Construct vector. z = 0, w = 1.
	void constructor(Vec2<A> vec)
	{
		p[0] = vec.p[0];
		p[1] = vec.p[1];
		p[2] = 0;
		p[3] = 1;
	}

	// Construct vector. w = 1.
	void constructor(Vec3<A> vec)
	{
		p[0] = vec.p[0];
		p[1] = vec.p[1];
		p[2] = vec.p[2];
		p[3] = 1;
	}

	// Construct zero vector.
	void constructor(Vec4<A> vec)
	{
		p[0] = vec.p[0];
		p[1] = vec.p[1];
		p[2] = vec.p[2];
		p[3] = vec.p[3];
	}

	// Copy passed-in vector. z = 0, w = 1.
	void copy(Vec2<A> vec)
	{
		p[0] = vec.p[0];
		p[1] = vec.p[1];
		p[2] = 0;
		p[3] = 1;
	}

	// Copy passed-in vector. w = 1.
	void copy(Vec3<A> vec)
	{
		p[0] = vec.p[0];
		p[1] = vec.p[1];
		p[2] = vec.p[2];
		p[3] = 1;
	}

	// Copy passed-in vector.
	void copy(Vec4<A> vec)
	{
		p[0] = vec.p[0];
		p[1] = vec.p[1];
		p[2] = vec.p[2];
		p[3] = vec.p[3];
	}

	// Copy from array.
	void copyFrom(A[] arr, u64 index)
	{
		p[0] = arr[index + 0];
		p[1] = arr[index + 1];
		p[2] = arr[index + 2];
		p[3] = arr[index + 3];
	}

	// Copy to an array.
	void copyTo(A[] arr, u64 index)
	{
		arr[index + 0] = p[0];
		arr[index + 1] = p[1];
		arr[index + 2] = p[2];
		arr[index + 3] = p[3];
	}

	// Set all vector components to zero.
	void zero()
	{
		p[0] = 0;
		p[1] = 0;
		p[2] = 0;
		p[3] = 0;
	}

	// Set all four components of vector.
	void set(A x, A y, A z, A w)
	{
		p[0] = x;
		p[1] = y;
		p[2] = z;
		p[3] = w;
	}

	// Get component. Overloads [] operator for this class.
	A get(u64 index)
	{
		return p[index];
	}

	// Set component. Overloads [] operator (assignments) for this class.
	void set(u64 index, A val)
	{
		p[index] = val;
	}

	// Values separated by single space.
	String<u8> toString() { return toString(2); }

	// Values separated by single space.
	String<u8> toString(u8 numDecDigits)
	{
		String<u8> s = String<u8>();

		s.append(String<u8>:formatNumber(p[0], numDecDigits));
		s.append(Chars:SPACE);
		s.append(String<u8>:formatNumber(p[1], numDecDigits));
		s.append(Chars:SPACE);
		s.append(String<u8>:formatNumber(p[2], numDecDigits));
		s.append(Chars:SPACE);
		s.append(String<u8>:formatNumber(p[3], numDecDigits));

		return s;
	}

	// Compare the x, y, and z values of this vector to the values of a passed-in Vec3, accounting for small variations.
	bool compare(Vec3<A> vec) { return compare(vec, 0.1); }

	// Compare the x, y, and z values of this vector to the values of a passed-in Vec3, accounting for small variations.
	bool compare(Vec3<A> vec, A maxTolerance)
	{
		for(u8 c=0; c<3; c++)
		{
			if(Math:compare(p[c], vec[c], maxTolerance) == false)
				return false;
		}

		return true;
	}

	// Compare the x, y, z, and w values of this vector to the values of a passed-in Vec4, accounting for small variations.
	bool compare(Vec4<A> vec) { return compare(vec, 0.1); }

	// Compare the x, y, z, and w values of this vector to the values of a passed-in Vec4, accounting for small variations.
	bool compare(Vec4<A> vec, A maxTolerance)
	{
		for(u8 c=0; c<4; c++)
		{
			if(Math:compare(p[c], vec[c], maxTolerance) == false)
				return false;
		}

		return true;
	}

	// The distance from the origin to the vector's end point. AKA magnitude. Ignores w component
	A length()
	{
		A len = Math:sqrt((p[0]*p[0]) + (p[1]*p[1]) + (p[2]*p[2]));
		return len;
	}

	// Makes x/y/z length (AKA magnitude) equal one. Ignores w component.
	void normalize()
	{
		A len = length();
		if(Math:compare(len, 0) == true)
			return; // nothing we can do

		A invLen = 1.0 / len;
		p[0] *= invLen;
		p[1] *= invLen;
		p[2] *= invLen;
	}

	// Inverts x/y/z. Works like Vec3.normalize(). Ignores w component.
	void invert()
	{
		p[0] *= -1;
		p[1] *= -1;
		p[2] *= -1;
	}

	// Dot product. Related to angle between these vectors. Ignores w component.
	A dot(Vec4<A> vec)
	{
		return (p[0] * vec.p[0]) + (p[1] * vec.p[1]) + (p[2] * vec.p[2]);
	}

	// Crosses passed-in vector with this. Ignores w component
	void cross(Vec4<A> vec)
	{
		A x = p[1] * vec.p[2] - p[2] * vec.p[1];
		A y = p[2] * vec.p[0] - p[0] * vec.p[2];
		A z = p[0] * vec.p[1] - p[1] * vec.p[0];

		p[0] = x;
		p[1] = y;
		p[2] = z;
	}

	// operator overload
	Vec4<A> add(Vec4<A> vec)
	{
		return Vec4<A>(this.p + vec.p);
	}

	// operator overload
	Vec4<A> add(A s)
	{
		return Vec4<A>(this.p[0] + s, this.p[1] + s, this.p[2] + s, this.p[3] + s);
	}

	// this + scalars
	Vec4<A> add(A x, A y, A z, A w)
	{
		return Vec4<A>(this.p[0] + x, this.p[1] + y, this.p[2] + z, this.p[3] + w);
	}

	// operator overload
	Vec4<A> subtract(Vec4<A> vec)
	{
		return Vec4<A>(this.p - vec.p);
	}

	// operator overload
	Vec4<A> subtract(A s)
	{
		return Vec4<A>(this.p[0] - s, this.p[1] - s, this.p[2] - s, this.p[3] - s);
	}

	// this + scalars
	Vec4<A> subtract(A x, A y, A z, A w)
	{
		return Vec4<A>(this.p[0] - x, this.p[1] - y, this.p[2] - z, this.p[3] - w);
	}

	// operator overload
	Vec4<A> multiply(Vec4<A> vec)
	{
		return Vec4<A>(this.p * vec.p);
	}

	// operator overload
	Vec4<A> multiply(A s)
	{
		return Vec4<A>(this.p[0] * s, this.p[1] * s, this.p[2] * s, this.p[3] * s);
	}

	// this + scalars
	Vec4<A> multiply(A x, A y, A z, A w)
	{
		return Vec4<A>(this.p[0] * x, this.p[1] * y, this.p[2] * z, this.p[3] * w);
	}

	// operator overload
	Vec4<A> divide(Vec4<A> vec)
	{
		return Vec4<A>(this.p / vec.p);
	}

	// operator overload
	Vec4<A> divide(A s)
	{
		return Vec4<A>(this.p[0] / s, this.p[1] / s, this.p[2] / s, this.p[3] / s);
	}

	// this + scalars
	Vec4<A> divide(A x, A y, A z, A w)
	{
		return Vec4<A>(this.p[0] / x, this.p[1] / y, this.p[2] / z, this.p[3] / w);
	}

	// Interpolate between between this and another point.
	Vec4<A> interpolate(Vec4<A> vEnd, f32 interp)
	{
		Vec4<A> v(this);

		v[0] += ((vEnd[0] - v[0]) * interp);
		v[1] += ((vEnd[1] - v[1]) * interp);
		v[2] += ((vEnd[2] - v[2]) * interp);
		v[3] += ((vEnd[3] - v[3]) * interp);

		return v;
	}
}