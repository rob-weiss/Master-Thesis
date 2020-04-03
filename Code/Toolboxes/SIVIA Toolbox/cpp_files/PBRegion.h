#ifndef _REGION_HPP
#define _REGION_HPP

#include "Box.h"
#include "BoxKind.h"
#include "Line.h"
#include "Math.h"
#include "Point.h"

#include <utility>
#include <vector>

class PBRegion
{

/*
 ******************************************************************************
 ************************************ RAW DATA ********************************
 ******************************************************************************
 */

protected:
	// POLYGONS NEEDED FOR REGION DEFINITION
	std::vector<Line> polygons;

	// BOOLS SIGNIFYING IF REGION LIES INSIDE POLYGON OR NOT
	std::vector<bool> in;

	// BOXKIND OF REGION
	BoxKind bk;

/*
 ******************************************************************************
 ********************************** CONSTRUCTORS ******************************
 ******************************************************************************
 */

public:
	PBRegion(
		const std::vector<Line>& polygons,
		const std::vector<bool>& in,
		const BoxKind boxkind);

/*
 ******************************************************************************
 ******************************** SAFE DATA ACCESS ****************************
 ******************************************************************************
 */

public:
	const std::vector<Line>& get_polygons() const;

	const std::vector<bool>& get_inclusions_exclusions() const;

	const BoxKind get_boxkind() const;

	std::vector<Line>& set_polygons();

	std::vector<bool>& set_inclusions_exclusions();

	BoxKind& set_boxkind();

/*
 ******************************************************************************
 ************************************ FUNCTIONS *******************************
 ******************************************************************************
 */

public:
	bool is_in(const Point& p) const;
};

/*
 ******************************************************************************
 ********************************* OTHER FUNCTIONS ****************************
 ******************************************************************************
 */

BoxKind FindBoxKind(
	const Point& point,
	const std::vector<PBRegion>& regions);

#endif