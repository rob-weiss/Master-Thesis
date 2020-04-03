#include "SetApproximer.h"

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

/*
 ******************************************************************************
 ************************************ BOX INFO ********************************
 ******************************************************************************
 */

/*! \brief Checks if weaker is truly weaker boxkind than stronger.
 *
 */
bool SetApproximer::is_weaker_boxkind(
	const BoxKind weaker, 
	const BoxKind stronger) const
{
	if (weaker == BoxKind::UNDEFINED &&
		stronger != BoxKind::UNDEFINED)
		return true;

	if (weaker == BoxKind::UNKNOWN_BOX &&
		(stronger == BoxKind::FALSE_BOX ||
		 stronger == BoxKind::TRUE_BOX))
		return true;

	return false;
}

/*! \brief Checks if stronger is truly stronger boxkind than weaker.
 *
 */
bool SetApproximer::is_stronger_boxkind(
	const BoxKind stronger, 
	const BoxKind weaker) const
{
	return is_weaker_boxkind(weaker, stronger);
}

/*! \brief Checks boxkinds are equally strong.
 *
 */
bool SetApproximer::is_equally_strong_boxkind(
	const BoxKind bk1,
	const BoxKind bk2) const
{
	if (bk1 == bk2)
		return true;
	if ((bk1 == BoxKind::FALSE_BOX && bk2 == BoxKind::TRUE_BOX) ||
		(bk1 == BoxKind::TRUE_BOX && bk2 == BoxKind::FALSE_BOX))
		return true;
	return false;
}

/*! \brief Checks boxkinds are uncomparable in strength.
 *
 */
bool SetApproximer::are_boxkinds_uncomparable(
	const BoxKind bk1,
	const BoxKind bk2) const
{
	if (bk1 != bk2 && (bk1 == BoxKind::EDGE_BOX || bk2 == BoxKind::EDGE_BOX))
		return true;
	return false;
}

/*! \brief Suggests dominant BoxKind in set. If set is empty or cannot be 
 *  decided, then BoxKind::UNDEFINED will be returned.
 *
 */
BoxKind SetApproximer::suggest_boxkind(
	const std::set<BoxKind>& bks,
	const bool edge_is_weak) const
{
	if (bks.empty())
		return BoxKind::UNDEFINED;

	BoxKind selected = *(bks.begin());
	for (auto& bk : bks)
	{
		// we are fine with this option
		if (bk == selected || is_weaker_boxkind(bk, selected))
		{
			continue;
		}
		else
		// we need to update selected to the stronger
		if (is_weaker_boxkind(selected, bk))
		{
			selected = bk;
		}
		else
		// we will take care of edge boxes
		if (edge_is_weak && (bk == BoxKind::EDGE_BOX || selected == BoxKind::EDGE_BOX))
		{
			if (bk == BoxKind::EDGE_BOX && selected == BoxKind::UNDEFINED)
			{
				selected = bk;
				continue;
			}

			if (selected == BoxKind::EDGE_BOX && bk != BoxKind::UNDEFINED)
			{
				selected = bk;
				continue;
			}
		}
		// one of bad options for us
		else
		{
			return BoxKind::UNDEFINED;
		}
	}

	return selected;
}

/*
 ******************************************************************************
 ********************************* POINT COUNTS *******************************
 ******************************************************************************
 */

/*! \brief Suggests number of points needed between p1 and p2 for smooth 
 *  approximation.
 *
 */
std::size_t SetApproximer::suggest_number_of_points(
	const Point& p1,
	const Point& p2,
	const double max_x_size,
	const double max_y_size) const
{
	if (max_x_size == 0 && max_y_size == 0)
	{
		throw new WrongDataException("Wrong size of picture");
		return 0;
	}

	const double suggested_size =
		std::sqrt(max_x_size*max_x_size + max_y_size*max_y_size);
	const double distance_of_cur_points =
		GetPointsEuclideanDistance(p1, p2);
	return (std::size_t)(1.0 + distance_of_cur_points / suggested_size);
}

/*! \brief Suggests number of points needed between points for smooth 
 *  approximation.
 *
 */
std::size_t SetApproximer::suggest_number_of_points(
	const Line& points,
	const double max_x_size,
	const double max_y_size) const
{
	std::size_t number_of_points = 0;
	for (std::size_t i = 0; i < points.size() - 1; ++i)
	{
		number_of_points +=
			suggest_number_of_points(
				points[i],
				points[i + 1],
				max_x_size,
				max_y_size);
	}
	return number_of_points;
}

/*
 ******************************************************************************
 ********************************** POINT MOVES *******************************
 ******************************************************************************
 */


/*! \brief Takes points as line/curve and recursively move them closer to each
 *  other. 
 * 
 */
Line SetApproximer::get_points_closer(
	const Line& line,
	const std::size_t count_of_included,
	const std::size_t degree,
	const bool circle_appr_allowed) const
{
	// end of recursion
	if (count_of_included < 1 || degree < 1)	
		return line;

	Line reworked_line;

	// circle
	if (line[0] == line[line.size() - 1] && circle_appr_allowed)	
	{
		const int current_count_of_included =
			std::min(count_of_included, line.size());

		for (std::size_t point = 0; point < line.size(); ++point)
		{
			double sum_x = line[point % (line.size() - 1)].get_x();
			double sum_y = line[point % (line.size() - 1)].get_y();
			sum_x += line[point % (line.size() - 1)].get_x();
			sum_y += line[point % (line.size() - 1)].get_y();
			for (std::size_t i = 1; i <= (std::size_t)current_count_of_included; ++i)
			{
				sum_x += line[(point + i + line.size()) % (line.size() - 1)].get_x();
				sum_x += line[(point - i + line.size()) % (line.size() - 1)].get_x();
				sum_y += line[(point + i + line.size()) % (line.size() - 1)].get_y();
				sum_y += line[(point - i + line.size()) % (line.size() - 1)].get_y();
			}
			sum_x /= double(2 * (current_count_of_included + 1));
			sum_y /= double(2 * (current_count_of_included + 1));
			reworked_line.emplace_back(sum_x, sum_y);
		}
	}
	// not circle
	else	
	{
		reworked_line.push_back(line[0]);
		for (std::size_t point = 1; point < line.size() - 1; ++point)
		{
			const int lower_possible_elements = 
				(int)point - 1;
			const int upper_possible_elements = 
				((int)line.size() - 1) - ((int)point + 1);
			const int possible_elements = std::min(
				lower_possible_elements, 
				upper_possible_elements);
			const int current_count_of_included =
				std::max(
					std::min(possible_elements, (int)count_of_included),
					0);

			if (current_count_of_included > 0)
			{
				double sum_x = line[point].get_x();
				double sum_y = line[point].get_y();
				sum_x += line[point].get_x();
				sum_y += line[point].get_y();
				for (std::size_t i = 1; i <= (std::size_t)current_count_of_included; ++i)
				{
					sum_x += line[point + i].get_x();
					sum_x += line[point - i].get_x();
					sum_y += line[point + i].get_y();
					sum_y += line[point - i].get_y();
				}
				sum_x /= double(2 * (current_count_of_included + 1));
				sum_y /= double(2 * (current_count_of_included + 1));
				reworked_line.emplace_back(sum_x, sum_y);
			}
			else
			{
				reworked_line.push_back(line[point]);
			}
		}
		reworked_line.push_back(line[line.size() - 1]);
	}

	return get_points_closer(reworked_line, count_of_included, degree - 1);
}

/*! \brief Takes points as line/curve and recursively move them closer to each
 *  other. 
 * 
 */
std::vector<Line> SetApproximer::get_points_closer(
	const std::vector<Line>& lines,
	const std::size_t count_of_included,
	const std::size_t degree,
	const bool circle_appr_allowed) const
{
	std::vector<Line> result;

	for (auto& l : lines)
	{
		result.push_back(
			get_points_closer(l, count_of_included, degree,circle_appr_allowed));
	}

	return result;
}

/*! \brief Takes points as line/curve and recursively move them closer to each
 *  other. Function will allow circle approximation for curve if there is not 
 *  other curve with same startpoint / endpoint as has the current one.
 * 
 */
