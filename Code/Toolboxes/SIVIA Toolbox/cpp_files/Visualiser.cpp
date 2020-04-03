#include "Visualiser.h"

#include "BoxProcessor.h"
#include "DataSet.h"
#include "DataRedefinitionException.h"
#include "Painter.h"
#include "Sampler.h"
#include "SetApproximer.h"

/*
 ******************************************************************************
 ********************************** CONSTRUCTORS ******************************
 ******************************************************************************
 */

/*! \brief Sets colors to default values.
 *
 */
void Visualiser::set_basic_colors()
{
	set_colors(
		Color(200, 155, 0),
		Color(30, 200, 70),
		Color(120, 50, 80),
		Color(0, 0, 0),
		Color(175, 32, 186));
}

/*! \brief Sets default options / settings.
 *
 */
void Visualiser::prepare_settings()
{
	set_visualisation_types();
	set_sampling_methods();
	set_approximating_methods();
}

/*! \brief This constructor have files containing separated coordinates of 
 *  boxes. Files have to be in order: 
 *  ... included min x, included max x, included min y, included max y
 *  ... unknown min x, unknown max x, unknown min y, unknown max y
 *  ... excluded min x, excluded max x, excluded min y, excluded max y
 *
 */
Visualiser::Visualiser(const std::vector<std::string>& file_names) 
  : _boxprocessor(),
	_dataset(_boxprocessor, file_names),
	_sampler(_dataset, _boxprocessor),
	_setapproximer(),
	_painter(_dataset)
{ 
	set_basic_colors();
	prepare_settings();
	adjust_tolerance();
}

/*! \brief This constructor have files containing separated boxes. First file
 *  is containing true boxes, second file is containing unknown files, third 
 *  file is containing false boxes. 
 *
 */
Visualiser::Visualiser(
	const std::string& t_file,
	const std::string& u_file,
	const std::string& f_file)
  : _boxprocessor(),
	_dataset(_boxprocessor, t_file, u_file, f_file),
	_sampler(_dataset, _boxprocessor),
	_setapproximer(),
	_painter(_dataset)
{ 
	set_basic_colors();
	prepare_settings();
	adjust_tolerance();
}

/*! \brief This constructor have vectors containing separated coordinates of 
 *  boxes. Vectors have to be in order: 
 *  ... included min x, included max x, included min y, included max y
 *  ... unknown min x, unknown max x, unknown min y, unknown max y
 *  ... excluded min x, excluded max x, excluded min y, excluded max y
 *
 */
Visualiser::Visualiser(const std::vector<std::vector<DataType> >& vectors)
  : _boxprocessor(),
	_dataset(_boxprocessor, vectors),
	_sampler(_dataset, _boxprocessor),
	_setapproximer(),
	_painter(_dataset)
{
	set_basic_colors();
	prepare_settings();
	adjust_tolerance();
}

/*! \brief This constructor have vectors containing separated true boxes, 
 *  unknown boxes and false boxes.
 *
 */
Visualiser::Visualiser(
	const std::vector<Box>& t_boxes,
	const std::vector<Box>& u_boxes,
	const std::vector<Box>& f_boxes)
  : _boxprocessor(),
	_dataset(_boxprocessor, t_boxes, u_boxes, f_boxes),
	_sampler(_dataset, _boxprocessor),
	_setapproximer(),
	_painter(_dataset)
{
	set_basic_colors();
	prepare_settings();
	adjust_tolerance();
}

/*
 ******************************************************************************
 ************************* DATA ACCESS, OPTIONS, SETTINGS *********************
 ******************************************************************************
 */

/*! \brief Returns width of visualisation.
 *
 */
std::size_t Visualiser::get_size_of_x() const
{
	return _painter.get_width();
}

/*! \brief Returns height of visualisation.
 *
 */
std::size_t Visualiser::get_size_of_y() const
{
	return _painter.get_height();
}

/*! \brief Returns real coordinates of the mid of the pixel defined by (x,y).
 *
 */
Point Visualiser::get_coordinates_of_pixel(
	const int x,
	const int y) const
{
	return _painter.get_coordinates_of_pixel(x, y);
}

/*! \brief Returns true, if x coordinates are visualised reverse.
 *
 */
bool Visualiser::is_x_reverse() const
{
	return _painter.is_x_reverse();
}

/*! \brief Returns true, if y coordinates are visualised reverse.
 *
 */
bool Visualiser::is_y_reverse() const
{
	return _painter.is_y_reverse();
}

/*! \brief Returns total minimum x coordinate of the domain.
 *
 */
DataType Visualiser::get_total_min_x() const
{
	return _painter.get_total_min_x();
}

/*! \brief Returns total maximum x coordinate of the domain.
 *
 */
DataType Visualiser::get_total_max_x() const
{
	return _painter.get_total_max_x();
}

/*! \brief Returns total minimum y coordinate of the domain.
 *
 */
DataType Visualiser::get_total_min_y() const
{
	return _painter.get_total_min_y();
}

/*! \brief Returns total maximum y coordinate of the domain.
 *
 */
DataType Visualiser::get_total_max_y() const
{
	return _painter.get_total_max_y();
}

/*! \brief Returns total minimum x coordinate of the currently zoomed region.
 *
 */
DataType Visualiser::get_zoomed_min_x() const
{
	return _painter.get_zoomed_min_x();
}

/*! \brief Returns total maximum x coordinate of the currently zoomed region.
 *
 */
DataType Visualiser::get_zoomed_max_x() const
{
	return _painter.get_zoomed_max_x();
}

/*! \brief Returns total minimum y coordinate of the currently zoomed region.
 *
 */
DataType Visualiser::get_zoomed_min_y() const
{
	return _painter.get_zoomed_min_y();
}

/*! \brief Returns total maximum y coordinate of the currently zoomed region.
 *
 */
DataType Visualiser::get_zoomed_max_y() const
{
	return _painter.get_zoomed_max_y();
}

/*! \brief Returns total minimum x coordinate of the currently zoomed region as
 *  reference.
 *
 */
DataType & Visualiser::set_zoomed_min_x()
{
	return _painter.set_zoomed_min_x();
}

/*! \brief Returns total maximum x coordinate of the currently zoomed region as
 *  reference.
 *
 */
