// TO DO! rework everything to count with deltas!!! 
// TO DO! rework DoLinePartiallyBelongsToBox deltas

#include "Math.h"

#include <algorithm>
#include <limits>
#include <cmath>

#include "Box.h"
#include "DataType.h"
#include "Line.h"
#include "Point.h"

/*
 ******************************************************************************
 ******************************** POINT and POINT *****************************
 ******************************************************************************
 */

/*! \brief Returns true, if p is in bounding box defined by p1 and p2.
*
*/
bool IsPointBetween(
	const Point& p,
	const Point& p1,
	const Point& p2)
{
	const DataType 
		min_x = std::min(p1.get_x(), p2.get_x()),
		max_x = std::max(p1.get_x(), p2.get_x()),
		min_y = std::min(p1.get_y(), p2.get_y()),
		max_y = std::max(p1.get_y(), p2.get_y());

	return (
		min_x <= p.get_x() &&
		max_x >= p.get_x() &&
		min_y <= p.get_y() &&
		max_y >= p.get_y());
}

/*! \brief Returns point having coordinates equal to arithmetic mean of p1 
 *  and p2.
 *
 */
Point GetPointBetween(
	const Point& p1,
	const Point& p2)
{
	return Point(
		(p1.get_x() + p2.get_x()) / 2.0,
		(p1.get_y() + p2.get_y()) / 2.0);
}

/*! \brief Returns point having coordinates equal to arithmetic mean of points.
 *
 */
Point GetPointBetween(
	const std::vector<Point>& points)
{
	DataType x = 0.0;
	DataType y = 0.0;
	for (auto& p : points)
	{
		x += p.get_x();
		y += p.get_y();
	}
	x = x / (double)points.size();
	y = y / (double)points.size();
	return Point(x, y);
}

/*
 ******************************************************************************
 ******************************** POINT and LINE ******************************
 ******************************************************************************
 */

/*! \brief Returns true, if p is on the right side of the direction from 
 *  p1 to p2.
 *
 */
bool IsOnTheRight(
	const Point& p1,
	const Point& p2,
	const Point& p)
{
	double anglepath1 = GetAngle(p1, p2);
	double anglepath2 =
		anglepath1 + M_PI >= 2 * M_PI ?
		std::fmod((anglepath1 + M_PI), 2 * M_PI) :
		anglepath1 + M_PI;
	double angleclosest = GetAngle(p1, p);

	if (anglepath1 == angleclosest || 
		anglepath2 == angleclosest)
	{
		return false;
	}

	if (anglepath1 < anglepath2)
	{
		if (anglepath1 < angleclosest &&
			angleclosest < anglepath2)
			return true;
		else
			return false;
	}
	// (anglepath2 < anglepath1)
	else
	{
		// 2 possibilities
		if ((anglepath1 < angleclosest &&
			 angleclosest < anglepath2 + 2 * M_PI) ||
			(anglepath1 < angleclosest + 2 * M_PI &&
			 angleclosest + 2 * M_PI < anglepath2 + 2 * M_PI))
			return true;
		else
			return false;;
	}

	// throw warning
	return false;
}

/*! \brief Returns true, if p is on the left side of the direction from 
 *  p1 to p2.
 *
 */
bool IsOnTheLeft(
	const Point& p1,
	const Point& p2,
	const Point& p)
{
	double anglepath1 = GetAngle(p1, p2);
	double anglepath2 =
		anglepath1 + M_PI >= 2 * M_PI ?
		std::fmod((anglepath1 + M_PI), 2 * M_PI) :
		anglepath1 + M_PI;
	double angleclosest = GetAngle(p1, p);

	if (anglepath1 == angleclosest ||
		anglepath2 == angleclosest)
	{
		return false;
	}

	if (anglepath1 < anglepath2)
	{
		if (anglepath1 < angleclosest &&
			angleclosest < anglepath2)
			return false;
		else
			return true;
	}
	// (anglepath2 < anglepath1)
	else
	{
		// 2 possibilities
		if ((anglepath1 < angleclosest &&
			 angleclosest < anglepath2 + 2 * M_PI) ||
			(anglepath1 < angleclosest + 2 * M_PI &&
			 angleclosest + 2 * M_PI < anglepath2 + 2 * M_PI))
			return false;
		else
			return true;
	}

	// throw warning
	return false;
}

