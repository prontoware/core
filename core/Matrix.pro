////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Matrix4x4
////////////////////////////////////////////////////////////////////////////////////////////////////

// Four by four matrix. Designed for use with cartesian 3D coordinate systems. Template type must
// be floating-point numerical primitive (f32 or f64). Use with Vec4<f32> etc.
//
// Row-Major vs Column-Major Convention. This class stores it's matrix data as row-major, just like
// C 2D arrays. For example:
//
// |sx  0  0  0| Row-Major: Where we do multiplication as [3d point] dot [matrix column N]
// | 0 sy  0  0| tn: translation
// | 0  0 sz  0| sn: scale
// |tx ty tz  0|
//
// |sx  0  0 tx| Column-Major: Where we do multiplication as [3d point] dot [matrix row N]
// | 0 sy  0 ty|
// | 0  0 sz tz|
// | 0  0  0  0|
//
// Of course these matrices are equivalent when transposed. OpenGL documentation is column-major.
// DirectX uses row-major for descriptions. Academic sources tend to present in column-major order.
//
class Matrix4x4<A>
{
	A[16] m; // vector of all 16 elements, row-major storage

	// Construct matrix, set to identity.
	void constructor()
	{
		setToIdentity();
	}

	// Construct matrix. m0 is row0 element, m1 is row1 element etc.
	void constructor(A m0, A m1, A m2, A m3, A m4, A m5, A m6, A m7, A m8, A m9, A m10, A m11, A m12, A m13, A m14, A m15)
	{
		set(m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15);
	}

	// Construct matrix, copy passed-in matrix.
	void constructor(Matrix4x4<A> mat)
	{
		this.m = mat.m;
	}

	// Copy passed-in matrix.
	void copy(Matrix4x4<A> mat)
	{
		this.m = mat.m;
	}

	// Overload []
	A get(u64 i)
	{
		return m[i];
	}

	// Get matrix row as vector.
	A[4] getRow(u8 index)
	{
		A[4] v;

		for(u8 i=0; i<4; i++)
			v[i] = m[(index * 4) + i];

		return v;
	}

	// Get matrix column as vector. Useful for doing vector * matrix multiplication.
	A[4] getColumn(u8 index)
	{
		A[4] v;

		for(u8 i=0; i<4; i++)
			v[i] = m[index + (i * 4)];

		return v;
	}

	// 4x4 string representation
	String<u8> toString() { return toString(2); }

	// 4x4 string representation
	String<u8> toString(u8 numDecDigits)
	{
		String<u8> s = String<u8>();

		Vec4<A> tempVec = Vec4<A>();

		for(u8 r=0; r<4; r++)
		{
			tempVec.p = getRow(r);
			String<u8> vecStr = tempVec.toString(numDecDigits);
			s.append(vecStr);
			s.append(Chars:NEW_LINE);
		}

		return s;
	}

	// Get matrix value as f64. Some operations (determinant/inverse) need very high precision.
	f64 getF64(u64 index)
	{
		return m[index];
	}

	// Set this to identity matrix.
	void setToIdentity()
	{
		m[0]  = 1.0f; m[1]  = 0.0f; m[2]  = 0.0f; m[3]  = 0.0f;
		m[4]  = 0.0f; m[5]  = 1.0f; m[6]  = 0.0f; m[7]  = 0.0f;
		m[8]  = 0.0f; m[9]  = 0.0f; m[10] = 1.0f; m[11] = 0.0f;
		m[12] = 0.0f; m[13] = 0.0f; m[14] = 0.0f; m[15] = 1.0f;
	}

	// Set all 16 components.
	void set(A m0, A m1, A m2, A m3, A m4, A m5, A m6, A m7, A m8, A m9, A m10, A m11, A m12, A m13, A m14, A m15)
	{
		m[0]  = m0;  m[1]  = m1;  m[2]  = m2;  m[3]  = m3;
		m[4]  = m4;  m[5]  = m5;  m[6]  = m6;  m[7]  = m7;
		m[8]  = m8;  m[9]  = m9;  m[10] = m10; m[11] = m11;
		m[12] = m12; m[13] = m13; m[14] = m14; m[15] = m15;
	}