std::vector<Line> SetApproximer::get_points_closer_adv(
	const std::vector<Line>& lines,
	const std::vector<Line>& other_constraint_lines,
	const std::size_t count_of_included,
	const std::size_t degree) const
{
	std::vector<Line> result;

	for (std::size_t i = 0; i < lines.size(); ++i)
	{
		bool cal = true;

		for (std::size_t j = 0; j < lines.size() && cal; ++j)
		{
			if (j == i)
				continue;

			if (lines[j][0] == lines[i][0] ||
				lines[j][0] == lines[i][lines[i].size() - 1] ||
				lines[j][lines[j].size() - 1] == lines[i][0] ||
				lines[j][lines[j].size() - 1] == lines[i][lines[i].size() - 1])
			{
				cal = false;
			}
		}

		for (auto& ocl : other_constraint_lines)
		{
			if (!cal)
				break;

			if (ocl[0] == lines[i][0] ||
				ocl[0] == lines[i][lines[i].size() - 1] ||
				ocl[ocl.size() - 1] == lines[i][0] ||
				ocl[ocl.size() - 1] == lines[i][lines[i].size() - 1])
			{
				cal = false;
			}
		}

		result.push_back(
			get_points_closer(lines[i], count_of_included, degree, cal));
	}

	return result;
}

/*
 ******************************************************************************
 ************************************* LINES **********************************
 ******************************************************************************
 */

/*! \brief Adds mid between each two points in vector.
 *
 */
Line SetApproximer::add_mids_to_line(const Line& line) const
{
	if (line.size() < 2)
		return line;

	Line reworked_line;
	reworked_line.reserve(line.size() * 2);
	for (std::size_t i = 0; i < line.size() - 1; ++i)
	{
		reworked_line.push_back(line[i]);
		reworked_line.emplace_back(GetPointBetween(line[i], line[i + 1]));
	}
	reworked_line.push_back(line[line.size() - 1]);

	return reworked_line;
}

Line SetApproximer::get_long_line(
	const Line& line,
	const double max_x_size,
	const double max_y_size) const
{
	// no need for adjusting line by any way
	return line;
}

/*! \brief Returns long lines approximation.
 *
 */
std::vector<Line> SetApproximer::get_long_line(
	const std::vector<Line>& lines,
	const double max_x_size,
	const double max_y_size) const
{
	// no need for adjusting lines by any way
	return lines;
}

/*
 ******************************************************************************
 ****************************** CASTELJAU's ALGORITHM *************************
 ******************************************************************************
 */

/*! \brief Returns Bezier's curve throught all points of line constructed 
 *  with De Casteljau's algorithm.
 *
 */
Line SetApproximer::get_casteljau(
	const Line& line,
	const double max_x_size,
	const double max_y_size) const
{
	if (line.size() <= 2)
		return line;

	std::size_t number_of_points =
		suggest_number_of_points(line, max_x_size, max_y_size);
	double subdiv_step = 1.0 / number_of_points;

	Line result;
	Line cpv(line);

	// current_parameter t
	double curp = 0.0; 

	while (curp < 1)
	{
		// set initial state for this point
		for (std::size_t i = 0; i < line.size(); ++i)
		{
			cpv[i].set_x() = line[i].get_x();
			cpv[i].set_y() = line[i].get_y();
		}

		for (int i = line.size() - 1; i >= 0; --i)
		{
			for (std::size_t curpoint = 0; (int)curpoint < i; ++curpoint)
			{
				cpv[curpoint].set_x() =
					(1 - curp) * cpv[curpoint].get_x() +
					(curp)* cpv[curpoint + 1].get_x();
				cpv[curpoint].set_y() =
					(1 - curp) * cpv[curpoint].get_y() +
					(curp)* cpv[curpoint + 1].get_y();
			}
		}

		// we have computed computed result for current parameter t
		result.push_back(cpv[0]);

		// we will adjust current parameter t
		curp += subdiv_step;
	}

	if (result[result.size() - 1] != line[line.size() - 1])
		result.push_back(line[line.size() - 1]);

	return result;
}

/*! \brief Returns Bezier's curve throught all points of each line constructed 
 *  with De Casteljau's algorithm.
 *
 */
std::vector<Line> SetApproximer::get_casteljau(
	const std::vector<Line>& lines,
	const double max_x_size,
	const double max_y_size) const
{
	std::vector<Line> casteljaus;
	casteljaus.reserve(lines.size());
	for (auto& l : lines)
	{
		casteljaus.push_back(
			get_casteljau(l, max_x_size, max_y_size));
	}
	return casteljaus;
}

/*
 ******************************************************************************
 ************************************ SPLINES *********************************
 ******************************************************************************
 */

//http://www.antigrain.com/research/bezier_interpolation/
//http://bseth99.github.io/projects/animate/2-bezier-curves.html
/*! \brief Returns control points.
 *
 */
std::pair<Point, Point> SetApproximer::find_control_points(
	const Point& s1,
	const Point& s2,
	const Point& s3) const
{
	double
		d1_x = s1.get_x() - s2.get_x(),
		d1_y = s1.get_y() - s2.get_y(),
		d2_x = s2.get_x() - s3.get_x(),
		d2_y = s2.get_y() - s3.get_y(),
		l1 = std::sqrt(d1_x*d1_x + d1_y*d1_y),
		l2 = std::sqrt(d2_x*d2_x + d2_y*d2_y),
		m1_x = (s1.get_x() + s2.get_x()) / 2.0,
		m1_y = (s1.get_y() + s2.get_y()) / 2.0,
		m2_x = (s2.get_x() + s3.get_x()) / 2.0,
		m2_y = (s2.get_y() + s3.get_y()) / 2.0,
		dm_x = m1_x - m2_x,
		dm_y = m1_y - m2_y,
		suml1l2 = l1 + l2,
		k = suml1l2 != 0 ? l2 / (l1 + l2) : 0,
		cm_x = m2_x + dm_x*k,
		cm_y = m2_y + dm_y*k,
		t_x = s2.get_x() - cm_x,
		t_y = s2.get_y() - cm_y;
	//Point
	//	c1(m1_x + t_x, m1_y + t_y),
	//	c2(m2_x + t_x, m2_y + t_y);
	//return
		//std::make_pair(c1, c2);
	return
		std::make_pair(
		Point(m1_x + t_x, m1_y + t_y),
		Point(m2_x + t_x, m2_y + t_y));
}

//http://www.antigrain.com/research/bezier_interpolation/
//http://bseth99.github.io/projects/animate/2-bezier-curves.html
//http://www.niksula.hut.fi/~hkankaan/Homepages/bezierfast.html
// won't add last point, non exact variant, but fast
/*! \brief Adds points of spline between lp2 and lp3.
 *
 *  If !add_last, it won't add last point. This is not exact variant, but pretty fast.
 */
void SetApproximer::add_spline_points_to_line(
	const Point& lp_1, 
	const Point& lp_2,
	const Point& lp_3,
	const Point& lp_4,
	std::size_t number_of_points,
	Line& line,
	const bool add_last) const
{
	if (number_of_points == 0)
		return;

	std::pair<Point, Point> s1 =
		find_control_points(lp_1, lp_2, lp_3);
	std::pair<Point, Point> s2 =
		find_control_points(lp_2, lp_3, lp_4);

	const Point&
		p1 = lp_2,
		p2 = s1.second,
		p3 = s2.first,
		p4 = lp_3;

	const double
		dx1 = p2.get_x() - p1.get_x(),
		dy1 = p2.get_y() - p1.get_y(),
		dx2 = p3.get_x() - p2.get_x(),
		dy2 = p3.get_y() - p2.get_y(),
		dx3 = p4.get_x() - p3.get_x(),
		dy3 = p4.get_y() - p3.get_y();

	const double 
		subdiv_step = 1.0 / number_of_points,
		subdiv_step2 = subdiv_step*subdiv_step,
		subdiv_step3 = subdiv_step*subdiv_step*subdiv_step,
		pre1 = 3.0 * subdiv_step,
		pre2 = 3.0 * subdiv_step2,
		pre4 = 6.0 * subdiv_step2,
		pre5 = 6.0 * subdiv_step3;

	double tmp1x = p1.get_x() - p2.get_x() * 2.0 + p3.get_x();
	double tmp1y = p1.get_y() - p2.get_y() * 2.0 + p3.get_y();

	double tmp2x = (-dx2)*3.0 - p1.get_x() + p4.get_x();
	double tmp2y = (-dy2)*3.0 - p1.get_y() + p4.get_y();

	double fx = p1.get_x();
	double fy = p1.get_y();

	double dfx = (dx1)*pre1 + tmp1x*pre2 + tmp2x*subdiv_step3;
	double dfy = (dy1)*pre1 + tmp1y*pre2 + tmp2y*subdiv_step3;

	double ddfx = tmp1x*pre4 + tmp2x*pre5;
	double ddfy = tmp1y*pre4 + tmp2y*pre5;

	double dddfx = tmp2x*pre5;
	double dddfy = tmp2y*pre5;

	while (--number_of_points)
	{
		line.push_back(Point(fx, fy));
		fx += dfx;
		fy += dfy;
		dfx += ddfx;
		dfy += ddfy;
		ddfx += dddfx;
		ddfy += dddfy;
	}

	if (add_last)
	{
		if (line.size() != 0)
		{
			if (line[line.size() - 1] != p4)
				line.push_back(p4);
		}
		else
		{
			line.push_back(p4);
		}
	}
}

