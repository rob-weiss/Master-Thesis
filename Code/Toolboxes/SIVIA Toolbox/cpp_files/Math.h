// TODO! premenovat nazvy funkcii

#ifndef _MATH_HPP
#define _MATH_HPP

#include <algorithm>
#include <limits>
#define _USE_MATH_DEFINES
#include <cmath>

#include "Box.h"
#include "DataType.h"
#include "Line.h"
#include "Point.h"

// Point and which part of the line the Point belongs to
typedef std::pair<Point, std::size_t> closest_point_in_line;

/*
 ******************************************************************************
 ******************************** POINT and POINT *****************************
 ******************************************************************************
 */

bool IsPointBetween(
	const Point& p,
	const Point& p1,
	const Point& p2);

Point GetPointBetween(
	const Point& p1,
	const Point& p2);

Point GetPointBetween(
	const std::vector<Point>& points);

/*
 ******************************************************************************
 ******************************** POINT and LINE ******************************
 ******************************************************************************
 */

bool IsOnTheRight(
	const Point& p1,
	const Point& p2,
	const Point& p);

bool IsOnTheLeft(
	const Point& p1,
	const Point& p2,
	const Point& p);

/*
 ******************************************************************************
 ****************************** PERPENDICULAR LINE ****************************
 ******************************************************************************
 */

std::pair<Point, Point> GetPerpendicularInMid(
	const Point& p1,
	const Point& p2,
	bool in_direction_of_fst = true,
	const double distance = 1.0);

/*
 ******************************************************************************
 ********************************** LINE LENGTH *******************************
 ******************************************************************************
 */

double GetPointsEuclideanSquaredDistance(
	const double x1,
	const double y1,
	const double x2,
	const double y2);

double GetPointsEuclideanSquaredDistance(
	const Point& fst,
	const Point& snd);

double GetPointsEuclideanDistance(
	const double x1,
	const double y1,
	const double x2,
	const double y2);

double GetPointsEuclideanDistance(
	const Point& fst,
	const Point& snd);

double GetLineLength(
	const Line& line);

double GetLineLengthESD(
	const Line& line);

/*
 ******************************************************************************
 ****************************** LINE belongs to BOX ***************************
 ******************************************************************************
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
	const double delta_x = 0.0,
	const double delta_y = 0.0);

bool DoLinePartiallyBelongsToBox(
	const double x1,
	const double y1,
	const double x2,
	const double y2,
	const Box& b,
	const double delta_x = 0.0,
	const double delta_y = 0.0);

bool DoLinePartiallyBelongsToBox(
	const Point& fst,
	const Point& snd,
	const Box& b,
	const double delta_x = 0.0,
	const double delta_y = 0.0);

bool DoLinePartiallyBelongsToBox(
	const Line& line,
	const Box& b,
	const double delta_x = 0.0,
	const double delta_y = 0.0);

/*
 ******************************************************************************
 **************************** LINE and BOX INTERSECTION ***********************
 ******************************************************************************
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
	const double delta_x = 0.0,
	const double delta_y = 0.0);

bool DoLineAndBoxHaveIntersection(
	const double x1,
	const double y1,
	const double x2,
	const double y2,
	const Box& b,
	const double delta_x = 0.0,
	const double delta_y = 0.0);

bool DoLineAndBoxHaveIntersection(
	const Point& fst,
	const Point& snd,
	const Box& b,
	const double delta_x = 0.0,
	const double delta_y = 0.0);

bool DoLineAndBoxHaveIntersection(
	const Line& line,
	const Box& b,
	const double delta_x = 0.0,
	const double delta_y = 0.0);

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
	const double b2_max_y);

bool DoBoxesHaveIntersection(
	const Box& b1,
	const double b2_min_x,
	const double b2_max_x,
	const double b2_min_y,
	const double b2_max_y);

bool DoBoxesHaveIntersection(
	const double b1_min_x,
	const double b1_max_x,
	const double b1_min_y,
	const double b1_max_y,
	const Box& b2);

bool DoBoxesHaveIntersection(
	const Box& b1,
	const Box& b2);

Box GetBoxesIntersection(
	const double b1_min_x,
	const double b1_max_x,
	const double b1_min_y,
	const double b1_max_y,
	const double b2_min_x,
	const double b2_max_x,
	const double b2_min_y,
	const double b2_max_y);

Box GetBoxesIntersection(
	const Box& b1,
	const double b2_min_x,
	const double b2_max_x,
	const double b2_min_y,
	const double b2_max_y);

Box GetBoxesIntersection(
	const double b1_min_x,
	const double b1_max_x,
	const double b1_min_y,
	const double b1_max_y,
	const Box& b2);

Box GetBoxesIntersection(
	const Box& b1,
	const Box& b2);

/*
 ******************************************************************************
 *************************** LINE and LINE INTERSECTION ***********************
 ******************************************************************************
 */

double GetAngle(
	const Point& a, 
	const Point& b);

bool AreLinesParallel(
	const double x1, const double y1, const double x2, const double y2,
	const double x3, const double y3, const double x4, const double y4);

bool AreLinesParallel(
	const Point& p1, const Point& p2,
	const Point& p3, const Point& p4);

bool DoLinesHaveIntersection(
	const double x1, const double y1, const double x2, const double y2,
	const double x3, const double y3, const double x4, const double y4,
	bool only_segments = true,
	const double delta_x = 0.0,
	const double delta_y = 0.0);

bool DoLinesHaveIntersection(
	const double x1, const double y1, const double x2, const double y2,
	const double x3, const double y3, const double x4, const double y4,
	double & x, double & y,
	bool only_segments = true,
	const double delta_x = 0.0,
	const double delta_y = 0.0);

bool DoLinesHaveIntersection(
	const Point& p1, const Point& p2,
	const Point& p3, const Point& p4,
	bool only_segments = true,
	const double delta_x = 0.0,
	const double delta_y = 0.0);

bool DoLinesHaveIntersection(
	const Point& p1, const Point& p2,
	const Point& p3, const Point& p4,
	Point& p,
	bool only_segments = true,
	const double delta_x = 0.0,
	const double delta_y = 0.0);

Point GetLinesIntersection(
	const double x1, const double y1, const double x2, const double y2,
	const double x3, const double y3, const double x4, const double y4);

/*
 ******************************************************************************
 ***************************** CLOSEST POINT to LINE **************************
 ******************************************************************************
 */

Point GetClosestPoint(
	const double x1, const double y1, const double x2, const double y2,
	const double x, const double y,
	bool is_segment = true);

Point GetClosestPoint(
	const Point& p1, const Point& p2,
	const Point& p,
	bool is_segment = true);

std::vector<closest_point_in_line> GetClosestPoints(
	const Line& line,
	const Point& point,
	double& min_distance);

/*
 ******************************************************************************
 ********************************* BOUNDARY BOX *******************************
 ******************************************************************************
 */

Box GetBoundaryBox(
	const Line& points);

/*
 ******************************************************************************
 *********************************** POLYGONS *********************************
 ******************************************************************************
 */

bool PointBelongsToPolygon(
	const Point& p,
	const Line& polygon);

int GetWindingNumber(
	const Point& p,
	const Line& polygons);

#endif // _MATH_HPP