	// Multiply Vec3 (assumed w=1.0). Drop W from result, does not do divide / W etc.
	Vec3<A> mul(Vec3<A> v3)
	{
		A[4] r;
		A[4] t;

		A[4] v;
		v[0] = v3[0];
		v[1] = v3[1];
		v[2] = v3[2];
		v[3] = 1.0;

		// this memory gather eats much of the performance benefits of SIMD ops
		A[4] col0 = getColumn(0);
		A[4] col1 = getColumn(1);
		A[4] col2 = getColumn(2);
		A[4] col3 = getColumn(3);

		t = col0 * v;
		r[0] = t[0] + t[1] + t[2] + t[3];
		t = col1 * v;
		r[1] = t[0] + t[1] + t[2] + t[3];
		t = col2 * v;
		r[2] = t[0] + t[1] + t[2] + t[3];
		t = col3 * v;
		r[3] = t[0] + t[1] + t[2] + t[3];

		return Vec3<A>(r[0], r[1], r[2]);
	}

	// Multiply Vec3 (assumed w=1.0). Drop W from result, does not do divide / W etc.
	void mul(Vec3<A> v3, Vec3<A> result)
	{
		A[4] r;
		A[4] t;

		A[4] v;
		v[0] = v3[0];
		v[1] = v3[1];
		v[2] = v3[2];
		v[3] = 1.0;

		// this memory gather eats much of the performance benefits of SIMD ops
		A[4] col0 = getColumn(0);
		A[4] col1 = getColumn(1);
		A[4] col2 = getColumn(2);
		A[4] col3 = getColumn(3);

		t = col0 * v;
		r[0] = t[0] + t[1] + t[2] + t[3];
		t = col1 * v;
		r[1] = t[0] + t[1] + t[2] + t[3];
		t = col2 * v;
		r[2] = t[0] + t[1] + t[2] + t[3];
		t = col3 * v;
		r[3] = t[0] + t[1] + t[2] + t[3];

		result.set(r[0], r[1], r[2]);
	}
	
	// Multiply vector by this matrix.
	A[4] mul(A[4] v)
	{
		A[4] r;
		A[4] t;

		// this memory gather eats much of the performance benefits of SIMD ops
		A[4] col0 = getColumn(0);
		A[4] col1 = getColumn(1);
		A[4] col2 = getColumn(2);
		A[4] col3 = getColumn(3);

		t = col0 * v;
		r[0] = t[0] + t[1] + t[2] + t[3];
		t = col1 * v;
		r[1] = t[0] + t[1] + t[2] + t[3];
		t = col2 * v;
		r[2] = t[0] + t[1] + t[2] + t[3];
		t = col3 * v;
		r[3] = t[0] + t[1] + t[2] + t[3];

		return r;
	}

	// Multiply vector by this matrix. Results stored in v parameter.
	void mul(Vec4<A> v)
	{
		A[4] t; // temporary
		A[4] r; // transient result

		// this memory gather eats much of the performance benefits of SIMD ops
		A[4] col0 = getColumn(0);
		A[4] col1 = getColumn(1);
		A[4] col2 = getColumn(2);
		A[4] col3 = getColumn(3);

		t = col0 * v.p;
		r[0] = t[0] + t[1] + t[2] + t[3];
		t = col1 * v.p;
		r[1] = t[0] + t[1] + t[2] + t[3];
		t = col2 * v.p;
		r[2] = t[0] + t[1] + t[2] + t[3];
		t = col3 * v.p;
		r[3] = t[0] + t[1] + t[2] + t[3];

		v.p = r; // store result
	}

	// Multiply vector by this matrix. Results stored in result.
	void mul(Vec4<A> v, Vec4<A> result)
	{
		A[4] t;

		// this memory gather eats much of the performance benefits of SIMD ops
		A[4] col0 = getColumn(0);
		A[4] col1 = getColumn(1);
		A[4] col2 = getColumn(2);
		A[4] col3 = getColumn(3);

		t = col0 * v.p;
		result.p[0] = t[0] + t[1] + t[2] + t[3];
		t = col1 * v.p;
		result.p[1] = t[0] + t[1] + t[2] + t[3];
		t = col2 * v.p;
		result.p[2] = t[0] + t[1] + t[2] + t[3];
		t = col3 * v.p;
		result.p[3] = t[0] + t[1] + t[2] + t[3];
	}

