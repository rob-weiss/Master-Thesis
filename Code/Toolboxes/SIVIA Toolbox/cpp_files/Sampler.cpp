// MUSIM UPRAVIT !!! POIs should be defined like this
// ~ 1. type POI = has intersect with at least 2 other non-point boxes in one place
// ~ 2. type POI = has intersect with other boxes at least in 3 different places
// ~ 3. type POI = has intersect with only one box
// ~ 4. type POI = is point alone in space that has no neighbours

#include "Sampler.h"

#include <algorithm>
#include <map>

#include "Border.h"
#include "Box.h"
#include "BoxKind.h"
#include "BoxProcessor.h"
#include "Comparers.h"
#include "DataSet.h"
#include "Line.h"
#include "Math.h"
#include "Point.h"

/*
 ******************************************************************************
 ********************************** CONSTRUCTORS ******************************
 ******************************************************************************
 */

/*! \brief Copy constructor.
 *
 */
Sampler::Sampler(
	const DataSet & ds, 
	const BoxProcessor & bp)
  : _dataset(ds), _boxprocessor(bp)
{ }

/*
 ******************************************************************************
 ********************************* DATABASE QUERIES ***************************
 ******************************************************************************
 */

/*! \brief Returns domain as Box.
 *
 */
Box Sampler::get_domain() const
{
	return
		Box(
		_dataset.get_min_x(), _dataset.get_max_x(),
		_dataset.get_min_y(), _dataset.get_max_y());
}

/*! \brief Returns domain edges as DataSetItemVector.
 *
 */
DataSetItemVector Sampler::get_domain_edges() const
{
	// we will get domain edge boxes
	DataSetItemVector domain_edges =
		_dataset.get_specific_boxes(BoxKind::EDGE_BOX);
	return domain_edges;
}

/*! \brief Returns intersections of boxes of BoxKind bk1 with boxes
 *  of BoxKind bk2.
 *
 *  If bk1 == bk2, then each intersection is returned just once.
 */
std::vector<Box> Sampler::get_intersections_of_spec_boxes(
	const BoxKind bk1, 
	const BoxKind bk2) const
{
	std::vector<Box> intersections;
	
	DataSetItemVector bk1_boxes = 
		_dataset.get_specific_boxes(bk1);
	
	for (auto& bk1_box : bk1_boxes)
	{
		if (bk1_box.has_specific_neighbour(bk2))
		{
			DataSetItemVector bk2_boxes = 
				bk1_box.get_specific_neighbours(bk2);
			for (auto& bk2_box : bk2_boxes)
			{
				intersections.emplace_back(
					bk1_box->get_intersection_with(*bk2_box));
			}
		}
	}

	if (bk1 == bk2)
	{
		for (std::size_t b1 = 0; b1 < intersections.size(); ++b1)
		{
			for (std::size_t b2 = b1 + 1; b2 < intersections.size(); ++b2)
			{
				if (intersections[b1] == intersections[b2])
				{
					intersections.erase(intersections.begin() + b2);
					--b2;
				}
			}
		}
	}

	return intersections;
}

/*! \brief Returns true, if dsi has any intersection with any of dsivec.
 * 
 */
bool Sampler::have_intersection(
	const DataSetItem& dsi,
	const DataSetItemVector& dsivec) const
{
	for (auto& item : dsivec)
	{
		if (item->has_intersection_with(*dsi))
		{
			return true;
		}
	}
	return false;
}

/*! \brief Returns intersections of dsi and dsivec.
 *
 */
std::vector<Box> Sampler::get_intersections(
	const DataSetItem& dsi,
	const DataSetItemVector& dsivec) const
{
	std::vector<Box> intersections;
	for (auto& item : dsivec)
	{
		if (item->has_intersection_with(*dsi))
		{
			intersections.emplace_back(
				item->get_intersection_with(*dsi));
		}
	}
	return intersections;
}

/*! \brief Returns boxes as DataSetItemVector. If there are more possible
 *  boxes in DataSet for current box, then first will be selected.
 *
 *  Throws exception if can't succeed and corresponding returned data 
 *  will not be viable.
 */
DataSetItemVector Sampler::reconstruct_dsiv(
	const std::vector<Box>& boxes) const
{
	DataSetItemVector reconstructed;
	std::vector<bool> success =
		_dataset.find_and_add(boxes, reconstructed);
	for (std::size_t s = 0; s < success.size(); ++s)
	{
		if (!success[s]) 
		{
			throw new WrongDataException("Box is not present in current DataSet");
		}
	}
	return reconstructed;
}


/*
 ******************************************************************************
 ******************************* POI BOXES SELECTION **************************
 ******************************************************************************
 */

/*! \brief Returns true, if box is considered as POI.
 *
 */
bool Sampler::box_is_POI(
	const std::size_t element,
	const std::vector<std::size_t>& neighbours_for_element,
	const std::vector<Box>& boxes) const
{
	// we will check if box isn't alone or just end of segment
	if (neighbours_for_element.size() < 2)
		return true;

	// we will check if box isn't possible crossroad
	if (neighbours_for_element.size() > 2)
		return true;

	return false;
}

/*! \brief Returns true/false for each box in boxes. True means that box
 *  is considered POI.
 *
 */
