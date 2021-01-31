////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Ray3D
////////////////////////////////////////////////////////////////////////////////////////////////////

// 3D ray. Rays have a start point (origin) and a direction.
class Ray3D<A>
{
	Vec3<A> pt;
	Vec3<A> dir;

	// Origin at 0,0,0 in direction 0,0,0
	void constructor()
	{
		pt  = Vec3<A>(0, 0, 0);
		dir = Vec3<A>(0, 0, 0);
	}

	// Set from origin and direction.
	void constructor(A x1, A y1, A z1, A dx, A dy, A dz)
	{
		this.pt  = Vec3<A>(x1, y1, z1);
		this.dir = Vec3<A>(dx, dy, dz);
	}

	// Set from origin and direction.
	void constructor(Vec3<A> origin, Vec3<A> direction)
	{
		this.pt  = Vec3<A>(origin);
		this.dir = Vec3<A>(direction);
	}

	// Copy constructor
	void constructor(Ray3D<A> v)
	{
		this.pt  = Vec3<A>(v.pt);
		this.dir = Vec3<A>(v.dir);
	}

	// Set from origin and direction.
	void set(A x1, A y1, A z1, A dx, A dy, A dz)
	{
		this.pt.set(x1, y1, z1);
		this.dir.set(dx, dy, dz);
	}

	// Set from origin and direction.
	void set(Vec3<A> pt, Vec3<A> dir)
	{
		this.pt.copy(pt);
		this.dir.copy(dir);
	}

	// Start / end points of segement
	void setFromLine(Vec3<A> startPt, Vec3<A> endPt)
	{
		this.pt.copy(startPt);
		this.dir.copy(endPt);
		this.dir -= startPt;
		this.dir.normalize();
	}

	// Copy constructor equivalent
	void copy(Ray3D<A> r)
	{
		this.pt.copy(r.pt);
		this.dir.copy(r.dir);
	}

	// Origin and direction.
	String<u8> toString()
	{
		String<u8> s;
		s.append(" Origin: ");
		s.append(this.pt.toString());
		s.append(" Direction: ");
		s.append(this.dir.toString());
		return s;
	}

	// Invert ray direction.
	void invert()
	{
		this.dir.invert();
	}