	// Multiply an array of vectors. More efficient than single transform. Results stored in original vector.
	void mul(Vec4<A>[] vectors, u64 numVectors)
	{
		A[4] col0 = getColumn(0);
		A[4] col1 = getColumn(1);
		A[4] col2 = getColumn(2);
		A[4] col3 = getColumn(3);
		
		A[4] t; // temporary
		A[4] r; // transient result

		for(u64 i=0; i<numVectors; i++)
		{
			A[4] v = vectors[i].p;

			t = col0 * v;
			r[0] = t[0] + t[1] + t[2] + t[3];
			t = col1 * v;
			r[1] = t[0] + t[1] + t[2] + t[3];
			t = col2 * v;
			r[2] = t[0] + t[1] + t[2] + t[3];
			t = col3 * v;
			r[3] = t[0] + t[1] + t[2] + t[3];

			vectors[i].p = r; // store result
		}
	}

	// Multiply a list of vectors. More efficient than single transform. Results stored in original vector.
	void mul(ArrayList<Vec4<A>> vectors)
	{
		mul(vectors.data, vectors.size());
	}

	// Multiply an array of vectors. More efficient than single transform. Results stored in results array.
	void mul(Vec4<A>[] vectors, u64 numVectors, Vec4<A>[] results)
	{
		A[4] col0 = getColumn(0);
		A[4] col1 = getColumn(1);
		A[4] col2 = getColumn(2);
		A[4] col3 = getColumn(3);
			
		A[4] t; // temporary
		A[4] r; // transient result

		for(u64 i=0; i<numVectors; i++)
		{
			A[4] v = vectors[i].p;

			t = col0 * v;
			r[0] = t[0] + t[1] + t[2] + t[3];
			t = col1 * v;
			r[1] = t[0] + t[1] + t[2] + t[3];
			t = col2 * v;
			r[2] = t[0] + t[1] + t[2] + t[3];
			t = col3 * v;
			r[3] = t[0] + t[1] + t[2] + t[3];

			results[i].p = r; // store result
		}
	}

	// Multiply a list of vectors. More efficient than single transform. Results stored in results vector.
	void mul(ArrayList<Vec4<A>> vectors, ArrayList<Vec4<A>> results)
	{
		mul(vectors.data, vectors.size(), results.data);
	}

	// Multiply this matrix by scalar.
	void mul(f32 scalar)
	{
		for(u8 i=0; i<16; i++)
			m[i] = m[i] * scalar;
	}

