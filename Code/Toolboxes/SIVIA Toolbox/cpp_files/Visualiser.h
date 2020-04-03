// TO DO! urobit orezanie ciar navzajom!!!
// TO DO! funguje to fajn, ale okraje approx line vlavo a dole nezobrazuje -> vyriesit!
// TO DO! vyriesit u paraboly problem => tie s edge boxes lajny parsovat vzdy aj so stredmi!
// TO DO! select_relevant_for_draw

#ifndef _VISUALISER_HPP
#define _VISUALISER_HPP

#include <utility>
#include <vector>
#include <string>

#include "BoxProcessor.h"
#include "CImg.h"
#include "DataSet.h"
#include "Painter.h"
#include "Sampler.h"
#include "SetApproximer.h"

typedef std::vector<std::pair<std::size_t, std::string> > available_settings;

class Visualiser
{

	enum class approx_option { ORIGINAL_AP, MINIMALISM_AP, MAXIMALISM_AP };

/*
 ******************************************************************************
 ************************************ RAW DATA ********************************
 ******************************************************************************
 */

protected:
	const BoxProcessor _boxprocessor;
	const DataSet _dataset;
	Sampler _sampler;
	SetApproximer _setapproximer;
	Painter _painter;

	// AVAILABLE SETTINGS
	bool settings_initialized = false;
	available_settings visualisation_types;
	available_settings sampling_methods;
	available_settings approximating_methods;
	std::size_t selected_visualisation_type = 0;
	std::size_t selected_sampling_method;
	std::size_t selected_approximating_method;

	// COLORS FOR BOXKINDS
	Color
		color_unknown,
		color_true,
		color_false,
		color_box_edges,
		color_lines;

	// DISTANCE TOLERANCE BETWEEN POINTS
	double
		x_tolerance,
		y_tolerance;

	// SETTINGS FOR POINT CLOSERING
	std::size_t point_closering_count = 2;
	std::size_t point_closering_depth = 0;

	// VISUALISATION SETTINGS
	bool
		tf_changes_denied = true,
		deep_evaluation = false,
		exact_filling = false,
		boxes_edges_shown = true,
		approximated_lines_shown = true;

	// SELECTED MIN/MAX APPROXIMATION OPTION
	approx_option
		selected_approximation_fill = approx_option::ORIGINAL_AP;

/*
 ******************************************************************************
 ********************************** CONSTRUCTORS ******************************
 ******************************************************************************
 */

protected:
	void set_basic_colors();

	void prepare_settings();

public:
	Visualiser(const std::vector<std::string>& file_names);

	Visualiser(
		const std::string& t_file,
		const std::string& u_file,
		const std::string& f_file);

	Visualiser(const std::vector<std::vector<DataType> >& vectors);

	Visualiser(
		const std::vector<Box>& t_boxes, 
		const std::vector<Box>& u_boxes,
		const std::vector<Box>& f_boxes);

private:
	//Visualiser(const Visualiser& v) = delete;

	//Visualiser(Visualiser&& v) = delete;

/*
 ******************************************************************************
 ************************************ OPERATORS *******************************
 ******************************************************************************
 */

private:
	//Visualiser operator= (const Visualiser& c) = delete;

	//Visualiser operator= (Visualiser&& c) = delete;

/*
 ******************************************************************************
 ************************* DATA ACCESS, OPTIONS, SETTINGS *********************
 ******************************************************************************
 */

public:
	std::size_t get_size_of_x() const;

	std::size_t get_size_of_y() const;

	Point get_coordinates_of_pixel(
		const int x,
		const int y) const;

	bool is_x_reverse() const;

	bool is_y_reverse() const;

	DataType get_total_min_x() const;

	DataType get_total_max_x() const;

	DataType get_total_min_y() const;

	DataType get_total_max_y() const;

	DataType get_zoomed_min_x() const;

	DataType get_zoomed_max_x() const;

	DataType get_zoomed_min_y() const;

	DataType get_zoomed_max_y() const;