/*
 ******************************************************************************
 ****************************** PERPENDICULAR LINE ****************************
 ******************************************************************************
 */

/*! \brief Function will return pair of Points First point in pair is mid point
 *  of segment line between p1 and p2. Second point in pair belongs to 
 *  perpendicular line to line between p1 and p2 in specified distance.
 *  Direction of line between p1 and p2 is from p1 to p2.
 *  If (in_direction_of_fst) then second point of pair belongs to ray belonging 
 *  to part of line in angle 90° in negative direction with line between p1 and 
 *  p2. 
 *  If (! in_direction_of_fst) then second point of pair belongs to ray belonging
 *  to part of line in angle 90° in positive direction with line between p1 and
 *  p2.
 *
 */
std::pair<Point, Point> GetPerpendicularInMid(
	const Point& p1,
	const Point& p2,
	bool  in_direction_of_fst,
	const double distance)
{
	const Point mid(
		(p1.get_x() + p2.get_x()) / 2.0,
		(p1.get_y() + p2.get_y()) / 2.0);

	const double original_angle =
		GetAngle(mid, p2);

	// we will get angle of perpendicular_line
	double perp_angle =
		in_direction_of_fst ? original_angle + M_PI_2 : original_angle + 3 * M_PI_2;

	if (perp_angle >= 2 * M_PI)
		perp_angle = std::fmod(perp_angle, 2 * M_PI);

	// becouse we are using angle in negative direction then
	perp_angle = -perp_angle;

	// we will get coordinates of perpendicular line from point (0,0)
	const double nx = distance * std::cos(perp_angle);
	const double ny = distance * std::sin(perp_angle);

	// we will get point on the perpendicular_line
	const Point p(nx + mid.get_x(), ny + mid.get_y());

	return std::make_pair(mid, p);
}

/*
 ******************************************************************************
 ********************************** LINE LENGTH *******************************
 ******************************************************************************
 */

/*! \brief Returns euclidean squared distance between point(x1,y1) and 
 *  point(x2,y2).
 *
 */
double GetPointsEuclideanSquaredDistance(
	const double x1,
	const double y1,
	const double x2,
	const double y2)
{
	double dx = x2 - x1;
	double dy = y2 - y1;
	return ((dx * dx) + (dy * dy));
}

/*! \brief Returns euclidean squared distance between fst and snd.
 *
 */
double GetPointsEuclideanSquaredDistance(
	const Point& fst,
	const Point& snd)
{
	return GetPointsEuclideanSquaredDistance(
		fst.get_x(), fst.get_y(),
		snd.get_x(), snd.get_y());
}

/*! \brief Function will return euclidean distance between point(x1,y1) and 
 *  point(x2,y2).
 *
 */
double GetPointsEuclideanDistance(
	const double x1,
	const double y1,
	const double x2,
	const double y2)
{
	double dx = x2 - x1;
	double dy = y2 - y1;
	return std::sqrt((dx * dx) + (dy * dy));
}

/*! \briefReturns euclidean distance between fst and snd.
 *
 */
double GetPointsEuclideanDistance(
	const Point& fst,
	const Point& snd)
{
	return GetPointsEuclideanDistance(
		fst.get_x(), fst.get_y(),
		snd.get_x(), snd.get_y());
}

/*! \brief Returns sum of euclidean distances between points subsequent 
 *  belonging to the line.
 *
 */
double GetLineLength(
	const Line& line)
{
	double result = 0;
	for (std::size_t i = 0; i < line.size() - 1; ++i)
		result += GetPointsEuclideanDistance(line[i], line[i + 1]);
	return result;
}

/*! \brief Returns sum of euclidean squared distances between subsequent 
 *  points belonging to the line.
 *
 */
double GetLineLengthESD(
	const Line& line)
{
	double result = 0;
	for (std::size_t i = 0; i < line.size() - 1; ++i)
		result += GetPointsEuclideanSquaredDistance(line[i], line[i + 1]);
	return result;
}

/*
 ******************************************************************************
 ****************************** LINE belongs to BOX ***************************
 ******************************************************************************
 */