	// Multiply this matrix by another matrix.
	void mul(Matrix4x4<A> n)
	{
		A[4] mRow0 = getRow(0);
		A[4] mRow1 = getRow(1);
		A[4] mRow2 = getRow(2);
		A[4] mRow3 = getRow(3);

		A[4] nCol0 = n.getColumn(0);
		A[4] nCol1 = n.getColumn(1);
		A[4] nCol2 = n.getColumn(2);
		A[4] nCol3 = n.getColumn(3);

		A[4] t;

		t = mRow0 * nCol0;
		m[0] = t[0] + t[1] + t[2] + t[3];
		t = mRow0 * nCol1;
		m[1] = t[0] + t[1] + t[2] + t[3];
		t = mRow0 * nCol2;
		m[2] = t[0] + t[1] + t[2] + t[3];
		t = mRow0 * nCol3;
		m[3] = t[0] + t[1] + t[2] + t[3];

		t = mRow1 * nCol0;
		m[4] = t[0] + t[1] + t[2] + t[3];
		t = mRow1 * nCol1;
		m[5] = t[0] + t[1] + t[2] + t[3];
		t = mRow1 * nCol2;
		m[6] = t[0] + t[1] + t[2] + t[3];
		t = mRow1 * nCol3;
		m[7] = t[0] + t[1] + t[2] + t[3];

		t = mRow2 * nCol0;
		m[8] = t[0] + t[1] + t[2] + t[3];
		t = mRow2 * nCol1;
		m[9] = t[0] + t[1] + t[2] + t[3];
		t = mRow2 * nCol2;
		m[10] = t[0] + t[1] + t[2] + t[3];
		t = mRow2 * nCol3;
		m[11] = t[0] + t[1] + t[2] + t[3];

		t = mRow3 * nCol0;
		m[12] = t[0] + t[1] + t[2] + t[3];
		t = mRow3 * nCol1;
		m[13] = t[0] + t[1] + t[2] + t[3];
		t = mRow3 * nCol2;
		m[14] = t[0] + t[1] + t[2] + t[3];
		t = mRow3 * nCol3;
		m[15] = t[0] + t[1] + t[2] + t[3];

		/*
		this.set(
			(row0[0]*n.row0[0] + row0[1]*n.row1[0] + row0[2]*n.row2[0] + row0[3]*n.row3[0]), (row0[0]*n.row0[1] + row0[1]*n.row1[1] + row0[2]*n.row2[1] + row0[3]*n.row3[1]),
			(row0[0]*n.row0[2] + row0[1]*n.row1[2] + row0[2]*n.row2[2] + row0[3]*n.row3[2]), (row0[0]*n.row0[3] + row0[1]*n.row1[3] + row0[2]*n.row2[3] + row0[3]*n.row3[3]),
			(row1[0]*n.row0[0] + row1[1]*n.row1[0] + row1[2]*n.row2[0] + row1[3]*n.row3[0]), (row1[0]*n.row0[1] + row1[1]*n.row1[1] + row1[2]*n.row2[1] + row1[3]*n.row3[1]),
			(row1[0]*n.row0[2] + row1[1]*n.row1[2] + row1[2]*n.row2[2] + row1[3]*n.row3[2]), (row1[0]*n.row0[3] + row1[1]*n.row1[3] + row1[2]*n.row2[3] + row1[3]*n.row3[3]),
			(row2[0]*n.row0[0] + row2[1]*n.row1[0] + row2[2]*n.row2[0] + row2[3]*n.row3[0]), (row2[0]*n.row0[1] + row2[1]*n.row1[1] + row2[2]*n.row2[1] + row2[3]*n.row3[1]),
			(row2[0]*n.row0[2] + row2[1]*n.row1[2] + row2[2]*n.row2[2] + row2[3]*n.row3[2]), (row2[0]*n.row0[3] + row2[1]*n.row1[3] + row2[2]*n.row2[3] + row2[3]*n.row3[3]),
			(row3[0]*n.row0[0] + row3[1]*n.row1[0] + row3[2]*n.row2[0] + row3[3]*n.row3[0]), (row3[0]*n.row0[1] + row3[1]*n.row1[1] + row3[2]*n.row2[1] + row3[3]*n.row3[1]),
			(row3[0]*n.row0[2] + row3[1]*n.row1[2] + row3[2]*n.row2[2] + row3[3]*n.row3[2]), (row3[0]*n.row0[3] + row3[1]*n.row1[3] + row3[2]*n.row2[3] + row3[3]*n.row3[3])
		);*/
	}

	// Go from column major order to row major order (or vice-versa).
	void transpose()
	{
		A[16] t = m;

		m[0] = t[0];
		m[1] = t[4];
		m[2] = t[8];
		m[3] = t[12];

		m[4] = t[1];
		m[5] = t[5];
		m[6] = t[9];
		m[7] = t[13];

		m[8]  = t[2];
		m[9]  = t[6];
		m[10] = t[10];
		m[11] = t[14];

		m[12] = t[3];
		m[13] = t[7];
		m[14] = t[11];
		m[15] = t[15];
	}

	// Used to make inverse matrix.
	A determinant()
	{
		// f64 precision is critical for this.

		f64 m0  = m[0];
		f64 m1  = m[1];
		f64 m2  = m[2];
		f64 m3  = m[3];

		f64 m4  = m[4];
		f64 m5  = m[5];
		f64 m6  = m[6];
		f64 m7  = m[7];

		f64 m8  = m[8];
		f64 m9  = m[9];
		f64 m10 = m[10];
		f64 m11 = m[11];

		f64 m12 = m[12];
		f64 m13 = m[13];
		f64 m14 = m[14];
		f64 m15 = m[15];

		f64 a = m3*m6*m9*m12;
		f64 b = m2*m7*m9*m12;
		f64 c = m3*m5*m10*m12;
		f64 d = m1*m7*m10*m12;

		f64 e = m2*m5*m11*m12;
		f64 f = m1*m6*m11*m12;
		f64 g = m3*m6*m8*m13;
		f64 h = m2*m7*m8*m13;

		f64 i = m3*m4*m10*m13;
		f64 j = m0*m7*m10*m13;
		f64 k = m2*m4*m11*m13;
		f64 l = m0*m6*m11*m13;

		f64 n = m3*m5*m8*m14;
		f64 o = m1*m7*m8*m14;
		f64 p = m3*m4*m9*m14;
		f64 q = m0*m7*m9*m14;

		f64 r = m1*m4*m11*m14;
		f64 s = m0*m5*m11*m14;
		f64 t = m2*m5*m8*m15;
		f64 u = m1*m6*m8*m15;

		f64 v = m2*m4*m9*m15;
		f64 w = m0*m6*m9*m15;
		f64 x = m1*m4*m10*m15;
		f64 y = m0*m5*m10*m15;

		f64 det = a  - b  - c + d +
				e - f - g  + h +
				i - j - k + l +
				n  - o  - p  + q +
				r - s - t  + u +
				v  - w  - x + y;

		return det;
	}

