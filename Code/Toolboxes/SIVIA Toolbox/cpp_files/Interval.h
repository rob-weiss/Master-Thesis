#ifndef _INTVAL_HPP
#define _INTVAL_HPP

#include <utility>
#include <vector>

#include "DataType.h"

class Interval
{

/*
 ******************************************************************************
 ************************************ RAW DATA ********************************
 ******************************************************************************
 */

protected:
	// EDGES OF INTERVAL
	DataType first;	// lower value
	DataType second;// higher value

/*
 ******************************************************************************
 ********************************** CONSTRUCTORS ******************************
 ******************************************************************************
 */

public:
	Interval(const Interval& i);

	Interval(Interval&& i);

	Interval(DataType f, DataType s);

	Interval();

/*
 ******************************************************************************
 *********************************** OPERATORS ********************************
 ******************************************************************************
 */

public:
	Interval & operator= (const Interval& i);

	Interval & operator= (Interval&& i);

	bool operator== (const Interval& i) const;

	bool operator!= (const Interval& i) const;

/*
 ******************************************************************************
 ******************************** SAFE DATA ACCESS ****************************
 ******************************************************************************
 */

public:
	DataType& set_fst();

	DataType& set_snd();

	DataType get_fst() const;

	DataType get_snd() const;

/*
 ******************************************************************************
 ************************************ FUNCTIONS *******************************
 ******************************************************************************
 */

public:
	DataType mid() const;

	DataType rad() const;

	DataType length() const;

	bool valid() const;

	bool is_point() const;

	bool contains(const Interval& i) const;

	bool contains(const DataType& point) const;

	std::vector<Interval> split_by(const Interval& splited_by) const;

	bool has_intersection_with(const Interval& other) const;

	Interval get_intersection_with(const Interval& other) const;

};

#endif