DataType & Visualiser::set_zoomed_max_x()
{
	return _painter.set_zoomed_max_x();
}

/*! \brief Returns total minimum y coordinate of the currently zoomed region as
 *  reference.
 *
 */
DataType & Visualiser::set_zoomed_min_y()
{
	return _painter.set_zoomed_min_y();
}

/*! \brief Returns total maximum y coordinate of the currently zoomed region as
 *  reference.
 *
 */
DataType & Visualiser::set_zoomed_max_y()
{
	return _painter.set_zoomed_max_y();
}

/*! \brief Changes tolerance to the currently needed level, where tolerance 
 *  specifies the level of accuracy of computation. This method has to be set 
 *  after each zoom, image resizing, etc. Depends on deep_evaluation setting.
 *
 *  Tolerance is used to suggest number of points needed for good, but no 
 *  over-estimated approximation.
 */
void Visualiser::adjust_tolerance()
{
	// we will set tolerance due to zoomed region
	if (deep_evaluation)
	{
		x_tolerance =
			std::abs(_painter.get_zoomed_max_x() - _painter.get_zoomed_min_x()) /
			(double)(_painter.get_width());
		y_tolerance =
			std::abs(_painter.get_zoomed_max_y() - _painter.get_zoomed_min_y()) /
			(double)(_painter.get_height());
	}
	// we will set tolerance due to total region
	else
	{
		x_tolerance =
			std::abs(_painter.get_total_max_x() - _painter.get_total_min_x()) /
			(double)(_painter.get_width());
		y_tolerance =
			std::abs(_painter.get_total_max_y() - _painter.get_total_min_y()) /
			(double)(_painter.get_height());
	}
}

/*! \brief Changes tolerance to the selected level, where tolerance specifies
 *  the level of accuracy of computation. This method has to be set after each 
 *  zoom, image resizing, etc.
 *
 *  Tolerance is used to suggest number of points needed for good, but no 
 *  over-estimated approximation.
 */
void Visualiser::adjust_tolerance(
	const double x_t,
	const double y_t)
{
	x_tolerance = x_t;
	y_tolerance = y_t;
}

/*! \brief Changes filling options. Currently only changes the BoxKind
 *  visualisation of the UNKNOWN BoxKinds.
 *
 */
void Visualiser::change_approximation_fill()
{
	if (selected_approximation_fill == approx_option::ORIGINAL_AP)
	{
		selected_approximation_fill = approx_option::MINIMALISM_AP;
		return;
	}
	else
	if (selected_approximation_fill == approx_option::MINIMALISM_AP)
	{
		selected_approximation_fill = approx_option::MAXIMALISM_AP;
		return;
	}
	else
	if (selected_approximation_fill == approx_option::MAXIMALISM_AP)
	{
		selected_approximation_fill = approx_option::ORIGINAL_AP;
		return;
	}

	throw new WrongDataException("unknown selected approximating fill");
	return;
}

/*! \brief Returns the name of the currently selected filling option.
 *
 */
std::string Visualiser::get_approximation_fill() const
{
	if (selected_approximation_fill == approx_option::ORIGINAL_AP)
	{
		return "ORIGINAL";
	}
	else
	if (selected_approximation_fill == approx_option::MINIMALISM_AP)
	{
		return "MINIMALISM"; 
	}
	else
	if (selected_approximation_fill == approx_option::MAXIMALISM_AP)
	{
		return "MAXIMALISM";
	}

	throw new WrongDataException("unknown selected approximating fill");
	return "";
}

/*! \brief Updates zoom and adjusts tolerance. This method has to be called 
 *  after each zoom.
 *
 */
void Visualiser::update_zoom()
{
	_painter.update_zoom();
	adjust_tolerance();
}

/*! \brief Allows changes of TRUE and FALSE boxes in visualisation.
 *
 */
void Visualiser::allow_tf_changes()
{
	tf_changes_denied = false;
}

/*! \brief Denies changes of TRUE and FALSE boxes in visualisation.
 *
 */
void Visualiser::deny_tf_changes()
{
	tf_changes_denied = true;
}

/*! \brief Returns true, if changes of TRUE and FALSE boxes are allowed in 
 *  visualisation.
 *
 */
bool Visualiser::tf_changes_being_denied() const
{
	return tf_changes_denied;
}

/*! \brief Box edges will be shown in visualisation.
 *
 */
void Visualiser::show_boxes_edges()
{
	boxes_edges_shown = true;
}

/*! \brief Box edges will be hidden in visualisation.
 *
 */
void Visualiser::hide_boxes_edges()
{
	boxes_edges_shown = false;
}

/*! \brief Returns true, if box edges are being shown in visualisation.
 *
 */
bool Visualiser::boxes_edges_being_shown() const
{
	return boxes_edges_shown;
}

/*! \brief Approximated lines will be shown in visualisation.
 *
 */
void Visualiser::show_approximated_lines()
{
	approximated_lines_shown = true;
}

/*! \brief Approximated lines will be hidden in visualisation.
 *
 */
void Visualiser::hide_approximated_lines()
{
	approximated_lines_shown = false;
}

/*! \brief Returns true, if approximated lines are being shown in visualisation.
 *
 */
bool Visualiser::approximated_lines_being_shown() const
{
	return approximated_lines_shown;
}

/*! \brief Enables deep evaluation. Visualisation with this option enabled
 *  may take very long time to be computed.
 *
 */
void Visualiser::enable_deep_evaluation()
{
	deep_evaluation = true;
}

/*! \brief Disables deep evaluation. Visualisation with this option enabled
 *  may take very long time to be computed.
 *
 */
void Visualiser::disable_deep_evaluation()
{
	deep_evaluation = false;
}

/*! \brief Returns true, if deep evaluation is enabled. Visualisation with this
 *  option enabled may take very long time to be computed.
 *
 */
bool Visualiser::deep_evaluation_allowed() const
{
	return deep_evaluation;
}

/*! \brief Enables exact filling. Visualisation with this option enabled may
 *  take very long time to be visualised.
 *
 */
void Visualiser::enable_exact_filling()
{
	exact_filling = true;
}

/*! \brief Disables exact filling. Visualisation with this option enabled may
 *  take very long time to be visualised.
 *
 */
void Visualiser::disable_exact_filling()
{
	exact_filling = false;
}