/*! \brief Returns true if line between between point(x1,y1) and point(x2,y2) 
 *  partially belongs to Box(b_min_x, b_max_x, b_min_y, b_max_x).
 *
 *  With deltas we can set deviation of calculation.
 */
bool DoLinePartiallyBelongsToBox(
	const double x1,
	const double y1,
	const double x2,
	const double y2,
	const double b_min_x,
	const double b_max_x,
	const double b_min_y,
	const double b_max_y,
	const double delta_x,
	const double delta_y)
{
	// at least one point of line belongs to box
	if ((x1 >= b_min_x && x1 <= b_max_x && 
		 y1 >= b_min_y && y1 <= b_max_y) ||
		(x2 >= b_min_x && x2 <= b_max_x && 
		 y2 >= b_min_y && y2 <= b_max_y))
		return true;

	// or if at least they have intersection with box
	if (DoLineAndBoxHaveIntersection(
		x1, y1, x2, y2,
		b_min_x, b_max_x, b_min_y, b_max_y,
		delta_x,
		delta_y))
		return true;

	return false;
}

/*! \brief Returns true if line between point(x1,y1) and point(x2,y2) partially 
 *  belongs to box b.
 *
 *  With deltas we can set deviation of calculation.
 */
bool DoLinePartiallyBelongsToBox(
	const double x1,
	const double y1,
	const double x2,
	const double y2,
	const Box& b,
	const double delta_x,
	const double delta_y)
{
	return DoLinePartiallyBelongsToBox(
		x1, y1, x2, y2,
		b.get_x().get_fst(), b.get_x().get_snd(),
		b.get_y().get_fst(), b.get_y().get_snd(),
		delta_x,
		delta_y);
}

/*! \brief Returns true if line between point(x1,y1) and point(x2,y2) partially
 *  belongs to Box(b_min_x, b_max_x, b_min_y, b_max_x).
 *
 *  With deltas we can set deviation of calculation.
 */
bool DoLinePartiallyBelongsToBox(
	const Point& fst,
	const Point& snd,
	const Box& b,
	const double delta_x,
	const double delta_y)
{
	return DoLinePartiallyBelongsToBox(
		fst.get_x(), fst.get_y(), fst.get_x(), fst.get_y(),
		b.get_x().get_fst(), b.get_x().get_snd(),
		b.get_y().get_fst(), b.get_y().get_snd(),
		delta_x,
		delta_y);
}

/*! \brief Returns true if line partially belongs to box b.
 *
 *  With deltas we can set deviation of calculation.
 */
bool DoLinePartiallyBelongsToBox(
	const Line& line,
	const Box& b,
	const double delta_x,
	const double delta_y)
{
	for (std::size_t i = 0; i < line.size() - 1; ++i)
	{
		if (DoLinePartiallyBelongsToBox(
			line[i],
			line[i + 1],
			b,
			delta_x,
			delta_y))
			return true;
	}
	return false;
}

/*
 ******************************************************************************
 **************************** LINE and BOX INTERSECTION ***********************
 ******************************************************************************
 */

/*! \brief Returns true if line between point(x1,y1) and point(x2,y2) has 
 *  intersection with edges of 
 *  Box(b_min_x, b_max_x, b_min_y, b_max_x).
 *
 *  With deltas we can set deviation of calculation.
 */
bool DoLineAndBoxHaveIntersection(
	const double x1,
	const double y1,
	const double x2,
	const double y2,
	const double b_min_x,
	const double b_max_x,
	const double b_min_y,
	const double b_max_y,
	const double delta_x,
	const double delta_y)
{
	if (DoLinesHaveIntersection(
		x1, y1, x2, y2,
		b_min_x, b_min_y, b_min_x, b_max_y,
		true,
		delta_x,
		delta_y))
		return true;

	if (DoLinesHaveIntersection(
		x1, y1, x2, y2,
		b_min_x, b_min_y, b_max_x, b_min_y,
		true,
		delta_x,
		delta_y))
		return true;

	if (DoLinesHaveIntersection(
		x1, y1, x2, y2,
		b_max_x, b_min_y, b_max_x, b_max_y,
		true,
		delta_x,
		delta_y))
		return true;
	
	if (DoLinesHaveIntersection(
		x1, y1, x2, y2,
		b_min_x, b_max_y, b_max_x, b_max_y,
		true,
		delta_x,
		delta_y))
		return true;
	
	return false;
}