std::vector<bool> Sampler::select_POI_boxes(
	const std::vector<std::vector<std::size_t> >& neighbourhoods,
	const std::vector<Box>& boxes,
	const bool check_for_edges) const
{
	std::vector<bool> POIs;

	if (! check_for_edges)
	{
		// for each box will be checked now
		for (std::size_t b = 0; b < neighbourhoods.size(); ++b)
		{
			// we will check if box is typical POI
			bool is_typical_POI = box_is_POI(b, neighbourhoods[b], boxes);

			// we will decide
			POIs.push_back(is_typical_POI);
		}

		return POIs;
	}

	// we will get domain edge boxes
	DataSetItemVector domain_edges = get_domain_edges();

	// for each box will be checked now
	for (std::size_t b = 0; b < neighbourhoods.size(); ++b)
	{
		// we will check if box is typical POI
		bool is_typical_POI = box_is_POI(b, neighbourhoods[b], boxes);

		// we will check if box lies on the edge of domain
		bool has_intersect_with_domain_edge = false;
		for (auto& dm : domain_edges)
		{
			if (dm->has_intersection_with(boxes[b]))
			{
				has_intersect_with_domain_edge = true;
				break;
			}
		}

		// we will decide
		POIs.push_back(has_intersect_with_domain_edge || is_typical_POI);
	}

	return POIs;
}

/*
 ******************************************************************************
 ******************************** BUILDING OF PATHS ***************************
 ******************************************************************************
 */

/*! \brief Returns constructed paths, where returned data are paths. Path
 *  is sequence of indexes to corresponding boxes.
 *
 */
std::vector<std::vector<std::size_t> > Sampler::get_paths(
	const std::vector<std::vector<std::size_t> >& neighbourhoods,
	const std::vector<std::size_t>& POI_boxes) const
{
	std::vector<std::vector<std::size_t> > paths;

	if (neighbourhoods.size() == 0)
		return paths;

	std::vector<bool> reached_points(neighbourhoods.size(), false);
	
	bool at_least_one_POI_exists = false;
	if (POI_boxes.size() > 0)
		at_least_one_POI_exists = true;
	
	// if there exists at least one POI we will use general method
	if (at_least_one_POI_exists)
	{
		// vector of significances for not going the same path for 2 times
		// -> POI_marked_paths[i] ~ POI_boxes[i] neighbourhood
		// -> POI_marked_paths[i][j] ~ if path between POI_boxes[i] and
		//    ... j-th neighbour of POI_boxes[i] was searched
		std::vector<std::vector<bool> > POI_marked_paths;
		for (auto& pb : POI_boxes)
			POI_marked_paths.emplace_back(
			std::vector<bool>(neighbourhoods[pb].size(), false));

		// for every POI_box
		for (std::size_t poi = 0; poi < POI_boxes.size(); ++poi)
		{
			// special type -> does not have any neighbour, but we still need 
			// ... might need him 
			if (POI_marked_paths[poi].size() == 0)
			{
				const std::vector<size_t> path {POI_boxes[poi]};
				paths.emplace_back(path);
				reached_points[POI_boxes[poi]] = true;
			}

			// for every neighbour of POI_box
			for (std::size_t nei = 0; nei < POI_marked_paths[poi].size(); ++nei)
			{
				// we will check, if the path from each of his neighbour has been 
				// ... made and if some hasn't been made then we will make one
				if (!POI_marked_paths[poi][nei])
				{
					std::vector<size_t> path;

					// we will put down that we have searched this path
					POI_marked_paths[poi][nei] = true;

					std::size_t current = POI_boxes[poi];
					std::size_t next = neighbourhoods[POI_boxes[poi]][nei];

					// we will find path to POI
					for (;;)
					{
						// we add current to path
						path.push_back(current);
						reached_points[current] = true;

						// we will find out if next one is POI
						bool next_is_POI = false;

						// if box is POI, then this is his location in POIs[c]
						int which_poi_is_next = -1;
						for (std::size_t i = 0; i < POI_boxes.size(); ++i)
						{
							if (next == POI_boxes[i])
							{
								next_is_POI = true;
								which_poi_is_next = (int)i;
								break;
							}
						}

						// next one is POI, so we have found the end of our path
						if (next_is_POI)
						{
							// add final box to path
							path.push_back(next);
							reached_points[next] = true;

							// we will find out, which neighbour of current
							int which_neighbour_is_current = -1;
							for (std::size_t i = 0; i < neighbourhoods[POI_boxes[which_poi_is_next]].size(); ++i)
							{
								if (neighbourhoods[POI_boxes[which_poi_is_next]][i] == current)
								{
									which_neighbour_is_current = (int)i;
									break;
								}
							}

							// we will put down that we have searched this path
							POI_marked_paths[which_poi_is_next][which_neighbour_is_current] = true;

							// breaks the cycle of finding path
							break;
						}
						// we continue our searching path towards some POI_box
						else
						{
							// we will find next box in path
							if (neighbourhoods[next][0] == current)
							{
								current = next;
								next = neighbourhoods[next][1];
							}
							//  neighbourhoods[next][1] == current
							else
							{
								current = next;
								next = neighbourhoods[next][0];
							}
						}
					}
					paths.emplace_back(path);
				}
			}
		}
	}

	// no other POIs exists so we will use circle method, 
	// ... becouse all boxes should have just 2 neighbours now 
	// ... and any box is near the domain edge
	while (has_value(reached_points, false))
	{
		std::vector<std::size_t> path;

		std::vector<std::size_t> possible_starts =
			get_indexes(reached_points, false);

		// we will remember, which element was first
		std::size_t first = possible_starts[0];
		std::size_t current = first;
		std::size_t next = neighbourhoods[first][0];

		// we will use greedy way of creating path
		for (;;)
		{
			// we add current to path
			path.push_back(current);
			reached_points[next] = true;

			// when we will get again on the first, we are done
			if (next == first)
			{
				path.push_back(next);
				// next == first and we know, that first is already reached
				break;
			}

			// we will find next box in path
			if (neighbourhoods[next][0] == current)
			{
				current = next;
				next = neighbourhoods[next][1];
			}
			//  neighbourhoods[next][1] == current
			else
			{
				current = next;
				next = neighbourhoods[next][0];
			}
		}
		paths.emplace_back(path);
	}

	return paths;
}