/*! \brief Returns true, if exact filling is enabled. Visualisation with this 
 *  option enabled may take very long time to be visualised.
 *
 */
bool Visualiser::exact_filling_allowed() const
{
	return exact_filling;
}

/*! \brief Sets point closering to the selected level. Level 3 means, that 
 *  in each cycle of point closering up to 3 neighbours are considered.
 *
 */
void Visualiser::set_point_closering_count(std::size_t pc)
{
	point_closering_count = pc;
}

/*! \brief Returns level of the current point closering. Level 3 means, that 
 *  in each cycle of point closering up to 3 neighbours are considered.
 *
 */
std::size_t Visualiser::get_point_closering_count() const
{
	return point_closering_count;
}

/*! \brief Sets point closering depth to the selected value.
 *
 */
void Visualiser::set_point_closering_depth(std::size_t pc)
{
	point_closering_depth = pc;
}

/*! \brief Returns point closering depth. This method will immediately change 
 *  the base of the painter.
 *
 */
std::size_t Visualiser::get_point_closering_depth() const
{
	return point_closering_depth;
}

void Visualiser::set_colors(
	const Color& color_for_unknown_boxes,
	const Color& color_for_true_boxes,
	const Color& color_for_false_boxes,
	const Color& color_for_edges_of_boxes,
	const Color& color_for_lines)
{
	color_unknown = color_for_unknown_boxes;
	color_true = color_for_true_boxes;
	color_false = color_for_false_boxes;
	color_box_edges = color_for_edges_of_boxes;
	color_lines = color_for_lines;

	_painter.set_base_to_colors(std::vector<Color>{
		color_for_unknown_boxes,
		color_for_true_boxes,
		color_for_false_boxes,
		color_for_edges_of_boxes,
		color_for_lines});
}

/*
 ******************************************************************************
 ************************************ SETTINGS ********************************
 ******************************************************************************
 */

/*! \brief Initializes the options / settings.
 *
 */
void Visualiser::initialize_settings()
{
	if (settings_initialized)
	{
		throw new DataRedefinitionException("settings of visualiser are already set");
		return;
	}

	set_visualisation_types();
	set_sampling_methods();
	set_approximating_methods();
}

/*! \brief Adds setting to the certain set of settings.
 *
 */
void Visualiser::add_setting(
	available_settings& settings,
	const std::string new_setting) const
{
	for (std::size_t i = 0; i < settings.size(); ++i)
	{
		if (settings[i].second == new_setting)
		{
			throw new DataRedefinitionException("this setting is already set");
			return;
		}
	}

	const std::size_t new_setting_id = settings.size();
	settings.push_back(std::make_pair(new_setting_id, new_setting));
}

/*! \brief Adds default types of visualisation to the set of possible 
 *  visualisation types.
 *
 */
void Visualiser::set_visualisation_types()
{
	add_setting(visualisation_types, "original");
	add_setting(visualisation_types, "lines");
	add_setting(visualisation_types, "borders");
	add_setting(visualisation_types, "regions");
}

/*! \brief Adds default methods of sampling to the set of possible sampling 
 *  methods.
 *
 */
void Visualiser::set_sampling_methods()
{
	add_setting(sampling_methods, "UB tracking edge sides of edge boxes");
	add_setting(sampling_methods, "UB tracking mids of edge boxes - strict method");
	add_setting(sampling_methods, "UB tracking mids of edge boxes - loose method");
	add_setting(sampling_methods, "UB & TB tracking edge sides of edge boxes");
	add_setting(sampling_methods, "UB & TB tracking mids of edge boxes - strict method");
	add_setting(sampling_methods, "UB & TB tracking mids of edge boxes - loose method");
	add_setting(sampling_methods, "UB & FB tracking edge sides of edge boxes");
	add_setting(sampling_methods, "UB & FB tracking mids of edge boxes - strict method");
	add_setting(sampling_methods, "UB & FB tracking mids of edge boxes - loose method");
}


/*! \brief Adds default methods of approximation to the set of possible 
 *  approximating methods.
 *
 */
void Visualiser::set_approximating_methods()
{
	add_setting(approximating_methods, "long lines");
	add_setting(approximating_methods, "interpolation per 2 points");
	add_setting(approximating_methods, "casteljau");
	add_setting(approximating_methods, "subdivision (0.33)");
}

/*! \brief Returns possible types of visualisation.
 *
 */
const available_settings& Visualiser::get_visualisation_types() const
{
	return visualisation_types;
}

/*! \brief Returns possible methods of samplation.
 *
 */
const available_settings& Visualiser::get_sampling_methods() const
{
	return sampling_methods;
}

/*! \brief Returns possible methods of approximation.
 *
 */
const available_settings& Visualiser::get_approximating_methods() const
{
	return approximating_methods;
}

/*! \brief Selects visualisation type with selected id.
 *
 */
void Visualiser::set_visualisation_type(const std::size_t method_id)
{
	selected_visualisation_type = method_id;
}

/*! \brief Selects sampling method with selected id.
 *
 */
void Visualiser::set_sampling_method(const std::size_t method_id)
{
	selected_sampling_method = method_id;
}

/*! \brief Selects approximating method with selected id.
 *
 */
void Visualiser::set_approximating_method(const std::size_t method_id)
{
	selected_approximating_method = method_id;
}

/*
 ******************************************************************************
 ***************************** GAINING APPROXIMATIONS *************************
 ******************************************************************************
 */

/*! \brief Applies currently selected approximating method on the line.
 *
 */
Line Visualiser::get_approximation(const Line& line) const
{
	Line approximation;

	Line closered_line = 
		_setapproximer.get_points_closer(
			line, 
			point_closering_count, 
			point_closering_depth, 
			true);

	// long lines
	if (selected_approximating_method == 0)
	{
		approximation = closered_line;
	}

	// spline per 2 points
	if (selected_approximating_method == 1)
	{
		approximation =
			_setapproximer.get_spline(
				closered_line,
				x_tolerance,
				y_tolerance);
	}

	// all points casteljau
	if (selected_approximating_method == 2)
	{
		approximation =
			_setapproximer.get_casteljau(
				closered_line,
				x_tolerance,
				y_tolerance);
	}

	// subdivision with ChaikinCoef=0.33
	if (selected_approximating_method == 3)
	{
		approximation =
			_setapproximer.get_subdivision(
				closered_line,
				x_tolerance,
				y_tolerance,
				0.33,
				false,
				false);
	}

	return approximation;
}