/*! \brief Returns spline through line. Spline is consisted of small splines
 *  which are made always between each 2 consecutive points in line.
 *
 *  Method is not using cyclic start/end point enabling smoothing so far.
 */
Line SetApproximer::get_spline(
	const Line& line,
	const double max_x_size,
	const double max_y_size) const
{
	if (line.size() <= 2)
		return line;

	Line enhanced_line;
	enhanced_line.reserve(line.size() + 2);
	enhanced_line.push_back(line[0]);
	enhanced_line.insert(enhanced_line.end(), line.begin(), line.end());
	enhanced_line.push_back(line[line.size() - 1]);
	
	Line spline;
	spline.reserve(spline.size());
	for (std::size_t i = 1; i < enhanced_line.size() - 2; ++i)
	{
		std::size_t number_of_points =
			suggest_number_of_points(
				enhanced_line[i],
				enhanced_line[i + 1],
				max_x_size,
				max_y_size);
		add_spline_points_to_line(
			enhanced_line[i - 1],
			enhanced_line[i],
			enhanced_line[i + 1],
			enhanced_line[i + 2],
			number_of_points, 
			spline,
			false);
	}

	if (spline.size() < line.size())
		return line;

	if (spline[spline.size() - 1] != line[line.size() - 1])
		spline.push_back(line[line.size() - 1]);

	return spline;
}

/*! \brief Returns spline through each line. Spline is consisted of small 
 *  splines which are made always between each 2 consecutive points in line.
 *
 *  Method is not using cyclic start/end point enabling smoothing so far.
 */
std::vector<Line> SetApproximer::get_spline(
	const std::vector<Line>& lines,
	const double max_x_size,
	const double max_y_size) const
{
	std::vector<Line> splines;
	splines.reserve(lines.size());
	for (auto& l : lines)
		splines.push_back(l);
	return splines;
}

/*
******************************************************************************
********************************** SUBDIVISION *******************************
******************************************************************************
*/

/*! \brief Function will suggest depth of subdivision algorithm for line
 *  to gain result with >= expected_points_count points. 
 *  If use_lower_estimation is true, then result will have 
 *  <= expected_points_count points, if line has less points then expected.
 *
 */
std::size_t SetApproximer::get_subdivision_depth(
	const Line& line,
	const std::size_t expected_points_count,
	const bool use_lower_estimation) const
{
	const std::size_t current_points_count = line.size();
	if (current_points_count >= expected_points_count)
		return 0;

	std::size_t suggested_points_count = 2 * current_points_count;
	std::size_t depth = 1;

	while (suggested_points_count < expected_points_count)
	{
		++depth;
		suggested_points_count *= 2;
	}

	if (use_lower_estimation)
		return (depth - 1);

	return depth;
}

/*! \brief Standard subdivision algorithm with Chaikin coeficient as alpha.
 *
 */
Line SetApproximer::get_subdivision(
	const Line& line,
	std::size_t depth,
	const double alpha,
	const bool circle_appr_allowed) const
{
	if (line.size() < 2 || depth < 1)
		return line;

	Line reworked_line = line;
	Line next_gen;

	while (depth > 0)
	{
		next_gen.clear();
		--depth;

		// circle
		if (line[0] == line[line.size() - 1] && 
			line.size() > 2 && 
			circle_appr_allowed)
		{
			for (std::size_t p = 0; p < reworked_line.size(); ++p)
			{
				const std::size_t p_before = ((p + reworked_line.size()) - 1) % reworked_line.size();
				const std::size_t p_after = (p + 1) % reworked_line.size();
				const Point
					new_p_before(
					reworked_line[p].get_x() - (reworked_line[p].get_x() - reworked_line[p_before].get_x()) * alpha,
					reworked_line[p].get_y() - (reworked_line[p].get_y() - reworked_line[p_before].get_y()) * alpha),
					new_p_after(
					reworked_line[p].get_x() + (reworked_line[p_after].get_x() - reworked_line[p].get_x()) * alpha,
					reworked_line[p].get_y() + (reworked_line[p_after].get_y() - reworked_line[p].get_y()) * alpha);
				if (IsPointBetween(new_p_before, reworked_line[p_before], reworked_line[p]) &&
					IsPointBetween(new_p_after, reworked_line[p], reworked_line[p_after]))
				{
					next_gen.push_back(new_p_before);
					next_gen.push_back(new_p_after);
				}
				else
				{
					next_gen.push_back(reworked_line[p]);
				}
			}
		}
		// not circle
		else
		{
			next_gen.push_back(line[0]);
			for (std::size_t p = 1; p < reworked_line.size() - 1; ++p)
			{
				const Point
					new_p_before(
					reworked_line[p].get_x() - (reworked_line[p].get_x() - reworked_line[p - 1].get_x()) * alpha,
					reworked_line[p].get_y() - (reworked_line[p].get_y() - reworked_line[p - 1].get_y()) * alpha),
					new_p_after(
					reworked_line[p].get_x() + (reworked_line[p + 1].get_x() - reworked_line[p].get_x()) * alpha,
					reworked_line[p].get_y() + (reworked_line[p + 1].get_y() - reworked_line[p].get_y()) * alpha);
				if (IsPointBetween(new_p_before, reworked_line[p - 1], reworked_line[p]) &&
					IsPointBetween(new_p_after, reworked_line[p], reworked_line[p + 1]))
				{
					next_gen.push_back(new_p_before);
					next_gen.push_back(new_p_after);
				}
				else
				{
					next_gen.push_back(reworked_line[p]);
				}
			}
			next_gen.push_back(line[line.size() - 1]);
		}

		reworked_line = next_gen;
	}

	return reworked_line;
}

/*! \brief Standard subdivision algorithm with Chaikin coeficient as alpha.
 *
 */
Line SetApproximer::get_subdivision(
	const Line& line,
	const double max_x_size,
	const double max_y_size,
	const double alpha,
	const bool circle_appr_allowed,
	const bool use_lower_estimation) const
{
	const std::size_t epc = suggest_number_of_points(line, max_x_size, max_y_size);
	const std::size_t depth = get_subdivision_depth(line, epc, use_lower_estimation);
	return get_subdivision(
		line,
		depth,
		alpha,
		circle_appr_allowed);
}

/*! \brief Standard subdivision algorithm with Chaikin coeficient as alpha.
 *
 */
std::vector<Line> SetApproximer::get_subdivision(
	const std::vector<Line>& lines,
	const std::size_t depth,
	const double alpha,
	const bool circle_appr_allowed) const
{
	std::vector<Line> result;

	for (auto& l : lines)
	{
		result.push_back(
			get_subdivision(l, depth, alpha, circle_appr_allowed));
	}

	return result;
}

/*! \brief Standard subdivision algorithm with Chaikin coeficient as alpha.
 *
 */
std::vector<Line> SetApproximer::get_subdivision(
	const std::vector<Line>& lines,
	const double max_x_size,
	const double max_y_size,
	const double alpha,
	const bool circle_appr_allowed,
	const bool use_lower_estimation) const
{
	std::vector<Line> result;

	for (auto& l : lines)
	{
		result.push_back(
			get_subdivision(
				l, 
				max_x_size, 
				max_y_size, 
				alpha, 
				circle_appr_allowed,
				use_lower_estimation));
	}

	return result;
}

/*! \brief Standard subdivision algorithm with Chaikin coeficient as alpha
 *  Function will allow circle approximation for curve if there is not
 *  other curve with same startpoint / endpoint as has the current one.
 *
 */
