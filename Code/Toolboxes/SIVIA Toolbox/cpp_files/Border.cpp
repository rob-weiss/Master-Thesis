#include "Border.h"

#include <utility>
#include <vector>

#include "Box.h"
#include "BoxKind.h"
#include "DataType.h"
#include "Line.h"
#include "Math.h"
#include "Point.h"

/*
 ******************************************************************************
 ********************************** CONSTRUCTORS ******************************
 ******************************************************************************
 */

/*! \brief Copy constructor.
 *
 */
Border::Border(const Border & i)
  : path(i.path),
	fst(i.fst),
	snd(i.snd),
	delta_x(i.delta_x),
	delta_y(i.delta_y)
{ }

/*! \brief Move constructor.
 *
 */
Border::Border(Border && i)
  : path(std::move(i.path)),
	fst(i.fst),
	snd(i.snd),
	delta_x(i.delta_x),
	delta_y(i.delta_y)
{ }

/*! \brief Constructor from values.
 *
 */
Border::Border(
	const Line& line, 
	BoxKind first, 
	BoxKind second)
  : path(line),
	fst(first),
	snd(second)
{ 
	reset_deltas();
}

/*! \brief Constructor.
 *
 */
Border::Border()
{ }

/*
******************************************************************************
*********************************** OPERATORS ********************************
******************************************************************************
*/

/*! \brief Assign operator.
 *
 */
Border & Border::operator= (const Border & i)
{
	path = i.path;
	fst = i.fst;
	snd = i.snd;
	return *this;
}

/*! \brief Move assignment operator.
 *
 */
Border & Border::operator= (Border && i)
{
	path = std::move(i.path);
	fst = std::move(i.fst);
	snd = std::move(i.snd);
	return *this;
}

/*
 ******************************************************************************
 ******************************** SAFE DATA ACCESS ****************************
 ******************************************************************************
 */

/*! \brief Returns path as const reference.
 *
 */
const Line & Border::get_path() const
{
	return path;
}

/*! \brief Returns first color as const reference.
 *
 */
const BoxKind & Border::get_fst() const
{
	return fst;
}

/*! \brief Returns second color as const reference.
 *
 */
const BoxKind & Border::get_snd() const
{
	return snd;
}

/*! \brief Returns delta for x.
 *
 */
double Border::get_delta_x() const
{
	return delta_x;
}

/*! \brief Returns delta for y.
 *
 */
double Border::get_delta_y() const
{
	return delta_y;
}

/*! \brief Returns path as reference.
 *
 */
Line & Border::set_path()
{
	return path;
}

/*! \brief Returns first color as reference.
 *
 */
BoxKind & Border::set_fst()
{
	return fst;
}

/*! \brief Returns second color as reference.
 *
 */
BoxKind & Border::set_snd()
{
	return snd;
}

/*! \brief Returns delta for x as reference.
 *
 */
double & Border::set_delta_x()
{
	return delta_x;
}

/*! \brief Returns delta for y as reference.
 *
 */
double & Border::set_delta_y()
{
	return delta_y;
}

/*
 ******************************************************************************
 ************************************ FUNCTIONS *******************************
 ******************************************************************************
 */

/*! \brief Reset deltas.
 *
 */
void Border::reset_deltas()
{
	delta_x = 0.0001;
	delta_y = 0.0001;
}

/*! \brief Returns if border with line have intersection.
 *
 */
bool Border::has_intersect_with(
	const Line& line,
	const bool exact,
	const double delta_x_line,
	const double delta_y_line) const
{
	const double
		delta_x_higher = 
			exact ? 0.0 : delta_x > delta_x_line ? delta_x : delta_x_line,
		delta_y_higher = 
			exact ? 0.0 : delta_y > delta_y_line ? delta_y : delta_y_line;

	for (std::size_t il = 1; il < line.size(); ++il)
	{
		for (std::size_t ip = 1; ip < path.size(); ++ip)
		{
			if (DoLinesHaveIntersection(
				line[il - 1].get_x(), line[il - 1].get_y(),
				line[il].get_x(), line[il].get_y(),
				path[ip - 1].get_x(), path[ip - 1].get_y(),
				path[ip].get_x(), path[ip].get_y(),
				true,
				delta_x_higher,
				delta_y_higher))
				return true;
		}
	}
	
	return false;
}

/*! \brief Returns if borders have intersection.
 *
 */
bool Border::has_intersect_with(
	const Border& border,
	const bool exact) const
{
	return has_intersect_with(
		border.path,
		exact,
		border.delta_x,
		border.delta_y);
}

/*! \brief Returns if border with box have intersection.
 *
 */
bool Border::has_intersect_with(
	const Box& box,
	const bool exact,
	const double delta_x_box_level,
	const double delta_y_box_level) const
{
	const double
		delta_x_higher =
			exact ? 0.0 : delta_x > delta_x_box_level ? delta_x : delta_x_box_level,
		delta_y_higher =
			exact ? 0.0 : delta_y > delta_y_box_level ? delta_y : delta_y_box_level;

	for (std::size_t ip = 1; ip < path.size(); ++ip)
	{
		if (DoLineAndBoxHaveIntersection(
			path[ip - 1].get_x(), path[ip - 1].get_y(),
			path[ip].get_x(), path[ip].get_y(),
			box,
			delta_x_higher,
			delta_y_higher))
			return true;
	}

	return false;
}


/*! \brief Returns closest points to the point and exports their distance from 
 *  the point in min_distance.
 *
 *  Points are in sequence based on path from path[0] to path[path.size() - 1]
 */
std::vector<closest_point_in_line> Border::get_closest_points(
	const Point& point,
	double& min_distance) const
{
	return GetClosestPoints(path, point, min_distance);
}

/*! \brief Returns closest points to the point.
 *
 *  Points are in sequence based on path from path[0] to path[path.size() - 1]
 */
std::vector<closest_point_in_line> Border::get_closest_points(
	const Point& point) const
{
	double min_distance;
	return get_closest_points(point, min_distance);
}