/*! \brief Applies currently selected approximating method on the path 
 * of the border.
 *
 */
Border Visualiser::get_approximation(const Border& border) const
{
	return Border(
		get_approximation(
			border.get_path()),
			border.get_fst(),
			border.get_snd());
}

/*! \brief Applies currently selected approximating method on lines.
 *
 */
std::vector<Line> Visualiser::get_approximation(
	const std::vector<Line>& lines) const
{
	std::vector<Line> approximations;
	for (auto& l : lines)
	{
		approximations.push_back(get_approximation(l));
	}
	return approximations;
}

/*! \brief Applies currently selected approximating method on paths of borders.
 *
 */
std::vector<Border> Visualiser::get_approximation(
	const std::vector<Border>& borders) const
{
	std::vector<Border> approximations;
	for (auto& b : borders)
	{
		approximations.emplace_back(
			get_approximation(b.get_path()),
			b.get_fst(),
			b.get_snd());
	}
	return approximations;
}

/*
 ******************************************************************************
 ******************************** GAINING SOLUTIONS ***************************
 **************************** due to visualisation type ***********************
 ******************************************************************************
 */

/*! \brief Return lines due to currently selected sampling method. 
 *  If (approximated), then approximated lines will be returned as output.
 *  If (with_hardlines), then also edges between included and excluded set will  
 *  be added as non-approximated lines to output.
 *  If (only_safe_output), then safe method will be used instead of unsafe 
 *  method. But only_safe_output does not prevent of using unsafe approximating
 *  method.
 *
 */
std::vector<Line> Visualiser::get_lines(
	const bool approximated,
	const bool with_hardlines,
	const bool only_safe_output) const
{
	std::vector<Line> result_lines;

	std::vector<Line> lines;

	// UB
	if (selected_sampling_method == 0 || 
		selected_sampling_method == 1 ||
		selected_sampling_method == 2)
	{
		std::vector<std::vector<Box> > sampled_boxes =
			_sampler.select_edges_of_boxes_with_neigh(
				BoxKind::UNKNOWN_BOX,
				std::vector<BoxKind>{BoxKind::FALSE_BOX, BoxKind::TRUE_BOX});

		if (selected_sampling_method == 0)
			lines = _sampler.sample_line_paths(sampled_boxes);
		if (selected_sampling_method == 1)
			lines = _sampler.sample_mids_and_intersections(sampled_boxes);
		if (selected_sampling_method == 2)
		{
			if (only_safe_output)
				lines = _sampler.sample_mids_and_intersections(sampled_boxes);
			else
				lines = _sampler.sample_mids(sampled_boxes);
		}
	}

	// UB & TB
	if (selected_sampling_method == 3 || 
		selected_sampling_method == 4 ||
		selected_sampling_method == 5)
	{
		std::vector<std::vector<Box> > sampled_boxes =
			_sampler.select_edges_of_boxes_with_neigh(
			BoxKind::UNKNOWN_BOX,
			std::vector<BoxKind>{BoxKind::FALSE_BOX});

		if (selected_sampling_method == 3)
			lines = _sampler.sample_line_paths(sampled_boxes);
		if (selected_sampling_method == 4)
			lines = _sampler.sample_mids_and_intersections(sampled_boxes);
		if (selected_sampling_method == 5)
		{
			if (only_safe_output)
				lines = _sampler.sample_mids_and_intersections(sampled_boxes);
			else
				lines = _sampler.sample_mids(sampled_boxes);
		}
	}

	// UB & FB
	if (selected_sampling_method == 6 || 
		selected_sampling_method == 7 || 
		selected_sampling_method == 8)
	{
		std::vector<std::vector<Box> > sampled_boxes =
			_sampler.select_edges_of_boxes_with_neigh(
			BoxKind::UNKNOWN_BOX,
			std::vector<BoxKind>{BoxKind::TRUE_BOX});

		if (selected_sampling_method == 6)
			lines = _sampler.sample_line_paths(sampled_boxes);
		if (selected_sampling_method == 7)
			lines = _sampler.sample_mids_and_intersections(sampled_boxes);
		if (selected_sampling_method == 8)
		{
			if (only_safe_output)
				lines = _sampler.sample_mids_and_intersections(sampled_boxes);
			else
				lines = _sampler.sample_mids(sampled_boxes);
		}
	}

	if (approximated)
		result_lines = get_approximation(lines);
	else
		result_lines = lines;

	if (with_hardlines)
	{
		std::vector<std::vector<Box> > sampled_hardlines =
			_sampler.select_edges_of_boxes_with_neigh(
				BoxKind::TRUE_BOX,
				std::vector<BoxKind>{BoxKind::FALSE_BOX});

		std::vector<Line> hardlines = _sampler.sample_line_paths(sampled_hardlines);
		result_lines.insert(result_lines.end(), hardlines.begin(), hardlines.end());
	}

	return result_lines;
}

/*! \brief Return borders. 
 *  Borders are constructed from output of get_lines(false, false, true) due
 *  to currently selected sampling method. 
 *  Afterwards we will try to resolve unsafe methods.
 *  If (approximated), then approximated borders will be returned as output.
 *  Approximation of borders happens after get_lines and resolving of unsafe
 *  methods.
 *  After approximation, we will add hard_edges and domain edges.
 *
 */