std::vector<Line> SetApproximer::get_subdivision(
	const std::vector<Line>& lines,
	const std::vector<Line>& other_constraint_lines,
	const std::size_t depth,
	const double alpha) const
{
	std::vector<Line> result;

	for (std::size_t i = 0; i < lines.size(); ++i)
	{
		bool cal = true;

		for (std::size_t j = 0; j < lines.size() && cal; ++j)
		{
			if (j == i)
				continue;

			if (lines[j][0] == lines[i][0] ||
				lines[j][0] == lines[i][lines[i].size() - 1] ||
				lines[j][lines[j].size() - 1] == lines[i][0] ||
				lines[j][lines[j].size() - 1] == lines[i][lines[i].size() - 1])
			{
				cal = false;
			}
		}

		for (auto& ocl : other_constraint_lines)
		{
			if (!cal)
				break;

			if (ocl[0] == lines[i][0] ||
				ocl[0] == lines[i][lines[i].size() - 1] ||
				ocl[ocl.size() - 1] == lines[i][0] ||
				ocl[ocl.size() - 1] == lines[i][lines[i].size() - 1])
			{
				cal = false;
			}
		}

		result.push_back(
			get_subdivision(lines[i], depth, alpha, cal));
	}

	return result;
}

/*! \brief Standard subdivision algorithm with Chaikin coeficient as alpha
 *  Function will allow circle approximation for curve if there is not
 *  other curve with same startpoint / endpoint as has the current one.
 *
 */
std::vector<Line> SetApproximer::get_subdivision(
	const std::vector<Line>& lines,
	const std::vector<Line>& other_constraint_lines,
	const double max_x_size,
	const double max_y_size,
	const double alpha,
	const bool use_lower_estimation) const
{
	std::vector<Line> result;

	for (std::size_t i = 0; i < lines.size(); ++i)
	{
		bool cal = true;

		for (std::size_t j = 0; j < lines.size() && cal; ++j)
		{
			if (j == i)
				continue;

			if (lines[j][0] == lines[i][0] ||
				lines[j][0] == lines[i][lines[i].size() - 1] ||
				lines[j][lines[j].size() - 1] == lines[i][0] ||
				lines[j][lines[j].size() - 1] == lines[i][lines[i].size() - 1])
			{
				cal = false;
			}
		}

		for (auto& ocl : other_constraint_lines)
		{
			if (!cal)
				break;

			if (ocl[0] == lines[i][0] ||
				ocl[0] == lines[i][lines[i].size() - 1] ||
				ocl[ocl.size() - 1] == lines[i][0] ||
				ocl[ocl.size() - 1] == lines[i][lines[i].size() - 1])
			{
				cal = false;
			}
		}

		result.push_back(
			get_subdivision(
				lines[i], 
				max_x_size, 
				max_y_size, 
				alpha, 
				cal,
				use_lower_estimation));
	}

	return result;
}

/*
 ******************************************************************************
 *************************** REWORKING LINES TO BORDERS ***********************
 ******************************************************************************
 */

// i could suggest boxkind also reverse then to the second point
/*! \brief Assigns BoxKind to the point in the direction of snd due to borders.
 *
 */
BoxKind SetApproximer::assign_boxkind(
	const Point& fst_p,
	const Point& snd_p,
	const std::vector<Border>& borders,
	const double maximum_allowed_distance,
	const bool reverse) const
{
	std::vector<Point> intersections;
	std::vector<std::size_t> which_border_intersects;
	std::vector<std::size_t> which_border_part_intersects;
	Point intersection;

	// for every outer_border
	for (std::size_t ob = 0; ob < borders.size(); ++ob)
	{
		const Line& ob_path = borders[ob].get_path();

		// for each segment starting point of ob
		for (std::size_t sp_ob = 0; sp_ob < ob_path.size() - 1; ++sp_ob)
		{
			// we will add intersection if there is any
			if (DoLinesHaveIntersection(
				fst_p, snd_p,
				ob_path[sp_ob], ob_path[sp_ob + 1],
				intersection,
				true,
				delta_x_box_level,
				delta_y_box_level))
			{
				intersections.push_back(intersection);
				which_border_intersects.push_back(ob);
				which_border_part_intersects.push_back(sp_ob);
			}
		}
	}

	if (intersections.size() == 0)
		return BoxKind::UNDEFINED;

	// we will sort intersections due to distance from mid
	std::vector<std::pair<double, std::size_t> > distances_for_ob_intersections;
	for (std::size_t i = 0; i < intersections.size(); ++i)
	{
		distances_for_ob_intersections.push_back(
			std::make_pair(
				GetPointsEuclideanDistance(fst_p, intersections[i]),
				i));
	}
	std::sort(
		distances_for_ob_intersections.begin(), 
		distances_for_ob_intersections.end());

	if (distances_for_ob_intersections[0].first > maximum_allowed_distance)
		return BoxKind::UNDEFINED;
	
	// we will cut BoxKind just for purpose of suggesting boxkind for fst_p
	const std::size_t selected_intersection = distances_for_ob_intersections[0].second;

	// we will get Border which was closest
	Line selected_line;
	selected_line.push_back(
		borders[which_border_intersects[selected_intersection]].get_path()
			   [which_border_part_intersects[selected_intersection]]);
	selected_line.push_back(
		borders[which_border_intersects[selected_intersection]].get_path()
			   [which_border_part_intersects[selected_intersection] + 1]);
	const Border selected_part(
		selected_line,
		borders[which_border_intersects[selected_intersection]].get_fst(),
		borders[which_border_intersects[selected_intersection]].get_snd());
	
	BoxKind suggested = suggest_boxkind(fst_p, selected_part);
	BoxKind reversed;

	// we will check, if result is not too close to decide right boxkind 
	// ... for the original point
	const bool too_close_to_fst_point =
		distances_for_ob_intersections[0].first <= std::max(delta_x_box_level, delta_y_box_level);
	// if it is too close, then we will take boxkind for the snd_p
	if (too_close_to_fst_point)
	{
		//BoxKind suggested_for_the_snd_p = selected_part.suggest_boxkind(snd_p);
		//return suggested_for_the_snd_p;
		if (IsOnTheRight(selected_part.get_path()[0], selected_part.get_path()[1], snd_p))
			return selected_part.get_fst();
		else
		if (IsOnTheLeft(selected_part.get_path()[0], selected_part.get_path()[1], snd_p))
			return selected_part.get_snd();
		else
			return BoxKind::UNDEFINED;
	}

	if (!reverse)
	{
		return suggested;
	}

	if (suggested == selected_part.get_fst())
	{
		reversed = selected_part.get_snd();
		return reversed;
	}
	else
	if (suggested == selected_part.get_snd())
	{
		reversed = selected_part.get_fst();
		return reversed;
	}

	return BoxKind::UNDEFINED;
}

/*! \brief Assigns BoxKind to the first point of perpendicular 
 *  in the direction of the second of perpendicular.
 *
 */
BoxKind SetApproximer::assign_boxkind(
	const std::pair<Point, Point>& perpendicular,
	const std::vector<Line>& inner_lines,
	const std::size_t which_inner_line,
	const std::size_t which_starting_point,
	const BoxKind& representing_bk,
	const std::vector<Border>& outer_borders,
	const std::vector<Border>& domain_edge_borders,
	const double max_allowed_distance) const
{
	// we will reset distance to inner line for fst_pil
	double distance_to_inner_line = max_allowed_distance;
	double dist = 0;
	Point intersection(0,0);
	BoxKind suggested_boxkind = BoxKind::UNDEFINED;

	// we will get minimum distance due to other inner_lines
	for (std::size_t ils = 0; ils < inner_lines.size(); ++ils)
	{
		for (std::size_t sp_ils = 0; sp_ils < inner_lines[ils].size() - 1; ++sp_ils)
		{
			if (ils == which_inner_line && sp_ils == which_starting_point)
			{
				continue;
			}

			if (DoLinesHaveIntersection(
				inner_lines[ils][sp_ils], inner_lines[ils][sp_ils + 1],
				perpendicular.first, perpendicular.second,
				intersection,
				true,
				delta_x_box_level,
				delta_y_box_level) &&
				!(intersection == perpendicular.first && ils == which_inner_line))
			{
				dist =
					GetPointsEuclideanDistance(intersection, perpendicular.first);
				if (distance_to_inner_line > dist)
					distance_to_inner_line = dist;
			}
		}
	}

	// we will try to find closest amongst outer_borders
	suggested_boxkind =
		assign_boxkind(
			perpendicular.first,
			perpendicular.second,
			outer_borders,
			distance_to_inner_line,
			true);

	if (suggested_boxkind == BoxKind::UNDEFINED)
	{
		// we will try to find closest amongst edge_borders
		suggested_boxkind =
			assign_boxkind(
				perpendicular.first,
				perpendicular.second,
				domain_edge_borders,
				distance_to_inner_line,
				false);
	}

	if (suggested_boxkind == BoxKind::UNDEFINED)
	{ 
		suggested_boxkind = representing_bk;
	}
	
	// suggested_bk = representing_bk;
	return suggested_boxkind;
}