/*! \brief Returns true if line between point(x1,y1) and point(x2,y2) has 
 *  intersection with edges of box b.
 *
 *  With deltas we can set deviation of calculation.
 */
bool DoLineAndBoxHaveIntersection(
	const double x1,
	const double y1,
	const double x2,
	const double y2,
	const Box& b,
	const double delta_x,
	const double delta_y)
{
	return DoLineAndBoxHaveIntersection(
		x1, y1,
		x2, y2,
		b.get_x().get_fst(),
		b.get_x().get_snd(),
		b.get_y().get_fst(),
		b.get_y().get_snd(),
		delta_x,
		delta_y);
}

/*! \brief Returns true if line between fst and snd has intersection with 
 *  edges of box b.
 *
 *  With deltas we can set deviation of calculation.
 */
bool DoLineAndBoxHaveIntersection(
	const Point& fst,
	const Point& snd,
	const Box& b,
	const double delta_x,
	const double delta_y)
{
	return DoLineAndBoxHaveIntersection(
		fst.get_x(),
		fst.get_y(),
		snd.get_x(),
		snd.get_y(),
		b,
		delta_x,
		delta_y);
}

/*! \brief Returns true if any part of line has intersection with 
 *  edges of box b.
 *
 *  With deltas we can set deviation of calculation.
 */
bool DoLineAndBoxHaveIntersection(
	const Line& line,
	const Box& b,
	const double delta_x,
	const double delta_y)
{
	for (std::size_t i = 1; i < line.size(); ++i)
	{
		if (DoLineAndBoxHaveIntersection(
			line[i - 1], line[i], 
			b,
			delta_x,
			delta_y))
			return true;
	}
	return false;
}

/*
 ******************************************************************************
 ***************************** BOX and BOX INTERSECTION ***********************
 ******************************************************************************
 */

bool DoBoxesHaveIntersection(
	const double b1_min_x,
	const double b1_max_x,
	const double b1_min_y,
	const double b1_max_y,
	const double b2_min_x,
	const double b2_max_x,
	const double b2_min_y,
	const double b2_max_y)
{
	return DoBoxesHaveIntersection(
		Box(b1_min_x, b1_max_x,
			b1_min_y, b1_max_y),
		Box(b2_min_x, b2_max_x,
			b2_min_y, b2_max_y));
}

bool DoBoxesHaveIntersection(
	const Box& b1,
	const double b2_min_x,
	const double b2_max_x,
	const double b2_min_y,
	const double b2_max_y)
{
	return DoBoxesHaveIntersection(
		b1,
		Box(b2_min_x, b2_max_x,
			b2_min_y, b2_max_y));
}

bool DoBoxesHaveIntersection(
	const double b1_min_x,
	const double b1_max_x,
	const double b1_min_y,
	const double b1_max_y,
	const Box& b2)
{
	return DoBoxesHaveIntersection(
		Box(b1_min_x, b1_max_x,
			b1_min_y, b1_max_y),
		b2);
}

bool DoBoxesHaveIntersection(
	const Box& b1,
	const Box& b2)
{
	return b1.has_intersection_with(b2);
}

Box GetBoxesIntersection(
	const double b1_min_x,
	const double b1_max_x,
	const double b1_min_y,
	const double b1_max_y,
	const double b2_min_x,
	const double b2_max_x,
	const double b2_min_y,
	const double b2_max_y)
{
	return GetBoxesIntersection(
		Box(b1_min_x, b1_max_x,
			b1_min_y, b1_max_y),
		Box(b2_min_x, b2_max_x,
			b2_min_y, b2_max_y));
}

Box GetBoxesIntersection(
	const Box& b1,
	const double b2_min_x,
	const double b2_max_x,
	const double b2_min_y,
	const double b2_max_y)
{
	return GetBoxesIntersection(
		b1,
		Box(b2_min_x, b2_max_x,
			b2_min_y, b2_max_y));
}