	// Does reverse of original matrix - can be used to transform vectors back to original state. Not all matrices have a valid inverse.
	Matrix4x4<A> inverse()
	{
		Matrix4x4<A> i = Matrix4x4<A>();

		f64 m0  = m[0];
		f64 m1  = m[1];
		f64 m2  = m[2];
		f64 m3  = m[3];

		f64 m4  = m[4];
		f64 m5  = m[5];
		f64 m6  = m[6];
		f64 m7  = m[7];

		f64 m8  = m[8];
		f64 m9  = m[9];
		f64 m10 = m[10];
		f64 m11 = m[11];

		f64 m12 = m[12];
		f64 m13 = m[13];
		f64 m14 = m[14];
		f64 m15 = m[15];

		i.m[0]  = ( m6*m11*m13 - m7*m10*m13 + m7*m9*m14 - m5*m11*m14 - m6*m9*m15 + m5*m10*m15);
		i.m[1]  = ( m3*m10*m13 - m2*m11*m13 - m3*m9*m14 + m1*m11*m14 + m2*m9*m15 - m1*m10*m15);
		i.m[2]  = ( m2*m7*m13 - m3*m6*m13 + m3*m5*m14 - m1*m7*m14 - m2*m5*m15 + m1*m6*m15);
		i.m[3]  = ( m3*m6*m9 - m2*m7*m9 - m3*m5*m10 + m1*m7*m10 + m2*m5*m11 - m1*m6*m11);
		i.m[4]  = ( m7*m10*m12 - m6*m11*m12 - m7*m8*m14 + m4*m11*m14 + m6*m8*m15 - m4*m10*m15);
		i.m[5]  = ( m2*m11*m12 - m3*m10*m12 + m3*m8*m14 - m0*m11*m14 - m2*m8*m15 + m0*m10*m15);
		i.m[6]  = ( m3*m6*m12 - m2*m7*m12 - m3*m4*m14 + m0*m7*m14 + m2*m4*m15 - m0*m6*m15);
		i.m[7]  = ( m2*m7*m8 - m3*m6*m8 + m3*m4*m10 - m0*m7*m10 - m2*m4*m11 + m0*m6*m11);
		i.m[8]  = ( m5*m11*m12 - m7*m9*m12 + m7*m8*m13 - m4*m11*m13 - m5*m8*m15 + m4*m9*m15);
		i.m[9]  = ( m3*m9*m12 - m1*m11*m12 - m3*m8*m13 + m0*m11*m13 + m1*m8*m15 - m0*m9*m15);
		i.m[10] = ( m1*m7*m12 - m3*m5*m12 + m3*m4*m13 - m0*m7*m13 - m1*m4*m15 + m0*m5*m15);
		i.m[11] = ( m3*m5*m8 - m1*m7*m8 - m3*m4*m9 + m0*m7*m9 + m1*m4*m11 - m0*m5*m11);
		i.m[12] = ( m6*m9*m12 - m5*m10*m12 - m6*m8*m13 + m4*m10*m13 + m5*m8*m14 - m4*m9*m14);
		i.m[13] = ( m1*m10*m12 - m2*m9*m12 + m2*m8*m13 - m0*m10*m13 - m1*m8*m14 + m0*m9*m14);
		i.m[14] = ( m2*m5*m12 - m1*m6*m12 - m2*m4*m13 + m0*m6*m13 + m1*m4*m14 - m0*m5*m14);
		i.m[15] = ( m1*m6*m8 - m2*m5*m8 + m2*m4*m9 - m0*m6*m9 - m1*m4*m10 + m0*m5*m10);

		f64 multiple = 1.0 / determinant();
		i.mul(multiple);

		return i; //i * (1/this->determinant());
	}

