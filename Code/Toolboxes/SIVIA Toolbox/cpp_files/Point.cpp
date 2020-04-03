#include "Point.h"

#include <utility>

#include "DataType.h"

/*
 ******************************************************************************
 ********************************** CONSTRUCTORS ******************************
 ******************************************************************************
 */

/*! \brief Copy constructor.
 *
 */
Point::Point(const Point & i)
  : x_value(i.x_value), 
	y_value(i.y_value) 
{ }

/*! \brief Move constructor.
 *
 */
Point::Point(Point && i)
  : x_value(std::move(i.x_value)), 
	y_value(std::move(i.y_value)) 
{ }

/*! \brief Constructor from values.
 *
 */
Point::Point(DataType f, DataType s)
  : x_value(f), 
	y_value(s) 
{ }

/*! \brief Constructor.
 *
 */
Point::Point() 
{ }

/*
 ******************************************************************************
 *********************************** OPERATORS ********************************
 ******************************************************************************
 */

/*! \brief Assign operator.
 *
 */
Point & Point::operator= (const Point & i)
{
	x_value = i.x_value;
	y_value = i.y_value;
	return *this;
}

/*! \brief Move assignment operator.
 *
 */
Point & Point::operator= (Point && i)
{
	x_value = std::move(i.x_value);
	y_value = std::move(i.y_value);
	return *this;
}

/*! \brief Equality operator.
 *
 */
bool Point::operator== (const Point & i) const
{
	return ((x_value == i.x_value) && 
		    (y_value == i.y_value));
}

/*! \brief Non-equality operator.
 *
 */
bool Point::operator!= (const Point & i) const
{
	return (!((x_value == i.x_value) && 
		      (y_value == i.y_value)));
}

/*! \brief Addition operator.
 *
 */
Point Point::operator+ (const Point & i) const
{
	return Point(
		x_value + i.x_value,
		y_value + i.y_value);
}

/*! \brief Subtraction operator.
 *
 */
Point Point::operator- (const Point & i) const
{
	return Point(
		x_value + i.x_value,
		y_value + i.y_value);
}

/*
 ******************************************************************************
 ******************************** SAFE DATA ACCESS ****************************
 ******************************************************************************
 */

/*! \brief Returns x-axis value with reference.
 *
 */
DataType& Point::set_x() 
{ 
	return x_value; 
}

/*! \brief Returns x-axis value with reference.
 *
 */
DataType& Point::set_y() 
{ 
	return y_value; 
}

/*! \brief Returns x-axis value.
 *
 */
DataType Point::get_x() const 
{ 
	return x_value; 
}

/*! \brief Returns y-axis value.
 *
 */
DataType Point::get_y() const 
{ 
	return y_value; 
}
