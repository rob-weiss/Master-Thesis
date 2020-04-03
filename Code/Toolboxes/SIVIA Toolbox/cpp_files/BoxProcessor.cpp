#include "BoxProcessor.h"

#include <map>
#include <set>
#include <utility>
#include <vector>

#include "BoxKind.h"
#include "DataSet.h"
#include "Point.h"
#include "Sampler.h"

/*
 ******************************************************************************
 ****************************** OBTAINING COMPONENTS **************************
 ******************************************************************************
 */

void BoxProcessor::get_components_recursion(
	const std::size_t which_element,
	const std::size_t not_assigned_value,
	const std::vector<Box>& boxes,
	std::vector<std::size_t>& components) const
{
	for (std::size_t i = 0; i < boxes.size(); ++i)
	{
		if (components[i] == not_assigned_value)
		{
			if (boxes[i].has_intersection_with(
				boxes[which_element]))
			{
				components[i] = components[which_element];
				get_components_recursion(i, not_assigned_value, boxes, components);
			}
		}
	}
}

std::vector<std::vector<Box> > BoxProcessor::get_components(
	const std::vector<Box>& boxes) const
{
	std::size_t not_assigned_value = 0;
	std::vector<std::size_t> components =
		std::vector<std::size_t>(boxes.size(), not_assigned_value);

	std::size_t component_number = 1;
	for (;;)
	{
		std::size_t element_of_component = 0;
		for (; element_of_component < components.size(); ++element_of_component)
		{
			if (components[element_of_component] == not_assigned_value)
			{
				break;
			}
		}

		if (element_of_component == components.size())
			break;

		components[element_of_component] = component_number;
		get_components_recursion(
			element_of_component,
			not_assigned_value,
			boxes,
			components);
		++component_number;
	}

	std::size_t max = not_assigned_value;
	for (std::size_t i = 0; i < components.size(); ++i)
	{
		if (components[i] > max)
			max = components[i];
	}

	std::vector<std::vector<Box> > result_comps;
	for (std::size_t i = not_assigned_value + 1; i <= max; ++i)
	{
		std::vector<Box> comp;
		for (std::size_t j = 0; j < components.size(); ++j)
		{
			if (i == components[j])
				comp.emplace_back(boxes[j]);
		}
		result_comps.emplace_back(comp);
	}
	return result_comps;
}

/*
 ******************************************************************************
 *************************** OBTAINING COVERAGE OF EDGES **********************
 ******************************************************************************
 */

std::vector<std::vector<Box> > BoxProcessor::get_edges_of_box(
	const Box& b) const
{
	// box's edges are in this sequence 
	// -> smaller x (left),  larger x (right),  smaller y (down), larger y (up)
	// -> mensie  x (vlavo), vacsie x (vpravo), mensie  y (dole), vacsie y (hore)
	std::vector<std::vector<Box> > edges_of_box;

	{
		std::vector<Box> left_edge;
		left_edge.push_back(
			Box(b.get_x().get_fst(),
			b.get_x().get_fst(),
			b.get_y().get_fst(),
			b.get_y().get_snd()));
		edges_of_box.push_back(left_edge);
	}
	{
		std::vector<Box> right_edge;
		right_edge.push_back(
			Box(b.get_x().get_snd(),
			b.get_x().get_snd(),
			b.get_y().get_fst(),
			b.get_y().get_snd()));
		edges_of_box.push_back(right_edge);
	}
	{
		std::vector<Box> down_edge;
		down_edge.push_back(
			Box(b.get_x().get_fst(),
			b.get_x().get_snd(),
			b.get_y().get_fst(),
			b.get_y().get_fst()));
		edges_of_box.push_back(down_edge);
	}
	{
		std::vector<Box> up_edge;
		up_edge.push_back(
			Box(b.get_x().get_fst(),
			b.get_x().get_snd(),
			b.get_y().get_snd(),
			b.get_y().get_snd()));
		edges_of_box.push_back(up_edge);
	}

	return edges_of_box;
}

std::vector<std::vector<Box> > BoxProcessor::get_covered_edges_of_box(
	const std::size_t covered_box,
	const std::vector<std::size_t>& covering_boxes,
	const std::vector<Box>& boxes) const
{
	// box's edges are in this sequence - due to method get_edges_of_box
	// -> smaller x (left),  larger x (right),  smaller y (down), larger y (up)
	// -> mensie  x (vlavo), vacsie x (vpravo), mensie  y (dole), vacsie y (hore)
	std::vector<std::vector<Box> > covered_edges;
	std::vector<std::vector<Box> > edges_of_box =
		get_edges_of_box(boxes[covered_box]);

	// for every side/edge of the box
	for (std::size_t i = 0; i < edges_of_box.size(); ++i)
	{
		// covered parts of edges
		covered_edges.push_back(std::vector<Box>());

		// for every part of side/edge of box 
		// ... in this case, there is just one part so cycle is not 
		// ... neccesserally required
		for (std::size_t j = 0; j < edges_of_box[i].size(); ++j)
		{

			// for every neighbour
			for (std::size_t k = 0; k < covering_boxes.size(); ++k)
			{
				// for every element of covering_boxes
				if (edges_of_box[i][j].has_intersection_with(boxes[covering_boxes[k]]))
				{
					// we will add parts of this side/edge covered by covering_box 
					covered_edges[i].push_back(
						edges_of_box[i][j].get_intersection_with(boxes[covering_boxes[k]]));
				}
			}
		}
	}
	return covered_edges;
}

