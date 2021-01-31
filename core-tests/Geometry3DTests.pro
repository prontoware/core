////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class Line3DTests implements IUnitTest
{
	void run()
	{
		LineSeg3D<f32> line1(0, 0, 0, 1, 0, 0);
		LineSeg3D<f32> line2(Vec3<f32>(0, 0, 0), Vec3<f32>(0, 1, 0));
		test(Math:compare(line1.length(), 1.0f, 0.0001f) == true);

		Vec3<f32> v = line1.midPoint();
		test(v.compare(Vec3<f32>(0.5, 0, 0), 0.001f) == true);

		// Test closest point on line to an arbitrary point - answer should be (0,0,0)
		Vec3<f32> linePt(1.0, -1.0, 0.0);
		LineSeg3D<f32> line(0.0, 0.0, 0.0,  0.0, 1.0, 0.0);
		Vec3<f32> lineClosestPt(line.findClosestPointOnLineToAPoint(linePt));
		test(lineClosestPt.compare(Vec3<f32>(0.0, 0.0, 0.0), 0.001f) != false);

		// Test closest distance between two lines (an intersection test that effectively considers that precision is only
		// guaranteed to a certain level of accuracy).
		LineSeg3D<f32> lineA(0.0f, 1.0f, 0.0f, 0.0f, -1.0f, 0.0f);
		LineSeg3D<f32> lineB(-1.5f, 0.5f, 0.0f, 2.0f, 0.3f, 0.0f);
		test(lineA.intersectLine(lineB, 0.1f, null) != false);

		// Scale
		line1 = LineSeg3D<f32>(0, 0, 0, 1, 0, 0);
		line1.scale(1.1f);
		test(line1.pt1.compare(Vec3<f32>(-0.05f, 0.0f, 0.0f)) == true);
		test(line1.pt2.compare(Vec3<f32>(1.05f, 0.0f, 0.0f)) == true);

		// Line overlap - test 1, no overlap (not parallel, not touching)
		LineSeg3D<f32> lineOverlap();
		lineA = LineSeg3D<f32>(0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
		lineB = LineSeg3D<f32>(1.0f, 0.0f, 0.0f, 2.0f, 0.0f, 0.0f);
		test(lineA.overlapsWith(lineB, lineOverlap) == false);

		// Line overlap - test 2, no overlap (not parallel, yes touching at vertex)
		lineA = LineSeg3D<f32>(0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
		lineB = LineSeg3D<f32>(0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f);
		test(lineA.overlapsWith(lineB, lineOverlap) == false);

		// Line overlap - test 3, no overlap (yes parallel, yes touching at vertex)
		lineA = LineSeg3D<f32>(0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
		lineB = LineSeg3D<f32>(0.0f, 1.0f, 0.0f, 0.0f, 2.0f, 0.0f);
		test(lineA.overlapsWith(lineB, lineOverlap) == false);

		// Line overlap - test 4, yes overlap (line B is totally within line A)
		lineA = LineSeg3D<f32>(0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
		lineB = LineSeg3D<f32>(0.0f, 0.1f, 0.0f, 0.0f, 0.9f, 0.0f);
		test(lineA.overlapsWith(lineB, lineOverlap) == true);
		test(lineOverlap.compare(lineB, 0.001f) == true);

		// Line overlap - test 5, yes overlap (share a vertex)
		lineA = LineSeg3D<f32>(0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
		lineB = LineSeg3D<f32>(0.0f, 0.0f, 0.0f, 0.0f, 0.9f, 0.0f);
		test(lineA.overlapsWith(lineB, lineOverlap) == true);
		test(lineOverlap.compare(lineB, 0.001f) == true);

		// Line overlap - test 6, yes overlap (share both vertices)
		lineA = LineSeg3D<f32>(0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
		lineB = LineSeg3D<f32>(0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
		test(lineA.overlapsWith(lineB, lineOverlap) == true);
		test(lineOverlap.compare(lineB, 0.001f) == true);
	}
}

class Ray3DTests implements IUnitTest
{
	void run()
	{
		Ray3D<f32> ray1(0, 0, 0, 1, 0, 0);
		Ray3D<f32> ray2(ray1);
		test(ray1.pt.compare(ray2.pt) == true);
		test(ray1.dir.compare(ray2.dir) == true);
	}
}

class PlaneTests implements IUnitTest
{
	void run()
	{
		Plane<f32> plane1(Vec3<f32>(0.0, 1.0, 0.0), Vec3<f32>(0.0, 2.0, 0.0));
		Plane<f32> plane2(plane1); // test copy
		test(plane1.normal.compare(plane2.normal) == true);
		
		// Test closest point to plane
		Vec3<f32> planePt(1.0, 3.0, 0.0);
		Vec3<f32> planeClosestPt = plane2.findClosestPointOnPlaneToAPoint(planePt);
		test(planeClosestPt.compare(Vec3<f32>(1, 2, 0)) == true);
			
		// Test ray against plane - intersection
		Vec3<f32> poi();
		Ray3D<f32> ray(0,2,0, 0,-1,0); // down towards plane
		plane1 = Plane<f32>(Vec3<f32>(0,1,0), Vec3<f32>(0,0,0));
		test(plane1.intersectRay(ray, poi) == true);
		test(poi.compare(Vec3<f32>(0,0,0), 0.01f) == true);

		// Test ray against plane - no intersection
		poi = Vec3<f32>();
		ray = Ray3D<f32>(0,2,0, 0,1,0); // going away from plane
		plane1 = Plane<f32>(Vec3<f32>(0,1,0), Vec3<f32>(0,0,0));
		test(plane1.intersectRay(ray, poi) == false);
	}
}