std::vector<Border> Visualiser::get_borders(const bool approximated) const
{
	std::vector<Border> result_borders;

	std::vector<Border> selected_borders;
	std::vector<Border> domain_edges;
	std::vector<Border> hard_edges;

	// dependant on selected_sampling_method => we will avoid unsafe BoxKind
	// ... recognition if needed
	std::vector<Line> lines = get_lines(false, false, true);

	std::vector<Border> borders;
	
	// UB tracking edge sides of edge boxes
	// UB tracking mids of edge boxes strict method
	// UB tracking mids of edge boxes loose method
	if (selected_sampling_method == 0 ||
		selected_sampling_method == 1 ||
		selected_sampling_method == 2)
	{
		selected_borders = _sampler.sample_borders(
			BoxKind::UNKNOWN_BOX,
			std::vector<BoxKind>({ BoxKind::FALSE_BOX, BoxKind::TRUE_BOX }));

		domain_edges = _sampler.sample_borders(
			BoxKind::EDGE_BOX,
			std::vector<BoxKind>({ BoxKind::FALSE_BOX, BoxKind::TRUE_BOX, BoxKind::UNKNOWN_BOX }));

		hard_edges = _sampler.sample_borders(
			BoxKind::TRUE_BOX,
			std::vector<BoxKind>({ BoxKind::FALSE_BOX }));

		borders = _setapproximer.rework_to_borders(
			lines,
			BoxKind::UNKNOWN_BOX,
			selected_borders,
			domain_edges,
			_sampler.get_domain());
	} 

	// UB & TB tracking edge sides of edge boxes
	// UB & TB tracking mids of edge boxes strict method
	// UB & TB tracking mids of edge boxes loose method
	if (selected_sampling_method == 3 ||
		selected_sampling_method == 4 ||
		selected_sampling_method == 5)
	{
		selected_borders = _sampler.sample_borders(
			BoxKind::UNKNOWN_BOX,
			std::vector<BoxKind>({ BoxKind::FALSE_BOX }));
		for (auto& sb : selected_borders)
		{
			if (sb.get_fst() == BoxKind::UNKNOWN_BOX)
				sb.set_fst() = BoxKind::TRUE_BOX;
			if (sb.get_snd() == BoxKind::UNKNOWN_BOX)
				sb.set_snd() = BoxKind::TRUE_BOX;
		}

		domain_edges = _sampler.sample_borders(
			BoxKind::EDGE_BOX,
			std::vector<BoxKind>({ BoxKind::FALSE_BOX, BoxKind::TRUE_BOX, BoxKind::UNKNOWN_BOX }));
		for (auto& de : domain_edges)
		{
			if (de.get_fst() == BoxKind::UNKNOWN_BOX)
				de.set_fst() = BoxKind::TRUE_BOX;
			if (de.get_snd() == BoxKind::UNKNOWN_BOX)
				de.set_snd() = BoxKind::TRUE_BOX;
		}

		hard_edges = _sampler.sample_borders(
			BoxKind::TRUE_BOX,
			std::vector<BoxKind>({ BoxKind::FALSE_BOX }));

		borders = _setapproximer.rework_to_borders(
			lines,
			BoxKind::TRUE_BOX,
			selected_borders,
			domain_edges,
			_sampler.get_domain());
	}
		
	// UB & FB tracking edge sides of edge boxes
	// UB & FB tracking mids of edge boxes strict method
	// UB & FB tracking mids of edge boxes loose method
	if (selected_sampling_method == 6 ||
		selected_sampling_method == 7 ||
		selected_sampling_method == 8)
	{
		selected_borders = _sampler.sample_borders(
			BoxKind::UNKNOWN_BOX,
			std::vector<BoxKind>({ BoxKind::TRUE_BOX }));
		for (auto& sb : selected_borders)
		{
			if (sb.get_fst() == BoxKind::UNKNOWN_BOX)
				sb.set_fst() = BoxKind::FALSE_BOX;
			if (sb.get_snd() == BoxKind::UNKNOWN_BOX)
				sb.set_snd() = BoxKind::FALSE_BOX;
		}

		domain_edges = _sampler.sample_borders(
			BoxKind::EDGE_BOX,
			std::vector<BoxKind>({ BoxKind::FALSE_BOX, BoxKind::TRUE_BOX, BoxKind::UNKNOWN_BOX }));
		for (auto& de : domain_edges)
		{
			if (de.get_fst() == BoxKind::UNKNOWN_BOX)
				de.set_fst() = BoxKind::FALSE_BOX;
			if (de.get_snd() == BoxKind::UNKNOWN_BOX)
				de.set_snd() = BoxKind::FALSE_BOX;
		}

		hard_edges = _sampler.sample_borders(
			BoxKind::TRUE_BOX,
			std::vector<BoxKind>({ BoxKind::FALSE_BOX }));

		borders = _setapproximer.rework_to_borders(
			lines,
			BoxKind::UNKNOWN_BOX,
			selected_borders,
			domain_edges,
			_sampler.get_domain());
	}

	// if we had unsafe sampling, we will try to resolve it here
	// loose method
	if (selected_sampling_method == 2 || 
		selected_sampling_method == 5 ||
		selected_sampling_method == 8)
	{
		std::vector<Border> reworked_borders;
		reworked_borders.reserve(borders.size());

		std::vector<Line> unsafe_lines = get_lines(false, false);
		std::set<Point, PointComparer> all_points;
		for (auto& ul : unsafe_lines)
		{
			for (auto& p : ul)
				all_points.insert(p);
		}

		for (auto& b : borders)
		{
			const Line& ol = b.get_path();
			Line rl;
			rl.push_back(ol[0]);
			for (std::size_t p = 1; p < ol.size() - 1; ++p)
			{
				auto ptr = all_points.find(ol[p]);
				if (ptr != all_points.end())
					rl.push_back(ol[p]);
			}
			rl.push_back(ol[ol.size() - 1]);

			reworked_borders.emplace_back(
				rl,
				b.get_fst(),
				b.get_snd());
		}

		borders = reworked_borders;
	}

	if (approximated)
	{
		for (auto& b : borders)
		{
			result_borders.emplace_back(
				get_approximation(b.get_path()),
				b.get_fst(),
				b.get_snd());
		}
	}
	// not approximated
	else
	{
		result_borders.insert(
			result_borders.end(),
			borders.begin(),
			borders.end());
	}
	
	// we will add domain_edges to borders
	for (auto& de : domain_edges)
	{
		Line rl = _setapproximer.add_mids_to_line(de.get_path());
		result_borders.emplace_back(
			rl,
			de.get_fst(),
			de.get_snd());
	}

	// we will add hard_edges to borders
	for (auto& he : hard_edges)
	{
		result_borders.push_back(he);
	}

	return result_borders;
}

/*! \brief Return regions. 
 *  Regions are constructed from output of get_borders(approximated).
 *
 */
