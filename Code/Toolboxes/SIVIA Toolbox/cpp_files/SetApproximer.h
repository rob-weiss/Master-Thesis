// TO DO! opravit, ak je vstup pre casteljau ci spline pod rozlisovacie schopnosti!!!
// TO DO! urobit nastavovanie delta_x_box_level, delta_y_box_level z visualiseru!!!
// TO DO! rozdelit metody KUA lepsie na protected a public
// TO DO! ten winding number robi nejake kraviny 
//        ... bud vracia 0 ked by nemal, alebo vravia 1 ked by nemal
// TO DO! pozri polygony ... pre ciaru tam vracia spustu polygonov, ktore su tvorene 
//        ... 1 bodom!!!
// TO DO! odstranit veci, ktore nepotrebujem!!!

#ifndef _SETAPPROXIMER_HPP
#define _SETAPPROXIMER_HPP

#include <algorithm>
#include <string>
#include <utility>
#include <vector>

#include "Border.h"
#include "BoxProcessor.h"
#include "Comparers.h"
#include "DataSet.h"
#include "DataType.h"
#include "Line.h"
#include "Math.h"
#include "Point.h"
#include "PBRegion.h"
#include "WrongDataException.h"

typedef std::pair<Point, Point> graph_edge;

typedef std::pair<std::pair<Point, Point>, std::pair<BoxKind, BoxKind> > graph_edge_bk;

class SetApproximer
{

/*
 ******************************************************************************
 ************************************ RAW DATA ********************************
 ******************************************************************************
 */
protected:
	double delta_x_box_level = 0.001;
	double delta_y_box_level = 0.001;

/*
 ******************************************************************************
 ************************************ BOX INFO ********************************
 ******************************************************************************
 */

protected:
	bool is_weaker_boxkind(
		const BoxKind weaker, 
		const BoxKind stronger) const;

	bool is_stronger_boxkind(
		const BoxKind stronger,
		const BoxKind weaker) const;

	bool is_equally_strong_boxkind(
		const BoxKind bk1,
		const BoxKind bk2) const;

	bool are_boxkinds_uncomparable(
		const BoxKind bk1,
		const BoxKind bk2) const;

	BoxKind suggest_boxkind(
		const std::set<BoxKind>& bks,
		const bool edge_is_weak) const;

/*
 ******************************************************************************
 ********************************* POINT COUNTS *******************************
 ******************************************************************************
 */

protected:
	std::size_t suggest_number_of_points(
		const Point& p1,
		const Point& p2,
		const double max_x_size,
		const double max_y_size) const;

	std::size_t suggest_number_of_points(
		const Line& points,
		const double max_x_size,
		const double max_y_size) const;

/*
 ******************************************************************************
 ********************************** POINT MOVES *******************************
 ******************************************************************************
 */

public:
	Line get_points_closer(
		const Line& line,
		const std::size_t count_of_included,
		const std::size_t degree,
		const bool circle_appr_allowed = true) const;

	std::vector<Line> get_points_closer(
		const std::vector<Line>& lines,
		const std::size_t count_of_included,
		const std::size_t degree,
		const bool circle_appr_allowed = true) const;

	std::vector<Line> get_points_closer_adv(
		const std::vector<Line>& lines,
		const std::vector<Line>& other_constraint_lines,
		const std::size_t count_of_included,
		const std::size_t degree) const;

/*
 ******************************************************************************
 ************************************* LINES **********************************
 ******************************************************************************
 */

public:
	Line add_mids_to_line(const Line& line) const;

	Line get_long_line(
		const Line& line,
		const double max_x_size,
		const double max_y_size) const;

	std::vector<Line> get_long_line(
		const std::vector<Line>& lines,
		const double max_x_size,
		const double max_y_size) const;

/*
 ******************************************************************************
 ****************************** CASTELJAU's ALGORITHM *************************
 ******************************************************************************
 */

public:
	Line get_casteljau(
		const Line& line,
		const double max_x_size,
		const double max_y_size) const;

	std::vector<Line> get_casteljau(
		const std::vector<Line>& lines,
		const double max_x_size,
		const double max_y_size) const;

/*
 ******************************************************************************
 ************************************ SPLINES *********************************
 ******************************************************************************
 */

protected:
	std::pair<Point, Point> find_control_points(
		const Point& s1,
		const Point& s2,
		const Point& s3) const;

public:
	void add_spline_points_to_line(
		const Point& lp_1,
		const Point& lp_2,
		const Point& lp_3,
		const Point& lp_4,
		const std::size_t number_of_points,
		Line& line,
		const bool add_last) const;

	Line get_spline(
		const Line& line,
		const double max_x_size,
		const double max_y_size) const;

