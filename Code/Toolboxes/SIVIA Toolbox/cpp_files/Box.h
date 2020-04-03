#ifndef _BOX_HPP
#define _BOX_HPP

#include <vector>
#include <utility>

#include "DataType.h"
#include "Interval.h"
#include "Point.h"

class Box
{

/*
 ******************************************************************************
 ************************************ RAW DATA ********************************
 ******************************************************************************
 */

protected:
	Interval x_intval;
	Interval y_intval;

/*
 ******************************************************************************
 ********************************** CONSTRUCTORS ******************************
 ******************************************************************************
 */

public:
	Box(const Box & i);

	Box(Box && i);

	Box(Interval x, Interval y);

	Box(DataType x1, DataType x2, DataType y1, DataType y2);

	Box();

/*
 ******************************************************************************
 *********************************** OPERATORS ********************************
 ******************************************************************************
 */

public:
	Box & operator= (const Box & i);

	Box & operator= (Box && i);

	bool operator== (const Box & i) const;

	bool operator!= (const Box & i) const;

/*
 ******************************************************************************
 ******************************** SAFE DATA ACCESS ****************************
 ******************************************************************************
 */

public:
	Interval & set_x();

	Interval & set_y();

	const Interval & get_x() const;

	const Interval & get_y() const;

/*
 ******************************************************************************
 ************************************ FUNCTIONS *******************************
 ******************************************************************************
 */

public:
	Point mid() const;

	bool valid() const;

	bool contains(const Box& b) const;

	bool contains(const Point& p) const;
	
	DataType volume() const;

	bool is_line() const;

	bool is_point() const;

	std::vector<Box> split_by(const Box& splited_by) const;

	bool has_intersection_with(const Box& other) const;

	Box get_intersection_with(const Box& other) const;

};

#endif