/*
 ******************************************************************************
 ******************************* SELECTIVE METHODS ****************************
 ******************************************************************************
 */

/*! \brief Returns true if there is instance of what in where.
 *
 */
bool Sampler::has_value(
	const std::vector<bool>& where,
	const bool what) const
{
	for (std::size_t i = 0; i < where.size(); ++i)
	{
		if (where[i] == what)
			return true;
	}
	
	return false;
}

/*! \brief Returns indexes of what in where.
 *
 */
std::vector<std::size_t> Sampler::get_indexes(
	const std::vector<bool>& where,
	const bool what) const
{
	std::vector<std::size_t> indexes;
	for (std::size_t i = 0; i < where.size(); ++i)
	{
		if (where[i] == what)
			indexes.push_back(i);
	}
	return indexes;
}

/*! \brief Method will delete all points from boxes.
 *
 */
void Sampler::delete_points(
	std::vector<Box>& boxes) const
{
	for (std::size_t i = 0; i < boxes.size(); ++i)
	if (boxes[i].is_point())
	{
		boxes.erase(boxes.begin() + i);
		--i;
	}
}

/*! \brief Returns DataSetItemVectors which have specific neighbours.
 *
 *  In this method all selected boxes are lines.
 */
std::vector<DataSetItemVector> Sampler::select_dsivs_having_neigh(
	const BoxKind bk,
	const std::vector<BoxKind> neigh_bk) const
{
	std::vector<std::vector<Box> > result_boxes = 
		select_boxes_having_neigh(bk, neigh_bk);
	std::vector<DataSetItemVector> result_dsivs;
	
	for (auto& path : result_boxes)
	{
		result_dsivs.push_back(reconstruct_dsiv(path));
	}

	return result_dsivs;
}


/*! \brief Returns vectors of boxes which have specific neighbours.
 *
 *  In this method all selected boxes are lines.
 */
std::vector<std::vector<Box> > Sampler::select_boxes_having_neigh(
	const BoxKind bk,
	const std::vector<BoxKind> neigh_bk) const
{
	std::vector<std::vector<Box> > result_boxes;

	// we will get all unknown components
	std::vector<DataSetItemVector> bk_comps =
		_dataset.get_specific_components(bk);

	// for every component
	for (auto& bk_c : bk_comps)
	{
		// we will get all boxes with intersection of component with neigh_bk
		std::vector<Box> selected_boxes;

		// for every DataSetItem in component 
		for (auto& bk_dsi : bk_c)
		{
			// for every specific box kind we will check, if there is 
			// ... any neighbour of this kind
			for (auto& spec_bk : neigh_bk)
			{
				const DataSetItemVector spec_neighs = 
					bk_dsi.get_specific_neighbours(spec_bk);
				// if there is any box of the specific kind we will 
				// ... add content of dsi to selected_boxes
				if (spec_neighs.size() > 0)
				{
					selected_boxes.push_back(bk_dsi.get_content());
					break;
				}
			}
		}

		// we will separate selected_boxes into components
		std::vector<std::vector<Box> > selected_boxes_in_components
			= _boxprocessor.get_components(selected_boxes);

		// for every component of selected_boxes
		for (auto& sbc : selected_boxes_in_components)
		{
			// we will delete points
			delete_points(sbc);

			// we will build neighbourhoods defined like
			// -> neighbourhoods[i] ~ vector of neighbours of element i from sbc
			std::vector<std::vector<std::size_t> > neighbourhoods =
				_boxprocessor.get_neighbourhoods(sbc);

			// we will delete unneeded corners from neighbourhoods
			_boxprocessor.delete_unneeded_corners_in_neighbours(neighbourhoods, sbc);

			// we will select POIs
			bool check_for_edges = ! (bk == BoxKind::EDGE_BOX);
			std::vector<bool> POI_detections =
				select_POI_boxes(neighbourhoods, sbc, check_for_edges);

			// we will check, if there is any POI
			std::vector<std::size_t> POI_boxes =
				get_indexes(POI_detections, true);

			// we will get paths
			std::vector<std::vector<std::size_t> > paths =
				get_paths(neighbourhoods, POI_boxes);

			// for every path
			for (auto& path : paths)
			{
				std::vector<Box> box_path;
				DataSetItemVector dsiv_path;
				for (auto& box : path)
				{
					box_path.push_back(sbc[box]);
				}
				result_boxes.push_back(box_path);
			} // for every path

		} // for sbc

	} // for every component

	return result_boxes;
}

/*! \brief Returns vectors of edges of boxes which have specific neighbours.
 *
 */