std::vector<PBRegion> Visualiser::get_regions(const bool approximated) const
{
	std::vector<PBRegion> regions;
	// if we will get approximated borders we will make approximated regions
	std::vector<Border> borders = get_borders(approximated);
	regions = _setapproximer.rework_to_regions(borders);
	return regions;
}

/*
 ******************************************************************************
 ******************************** DRAWING SOLUTIONS ***************************
 ********************************** help functions ****************************
 ******************************************************************************
 */

/*! \brief Draws edges of boxes using color_box_edges.
 *
 */
void Visualiser::draw_boxes_edges()
{
	DataSetItemVector ub = _dataset.get_specific_boxes(BoxKind::UNKNOWN_BOX);
	DataSetItemVector fb = _dataset.get_specific_boxes(BoxKind::FALSE_BOX);
	DataSetItemVector tb = _dataset.get_specific_boxes(BoxKind::TRUE_BOX);

	_painter.draw_box_edges(ub, color_box_edges, false);
	_painter.draw_box_edges(fb, color_box_edges, false);
	_painter.draw_box_edges(tb, color_box_edges, false);
}

/*! \brief Method for deciding of color for UNKNOWN BoxKinds due to selected
 *  approximation fill option.
 *
 */
const Color& Visualiser::decide_u_color()
{
	if (selected_approximation_fill == approx_option::MAXIMALISM_AP)
		return color_true;
	else
	if (selected_approximation_fill == approx_option::MINIMALISM_AP)
		return color_false;
	
	return color_unknown;
}

/*! \brief Draws unknown boxes with color gained from method decide_u_color().
 *
 */
void Visualiser::draw_u_boxes()
{
	DataSetItemVector ub = _dataset.get_specific_boxes(BoxKind::UNKNOWN_BOX);

	_painter.draw_box_fill(ub, decide_u_color(), true);
}

/*! \brief Draws true boxes using color_false and true boxes using color_false.
 *
 */
void Visualiser::draw_tf_boxes()
{
	DataSetItemVector fb = _dataset.get_specific_boxes(BoxKind::FALSE_BOX);
	DataSetItemVector tb = _dataset.get_specific_boxes(BoxKind::TRUE_BOX);

	_painter.draw_box_fill(fb, color_false, true);
	_painter.draw_box_fill(tb, color_true, true);
}

/*! \brief Method that tries to hide approximated lines in visualisation.
 *
 */
void Visualiser::remove_approximated_lines()
{
	for (int x = 0; x < (int)_painter.get_width(); ++x)
	{
		for (int y = 0; y < (int)_painter.get_height(); ++y)
		{
			if (_painter.check_if_pixel_is_color(
				(std::size_t)x,
				(std::size_t)y,
				0,
				color_lines))
			{
				const bool
					lx = (x - 1 >= 0),
					ux = (x + 1 < (int)_painter.get_width()),
					ly = (y - 1 >= 0),
					uy = (y + 1 < (int)_painter.get_height());

				int
					uc = 0,
					fc = 0,
					tc = 0;

				if (lx)
				{
					if (_painter.check_if_pixel_is_color(
						(std::size_t)(x - 1),
						(std::size_t)y,
						0,
						color_true))
						++tc;
					else
					if (_painter.check_if_pixel_is_color(
						(std::size_t)(x - 1),
						(std::size_t)y,
						0,
						color_false))
						++fc;
					else 
					if (_painter.check_if_pixel_is_color(
						(std::size_t)(x - 1),
						(std::size_t)y,
						0,
						color_unknown))
						++uc;
				}

				if (ux)
				{
					if (_painter.check_if_pixel_is_color(
						(std::size_t)(x + 1),
						(std::size_t)y,
						0,
						color_true))
						++tc;
					else
					if (_painter.check_if_pixel_is_color(
						(std::size_t)(x + 1),
						(std::size_t)y,
						0,
						color_false))
						++fc;
					else
					if (_painter.check_if_pixel_is_color(
						(std::size_t)(x + 1),
						(std::size_t)y,
						0,
						color_unknown))
						++uc;
				}

				if (ly)
				{
					if (_painter.check_if_pixel_is_color(
						(std::size_t)x,
						(std::size_t)(y - 1),
						0,
						color_true))
						++tc;
					else
					if (_painter.check_if_pixel_is_color(
						(std::size_t)x,
						(std::size_t)(y - 1),
						0,
						color_false))
						++fc;
					else
					if (_painter.check_if_pixel_is_color(
						(std::size_t)x,
						(std::size_t)(y - 1),
						0,
						color_unknown))
						++uc;
				}

				if (uy)
				{
					if (_painter.check_if_pixel_is_color(
						(std::size_t)x,
						(std::size_t)(y + 1),
						0,
						color_true))
						++tc;
					else
					if (_painter.check_if_pixel_is_color(
						(std::size_t)x,
						(std::size_t)(y + 1),
						0,
						color_false))
						++fc;
					else
					if (_painter.check_if_pixel_is_color(
						(std::size_t)x,
						(std::size_t)(y + 1),
						0,
						color_unknown))
						++uc;
				}

				if (tc >= uc && tc >= fc)
				{
					_painter.draw_pixel(x, y, color_true, false);
					continue;
				}

				if (fc >= uc && fc >= tc)
				{
					_painter.draw_pixel(x, y, color_false, false);
					continue;
				}

				if (uc >= tc && uc >= fc)
				{
					_painter.draw_pixel(x, y, decide_u_color(), false);
					continue;
				}

			} // color of pixel is specific for approximation lines

		} // for y

	} // for x
}

/*! \brief Selects only relevant parts of line for visualisation of the 
 *  solution.
 *
 */
Line Visualiser::select_relevant_for_draw(const Line& line) const
{
	if (line.size() < 2)
		return line;

	// better to use some way -> size_of_pixel

	Line result;
	result.reserve(line.size());

	std::pair<int, int> prev = _painter.get_pixel_with_coordinates(line[0]);
	std::pair<int, int> cur;

	result.push_back(line[0]);
	for (std::size_t i = 1; i < line.size(); ++i)
	{
		cur = _painter.get_pixel_with_coordinates(line[0]);
		if (cur != prev)
			result.push_back(line[i]);
		prev = cur;
	}

	return line;
}

/*
 ******************************************************************************
 ******************************** DRAWING SOLUTIONS ***************************
 **************************** due to visualisation type ***********************
 ******************************************************************************
 */