	// Set this matrix as a scale transform matrix.
	void setAsScaleMatrix(Vec3<A> sx)
	{
		A x = sx.p[0];
		A y = sx.p[1];
		A z = sx.p[2];

		m[0]  = x;   m[1]  = 0.0; m[2]  = 0.0; m[3]  = 0.0;
		m[4]  = 0.0; m[5]  = y;   m[6]  = 0.0; m[7]  = 0.0;
		m[8]  = 0.0; m[9]  = 0.0; m[10] = z;   m[11] = 0.0;
		m[12] = 0.0; m[13] = 0.0; m[14] = 0.0; m[15] = 1.0;
	}

	// Set this matrix as a translation transform matrix.
	void setAsTranslationMatrix(Vec3<A> tx)
	{
		A x = tx.p[0];
		A y = tx.p[1];
		A z = tx.p[2];

		m[0]  = 1.0; m[1]  = 0.0; m[2]  = 0.0; m[3]  = 0.0;
		m[4]  = 0.0; m[5]  = 1.0; m[6]  = 0.0; m[7]  = 0.0;
		m[8]  = 0.0; m[9]  = 0.0; m[10] = 1.0; m[11] = 0.0;
		m[12] = x;   m[13] = y;   m[14] = z;   m[15] = 1.0;
	}

	// Set this matrix as a rotation transform matrix. Provide an axis to rotate around and an angle in radians. The rotation
	// is positive in the clockwise direction when looking down the axis in the positive direction (from the origin).
	void setAsRotationMatrix(Vec3<A> axis, f32 radians)
	{
		Vec3<A> a = Vec3<A>(axis);
		a.normalize();
		f32 r = radians;

		m[0]  = Math:cos(r) + (a.p[0] * a.p[0]) * (1.0f - Math:cos(r));
		m[1]  = a.p[0] * a.p[1] * (1.0f - Math:cos(r)) - a.p[2] * Math:sin(r);
		m[2]  = a.p[0] * a.p[2] * (1.0f - Math:cos(r)) + a.p[1] * Math:sin(r);
		m[3]  = 0.0f;

		m[4]  = a.p[1] * a.p[0] * (1.0f - Math:cos(r)) + a.p[2] * Math:sin(r);
		m[5]  = Math:cos(r) + (a.p[1] * a.p[1]) * (1.0f - Math:cos(r));
		m[6]  = a.p[1] * a.p[2] * (1.0f - Math:cos(r)) - a.p[0] * Math:sin(r);
		m[7]  = 0.0f;

		m[8]  = a.p[2] * a.p[0] * (1.0f - Math:cos(r)) - a.p[1] * Math:sin(r);
		m[9]  = a.p[2] * a.p[1] * (1.0f - Math:cos(r)) + a.p[0] * Math:sin(r);
		m[10] = Math:cos(r) + (a.p[2] * a.p[2]) * (1.0f - Math:cos(r));
		m[11] = 0.0f;

		m[12] = 0.0f;
		m[13] = 0.0f;
		m[14] = 0.0f;
		m[15] = 1.0f;
	}

	// Set as a left-handed look at matrix. Note the undefined state where the up and direction (eye - at) vectors are parallel.
	void setAsLeftHandedLookAtMatrix(Vec3<A> eye, Vec3<A> at, Vec3<A> up)
	{
		Vec3<A> zAxis = Vec3<A>(at);
		zAxis -= eye;
		zAxis.normalize();

		Vec3<A> xAxis = Vec3<A>(up);
		xAxis.cross(zAxis);
		xAxis.normalize();

		Vec3<A> yAxis = Vec3<A>(zAxis);
		yAxis.cross(xAxis);
		yAxis.normalize();

		m[0]  = xAxis.p[0];
		m[1]  = yAxis.p[0];
		m[2]  = zAxis.p[0];
		m[3]  = 0.0f;

		m[4]  = xAxis.p[1];
		m[5]  = yAxis.p[1];
		m[6]  = zAxis.p[1];
		m[7]  = 0.0f;

		m[8]  = xAxis.p[2];
		m[9]  = yAxis.p[2];
		m[10] = zAxis.p[2];
		m[11] = 0.0f;

		m[12] = -1.0f * xAxis.dot(eye);
		m[13] = -1.0f * yAxis.dot(eye);
		m[14] = -1.0f * zAxis.dot(eye);
		m[15] = 1.0f;
	}

