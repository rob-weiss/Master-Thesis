#ifndef _COORDINATES_HPP
#define _COORDINATES_HPP

#include <utility>

#include "DataType.h"

class Point
{

/*
 ******************************************************************************
 ************************************ RAW DATA ********************************
 ******************************************************************************
 */

protected:
	DataType x_value;
	DataType y_value;

/*
 ******************************************************************************
 ********************************** CONSTRUCTORS ******************************
 ******************************************************************************
 */

public:
	Point(const Point & i);
	 
	Point(Point && i);
	
	Point(DataType f, DataType s);
	
	Point();

/*
 ******************************************************************************
 *********************************** OPERATORS *******************************
 ******************************************************************************
 */	

public:
	Point & operator= (const Point & i);

	Point & operator= (Point && i);

	bool operator== (const Point & i) const;

	bool operator!= (const Point & i) const;

	Point operator+ (const Point & i) const;

	Point operator- (const Point & i) const;

/*
 ******************************************************************************
 ******************************** SAFE DATA ACCESS ****************************
 ******************************************************************************
 */

public:
	DataType& set_x();

	DataType& set_y();

	DataType get_x() const;

	DataType get_y() const;
};

#endif