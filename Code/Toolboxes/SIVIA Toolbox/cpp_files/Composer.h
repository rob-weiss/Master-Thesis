// TO DO! prerobit show_settings aby sa vzdy nieco zobrazilo
// TO DO! zaistit aby pri ukladani ziaden iny subor nepremazalo
// TO DO! zredukovat tolke update image a podobne veci
// TO DO! dorobit klavesu na vyplutie informacii

#ifndef _COMPOSER_HPP
#define _COMPOSER_HPP

#include <utility>
#include <vector>

#include "CImg.h"
#include "MatlabLayer.h"
#include "NotAllowedOperationException.h"
#include "Painter.h"
#include "Visualiser.h"

using namespace cimg_library;

class Composer
{

	enum class DIRECTION_MOVE { DOWN, UP, LEFT, RIGHT };

/*
 ******************************************************************************
 ********************************** CONSTRUCTORS ******************************
 ******************************************************************************
 */

public:
	Composer(const std::size_t visualiser_count);

private:
	Composer(const Composer& c) = delete;

	Composer(Composer&& c) = delete;

/*
 ******************************************************************************
 ************************************ OPERATORS *******************************
 ******************************************************************************
 */

private:
	Composer operator= (const Composer& c) = delete;

	Composer operator= (Composer&& c) = delete;

/*
 ******************************************************************************
 ************************************ RAW DATA ********************************
 ******************************************************************************
 */

protected:
	// MAXIMUM ALLOWED NUMBER OF VISUALISERS
	std::size_t
		max_size_of_viss;

	// NUMBER OF PIXELS ON BORDER OF EACH VISUALISATION IN COMPOSED IMAGE
	std::size_t 
		border_size = 2;

	// DEFAULT SIZES
	std::size_t
		base_size_of_x,
		base_size_of_y;

	// CURRENT SIZES
	std::size_t
		size_of_x,
		size_of_y;

	// STARTING POINT OF VISUALISATIONS OF SOLUTIONS IN COMPOSED IMAGE
	std::vector<int> starting_x;
	std::vector<int> starting_y;

	// VISUALISATION RESULTS
	std::vector<Visualiser> viss;
	std::vector<CImg<unsigned char> > solutions;
	std::vector<CImg<unsigned char> > shown;

	// COMPOSED IMAGE AND DISPLAY CONTAINING COMPOSED IMAGE
	CImg<unsigned char> img;
	CImgDisplay display;

/*
 ******************************************************************************
 ********************* COORDINATES AND SELECTION OF VISUALISER ****************
 ******************************************************************************
 */

protected: 
	int which_visualiser(
		const int x,
		const int y) const;

	std::pair<int, int> which_point_of_picture(
		const int x,
		const int y,
		const int which_vis) const;

/*
 ******************************************************************************
 ************************************* ZOOMING ********************************
 ******************************************************************************
 */

protected:
	std::pair<std::pair<int, int>, std::pair<int, int> > gain_possible_selection(
		const int fst_x,
		const int fst_y,
		const int snd_x,
		const int snd_y);

	void zoom(
		int which_vis,
		int sx,
		int sy,
		int ex,
		int ey);

	void move_zoom(
		const DIRECTION_MOVE direction,
		const std::size_t cur_vis,
		const double move_constant = 0.25);

	// not done yet
	void resize(
		const std::size_t width,
		const std::size_t height);

/*
 ******************************************************************************
 *************************** ADDITIONAL INFORMATIONS INTO IMG *****************
 ******************************************************************************
 */

protected:
	void change_color_of_border(
		const int which_vis,
		const Color& color);

	void show_help_menu(const int which_vis);

	int show_visualisation_types(const int which_vis);

	int show_sampling_methods(const int which_vis);

	int show_approximating_methods(const int which_vis);

	int show_settings(
		const int which_vis,
		const available_settings& settings,
		const bool with_storno_option = false);

	void show_info_about_recomputing(const int which_vis);

	void clear_selection(
		const int start_x,
		const int start_y,
		const int end_x,
		const int end_y);

	void draw_selection(
		const int start_x,
		const int start_y,
		const int end_x,
		const int end_y,
		const Color& color);

	void clear_all_information(
		const int which_vis = 0,
		const std::size_t font_size = 13);

	void clear_information(
		const int which_vis = 0,
		const std::size_t font_size = 13,
		const bool up = true);

	void put_information(
		const std::string& str,
		const Color& color,
		const int which_vis = 0,
		const std::size_t font_size = 13,
		const bool up = true);

	void clear_coordinates_info(
		const int which_vis,
		const std::size_t font_size,
		const bool coordinates_up);

	void draw_coordinates_info(
		const int mx,
		const int my,
		bool& coordinates_up,
		const std::size_t font_size,
		const Color& color);

	void run_saving_dialog(
		const CImg<unsigned char>& saved_img,
		const Color& info_color);

	void update_all_solutions();

	void update_solution(std::size_t which_solution);

	void update_all_shown();

	void update_shown(std::size_t which_solution);

	void compose_image();

	void update_image(std::size_t which_solution);

	void update_image(
		const int which_vis,
		const std::size_t sx,
		const std::size_t ex,
		const std::size_t sy,
		const std::size_t ey);

	void update_image(
		const int which_vis,
		CImg<unsigned char>& o);

	void update(
		CImg<unsigned char>& into,
		const CImg<unsigned char>& from,
		const std::size_t into_sx,
		const std::size_t into_sy,
		const std::size_t into_ex,
		const std::size_t into_ey,
		const std::size_t from_sx,
		const std::size_t from_sy,
		const std::size_t from_ex,
		const std::size_t from_ey) const;

	void dispatch();

public:
	void visualise(
		const std::size_t width,
		const std::size_t height);

	void add_visualiser(const std::vector<std::string>& file_names);

	void add_visualiser(
		const std::string& t_file,
		const std::string& u_file,
		const std::string& f_file);

	void add_visualiser(
		const std::vector<std::vector<DataType> >& vectors);

	void add_visualiser(
		const std::vector<Box>& t_boxes,
		const std::vector<Box>& u_boxes,
		const std::vector<Box>& f_boxes);

};

#endif