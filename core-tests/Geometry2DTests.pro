////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class Rectangle2DTests implements IUnitTest
{
	void run()
	{
		Rectangle2D<i32> rectA(0, 0, 1, 2);
		test(rectA.getWidth() == 1);
		test(rectA.getHeight() == 2);

		rectA.setWidth(3);
		test(rectA.getWidth() == 3);
	}
}

class Polygon2DTests implements IUnitTest
{
	void run()
	{
		Polygon2D<f32> polyA(f32(0, 0), f32(1, 0), f32(1, 1));
		test(polyA.pts.size() == 3);

		Rectangle2D<f32> bounds = polyA.getBounds();
		test(bounds.getWidth() >= 0.9f && bounds.getHeight() >= 0.9f);

		// triangulate concave polygon
		Polygon2D<f32> polyB();
		polyB.pts.add(f32(0, 0));
		polyB.pts.add(f32(1, 0));
		polyB.pts.add(f32(1, 1));
		polyB.pts.add(f32(0.9, 0.1));
		polyB.pts.add(f32(0.4, 0.2));

		ArrayList<Polygon2D<f32>> tris = polyB.triangulate();
		test(tris.size() == 3);

		// check first tri (this is a key indicator algo is working, it's the first ear, but not the first 3 vertices as ordered in polyB)
		Polygon2D<f32> t0 = tris[0];
		test(t0.pts[0].equals(f32(0.4, 0.2)) == true); // index is "-1"
		/*
		{
			for(u32 t=0; t<tris.size(); t++)
			{
				Log:log("tri #" + t);
				Polygon2D<f32> curTri = tris[t];
				for(u32 p=0; p<curTri.pts.size(); p++)
				{
					Log:log("" + String<u8>:formatNumber(curTri.pts[p][0]) + ", " + String<u8>:formatNumber(curTri.pts[p][1]));
				}
			}
			return 4;
		}*/

		test(t0.pts[1].equals(f32(0, 0)) == true);
	}
}