/*! \brief Draws true and false boxes using color_true and color_false. 
 *  Unknown boxes will be drawn by color decided by decide_u_color().
 *
 */
void Visualiser::draw_original()
{
	draw_tf_boxes();
	draw_u_boxes();
}

/*! \brief Draws approximating lines of solution using color_lines. 
 *  Afterward true and false boxes are drawn.
 *  Unknown boxes will try to be filled due to colors of neighbours.
 *
 */
void Visualiser::draw_lines()
{
	std::vector<Line> lines = get_lines(true, true);

	_painter.draw_line(lines, color_lines, false);

	draw_tf_boxes();

	for (int x = 0; x < (int)_painter.get_width(); ++x)
	{
		for (int y = 0; y < (int)_painter.get_height(); ++y)
		{
			if (_painter.check_if_pixel_is_base(
				(std::size_t)x, 
				(std::size_t)y, 
				0))
			{
				if (x - 1 >= 0)
				{
					if (!_painter.check_if_pixel_is_color(
						(std::size_t)(x - 1),
						(std::size_t)y,
						0,
						color_lines) &&
						!_painter.check_if_pixel_is_base(
						(std::size_t)(x - 1),
						(std::size_t)y,
						0))
					{
						_painter.draw_fill_from_pixel(
							x, y,
							_painter.get_color_of_pixel(x - 1, y));
						continue;
					}
				}

				if (x + 1 < (int)_painter.get_width())
				{
					if (!_painter.check_if_pixel_is_color(
						(std::size_t)(x + 1),
						(std::size_t)y,
						0,
						color_lines) &&
						!_painter.check_if_pixel_is_base(
						(std::size_t)(x + 1),
						(std::size_t)y,
						0))
					{
						_painter.draw_fill_from_pixel(
							(std::size_t)x, 
							(std::size_t)y,
							_painter.get_color_of_pixel((std::size_t)(x + 1), (std::size_t)y));
						continue;
					}
				}
					
				if (y - 1 >= 0)
				{
					if (!_painter.check_if_pixel_is_color(
						(std::size_t)x,
						(std::size_t)(y - 1),
						0,
						color_lines) &&
						!_painter.check_if_pixel_is_base(
						(std::size_t)x,
						(std::size_t)(y - 1),
						0))
					{
						_painter.draw_fill_from_pixel(
							(std::size_t)x, 
							(std::size_t)y,
							_painter.get_color_of_pixel((std::size_t)x, (std::size_t)(y - 1)));
						continue;
					}
				}
					
				if (y + 1 < (int)_painter.get_height())
				{
					if (!_painter.check_if_pixel_is_color(
						(std::size_t)x,
						(std::size_t)(y + 1),
						0,
						color_lines) &&
						!_painter.check_if_pixel_is_base(
						(std::size_t)x,
						(std::size_t)(y + 1),
						0))
					{
						_painter.draw_fill_from_pixel(
							(std::size_t)x, 
							(std::size_t)y,
							_painter.get_color_of_pixel((std::size_t)x, (std::size_t)(y + 1)));
						continue;
					}
				}
			}

		} // for y

	} // for x

	for (int x = 0; x < (int)_painter.get_width(); ++x)
	{
		for (int y = 0; y < (int)_painter.get_height(); ++y)
		{
			if (_painter.check_if_pixel_is_base(
				(std::size_t)x,
				(std::size_t)y,
				0))
			{
				_painter.draw_fill_from_pixel(
					(std::size_t)x,
					(std::size_t)y,
					decide_u_color());
			}

		} // for y

	} // for x

}

/*! \brief Draws approximating lines of solution using color_lines. 
 *  If true and false boxes changes are denied, then true and false
 *  boxes will be drawn.
 *  Afterward points are being filled due to closest border + fill.
 *  If exact filling is enabled, then each point is filled individually.
 *
 */
void Visualiser::draw_borders()
{
	std::vector<Border> borders = get_borders(true);

	for (auto& b : borders)
	{
		_painter.draw_line(b.get_path(), color_lines, true);
	}

	// draw true and false boxes, so we can't change them
	if (tf_changes_denied)
	{
		draw_tf_boxes();
	}

	if (exact_filling)
	{
		for (std::size_t x = 0; x < _painter.get_width(); ++x)
		{
			for (std::size_t y = 0; y < _painter.get_height(); ++y)
			{
				if (_painter.check_if_pixel_is_base(x, y, 0))
				{
					Point point = _painter.get_coordinates_of_pixel(x, y);

					BoxKind bk = _setapproximer.suggest_boxkind(point, borders);

					switch (bk)
					{
					case BoxKind::UNDEFINED:
						// warning
						_painter.draw_point(point.get_x(), point.get_y(), color_box_edges);
						break;
					case BoxKind::TRUE_BOX:
						_painter.draw_point(point.get_x(), point.get_y(), color_true);
						break;
					case BoxKind::FALSE_BOX:
						_painter.draw_point(point.get_x(), point.get_y(), color_false);
						break;
					case BoxKind::UNKNOWN_BOX:
						_painter.draw_point(point.get_x(), point.get_y(), decide_u_color());
						break;
					case BoxKind::EDGE_BOX:
						// warning
						_painter.draw_point(point.get_x(), point.get_y(), color_box_edges);
						break;
					default:
						// warning
						break;
					}
				}
			}
		}
	}
	// not exact filling, we will make 2 step filling
	else
	{
		// first step -> only true and false
		for (std::size_t x = 0; x < _painter.get_width(); ++x)
		{
			for (std::size_t y = 0; y < _painter.get_height(); ++y)
			{
				if (_painter.check_if_pixel_is_base(x, y, 0))
				{
					Point point = _painter.get_coordinates_of_pixel(x, y);

					BoxKind bk = _setapproximer.suggest_boxkind(point, borders);

					// we maybe should check, if it is safe to use suggestion!

					switch (bk)
					{
					case BoxKind::TRUE_BOX:
						_painter.draw_fill_from_pixel(x, y, color_true);
						break;
					case BoxKind::FALSE_BOX:
						_painter.draw_fill_from_pixel(x, y, color_false);
						break;
					default:
						break;
					}
				}
			}
		}

		// second step -> all other
		for (std::size_t x = 0; x < _painter.get_width(); ++x)
		{
			for (std::size_t y = 0; y < _painter.get_height(); ++y)
			{
				if (_painter.check_if_pixel_is_base(x, y, 0))
				{
					Point point = _painter.get_coordinates_of_pixel(x, y);

					BoxKind bk = _setapproximer.suggest_boxkind(point, borders);

					// we maybe should check, if it is safe to use suggestion!

					switch (bk)
					{
					case BoxKind::UNDEFINED:
						// warning
						_painter.draw_fill_from_pixel(x, y, color_box_edges);
						break;
					case BoxKind::UNKNOWN_BOX:
						//_painter.draw_point(point.get_x(), point.get_y(), decide_u_color());
						_painter.draw_fill_from_pixel(x, y, decide_u_color());
						break;
					case BoxKind::EDGE_BOX:
						// warning
						_painter.draw_fill_from_pixel(x, y, color_box_edges);
						break;
					default:
						// warning
						break;
					}
				}
			}
		}
	}
}