Box GetBoxesIntersection(
	const double b1_min_x,
	const double b1_max_x,
	const double b1_min_y,
	const double b1_max_y,
	const Box& b2)
{
	return GetBoxesIntersection(
		Box(b1_min_x, b1_max_x,
			b1_min_y, b1_max_y),
		b2);
}

Box GetBoxesIntersection(
	const Box& b1,
	const Box& b2)
{
	return b1.get_intersection_with(b2);
}

/*
 ******************************************************************************
 *************************** LINE and LINE INTERSECTION ***********************
 ******************************************************************************
 */

/*! \brief Returns angle between x-axis and line in radians. Angle is from 
 *  x-axis to line in negative direction.
 *
 *  Simple examples:
 *	GetAngle(Point(0, 0), Point( 1,  0)) ~ -0
 *	GetAngle(Point(0, 0), Point( 0, -1)) ~ pi/2
 *	GetAngle(Point(0, 0), Point(-1,  0)) ~ pi
 *	GetAngle(Point(0, 0), Point( 0,  1)) ~ 3*pi/2
 */
double GetAngle(
	const Point& a,
	const Point& b)
{
	double theta = std::atan2(-(b.get_y() - a.get_y()), b.get_x() - a.get_x());
	if (theta < 0)
	{
		theta += M_PI * 2;
	}
	return theta;
}

/*! \brief Returns true if line between points (x1,y1) and (x2,y2) is parallel 
 *  line to line between points (x3,y3) and (x4, y4).
 *
 */
bool AreLinesParallel(
	const double x1, const double y1, const double x2, const double y2,
	const double x3, const double y3, const double x4, const double y4)
{
	if ((x1 == x2 && x3 == x4) || (y1 == y2 && y3 == y4))
		return true;
	if (x1 == x2 || x3 == x4 || y1 == y2 || y3 == y4)
		return false;
	if ((x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4) == 0)
		return true;
	return false;
}

/*! \brief Returns true if line between points p1 and p2 is parallel line 
 *  to line between points p3 and p4.
 *
 */
bool AreLinesParallel(
	const Point& p1, const Point& p2,
	const Point& p3, const Point& p4)
{
	return AreLinesParallel(
		p1.get_x(), p1.get_y(),
		p2.get_x(), p2.get_y(),
		p3.get_x(), p3.get_y(),
		p4.get_x(), p4.get_y());
}

/*! \brief Returns true if line between points (x1,y1) and (x2,y2) has 
 *  intersection with line between points (x3,y3) and (x4, y4).
 *  If only_segments then lines are considered as segments.
 *
 *  With deltas we can set deviation of calculation.
 */
bool DoLinesHaveIntersection(
	const double x1, const double y1, const double x2, const double y2,
	const double x3, const double y3, const double x4, const double y4,
	bool only_segments,
	const double delta_x,
	const double delta_y)
{
	double x, y;
	return DoLinesHaveIntersection(
		x1, y1, x2, y2,
		x3, y3, x4, y4,
		x, y,
		only_segments,
		delta_x,
		delta_y);
}

/*! \brief Returns true if line between points (x1,y1) and (x2,y2) has 
 *  intersection with line between points (x3,y3) and (x4, y4).
 *  If lines have intersection point, then intersection point is exported 
 *  in variables x and y.
 *  If only_segments then lines are considered as segments.
 *
 *  With deltas we can set deviation of calculation.
 */
bool DoLinesHaveIntersection(
	const double x1, const double y1, const double x2, const double y2,
	const double x3, const double y3, const double x4, const double y4,
	double & x, double & y,
	bool only_segments,
	const double delta_x,
	const double delta_y)
{
	Point p = GetLinesIntersection(
		x1, y1, x2, y2,
		x3, y3, x4, y4);

	if (!(isnan(p.get_x()) || isnan(p.get_y())))
	{
		if (only_segments)
		{
			// we will enlarge lines due to deltas
			if ((x1 <= x2 ? x1 : x2) - delta_x <= p.get_x() && 
				p.get_x() <= (x1 >= x2 ? x1 : x2) + delta_x &&
				(y1 <= y2 ? y1 : y2) - delta_y <= p.get_y() && 
				p.get_y() <= (y1 >= y2 ? y1 : y2) + delta_y &&
				(x3 <= x4 ? x3 : x4) - delta_x <= p.get_x() && 
				p.get_x() <= (x3 >= x4 ? x3 : x4) + delta_x &&
				(y3 <= y4 ? y3 : y4) - delta_y <= p.get_y() && 
				p.get_y() <= (y3 >= y4 ? y3 : y4) + delta_y)
			{
				x = p.get_x();
				y = p.get_y();
				return true;
			}
		}
		// lines are not considered as segments
		else
		{
			x = p.get_x();
			y = p.get_y();
			return true;
		}
	}

	return false;
}