// urobim kolmicu na il, pretnem ju s domain_edges ... ziskam tym 2-4 body
// vyrobim usecku hil medzi tymi bodmi ... s nou ziskam vsetky prieniky s ob
// potom najblizsie k presecniku hil vyberiem v oboch smeroch najblizsi prienik
// s ob a ostatnymi il ... 
// nasledne z toho ziskam 1-2 inner bordery ... 
/*! \brief Reworks inner_lines[current_line] into the vector of borders.
 *
 */
std::vector<Border> SetApproximer::rework_to_borders(
	const std::vector<Line>& inner_lines,
	const std::size_t current_line,
	const BoxKind& representing_bk,
	const std::vector<Border>& outer_borders,
	const std::vector<Border>& domain_edge_borders,
	const Box& domain) const
{
	std::vector<Border> inner_borders;
	if (inner_lines.size() == 0)
		// || inner_lines.size() == 1)
		return inner_borders;

	std::vector<BoxKind> fst_bks;
	std::vector<BoxKind> snd_bks;

	const Line& inner_line = inner_lines[current_line];
	const double maximum_domain_distance = 
		GetPointsEuclideanDistance(
			domain.get_x().get_fst(), domain.get_y().get_fst(),
			domain.get_x().get_snd(), domain.get_y().get_snd());

	// for each segment starting point of inner_line
	for (std::size_t sp_il = 0; sp_il < inner_line.size() - 1; ++sp_il)
	{
		// we will get BoxKinds on each side

		// perpendicular line to inner_line first ("right") side
		std::pair<Point, Point> fst_pil =
			GetPerpendicularInMid(
				inner_line[sp_il], inner_line[sp_il + 1],
				true,
				maximum_domain_distance);

		fst_bks.push_back(
			assign_boxkind(
				fst_pil,
				inner_lines,
				current_line,
				sp_il,
				representing_bk,
				outer_borders,
				domain_edge_borders,
				maximum_domain_distance));


		// perpendicular line to inner_line second ("second") side
		std::pair<Point, Point> snd_pil =
			GetPerpendicularInMid(
				inner_line[sp_il], inner_line[sp_il + 1],
				false,
				maximum_domain_distance);

		snd_bks.push_back(
			assign_boxkind(
				snd_pil,
				inner_lines,
				current_line,
				sp_il,
				representing_bk,
				outer_borders,
				domain_edge_borders,
				maximum_domain_distance));

	} // for each segment starting point of inner_line


	// we will separate parts due to BoxKinds
	
	// for each segment starting point of inner_line
	BoxKind fst = fst_bks[0];
	BoxKind snd = snd_bks[0];
	Line constructed;
	for (std::size_t sp_il = 0; sp_il < inner_line.size() - 1; ++sp_il)
	{
		constructed.push_back(inner_line[sp_il]);

		if (is_weaker_boxkind(fst, fst_bks[sp_il]))
		{
			fst = fst_bks[sp_il];
		}

		if (is_weaker_boxkind(snd, snd_bks[sp_il]))
		{
			snd = snd_bks[sp_il];
		}

		if ((fst != fst_bks[sp_il] && !is_weaker_boxkind(fst_bks[sp_il], fst)) ||
			(snd != snd_bks[sp_il] && !is_weaker_boxkind(snd_bks[sp_il], snd)))
		{
			inner_borders.emplace_back(constructed, fst, snd);
			Point last = constructed[constructed.size() - 1];
			constructed.clear();
			constructed.push_back(last);
			fst = fst_bks[sp_il];
			snd = snd_bks[sp_il];
		}
	}
	
	constructed.push_back(inner_line[inner_line.size() - 1]);
	inner_borders.emplace_back(constructed, fst, snd);

	return inner_borders;
}

/*! \brief Reworks inner_lines into the vector of borders.
 *
 */
std::vector<Border> SetApproximer::rework_to_borders(
	const std::vector<Line>& inner_lines,
	const BoxKind& representing_bk,
	const std::vector<Border>& outer_borders,
	const std::vector<Border>& domain_edge_borders,
	const Box& domain) const
{
	std::vector<Border> inner_borders;

	std::vector<Border> i_b;
	for (std::size_t i = 0; i < inner_lines.size(); ++i)
	{
		i_b = rework_to_borders(
			inner_lines,
			i,
			representing_bk,
			outer_borders,
			domain_edge_borders,
			domain);
		inner_borders.insert(inner_borders.end(), i_b.begin(), i_b.end());
	}

	return inner_borders;
}

/*
 ******************************************************************************
 ****************************** WORKING WITH BORDERS **************************
 ******************************************************************************
 */

/*! \brief Suggest BoxKind for the point due to closest points of path and
*  exports their distance from the point in min_distance.
*
*/
BoxKind SetApproximer::suggest_boxkind(
	const Point& point,
	const Border& border,
	double& min_distance) const
{
	if (border.get_path().size() == 0)
		return BoxKind::UNDEFINED;

	std::vector<closest_point_in_line> points =
		border.get_closest_points(point, min_distance);

	if (min_distance == 0)
		return BoxKind::UNDEFINED;

	std::vector<BoxKind> bks;
	for (auto& p : points)
	{
		if (IsOnTheRight(
			border.get_path()[p.second], 
			border.get_path()[p.second + 1], 
			point))
		{
			bks.push_back(border.get_fst());
		}
		else
		if (IsOnTheLeft(
			border.get_path()[p.second], 
			border.get_path()[p.second + 1], 
			point))
		{
			bks.push_back(border.get_snd());
		}
		else
		{
			bks.push_back(BoxKind::UNDEFINED);
		}
	}

	if (bks.size() == 0)
	{
		return BoxKind::UNDEFINED;
	}

	BoxKind bk_first = bks[0];
	for (auto& bk : bks)
	{
		if (bk != bk_first)
		{
			if (is_weaker_boxkind(bk, bk_first))
				continue;

			if (is_weaker_boxkind(bk_first, bk))
			{
				bk_first = bk;
				continue;
			}

			return BoxKind::UNDEFINED;
		}
	}

	return bk_first;
}

/*! \brief Suggest BoxKind for the point due to closest points of path.
*
*/
BoxKind SetApproximer::suggest_boxkind(
	const Point& point,
	const Border& border) const
{
	double min_distance;
	return suggest_boxkind(
		point, 
		border,
		min_distance);
}

/*! \brief Suggests BoxKind for the point due to closest points of paths 
 *  of borders.
 *
 */
BoxKind SetApproximer::suggest_boxkind(
	const Point& point,
	const std::vector<Border>& borders) const
{
	double min_distance;
	std::vector<double> distances;
	std::vector<BoxKind> bks;
	min_distance = std::numeric_limits<double>::max();

	for (auto& b : borders)
	{
		bks.push_back(suggest_boxkind(point, b, min_distance));
		distances.push_back(min_distance);
	}

	if (bks.size() == 0)
		return BoxKind::UNDEFINED;

	for (auto& d : distances)
	{
		if (min_distance > d)
			min_distance = d;
	}

	std::vector<std::size_t> positions;
	for (std::size_t i = 0; i < distances.size(); ++i)
	{
		if (min_distance == distances[i])
			positions.push_back(i);
	}

	BoxKind bk_first = bks[positions[0]];
	for (auto& pos : positions)
	{
		if (bk_first != bks[pos])
		{
			if (is_weaker_boxkind(bks[pos], bk_first))
				continue;

			if (is_weaker_boxkind(bk_first, bks[pos]))
			{
				bk_first = bks[pos];
				continue;
			}

			return BoxKind::UNDEFINED;
		}
	}
	
	return bk_first;
}

/*
 ******************************************************************************
 *************************** REWORKING LINES TO POLYGONS **********************
 ******************************************************************************
 */

/*! \brief Adds intersections of lines to the corresponding lines.
 *
 */