std::vector<std::vector<Box> > Sampler::select_edges_of_boxes_with_neigh(
	const BoxKind bk,
	const std::vector<BoxKind> neigh_bk) const
{
	std::vector<std::vector<Box> > result_boxes;

	// we will get all unknown components
	std::vector<DataSetItemVector> bk_comps =
		_dataset.get_specific_components(bk);

	// for every component
	for (auto& bk_c : bk_comps)
	{
		// we will get all boxes with intersection of component with neigh_bk
		std::vector<Box> selected_boxes;

		// for every DataSetItem in component 
		for (auto& bk_dsi : bk_c)
		{
			// for every specific box kind we will check, if there is 
			// ... any neighbour of this kind
			for (auto& spec_bk : neigh_bk)
			{
				const DataSetItemVector spec_neighs =
					bk_dsi.get_specific_neighbours(spec_bk);
				// for box of the specific kind we will add intersection 
				// ... of dsi with spec_neigh to selected_boxes
				for (auto& spec_n : spec_neighs)
				{
					selected_boxes.push_back(
						bk_dsi->get_intersection_with(*spec_n));
				}
			}
		}

		// we will separate selected_boxes into components
		std::vector<std::vector<Box> > selected_boxes_in_components = 
			_boxprocessor.get_components(selected_boxes);

		// for every component of selected_boxes
		for (auto& sbc : selected_boxes_in_components)
		{
			// we will delete points
			delete_points(sbc);

			// we will build neighbourhoods defined like
			// -> neighbourhoods[i] ~ vector of neighbours of element i from sbc
			std::vector<std::vector<std::size_t> > neighbourhoods =
				_boxprocessor.get_neighbourhoods(sbc);

			// we will delete unneeded corners from neighbourhoods
			_boxprocessor.delete_unneeded_corners_in_neighbours(neighbourhoods, sbc);

			// we will select POIs
			bool check_for_edges = ! (bk == BoxKind::EDGE_BOX);
			std::vector<bool> POI_detections =
				select_POI_boxes(neighbourhoods, sbc, check_for_edges);

			// we will check, if there is any POI
			std::vector<std::size_t> POI_boxes =
				get_indexes(POI_detections, true);

			// we will get paths
			std::vector<std::vector<std::size_t> > paths =
				get_paths(neighbourhoods, POI_boxes);

			// for every path
			for (auto& path : paths)
			{
				std::vector<Box> box_path;
				DataSetItemVector dsiv_path;
				for (auto& box : path)
				{
					box_path.push_back(sbc[box]);
				}
				result_boxes.push_back(box_path);
			} // for every path

		} // for sbc

	} // for every component

	return result_boxes;
}

/*
 ******************************************************************************
 ******************************** SAMPLING METHODS ****************************
 ******************************************************************************
 */

/*! \brief Obtain parts that needs to be added due to being neighbours 
 *  of domain edges.
 *
 */
std::vector<std::vector<Box> > Sampler::obtain_necc_paths_to_domain_edges(
	const std::vector<std::vector<Box> >& paths,
	const bool only_fst_last_points, 
	const bool corner_preference) const
{
	std::vector<std::vector<Box> > results;

	// there should be 4 domain edges
	DataSetItemVector domain_edges = get_domain_edges();

	std::vector<std::set<Box, BoxComparer> > points_near_the_domain_edge;
	for (auto& de : domain_edges)
	{
		points_near_the_domain_edge.push_back(
			std::set<Box, BoxComparer>());
	}

	// we will select all points near the domain edge
	for (std::size_t de = 0; de < domain_edges.size(); ++de)
	{
		for (auto& path : paths)
		{
			if (only_fst_last_points)
			{
				if (domain_edges[de]->has_intersection_with(path[0]))
				{
					auto start_ptr = points_near_the_domain_edge[de].find(path[0]);
					if (start_ptr == points_near_the_domain_edge[de].end())
						points_near_the_domain_edge[de].insert(path[0]);
				}

				if (domain_edges[de]->has_intersection_with(path[path.size() - 1]))
				{
					auto end_ptr = points_near_the_domain_edge[de].find(path[path.size() - 1]);
					if (end_ptr == points_near_the_domain_edge[de].end())
						points_near_the_domain_edge[de].insert(path[path.size() - 1]);
				}				
			}
			// all points checking
			else
			{
				for (auto& box : path)
				{
					if (domain_edges[de]->has_intersection_with(box))
					{
						auto ptr = points_near_the_domain_edge[de].find(box);
						if (ptr == points_near_the_domain_edge[de].end())
							points_near_the_domain_edge[de].insert(box);
					}
				}
			}
		}
	}
	
	for (std::size_t de = 0; de < points_near_the_domain_edge.size(); ++de)
	{
		for (auto& box : points_near_the_domain_edge[de])
		{
			bool corner = false;

			if (corner_preference)
			{
				for (std::size_t other_de = 0;
					other_de < points_near_the_domain_edge.size();
					++other_de)
				{
					if (de == other_de)
						continue;

					if (points_near_the_domain_edge[other_de].find(box) !=
						points_near_the_domain_edge[other_de].end())
					{
						corner = true;

						// to have each corner path only once
						if (de < other_de)
						{
							results.push_back(std::vector<Box>({
								box,
								domain_edges[de]->get_intersection_with(*domain_edges[other_de])
							}));
						}
					}
				}
			}

			if (!corner)
			{
				results.push_back(std::vector<Box>({
					box, 
					domain_edges[de]->get_intersection_with(box)
				}));
			}

		} // for each box in domain edge

	} // for each domain edge

	return results;
}