	// Make a left-handed look matrix by explicitly specifying all three axis and the eye point location. Avoids the undefined state where
	// the up and direction (eye - at) vectors are parallel because you provide the forward/side/up axis explcitly.
	void setAsLeftHandedLookAtMatrix(Vec3<A> eye, Vec3<A> forwardAxis, Vec3<A> sideAxis, Vec3<A> upAxis)
	{
		Vec3<A> xAxis = Vec3<A>(sideAxis);
		Vec3<A> yAxis = Vec3<A>(upAxis);
		Vec3<A> zAxis = Vec3<A>(forwardAxis);

		xAxis.normalize();
		yAxis.normalize();
		zAxis.normalize();

		m[0]  = xAxis.p[0];
		m[1]  = yAxis.p[0];
		m[2]  = zAxis.p[0];
		m[3]  = 0.0f;

		m[4]  = xAxis.p[1];
		m[5]  = yAxis.p[1];
		m[6]  = zAxis.p[1];
		m[7]  = 0.0f;

		m[8]  = xAxis.p[2];
		m[9]  = yAxis.p[2];
		m[10] = zAxis.p[2];
		m[11] = 0.0f;

		m[12] = -1.0f * xAxis.dot(eye);
		m[13] = -1.0f * yAxis.dot(eye);
		m[14] = -1.0f * zAxis.dot(eye);
		m[15] = 1.0f;
	}

	// Make a left-handed perspective projection matrix from a field of view.
	void setAsLeftHandedPerspectiveMatrix(A fieldOfViewYRadians, A aspectRatio, A zNearPlane, A zFarPlane)
	{
		A yScale = 1.0f / Math:tan(fieldOfViewYRadians * 0.5f); //yScale = cot(fovY/2)
		A xScale = yScale / aspectRatio;

		m[0]  = xScale;
		m[1]  = 0.0f;
		m[2]  = 0.0f;
		m[3]  = 0.0f;

		m[4]  = 0.0f;
		m[5]  = yScale;
		m[6]  = 0.0f;
		m[7]  = 0.0f;

		m[8]  = 0.0f;
		m[9]  = 0.0f;
		m[10] = zFarPlane / (zFarPlane - zNearPlane);
		m[11] = 1;

		m[12] = 0.0f;
		m[13] = 0.0f;
		m[14] = -1.0f * zNearPlane * zFarPlane / (zFarPlane - zNearPlane); //-zn*zf/(zf-zn)
		m[15] = 0.0f;
	}

	// Make a left-handed orthographic matrix (width/height are normally pixel width/height of viewport)
	void setAsLeftHandedOrthographicMatrix(A width, A height, A zNearPlane, A zFarPlane)
	{
		//  2/w  0    0           0
		//  0    2/h  0           0
		//	0    0    1/(zf-zn)   0
		//	0    0   -zn/(zf-zn)  1

		m[0]  = 2.0f / width;
		m[1]  = 0.0f;
		m[2]  = 0.0f;
		m[3]  = 0.0f;

		m[4]  = 0.0f;
		m[5]  = 2.0f / height;
		m[6]  = 0.0f;
		m[7]  = 0.0f;

		m[8]  = 0.0f;
		m[9]  = 0.0f;
		m[10] = 1.0f / (zFarPlane - zNearPlane);
		m[11] = 0.0f;

		m[12] = 0.0f;
		m[13] = 0.0f;
		m[14] = (-1.0f * zNearPlane) / (zFarPlane - zNearPlane);
		m[15] = 1.0f;
	}

	// Make a viewport matrix. This transforms from projection space to screen space. Still need 
	// to divide by w to go from homogeneous coordinates in 4-space to "normal" Euclidean 3-space.
	void setAsViewportMatrix(A viewportWidthPixels, A viewportHeightPixels)
	{
		m[0]  = viewportWidthPixels * 0.5f;
		m[1]  = 0.0f;
		m[2]  = 0.0f;
		m[3]  = 0.0f;

		m[4]  = 0.0f;
		m[5]  = viewportHeightPixels * -0.5f;
		m[6]  = 0.0f;
		m[7]  = 0.0f;

		m[8]  = 0.0f;
		m[9]  = 0.0f;
		m[10] = 1.0f;
		m[11] = 0.0f;

		m[12] = viewportWidthPixels * 0.5f;
		m[13] = viewportHeightPixels * 0.5f;
		m[14] = 0.0f;
		m[15] = 1.0f;
	}
}