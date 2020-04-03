// TO DO !!! make better checking for zoom boundaries!

#ifndef _PAINTER_HPP
#define _PAINTER_HPP

#include <queue>

#include "DataSet.h"
#include "CImg.h"
#include "Color.h"
#include "DataSetItem.h"
#include "Line.h"
#include "Math.h"
#include "NotAllowedOperationException.h"
#include "Point.h"

using namespace cimg_library;

class Painter
{

/*
 ******************************************************************************
 ************************************ RAW DATA ********************************
 ******************************************************************************
 */

protected:
	// IMAGE
	CImg<unsigned char> img;

	// RESOLUTION SIZES
	std::size_t
		size_of_x,
		size_of_y;

	// COORDINATES IN REVERSE ORDER
	bool 
		x_rev,
		y_rev;

	// DEFAULT EXTREMES/ZOOM
	DataType
		t_min_x,
		t_max_x,
		t_min_y,
		t_max_y;

	// CURRENT EXTREMES/ZOOM
	DataType
		min_x,
		max_x,
		min_y,
		max_y;

	// CURRENT EXTREMES/ZOOM AS BOX
	Box
		zoomed_place;
	
	// SPECIAL VALUE IN RED COMPONENT OF COLOR SPECIFING NOT FILLED PIXEL
	unsigned char
		base;

/*
 ******************************************************************************
 ********************************** CONSTRUCTORS ******************************
 ******************************************************************************
 */

public:
	Painter(const DataSet& ds);

/*
 ******************************************************************************
 ********************************** DATA ACCESS *******************************
 ******************************************************************************
 */

public:
	CImg<unsigned char> get_image() const;

	const CImg<unsigned char>& lend_image() const;

	int find_base_to_colors(
		const std::vector<Color>& colors_to_be_used) const;

	int set_base_to_colors(
		const std::vector<Color>& colors_to_be_used);

	void set_base(const unsigned char c);

	unsigned char get_base();

	std::size_t get_width() const;

	std::size_t get_height() const;

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

	void update_zoom();

	Point get_coordinates_of_pixel(
		const int x,
		const int y) const;

	std::pair<int, int> get_pixel_with_coordinates(
		const DataType x,
		const DataType y) const;

	std::pair<int, int> get_pixel_with_coordinates(
		const Point& p) const;

	std::pair<double, double> get_size_of_pixel() const;

	Color get_color_of_pixel(
		std::size_t x,
		std::size_t y) const;

/*
 ******************************************************************************
 ******************************* DATA TRANSFORMATION **************************
 ******************************************************************************
 */

protected:
	int to_gif_coordinates(
		double min_coor,
		double max_coor,
		std::size_t count_of_pixels,
		double point,
		bool rev) const;

	double from_gif_coordinates(
		double min_coor,
		double max_coor,
		std::size_t count_of_pixels,
		int pixel,
		bool rev) const;

/*
 ******************************************************************************
 ******************************** HELP FUNCTIONS ******************************
 ******************************************************************************
 */

public:
	bool check_if_pixel_is_base(
		const std::size_t x,
		const std::size_t y,
		const std::size_t z) const;

	bool check_if_pixel_is_color(
		const std::size_t x,
		const std::size_t y,
		const std::size_t z,
		const Color& c) const;

	void reset_image(bool strong = false);

	void resize(std::size_t width, std::size_t height);

/*
 ******************************************************************************
 ******************************* ZOOMING FUNCTIONS ****************************
 ******************************************************************************
 */

public:
	void reset_zoom();

	void zoom(int new_min_x, int new_max_x, int new_min_y, int new_max_y);

/*
 ******************************************************************************
 ******************************* DRAWING FUNCTIONS ****************************
 ******************************************************************************
 */

protected:
	void set_pixel(
		const int x,
		const int y,
		const Color& color,
		const bool only_background = false);

	void draw_line_pixel_by_pixel(
		const DataType fst_x,
		const DataType fst_y,
		const DataType snd_x,
		const DataType snd_y,
		const Color& color,
		const bool only_background = false);

	void draw_line_pixel_by_pixel(
		const Point& fst,
		const Point& snd,
		const Color& color,
		const bool only_background = false);

