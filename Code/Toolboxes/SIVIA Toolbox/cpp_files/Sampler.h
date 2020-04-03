// DO TO ! better sampler_borders -> rozsirit o to, ze je mozne zistit aj z druheho bodu 
// DO TO ! better rework_to_borders -> rozsirit o to, ze je mozne zistit aj z druheho bodu 
// DO TO! sample_line_paths!
// DO TO! prerobit emplace_back!

#ifndef _SAMPLER_HPP
#define _SAMPLER_HPP

#include <map>

#include "Border.h"
#include "Box.h"
#include "BoxKind.h"
#include "BoxProcessor.h"
#include "Comparers.h"
#include "DataSet.h"
#include "Line.h"
#include "Point.h"
#include "WrongDataException.h"

class Sampler 
{

/*
 ******************************************************************************
 ************************************ RAW DATA ********************************
 ******************************************************************************
 */

protected:
	const DataSet & _dataset;
	const BoxProcessor & _boxprocessor;

/*
 ******************************************************************************
 ********************************** CONSTRUCTORS ******************************
 ******************************************************************************
 */

public:
	Sampler(
		const DataSet & ds, 
		const BoxProcessor & bp);

/*
 ******************************************************************************
 ********************************* DATABASE QUERIES ***************************
 ******************************************************************************
 */

public:
	Box get_domain() const;

	DataSetItemVector get_domain_edges() const;

	std::vector<Box> get_intersections_of_spec_boxes(
		const BoxKind bk1, 
		const BoxKind bk2) const;

	bool have_intersection(
		const DataSetItem& dsi,
		const DataSetItemVector& dsivec) const;

	std::vector<Box> get_intersections(
		const DataSetItem& dsi,
		const DataSetItemVector& dsivec) const;

	DataSetItemVector reconstruct_dsiv(
		const std::vector<Box>& box_path) const;

/*
 ******************************************************************************
 ******************************* POI BOXES SELECTION **************************
 ******************************************************************************
 */

public:
	bool box_is_POI(
		const std::size_t element,
		const std::vector<std::size_t>& neighbours_for_element,
		const std::vector<Box>& boxes) const;

	std::vector<bool> select_POI_boxes(
		const std::vector<std::vector<std::size_t> >& neighbourhoods,
		const std::vector<Box>& boxes,
		const bool check_for_edges) const;

/*
 ******************************************************************************
 ******************************** BUILDING OF PATHS ***************************
 ******************************************************************************
 */

public:
	std::vector<std::vector<std::size_t> > get_paths(
		const std::vector<std::vector<std::size_t> >& neighbourhoods,
		const std::vector<std::size_t>& POI_boxes) const;

/*
 ******************************************************************************
 ******************************* SELECTIVE METHODS ****************************
 ******************************************************************************
 */

protected:
	bool has_value(
		const std::vector<bool>& where,
		const bool what) const;

	std::vector<std::size_t> get_indexes(
		const std::vector<bool>& where,
		const bool what) const;

	void delete_points(
		std::vector<Box>& boxes) const;

public:
	std::vector<DataSetItemVector> select_dsivs_having_neigh(
		const BoxKind bk,
		const std::vector<BoxKind> neigh_bk) const;

	std::vector<std::vector<Box> > select_boxes_having_neigh(
		const BoxKind bk,
		const std::vector<BoxKind> neigh_bk) const;

	std::vector<std::vector<Box> > select_edges_of_boxes_with_neigh(
		const BoxKind bk,
		const std::vector<BoxKind> neigh_bk) const;

/*
 ******************************************************************************
 ******************************** SAMPLING METHODS ****************************
 ******************************************************************************
 */

protected:
	std::vector<std::vector<Box> > obtain_necc_paths_to_domain_edges(
		const std::vector<std::vector<Box> >& paths,
		const bool only_fst_last_points,
		const bool corner_preference) const;

public:
	std::vector<Line> sample_mids_and_intersections(
		const std::vector<std::vector<Box> >& paths) const;

	std::vector<Line> sample_mids(
		const std::vector<std::vector<Box> >& paths) const;

	std::vector<Line> sample_line_paths(
		const std::vector<std::vector<Box> >& paths) const;

	std::vector<Border> sample_borders(
		const BoxKind bk,
		const std::vector<BoxKind>& neigh_bk) const;

	std::vector<std::size_t> decide_origin_component(
		const std::vector<DataSetItemVector>& dsiv,
		const std::vector<DataSetItemVector>& components) const;

};

#endif // _SAMPLER_HPP