/*
 ******************************************************************************
 ******************************** OBTAINING CORNERS ***************************
 ******************************************************************************
 */

// MUSIM!!!!! tu prerobit check, ci 2 boxy nie su spojene IBA cez corner ... 
// this method could be reworked into more general version
// -> it could have for cycles to solve corners
// -> MAYBE it could put away all unneeded parts from neighbours
std::vector<bool> BoxProcessor::select_corners(
	std::vector<std::vector<Box> >& edges) const
{
	bool
		left_lower_corner = false,
		left_upper_corner = false,
		right_lower_corner = false,
		right_upper_corner = false;

	// result will be this vector, having bool for each corner
	// ... if bool for corner is true ~ corner is unneeded
	// ... if bool for corner is false ~ corner is needed
	// ... corners are in this sequence 
	// ...  -> left lower corner, left upper corner, 
	// ...     right lower corner, right upper corner
	std::vector<bool> corners = std::vector<bool>();

	// box's edges are in this sequence - due to method get_edges_of_box
	// -> smaller x (left),  larger x (right),  smaller y (down), larger y (up)
	// -> mensie  x (vlavo), vacsie x (vpravo), mensie  y (dole), vacsie y (hore)
	std::vector<Box> left_points;
	std::vector<Box> right_points;
	std::vector<Box> lower_points;
	std::vector<Box> upper_points;

	// we will select point parts
	for (std::size_t e = 0; e < edges[0].size(); ++e)
	{
		if (edges[0][e].is_point())
			left_points.push_back(edges[0][e]);
	}
	for (std::size_t e = 0; e < edges[1].size(); ++e)
	{
		if (edges[1][e].is_point())
			right_points.push_back(edges[1][e]);
	}
	for (std::size_t e = 0; e < edges[2].size(); ++e)
	{
		if (edges[2][e].is_point())
			lower_points.push_back(edges[2][e]);
	}
	for (std::size_t e = 0; e < edges[3].size(); ++e)
	{
		if (edges[3][e].is_point())
			upper_points.push_back(edges[3][e]);
	}

	// we will check, if there is any corner twice
	for (std::size_t p = 0; p < left_points.size(); ++p)
	{
		for (std::size_t s = 0; s < lower_points.size(); ++s)
		{
			if (left_points[p] == lower_points[s]) 
				left_lower_corner = true;
		}
	}
	for (std::size_t p = 0; p < left_points.size(); ++p)
	{
		for (std::size_t s = 0; s < upper_points.size(); ++s)
		{
			if (left_points[p] == upper_points[s])
				left_upper_corner = true;
		}
	}
	for (std::size_t p = 0; p < right_points.size(); ++p)
	{
		for (std::size_t s = 0; s < lower_points.size(); ++s)
		{
			if (right_points[p] == lower_points[s])
				right_lower_corner = true;
		}
	}
	for (std::size_t p = 0; p < right_points.size(); ++p)
	{
		for (std::size_t s = 0; s < upper_points.size(); ++s)
		{
			if (right_points[p] == upper_points[s])
				right_upper_corner = true;
		}
	}

	// we will insert results
	corners.push_back(left_lower_corner);
	corners.push_back(left_upper_corner);
	corners.push_back(right_lower_corner);
	corners.push_back(right_upper_corner);
	return corners;
}

/*
 ******************************************************************************
 ***************************** OBTAINING NEIGHBOURHOODS ***********************
 ******************************************************************************
 */

std::vector<std::vector<std::size_t> > BoxProcessor::get_neighbourhoods(
	const std::vector<Box>& boxes) const
{
	std::vector<std::vector<std::size_t> > neighbourhoods;
	for (std::size_t i = 0; i < boxes.size(); ++i)
	{
		std::vector<std::size_t> neigh_for_i;
		for (std::size_t j = 0; j < boxes.size(); ++j)
		{
			if (i != j && 
				boxes[i].has_intersection_with(boxes[j]))
			{
				neigh_for_i.push_back(j);
			}
		}
		neighbourhoods.emplace_back(neigh_for_i);
	}
	return neighbourhoods;
}

/*
 ******************************************************************************
 ***************************** NEIGHBOURHOOD PROCESSING ***********************
 ******************************************************************************
 */

