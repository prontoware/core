////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Line2D
////////////////////////////////////////////////////////////////////////////////////////////////////

// Line segment.
class Line2D<A>
{
	A[4] pts; // x0, y0, x1, y1

	// 0,0 to 0,0
	void constructor()
	{
		pts[0] = 0;
		pts[1] = 0;
		pts[2] = 0;
		pts[3] = 0;
	}

	// Pass in two points on line.
	void constructor(A x0, A y0, A x1, A y1)
	{
		pts[0] = x0;
		pts[1] = y0;
		pts[2] = x1;
		pts[3] = y1;
	}

	// Copy contructor.
	void constructor(Line2D<A> line)
	{
		this.pts = line.pts;
	}

	// Copy passed-in.
	void copy(Line2D<A> line)
	{
		this.pts = line.pts;
	}

	// Pass in two points on line.
	void set(A x0, A y0, A x1, A y1)
	{
		pts[0] = x0;
		pts[1] = y0;
		pts[2] = x1;
		pts[3] = y1;
	}

	// Overload []
	A get(u64 index)
	{
		return pts[index];
	}

	// Overload []
	void set(u64 index, A val)
	{
		pts[index] = val;
	}

	// Coordinates
	String<u8> toString()
	{
		String<u8> s();
		s += String<u8>:formatNumber(pts[0]);
		s.append(Chars:COMMA, Chars:SPACE);
		s += String<u8>:formatNumber(pts[1]);
		s.append(Chars:COMMA, Chars:SPACE);
		s += String<u8>:formatNumber(pts[2]);
		s.append(Chars:COMMA, Chars:SPACE);
		s += String<u8>:formatNumber(pts[3]);
		return s;
	}