/*! \brief Returns true if line between points (x1,y1) and (x2,y2) has 
 *  intersection with line between points (x3,y3) and (x4, y4).
 *  If only_segments then lines are considered as segments.
 *
 *  With deltas we can set deviation of calculation.
 */
bool DoLinesHaveIntersection(
	const Point& p1, const Point& p2,
	const Point& p3, const Point& p4,
	bool only_segments,
	const double delta_x,
	const double delta_y)
{
	return DoLinesHaveIntersection(
		p1.get_x(), p1.get_y(), p2.get_x(), p2.get_y(),
		p3.get_x(), p3.get_y(), p4.get_x(), p4.get_y(),
		only_segments,
		delta_x,
		delta_y);
}

/*! \brief Returns true if line between points p1 and p2 has intersection 
 *  with line between points p3 and p4.
 *  If lines have intersection point, then intersection point is exported 
 *  in variable p.
 *  If only_segments then lines are considered as segments.
 *
 *  With deltas we can set deviation of calculation.
 */
bool DoLinesHaveIntersection(
	const Point& p1, const Point& p2,
	const Point& p3, const Point& p4,
	Point& p,
	bool only_segments,
	const double delta_x,
	const double delta_y)
{
	return DoLinesHaveIntersection(
		p1.get_x(), p1.get_y(), p2.get_x(), p2.get_y(),
		p3.get_x(), p3.get_y(), p4.get_x(), p4.get_y(),
		p.set_x(), p.set_y(),
		only_segments,
		delta_x,
		delta_y);
}

/*! \brief Returns point of intersection of straight line between points 
 *  (x1,y1) and (x2,y2) and straight line between points (x3,y3) and (x4, y4).
 *  If they are parallel but not coincident, then NAN will be returned.
 *  If lines are coincident then if they have intersection as segments then 
 *  middle of their segment intersection is returned, else middle of segment 
 *  line between p1 and p2 is returned.
 *
 */