	// Get a point a certain distance along the ray from the origin.
	Vec3<A> pointAlong(A distance)
	{
		Vec3<A> dirDist = Vec3<A>(this.dir);
		dirDist *= distance;
	
		Vec3<A> originPlusDist = Vec3<A>(this.pt);
		originPlusDist += dirDist;
	
		return originPlusDist;
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////
// LineSeg3D
////////////////////////////////////////////////////////////////////////////////////////////////////

// Line segment representation in three dimensions.
class LineSeg3D<A>
{
	Vec3<A> pt1();
	Vec3<A> pt2();

	// 0,0,0 to 0,0,0
	void constructor()
	{

	}

	// Define by two points.
	void constructor(A x1, A y1, A z1, A x2, A y2, A z2)
	{
		this.pt1.set(x1, y1, z1);
		this.pt2.set(x2, y2, z2);
	}

	// Define by two points.
	void constructor(Vec3<A> p0, Vec3<A> p1)
	{
		this.pt1 = p0;
		this.pt2 = p1;
	}

	// Copy constructor
	void constructor(LineSeg3D<A> v)
	{
		this.pt1.copy(v.pt1);
		this.pt2.copy(v.pt2);
	}

	// Returns PT1 to PT2
	String<u8> toString()
	{
		String<u8> s;
		s.append(this.pt1.toString());
		s.append(" to ");
		s.append(this.pt2.toString());
		return s;
	}

	// Set end points.
	void set(A x1, A y1, A z1, A x2, A y2, A z2)
	{
		this.pt1.p[0] = x1; 
		this.pt1.p[1] = y1; 
		this.pt1.p[2] = z1;
		this.pt2.p[0] = x2; 
		this.pt2.p[1] = y2; 
		this.pt2.p[2] = z2;
	}

	// Set end points.
	void set(Vec3<A> p0, Vec3<A> p1)
	{
		this.pt1 = p0;
		this.pt2 = p1;
	}

	// Copy passed-in.
	void copy(LineSeg3D<A> line)
	{
		this.pt1.copy(line.pt1);
		this.pt2.copy(line.pt2);
	}

	// Check if same ling segment.
	bool compare(LineSeg3D<A> i, A distTolerance)
	{
		if(pt1.compare(i.pt1, distTolerance) && pt2.compare(i.pt2, distTolerance))
			return true;

		// points reveresed, but same segement
		if(pt1.compare(i.pt2, distTolerance) && pt2.compare(i.pt1, distTolerance))
			return true;

		return false;
	}

	// Get line length.
	A length()
	{
		Vec3<A> v(this.pt1);
		v -= this.pt2;
		A len = v.length();
		return len;
	}

	// Get line mid point.
	Vec3<A> midPoint()
	{
		Vec3<A> v(this.pt2);
		v -= this.pt1;
		v *= 0.5;
		v += this.pt1;
		return v;
	}

	// Get point along line.
	Vec3<A> interpolate(A interp)
	{
		Vec3<A> v(this.pt2);
		v -= this.pt1;
		v *= interp;
		v += this.pt1;
		return v;
	}

	// Translate
	void translate(Vec3<A> xyz)
	{
		this.pt1 += xyz;
		this.pt2 += xyz;
	}

	// Shrink/Enlarge the line length (towards its midpoint) by a relative amount (i.e. newLenFactor = 0.95 means shrink line to 95% of original length)
	void scale(A newLenFactor)
	{
		Vec3<A> midPt = midPoint();

		Vec3<A> newA(pt1);
		newA -= midPt;
		newA *= newLenFactor;

		Vec3<A> newB(pt2);
		newB -= midPt;
		newB *= newLenFactor;

		pt1.copy(midPt);
		pt1 += newA;

		pt2.copy(midPt);
		pt2 += newB;
	}

	// Shrink/Enlarge line by absolute amount from midpoint of line
	void resize(A newLength)
	{
		A halfDist = newLength/2.0;

		Vec3<A> midPt  = midPoint();
		Vec3<A> dirPt1 = Vec3<A>:normalize(pt1 - pt2);
		Vec3<A> dirPt2 = Vec3<A>:normalize(pt2 - pt1);

		pt1 = midPt + (dirPt1 * Vec3<A>(halfDist, halfDist, halfDist));
		pt2 = midPt + (dirPt2 * Vec3<A>(halfDist, halfDist, halfDist));
	}

	// Shrink line segment towards its midpoint
	void shrink(A distToCutOffEachEnd)
	{
		if((distToCutOffEachEnd * 2.0f) >= length())
			distToCutOffEachEnd = length() * 0.49f;

		A newLength = length() - (distToCutOffEachEnd * 2.0f);
		resize(newLength);
	}

	// Enlarge line segment away from its midpoint
	void enlarge(A distToAddToEachEnd)
	{
		A newLength = length() + (distToAddToEachEnd * 2.0f);
		resize(newLength);
	}

	// Returns t distance along line
	f32 inverseInterpolate(Vec3<A> ptOnLine)
	{
		f32 t = 0.0f;

		f32 totalLen = length();
		if(totalLen <= 0.0f)
			return 0.0f; // avoid divide by zero

		f32 ptLen = pt1.distanceTo(ptOnLine);

		return ptLen / totalLen;
	}

	// Find the z (value to be interpolated) value of the middle point (mid) between pt1 and pt2 (mid.xy must be point on the line!)
	f32 interpolate(f32 pt1w, f32 pt2w, Vec3<A> mid)
	{
		Vec2<A> v(this.pt1[0], this.pt1[1]);
		v -= Vec2<A>(this.pt2[0], this.pt2[1]);
		f32 lineLen = v.length();
		Vec3<A> v2(mid);
		v2 -= this.pt2;
		f32 poiLen  = v2.length();
		f32 wRatio  = poiLen / lineLen;
		f32 wLen    = pt1w - pt2w;
		f32 w       = pt2w + (wLen * wRatio);

		return w;
	}

	// Compute closest point on line to some arbitrary point.
	Vec3<A> findClosestPointOnLineToAPoint(Vec3<A> Pt)
	{
		//compute line direction vector
		Vec3<A> lineDir(this.pt2); 
		lineDir -= this.pt1;

		//project Pt onto line P1.P2 computing parameterized position d(t) = p1 + t * (lineDir)
		Vec3<A> dirPtPt1(Pt);
		dirPtPt1 -= this.pt1;
		f32 t = dirPtPt1.dot(lineDir) / lineDir.dot(lineDir);

		if(t < 0.0f)
			t = 0.0f; //this will be closest point, at the end of line segment
		if(t > 1.0f)
			t = 1.0f; //this will be closest point, at the (other) end of the line segment

		lineDir *= t;
		lineDir += this.pt1;
	
		return lineDir;
	}

	// Are two line segments parallel (i.e. in same direction)
	bool isParallelTo(LineSeg3D<A> line)
	{
		return isParallelTo(line, 0.00001f);
	}

	// Are two line segments parallel (i.e. in same direction)
	bool isParallelTo(LineSeg3D<A> line, f32 dotPtTolerance)
	{
		Vec3<A> dir0 = Vec3<A>:normalize(pt2 - pt1);
		Vec3<A> dir1 = Vec3<A>:normalize(line.pt2 - line.pt1);

		f32 dotPt = dir0.dot(dir1);
		if(Math:compare(dotPt, 1.0f, dotPtTolerance) || Math:compare(dotPt, -1.0f, dotPtTolerance))
			return true;

		return false;
	}

	// Do two lines overlap, and if so, what is the overlap segement?
	bool overlapsWith(LineSeg3D<A> line, LineSeg3D<A> overlapOut)
	{
		return overlapsWith(line, overlapOut, 0.00001f, 0.001f, 0.0001f);
	}

	// Do two lines overlap, and if so, what is the overlap segement?
	bool overlapsWith(LineSeg3D<A> line, LineSeg3D<A> overlapOut, f32 dotPtTolerance, f32 minSegLength, f32 maxOverlapGap)
	{
		if(isParallelTo(line, dotPtTolerance) == false)
			return false;

		// We know they are parallel, so now we want the overlap (if exists). Now we are
		// effectively going to project the end points of each segment onto the other line
		// segment. We do this by finding the closest point and confirming it's on the
		// line (by a distance check).

		// Four possible end points for overlap segment are the end points of the two lines.
		Vec3<A>[] overlapPts = Vec3<A>[](4);
		u32  numPts = 0;
		Vec3<A> overlapTestPt;
		
		// this line (A)'s end points onto input line (B)
		overlapTestPt = line.findClosestPointOnLineToAPoint(pt1);
		if(overlapTestPt.distanceTo(pt1) < maxOverlapGap)
		{
			overlapPts[numPts] = overlapTestPt;
			numPts++;
		}

		overlapTestPt = line.findClosestPointOnLineToAPoint(pt2);
		if(overlapTestPt.distanceTo(pt2) < maxOverlapGap)
		{
			overlapPts[numPts] = overlapTestPt;
			numPts++;
		}

		// reverse: B's end points onto A
		overlapTestPt = this.findClosestPointOnLineToAPoint(line.pt1);
		if(overlapTestPt.distanceTo(line.pt1) < maxOverlapGap)
		{
			overlapPts[numPts] = overlapTestPt;
			numPts++;
		}

		overlapTestPt = this.findClosestPointOnLineToAPoint(line.pt2);
		if(overlapTestPt.distanceTo(line.pt2) < maxOverlapGap)
		{
			overlapPts[numPts] = overlapTestPt;
			numPts++;
		}

		// So *if* there is overlap, then at least *two* of the overlap points will have effectively
		// zero distance between the closest point and the end point it was calculated from.
		if(numPts < 2)
			return false; // it really should be zero or two points, never 1, but robustness issues, you know?

		if(numPts == 2)
		{
			// easy
			overlapOut.set(overlapPts[0], overlapPts[1]);
		}
		else if(numPts == 3)
		{
			// so, two of three points are the same
			if(overlapPts[0].compare(overlapPts[1], 0.0001f) == false)
				overlapOut.set(overlapPts[0], overlapPts[1]);
			else if(overlapPts[1].compare(overlapPts[2], 0.0001f) == false)
				overlapOut.set(overlapPts[1], overlapPts[2]);
		}
		else if(numPts == 4)
		{
			// the line segments are identical (after all that checking!)
			overlapOut.set(pt1, pt2);
		}

		// Confirm line segment is long enough to qualify (otherwise we might have a two lines that really
		// just share a single vertex).
		if(overlapOut.length() < minSegLength)
			return false;

		return true;
	}

	// Compute intersection between two lines. Note that this tests their intersection to a small delta of distance.
	//bool intersectLine(LineSeg3D<A> line)
	//{
	//	return intersectLine(line, 0.00001f, null);
	//}

	// Compute intersection between two lines. Note that this tests their intersection to minDistRequiredForCollision.
	bool intersectLine(LineSeg3D<A> line, f32 minDistRequiredForCollision, Vec3<A> poiOut)
	{
		f32 FLOAT_TOLERANCE = 0.00001f;

		f32 s = 0.0f; // these are the scalar values along the directed line segments (must be between 0.1)
		f32 t = 0.0f;

		Vec3<A> POIa = Vec3<A>(0.0f,0.0f,0.0f); // closest POI for this.line segment
		Vec3<A> POIb = Vec3<A>(0.0f,0.0f,0.0f); 

		Vec3<A> d1(this.pt2); 
		d1 -= this.pt1;    // Direction vector of segment S1
		Vec3<A> d2(line.pt2);
		d2 -= line.pt1;    // Direction vector of segment S2
		Vec3<A> r(this.pt1);
		r -= line.pt1;

		f32 a = d1.dot(d1); // Squared length of segment S1, always nonnegative
		f32 e = d2.dot(d2); // Squared length of segment S2, always nonnegative
		f32 f = d2.dot(r);

		// Check if both segments degenerate into points
		if(a <= FLOAT_TOLERANCE && e <= FLOAT_TOLERANCE) 
		{
			// Both segments degenerate into points
			s = 0;
			t = 0;
			POIa.copy(this.pt1);
			POIb.copy(line.pt1);
			Vec3<A> c1c2(POIa);
			c1c2 -= POIb;
			f32 distBetween = Math:sqrt(c1c2.dot(c1c2)); 

			if(distBetween <= minDistRequiredForCollision)
				return true;
			else
				return false;
		}

		//Check if first line degenerates into a point
		if (a <= FLOAT_TOLERANCE) 
		{
			// First segment degenerates into a point
			s = 0.0f;
			t = f / e; // s = 0 => t = (b*s + f) / e = f / e
			t = Math:minMax(0.0f, 1.0f, t);
		} 
		else 
		{
			f32 c = d1.dot(r);
			//Check if second line degenerates into a point
			if (e <= FLOAT_TOLERANCE) 
			{
				// Second segment degenerates into a point
				t = 0.0f;
				s = Math:minMax(0.0f, 1.0f, (-1 * c) / a); // t = 0 => s = (b*t - c) / a = -c / a
			} 
			else 
			{
				// The general nondegenerate case starts here
				f32 b = d1.dot(d2);
				f32 denom = a*e-b*b; // Always nonnegative

				// If segments not parallel, compute closest point on L1 to L2, and
				// clamp to segment S1. Else pick arbitrary s (here 0)
				if(Math:compare(denom, 0.0f) == false) 
					s = Math:minMax(0.0f, 1.0f, (b*f - c*e) / denom);
				else
					s = 0.0f;

				// Compute point on L2 closest to S1(s) using
				// t = Dot((P1+D1*s)-P2,D2) / Dot(D2,D2) = (b*s + f) / e
				t = (b*s + f) / e;

				// If t in [0,1] done. Else clamp t, recompute s for the new value
				// of t using s = Dot((P2+D2*t)-P1,D1) / Dot(D1,D1)= (t*b - c) / a
				// and clamp s to [0, 1]
				if (t < 0.0f)
				{
					t = 0.0f;
					s = Math:minMax(0.0f, 1.0f, (-1 * c) / a);
				} 
				else if (t > 1.0f) 
				{
					t = 1.0f;
					s = Math:minMax(0.0f, 1.0f, (b - c) / a);
				}
			}
		}

		d1 *= s;
		POIa.copy(this.pt1);
		POIa += d1;

		d2 *= t;
		POIb.copy(line.pt1); // + d2 * t;
		POIb += d2;

		Vec3<A> c1c2(POIa);
		c1c2 -= POIb;
		f32 distBetween = Math:sqrt(c1c2.dot(c1c2)); 

		if(distBetween <= minDistRequiredForCollision)
		{
			if(poiOut != null)
				poiOut.copy(POIa);
			return true;
		}

		return false;
	}

	// Measure 'how much' these points are colinear. Smaller values indicate more colinear. The
	// value returned is the smallest distance from P' to LineAB / LineBC / LineAC. Note: There
	// are two ways to define "how colinear". One is the relation of angles between the lines
	// formed by the points (i.e. a triangle). The other is the closest distance from a point P'
	// to the three lines. This method provides the distance.
	shared f32 measureCollinearDist(Vec3<A> a, Vec3<A> b, Vec3<A> c)
	{
		LineSeg3D<A> ab(a, b);
		LineSeg3D<A> bc(b, c);
		LineSeg3D<A> ac(a, c);

		f32 aDist = bc.findClosestPointOnLineToAPoint(a).distanceTo(a);
		f32 bDist = ac.findClosestPointOnLineToAPoint(b).distanceTo(b);
		f32 cDist = ab.findClosestPointOnLineToAPoint(c).distanceTo(c);

		if(aDist < bDist && aDist < cDist)
			return aDist;

		if(bDist < aDist && bDist < cDist)
			return bDist;

		return cDist;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Sphere
////////////////////////////////////////////////////////////////////////////////////////////////////

// Sphere represented by center + radius.
class Sphere<A>
{
	Vec3<A> center();
	A       radius;

	// Construct at 0,0,0 with radius=1.
	void constructor()
	{
		this.center.set(0.0f, 0.0f, 0.0f);
		this.radius = 1.0f;
	}

	// Construct from center + radius.
	void constructor(Vec3<A> center, A radius)
	{
		this.center.copy(center);
		this.radius = radius;
	}

	// Copy constructor.
	void constructor(Sphere<A> v)
	{
		this.center.copy(v.center);
		this.radius = v.radius;
	}

	// Center and radius.
	String<u8> toString()
	{
		String<u8> s(32);
		s.append("center: ");
		s.append(this.center.toString());
		s.append( " radius: ");
		s.append(this.radius);
		return s;
	}

	// Move the sphere center.
	void translate(Vec3<A> xyz)
	{
		this.center += xyz;
	}

	// Scale the radius.
	void scale(A s)
	{
		radius *= s;
	}

	// Copy passed-in.
	void copy(Sphere<A> sphere)
	{
		this.center.copy(sphere.center);
		this.radius = sphere.radius;
	}

	// Set center and radius.
	void set(Vec3<A> center, A radius)
	{
		this.center.copy(center);
		this.radius = radius;
	}

	// Check if spheres are the same (overlap 100%).
	bool compare(Sphere<A> sphere)
	{
		if(sphere.center.compare(this.center) == false)
			return false;
	
		if(Math::compare(this.radius, sphere.radius) == false)
			return false;
	
		return true;
	}

	// Is point inside sphere?
	bool contains(Vec3<A> pt)
	{
		Vec3<A> distVec(this.center);
		distVec -= pt;
		f32 distLen = distVec.length();
	
		if(distLen <= this.radius)
			return true;

		return false;
	}
	
	// Intersection test with ray.
	bool intersectRay(Ray3D<A> ray, Vec3<A> poiOut)
	{
		Vec3<A> p(ray.pt);
		Vec3<A> d(ray.dir);
	
		Vec3<A> m(p);
		m -= this.center;
	
		A b = m.dot(d);
		A c = m.dot(m) - (this.radius * this.radius);
	
		// No intersection if r's origin outside of s (c > 0) and r pointing away from s (b > 0)
		if(c > 0.0 && b > 0.0)
			return false;
	
		A discr = (b * b) - c;
	
		if(discr < 0.0)
			return false;
	
		// ray intersects sphere
		if(poiOut == null)
			return true; // done
	
		// Calculate intersection point.
		A t = (-1.0 * b) - Math:sqrt(discr);
	
		// if t is negative, ray origin inside sphere
		if(t < 0.0)
			t = 0.0;
	
		// move along t in ray direction for POI
		poiOut.copy(ray.dir);
		poiOut *= t;
		poiOut += ray.pt;
		
		return true;
	}

	// Intersection test with a line segment.
	bool intersectLine(LineSeg3D<A> line, Vec3<A> poiOut)
	{
		// special case, line is completely inside sphere
		if(this.contains(line.pt1)  == true && this.contains(line.pt2)  == true)
			return true; // no intersection points, but yes "intersection"
	
		// use the ray test + cutoff
		Vec3<A> poi0();
		Vec3<A> dir(line.pt2);
		dir -= line.pt1;
		dir.normalize();
		Ray3D<A> ray(line.pt1, dir);

		bool intersection = this.intersectRay(ray, poi0);

		// copy intersections (may not be valid, but we want to recycle poi0)
		poiOut.copy(poi0);

		if(intersection  == false)
			return false;
	
		//need to make sure ray intersection point is along line segment
		Vec3<A> toLineEnd(line.pt2);
		toLineEnd -= line.pt1;

		Vec3<A> toIntersection(poi0);
		toIntersection -= line.pt1;

		if(toLineEnd.length() > toIntersection.length())
			return true; //must be point on line

		return false; //beyond end of line segment
	}

	// Intersection test with another sphere.
	bool intersectSphere(Sphere<A> sphere)
	{
		Vec3<A> distVec(this.center);
		distVec -= sphere.center;
		A distLen = distVec.length();
	
		if(distLen < (this.radius + sphere.radius))
			return true;
	
		return false;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Plane
////////////////////////////////////////////////////////////////////////////////////////////////////

// 3D plane.
// Note, by convention, the 2 volumes on either side of the plane are called:
// - Positive half-space: side the normal points into
// - Negative half-space: other side
class Plane<A>
{
	Vec3<A> normal;
	A       dotpt;

	void constructor()
	{
		normal = Vec3<A>(0, 0, 1);
		dotpt  = 0;
	}

	// Create a 3D plane by passing in 3 points 
	void constructor(Vec3<A> p1, Vec3<A> p2, Vec3<A> p3)
	{
		Vec3<A> v1 = Vec3<A>(p1);
		v1 -= p2;
	
		Vec3<A> v2 = Vec3<A>(p3);
		v2 -= p2;
	
		this.normal = Vec3<A>(v1);
		this.normal.cross(v2);
		this.normal.normalize();
	
		this.dotpt = this.normal.dot(p2);
	}

	// The plane normal and a point on the plan
	void constructor(Vec3<A> normal, Vec3<A> pt)
	{
		this.normal = Vec3<A>(normal);
		this.normal.normalize();
		this.dotpt = this.normal.dot(pt);
	}

	// Copy constructor.
	void constructor(Plane<A> v)
	{
		this.normal = Vec3<A>(v.normal);
		this.dotpt  = v.dotpt;
	}

	// Copy exact.
	void copy(Plane<A> p)
	{
		this.normal.copy(p.normal);
		this.dotpt = p.dotpt;
	}

	// Set from normal and point on the plance.
	void set(Vec3<A> normal, Vec3<A> pointOnPlane)
	{
		this.normal.copy(normal);
		this.normal.normalize();
		this.dotpt = this.normal.dot(pointOnPlane);
	}

	// Compare against another plane.
	bool compare(Plane<A> t, f32 minDistApart)
	{
		//first, confirm parallel via normals same (including inverted)
		Vec3<A> invNormal = Vec3<A>(this.normal);
		invNormal.invert();
		if(this.normal.compare(t.normal, 0.0001f) == false && invNormal.compare(t.normal, 0.0001f) == false)
		{
			return false;
		}
	
		// Shoot a line through planes checking if they have the same POI. There are definitely more
		// efficient ways to check if planes are same (i.e. converting to cartesian form and checking 
		// a point) but they are more complex with more edge cases.
		Vec3<A> normalOffset(this.normal);
		normalOffset *= -100.0;

		Ray3D<A> ray = Ray3D<A>(normalOffset, normal); // -100.0f because ray needs to go in opposite direction of origin point pushed out (push one way, dir other)
		Vec3<A> poi0 = Vec3<A>();
		Vec3<A> poi1 = Vec3<A>();
		if(this.intersectRay(ray, poi0) == true)
		{
			if(t.intersectRay(ray, poi1) == true)
			{
				if(poi0.compare(poi1, minDistApart) == true)
				{
					return true;
				}
			}
		}
		else
		{
			// invert ray, try other direction
			normalOffset.copy(invNormal);
			normalOffset *= -100.0;
			ray = Ray3D<A>(normalOffset, invNormal); // -100.0f because ray needs to go in opposite direction of origin point pushed out (push one way, dir other)
			if(this.intersectRay(ray, poi0) == true && t.intersectRay(ray, poi1) == true)
			{
				if(poi0.compare(poi1, minDistApart)  == true)
				{
					return true;
				}
			}
		}

		return false;
	}

	// Normal and dot product value.
	String<u8> toString()
	{
		String<u8> s();
		
		s.append(" Normal:");
		s.append(this.normal.toString());
		s.append(" DotPt: ");
		s.append(this.dotpt);
		s.append(" ");

		return s;
	}

	// Distance from point to plane
	A distanceToPlane(Vec3<A> pt)
	{
		Vec3<A> closePt = findClosestPointOnPlaneToAPoint(pt);
		return closePt.distanceTo(pt);
	}

	// Closest point on plane to an arbitrary point (on, or not on place) - returns distance between point and plane.
	Vec3<A> findClosestPointOnPlaneToAPoint(Vec3<A> pt)
	{
		A t = (this.normal.dot(pt) - this.dotpt) / this.normal.dot(this.normal);
		Vec3<A> n(this.normal);
		n *= t;
		Vec3<A> p(pt);
		p -= n;
	
		return p;
	}

	// Project point onto plane - this is slightly different from findClosestPointOnPlaneToAPoint() since you provide the normal. Note, if the normal points away from the plane, this returns false.
	bool projectPointOntoPlane(Vec3<A> pt, Vec3<A> ptNormal, Vec3<A> projPtOut)
	{
		Ray3D<A> ray = Ray3D<A>(pt, ptNormal);
		return intersectRay(ray, projPtOut);
	}

	// Is the passed-in point contained in the positive half-space? (i.e. the volume that the plane normal points into).
	bool pointInPositiveHalfSpace(Vec3<A> pt)
	{
		A dist = pt.dot(this.normal) - this.dotpt;
		return dist > 0.0f;
	}

	// Is the passed-in point contained in the negative half-space? (i.e. the volume opposite of the plane normal).
	bool pointInNegativeHalfSpace(Vec3<A> pt)
	{
		A dist = pt.dot(this.normal) - this.dotpt;
		return dist < 0.0f;
	}

/*
	// Is the passed-in sphere contained in the positive half-space? (i.e. the volume that the plane normal points into).
	bool sphereInPositiveHalfSpace(Sphere<Vertex> & sphere)
	{
		f32 dist = sphere.center.dot(this.normal) - this.dotpt;
		return dist > sphere.radius;
	}

	// Is the passed-in sphere contained in the negative half-space? (i.e. the volume opposite of the plane normal).
	bool sphereInNegativeHalfSpace(Sphere<Vertex> & sphere)
	{
		f32 dist = sphere.center.dot(this.normal) - this.dotpt;
		return dist < sphere.radius;
	}

	// Is the passed-in line segment contained completely in the positive half-space? (i.e. the volume that the plane normal points into).
	bool lineInPositiveHalfSpace(LineSeg3D & line)
	{
		if(this.pointInPositiveHalfSpace(line.pt1)  == false)
			return false;
		if(this.pointInPositiveHalfSpace(line.pt2)  == false)
			return false;
	
		return true;
	}

	// Is the passed-in line segment contained completely in the negative half-space? (i.e. the volume that the plane normal points away from).
	bool lineInNegativeHalfSpace(LineSeg3D & line)
	{
		if(this.pointInNegativeHalfSpace(line.pt1)  == false)
			return false;
		if(this.pointInNegativeHalfSpace(line.pt2)  == false)
			return false;

		return true;
	}*/

	// Is the passed-in ray contained completely in the positive half-space? (i.e. the volume that the plane normal points into).
	bool rayInPositiveHalfSpace(Ray3D<A> ray)
	{
		Vec3<A> poi = Vec3<A>();

		if(this.intersectRay(ray, poi)  == true)
			return false; //ray is in both spaces
		if(this.pointInPositiveHalfSpace(ray.pt)  == false)
			return false; //ray starts in wrong space

		return true;
	}

	// Is the passed-in ray contained completely in the negative half-space? (i.e. the volume that the plane normal points into).
	bool rayInNegativeHalfSpace(Ray3D<A> ray)
	{
		Vec3<A> poi = Vec3<A>();

		if(this.intersectRay(ray, poi) == true)
			return false; //ray is in both spaces
		if(this.pointInNegativeHalfSpace(ray.pt) == false)
			return false; //ray starts in wrong space

		return true;
	}
/*
	// Intersection test between this plane and a 3D line.
	bool intersectLine(LineSeg3D & lineIn, Vec3 & poiOut)
	{
		Vec3 lineDir =  Vec3(lineIn.pt1);
		lineDir.subtractVector(lineIn.pt2);

		f32 t = (this.dotpt - this.normal.dot(lineIn.pt2)) / this.normal.dot(lineDir);
		
		if(t >= 0.0 && t <= 1.0)
		{
			lineDir.multiplyScalar(t);
			poiOut.copy(lineIn.pt2);
			poiOut.addVector(lineDir);
		
			return true; //yes, Point Of Intersection
		}

		return false;
	}*/

	// Intersection test between this plane and a 3D ray. If the ray/plane intersection is really far away (> 10000 units) this may fail.
	bool intersectRay(Ray3D<A> ray, Vec3<A> poiOut)
	{
		// sanity check special case: ray origin is basically a point on plane
		Vec3<A> closestPt = findClosestPointOnPlaneToAPoint(ray.pt);
		if(closestPt.distanceTo(ray.pt) < 0.001f)
		{
			if(poiOut != null)
				poiOut.copy(ray.pt);

			return true;
		}

		// Using line segment / plane intersection test with ray arbitrarily stretched long

		//Vec3<A> pt2     = ray.pt + (ray.dir * 10000.0f);
		Vec3<A> pt2 = Vec3<A>(ray.pt);
		pt2 += Vec3<A>(ray.dir.p[0] * 10000.0f, ray.dir.p[1] * 10000.0f, ray.dir.p[2] * 10000.0f);

		//Vec3<A> lineDir = pt2 - ray.pt;
		Vec3<A> lineDir = Vec3<A>(pt2);
		lineDir -= ray.pt;

		// Compute t scalar value along ray length
		A tDenom = this.normal.dot(lineDir);
		if(Math:compare(tDenom, 0.0f, 0.00001f) == true) // line and plane are parallel
		{
			return false;
		}

		A t = (this.dotpt - this.normal.dot(ray.pt)) / tDenom;

		if(t >= 0.0f && t <= 1.0f)
		{
			lineDir *= t;
			if(poiOut != null)
			{
				poiOut.copy(ray.pt + lineDir);
			}
		
			return true; //yes, Point Of Intersection
		}

		return false;
	}
/*
	// Test if sphere intersects this plane.
	bool intersectSphere(Sphere<Vertex> & sphere)
	{
		A dist = sphere.center.dot(this.normal) - this.dotpt;
	
		if(std::abs(dist) <= sphere.radius)
			return true;
	
		return false;
	}*/

	// Intersection test between this plane and another plane. Planes will intersect as long as they are not parallel to each other.
	bool intersectPlane(Plane<A> plane, Ray3D<A> lineOut)
	{
		Vec3<A> tempDir(this.normal);
		tempDir.cross(plane.normal);
	
		//if d is zero, planes are parallel
		if(Math:compare(tempDir.dot(tempDir), 0.0f)  == true)
		{
			return false;
		}

		lineOut.dir.copy(tempDir);
	
		A d11 = this.normal.dot(this.normal);
		A d12 = this.normal.dot(plane.normal);
		A d22 = plane.normal.dot(plane.normal);
	
		A denom = (d11 * d22) - (d12 * d12);
		A k1 = ((this.dotpt*d22)  - (plane.dotpt*d12)) / denom;
		A k2 = ((plane.dotpt*d11) - (this.dotpt*d12))  / denom;

		//Line intersection
		lineOut.pt.copy(this.normal);
		lineOut.pt *= k1;
		Vec3<A> temp0 = Vec3<A>(plane.normal);
		temp0 *= k2;
		lineOut.pt += temp0;
	
		return true;
	}

	// Mirror a point from one side of plane to the other
	Vec3<A> mirror(Vec3<A> pt)
	{
		if(distanceToPlane(pt) < 0.0001f)
		{
			// don't move the point, it's "on the plane" for all reasonable intents
			return Vec3<A>(pt);
		}

		Vec3<A> planePt = findClosestPointOnPlaneToAPoint(pt);
		Vec3<A> segmentToPlane = Vec3<A>(pt);
		segmentToPlane -= planePt;

		Vec3<A> invSegmentToPlane = Vec3<A>(segmentToPlane); // Vec3<A>::invert(segmentToPlane);
		invSegmentToPlane.invert();

		/*
		if(pointInPositiveHalfSpace(pt) == true)
		{
			// test that plane normal is same as segment
			//VERT(Vec3<A>::normalize(segmentToPlane).compare(normal, 0.1f) == true);
		}
		else
		{
			// test that plane normal is same as segment inverted
			//VERT(Vec3<A>::normalize(invSegmentToPlane).compare(normal, 0.1f) == true);
		}*/

		Vec3<A> res(planePt);
		res += invSegmentToPlane;
		return res;
	}
}