/*! \brief Sample Lines as sequences of mids and intersections.
 *
 *  For example: we have 3 boxes in path. 
 *  First point will be mid of the first box.
 *  Second point will be mid of intersection of the first box and the second box.
 *  Third point will be mid of the second box.
 *  Fourth point will be mid of intersection of the second box and the third box.
 *  Fifth point will be mid of the third box.
 */
std::vector<Line> Sampler::sample_mids_and_intersections(
	const std::vector<std::vector<Box> >& paths) const
{
	std::vector<Line> result;

	// for every path
	for (auto& path : paths)
	{
		// we have found path and now we will create line
		Line path_of_points;

		if (path.size() == 0)
			continue;

		if (path.size() == 1)
		{
			if (path[0].is_point())
				continue;

			if (path[0].is_line())
			{
				path_of_points.emplace_back(Point(
					path[0].get_x().get_fst(),
					path[0].get_y().get_fst()));
				path_of_points.emplace_back(Point(
					path[0].get_x().get_snd(),
					path[0].get_y().get_snd()));
				result.push_back(path_of_points);
				continue;
			}

			path_of_points.emplace_back(Point(
				path[0].get_x().get_fst(),
				path[0].get_y().mid()));
			path_of_points.emplace_back(Point(
				path[0].get_x().mid(),
				path[0].get_y().get_fst()));
			path_of_points.emplace_back(Point(
				path[0].get_x().get_snd(),
				path[0].get_y().mid()));
			path_of_points.emplace_back(Point(
				path[0].get_x().mid(),
				path[0].get_y().get_snd()));
			result.push_back(path_of_points);
			continue;
		}

		// for every path we will create path of points
		for (std::size_t which_box = 0; which_box < path.size(); ++which_box)
		{
			// in the sequence
			if (which_box > 0 && which_box < path.size() - 1)
			{
				Box inter = 
					path[which_box - 1].get_intersection_with(
					path[which_box]);

				path_of_points.emplace_back(inter.mid());
				path_of_points.emplace_back(path[which_box].mid());
			}
			else
			// end of sequence
			if (which_box == path.size() - 1)
			{
				Box inter =
					path[which_box - 1].get_intersection_with(
					path[which_box]);

				path_of_points.emplace_back(inter.mid());
				path_of_points.emplace_back(path[which_box].mid());
			}
			// start of the sequence ~ which_box == 0
			else
			{
				path_of_points.emplace_back(path[which_box].mid());
			}
		}

		// we will add path to the result
		result.push_back(path_of_points);

	} // for every path

	// adding missing important paths - start/end box + intersection 
	// ... with domain edge
	std::vector<std::vector<Box> > domain_edges_conns =
		obtain_necc_paths_to_domain_edges(paths, true, false);
	for (auto& line : domain_edges_conns)
	{
		result.push_back(Line({ line[0].mid(), line[1].mid() }));
	}

	return result;
}

/*! \brief Sample Lines as sequences of mids.
 *
 *  For example: we have 3 boxes in path. 
 *  First point will be mid of the first box.
 *  Second point will be mid of the second box.
 *  Third point will be mid of the third box.
 */
std::vector<Line> Sampler::sample_mids(
	const std::vector<std::vector<Box> >& paths) const
{
	std::vector<Line> result;

	// for every path
	for (auto& path : paths)
	{
		// we have found path and now we will create line
		Line path_of_points;

		if (path.size() == 0)
			continue;

		if (path.size() == 1)
		{
			if (path[0].is_point())
				continue;

			if (path[0].is_line())
			{
				path_of_points.emplace_back(Point(
					path[0].get_x().get_fst(),
					path[0].get_y().get_fst()));
				path_of_points.emplace_back(Point(
					path[0].get_x().get_snd(),
					path[0].get_y().get_snd()));
				result.push_back(path_of_points);
				continue;
			}

			path_of_points.emplace_back(Point(
				path[0].get_x().get_fst(),
				path[0].get_y().mid()));
			path_of_points.emplace_back(Point(
				path[0].get_x().mid(),
				path[0].get_y().get_fst()));
			path_of_points.emplace_back(Point(
				path[0].get_x().get_snd(),
				path[0].get_y().mid()));
			path_of_points.emplace_back(Point(
				path[0].get_x().mid(),
				path[0].get_y().get_snd()));
			result.push_back(path_of_points);
			continue;
		}

		// for every path we will create path of points
		for (std::size_t which_box = 0; which_box < path.size(); ++which_box)
		{
			path_of_points.emplace_back(path[which_box].mid());
		}

		// we will add path to the result
		result.push_back(path_of_points);

	} // for every path

	// adding missing important paths - start/end box + intersection 
	// ... with domain edge
	std::vector<std::vector<Box> > domain_edges_conns =
		obtain_necc_paths_to_domain_edges(paths, true, false);
	for (auto& line : domain_edges_conns)
	{
		result.push_back(Line({ line[0].mid(), line[1].mid() }));
	}

	return result;
}

/*! \brief Sample Lines as sequences edge points of boxes. We suppose 
 *  that boxes are lines.
 *
 *  For example: we have 3 boxes in path. 
 *  First point will be an ending point of the first box, which is further from the 
 *  second box.
 *  Second point will be mid of intersection of the first box and the second box.
 *  Third point will be mid of intersection of the second box and the third box.
 *  Fourth point will be an ending point of the third box, which is further from the 
 *  second box.
 */