Point GetLinesIntersection(
	const double x1, const double y1, const double x2, const double y2,
	const double x3, const double y3, const double x4, const double y4)
{
	// check if any of them is point
	if ((x1 == x2 && y1 == y2) ||
		(x3 == x4 && y3 == y4))
		return Point(x1, y1);

	// at least one line is special or lines are parallel/coincident, where
	// ... special ~ (x1 == x2 || x3 == x4 || y1 == y2 || y3 == y4)
	if ((x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4) == 0)
	{
		if (x1 == x2 && x3 == x4 && x1 == x3)
		{
			Interval 
				i12(y1, y2),
				i34(y3, y4);
			return Point(x1,i12.get_intersection_with(i34).mid());
		}
		else
		if (y1 == y2 && y3 == y4 && y1 == y3)
		{
			Interval
				i12(x1, x2),
				i34(x3, x4);
			return Point(i12.get_intersection_with(i34).mid(), y1);
		}
		else
		// special parallel lines
		if ((x1 == x2 && x3 == x4) || (y1 == y2 && y3 == y4))
		{
			return Point(
			(std::numeric_limits<double>::quiet_NaN()), 
			(std::numeric_limits<double>::quiet_NaN()));
		}
		else
		if (x1 == x2 && y3 == y4)
		{
			return Point(x1, y3);
		}
		else 
		if (x3 == x4 && y1 == y2)
		{
			return Point(x3, y1);
		}
		else
		// y = a*x + b
		if (x1 == x2)
		{
			double a = (y3 - y4) / (x3 - x4);
			double b = y3 - a*x3;
			return Point(x1, a*x1 + b);
		}
		else
		if (x3 == x4)
		{
			double a = (y1 - y2) / (x1 - x2);
			double b = y1 - a*x1;
			return Point(x3, a*x3 + b);
		}
		else
		if (y1 == y2)
		{
			double a = (y3 - y4) / (x3 - x4);
			double b = y3 - a*x3;
			return Point((b - y1) / a, y1);
		}
		else
		if (y3 == y4)
		{
			double a = (y1 - y2) / (x1 - x2);
			double b = y1 - a*x1;
			return Point((b - y3) / a, y3);
		}
		// they are parallel or coincident
		else
		{
			double a12 = (y1 - y2) / (x1 - x2);
			double b12 = y1 - a12*x1;
			double a34 = (y3 - y4) / (x3 - x4);
			double b34 = y3 - a34*x3;

			// lines are coincident
			if (a12 == a34 && b12 == b34)
			{
				Box box12(
					x1 < x2 ? x1 : x2, 
					x1 > x2 ? x2 : x1, 
					y1 < y2 ? y1 : y2, 
					y1 > y2 ? y2 : y1);
				Box box34(
					x3 < x4 ? x3 : x4,
					x3 > x4 ? x4 : x3,
					y3 < y4 ? y3 : y4,
					y3 > y4 ? y4 : y3);
				
				if (DoBoxesHaveIntersection(box12, box34))
				{
					return box12.get_intersection_with(box34).mid();
				}
				else
				{
					return box12.mid();
				}
			}
			// lines are parallel but they are not coincident
			else 
				return Point(
				(std::numeric_limits<double>::quiet_NaN()),
				(std::numeric_limits<double>::quiet_NaN()));
		}
		
	}
	else
	{
		double px =
			((x1*y2 - y1*x2)*(x3 - x4) - (x1 - x2)*(x3*y4 - y3*x4)) /
			((x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4));
		double py =
			((x1*y2 - y1*x2)*(y3 - y4) - (y1 - y2)*(x3*y4 - y3*x4)) /
			((x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4));
		return Point(px, py);
	}

	return Point(
		(std::numeric_limits<double>::quiet_NaN()),
		(std::numeric_limits<double>::quiet_NaN()));
}

/*
 ******************************************************************************
 ***************************** CLOSEST POINT to LINE **************************
 ******************************************************************************
 */

/*! \brief Returns closest Point belonging on line between points (x1,y1) and
 *  (x2,y2) to the Point(x,y).
 *  If (is_segment) then line is considered as segment line and returned 
 *  point belongs is selected only from segment, not whole straight line.
 *
 */
// http://stackoverflow.com/questions/3120357/get-closest-point-to-a-line
// http://www.gamedev.net/topic/444154-closest-point-on-a-line/
Point GetClosestPoint(
	const double x1, const double y1, const double x2, const double y2,
	const double x, const double y, 
	bool is_segment)
{
	// P1 to P
	double P1P_x = x - x1;
	double P1P_y = y - y1;

	// P1 to P2
	double P1P2_x = x2 - x1;
	double P1P2_y = y2 - y1;

	// squared magnitude of vector P1 to P2
	double P1P2M = P1P2_x * P1P2_x + P1P2_y * P1P2_y;

	// scalar/dot product of P1P and P1P2
	double DP = P1P_x * P1P2_x + P1P_y * P1P2_y;

	// normalized distance from P1 to the closest point to P
	double t = DP / P1P2M;

	if (is_segment)
	{
		if (t < 0.0)
			t = 0.0;
		else
		if (t > 1.0)
			t = 1.0;
	}

	return Point(
		x1 + P1P2_x * t, 
		y1 + P1P2_y * t);
}

/*! \brief Returns closest Point belonging on line between points p1 and p2
 *  to the Point(x,y).
 *  If (is_segment) then line is considered as segment line and returned 
 *  point belongs is selected only from segment, not whole straight line.
 *
 */
Point GetClosestPoint(
	const Point& p1, const Point& p2,
	const Point& p,
	bool is_segment)
{
	return GetClosestPoint(
		p1.get_x(), p1.get_y(), p2.get_x(), p2.get_y(),
		p.get_x(), p.get_y(),
		is_segment);
}