void SetApproximer::add_intersections_to(
	Line& fst_l,
	Line& snd_l) const
{
	if (fst_l.size() == 0 || snd_l.size() == 0)
		return;

	Point add_point;

	// and we will add to them their intersections
	for (std::size_t fl_index = 0; fl_index < fst_l.size() - 1; ++fl_index)
	{
		for (std::size_t sl_index = 0; sl_index < snd_l.size() - 1; ++sl_index)
		{
			// if the intersection already exists, then its fine
			if (fst_l[fl_index] == snd_l[sl_index] ||
				fst_l[fl_index + 1] == snd_l[sl_index] ||
				fst_l[fl_index] == snd_l[sl_index + 1] ||
				fst_l[fl_index + 1] == snd_l[sl_index + 1])
				continue;

			// if the intersection exists, then we will add it
			if (DoLinesHaveIntersection(
				fst_l[fl_index],
				fst_l[fl_index + 1],
				snd_l[sl_index],
				snd_l[sl_index + 1],
				add_point,
				true,
				delta_x_box_level,
				delta_y_box_level))
			{
				// we will try if the point is valid
				if (IsPointBetween(add_point, fst_l[fl_index], fst_l[fl_index + 1]) &&
					IsPointBetween(add_point, snd_l[sl_index], snd_l[sl_index + 1]))
				{
					fst_l.insert(fst_l.begin() + fl_index + 1, add_point);
					snd_l.insert(snd_l.begin() + sl_index + 1, add_point);
					++sl_index;
					continue;
				}

				// not between the points, we will try another method
				const Point fst_mp = GetPointBetween(fst_l[fl_index], fst_l[fl_index + 1]);
				const Point snd_mp = GetPointBetween(snd_l[sl_index], snd_l[sl_index + 1]);
				const Point fs_mp = GetPointBetween(fst_mp, snd_mp);
				if (IsPointBetween(fs_mp, fst_l[fl_index], fst_l[fl_index + 1]) &&
					IsPointBetween(fs_mp, snd_l[sl_index], snd_l[sl_index + 1]))
				{
					fst_l.insert(fst_l.begin() + fl_index + 1, fs_mp);
					snd_l.insert(snd_l.begin() + sl_index + 1, fs_mp);
					++sl_index;
					continue;
				}

				// still not between the points, we will try another method
				if (IsPointBetween(fst_l[fl_index], snd_l[sl_index], snd_l[sl_index + 1]))
				{
					snd_l.insert(snd_l.begin() + sl_index + 1, fst_l[fl_index]);
					++sl_index;
					continue;
				}
				if (IsPointBetween(fst_l[fl_index + 1], snd_l[sl_index], snd_l[sl_index + 1]))
				{
					snd_l.insert(snd_l.begin() + sl_index + 1, fst_l[fl_index + 1]);
					++sl_index;
					continue;
				}
				if (IsPointBetween(snd_l[sl_index], fst_l[fl_index], fst_l[fl_index + 1]))
				{
					fst_l.insert(fst_l.begin() + fl_index + 1, snd_l[sl_index]);
					++sl_index;
					continue;
				}
				if (IsPointBetween(snd_l[sl_index + 1], fst_l[fl_index], fst_l[fl_index + 1]))
				{
					fst_l.insert(fst_l.begin() + fl_index + 1, snd_l[sl_index + 1]);
					++sl_index;
					continue;
				}

				// if nothing succeeded
				continue;

			} // if they have intersection

		} // for sl_index

	} // for fl_index
}

/*! \brief Adds intersections of lines to the corresponding lines.
 *
 */
void SetApproximer::add_intersections_to(
	std::vector<Line>& lines) const
{
	// we will select 2 different lines
	for (std::size_t fst_line = 0; fst_line < lines.size(); ++fst_line)
	{
		for (std::size_t snd_line = fst_line + 1; snd_line < lines.size(); ++snd_line)
		{
			add_intersections_to(
				lines[fst_line],
				lines[snd_line]);
		}
	}
}

/*! \brief Adds intersections of borders to the corresponding borders.
 *
 */
void SetApproximer::add_intersections_to(
	std::vector<Border>& borders) const
{
	// we will select 2 different lines
	for (std::size_t fst_line = 0; fst_line < borders.size(); ++fst_line)
	{
		for (std::size_t snd_line = fst_line + 1; snd_line < borders.size(); ++snd_line)
		{
			//Line& fst_l = borders[fst_line].set_path();
			//Line& snd_l = borders[snd_line].set_path();

			add_intersections_to(
				borders[fst_line].set_path(),
				borders[snd_line].set_path());
			
		} // for snd_line

	} // for fst_line
}

/*! \brief Method split polygons into smaller polygons if possible.
 *
 */
std::vector<Line> SetApproximer::split_polygons(
	const std::vector<Line>& polygons) const
{
	std::vector<Line> splitted_polygons;

	std::set<Point, PointComparer> split_points;

	for (auto& p : polygons)
	{
		split_points.clear();		

		for (std::size_t e1 = 0; e1 < p.size(); ++e1)
		{
			for (std::size_t e2 = e1 + 1; e2 < p.size(); ++e2)
			{
				if (p[e1] == p[e2])
				{
					auto ptr = split_points.find(p[e1]);
					if (ptr == split_points.end())
					{
						split_points.insert(p[e1]);
					}
				}
			}
		}

		if (split_points.size() > 0)
		{
			bool fst_part = true;
			Line fst;
			Line next;

			for (std::size_t e = 0; e < p.size(); ++e)
			{
				auto ptr = split_points.find(p[e]);

				if (ptr == split_points.end())
				{
					if (fst_part)
					{
						fst.push_back(p[e]);
					}
					else
					{
						next.push_back(p[e]);
					}
				}
				// (ptr != split_points.end())
				else
				{
					if (fst_part)
					{
						fst.push_back(p[e]);
						fst_part = false;
					}
					else
					{
						next.push_back(p[e]);
						splitted_polygons.push_back(next);
						next.clear();
					}
				}
			}

			// the last part with few first elements
			next.insert(next.end(), fst.begin(), fst.end());
			if (next.size() > 0)
			{
				splitted_polygons.push_back(next);
			}
		}
		else
		{
			splitted_polygons.push_back(p);
		}

	}

	return splitted_polygons;
}

/*! \brief Checks, if oriented edge has already been used.
 *
 */
bool SetApproximer::edge_was_walked(
	const graph_edge& edge,
	const std::vector<graph_edge>& walked_edges) const
{
	for (auto& we : walked_edges)
	{
		if (we.first == edge.first && we.second == edge.second)
			return true;
	}
	return false;
}

/*! \brief Returns index of p in points.
 *
 */
int SetApproximer::get_index_of_element(
	const Point& p,
	const std::vector<Point>& points) const
{
	for (std::size_t i = 0; i < points.size(); ++i)
	{
		if (points[i] == p)
		{
			return i;
		}
	}
	return -1;
}

/*! \brief Method will try to use oriented edge.
 *
 */
bool SetApproximer::walk_edge(
	Point v_curr,
	Point v_next,
	std::vector<Point>& polygon,
	std::vector<graph_edge>& walked_edges,
	const std::map<Point, std::vector<Point>, PointComparer>& points) const
{
	for (;;)
	{
		if (v_next == polygon[0])
			return true;

		const std::pair<Point, Point> edge =
			std::make_pair(v_curr, v_next);

		if (edge_was_walked(edge, walked_edges))
			return false;

		polygon.push_back(v_next);
		walked_edges.push_back(edge);

		auto p = points.find(v_next);
		if (p == points.end())
		{
			throw new WrongDataException("Point not present amongst the points");
		}
		const std::vector<Point>& cons_of_v_next = p->second;

		int index = get_index_of_element(v_curr, cons_of_v_next);
		if (index == -1)
		{
			throw new WrongDataException("Index not found for the Point");
		}

		// next point is selected due to angle held with current one
		std::size_t next = ((std::size_t)index + 1) % cons_of_v_next.size();

		// for next iteration
		v_curr = v_next;
		v_next = cons_of_v_next[next];
	}
}

/*! \brief Method will build polygons. Polygon implemented this way 
 *  does not have last point same as first point and edge between
 *  last and first point done by definition.
 *
 */