	void draw_line_pixel_by_pixel(
		const Line& line,
		const Color& color,
		const bool only_background = false);

	void draw_line_pixel_by_pixel(
		const std::vector<Line>& lines,
		const Color& color,
		const bool only_background = false);

	void draw_rectangle_pixel_by_pixel(
		const DataType fst_x,
		const DataType fst_y,
		const DataType snd_x,
		const DataType snd_y,
		const Color& color,
		const bool only_background = false);

	void draw_fill_pixel_by_pixel(
		const int x,
		const int y,
		const Color& color,
		const std::size_t x_lower_bound,
		const std::size_t x_upper_bound,
		const std::size_t y_lower_bound,
		const std::size_t y_upper_bound);

	void draw_fill_pixel_by_pixel(
		const int x,
		const int y,
		const Color& color);

	void draw_fill_pixel_by_pixel(
		const Point& point,
		const Color& color);

/*
 ******************************************************************************
 ************************* PUBLIC DRAWING FUNCTIONS ***************************
 ******************************************************************************
 */

public:
	void draw_point(
		const DataType x,
		const DataType y,
		const Color& color,
		const bool only_background = false);

	void draw_point(
		const Point& point,
		const Color& color,
		const bool only_background = false);

	void draw_point(
		const std::vector<Point>& point,
		const Color& color,
		const bool only_background = false);

	void draw_pixel(
		const int x, 
		const int y, 
		const Color& color,
		const bool only_background = false);

	void draw_line(
		const DataType fst_x,
		const DataType fst_y,
		const DataType snd_x,
		const DataType snd_y,
		const Color& color,
		const bool only_background = false);

	void draw_line(
		const Point& fst,
		const Point& snd,
		const Color& color,
		const bool only_background = false);

	void draw_line(
		const Line& lines,
		const Color& color,
		const bool only_background = false);

	void draw_line(
		const std::vector<Line>& lines,
		const Color& color,
		const bool only_background = false);

	void draw_box_fill(
		const DataType b_min_x,
		const DataType b_max_x,
		const DataType b_min_y,
		const DataType b_max_y,
		const Color& color,
		const bool only_background = false);

	void draw_box_fill(
		const Box& box,
		const Color& color,
		const bool only_background = false);

	void draw_box_fill(
		const std::vector<Box>& boxes,
		const Color& color,
		const bool only_background = false);

	void draw_box_fill(
		const DataSetItem& dsi,
		const Color& color,
		const bool only_background = false);

	void draw_box_fill(
		const DataSetItemVector& dsiv,
		const Color& color,
		const bool only_background = false);

	void draw_box_edges(
		const DataType b_min_x,
		const DataType b_max_x,
		const DataType b_min_y,
		const DataType b_max_y,
		const Color& color,
		const bool only_background = false);

	void draw_box_edges(
		const Box& boxes,
		const Color& color,
		const bool only_background = false);

	void draw_box_edges(
		const std::vector<Box>& boxes,
		const Color& color,
		const bool only_background = false);

	void draw_box_edges(
		const DataSetItem& dsi,
		const Color& color,
		const bool only_background = false);

	void draw_box_edges(
		const DataSetItemVector& dsiv,
		const Color& color,
		const bool only_background = false);

	void draw_fill_from_pixel(
		const std::size_t x,
		const std::size_t y,
		const Color& color,
		const std::size_t x_lower_bound,
		const std::size_t x_upper_bound,
		const std::size_t y_lower_bound,
		const std::size_t y_upper_bound);

	void draw_fill_from_pixel(
		const std::size_t x,
		const std::size_t y,
		const Color& color);

	void draw_fill_from_coordinates(
		const DataType x,
		const DataType y,
		const Color& color,
		const DataType x_lower_bound,
		const DataType x_upper_bound,
		const DataType y_lower_bound,
		const DataType y_upper_bound);

	void draw_fill_from_coordinates(
		const DataType x,
		const DataType y,
		const Color& color);

	void draw_fill_from_coordinates(
		const Point& point,
		const Color& color,
		const DataType x_lower_bound,
		const DataType x_upper_bound,
		const DataType y_lower_bound,
		const DataType y_upper_bound);

	void draw_fill_from_coordinates(
		const Point& point,
		const Color& color);

};

#endif
