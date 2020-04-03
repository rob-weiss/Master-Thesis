#include "Box.h"

#include <utility>
#include <vector>

#include "DataType.h"
#include "Point.h"
#include "Interval.h"

/*
******************************************************************************
********************************** CONSTRUCTORS ******************************
******************************************************************************
*/

/*! \brief Copy constructor.
 *
 */
Box::Box(const Box & i)
  : x_intval(i.x_intval), 
	y_intval(i.y_intval) 
{ }

/*! \brief Move constructor.
 *
 */
Box::Box(Box && i)
  : x_intval(std::move(i.x_intval)), 
	y_intval(std::move(i.y_intval)) 
{ }

/*! \brief Constructor from intervals.
 *
 */
Box::Box(Interval x, Interval y)
  : x_intval(x), 
	y_intval(y) 
{ }

/*! \brief Constructor from values.
 *
 */
Box::Box(DataType x1, DataType x2, DataType y1, DataType y2)
  : x_intval(Interval(x1, x2)), 
	y_intval(Interval(y1, y2)) 
{ }

/*! \brief Constructor.
 *
 */
Box::Box() 
{ }

/*
 ******************************************************************************
 *********************************** OPERATORS ********************************
 ******************************************************************************
 */

/*! \brief Assign operator.
 *
 */
Box & Box::operator= (const Box & i)
{
	x_intval = i.x_intval;
	y_intval = i.y_intval;
	return *this;
}

/*! \brief Move assignment operator.
 *
 */
Box & Box::operator= (Box && i)
{
	x_intval = std::move(i.x_intval);
	y_intval = std::move(i.y_intval);
	return *this;
}

/*! \brief Equality operator.
 *
 */
bool Box::operator== (const Box & i) const
{
	return ((x_intval == i.x_intval) && 
			(y_intval == i.y_intval));
}

/*! \brief Non-equality operator.
 *
 */
bool Box::operator!= (const Box & i) const
{
	return (!((x_intval == i.x_intval) && 
			  (y_intval == i.y_intval)));
}

/*
 ******************************************************************************
 ******************************** SAFE DATA ACCESS ****************************
 ******************************************************************************
 */

/*! \brief Returns interval on x-axis as reference.
 *
 */
Interval & Box::set_x() 
{ 
	return x_intval; 
}

/*! \brief Returns interval on y-axis as reference.
 *
 */
Interval & Box::set_y() 
{ 
	return y_intval; 
}

/*! \brief Returns interval on x-axis as const reference.
 *
 */
const Interval & Box::get_x() const 
{ 
	return x_intval; 
}

/*! \brief Returns interval on y-axis as const reference.
 *
 */
const Interval & Box::get_y() const 
{ 
	return y_intval; 
}

/*
 ******************************************************************************
 ************************************ FUNCTIONS *******************************
 ******************************************************************************
 */

/*! \brief Returns mid of the Box.
 *
 */
Point Box::mid() const 
{ 
	return Point(x_intval.mid(), y_intval.mid()); 
}

/*! \brief Returns true, if Box is valid ~ x_intval and y_intval are valid.
 *
 */
bool Box::valid() const 
{ 
	return (x_intval.valid() && 
			y_intval.valid()); 
}

/*! \brief Returns true, if WHOLE Box b belongs to the Box.
 *
 *  Checks if every points belonging to b also belongs to the Box.
 */ 
bool Box::contains(const Box& b) const 
{ 
	return (x_intval.contains(b.x_intval) && 
			y_intval.contains(b.y_intval)); 
}

/*! \brief Returns true, if point c belongs to the Box.
 *
 */
bool Box::contains(const Point& p) const 
{ 
	return (x_intval.contains(p.get_x()) && 
			y_intval.contains(p.get_y())); 
}

/*! \brief Returns volume of the Box.
 *
 */
DataType Box::volume() const
{ 
	return (x_intval.length() * y_intval.length()); 
}

/*! \brief Returns true, if the Box is a line.
 *
 */
bool Box::is_line() const 
{ 
	return ((x_intval.get_fst() == x_intval.get_snd() && 
			 y_intval.get_fst() != y_intval.get_snd()) 
		 || (x_intval.get_fst() != x_intval.get_snd() && 
		     y_intval.get_fst() == y_intval.get_snd())); 
}

/*! \brief Returns true, if the Box is a point.
 *
 */
bool Box::is_point() const 
{ 
	return (x_intval.get_fst() == x_intval.get_snd() && 
		    y_intval.get_fst() == y_intval.get_snd()); 
}

/*! \brief Tries to split Box by Box splited_by. If they don't have 
 *  intersection, then original Box will be returned. If they have 
 *  intersection, then return boxes made by (original - splited_by).
 *
 *  Look at interval::split_by
 */
std::vector<Box> Box::split_by(const Box& splited_by) const
{
	std::vector<Box> splited_box = std::vector<Box>();
	if (has_intersection_with(splited_by))
	{
		std::vector<Interval> splited_x = x_intval.split_by(splited_by.x_intval);
		std::vector<Interval> splited_y = y_intval.split_by(splited_by.y_intval);
		Interval intersected_x = x_intval.get_intersection_with(splited_by.x_intval);
		Interval intersected_y = y_intval.get_intersection_with(splited_by.y_intval);

		for (std::size_t i = 0; i < splited_x.size(); ++i)
		{
			for (std::size_t j = 0; j < splited_y.size(); ++j)
			{
				splited_box.push_back(Box(splited_x[i], splited_y[j]));
			}
		}
		if (intersected_x.valid())
		{
			for (std::size_t i = 0; i < splited_y.size(); ++i)
			{
				splited_box.push_back(Box(intersected_x, splited_y[i]));
			}
		}
		if (intersected_y.valid())
		{
			for (std::size_t i = 0; i < splited_x.size(); ++i)
			{
				splited_box.push_back(Box(splited_x[i], intersected_y));
			}
		}
	}
	else 
		splited_box.push_back(*this);
	return splited_box;
}

/*! \brief Returns true, if box has intersection with other box.
 *
 */
bool Box::has_intersection_with(const Box& other) const
{
	return (x_intval.has_intersection_with(other.x_intval) &&
			y_intval.has_intersection_with(other.y_intval));
}

/*! \brief Forces intersection of Box with Box. If they don't have intersection,
 *  then returned Box will be invalid.
 *
 */
Box Box::get_intersection_with(const Box& other) const
{
	Interval intersected_x = 
		x_intval.get_intersection_with(other.x_intval);
	Interval intersected_y = 
		y_intval.get_intersection_with(other.y_intval);
	return Box(intersected_x, intersected_y);
}