	std::vector<Line> get_spline(
		const std::vector<Line>& lines,
		const double max_x_size,
		const double max_y_size) const;

/*
 ******************************************************************************
 ********************************** SUBDIVISION *******************************
 ******************************************************************************
 */

protected:
	std::size_t get_subdivision_depth(
		const Line& line,
		const std::size_t expected_points_count,
		const bool use_lower_estimation = true) const;

public:
	Line get_subdivision(
		const Line& line,
		std::size_t depth,
		const double alpha = 0.3333,
		const bool circle_appr_allowed = true) const;

	Line get_subdivision(
		const Line& line,
		const double max_x_size,
		const double max_y_size,
		const double alpha = 0.3333,
		const bool circle_appr_allowed = true,
		const bool use_lower_estimation = true) const;

	std::vector<Line> get_subdivision(
		const std::vector<Line>& lines,
		const std::size_t depth,
		const double alpha = 0.3333,
		const bool circle_appr_allowed = true) const;

	std::vector<Line> get_subdivision(
		const std::vector<Line>& line,
		const double max_x_size,
		const double max_y_size,
		const double alpha = 0.3333,
		const bool circle_appr_allowed = true,
		const bool use_lower_estimation = true) const;

	std::vector<Line> get_subdivision(
		const std::vector<Line>& lines,
		const std::vector<Line>& other_constraint_lines,
		const std::size_t depth,
		const double alpha = 0.3333) const;

	std::vector<Line> get_subdivision(
		const std::vector<Line>& lines,
		const std::vector<Line>& other_constraint_lines,
		const double max_x_size,
		const double max_y_size,
		const double alpha = 0.3333,
		const bool use_lower_estimation = true) const;

/*
 ******************************************************************************
 *************************** REWORKING LINES TO BORDERS ***********************
 ******************************************************************************
 */

public:
	BoxKind assign_boxkind(
		const Point& fst_p,
		const Point& snd_p,
		const std::vector<Border>& borders,
		const double maximum_distance,
		const bool reverse) const;

	BoxKind assign_boxkind(
		const std::pair<Point, Point>& perpendicular,
		const std::vector<Line>& inner_lines,
		const std::size_t which_inner_line,
		const std::size_t which_starting_point,
		const BoxKind& representing_bk,
		const std::vector<Border>& outer_borders,
		const std::vector<Border>& domain_edge_borders,
		const double max_allowed_distance) const;

	std::vector<Border> rework_to_borders(
		const std::vector<Line>& inner_lines,
		const std::size_t current_line,
		const BoxKind& representing_bk,
		const std::vector<Border>& outer_borders,
		const std::vector<Border>& domain_edge_borders,
		const Box& domain) const;

	std::vector<Border> rework_to_borders(
		const std::vector<Line>& inner_lines,
		const BoxKind& representing_bk,
		const std::vector<Border>& outer_borders,
		const std::vector<Border>& domain_edge_borders,
		const Box& domain) const;

/*
 ******************************************************************************
 ****************************** WORKING WITH BORDERS **************************
 ******************************************************************************
 */

public:
	BoxKind suggest_boxkind(
		const Point& point,
		const Border& border,
		double& min_distance) const;

	BoxKind suggest_boxkind(
		const Point& point,
		const Border& border) const;

	BoxKind suggest_boxkind(
		const Point& point,
		const std::vector<Border>& borders) const;

/*
 ******************************************************************************
 *************************** REWORKING LINES TO POLYGONS **********************
 ******************************************************************************
 */

protected:
	void add_intersections_to(
		Line& fst_l,
		Line& snd_l) const;

public:
	void add_intersections_to(
		std::vector<Line>& lines) const;

	void add_intersections_to(
		std::vector<Border>& borders) const;

	std::vector<Line> split_polygons(
		const std::vector<Line>& polygons) const;

	bool edge_was_walked(
		const graph_edge& edge,
		const std::vector<graph_edge>& walked_edges) const;

	int get_index_of_element(
		const Point& p,
		const std::vector<Point>& points) const;

	bool walk_edge(
		Point v_curr,
		Point v_next,
		std::vector<Point>& polygon,
		std::vector<graph_edge>& walked_edges,
		const std::map<Point, std::vector<Point>, PointComparer>& points) const;

	std::vector<Line> build_polygons(
		const std::map<Point, std::vector<Point>, PointComparer>& points) const;

	std::vector<Line> get_polygons(
		const std::vector<Line>& lines) const;

	// only for fst boxkind!
	std::vector<Border> get_polygons(
		const std::vector<Border>& borders) const;

/*
 ******************************************************************************
 ************************** REWORKING BORDERS TO REGIONS **********************
 ******************************************************************************
 */

public:
	bool polygons_are_same(
		const Line& fst,
		const Line& snd) const;

	bool polygons_cover_same_place(
		const Line& fst,
		const Line& snd) const;

	bool polygon_is_inner_boundary(
		const Line& which) const;

	bool polygon_is_outer_boundary(
		const Line& which) const;

	bool polygon_belongs_to_polygon(
		const Line& which,
		const Line& owner) const;

	std::vector<PBRegion> rework_to_regions(
		const std::vector<Border>& borders) const;

};

#endif