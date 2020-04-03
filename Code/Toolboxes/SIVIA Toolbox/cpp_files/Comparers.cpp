#include "Comparers.h"

#include "Box.h"
#include "Point.h"

/*
 ******************************************************************************
 ****************************** COMPARING FUNCTIONS ***************************
 ******************************************************************************
 */

/*! \brief Returns compares two boxes due to fst coordinates.
 *
 */
bool BoxComparer::operator() (
	const Box& lhs,
	const Box& rhs) const
{
	if (lhs.get_x().get_fst() < rhs.get_x().get_fst())
		return true;
	
	if (lhs.get_x().get_fst() == rhs.get_x().get_fst() && 
		lhs.get_y().get_fst() < rhs.get_y().get_fst())
		return true;

	return false;
}

/*
 ******************************************************************************
 ****************************** COMPARING FUNCTIONS ***************************
 ******************************************************************************
 */

/*! \brief Returns compares two points.
 *
 */
bool PointComparer::operator() (
	const Point& lhs, 
	const Point& rhs) const
{
	if (lhs.get_x() < rhs.get_x())
		return true;
	
	if (lhs.get_x() == rhs.get_x() && lhs.get_y() < rhs.get_y())
		return true; 
		
	return false;
}

/*! \brief Returns compares two pairs of points.
 *
 */
bool PointComparer::operator() (
	const std::pair<Point, Point>& lhs,
	const std::pair<Point, Point>& rhs) const
{
	if ((*this)(lhs.first, rhs.first))
		return true;
	else
	if (lhs.first == rhs.first && (*this)(lhs.second, rhs.second))
		return true;
	return false;
}