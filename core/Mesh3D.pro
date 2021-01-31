////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// MeshVertex
////////////////////////////////////////////////////////////////////////////////////////////////////

// Standardized vertex for working with mesh vertices.
class MeshVertex
{
	Vec3<f32> pos;
	Vec3<f32> normal;
	Vec2<f32> uv;
	Vec4<u8>  color;
	Vec4<u8>  jointIndexes;
	Vec4<u8>  jointWeights;

	// Construct.
	void constructor()
	{
		pos          = Vec3<f32>();
		normal       = Vec3<f32>();
		uv           = Vec2<f32>();
		color        = Vec4<f32>();
		jointIndexes = Vec4<f32>();
		jointWeights = Vec4<f32>();
	}

	// Construct.
	void constructor(bool allocate)
	{
		if(allocate == true)
			constructor();
	}

	// Copy constructor
	void constructor(MeshVertex v)
	{
		pos          = Vec3<f32>(v.pos);
		normal       = Vec3<f32>(v.normal);
		uv           = Vec2<f32>(v.uv);
		color        = Vec4<f32>(v.color);
		jointIndexes = Vec4<f32>(v.jointIndexes);
		jointWeights = Vec4<f32>(v.jointWeights);
	}

	// Compare
	bool compare(MeshVertex v)
	{
		if(pos.compare(v.pos) == false)
			return false;

		return true;
	}