/*! \brief Draws approximating lines of solution using color_lines. 
 *  If true and false boxes changes are denied, then true and false
 *  boxes will be drawn.
 *  Afterward points are being filled due first found region + fill.
 *  If exact filling is enabled, then each point is filled individually.
 *
 */
void Visualiser::draw_regions()
{
	std::vector<PBRegion> regions = get_regions(true);

	for (auto& r : regions)
	{
		std::vector<Line> drawed_lines_of_region(r.get_polygons());
		for (auto& l : drawed_lines_of_region)
		{
			if (l[0] != l[l.size() - 1])
				l.push_back(l[0]);
		}

		_painter.draw_line(drawed_lines_of_region, color_lines, true);
	}

	// draw true and false boxes, so we can't change them
	if (tf_changes_denied)
	{
		draw_tf_boxes();
	}

	if (exact_filling)
	{
		for (std::size_t x = 0; x < _painter.get_width(); ++x)
		{
			for (std::size_t y = 0; y < _painter.get_height(); ++y)
			{
				if (_painter.check_if_pixel_is_base(x, y, 0))
				{
					Point point = _painter.get_coordinates_of_pixel(x, y);

					BoxKind bk = FindBoxKind(point, regions);

					// we maybe should check, if it is safe to use find suggestion!

					switch (bk)
					{
					case BoxKind::UNDEFINED:
						// warning
						_painter.draw_point(point.get_x(), point.get_y(), color_box_edges);
						break;
					case BoxKind::TRUE_BOX:
						_painter.draw_point(point.get_x(), point.get_y(), color_true);
						break;
					case BoxKind::FALSE_BOX:
						_painter.draw_point(point.get_x(), point.get_y(), color_false);
						break;
					case BoxKind::UNKNOWN_BOX:
						_painter.draw_point(point.get_x(), point.get_y(), decide_u_color());
						//_painter.draw_fill_from_pixel(x, y, decide_u_color());
						break;
					case BoxKind::EDGE_BOX:
						// warning
						_painter.draw_point(point.get_x(), point.get_y(), color_box_edges);
						break;
					default:
						// warning
						break;
					}
				}
			}
		}
	}
	else
	{
		for (std::size_t x = 0; x < _painter.get_width(); ++x)
		{
			for (std::size_t y = 0; y < _painter.get_height(); ++y)
			{
				if (_painter.check_if_pixel_is_base(x, y, 0))
				{
					Point point = _painter.get_coordinates_of_pixel(x, y);

					BoxKind bk = FindBoxKind(point, regions);

					// we maybe should check, if it is safe to use find suggestion!

					switch (bk)
					{
					case BoxKind::UNDEFINED:
						// warning
						_painter.draw_fill_from_pixel(x, y, color_box_edges);
						break;
					case BoxKind::TRUE_BOX:
						_painter.draw_fill_from_pixel(x, y, color_true);
						break;
					case BoxKind::FALSE_BOX:
						_painter.draw_fill_from_pixel(x, y, color_false);
						break;
					case BoxKind::UNKNOWN_BOX:
						//_painter.draw_point(point.get_x(), point.get_y(), decide_u_color());
						_painter.draw_fill_from_pixel(x, y, decide_u_color());
						break;
					case BoxKind::EDGE_BOX:
						// warning
						_painter.draw_fill_from_pixel(x, y, color_box_edges);
						break;
					default:
						// warning
						break;
					}
				}
			}
		}
	}
}

/*
 ******************************************************************************
 ******************************* ZOOMING AND RESIZING *************************
 ******************************************************************************
 */

/*! \brief This method will resize visualisation and immedeatelly adjusts 
 *  tolerance.
 *
 */
void Visualiser::resize(
	const std::size_t x,
	const std::size_t y)
{
	_painter.resize(x, y);
	adjust_tolerance();
}

/*! \brief This method will zoom into certain interval of visualisation 
 *  and immedeatelly adjusts tolerance.
 *
 */
void Visualiser::zoom(
	const int sx,
	const int ex,
	const int sy,
	const int ey)
{
	_painter.zoom(sx, ex, sy, ey);
	adjust_tolerance();
}

/*! \brief This method will reset zoom to the whole domain space and 
 *  immedeatelly adjusts tolerance.
 *
 */
void Visualiser::reset_zoom()
{
	_painter.reset_zoom();
	adjust_tolerance();
}

/*
 ******************************************************************************
 ******************************** GETTING SOLUTIONS ***************************
 ******************************************************************************
 */

/*! \brief Returns solution due to selected settings / options.
 *
 */
CImg<unsigned char> Visualiser::get_visualisation()
{
	_painter.reset_image(true);

	// original
	if (selected_visualisation_type == 0)
	{
		draw_original();
	}

	// lines
	if (selected_visualisation_type == 1)
	{
		draw_lines();
	}

	// borders
	if (selected_visualisation_type == 2)
	{
		draw_borders();
	}

	// regions
	if (selected_visualisation_type == 3)
	{
		draw_regions();
	}

	// remove lines
	if (! approximated_lines_shown)
	{
		remove_approximated_lines();
	}

	// edges of boxes
	if (boxes_edges_shown)
	{
		draw_boxes_edges();
	}

	return _painter.get_image();
}