std::vector<Line> SetApproximer::build_polygons(
	const std::map<Point, std::vector<Point>, PointComparer>& points) const
{
	// built polygons
	std::vector<Line> polygons;

	// vector of walked edges
	std::vector<graph_edge> walked_edges;

	// for each point
	for (auto it = points.begin(); it != points.end(); ++it)
	{
		const Point& v0 = it->first;
		const std::vector<Point>& cons = it->second;
		// for each his connection we will try to build polygon
		for (std::size_t con = 0; con < cons.size(); ++con)
		{
			const Point& vn = cons[con];
			std::vector<Point> polygon;

			polygon.push_back(v0);
			
			// walk_edge
			bool new_polygon =
				walk_edge(v0, vn, polygon, walked_edges, points);

			if (new_polygon)
				polygons.push_back(polygon);
		}
	}

	std::vector<Line> splitted_polygons =
		split_polygons(polygons);

	return splitted_polygons;
}

/*! \brief Returns polygons made from lines. Polygon implemented this way 
 *  does not have last point same as first point and edge between
 *  last and first point done by definition. Polygons do not have other, than 
 *  line intersections.
 *
 */
std::vector<Line> SetApproximer::get_polygons(
	const std::vector<Line>& lines) const
{
	// map of neighbours for each point
	std::map<Point, std::vector<Point>, PointComparer> points;

	// we will add intersections to the lines
	std::vector<Line> lines_with_intersections(lines);
	add_intersections_to(lines_with_intersections);

	// we will get points with connections from lines
	for (auto& l : lines_with_intersections)
	{
		if (l.size() <= 1)
			continue;

		for (std::size_t i = 0; i < l.size() - 1; ++i)
		{
			// we will add path from first to second point 
			// ... and from second to first
			auto s1 = points.find(l[i]);
			auto s2 = points.find(l[i + 1]);

			if (s1 == points.end())
			{
				points.insert(std::make_pair(l[i], std::vector<Point>{l[i + 1]}));
			}
			else
			{
				bool is_in = false;
				for (auto& n : s1->second)
				{
					if (n == l[i + 1])
					{
						is_in = true;
						break;
					}
				}

				if (!is_in)
				{
					s1->second.push_back(l[i + 1]);
				}
			}

			if (s2 == points.end())
			{
				points.insert(std::make_pair(l[i + 1], std::vector<Point>{l[i]}));
			}
			else
			{
				bool is_in = false;
				for (auto& n : s2->second)
				{
					if (n == l[i])
					{
						is_in = true;
						break;
					}
				}

				if (!is_in)
				{
					s2->second.push_back(l[i]);
				}
			}

		} // for each line segment

	} // for each line

	// for each vertex we will sort connected vertices due to an angle
	for (auto it = points.begin(); it != points.end(); ++it)
	{
		const Point& v0 = it->first;
		const std::vector<Point>& cons = it->second;

		std::vector<std::pair<double, std::size_t> > angles;
		for (std::size_t con = 0; con < cons.size(); ++con)
		{
			angles.push_back(
				std::make_pair(GetAngle(v0, cons[con]), con));
		}
		std::sort(angles.begin(), angles.end());

		std::vector<Point> sorted_cons;
		for (std::size_t i = 0; i < angles.size(); ++i)
			sorted_cons.push_back(cons[angles[i].second]);

		it->second = sorted_cons;
	}

	return build_polygons(points);
}

/*! \brief Returns polygons made from borders. Polygon implemented this way 
 *  does not have last point same as first point and edge between
 *  last and first point done by definition. Polygons do not have other, than 
 *  line intersections.
 *
 */
std::vector<Border> SetApproximer::get_polygons(
	const std::vector<Border>& borders) const
{
	// map of neighbours for each point
	std::map<Point, std::vector<Point>, PointComparer> points;

	// map of boxkinds for each pair of points with existing segment
	std::map<std::pair<Point, Point>, std::pair<BoxKind, BoxKind>, PointComparer> point_bks;

	// we will add intersections to the lines
	std::vector<Border> borders_with_intersections(borders);
	add_intersections_to(borders_with_intersections);

	// we will get points with connections from lines
	for (auto& border : borders_with_intersections)
	{
		const Line& line = border.get_path();

		if (line.size() <= 1)
			continue;

		for (std::size_t i = 0; i < line.size() - 1; ++i)
		{
			// we will add path from first to second point 
			// ... and from second to first
			auto s1 = points.find(line[i]);
			auto s2 = points.find(line[i + 1]);

			if (s1 == points.end())
			{
				points.insert(std::make_pair(line[i], std::vector<Point>{line[i + 1]}));
			}
			else
			{
				bool is_in = false;
				for (auto& n : s1->second)
				{
					if (n == line[i + 1])
					{
						is_in = true;
						break;
					}
				}

				if (!is_in)
				{
					s1->second.push_back(line[i + 1]);
				}
			}

			if (s2 == points.end())
			{
				points.insert(std::make_pair(line[i + 1], std::vector<Point>{line[i]}));
			}
			else
			{
				bool is_in = false;
				for (auto& n : s2->second)
				{
					if (n == line[i])
					{
						is_in = true;
						break;
					}
				}

				if (!is_in)
				{
					s2->second.push_back(line[i]);
				}
			}

			// we will assign corresponding BoxKinds to each line segment
			auto s12 = point_bks.find(std::make_pair(line[i], line[i + 1]));
			auto s21 = point_bks.find(std::make_pair(line[i + 1], line[i]));

			if (s12 == point_bks.end())
			{
				point_bks.insert(std::make_pair(
					std::make_pair(line[i], line[i + 1]),
					std::make_pair(border.get_fst(), border.get_snd())));
			}
			else
			{
				if (s12->second.first != border.get_fst() &&
					! is_weaker_boxkind(border.get_fst(), s12->second.first))
				{
					if (is_weaker_boxkind(s12->second.first, border.get_fst()))
					{
						s12->second.first = border.get_fst();
					}
					else
					{
						throw new WrongDataException("BoxKind of polygon is ambigious");
					}
				}
				
				if (s12->second.second != border.get_snd() &&
					! is_weaker_boxkind(border.get_snd(), s12->second.second))
				{
					if (is_weaker_boxkind(s12->second.second, border.get_snd()))
					{
						s12->second.second = border.get_snd();
					}
					else
					{
						throw new WrongDataException("BoxKind of polygon is ambigious");
					}
				}
			}

			if (s21 == point_bks.end())
			{
				point_bks.insert(std::make_pair(
					std::make_pair(line[i + 1], line[i]),
					std::make_pair(border.get_snd(), border.get_fst())));
			}
			else
			{
				if (s21->second.first != border.get_snd() &&
					! is_weaker_boxkind(border.get_snd(), s21->second.first))
				{
					if (is_weaker_boxkind(s21->second.first, border.get_snd()))
						s21->second.first = border.get_snd();
					else
					{
						throw new WrongDataException("BoxKind of polygon is ambigious");
					}
				}

				if (s21->second.second != border.get_fst() &&
					! is_weaker_boxkind(border.get_fst(), s21->second.second))
				{
					if (is_weaker_boxkind(s21->second.second, border.get_fst()))
						s21->second.second = border.get_fst();
					else
					{
						throw new WrongDataException("BoxKind of polygon is ambigious");
					}
				}
			}

		} // for each line segment

	} // for each line

	// for each vertex we will sort connected vertices due to an angle
	for (auto it = points.begin(); it != points.end(); ++it)
	{
		const Point& v0 = it->first;
		const std::vector<Point>& cons = it->second;

		std::vector<std::pair<double, std::size_t> > angles;
		for (std::size_t con = 0; con < cons.size(); ++con)
		{
			angles.push_back(
				std::make_pair(GetAngle(v0, cons[con]), con));
		}
		std::sort(angles.begin(), angles.end());

		std::vector<Point> sorted_cons;
		for (std::size_t i = 0; i < angles.size(); ++i)
			sorted_cons.push_back(cons[angles[i].second]);

		it->second = sorted_cons;
	}

	std::vector<Line> polygons = build_polygons(points);
	std::vector<Border> basic_regions;

	std::set<BoxKind> p_fst_bks;
	std::set<BoxKind> p_snd_bks;
	// we will get fst and snd bks for polygon
	for (auto& p : polygons)
	{
		if (p.size() < 3)
			continue;

		p_fst_bks.clear();
		p_snd_bks.clear();

		for (std::size_t i = 0; i < p.size() - 1; ++i)
		{
			auto ptr = point_bks.find(std::make_pair(p[i], p[i + 1]));

			auto fst_bk = p_fst_bks.find(ptr->second.first);
			auto snd_bk = p_snd_bks.find(ptr->second.second);
			if (fst_bk == p_fst_bks.end())
				p_fst_bks.insert(ptr->second.first);
			if (snd_bk == p_snd_bks.end())
				p_snd_bks.insert(ptr->second.second);
		}

		// might be reworked just for iterators
		if (p_fst_bks.empty())
		{
			throw new WrongDataException("BoxKind of polygon must be set");
		}
		BoxKind fst = suggest_boxkind(p_fst_bks, true);

		if (p_snd_bks.empty())
		{
			throw new WrongDataException("BoxKind of polygon must be set");
		}
		BoxKind snd = suggest_boxkind(p_snd_bks, true);

		basic_regions.emplace_back(p, fst, snd);
	}
	
	return basic_regions;
}