	DataType & set_zoomed_min_x();

	DataType & set_zoomed_max_x();

	DataType & set_zoomed_min_y();

	DataType & set_zoomed_max_y();

	void adjust_tolerance();

	void adjust_tolerance(
		const double x_t,
		const double y_t);

	void change_approximation_fill();

	std::string get_approximation_fill() const;

	void update_zoom();

	void allow_tf_changes();

	void deny_tf_changes();

	bool tf_changes_being_denied() const;

	void show_boxes_edges();

	void hide_boxes_edges();

	bool boxes_edges_being_shown() const;

	void show_approximated_lines();

	void hide_approximated_lines();

	bool approximated_lines_being_shown() const;

	void enable_deep_evaluation();

	void disable_deep_evaluation();

	bool deep_evaluation_allowed() const;

	void enable_exact_filling();

	void disable_exact_filling();

	bool exact_filling_allowed() const;

	void set_point_closering_count(std::size_t pc);

	std::size_t get_point_closering_count() const;

	void set_point_closering_depth(std::size_t pc);

	std::size_t get_point_closering_depth() const;

	void set_colors(
		const Color& color_for_unknown_boxes,
		const Color& color_for_true_boxes,
		const Color& color_for_false_boxes,
		const Color& color_for_edges_of_boxes,
		const Color& color_for_lines);

/*
 ******************************************************************************
 ************************************ SETTINGS ********************************
 ******************************************************************************
 */

protected:
	void initialize_settings();

	void add_setting(
		available_settings& settings, 
		const std::string new_setting) const;

	void set_visualisation_types();

	void set_sampling_methods();

	void set_approximating_methods();

public:
	const available_settings& get_visualisation_types() const;

	const available_settings& get_sampling_methods() const;

	const available_settings& get_approximating_methods() const;

	void set_visualisation_type(const std::size_t method_id);

	void set_sampling_method(const std::size_t method_id);

	void set_approximating_method(const std::size_t method_id);

/*
 ******************************************************************************
 ***************************** GAINING APPROXIMATIONS *************************
 ******************************************************************************
 */

protected:
	Line get_approximation(const Line& line) const;

	Border get_approximation(const Border& border) const;

	std::vector<Line> get_approximation(
		const std::vector<Line>& lines) const;

	std::vector<Border> get_approximation(
		const std::vector<Border>& borders) const;

/*
 ******************************************************************************
 ******************************** GAINING SOLUTIONS ***************************
 **************************** due to visualisation type ***********************
 ******************************************************************************
 */

protected:
	std::vector<Line> get_lines(
		const bool approximated,
		const bool with_hardlines,
		const bool only_safe_output = false) const;

	std::vector<Border> get_borders(
		const bool approximated) const;

	std::vector<PBRegion> get_regions(const bool approximated) const;

/*
 ******************************************************************************
 ******************************** DRAWING SOLUTIONS ***************************
 ********************************** help functions ****************************
 ******************************************************************************
 */

protected:
	void draw_boxes_edges();

	const Color& decide_u_color();

	void draw_u_boxes();
	
	void draw_tf_boxes();

	void remove_approximated_lines();

	Line select_relevant_for_draw(const Line& line) const;

/*
 ******************************************************************************
 ******************************** DRAWING SOLUTIONS ***************************
 **************************** due to visualisation type ***********************
 ******************************************************************************
 */

protected:
	void draw_original();

	void draw_lines();

	void draw_borders();

	void draw_regions();

/*
 ******************************************************************************
 ******************************* ZOOMING AND RESIZING *************************
 ******************************************************************************
 */

public:
	void resize(
		const std::size_t x,
		const std::size_t y);

	void zoom(
		const int sx,
		const int ex,
		const int sy,
		const int ey);

	void reset_zoom();

/*
 ******************************************************************************
 ******************************** GETTING SOLUTIONS ***************************
 ******************************************************************************
 */

public:
	CImg<unsigned char> get_visualisation();

};



#endif