	// Interpolate values between this and another point. interp in 0.0 to 1.0 range.
	MeshVertex interpolate(MeshVertex to, f32 interp)
	{
		MeshVertex v(false);

		v.pos          = pos.interpolate(to.pos, interp);
		v.normal       = normal.interpolate(to.normal, interp);
		v.uv           = uv.interpolate(to.uv, interp);
		v.color        = color.interpolate(to.color, interp);
		v.jointIndexes = jointIndexes.interpolate(to.jointIndexes, interp);
		v.jointWeights = jointWeights.interpolate(to.jointWeights, interp);

		return v;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// MeshTriangle
////////////////////////////////////////////////////////////////////////////////////////////////////

// Represents a 3D triangle.
class MeshTriangle
{
	MeshVertex pts[3];
	Vec3<f32>  normal; // face normal

	void constructor() {}

	// Triangle vertices normally given in clockwise winding order (CW)
	void constructor(MeshVertex p1, MeshVertex p2, MeshVertex p3)
	{
		this.pts[0] = p1; // normally given in clockwise winding order (CW)
		this.pts[1] = p2;
		this.pts[2] = p3;

		Vec3<f32> ab(this.pts[1].pos);
		ab.sub(this.pts[0].getPos());
	
		Vec3<f32> ac(this.pts[2].pos);
		ac.sub(this.pts[0].getPos());
	
		ab.cross(ac);
		this.normal.copy(ab);
		this.normal.normalize();
	}

	// Triangle vertices normally given in clockwise winding order (CW)
	void constructor(MeshVertex p1, MeshVertex p2, MeshVertex p3, Vec3<f32> normal)
	{
		this.pts[0] = p1; // normally given in clockwise winding order (CW)
		this.pts[1] = p2;
		this.pts[2] = p3;
		this.normal.copy(normal);
	}

	// Copy constructor.
	void constructor(MeshTriangle v)
	{
		pts[0] = v.pts[0];
		pts[1] = v.pts[1];
		pts[2] = v.pts[2];
		normal = v.normal;
	}

	// Overload [] operator
	MeshVertex get(u64 index)
	{
		return pts[index];
	}

	// Copy
	void copy(MeshTriangle & v)
	{
		pts[0] = v.pts[0];
		pts[1] = v.pts[1];
		pts[2] = v.pts[2];
		normal = v.normal;
	}

	// Copy from arrays. Pass null for unused arrays.
	void copyFromArray(f32[] positions, f32[] normals, f32[] uvs, u8[] colors, u8[] jointIndexes, u8[] jointWeights, u32 startVertexIndex)
	{
		if(positions != null)
		{
			this.pts[0].pos.copyFrom(positions, (startVertexIndex * 3) + 0);
			this.pts[1].pos.copyFrom(positions, (startVertexIndex * 3) + 3);
			this.pts[2].pos.copyFrom(positions, (startVertexIndex * 3) + 6);
		}

		if(normals != null)
		{
			this.pts[0].normal.copyFrom(normals, (startVertexIndex * 3) + 0);
			this.pts[1].normal.copyFrom(normals, (startVertexIndex * 3) + 3);
			this.pts[2].normal.copyFrom(normals, (startVertexIndex * 3) + 6);
		}

		if(uvs != null)
		{
			this.pts[0].uv.copyFrom(uvs, (startVertexIndex * 2) + 0);
			this.pts[1].uv.copyFrom(uvs, (startVertexIndex * 2) + 2);
			this.pts[2].uv.copyFrom(uvs, (startVertexIndex * 2) + 4);
		}

		if(colors != null)
		{
			this.pts[0].color.copyFrom(colors, (startVertexIndex * 4) + 0);
			this.pts[1].color.copyFrom(colors, (startVertexIndex * 4) + 4);
			this.pts[2].color.copyFrom(colors, (startVertexIndex * 4) + 8);
		}

		if(jointIndexes != null)
		{
			this.pts[0].jointIndexes.copyFrom(jointIndexes, (startVertexIndex * 4) + 0);
			this.pts[1].jointIndexes.copyFrom(jointIndexes, (startVertexIndex * 4) + 4);
			this.pts[2].jointIndexes.copyFrom(jointIndexes, (startVertexIndex * 4) + 8);
		}

		if(jointWeights != null)
		{
			this.pts[0].jointWeights.copyFrom(jointWeights, (startVertexIndex * 4) + 0);
			this.pts[1].jointWeights.copyFrom(jointWeights, (startVertexIndex * 4) + 4);
			this.pts[2].jointWeights.copyFrom(jointWeights, (startVertexIndex * 4) + 8);
		}

		this.calculateNormal();
	}

	// Copy to arrays. Pass null for unused arrays.
	void copyToArray(f32[] positions, f32[] normals, f32[] uvs, u8[] colors, u8[] jointIndexes, u8[] jointWeights, u32 startVertexIndex)
	{
		if(positions != null)
		{
			this.pts[0].pos.copyTo(arr, (startVertexIndex * 3) + 0);
			this.pts[1].pos.copyTo(arr, (startVertexIndex * 3) + 3);
			this.pts[2].pos.copyTo(arr, (startVertexIndex * 3) + 6);
		}

		if(normals != null)
		{
			this.pts[0].normal.copyTo(normals, (startVertexIndex * 3) + 0);
			this.pts[1].normal.copyTo(normals, (startVertexIndex * 3) + 3);
			this.pts[2].normal.copyTo(normals, (startVertexIndex * 3) + 6);
		}

		if(uvs != null)
		{
			this.pts[0].uv.copyTo(uvs, (startVertexIndex * 2) + 0);
			this.pts[1].uv.copyTo(uvs, (startVertexIndex * 2) + 2);
			this.pts[2].uv.copyTo(uvs, (startVertexIndex * 2) + 4);
		}

		if(colors != null)
		{
			this.pts[0].color.copyTo(colors, (startVertexIndex * 4) + 0);
			this.pts[1].color.copyTo(colors, (startVertexIndex * 4) + 4);
			this.pts[2].color.copyTo(colors, (startVertexIndex * 4) + 8);
		}

		if(jointIndexes != null)
		{
			this.pts[0].jointIndexes.copyTo(jointIndexes, (startVertexIndex * 4) + 0);
			this.pts[1].jointIndexes.copyTo(jointIndexes, (startVertexIndex * 4) + 4);
			this.pts[2].jointIndexes.copyTo(jointIndexes, (startVertexIndex * 4) + 8);
		}

		if(jointWeights != null)
		{
			this.pts[0].jointWeights.copyTo(jointWeights, (startVertexIndex * 4) + 0);
			this.pts[1].jointWeights.copyTo(jointWeights, (startVertexIndex * 4) + 4);
			this.pts[2].jointWeights.copyTo(jointWeights, (startVertexIndex * 4) + 8);
		}
	}

	// Set positions.
	void set(Vec3<f32> v0, Vec3<f32> v1, Vec3<f32> v2)
	{
		this.pts[0].pos.copy(v0);
		this.pts[1].pos.copy(v1);
		this.pts[2].pos.copy(v2);
		this.calculateNormal();
	}

	// Compare by position.
	bool compare(MeshTriangle t)
	{
		for(u32 p=0; p<3; p++)
		{
			if(this.pts[p].compare(t.pts[p]) == false)
				return false;
		}

		return true;
	}

	// Positions
	String<u8> toString()
	{
		String<u8> s(32);

		s.append(" p0:");
		s.append(this.pts[0].pos.toString());
		s.append(" p1:");
		s.append(this.pts[1].pos.toString());
		s.append(" p2:");
		s.append(this.pts[2].pos.toString());
		s.append(" ");

		return s;
	}

	// Points are valid (not infinity etc.) and triangle isn't degenerate (i.e. colinear points)
	bool isValid()
	{
		if(Vec3:areCollinear(pts[0].pos, pts[1].pos, pts[2].pos) == true)
			return false;

		return true;
	}

	// Check if degenerate (i.e. three colinear points)
	bool isDegenerate()
	{
		if(Vec3:areCollinear(pts[0].pos, pts[1].pos, pts[2].pos) == true)
			return true;

		return false;
	}

	// Normal calculated as: (v1 - v0) x (v2 - v0)
	void calculateNormal()
	{
		Vec3<f32> ab(this.pts[1].getPos());
		ab.sub(this.pts[0].getPos());
	
		Vec3<f32> ac(this.pts[2].getPos());
		ac.sub(this.pts[0].getPos());
	
		ab.cross(ac);
		this.normal.copy(ab);
		this.normal.normalize();
	}

	// Fix the normal so it points in the same general direction as approxNormal and fix this triangle to be clockwise.
	void fixNormal(Vec3<f32> approxNormal)
	{
		Vec3<f32> ab(pts[1].pos);
		ab.sub(pts[0].pos);
		ab.normalize();

		Vec3<f32> ac(pts[2].pos);
		ac.sub(pts[0].pos);
		ac.normalize();

		normal.copy(ab);
		normal.cross(ac);
		normal.normalize();

		if(approxNormal.dot(this.normal) < 0.0f) // don't point in same direction!
			this.normal.invert();

		makeClockwise();
	}

	// Determine if the current three vertices of the triangle and it's normal are clockwise.
	bool isClockwise()
	{
		return isClockwise(this.normal, pts[0].pos, pts[1].pos, pts[2].pos);
	}

	// Determine if three points forming a triangle are in clockwise or counter-clockwise ordering. Since ordering is dependent on where
	// the triangle is viewed from, a triangle normal (from the surface of the triangle, pointing away in the direction the triangle would
	// be viewed from).
	bool isClockwise(Vec3<f32> faceNormal)
	{
		return isClockwise(faceNormal, pts[0].pos, pts[1].pos, pts[2].pos);
	}

	// Make this triangle clockwise relative to it's normal.
	void makeClockwise()
	{
		if(isClockwise(normal) == false)
		{
			// swap last two points
			MeshVertex temp = pts[1];
			pts[1] = pts[2];
			pts[2] = temp;
		}
	}

	// Tnvert normal, make vertices still clockwise order.
	void invert()
	{
		normal.invert();
		makeClockwise();
	}

	// Get centroid of this triangle.
	Vec3<f32> getCentroid()
	{
		Vec3<f32> cen(pts[0].pos);
		cen.add(pts[1].pos);
		cen.add(pts[2].pos);
		cen.div(3.0f);
		return cen;
	}

	// Triagnle side (AKA edge) length. side 0 is v0 to v1, side 1 is v1 to v2 and side 2 is v2 to v0.
	f32 getSideLength(u32 index)
	{
		if(index == 2)
			return pts[2].pos.distanceTo(pts[0].pos;

		return pts[index].pos.distanceTo(pts[index + 1].pos);
	}

	// Get interior angle at a vertex, where 0 is v0 angle etc.
	f32 getAngle(u32 index)
	{
		u32 indexA = 2;
		u32 indexB = 1;
		u32 indexC = 0;

		if(index == 1)
		{
			indexA = 0;
			indexB = 2;
			indexC = 1;
		}
		else if(index == 2)
		{
			indexA = 1;
			indexB = 0;
			indexC = 2;
		}

		Vec3<f32> prevDir(pts[indexA].pos);
		prevDir.sub(pts[indexC].pos);
		prevDir.normalize();

		Vec3<f32> nextDir(pts[indexB].pos);
		nextDir.sub(pts[indexC].pos);
		nextDir.normalize();

		f32 res = prevDir.angleBetweenVectors(nextDir);

		return res;
	}

	// get area
	f32 getArea()
	{
		f32 area = 0.0f;

		f32 aLen = getSideLength(0);
		f32 bLen = getSideLength(1);
		f32 cLen = getSideLength(2);

		f32 base   = 0.0f;
		f32 height = 0.0f;

		// longest side is base, and we use opposite vertex to base side to find height
		Vec3<f32> basePt();
		if(aLen >= bLen && aLen >= cLen)
		{
			base   = aLen;
			basePt = getSide(0).findClosestPointOnLineToAPoint(pts[2].getPos());
			height = basePt.distanceTo(pts[2].getPos());
		}
		else if(bLen >= aLen && bLen >= cLen)
		{
			base   = bLen;
			basePt = getSide(1).findClosestPointOnLineToAPoint(pts[0].getPos());
			height = basePt.distanceTo(pts[0].getPos());
		}
		else
		{
			base = cLen;
			basePt = getSide(2).findClosestPointOnLineToAPoint(pts[1].getPos());
			height = basePt.distanceTo(pts[1].getPos());
		}

		return (base * height) / 2.0f;
	}

	// Move vertices
	void translate(Vec3<f32> offset)
	{
		pts[0].pos.add(offset);
		pts[1].pos.add(offset);
		pts[2].pos.add(offset);

		calculateNormal();
	}

	// Get longest side indices. First two of triple are the longest side. Last index is the adjacent vertex index.
	Vec3<u32> getLongestSide()
	{
		Vec3<f32> v(pts[0].pos);
		v.sub(pts[1].pos);
		f32 ab = v.lengthSquared();

		v.copy(pts[1].pos);
		v.sub(pts[2].pos);
		f32 bc = v.lengthSquared();

		v.copy(pts[2].pos);
		v.sub(pts[0].pos);
		f32 ca = v.lengthSquared();

		if(ab > bc && ab > ca)
			return Vec3<u32>(0, 1, 2);

		if(bc > ab && bc > ca)
			return Vec3<u32>(1, 2, 0);

		// equal or ca is longest
		return Vec3<u32>(2, 0, 1);
	}

	// Split triangle into two along the mid point of the longest side to the adjacent vertex.
	Pair<MeshTriangle, MeshTriangle> subdivide()
	{
		Vec3<u32> ls = getLongestSide();

		// interpolate break point
		MeshVertex breakVertex = pts[ls[0]].interpolate(pts[ls[1]], 0.5f);

		// define two sub triangles
		MeshTriangle triA(pts[ls[2]], breakVertex, pts[ls[0]], normal);
		triA.makeClockwise();

		MeshTriangle triB(pts[ls[2]], breakVertex, pts[ls[1]], normal);
		triB.makeClockwise();

		return Pair<MeshTriangle, MeshTriangle>(triA, triB);
	}

	// Split triangle into four along the mid points of each side of the existing triangle.
	ArrayList<MeshTriangle> subdivide4x()
	{
		MeshVertex midPts[](3);
		midPts[0] = pts[0].interpolate(pts[1], 0.5f);
		midPts[1] = pts[1].interpolate(pts[2], 0.5f);
		midPts[2] = pts[2].interpolate(pts[0], 0.5f);

		// Define four sub triangles: Viualize triforce. We start from top trianlge and go clockwise.

		MeshTriangle triA(pts[0], midPts[0], midPts[2], normal);
		triA.makeClockwise();

		MeshTriangle triB(midPts[0], pts[1], midPts[1], normal);
		triB.makeClockwise();

		MeshTriangle triC(midPts[0], midPts[1], midPts[2], normal);
		triC.makeClockwise();

		MeshTriangle triD(midPts[2], midPts[1], pts[2], normal);
		triD.makeClockwise();

		ArrayList<MeshTriangle> newTris(4);
		newsTris[0] = triA;
		newsTris[1] = triB;
		newsTris[2] = triC;
		newsTris[3] = triD;

		return newsTris;
	}

	/*
	// Rotate to so that normal matches newNormal. Origin is centroid.
	void orientate(Vec3<f32> newNormal)
	{
		Vec3<f32> centroid = getCentroid(); // used as origin
		orientate(newNormal, centroid);
	}

	// Rotate to so that normal matches newNormal, using the origin provided (i.e. the centroid of the triangle).
	void orientate(Vec3<f32> newNormal, Vec3<f32> origin)
	{
		Vec3<f32> axis    = normal.axisBetweenVectors(newNormal);
		f32       radians = normal.angleBetweenVectors(newNormal);

		for(u32 p=0; p<3; p++)
		{
			Vec3<f32> curPos(pts[p].pos);

			curPos -= origin; // shift back to origin first 
			curPos =  curPos.rotateAroundVector(axis, radians);
			curPos += origin; // shift back to original offset
			
			pts[p].setPos(curPos);
		}

		this.normal = newNormal;
	}*/

	// @param {number} side 0, 1, or 2 (pt0 >pt1, pt1.pt2 and pt2.pt0 respectively)
	// @param {LineSegment3} [line] set here, or a new LineSegment3 will be allocated
	// @return {LineSegment3} line param or newly allocated
	LineSeg3D<f32> getSide(u32 side, LineSeg3D<f32> line)
	{
		if(side  == 0)
			line.set(this.pts[0].pos, this.pts[1].pos);
		else if(side  == 1)
			line.set(this.pts[1].pos, this.pts[2].pos);
		else
			line.set(this.pts[2].pos, this.pts[0].pos);
	
		return line;
	}

	// Get triangle side (AKA edge). side 0, 1, or 2 (pt0 >pt1, pt1.pt2 and pt2.pt0 respectively)
	LineSeg3D<f32> getSide(u32 side)
	{	
		LineSeg3D<f32> line();

		if(side == 0)
			line.set(this.pts[0].getPos(), this.pts[1].getPos());
		else if(side == 1)
			line.set(this.pts[1].getPos(), this.pts[2].getPos());
		else
			line.set(this.pts[2].getPos(), this.pts[0].getPos());
	
		return line;
	}

	// Is a point in/on the triangle?
	bool contains(Vec3<f32> pt)
	{
		// Translate triangle so that pt is at the origin. If the origin is inside the triangle,
		// then all three triangles formed via the vertices + origin must be CW or CCW.
		// From RTR pg 204

		// Translate pt to origin (along with triangle vertices)
		Vec3<f32> triA(pts[0].pos);
		triA.sub(pt);

		Vec3<f32> triB(pts[1].pos);
		triB.sub(pt);

		Vec3<f32> triC(pts[2].pos);
		triC.sub(pt);

		// Normal vectors of triangles PAB and PBC
		Vec3<f32> u(triB);
		u.cross(triC);

		Vec3<f32> v(triC);
		v.cross(triA);

		// Make sure both are pointing in same direction
		if(u.dot(v) < 0.0f)
			return false;

		// Normal vector for triangle PCA
		Vec3<f32> w(triA);
		w.cross(triB);

		// Make sure points in same direction as first two
		if(u.dot(w) < 0.0f)
			return false;

		// pt is in triangle
		return true;
	}

	// Check if the passed in vertex matches one of the three vertices of this triangle
	bool hasVertex(MeshVertex vert)
	{
		for(u32 v=0; v<3; v++)
		{
			if(pts[v].compare(vert) == true)
				return true;
		}

		return false;
	}

	// Compute barycentric coordinates (x, y, z correspond to pts[0], pts[1], pts[2]) for point p with respect to this triangle.
	Vec3<f32> barycentricCoords(Vec2<f32> pt)
	{
		Vec2<f32> v0(this.pts[1][0], this.pts[1][1]);
		v0.sub(this.pts[0][0], this.pts[0][1]);

		Vec2<f32> v1(this.pts[2][0], this.pts[2][1]);
		v1.sub(this.pts[0][0], this.pts[0][1]);

		Vec2<f32> v2(pt);
		v2.sub(this.pts[0][0], this.pts[0][1]);

		f32 d00 = v0.dot(v0);
		f32 d01 = v0.dot(v1);
		f32 d11 = v1.dot(v1);
		f32 d20 = v2.dot(v0);
		f32 d21 = v2.dot(v1);
		f32 denom = d00 * d11 - d01 * d01;

		Vec3<f32> bary;
		bary.p[1] = (d11 * d20 - d01 * d21) / denom;
		bary.p[2] = (d00 * d21 - d01 * d20) / denom;
		bary.p[0] = 1.0f - bary.p[1] - bary.p[2];

		return bary;
	}

	// Interpolate values from the 3 triangle vertices to arbitrary point within triangle (must provide result from BarycentricCoords() call). barycentricCoords distances from 3 vertices
	f32 interpolate(Vec3<f32> barycentricCoords, f32 v0Value, f32 v1Value, f32 v2Value)
	{
		return (barycentricCoords.p[0] * v0Value) + (barycentricCoords.p[1] * v1Value) + (barycentricCoords.p[2] * v2Value);
	}

	// Get 3D point from barycentric coordinates.
	Vec3<f32> pointFromBarycentricCoords(Vec3<f32> barycentricCoords)
	{
		Vec3<f32> p();

		p.p[0] = (this.pts[0].p[0] * barycentricCoords.p[0]) + (this.pts[1].p[0] * barycentricCoords.p[1]) + (this.pts[2].p[0] * barycentricCoords.p[2]);
		p.p[1] = (this.pts[0].p[1] * barycentricCoords.p[0]) + (this.pts[1].p[1] * barycentricCoords.p[1]) + (this.pts[2].p[1] * barycentricCoords.p[2]);
		p.p[2] = (this.pts[0].p[2] * barycentricCoords.p[0]) + (this.pts[1].p[2] * barycentricCoords.p[1]) + (this.pts[2].p[2] * barycentricCoords.p[2]);

		return p;
	}

	// Intersection test for this triangle with a line.
	bool intersectLine(LineSeg3D<f32> line, Vec3<f32> poiOut)
	{
		// Vector3 qp = line.pt1 - line.pt2;
		Vec3<f32> qp(line.pt1);
		qp.sub(line.pt2);

		// triangle normal. cached!
		Vec3<f32> ab(this.pts[1]);
		ab.sub(this.pts[0]);
	
		Vec3<f32> ac(this.pts[2]);
		ac.sub(this.pts[0]);
	
		Vec3<f32> fullNormal(ab);
		fullNormal.cross(ac);

		// Compute denominator d. If d <= 0, segment is parallel to or points away from triangle, so exit early
		f32 d = qp.dot(fullNormal);
		if(d <= 0.0f)
			return false;

		// Compute intersection t value of pq with plane of triangle. A ray intersects if
		// 0 <= t.  Segment intersects if 0 <= t <= 1.  Delay dividing by d until intersection
		// has been found to pierce triangle.
		// Vector3 ap = line.pt1 - pts[0];
		Vec3<f32> ap(line.pt1);
		ap.sub(this.pts[0]);
		f32 t = ap.dot(fullNormal);
		if(t < 0.0f)
			return false;
		if(t > d) // For segment; exclude this code line for ray, since ray goes beyond d
			return false;

		// Compute barycentric coordinate components and test if within bounds
		Vec3<f32> e(qp);
		e.cross(ap);

		f32 v = ac.dot(e);
		if(v < 0.0f || v > d)
			return false;

		f32 w = - ab.dot(e);
		if(w < 0.0f || (v + w) > d)
			return false;
	
		// calculate poi from ray origin using t
		if(poiOut != null)
		{
			Vec3<f32> dir(line.pt2);
			dir.sub(line.pt1);
			dir.normalize();

			poiOut.copy(dir);
			poiOut.mul(t);
			poiOut.add(line.pt1);
		}
	
		return true;
	}

	// Intersection test for this triangle with a ray, using Möller–Trumbore intersection algorithm. Doesn't require precomputed plane properties etc.
	// Returns intersections with triangle regardless of front/back face.
	bool intersectRay(Ray3D<f32> ray, Vec3<f32> poiOut, bool testBackside)
	{
		f32 epsilon = 0.000001f;

		Vec3<f32> triVert0(this.pts[0]);
		Vec3<f32> triVert1(this.pts[1]);
		Vec3<f32> triVert2(this.pts[2]);
		Vec3<f32> rayOrigin(ray.pt);
		Vec3<f32> rayDir(ray.dir);

		// Find vectors for two edges sharing V1
		Vec3<f32> edge0(triVert1);
		edge0.sub(triVert0);
		Vec3<f32> edge1(triVert2);
		edge1.sub(triVert0);

		// Begin calculating determinant - also used to calculate u parameter
		Vec3<f32> dirEdgeCross(rayDir);
		dirEdgeCross.cross(edge1);
		// if determinant is near zero, ray lies in plane of triangle
		f32 det = edge0.dot(dirEdgeCross);// DOT(e1, P);

		// OPTIONAL - this makes it work like if we only want intersection from the "front" of the triangle
		if(testBackside == false)
		{
			Vec3<f32> triNormal(edge0);
			triNormal.cross(edge1);
			triNormal.invert();
			triNormal.normalize();
			if(triNormal.dot(rayDir) < 0.0f)
				return false; // ray is coming-in from the back
		}

		// Test intersection
		if(det > -epsilon && det < epsilon) 
			return false;
		f32 inv_det = 1.0f / det;
 
		// calculate distance from V1 to ray origin
		Vec3<f32> originToTriVert0(rayOrigin);
		originToTriVert0.sub(triVert0);
 
		// Calculate u parameter and test bound
		f32 u = originToTriVert0.dot(dirEdgeCross) * inv_det;
		// The intersection lies outside of the triangle
		if(u < 0.0f || u > 1.0f)
			return false;
 
		// Prepare to test v parameter
		Vec3<f32> originToTriVert0CrossTriEdge0(originToTriVert0);
		originToTriVert0CrossTriEdge0.cross(edge0);
 
		// Calculate V parameter and test bound
		f32 v = rayDir.dot(originToTriVert0CrossTriEdge0) * inv_det;

		// The intersection lies outside of the triangle
		if(v < 0.0f || u + v  > 1.0f)
			return false;
 
		f32 t = edge1.dot(originToTriVert0CrossTriEdge0) * inv_det;
		if(t > epsilon)
		{
			// use t to calculate POI along ray
			if(poiOut != null)
				poiOut = ray.pointAlong(t);

			return true;
		}
 
		// No hit, no win
		return false;
	}

	// Does passed in triangle intersect this one?
	bool intersectTriangle(MeshTriangle tri)
	{
		f32 MINIMUM_COLLISION_DISTANCE = 0.00001f;

		// Quick test to dismiss most non intersecting cases - check if all the
		// points of one triangle are in the negative or positive half-space of the
		// other triangles' plane.
		Plane<f32> plane0(this.normal, this.pts[0].pos);
		Plane<f32> plane1(tri.normal, tri.pts[0].pos);

		// special case: handle coplanar triangle intersection...
		if(plane0.compare(plane1) == true)
		{
			// could project onto one of the major axes (XY, XZ, YZ) and do 2D
			// overlap check, but this is probably almost as fast:
		
			// Check each triangle line of first triangle against each line of
			// second (9 line combos)

			// first triangle
			LineSeg3D side0(); // first triangle
			LineSeg3D side1(); // second triangle
			for(u32 s0=0; s0<3; s0++)
			{
				this.getSide(s0, side0);

				for(u32 s1=0; s1<3; s1++)
				{
					tri.getSide(s1, side1);
				
					if(side0.intersectLine(side1, MINIMUM_COLLISION_DISTANCE)  == true)
					{
						return true;
					}
				}
			}
		}
	
		if(plane0.pointInNegativeHalfSpace(tri.pts[0])  == true &&
		   plane0.pointInNegativeHalfSpace(tri.pts[1])  == true &&
		   plane0.pointInNegativeHalfSpace(tri.pts[2])  == true)
		{
			return false;
		}

		if(plane0.pointInPositiveHalfSpace(tri.pts[0])  == true &&
		   plane0.pointInPositiveHalfSpace(tri.pts[1])  == true &&
		   plane0.pointInPositiveHalfSpace(tri.pts[2])  == true)
		{
			return false;
		}
	
		// Use penetration test (each of the three triangle edges against the
		// opposite triangle). This test is slower than some other more specialized
		// tests (i.e. the interval overlap test by Moller 97), but with the test
		// above, its' unclear if we would gain much by replacing this in practice.
		LineSeg3D<f32> side();
	
		// first triangle
		Vec3<f32> poi();
		for(u32 s=0; s<3; s++)
		{
			this.getSide(s, side);
		
			if(tri.intersectLine(side, poi)  == true)
			{
				return true;
			}
		}

		// second triangle
		for(u32 s=0; s<3; s++)
		{
			tri.getSide(s, side);

			if(this.intersectLine(side, poi)  == true)
			{
				return true;
			}
		}
	
		return false;
	}

	// Does sphere intersect this triangle?
	bool intersectSphere(Sphere<f32> sphere)
	{
		Vec3<f32> closestTriPt = closestPointOnTri(sphere.center.getPos());

		f32 distSq = closestTriPt.distanceToSquared(sphere.center.getPos());
		if(distSq <= (sphere.radius * sphere.radius))
			return true;

		return false;
	}

	// Calculate closest point on this triangle to a point. Useful for sphere/triangle intersection test.
	Vec3<f32> closestPointOnTri(Vec3<f32> toPt)
	{
		Vec3<f32> p(toPt);
		Vec3<f32> a(this.pts[0].pos);
		Vec3<f32> b(this.pts[1].pos);
		Vec3<f32> c(this.pts[2].pos);

		Vec3<f32> ab = Vec3<f32>:sub(b, a);
		Vec3<f32> ac = Vec3<f32>:sub(c, a);
		Vec3<f32> bc = Vec3<f32>:sub(c, b);

		f32 snom   = Vec3<f32>:sub(p, a).dot(ab);
		f32 sdenom = Vec3<f32>:sub(p, b).dot(Vec3<f32>:sub(a, b));

		f32 tnom   = Vec3<f32>:sub(p, a).dot(ac);
		f32 tdenom = Vec3<f32>:sub(p, c).dot(Vec3<f32>(a, c));

		if(snom <= 0.0f && tnom <= 0.0f)
			return a;

		f32 unom   = Vec3<f32>:sub(p, b).dot(bc);
		f32 udenom = Vec3<f32>:sub(p, c).dot(Vec3<f32>:sub(b, c));

		if(sdenom <= 0.0f && unom <= 0.0f)
			return b;

		if(tdenom <= 0.0f && udenom <= 0.0f)
			return c;

		Vec3<f32> n = Vec3<f32>:sub(b, a);
		n.cross(Vec3<f32>:sub(c, a));

		Vec3<f32> z = Vec3<f32>:sub(a, p);
		z.cross(Vec3<f32>:sub(b, p));
		f32 vc = n.dot(z);

		if(vc <= 0.0f && snom >= 0.0f && sdenom >= 0.0f)
		{
			ab.mul(snom / (snom + sdenom));
			a.add(ab);
			return a;
		}

		Vec3<f32> z2 = Vec3<f32>:sub(b, p);
		z2.cross(Vec3<f32>:sub(c, p));
		f32 va = n.dot(z2);

		if(va <= 0.0f && unom >= 0.0f && udenom >= 0.0f)
		{
			bc.mul(unom / (unom + udenom));
			b.add(bc);
			return b;
		}

		Vec3<f32> z3 = Vec3<f32>:sub(c, p);
		z3.cross(Vec3<f32>:sub(a - p));
		f32 vb = n.dot(z3);

		if(vb <= 0.0f && tnom >= 0.0f && tdenom >= 0.0f)
		{
			ac.mul(tnom / (tnom + tdenom));
			a.add(ac);
			return a;
		}

		// P must project inside face region, compute Q using barycentric coordinates
		f32 u = va / (va + vb + vc);
		f32 v = vb / (va + vb + vc);
		f32 w = 1.0f - u - v;

		Vec3<f32> res0(a);
		res0.mul(u);

		Vec3<f32> res1(b);
		res1.mul(v);

		Vec3<f32> res2(c);
		res1.mul(w);

		res0.add(res1);
		res0.add(res2);

		return res0;
	}

	// Is the passed-in triangle contained completely in the positive half-space? (i.e. the volume that the plane normal points into).
	bool inPositiveHalfSpace(Plane<A> plane)
	{
		if(plane.pointInPositiveHalfSpace(pts[0].pos)  == false)
			return false;
		if(plane.pointInPositiveHalfSpace(pts[1].pos)  == false)
			return false;
		if(plane.pointInPositiveHalfSpace(pts[2].pos)  == false)
			return false;

		return true;
	}

	// Is the passed-in triangle contained completely in the negative half-space? (i.e. the volume that the plane normal points away from).
	bool inNegativeHalfSpace(Plane<A> plane)
	{
		if(plane.pointInNegativeHalfSpace(pts[0].pos)  == false)
			return false;
		if(plane.pointInNegativeHalfSpace(pts[1].pos)  == false)
			return false;
		if(plane.pointInNegativeHalfSpace(pts[2].pos)  == false)
			return false;

		return true;
	}

	// Calculate normal of three vectors forming a triangle. Assumes clockwise ordering of vertices.
	shared Vec3<f32> calculateNormal(Vec3<f32> v0, Vec3<f32> v1, Vec3<f32> v2)
	{
		Vec3<f32> t1(v1);
		t1.sub(v0);

		Vec3<f32> t2(v2);
		t2.sub(v0);

		t1.cross(t2);
		t1.normalize();

		return t1;
	}

	// Calculate normal of three vectors forming a triangle. Does NOT assume a clockwise ordering of vertices, uses the rough normal for picking the side.
	shared Vec3<f32> calculateNormal(Vec3<f32> v0, Vec3<f32> v1, Vec3<f32> v2, Vec3<f32> roughNormal)
	{
		Vec3<f32> normal = calculateNormal(v0, v1, v2);

		if(normal.dot(roughNormal) < 0.0f)
			normal.invert(); // must want other direction

		return normal;
	}

	// Determine if three points forming a triangle are in clockwise or counter-clockwise ordering. Since ordering is dependent on where the triangle is viewed from, a "face normal" must be provided.
	shared bool isClockwise(Vec3<f32> faceNormal, Vec3<f32> v0, Vec3<f32> v1, Vec3<f32> v2)
	{
		// calculate normal from v0/v1/v2, if the sign is the same as the viewerNormal
		Vec3<f32> a(v0);
		Vec3<f32> b(v1);
		Vec3<f32> c(v2);
		
		b.sub(a);
		b.normalize();
		c.sub(a);
		c.normalize();
		b.cross(c); // order of the cross is important - C x B would be counter-clockwise normal
		b.normalize();
		
		// a is the triangle normal
		
		// if the dot product is 1, the normals point in the same direction, if zero,
		// they are perpendicular, and -1, opposite directions
		f32 dot = faceNormal.dot(b);

		if(dot < 0.0f)
			return false; // normals point in opposite directions, triangle is clockwise ordered
		
		return true;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Mesh
////////////////////////////////////////////////////////////////////////////////////////////////////

// Mesh can represent meshs with any of the following:
// - Vertex positions (x, y, z)
// - Normals (x, y, z) for lighting
// - uTangents/vTangents (x, y, z) for normal mapping etc.
// - One set of texture coordinates (u,v)
// - Vertex colors (r, g, b, a)
// - Skeletal animation joints/bones (up to four inlfuences per vertex)
//
// Mesh has many tools for manually constructing geometry, modifying existing etc.
class Mesh
{
	// Vertex attributes
	u32   numTriAlloc;    // tells us the size of positions, colors etc.
	u32   numTriUsed;     // NOT optional, tells us how many positions are actually to be rendered (valid geometry)
	f32[] positions;      // XYZ, 3 f32's per vertex
	f32[] normals;        // XYZ, 3 f32's per vertex
	f32[] uTangents;      // vector that relates U (AKA right direction) texture space axis to model space (for normal mapping)
	f32[] vTangents;      // vector that relates V (AKA up direction) texture space axis to model space (for normal mapping).  If we were sure the tangent & normal were always orthoganal we could compute this in the vertex shader, but we don't assume that.
	f32[] uvs;            // UV, 2 f32's per vertex
	u8[]  colors;         // RGBA color per vertex
	u8[]  jointIndexes;   // every vertex gets 4 possible joint influences, by joint index id
	u8[]  jointWeights;   // each joint influence index gets a weight between 0 and 255

	// Construct with no mesh data.
	void constructor()
	{
		this.numTriAlloc = 0;
		this.numTriUsed  = 0;
	}

	// Construct with allocated space.
	void constructor(u32 numTri)
	{
		this.numTriAlloc = numTri;
		this.numTriUsed  = 0;

		createArrays(numTri, true, true, true, true, true, true);
	}

	// Construct with allocated space.
	void constructor(u32 numTri, bool wantPositions, bool wantNormals, bool wantTangenets, bool wantUVs, bool wantColors, bool wantJoints)
	{
		this.numTriAlloc = numTri;
		this.numTriUsed  = 0;

		createArrays(numTri, wantPositions, wantNormals, wantTangenets, wantUVs, wantColors, wantJoints);
	}

	// Release arrays
	void destroy()
	{
		destroyArrays();
	}

	// Allocate memory.
	void createArrays(u32 numTri, bool wantPositions, bool wantNormals, bool wantTangenets, bool wantUVs, bool wantColors, bool wantJoints)
	{
		this.numTriAlloc = numTri;

		u32 numNewVerts = newNumTri * 3;

		if(wantPositions == true)
			this.positions = f32[](numNewVerts * 3);
		if(wantNormals == true)
			this.normals = f32[](numNewVerts * 3);
		if(wantTangenets == true)
		{
			this.uTangents = f32[](numNewVerts * 3);
			this.vTangents = f32[](numNewVerts * 3);
		}
		if(wantUVs == true)
			this.uvs = f32[](numNewVerts * 2);
		if(wantColors == true)
			this.colors = u8[](numNewVerts * 4);
		if(wantJoints == true)
		{
			this.jointIndexes = u8[](numNewVerts * 4);
			this.jointWeights = u8[](numNewVerts * 4);
		}
	}

	// Deallocate existing memory
	void destroyArrays()
	{
		positions    = null;
		normals      = null;
		uTangents    = null;
		vTangents    = null;
		uvs          = null;
		colors       = null;
		jointIndexes = null;
		jointWeights = null;
	}

	// Resize existing arrays preserving data.
	void resizeArrays(u32 newNumTri)
	{
		u32 numNewVerts    = newNumTri * 3;
		u32 numVertsToCopy = Math:min(numTriAlloc, newNumTri) * 3; // in case numTriAlloc is more than newNumTri

		if(positions != null)
		{
			f32[] oldPositions = positions;
			positions = f32[](numNewVerts * 3);
			positions.copy(oldPositions, 0, 0, numVertsToCopy * 3);
		}

		if(normals != null)
		{
			f32[] oldNormals = normals;
			normals = f32[](numNewVerts * 3);
			normals.copy(oldNormals, 0, 0, numVertsToCopy * 3);
		}

		if(uTangents != null)
		{
			f32[] oldUTangents = uTangents;
			uTangents = f32[](numNewVerts * 3);
			uTangents.copy(oldUTangents, 0, 0, numVertsToCopy * 3);
		}

		if(vTangents != null)
		{
			f32[] oldVTangents = vTangents;
			vTangents = f32[](numNewVerts * 3);
			vTangents.copy(oldVTangents, 0, 0, numVertsToCopy * 3);
		}

		if(uvs != null)
		{
			f32[] oldUVs = uvs;
			uvs = f32[](numNewVerts * 2);
			uvs.copy(oldUVs, 0, 0, numVertsToCopy * 2);
		}

		if(colors != null)
		{
			u8[] oldColors = colors;
			colors = u8[](numNewVerts * 4);
			colors.copy(oldColors, 0, 0, numVertsToCopy * 4);
		}

		if(jointIndexes != null)
		{
			u8[] oldIndexes = jointIndexes;
			jointIndexes = u8[](numNewVerts * 4);
			jointIndexes.copy(oldIndexes, 0, 0, numVertsToCopy * 4);
		}

		if(jointWeights != null)
		{
			u8[] oldWeights = jointWeights;
			jointWeights = u8[](numNewVerts * 3 * 4);
			jointWeights.copy(oldWeights, 0, 0, numVertsToCopy * 3 * 4);
		}
	}


}