/*
 ******************************************************************************
 ************************** REWORKING BORDERS TO REGIONS **********************
 ******************************************************************************
 */

/*! \brief Returns true, only if polygons are same. 
 * 
 */
bool SetApproximer::polygons_are_same(
	const Line& fst,
	const Line& snd) const
{
	if (fst.size() != snd.size() )
		return false;

	if (fst.size() == 0)
		return false;

	// we will get indexes of all same points as the fst[0]
	std::vector<std::size_t> indexes;
	for (std::size_t i = 0; i < snd.size(); ++i)
	{
		if (fst[0] == snd[i])
			indexes.push_back(i);
	}

	if (indexes.size() == 0)
		return false;

	bool same = false;
	for (auto& i : indexes)
	{
		same = true;
		// to the right side
		for (std::size_t j = 0; j < snd.size(); ++j)
		{
			if (fst[j] != snd[(i + j) % snd.size()])
			{
				same = false;
				break;
			}
		}
		if (same)
			return true;

		same = true;
		// to the left side
		for (std::size_t j = 0; j < snd.size(); ++j)
		{
			if (fst[j] != snd[(i + snd.size() - j) % snd.size()])
			{
				same = false;
				break;
			}
		}
		if (same)
			return true;
	}

	return false;	
}

/*! \brief Returns true, only if polygon is representing inner boundary. 
 * 
 */
bool SetApproximer::polygon_is_inner_boundary(
	const Line& which) const
{
	int wn;
	int sum = 0;
	for (auto& point : which)
	{
		wn = GetWindingNumber(point, which);
		sum += wn;
	}

	return sum > 0;
}

/*! \brief Returns true, only if polygon is representing outer boundary. 
 * 
 */
bool SetApproximer::polygon_is_outer_boundary(
	const Line& which) const
{
	int wn;
	int sum = 0;
	for (auto& point : which)
	{
		wn = GetWindingNumber(point, which);
		sum += wn;
	}

	return sum < 0;
}

/*! \brief Returns true, only if polygon which belongs to polygon owner, 
 *   or is same.
 * 
 *  WRONG DESCRIPTION
 *  Polygon 
 *  which must have at least one point strictly on the inside of the polygon 
 *  owner.
 *
 */
bool SetApproximer::polygon_belongs_to_polygon(
	const Line& which,
	const Line& owner) const
{
	for (auto& point : which)
	{
		if (! PointBelongsToPolygon(point, owner))
			return false;
	}

	return true;
}

/*! \brief Reworks borders into the regions.
 *
 */
std::vector<PBRegion> SetApproximer::rework_to_regions(
	const std::vector<Border>& borders) const
{
	std::vector<PBRegion> regions;

	// we will get polygons from the borders
	std::vector<Border> polygons = get_polygons(borders);

	// we will delete empty and not usable polygons
	for (std::size_t i = 0; i < polygons.size(); ++i)
	{
		if (polygons.size() < 3)
		{
			polygons.erase(polygons.begin() + i);
			--i;
		}
	}

	// we will get boundary box for each polygon
	std::vector<Box> boundary_boxes;
	boundary_boxes.reserve(polygons.size());
	for (auto& p : polygons)
		boundary_boxes.push_back(GetBoundaryBox(p.get_path()));

	// we will say, which are inner and which are outer
	std::vector<bool> inner;
	inner.reserve(polygons.size());
	for (auto& p : polygons)
	{
		bool in = polygon_is_inner_boundary(p.get_path());
		inner.push_back(in);
	}

	// we will delete the same outer ones if they cover the same region as 
	// ... inner ones!!!
	for (std::size_t i = 0; i < polygons.size(); ++i)
	{
		for (std::size_t j = i + 1; j < polygons.size(); ++j)
		{
			// we know that one has to be inner and the second has to be outer
			if ((inner[i] && ! inner[j]) ||
				(inner[j] && ! inner[i]))
			{
				// we know that they have to have same boundary box
				if (boundary_boxes[i] == boundary_boxes[j])
				{
					// we will make the very deep check if they are the same
					if (polygons_are_same(polygons[i].get_path(), polygons[j].get_path()) || 
						(polygon_belongs_to_polygon(polygons[i].get_path(), polygons[j].get_path()) && 
						 polygon_belongs_to_polygon(polygons[j].get_path(), polygons[i].get_path())))
					{
						if (! inner[i])
						{
							polygons.erase(polygons.begin() + i);
							inner.erase(inner.begin() + i);
							boundary_boxes.erase(boundary_boxes.begin() + i);
							--i;
							break;
						}
						// (! inner[j])
						else
						{
							polygons.erase(polygons.begin() + j);
							inner.erase(inner.begin() + j);
							boundary_boxes.erase(boundary_boxes.begin() + j);
							--j;
						}
					}
				}
			}
		}
	}

	// we know that polygons do not intersect in more than border
	
	// whole polygon may belongs to another one

	// for every polygon
	for (std::size_t i = 0; i < polygons.size(); ++i)
	{
		// we don't care doing regions for outer regions, if we will need them
		// ... we will use them in another inner regions
		if (!inner[i])
			continue;

		// we will select those polygons representing outer sides, 
		// ... which's boundary boxes have intersection with current's boundary box
		std::vector<bool> needed(polygons.size(), false);
		for (std::size_t j = 0; j < polygons.size(); ++j)
		{
			if (i == j)
				continue;

			if (boundary_boxes[i].has_intersection_with(boundary_boxes[j]))
			{
				needed[j] = true;
			}
		}

		// we will deselect those, which are not inside the polygon
		for (std::size_t j = 0; j < polygons.size(); ++j)
		{
			if (needed[j])
			{
				if (! polygon_belongs_to_polygon(
					polygons[j].get_path(), 
					polygons[i].get_path()))
				{
					needed[j] = false;
				}
			}
		}

		// we will deselect those, who are nested into other ones
		for (std::size_t j = 0; j < polygons.size(); ++j)
		{
			if (needed[j])
			{
				for (std::size_t k = 0; k < polygons.size(); ++k)
				{
					if (needed[k] && j != k)
					{
						if (polygon_belongs_to_polygon(
							polygons[k].get_path(),
							polygons[j].get_path()))
						{
							needed[k] = false;
						}
					}
				}
			}
		}

		std::vector<Line> selected_polygons;
		std::vector<bool> in_out;
		// we will add inner bk ~ snd
		BoxKind inner_bk = polygons[i].get_snd(); 
		std::set<BoxKind> basic_region_possible_bks;
		basic_region_possible_bks.insert(inner_bk);
		
		selected_polygons.push_back(polygons[i].get_path());
		in_out.push_back(true);
		for (std::size_t j = 0; j < polygons.size(); ++j)
		{
			if (needed[j])
			{
				selected_polygons.push_back(polygons[j].get_path());
				in_out.push_back(false);
				
				if (inner[j])
				{
					// we will add outer bk ~ fst
					auto ptr = basic_region_possible_bks.find(polygons[j].get_fst());
					if (ptr == basic_region_possible_bks.end())
						basic_region_possible_bks.insert(polygons[j].get_fst());
				}
				// ! inner[j]
				else
				{
					// we will add outer bk ~ snd
					auto ptr = basic_region_possible_bks.find(polygons[j].get_snd());
					if (ptr == basic_region_possible_bks.end())
						basic_region_possible_bks.insert(polygons[j].get_snd());
				}
			}
		}

		BoxKind selected_bk = suggest_boxkind(basic_region_possible_bks, true);
		regions.emplace_back(selected_polygons, in_out, selected_bk);

	} // for each polygon

	return regions;
}