// this method could be reworked into more general version
// -> it could have for cycles to solve corners
void BoxProcessor::delete_unneeded_corners_in_neighbours(
	std::vector<std::vector<std::size_t> >& neighbourhoods,
	const std::vector<Box>& boxes) const
{
	// for every box in boxes 
	for (std::size_t b = 0; b < neighbourhoods.size(); ++b)
	{
		// we will get covered edges
		std::vector<std::vector<Box> > covered_edges_of_box =
			get_covered_edges_of_box(b, neighbourhoods[b], boxes);

		// we will get unneeded corners from covered edges
		// ... if bool for corner is true ~ corner is unneeded
		// ... if bool for corner is false ~ corner is needed
		// ... corners are in this sequence 
		// ...  -> left lower corner, left upper corner, 
		// ...     right lower corner, right upper corner
		std::vector<bool> which_corners =
			select_corners(covered_edges_of_box);

		// left lower corner exists, 
		// ... so we need to delete it or repair it to not be there twice
		if (which_corners[0])
		{
			Box left_lower_corner(
				boxes[b].get_x().get_fst(),
				boxes[b].get_x().get_fst(),
				boxes[b].get_y().get_fst(),
				boxes[b].get_y().get_fst());

			// we will get known, if corner is needed or not
			bool needed = true;
			for (std::size_t n = 0; n < neighbourhoods[b].size(); ++n)
			{
				if (boxes[neighbourhoods[b][n]].has_intersection_with(left_lower_corner))
				{
					if (boxes[neighbourhoods[b][n]].get_intersection_with(
						boxes[b]).is_line())
						needed = false;
				}
			}

			// we will delete all occurences of this corner if not needed
			if (!needed)
			for (std::size_t n = 0; n < neighbourhoods[b].size(); ++n)
			{
				if ((boxes[b].get_intersection_with(
					boxes[neighbourhoods[b][n]]))
					== left_lower_corner)
				{
					neighbourhoods[b].erase(neighbourhoods[b].begin() + n);
					--n;
				}
			}
		}

		// left upper corner exists,
		// ... so we need to delete it or repair it to not be there twice
		if (which_corners[1])
		{
			Box left_upper_corner(
				boxes[b].get_x().get_fst(),
				boxes[b].get_x().get_fst(),
				boxes[b].get_y().get_snd(),
				boxes[b].get_y().get_snd());

			// we will get known, if corner is needed or not
			bool needed = true;
			for (std::size_t n = 0; n < neighbourhoods[b].size(); ++n)
			{
				if (boxes[neighbourhoods[b][n]].has_intersection_with(left_upper_corner))
				{
					if (boxes[neighbourhoods[b][n]].get_intersection_with(
						boxes[b]).is_line())
						needed = false;
				}
			}

			// we will delete all occurences of this corner
			if (!needed)
			for (std::size_t n = 0; n < neighbourhoods[b].size(); ++n)
			{
				if ((boxes[b].get_intersection_with(
					boxes[neighbourhoods[b][n]]))
					== left_upper_corner)
				{
					neighbourhoods[b].erase(neighbourhoods[b].begin() + n);
					--n;
				}
			}
		}

		// right lower corner exists,
		// ... so we need to delete it or repair it to not be there twice
		if (which_corners[2])
		{
			Box right_lower_corner(
				boxes[b].get_x().get_snd(),
				boxes[b].get_x().get_snd(),
				boxes[b].get_y().get_fst(),
				boxes[b].get_y().get_fst());

			// we will get known, if corner is needed or not
			bool needed = true;
			for (std::size_t n = 0; n < neighbourhoods[b].size(); ++n)
			{
				if (boxes[neighbourhoods[b][n]].has_intersection_with(right_lower_corner))
				{
					if (boxes[neighbourhoods[b][n]].get_intersection_with(
						boxes[b]).is_line())
						needed = false;
				}
			}

			// we will delete all occurences of this corner
			if (!needed)
			for (std::size_t n = 0; n < neighbourhoods[b].size(); ++n)
			{
				if ((boxes[b].get_intersection_with(
					boxes[neighbourhoods[b][n]]))
					== right_lower_corner)
				{
					neighbourhoods[b].erase(neighbourhoods[b].begin() + n);
					--n;
				}
			}
		}

		// right upper corner exists,
		// ... so we need to delete it or repair it to not be there twice
		if (which_corners[3])
		{
			Box right_upper_corner(
				boxes[b].get_x().get_snd(),
				boxes[b].get_x().get_snd(),
				boxes[b].get_y().get_snd(),
				boxes[b].get_y().get_snd());

			// we will get known, if corner is needed or not
			bool needed = true;
			for (std::size_t n = 0; n < neighbourhoods[b].size(); ++n)
			{
				if (boxes[neighbourhoods[b][n]].has_intersection_with(right_upper_corner))
				{
					if (boxes[neighbourhoods[b][n]].get_intersection_with(
						boxes[b]).is_line())
						needed = false;
				}
			}

			// we will delete all occurences of this corner
			if (!needed)
			for (std::size_t n = 0; n < neighbourhoods[b].size(); ++n)
			{
				if ((boxes[b].get_intersection_with(
					boxes[neighbourhoods[b][n]]))
					== right_upper_corner)
				{
					neighbourhoods[b].erase(neighbourhoods[b].begin() + n);
					--n;
				}
			}
		}
	}
}