/*! \brief Returns vector of closest points belonging on line to the Point(x,y).
 *  All selected points have same distance to the point, which is returned in 
 *  min_distance. Each part of line is considered as segment. 
 *
 */
std::vector<closest_point_in_line> GetClosestPoints(
	const Line& line,
	const Point& point,
	double& min_distance)
{
	std::vector<closest_point_in_line> closest_points;
	min_distance = std::numeric_limits<double>::max();

	if (line.size() == 0)
		return closest_points;

	std::vector<Point> pts;
	for (std::size_t i = 0; i < line.size() - 1; ++i)
		pts.push_back(GetClosestPoint(line[i], line[i + 1], point, true));

	std::vector<double> distances;
	for (std::size_t d = 0; d < pts.size(); ++d)
		distances.push_back(GetPointsEuclideanDistance(point, pts[d]));

	for (std::size_t i = 0; i < distances.size(); ++i)
	{
		if (min_distance > distances[i])
			min_distance = distances[i];
	}

	for (std::size_t i = 0; i < pts.size(); ++i)
	{
		if (min_distance == distances[i])
			closest_points.push_back(std::make_pair(pts[i], i));
	}

	return closest_points;
}

/*
 ******************************************************************************
 ********************************* BOUNDARY BOX *******************************
 ******************************************************************************
 */

Box GetBoundaryBox(
	const Line& points)
{
	DataType x_min = DataType_max();
	DataType x_max = DataType_min();
	DataType y_min = DataType_max();
	DataType y_max = DataType_min();

	for (auto& p : points)
	{
		if (x_min > p.get_x())
			x_min = p.get_x();
		if (x_max < p.get_x())
			x_max = p.get_x();
		if (y_min > p.get_y())
			y_min = p.get_y();
		if (y_max < p.get_y())
			y_max = p.get_y();
	}

	return Box(x_min, x_max, y_min, y_max);
}

/*
 ******************************************************************************
 *********************************** POLYGONS *********************************
 ******************************************************************************
 */

bool PointBelongsToPolygon(
	const Point& p,
	const Line& polygon)
{
	if (polygon.empty())
		return false;

	for (auto& pp : polygon)
	{
		if (p == pp)
			return true;
	}

	Box boundary_box = GetBoundaryBox(polygon);
	if (!boundary_box.contains(p))
		return false;
	
	if (GetWindingNumber(p, polygon) != 0)
		return true;

	return false;
}

// http://www.engr.colostate.edu/~dga/dga/papers/point_in_polygon.pdf
// does not work if p belongs to polygon
int GetWindingNumber(
	const Point& p,
	const Line& polygon)
{
	int wn = 0;

	if (polygon.size() < 3)
		return 0;

	std::vector<DataType> x;
	std::vector<DataType> y;

	for (auto& bp : polygon)
	{
		x.push_back(bp.get_x() - p.get_x());
		y.push_back(bp.get_y() - p.get_y());
	}

	if (polygon[0] != polygon[polygon.size() - 1])
	{
		x.push_back(polygon[0].get_x() - p.get_x());
		y.push_back(polygon[0].get_y() - p.get_y());
	}

	// also we will add the first

	// for every vertex of border
	for (std::size_t i = 0; i < x.size() - 1; ++i)
	{
		// if segment between v_i a v_(i+1) crosses the x-axis
		if (y[i] * y[i + 1] < 0)
		{
			// x of intersection of segment(v_i,v_(i+1)) and x-axis
			double r = x[i] + (y[i] * (x[i + 1] - x[i])) / (y[i] - y[i + 1]);

			// if segment(v_i,v_i+1) crosses positive x-axis
			if (r > 0)
				wn += y[i] < 0 ? 2 : -2;
		}
		// no change in y
		else if (y[i] == y[i + 1])
		{
		}
		// v_i is on positive x-axis
		else if (y[i] == 0 && x[i] >= 0)
			wn += y[i + 1] > 0 ? 1 : -1;
		// v_(i+1) is on positive x-axis
		else if (y[i + 1] == 0 && x[i + 1] >= 0)
			wn += y[i] < 0 ? 1 : -1;
	}

	return wn;
}