std::vector<Line> Sampler::sample_line_paths(
	const std::vector<std::vector<Box> >& paths) const
{
	std::vector<Line> result;

	for (auto& path : paths)
	{
		for (auto& box : path)
		{
			if (box.is_line() && box.is_point())
				throw new WrongDataException("sample_line_paths works only for lines");
		}
	}

	// for every path
	for (std::size_t i = 0; i < paths.size(); ++i)
	{
		const std::vector<Box>& path = paths[i];

		// we have found path and now we will create line
		Line path_of_points;

		if (path.size() == 0)
			continue;

		if (path.size() == 1)
		{
			if (path[0].is_point())
				continue;

			if (path[0].is_line())
			{
				path_of_points.emplace_back(Point(
					path[0].get_x().get_fst(),
					path[0].get_y().get_fst()));
				path_of_points.emplace_back(Point(
					path[0].get_x().get_snd(),
					path[0].get_y().get_snd()));
				result.push_back(path_of_points);
				continue;
			}

			path_of_points.emplace_back(Point(
				path[0].get_x().get_fst(),
				path[0].get_y().mid()));
			path_of_points.emplace_back(Point(
				path[0].get_x().mid(),
				path[0].get_y().get_fst()));
			path_of_points.emplace_back(Point(
				path[0].get_x().get_snd(),
				path[0].get_y().mid()));
			path_of_points.emplace_back(Point(
				path[0].get_x().mid(),
				path[0].get_y().get_snd()));
			result.push_back(path_of_points);
			continue;
		}

		// we will get info, if path with >= 2 points is cyclic
		bool is_cyclic = (path[0] == path[path.size() - 1]);

		bool startp_mid = false;
		bool endp_mid = false;

		if (is_cyclic)
		{
			startp_mid = true;
			endp_mid = true;
		}
		else
		{
			for (std::size_t j = 0; j < paths.size(); ++j)
			{
				if (i == j)
					continue;
				if (path[0] == paths[j][0] ||
					path[0] == paths[j][paths[j].size() - 1])
					startp_mid = true;
				if (path[path.size() - 1] == paths[j][0] ||
					path[path.size() - 1] == paths[j][paths[j].size() - 1])
					endp_mid = true;
			}
		}

		// for every path we will create path of points
		for (std::size_t which_box = 0; which_box < path.size(); ++which_box)
		{
			// in the sequence
			if (which_box > 0 && which_box < path.size() - 1)
			{
				if (path[which_box].get_x().get_fst() ==
					path_of_points[path_of_points.size() - 1].get_x() &&
					path[which_box].get_y().get_fst() ==
					path_of_points[path_of_points.size() - 1].get_y())
				{
					path_of_points.emplace_back(Point(
						path[which_box].get_x().get_snd(),
						path[which_box].get_y().get_snd()));
				}
				else
				{
					path_of_points.emplace_back(Point(
						path[which_box].get_x().get_fst(),
						path[which_box].get_y().get_fst()));
				}
			}
			else
			// end of sequence
			if (which_box == path.size() - 1)
			{
				if (endp_mid)
				{
					path_of_points.emplace_back(path[which_box].mid());
				}
				else
				{
					Box is =
						path[path.size() - 2].get_intersection_with(
						path[path.size() - 1]);

					if (is.get_x().get_fst() == path[path.size() - 1].get_x().get_snd() &&
						is.get_y().get_fst() == path[path.size() - 1].get_y().get_snd())
					{
						path_of_points.emplace_back(Point(
							path[which_box].get_x().get_fst(),
							path[which_box].get_y().get_fst()));
					}
					else
					{
						path_of_points.emplace_back(Point(
							path[which_box].get_x().get_snd(),
							path[which_box].get_y().get_snd()));
					}
				}
			}
			// start of the sequence ~ which_box == 0
			else
			{
				Box is = 
					path[0].get_intersection_with(
					path[1]);

				if (is.get_x().get_fst() == path[0].get_x().get_snd() &&
					is.get_y().get_fst() == path[0].get_y().get_snd())
				{
					if (startp_mid)
					{
						path_of_points.emplace_back(path[which_box].mid());
					}
					else
					{
						path_of_points.emplace_back(Point(
							path[which_box].get_x().get_fst(),
							path[which_box].get_y().get_fst()));
					}

					path_of_points.emplace_back(Point(
						path[which_box].get_x().get_snd(),
						path[which_box].get_y().get_snd()));
				}
				else
				{
					if (startp_mid)
					{
						path_of_points.emplace_back(path[which_box].mid());
					}
					else
					{
						path_of_points.emplace_back(Point(
							path[which_box].get_x().get_snd(),
							path[which_box].get_y().get_snd()));
					}

					path_of_points.emplace_back(Point(
						path[which_box].get_x().get_fst(),
						path[which_box].get_y().get_fst()));
				}
			}
		}

		// we will add path to the result
		result.push_back(path_of_points);

	} // for every path

	return result;
}

