#ifndef _COMPARERS_HPP
#define _COMPARERS_HPP

#include "Box.h"
#include "Point.h"

class BoxComparer
{

/*
 ******************************************************************************
 ****************************** COMPARING FUNCTIONS ***************************
 ******************************************************************************
 */

public:
	bool operator() (
		const Box& lhs,
		const Box& rhs) const;

};

class PointComparer
{

/*
 ******************************************************************************
 ****************************** COMPARING FUNCTIONS ***************************
 ******************************************************************************
 */

public:
	bool operator() (
		const Point& lhs,
		const Point& rhs) const;

	bool operator() (
		const std::pair<Point, Point>& lhs,
		const std::pair<Point, Point>& rhs) const;

};

#endif // _COMPARERS_HPP