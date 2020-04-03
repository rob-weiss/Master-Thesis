#ifndef _BOXPROCESSOR_HPP
#define _BOXPROCESSOR_HPP

#include "Box.h"

class BoxProcessor
{

/*
 ******************************************************************************
 ****************************** OBTAINING COMPONENTS **************************
 ******************************************************************************
 */

public:
	void get_components_recursion(
	const std::size_t which_element,
	const std::size_t not_assigned_value,
	const std::vector<Box>& boxes,
	std::vector<std::size_t>& components) const;

	std::vector<std::vector<Box> > get_components(
		const std::vector<Box>& boxes) const;

/*
 ******************************************************************************
 *************************** OBTAINING COVERAGE OF EDGES **********************
 ******************************************************************************
 */

public:
	std::vector<std::vector<Box> > get_edges_of_box(
		const Box& b) const;

	std::vector<std::vector<Box> > get_covered_edges_of_box(
		const std::size_t covered_box,
		const std::vector<std::size_t>& covering_boxes,
		const std::vector<Box>& boxes) const;

/*
 ******************************************************************************
 ******************************** OBTAINING CORNERS ***************************
 ******************************************************************************
 */

public:
	std::vector<bool> select_corners(
		std::vector<std::vector<Box> >& edges) const;

/*
 ******************************************************************************
 ***************************** OBTAINING NEIGHBOURHOODS ***********************
 ******************************************************************************
 */

public:
	std::vector<std::vector<std::size_t> > get_neighbourhoods(
		const std::vector<Box>& boxes) const;

/*
 ******************************************************************************
 ***************************** NEIGHBOURHOOD PROCESSING ***********************
 ******************************************************************************
 */

public:
	void delete_unneeded_corners_in_neighbours(
		std::vector<std::vector<std::size_t> >& neighbours,
		const std::vector<Box>& boxes) const;
	

};

#endif