// neosetrujem, ze su tam 2 krat rovnake hranice, ak bk1 == bk2
// prienik boxov moze byt bod alebo usecka, nic ine
/*! \brief This method returns borders of boxes with BoxKind bk with
*  boxes of specific BoxKinds.
*
*  I don't check, if there are not twice same borders. Also I don't check
*  if there are not boxes which are only lines or points.
*/
std::vector<Border> Sampler::sample_borders(
	const BoxKind bk,
	const std::vector<BoxKind>& neigh_bk) const
{
	std::vector<Border> result;

	std::vector<DataSetItemVector> bk_boxes =
		_dataset.get_specific_components(bk);

	// for every component of bk boxes
	for (auto& bk_comp : bk_boxes)
	{
		// for each specific neigh_bk we will procceed individually
		for (auto& spec_bk : neigh_bk)
		{
			std::vector<Box> intersections;

			// fst_side ~ BoxKind with larger x if it is vertical line
			// ... else ~ BoxKind with lesser y if it is horizontal line
			// ... alternatively -> BoxKind on the right side
			std::vector<BoxKind> fst_side_type;

			// snd_side ~ BoxKind with lesser x if it is vertical line
			// ... else ~ BoxKind with larger y if it is horizontal line
			// ... alternatively -> BoxKind on the left side
			std::vector<BoxKind> snd_side_type;

			// for every box of the bk component
			for (auto& bk_b : bk_comp)
			{
				// we will get neighbours of specific BoxKind
				DataSetItemVector spec_boxes =
					bk_b.get_specific_neighbours(spec_bk);

				// for every neighbour of specific BoxKind
				for (auto& spec_b : spec_boxes)
				{
					// we will get their intersect
					Box intersection =
						bk_b->get_intersection_with(*spec_b);

					// if intersection is point then its not important for us
					if (intersection.is_point())
						continue;

					// we will add new intersection
					intersections.push_back(intersection);

					// we will add new intersection's BoxKind informations
					if (spec_b->is_line() && bk_b->is_line())
					{
						fst_side_type.push_back(BoxKind::UNDEFINED);
						snd_side_type.push_back(BoxKind::UNDEFINED);
						continue;
					}

					if (spec_b->is_line())
					{
						if (IsOnTheRight(
							Point(intersection.get_x().get_fst(), intersection.get_y().get_fst()),
							Point(intersection.get_x().get_snd(), intersection.get_y().get_snd()),
							bk_b->mid()))
						{
							fst_side_type.push_back(bk);
							snd_side_type.push_back(spec_bk);
							continue;
						}

						if (IsOnTheLeft(
							Point(intersection.get_x().get_fst(), intersection.get_y().get_fst()),
							Point(intersection.get_x().get_snd(), intersection.get_y().get_snd()),
							bk_b->mid()))
						{
							fst_side_type.push_back(spec_bk);
							snd_side_type.push_back(bk);
							continue;
						}

						// other variants
						{
							fst_side_type.push_back(BoxKind::UNDEFINED);
							snd_side_type.push_back(BoxKind::UNDEFINED);
							continue;
						}
					}

					if (IsOnTheRight(
						Point(intersection.get_x().get_fst(), intersection.get_y().get_fst()),
						Point(intersection.get_x().get_snd(), intersection.get_y().get_snd()),
						spec_b->mid()))
					{
						fst_side_type.push_back(spec_bk);
						snd_side_type.push_back(bk);
						continue;
					}

					if (IsOnTheLeft(
						Point(intersection.get_x().get_fst(), intersection.get_y().get_fst()),
						Point(intersection.get_x().get_snd(), intersection.get_y().get_snd()),
						spec_b->mid()))
					{
						fst_side_type.push_back(bk);
						snd_side_type.push_back(spec_bk);
						continue;
					}

					// other variants
					{
						fst_side_type.push_back(BoxKind::UNDEFINED);
						snd_side_type.push_back(BoxKind::UNDEFINED);
						continue;
					}

				} // for every neighbour of specific BoxKind

			} // for every box of the bk component

			std::vector<std::vector<std::size_t> > neighbourhoods =
				_boxprocessor.get_neighbourhoods(intersections);

			std::vector<bool> POI_detections;

			bool check_for_edges = !(bk == BoxKind::EDGE_BOX);
			POI_detections =
				select_POI_boxes(neighbourhoods, intersections, check_for_edges);

			// we will ensure that we get only coresponding sides by adding more POIs
			// for every intersection
			for (std::size_t i = 0; i < neighbourhoods.size(); ++i)
			{
				// for every intersection's neighbour
				for (std::size_t n = 0; n < neighbourhoods[i].size(); ++n)
				{
					if ((intersections[neighbourhoods[i][n]].get_x().get_fst() ==
						 intersections[neighbourhoods[i][n]].get_x().get_snd() &&
						 intersections[i].get_x().get_fst() ==
						 intersections[i].get_x().get_snd() &&
						 (fst_side_type[i] != fst_side_type[neighbourhoods[i][n]] ||
						  snd_side_type[i] != snd_side_type[neighbourhoods[i][n]]))
						||
						(intersections[neighbourhoods[i][n]].get_y().get_fst() ==
						 intersections[neighbourhoods[i][n]].get_y().get_snd() &&
						 intersections[i].get_y().get_fst() ==
						 intersections[i].get_y().get_snd() &&
						 (fst_side_type[i] != fst_side_type[neighbourhoods[i][n]] ||
						  snd_side_type[i] != snd_side_type[neighbourhoods[i][n]]))
					   )
					{
						//neighbourhoods[i].erase(neighbourhoods[i].begin() + n);
						//--n;
						POI_detections[i] = true;
						POI_detections[n] = true;
					}
				}
			}

			// we will check, if there is any POI
			std::vector<std::size_t> POI_boxes =
				get_indexes(POI_detections, true);

			// we will get paths
			std::vector<std::vector<std::size_t> > paths =
				get_paths(neighbourhoods, POI_boxes);

			// we will construct borders from paths
			for (auto& path : paths)
			{
				if (path.size() == 0)
					continue;

				// path of points construction
				Line path_of_points;

				// special variant, where path is only one point
				if (path.size() == 1)
				{
					path_of_points.emplace_back(
						intersections[path[0]].get_x().get_fst(),
						intersections[path[0]].get_y().get_fst());
					path_of_points.emplace_back(
						intersections[path[0]].get_x().get_snd(),
						intersections[path[0]].get_y().get_snd());
				}
				// path is made of more than one point
				else
				{

					if ((intersections[path[0]].get_x().get_fst() ==
						 intersections[path[1]].get_x().get_fst() &&
						 intersections[path[0]].get_y().get_fst() ==
						 intersections[path[1]].get_y().get_fst())
						||
						(intersections[path[0]].get_x().get_fst() ==
						 intersections[path[1]].get_x().get_snd() &&
						 intersections[path[0]].get_y().get_fst() ==
						 intersections[path[1]].get_y().get_snd()))
					{
						path_of_points.emplace_back(
							intersections[path[0]].get_x().get_snd(),
							intersections[path[0]].get_y().get_snd());
					}
					else
					{
						path_of_points.emplace_back(
							intersections[path[0]].get_x().get_fst(),
							intersections[path[0]].get_y().get_fst());
					}

					for (std::size_t i = 0; i < path.size() - 1; ++i)
					{
						Box inters =
							intersections[path[i]].get_intersection_with(
							intersections[path[i + 1]]);

						path_of_points.emplace_back(
							inters.get_x().get_fst(),
							inters.get_y().get_fst());
					}

					if (intersections[path[0]] != intersections[path[path.size() - 1]])
					{
						if ((intersections[path[path.size() - 1]].get_x().get_fst() ==
							 intersections[path[path.size() - 2]].get_x().get_fst() &&
							 intersections[path[path.size() - 1]].get_y().get_fst() ==
							 intersections[path[path.size() - 2]].get_y().get_fst())
							||
							(intersections[path[path.size() - 1]].get_x().get_fst() ==
							 intersections[path[path.size() - 2]].get_x().get_snd() &&
							 intersections[path[path.size() - 1]].get_y().get_fst() ==
							 intersections[path[path.size() - 2]].get_y().get_snd()))
						{
							path_of_points.emplace_back(
								intersections[path[path.size() - 1]].get_x().get_snd(),
								intersections[path[path.size() - 1]].get_y().get_snd());
						}
						else
						{
							path_of_points.emplace_back(
								intersections[path[path.size() - 1]].get_x().get_fst(),
								intersections[path[path.size() - 1]].get_y().get_fst());
						}
					}

				} // path of more than one point

				// assigning BoxKinds due to first 2 points ~ points of 
				// ... the first box
				BoxKind l, r;

				if (path_of_points[0].get_x() == path_of_points[1].get_x())
				{
					if (path_of_points[0].get_y() < path_of_points[1].get_y())
					{
						r = fst_side_type[path[0]];
						l = snd_side_type[path[0]];
					}
					else
					if (path_of_points[0].get_y() > path_of_points[1].get_y())
					{
						r = snd_side_type[path[0]];
						l = fst_side_type[path[0]];
					}
					else
					{
						// warning
					}
				}
				else
				if (path_of_points[0].get_y() == path_of_points[1].get_y())
				{
					if (path_of_points[0].get_x() < path_of_points[1].get_x())
					{
						r = fst_side_type[path[0]];
						l = snd_side_type[path[0]];
					}
					else
					if (path_of_points[0].get_x() > path_of_points[1].get_x())
					{
						r = snd_side_type[path[0]];
						l = fst_side_type[path[0]];
					}
					else
					{
						// error
					}
				}
				// (path_of_points[0].get_x() == path_of_points[1].get_x() && 
				//  path_of_points[0].get_y() == path_of_points[1].get_y())
				else
				{
					// error
				}

				result.emplace_back(path_of_points, r, l);

			} // for every path

		} // for each specific neigh_bk

	} // for every component of bk boxes

	return result;
}

/*! \brief This method will try to guess for every dsiv and possible components
 *  original component of the dsiv.
 *
 *  If the satisfying component is not assigned to the dsiv, then 
 *  invalid/non-existing component is assigned.
 */
std::vector<std::size_t> Sampler::decide_origin_component(
	const std::vector<DataSetItemVector>& dsivs,
	const std::vector<DataSetItemVector>& components) const
{
	std::vector<std::size_t> dsivs_origin_comps;
	for (auto& dsiv : dsivs)
	{
		if (dsiv.size() == 0)
		{
			dsivs_origin_comps.push_back(components.size());
			continue;
		}
		bool found = false;
		for (std::size_t c = 0; c < components.size(); ++c)
		{
			if (components[c].size() == 0)
			{
				continue;
			}
			if (dsiv[0].is_in_same_component_as(components[c][0]))
			{
				dsivs_origin_comps.push_back(components.size());
				found = true;
				break;
			}
		}
		// if not found component, then original component is not in components
		if (!found)
		{
			dsivs_origin_comps.push_back(components.size());
		}
	}
	return dsivs_origin_comps;
}

