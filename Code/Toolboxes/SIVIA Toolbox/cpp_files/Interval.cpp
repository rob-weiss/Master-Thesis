#include "Interval.h"

#include <utility>
#include <vector>

#include "DataType.h"

/*
 ******************************************************************************
 ********************************** CONSTRUCTORS ******************************
 ******************************************************************************
 */

/*! \brief Copy constructor.
 *
 */
Interval::Interval(const Interval& i)
  : first(i.first), 
	second(i.second) 
{ }

/*! \brief Move constructor.
 *
 */
Interval::Interval(Interval&& i)
  : first(i.first),
	second(i.second)
{ }

/*! \brief Constructor from values.
 *
 */
Interval::Interval(DataType f, DataType s)
  : first(f), 
	second(s) 
{ }

/*! \brief Constructor.
 *
 */
Interval::Interval() 
{ }

/*
 ******************************************************************************
 *********************************** OPERATORS ********************************
 ******************************************************************************
 */

/*! \brief Assign operator.
 *
 */
Interval & Interval::operator= (const Interval& i)
{
	first = i.first;
	second = i.second;
	return *this;
}

/*! \brief Move assignment operator.
 *
 */
Interval & Interval::operator= (Interval&& i)
{
	first = std::move(i.first);
	second = std::move(i.second);
	return *this;
}

/*! \brief Equality operator.
 *
 */
bool Interval::operator== (const Interval& i) const
{
	return ((first == i.first) && 
			(second == i.second));
}

/*! \brief Non-equality operator.
 *
 */
bool Interval::operator!= (const Interval& i) const
{
	return (!((first == i.first) && 
		      (second == i.second)));
}

/*
 ******************************************************************************
 ******************************** SAFE DATA ACCESS ****************************
 ******************************************************************************
 */

/*! \brief Returns first value with reference.
 *
 */
DataType& Interval::set_fst() 
{ 
	return first; 
}

/*! \brief Returns second value with reference.
 *
 */
DataType& Interval::set_snd() 
{ 
	return second; 
}

/*! \brief Returns first value.
 *
 */
DataType Interval::get_fst() const 
{ 
	return first; 
}

/*! \brief Returns second value.
 *
 */
DataType Interval::get_snd() const 
{ 
	return second; 
}

/*
 ******************************************************************************
 ************************************ FUNCTIONS *******************************
 ******************************************************************************
 */

/*! \brief Returns mid of interval.
 *
 */
DataType Interval::mid() const 
{ 
	return (second + first) / 2; 
}

/*! \brief Returns radius of interval.
 *
 */
DataType Interval::rad() const 
{ 
	return (second - first) / 2; 
} 

/*! \brief Returns length of interval.
 *
 */
DataType Interval::length() const
{ 
	return (second - first); 
}

/*! \brief Returns true if first <= second.
 *
 */
bool Interval::valid() const
{ 
	return first <= second; 
} 

/*! \brief Returns true if first == second.
 *
 */
bool Interval::is_point() const
{
	return (first == second);
}

/*! \brief Returns true if WHOLE interval i belongs to the interval.
 *
 */
bool Interval::contains(const Interval& i) const
{ 
	return (i.first >= first && i.second <= second); 
}

/*! \brief Returns true if point belongs to interval.
 *
 */
bool Interval::contains(const DataType& point) const 
{ 
	return (point >= first && point <= second); 
}

/*! \brief Forces splitting of intervals. If they don't have intersection
 *  then returns original interval. When they have intersection, then result
 *  will be one or two intervals made by (*this - splited_by).
 *
 *  If result is the original interval, no changes on original interval were 
 *  made.
 *  If result is one smaller interval, then something from "left" or "right" 
 *  was cut away.
 *  If result are two smaller intervals, then something from "mid" of the 
 *  interval was cut away.
 */
std::vector<Interval> Interval::split_by(const Interval& splited_by) const
{
	std::vector<Interval> splited_intval = std::vector<Interval>();
	if (has_intersection_with(splited_by))
	{
		if (first < splited_by.first)
		{
			if (second > splited_by.second)
			{
				splited_intval.push_back(
					Interval(first, splited_by.first));
				splited_intval.push_back(
					Interval(splited_by.second, second));
			}
			// (second <= splited_by.second)
			else 
			{
				splited_intval.push_back(
					Interval(first, splited_by.first));
			}
		}
		// (first >= splited_by.first)
		else 
		{
			splited_intval.push_back(
				Interval(splited_by.second, second));
		}
	}
	else 
		splited_intval.push_back(*this);
	return splited_intval;
}

/*! \brief Returns true, if interval has intersection with other interval.
 *
 */
bool Interval::has_intersection_with(const Interval& other) const
{
	return (!((second < other.first) || (first > other.second)));
}

/*! \brief Forces intersection of interval with interval. If they don't have 
 *  intersection, then returned interval will be invalid.
 *
 */
Interval Interval::get_intersection_with(const Interval& other) const
{
	if (has_intersection_with(other))
	{
		if (first < other.first)
		{
			if (second > other.second)
			{
				return other;
			}
			// (second <= intersected_with.second)
			else 
			{
				return Interval(other.first, second);
			}
		}
		// (first >= intersected_with.first)
		else 
		{
			if (second > other.second)
			{
				return Interval(first, other.second);
			}
			// (second <= intersected_with.second)
			else 
			{
				return (*this);
			}
		}
	}
	else // getting invalid data
	{
		if (second < other.first)
			return Interval(other.first, second);
		else 
			return Interval(first, other.second);
	}
}

