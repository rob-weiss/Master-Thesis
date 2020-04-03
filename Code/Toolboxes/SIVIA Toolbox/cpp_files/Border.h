#ifndef _BORDER_HPP
#define _BORDER_HPP

#include <vector>
#include <utility>

#include "Box.h"
#include "BoxKind.h"
#include "DataType.h"
#include "Line.h"
#include "Math.h"
#include "Point.h"

class Border
{

/*
 ******************************************************************************
 ************************************ RAW DATA ********************************
 ******************************************************************************
 */

protected:
	// PATH OF POINTS THAT DEFINE BORDER
	Line path;

	// BOXKINDS OF BORDER
	BoxKind fst; // on the "right" in directions from the first to the second
	BoxKind snd; // on the "left"  in directions from the first to the second

	// ALLOWED DIFFERENCE IN COMPUTATION
	double delta_x;
	double delta_y;

/*
 ******************************************************************************
 ********************************** CONSTRUCTORS ******************************
 ******************************************************************************
 */

public:
	Border(const Border & i);

	Border(Border && i);

	Border(
		const Line& line,
		BoxKind fst,
		BoxKind snd);

	Border();

/*
 ******************************************************************************
 *********************************** OPERATORS ********************************
 ******************************************************************************
 */

public:
	Border & operator= (const Border & i);

	Border & operator= (Border && i);

/*
 ******************************************************************************
 ******************************** SAFE DATA ACCESS ****************************
 ******************************************************************************
 */

public:
	const Line & get_path() const;

	const BoxKind & get_fst() const;

	const BoxKind & get_snd() const;

	double get_delta_x() const;

	double get_delta_y() const;

	Line & set_path();

	BoxKind & set_fst();

	BoxKind & set_snd();

	double & set_delta_x();

	double & set_delta_y();

/*
 ******************************************************************************
 ************************************ FUNCTIONS *******************************
 ******************************************************************************
 */

public:
	void reset_deltas();

	bool has_intersect_with(
		const Line& line,
		const bool exact = true,
		const double delta_x_line = 0.0,
		const double delta_y_line = 0.0) const;

	bool has_intersect_with(
		const Border& border, 
		const bool exact = true) const;

	bool has_intersect_with(
		const Box& box,
		const bool exact = true,
		const double delta_x_box_level = 0.0,
		const double delta_y_box_level = 0.0) const;

	std::vector<closest_point_in_line> get_closest_points(
		const Point& point,
		double& distance) const;

	std::vector<closest_point_in_line> get_closest_points(
		const Point& point) const;

};

#endif