	// Min/max x/y in returned rectangle.
	Rectangle2D<A> getBounds()
	{
		Rectangle2D<A> rect = Rectangle2D<A>();

		if(pts[0] < pts[2])
		{
			rect.setMinX(pts[0]);
			rect.setWidth(pts[2] - pts[0]);
		}
		else
		{
			rect.setMinX(pts[2]);
			rect.setWidth(pts[0] - pts[2]);
		}

		if(pts[1] < pts[3])
		{
			rect.setMinY(pts[1]);
			rect.setHeight(pts[3] - pts[1]);
		}
		else
		{
			rect.setMinY(pts[3]);
			rect.setHeight(pts[1] - pts[3]);
		}

		return rect;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Rectangle2D
////////////////////////////////////////////////////////////////////////////////////////////////////

// Rectangle representation that represents regular rectangles.
class Rectangle2D<A>
{
	A[4] r; // vector of 2x points, x0, y0, width, height

	// Construct zero rectangle.
	void constructor()
	{
		r[0] = 0;
		r[1] = 0;
		r[2] = 0;
		r[3] = 0;
	}

	// Construct rectangle from top-left corner and width/height
	void constructor(A[4] rect)
	{
		r[0] = rect[0];
		r[1] = rect[1];
		r[2] = rect[2];
		r[3] = rect[3];
	}

	// Construct rectangle from min x/y corner and width/height.
	void constructor(A x, A y, A width, A height)
	{
		r[0] = x;
		r[1] = y;
		r[2] = width;
		r[3] = height;
	}

	// Copy contructor.
	void constructor(Rectangle2D<A> rect)
	{
		this.r = rect.r;
	}

	// Copy passed-in.
	void copy(Rectangle2D<A> rect)
	{
		this.r = rect.r;
	}

	// x, y width, height.
	String<u8> toString()
	{
		String<u8> s();
		s += String<u8>:formatNumber(r[0]);
		s.append(Chars:COMMA, Chars:SPACE);
		s += String<u8>:formatNumber(r[1]);
		s.append(Chars:COMMA, Chars:SPACE);
		s += String<u8>:formatNumber(r[2]);
		s.append(Chars:COMMA, Chars:SPACE);
		s += String<u8>:formatNumber(r[3]);
		return s;
	}

	// Copy passed-in.
	void set(Rectangle2D<A> rect)
	{
		this.r = rect.r;
	}

	// Set rectangle.
	void set(A x, A y, A width, A height)
	{
		r[0] = x;
		r[1] = y;
		r[2] = width;
		r[3] = height;
	}

	// Set rectangle.
	void set(A[4] rect)
	{
		r[0] = rect[0];
		r[1] = rect[1];
		r[2] = rect[2];
		r[3] = rect[3];
	}

	// Clone this.
	Rectangle2D<A> clone()
	{
		return Rectangle2D<A>(this.r);
	}

	// Overload []
	A get(u64 index)
	{
		return r[index];
	}

	// Overload []
	void set(u64 index, A val)
	{
		r[index] = val;
	}

	// Get minimum x.
	A getMinX()
	{
		return r[0];
	}

	// Set minimum x, inclusive.
	void setMinX(A val)
	{
		r[0] = val;
	}

	// Get minimum y.
	A getMinY()
	{
		return r[1];
	}

	// Set minimum y, inclusive.
	void setMinY(A val)
	{
		r[1] = val;
	}

	// Get maximum x.
	A getMaxX()
	{
		return r[0] + (r[2]);
	}

	// Set maximum x, inclusive.
	void setMaxX(A val)
	{
		r[2] = (val) - r[0];
	}

	// Get maximum y.
	A getMaxY()
	{
		return r[1] + (r[3]);
	}

	// Set maximum y, inclusive.
	void setMaxY(A val)
	{
		r[3] = (val) - r[1];
	}

	// Get absolute width.
	A getWidth()
	{
		return r[2];
	}

	// Get absolute height.
	A getHeight()
	{
		return r[3];
	}

	// Set width
	void setWidth(A width)
	{
		r[2] = width;
	}

	// Set height.
	void setHeight(A height)
	{
		r[3] = height;
	}

	// Contains point? Inclusive of edges.
	bool contains(A x, A y)
	{
		if(x >= r[0] && x <= getMaxX() && y >= r[1] && y <= getMaxY())
			return true;

		return false;
	}

	// Contains another rectangle? Inclusive.
	bool contains(Rectangle2D<A> r)
	{
		if(contains(r.getMinX(), r.getMinY()) == true && contains(r.getMaxX(), r.getMaxY()) == true)
			return true;

		return false;
	}

	// Shrink with relative 0..1 factor.
	void shrink(f64 xFactor, f64 yFactor)
	{
		A xDiff = getWidth() * (xFactor * 0.5);
		A yDiff = getHeight() * (yFactor * 0.5);

		r[0] += xDiff;
		r[1] += yDiff;
		r[2] -= (xDiff * 2);
		r[3] -= (yDiff * 2);
	}

	// Enlarge with relative 0..1 factor.
	void enlarge(f64 xFactor, f64 yFactor)
	{
		A xDiff = getWidth() * (xFactor * 0.5);
		A yDiff = getHeight() * (yFactor * 0.5);

		r[0] -= xDiff;
		r[1] -= yDiff;
		r[2] += (xDiff * 2);
		r[3] += (yDiff * 2);
	}

	// Shrink with absolute values.
	void shrinkAbs(A valX, A valY)
	{
		r[0] += (valX * 0.5);
		r[1] += (valY * 0.5);
		r[2] -= valX;
		r[3] -= valY;
	}

	// Enlarge with absolute values.
	void enlargeAbs(A valX, A valY)
	{
		r[0] -= (valX * 0.5);
		r[1] -= (valY * 0.5);
		r[2] += valX;
		r[3] += valY;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Polygon2D
////////////////////////////////////////////////////////////////////////////////////////////////////

// Polygon representation that represents convex/concave shapes with no holes.
class Polygon2D<A>
{
	ArrayList<A[2]> pts = ArrayList<A[2]>(); // points must always be in edge connecting order.

	// Empty polygon.
	void constructor()
	{

	}

	// From list of x/y points.
	void constructor(A[] inPts)
	{
		for(u64 c=0; c<inPts.length()-1; c+=2)
		{
			A[2] pt;
			pt[0] = inPts[c+0];
			pt[1] = inPts[c+1];
			pts.add(pt);
		}
	}

	// From list of x/y points.
	void constructor(ICollection<Vec2<A>> inPts)
	{
		IIterator<Vec2<A>> iter = inPts.getIterator();
		while(iter.hasNext())
		{
			Vec2<A> xy = iter.next();
			A[2] pt;
			pt[0] = xy[0];
			pt[1] = xy[1];
			pts.add(pt);
		}
	}

	// From list of x/y points.
	void constructor(ICollection<A[2]> inPts)
	{
		IIterator<A[2]> iter = inPts.getIterator();
		while(iter.hasNext())
		{
			A[2] xy = iter.next();
			pts.add(xy);
		}
	}

	// Copy passed-in polygon.
	void constructor(Polygon2D<A> poly)
	{
		copy(poly);
	}

	// Construct triangle.
	void constructor(A[2] p0, A[2] p1, A[2] p2)
	{
		pts.add(p0);
		pts.add(p1);
		pts.add(p2);
	}

	// Set as triangle.
	void setTriangle(A[2] p0, A[2] p1, A[2] p2)
	{
		pts.clear();

		pts.add(p0);
		pts.add(p1);
		pts.add(p2);
	}

	// Delete all points.
	void clear()
	{
		pts.clear();
	}

	// Copy passed-in polygon.
	void copy(Polygon2D<A> poly)
	{
		clear();
		for(u64 p=0; p<poly.pts.size(); p++)
		{
			pts.add(poly.pts[p]);
		}
	}

	// x, y width, height.
	String<u8> toString()
	{
		String<u8> s();
		for(u64 p=0; p<pts.size(); p++)
		{
			s.append(Chars:OPEN_PARENTHESIS);
			s += String<u8>:formatNumber(pts[p][0]);
			s.append(Chars:COMMA, Chars:SPACE);
			s += String<u8>:formatNumber(pts[p][1]);
			s.append(Chars:CLOSE_PARENTHESIS);
		}

		return s;
	}

	// Get point by index. Negative indices wrap around.
	A[2] getPoint(i64 index)
	{
		index = Math:wrap(0, pts.size()-1, index);
		return pts[index];
	}

	// Translate all points by an offset.
	void translate(A[2] xy)
	{
		for(u64 p=0; p<pts.size(); p++)
			pts[p] += xy;
	}

	// Min/max x/y in returned rectangle.
	Rectangle2D<A> getBounds()
	{
		Rectangle2D<A> rect = Rectangle2D<A>();
		if(pts.size() < 1)
			return rect;

		// Starting min/max
		rect.r[0] = pts[0][0];
		rect.r[1] = pts[0][1];
		rect.r[2] = pts[0][0];
		rect.r[3] = pts[0][1];

		for(u64 p=0; p<pts.size(); p++)
		{
			A[2] pt = pts[p];

			// min x/y
			if(pt[0] < rect.r[0])
				rect.r[0] = pt[0];
			if(pt[1] < rect.r[1])
				rect.r[1] = pt[1];

			// max x/y
			if(pt[0] > rect.r[2])
				rect.r[2] = pt[0];
			if(pt[1] > rect.r[3])
				rect.r[3] = pt[1];
		}

		return rect;
	}

	// Check if a point is contained within this polygon.
	bool contains(A[2] pt)
	{
		// http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html
	    bool inside = false;
	    u64 ptsSize = pts.size();
	    u64 j = ptsSize - 1;
	    for(u64 i=0; i<ptsSize; i++)
	    {
	    	if(i != 0)
	    		j = i - 1;

	    	// must be done as floating-point, integer math would need changes to inequalities etc.
	        if((f32(pts.data[i][1]) > f32(pt[1])) != (f32(pts.data[j][1]) > f32(pt[1])))
	        {
	            if(f32(pt[0]) < (f32(pts.data[j][0]) - f32(pts.data[i][0])) * (f32(pt[1]) - f32(pts.data[i][1])) / (f32(pts.data[j][1]) - f32(pts.data[i][1])) + f32(pts.data[i][0]))
		        {
		            inside = !inside;
		        }
	    	}
	    }

		return inside;
	}

	// Triangulate.
	ArrayList<Polygon2D<A>> triangulate()
	{
		ArrayList<Polygon2D<A>> tris();

		// ear clipping method
		Polygon2D<A> curPoly(this);

		while(curPoly.pts.size() > 3)
		{
			// find ear
			u64 curNumPts = curPoly.pts.size();
			Polygon2D<A> ear();
			for(i64 p=0; p<curPoly.pts.size(); p++)
			{
				// use next three points
				A[2] p0 = curPoly.getPoint(p-1);
				A[2] p1 = curPoly.getPoint(p);
				A[2] p2 = curPoly.getPoint(p+1);

				ear.pts.clear();
				ear.pts.add(p0);
				ear.pts.add(p1);
				ear.pts.add(p2);

				// check if any of the original polygon points are inside this ear (in which case, not a ear).
				bool validEar = true;
				for(i64 c=0; c<this.pts.size(); c++)
				{
					if(ear.pts[0].equals(this.pts[c]) == true)
						continue;
					if(ear.pts[1].equals(this.pts[c]) == true)
						continue;
					if(ear.pts[2].equals(this.pts[c]) == true)
						continue;

					if(ear.contains(this.pts[c]) == true)
					{
						validEar = false;
						break;
					}
				}

				if(validEar == true)
				{
					tris.add(ear);
					curPoly.pts.remove(p);
					ear = Polygon2D<A>();
					break;
				}
			}

			if(curNumPts == curPoly.pts.size())
			{
				tris.clear(); // failed to triangulate
				return tris;
			}
		}

		tris.add(curPoly); // last triangle

		return tris;
	}
}