#include "PBRegion.h"

#include "Box.h"
#include "BoxKind.h"
#include "Line.h"
#include "Math.h"
#include "Point.h"

#include <utility>
#include <vector>

/*
 ******************************************************************************
 ********************************** CONSTRUCTORS ******************************
 ******************************************************************************
 */

/*! \brief Constructor.
 *
 */
PBRegion::PBRegion(
	const std::vector<Line>& defined_lines,
	const std::vector<bool>& is_in_border,
	const BoxKind boxkind)
  : polygons(defined_lines),
	in(is_in_border),
	bk(boxkind)
{ }

/*
 ******************************************************************************
 ******************************** SAFE DATA ACCESS ****************************
 ******************************************************************************
 */

/*! \brief Returns polygons as const reference.
 *
 */
const std::vector<Line>& PBRegion::get_polygons() const
{
	return polygons;
}

/*! \brief Returns information for each polygon in sequence, if we region is in
 *  or out of current polygon as const reference.
 *
 */
const std::vector<bool>& PBRegion::get_inclusions_exclusions() const
{
	return in;
}

/*! \brief Returns boxkind of the region.
 *
 */
const BoxKind PBRegion::get_boxkind() const
{
	return bk;
}

/*! \brief Returns polygons as reference.
 *
 */
std::vector<Line>& PBRegion::set_polygons()
{
	return polygons;
}

/*! \brief Returns information for each polygon in sequence, if we region is in
 *  or out of current polygon as reference.
 *
 */
std::vector<bool>& PBRegion::set_inclusions_exclusions()
{
	return in;
}

/*! \brief Returns boxkind of the region by reference.
 *
 */
BoxKind& PBRegion::set_boxkind()
{
	return bk;
}

/*
 ******************************************************************************
 ************************************ FUNCTIONS *******************************
 ******************************************************************************
 */

/*! \brief Returns true, if p belongs to the region.
 *
 */
bool PBRegion::is_in(const Point& p) const
{
	for (std::size_t i = 0; i < polygons.size(); ++i)
	{
		if (PointBelongsToPolygon(p, polygons[i]) != in[i])
			return false;
	}
	return true;
}

/*
 ******************************************************************************
 ********************************* OTHER FUNCTIONS ****************************
 ******************************************************************************
 */

/*! \brief Finds first region, in which point belongs. If there is not any
 *  region having point inside, then UNDEFINED BoxKind will be returned.
 *
 */
BoxKind FindBoxKind(
	const Point& point,
	const std::vector<PBRegion>& regions)
{
	for (auto& r : regions)
	{
		if (r.is_in(point))
			return r.get_boxkind();
	}

	return BoxKind::UNDEFINED;
}