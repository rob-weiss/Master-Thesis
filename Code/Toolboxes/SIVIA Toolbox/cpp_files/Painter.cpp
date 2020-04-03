#include "Painter.h"

#include <queue>

#include "DataSet.h"
#include "CImg.h"
#include "Color.h"
#include "DataSetItem.h"
#include "Line.h"
#include "Math.h"
#include "NotAllowedOperationException.h"
#include "Point.h"

/*
 ******************************************************************************
 ********************************** CONSTRUCTORS ******************************
 ******************************************************************************
 */

/*! \brief Constructor with resolution (612,612) and base 127.
 *
 */
Painter::Painter(const DataSet& ds)
{
	size_of_x = 612;
	size_of_y = 612;
	img = CImg<unsigned char>(size_of_x, size_of_y, 1, 3, 0);
	x_rev = false;
	y_rev = true;
	if (!ds.data_ready())
	{
		throw new NotAllowedOperationException("DataSet queries are not allowed before data are ready");
	}
	t_min_x = ds.get_min_x();
	t_max_x = ds.get_max_x();
	t_min_y = ds.get_min_y();
	t_max_y = ds.get_max_y();
	min_x = t_min_x;
	max_x = t_max_x;
	min_y = t_min_y;
	max_y = t_max_y;
	base = 127;
	
	zoomed_place = Box(min_x, max_x, min_y, max_y);
	reset_image();
}

/*
 ******************************************************************************
 ********************************** DATA ACCESS *******************************
 ******************************************************************************
 */

/*! \brief Returns CImg image.
 *
 */
CImg<unsigned char> Painter::get_image() const
{
	return img;
}

/*! \brief Returns CImg image by const reference.
 *
 */
const CImg<unsigned char>& Painter::lend_image() const
{
	return img;
}

/*! \brief Function to find base automatically from colors. If unique value
 *  for base doesn't exist, -1 will be returned.
 *
 */
int Painter::find_base_to_colors(
	const std::vector<Color>& colors_to_be_used) const
{
	for (unsigned char c = 0; c < 255; ++c)
	{
		bool is_unique = true;

		for (std::size_t i = 0; i < colors_to_be_used.size(); ++i)
		if (colors_to_be_used[i].get_R() == c)
		{
			is_unique = false;
			break;
		}

		if (is_unique)
			return c;
	}
	// return -1 if there is no suitable value thus painter can't work properly
	return -1;
}

/*! \brief Function to set base automatically from colors. If unique value
 *  for base doesn't exist, -1 will be returned.
 *
 */
int Painter::set_base_to_colors(
	const std::vector<Color>& colors_to_be_used)
{
	int v = find_base_to_colors(colors_to_be_used);
	if (v != -1)
		base = (unsigned char)v;
	return v;
}

/*! \brief Set significant unique value for base of the image.
 *
 */
void Painter::set_base(const unsigned char c)
{
	base = c;
}

/*! \brief Get significant unique value for base of the image.
 *
 */
unsigned char Painter::get_base()
{
	return base;
}

/*! \brief Get width of the CImg.
 *
 */
std::size_t Painter::get_width() const
{
	return size_of_x;
}

/*! \brief Get height of the CImg.
 *
 */
std::size_t Painter::get_height() const
{
	return size_of_y;
}

/*! \brief Returns bool, if x-axis is reverse viewed in CImg.
 *
 */
bool Painter::is_x_reverse() const
{
	return x_rev;
}

/*! \brief Returns bool, if y-axis is reverse viewed in CImg.
 *
 */
bool Painter::is_y_reverse() const
{
	return y_rev;
}

/*! \brief Returns lowest x of domain.
 *
 */
DataType Painter::get_total_min_x() const
{
	return t_min_x;
}

/*! \brief Returns highest x of domain.
 *
 */
DataType Painter::get_total_max_x() const
{
	return t_max_x;
}

/*! \brief Returns lowest y of domain.
 *
 */
DataType Painter::get_total_min_y() const
{
	return t_min_y;
}

/*! \brief Returns highest y of domain.
 *
 */
DataType Painter::get_total_max_y() const
{
	return t_max_y;
}

/*! \brief Returns lower bound of x-axis of current zoom.
 *
 */
DataType Painter::get_zoomed_min_x() const
{
	return min_x;
}

/*! \brief Returns upper bound of x-axis of current zoom.
 *
 */
DataType Painter::get_zoomed_max_x() const
{
	return max_x;
}

/*! \brief Returns lower bound of y-axis of current zoom.
 *
 */
DataType Painter::get_zoomed_min_y() const
{
	return min_y;
}

/*! \brief Returns upper bound of y-axis of current zoom.
 *
 */
DataType Painter::get_zoomed_max_y() const
{
	return max_y;
}

/*! \brief Returns lower bound of x-axis of current zoom by reference.
 *
 */
DataType & Painter::set_zoomed_min_x()
{
	return min_x;
}

/*! \brief Returns upper bound of x-axis of current zoom by reference.
 *
 */
DataType & Painter::set_zoomed_max_x()
{
	return max_x;
}

/*! \brief Returns lower bound of y-axis of current zoom by reference.
 *
 */
DataType & Painter::set_zoomed_min_y()
{
	return min_y;
}

/*! \brief Returns upper bound of y-axis of current zoom by reference.
 *
 */
DataType & Painter::set_zoomed_max_y()
{
	return max_y;
}

/*! \brief Updates zoomed_place on values in min_x, max_x, min_y, max_y. Must
 *  be called after change of zoom window without using of function zoom!
 *
 */
void Painter::update_zoom()
{
	zoomed_place = Box(min_x, max_x, min_y, max_y);
}

/*! \brief Returns real coordinates of pixel x,y in CImg.
 *
 */
Point Painter::get_coordinates_of_pixel(
	const int x,
	const int y) const
{
	return Point(
		from_gif_coordinates(min_x, max_x, size_of_x, x, x_rev),
		from_gif_coordinates(min_y, max_y, size_of_y, y, y_rev));
}

/*! \brief Returns coordinates of pixel in CImg for Point p(x,y).
 *
 */
std::pair<int, int> Painter::get_pixel_with_coordinates(
	const DataType x,
	const DataType y) const
{
	return std::make_pair(
		to_gif_coordinates(min_x, max_x, size_of_x, x, x_rev),
		to_gif_coordinates(min_y, max_y, size_of_y, y, y_rev));
}

/*! \brief Returns coordinates of pixel in CImg for Point p.
 *
 */
std::pair<int, int> Painter::get_pixel_with_coordinates(
	const Point& p) const
{
	return std::make_pair(
		to_gif_coordinates(min_x, max_x, size_of_x, p.get_x(), x_rev),
		to_gif_coordinates(min_y, max_y, size_of_y, p.get_y(), y_rev));
}

/*! \brief Returns size of pixel on x-axis and size of pixel on y-axis 
 *  as a pair of doubles.
 *
 */
std::pair<double, double> Painter::get_size_of_pixel() const
{
	return std::make_pair(
		std::fabs(max_x - min_x) / double(size_of_x),
		std::fabs(max_y - min_y) / double(size_of_y));
}

/*! \brief Returns Color of the pixel (x,y).
 *
 */
Color Painter::get_color_of_pixel(
	std::size_t x,
	std::size_t y) const
{
	return Color(
		img(x, y, 0, 0),
		img(x, y, 0, 1),
		img(x, y, 0, 2));
}

/*
 ******************************************************************************
 ******************************* DATA TRANSFORMATION **************************
 ******************************************************************************
 */

/*! \brief Transforms coordinates of real point into coordinates of pixel in image.
 *
 */
int Painter::to_gif_coordinates(
	double min_coor,
	double max_coor,
	std::size_t count_of_pixels,
	double point,
	bool rev) const
{
	const double size_of_pixel = std::fabs(max_coor - min_coor) / (double)count_of_pixels;
	const double distance_to_zero = -(min_coor);

	const double double_result = (point + distance_to_zero) / size_of_pixel;
	int result = (int)std::round(double_result);

	if (rev)
	{
		int distance_to_mid = std::abs(result - (int)(count_of_pixels / 2));

		if (result > (int)(count_of_pixels / 2))
		{
			result -= 2 * distance_to_mid;
		}
		else
		{
			result += 2 * distance_to_mid;
		}
	}

	return result;
}

/*! \brief Transforms coordinates of pixel in image into coordinates of real point.
 *
 */
double Painter::from_gif_coordinates(
	double min_coor, 
	double max_coor,
	std::size_t count_of_pixels,
	int pixel,
	bool rev)const
{
	const double size_of_pixel = std::fabs(max_coor - min_coor) / (double)count_of_pixels;
	const double distance_to_zero = -(min_coor);

	if (rev)
	{
		int distance_to_mid = std::abs(pixel - (int)(count_of_pixels / 2));

		if (pixel > (int)(count_of_pixels / 2))
		{
			pixel -= (int)(2 * distance_to_mid);
		}
		else
		{
			pixel += (int)(2 * distance_to_mid);
		}
	}

	const double result = (((double)pixel * size_of_pixel) - distance_to_zero);

	return result;
}

/*
 ******************************************************************************
 ******************************** HELP FUNCTIONS ******************************
 ******************************************************************************
 */

/*! \brief Returns true, if pixel of image on coordinates x,y,z is base.
 *
 */
bool Painter::check_if_pixel_is_base(
	const std::size_t x,
	const std::size_t y,
	const std::size_t z) const
{
	if (img(x, y, z, 0) == base)
		return true;
	return false;
}

/*! \brief Returns true, if pixel of image on coordinates x,y,z has same 
 *  color as c.
 *
 */
bool Painter::check_if_pixel_is_color(
	const std::size_t x,
	const std::size_t y,
	const std::size_t z,
	const Color& c) const
{
	if (img(x, y, z, 0) == c.get_R() && 
		img(x, y, z, 1) == c.get_G() && 
		img(x, y, z, 2) == c.get_B())
		return true;
	return false;
}

/*! \brief Resets image to base. Only red color is changed.
 *
 */
void Painter::reset_image(bool strong)
{
	if (strong)
	{
		unsigned char values[3] = { base, 0, 0 };

		cimg_forXYZC(img, x, y, z, c)
		{
			img(x, y, z, c) = values[c];
		}
	}
	else
	{
		cimg_forXYZ(img, x, y, z)
		{
			img.fillC(x, y, z, base);
		}
	}
}

/*! \brief Function will resize image and resets it.
 *
 */
void Painter::resize(std::size_t width, std::size_t height)
{
	size_of_x = width;
	size_of_y = height;
	img.resize(width, height);
	reset_image();
}

/*
 ******************************************************************************
 ******************************* ZOOMING FUNCTIONS ****************************
 ******************************************************************************
 */

/*! \brief Fuction will reset zoom into whole domain and will reset image.
 *
 */
void Painter::reset_zoom()
{
	if (x_rev)
	{
		min_x = t_max_x;
		max_x = t_min_x;
	}
	else
	{
		min_x = t_min_x;
		max_x = t_max_x;
	}
	if (y_rev)
	{
		min_y = t_max_y;
		max_y = t_min_y;
	}
	{
		min_y = t_min_y;
		max_y = t_max_y;
	}
	
	update_zoom();
	reset_image();
}

/*! \brief Function will make deep zoom into specified subset of current zoom.
 *
 */
void Painter::zoom(int new_min_x, int new_max_x, int new_min_y, int new_max_y)
{
	if (new_min_x > new_max_x)
	{
		int swap_x = new_min_x;
		new_min_x = new_max_x;
		new_max_x = swap_x;
	}
	if (new_min_y > new_max_y)
	{
		int swap_y = new_min_y;
		new_min_y = new_max_y;
		new_max_y = swap_y;
	}

	if (x_rev)
	{
		double h_min_x = from_gif_coordinates(min_x, max_x, size_of_x, new_min_x, x_rev);
		double h_max_x = from_gif_coordinates(min_x, max_x, size_of_x, new_max_x, x_rev);
		min_x = h_max_x;
		max_x = h_min_x;
	}
	else
	{
		double h_min_x = from_gif_coordinates(min_x, max_x, size_of_x, new_min_x, x_rev);
		double h_max_x = from_gif_coordinates(min_x, max_x, size_of_x, new_max_x, x_rev);
		min_x = h_min_x;
		max_x = h_max_x;
	}
	if (y_rev)
	{
		double h_min_y = from_gif_coordinates(min_y, max_y, size_of_y, new_min_y, y_rev);
		double h_max_y = from_gif_coordinates(min_y, max_y, size_of_y, new_max_y, y_rev);
		min_y = h_max_y;
		max_y = h_min_y;
	}
	else
	{
		double h_min_y = from_gif_coordinates(min_y, max_y, size_of_y, new_min_y, y_rev);
		double h_max_y = from_gif_coordinates(min_y, max_y, size_of_y, new_max_y, y_rev);
		min_y = h_min_y;
		max_y = h_max_y;
	}

	update_zoom();
	reset_image();
}

/*
 ******************************************************************************
 ******************************* DRAWING FUNCTIONS ****************************
 ******************************************************************************
 */

/*! \brief Basic function for setting value/color of CImg pixel. 
 *  If (only_background) then pixel will be changed only if his "red"/first value 
 *  is equal to base.
 *
 */
void Painter::set_pixel(
	const int x,
	const int y,
	const Color& color,
	const bool only_background)
{
	if (x >= (int)0 && x <= (int)size_of_x &&
		y >= (int)0 && y <= (int)size_of_y)
	{
		if (!only_background)
		{
			img.draw_point(x, y, color.get_data());
		}
		else
		{
			if (check_if_pixel_is_base(x, y, 0))
				img.draw_point(x, y, color.get_data());
		}
	}
}

/*! \brief Bressenham's line drawing algoritmh. Line is drawn between fst and snd point 
 *  into CImg image with specified color. If (only_background) then only pixels with 
 *  base value will be changed.
 *
 */
void Painter::draw_line_pixel_by_pixel(
	DataType fst_x,
	DataType fst_y,
	DataType snd_x,
	DataType snd_y,
	const Color& color,
	const bool only_background)
{
	std::pair<int, int> fst_pt =
		get_pixel_with_coordinates(fst_x, fst_y);
	std::pair<int, int> snd_pt =
		get_pixel_with_coordinates(snd_x, snd_y);
	int x1 = fst_pt.first,
		x2 = snd_pt.first,
		y1 = fst_pt.second,
		y2 = snd_pt.second;

	if (x1 == x2 && y1 == y2)
	{
		set_pixel(
			x1, y1, 
			color, 
			only_background);
	}
	else
	if (x1 == x2)
	{
		int dy = y1 > y2 ? y1 - y2 : y2 - y1; // abs(y2 - y1),
		int sy = 1;
		int current_y = y1 < y2 ? y1 : y2;
		int target_y = y1 > y2 ? y1 : y2;
		for (;;)
		{
			set_pixel(
				x1, current_y, 
				color, 
				only_background);

			if (current_y < target_y)
				current_y += sy;
			else
				break;
		}
	}
	else
	if (y1 == y2)
	{
		int dx = x1 > x2 ? x1 - x2 : x2 - x1; // abs(x2 - x1),
		int sx = 1;
		int current_x = x1 < x2 ? x1 : x2;
		int target_x = x1 > x2 ? x1 : x2;
		for (;;)
		{
			set_pixel(
				current_x, y1, 
				color, 
				only_background);

			if (current_x < target_x)
				current_x += sx;
			else
				break;
		}
	}
	else
	{
		// http://rosettacode.org/wiki/Bitmap/Bresenham's_line_algorithm#C.2B.2B
		int dx = x1 > x2 ? x1 - x2 : x2 - x1, // abs(x2 - x1),
			sx = x1 < x2 ? 1 : -1;
		int dy = y1 > y2 ? y1 - y2 : y2 - y1, // abs(y2 - y1),
			sy = y1 < y2 ? 1 : -1;
		int err = (dx > dy ? dx : -dy) / 2, 
			e2;

		for (;;)
		{
			set_pixel(
				x1, y1, 
				color, 
				only_background);

			if (x1 == x2 && y1 == y2) break;
			e2 = err;
			if (e2 >-dx) { err -= dy; x1 += sx; }
			if (e2 < dy) { err += dx; y1 += sy; }
		}
	}
}

/*! \brief Function for drawing line into CImg. If (only_background) then
 *  only pixels with value base  will be changed.
 *
 */
void Painter::draw_line_pixel_by_pixel(
	const Point& fst,
	const Point& snd,
	const Color& color,
	const bool only_background)
{
	draw_line_pixel_by_pixel(
		fst.get_x(), fst.get_y(),
		snd.get_x(), snd.get_y(),
		color,
		only_background);
}

/*! \brief Function for drawing line into CImg. If (only_background) then
 *  only pixels with base value will be changed.
 *
 */
void Painter::draw_line_pixel_by_pixel(
	const Line& line,
	const Color& color,
	const bool only_background)
{
	for (std::size_t i = 0; i < line.size() - 1; ++i)
	{
		draw_line_pixel_by_pixel(
			line[i], 
			line[i + 1], 
			color,
			only_background);
	}
}

/*! \brief Function for drawing line into CImg. If (only_background) then
 *  only pixels with base value will be changed.
 *
 */
void Painter::draw_line_pixel_by_pixel(
	const std::vector<Line>& lines,
	const Color& color,
	const bool only_background)
{
	for (const auto& line : lines)
		draw_line_pixel_by_pixel(
			line, 
			color, 
			only_background);
}

/*! \brief Function for drawing rectangle into CImg. If (only_background) then
 *  only pixels with base value will be changed.
 *
 */
void Painter::draw_rectangle_pixel_by_pixel(
	const DataType fst_x,
	const DataType fst_y,
	const DataType snd_x,
	const DataType snd_y,
	const Color& color,
	const bool only_background)
{
	std::pair<int, int> fst_pt =
		get_pixel_with_coordinates(fst_x, fst_y);
	std::pair<int, int> snd_pt =
		get_pixel_with_coordinates(snd_x, snd_y);

	int 
		x1 = fst_pt.first < snd_pt.first ? fst_pt.first : snd_pt.first,
		x2 = fst_pt.first > snd_pt.first ? fst_pt.first : snd_pt.first,
		y1 = fst_pt.second < snd_pt.second ? fst_pt.second : snd_pt.second,
		y2 = fst_pt.second > snd_pt.second ? fst_pt.second : snd_pt.second;

	// we will cut drawed box so we don't have to 
	// ... draw him whole if he is out of zoomed boundaries
	if (x1 < (int)0)
		x1 = (int)0;
	else 
	if (x1 > (int)(size_of_x - 1))
		x1 = (int)(size_of_x - 1);

	if (y1 < (int)0)
		y1 = (int)0;
	else
	if (y1 > (int)(size_of_y - 1))
		y1 = (int)(size_of_y - 1);

	if (x2 < (int)0)
		x2 = (int)0;
	else
	if (x2 > (int)(size_of_x - 1))
		x2 = (int)(size_of_x - 1);

	if (y2 < (int)0)
		y2 = (int)0;
	else
	if (y2 > (int)(size_of_y - 1))
		y2 = (int)(size_of_y - 1);

	int sx = 1;
	int	sy = 1;

	// we will draw pixels in rectangle
	for (int x = x1; x <= x2; ++x)
	{
		for (int y = y1; y <= y2; ++y)
		{
			set_pixel(
				x, y, 
				color, 
				only_background);
		}
	}
}

/*! \brief Function for initiating 4-direction (left, right, down, up) bounded 
 *  floodfill. Only pixels with base value will be filled. Pixels with other 
 *  value than base will stop floodfill.
 *
 */
void Painter::draw_fill_pixel_by_pixel(
	const int x,
	const int y,
	const Color& color,
	const std::size_t x_lower_bound,
	const std::size_t x_upper_bound,
	const std::size_t y_lower_bound,
	const std::size_t y_upper_bound)
{
	if (x < (int)x_lower_bound || x >= (int)x_upper_bound ||
		y < (int)y_lower_bound || y >= (int)y_upper_bound ||
		x < 0 || x >= (int)size_of_x || 
		y < 0 || y >= (int)size_of_y)
		return;

	// we will use queue of pixels, becouse its better solution
	// ... than recursion (due to unknown depth of stack) or stack 
	// ... (becouse queue is more sparingle solution in terms of memory)
	std::queue<std::pair<int, int> > pixels_to_be_painted;
	pixels_to_be_painted.emplace(x, y);
	for (;;)
	{
		if (pixels_to_be_painted.empty())
			break;

		std::pair<int, int> cur =
			pixels_to_be_painted.front();
		pixels_to_be_painted.pop();

		if (cur.first < (int)x_lower_bound || cur.first >= (int)x_upper_bound ||
			cur.second < (int)y_lower_bound || cur.second >= (int)y_upper_bound ||
			cur.first < 0 || cur.first >= (int)size_of_x ||
			cur.second < 0 || cur.second >= (int)size_of_y)
			continue;
		if (check_if_pixel_is_base(cur.first, cur.second, 0))
		{
			set_pixel(cur.first, cur.second, color, true);
			pixels_to_be_painted.emplace(cur.first - 1, cur.second);
			pixels_to_be_painted.emplace(cur.first + 1, cur.second);
			pixels_to_be_painted.emplace(cur.first, cur.second - 1);
			pixels_to_be_painted.emplace(cur.first, cur.second + 1);
		}
	}
}

/*! \brief Function for initiating 4-direction (left, right, down, up) floodfill.
 *  Only pixels with base value will be filled. Pixels with other value than base
 *  will stop floodfill.
 *
 */
void Painter::draw_fill_pixel_by_pixel(
	const int x,
	const int y,
	const Color& color)
{
	draw_fill_pixel_by_pixel(
		x, y, 
		color, 
		0, 
		size_of_x,
		0,
		size_of_y);
}

/*
 ******************************************************************************
 ************************* PUBLIC DRAWING FUNCTIONS ***************************
 ******************************************************************************
 */

/*! \brief Function will draw point with real coordinates x,y into image. 
 *  If (only_background) then pixel will be changed only if his "red"/first value 
 *  is equal to base.
 *
 */
void Painter::draw_point(
	const DataType x,
	const DataType y,
	const Color& color,
	const bool only_background)
{
	if (x >= t_min_x && x <= t_max_x &&
		y >= t_min_y && y <= t_max_y)
	{
		std::pair<int, int> pt =
			get_pixel_with_coordinates(x, y);
		set_pixel(
			pt.first, pt.second, 
			color, 
			only_background);
	}
}

/*! \brief Function will draw point into image. 
 *  If (only_background) then pixel will be changed only if his "red"/first value 
 *  is equal to base.
 *
 */
void Painter::draw_point(
	const Point& point,
	const Color& color,
	const bool only_background)
{
	draw_point(
		point.get_x(), point.get_y(),
		color,
		only_background);
}

/*! \brief Function will draw all points in vector into image. 
 *  If (only_background) then pixels will be changed only if their "red"/first value 
 *  is equal to base.
 *
 */
void Painter::draw_point(
	const std::vector<Point>& point,
	const Color& color,
	const bool only_background)
{
	for (auto& p : point)
	draw_point(
		p.get_x(), p.get_y(),
		color,
		only_background);
}

/*! \brief Function will fill one pixel with specific color.
 *
 */
void Painter::draw_pixel(
	const int x,
	const int y,
	const Color& color,
	const bool only_background)
{
	set_pixel(x, y, color, only_background);
}

/*! \brief Function will draw line between points fst and snd into image. 
 *  If (only_background) then pixels will be changed only if their "red"/first value 
 *  is equal to base.
 *
 */
void Painter::draw_line(
	const DataType fst_x,
	const DataType fst_y,
	const DataType snd_x,
	const DataType snd_y,
	const Color& color,
	const bool only_background)
{
	if (DoLinePartiallyBelongsToBox(
		fst_x, fst_y,
		snd_x, snd_y,
		zoomed_place))
	{
		draw_line_pixel_by_pixel(
			fst_x, fst_y, snd_x, snd_y,
			color,
			only_background);
	}
}

/*! \brief Function will draw line between points fst and snd into image. 
 *  If (only_background) then pixels will be changed only if their "red"/first value 
 *  is equal to base.
 *
 */
void Painter::draw_line(
	const Point& fst,
	const Point& snd,
	const Color& color,
	const bool only_background)
{
	draw_line(
		fst.get_x(), fst.get_y(), 
		snd.get_x(), snd.get_y(),
		color,
		only_background);
}

/*! \brief Function will draw all parts of line into image. 
 *  If (only_background) then pixels will be changed only if their "red"/first value 
 *  is equal to base.
 *
 */
void Painter::draw_line(
	const Line& line,
	const Color& color,
	const bool only_background)
{
	if (line.size() == 0)
		return;

	for (std::size_t p = 0; p < line.size() - 1; ++p)
	{
		draw_line(
			line[p], line[p + 1],
			color,
			only_background);
	}
}

/*! \brief Function will draw all lines in vector into image. 
 *  If (only_background) then pixels will be changed only if their "red"/first value 
 *  is equal to base.
 *
 */
void Painter::draw_line(
	const std::vector<Line>& lines, 
	const Color& color,
	const bool only_background)
{
	for (auto& line : lines)
	{
		draw_line(
			line,
			color,
			only_background);
	}
}

/*! \brief Function will draw box into image.
 *  If (only_background) then pixels will be changed only if their "red"/first value 
 *  is equal to base.
 *
 */
void Painter::draw_box_fill(
	const DataType b_min_x,
	const DataType b_max_x,
	const DataType b_min_y,
	const DataType b_max_y,
	const Color& color,
	const bool only_background)
{
	//		img.draw_rectangle(
	//			to_gif_coordinates(min_x, max_x, size_of_x, b_min_x, x_rev),
	//			to_gif_coordinates(min_y, max_y, size_of_y, b_min_y, y_rev),
	//			to_gif_coordinates(min_x, max_x, size_of_x, b_max_x, x_rev),
	//			to_gif_coordinates(min_y, max_y, size_of_y, b_max_y, y_rev),
	//			color.get_data());
	if (DoBoxesHaveIntersection(
		zoomed_place,
		b_min_x, b_max_x, b_min_y, b_max_y))
	{
		draw_rectangle_pixel_by_pixel(
			b_min_x, b_min_y,
			b_max_x, b_max_y,
			color,
			only_background);
	}
}

/*! \brief Function will draw box into image.
 *  If (only_background) then pixels will be changed only if their "red"/first value 
 *  is equal to base.
 *
 */
void Painter::draw_box_fill(
	const Box& box,
	const Color& color,
	const bool only_background)
{
	//		img.draw_rectangle(
	//			to_gif_coordinates(min_x, max_x, size_of_x, box.get_x().get_fst(), x_rev),
	//			to_gif_coordinates(min_y, max_y, size_of_y, box.get_y().get_fst(), y_rev),
	//			to_gif_coordinates(min_x, max_x, size_of_x, box.get_x().get_snd(), x_rev),
	//			to_gif_coordinates(min_y, max_y, size_of_y, box.get_y().get_snd(), y_rev),
	//			color.get_data());
	if (DoBoxesHaveIntersection(
		zoomed_place,
		box))
	{
		draw_rectangle_pixel_by_pixel(
			box.get_x().get_fst(), box.get_y().get_fst(),
			box.get_x().get_snd(), box.get_y().get_snd(),
			color,
			only_background);
	}
}

/*! \brief Function will draw all boxes in vector into image.
 *  If (only_background) then pixels will be changed only if their "red"/first value 
 *  is equal to base.
 *
 */
void Painter::draw_box_fill(
	const std::vector<Box>& boxes,
	const Color& color,
	const bool only_background)
{
	for (auto& box : boxes)
	{
		draw_box_fill(
			box,
			color,
			only_background);
	}
}

/*! \brief Function will draw content of DataSetItem into image.
 *  If (only_background) then pixels will be changed only if their "red"/first value 
 *  is equal to base.
 *
 */
void Painter::draw_box_fill(
	const DataSetItem& dsi,
	const Color& color,
	const bool only_background)
{
	draw_box_fill(
		*dsi,
		color,
		only_background);
}

/*! \brief Function will draw contents of each DataSetItem in vector into image.
 *  If (only_background) then pixels will be changed only if their "red"/first value 
 *  is equal to base.
 *
 */
void Painter::draw_box_fill(
	const DataSetItemVector& dsiv,
	const Color& color,
	const bool only_background)
{
	for (auto& dsi : dsiv)
	{
		draw_box_fill(
			dsi,
			color,
			only_background);
	}
}

/*! \brief Function will draw edges of box into image.
 *  If (only_background) then pixels will be changed only if their "red"/first value 
 *  is equal to base.
 *
 */
void Painter::draw_box_edges(
	const DataType b_min_x,
	const DataType b_max_x,
	const DataType b_min_y,
	const DataType b_max_y,
	const Color& color,
	const bool only_background)
{
	// we will select only relevant boxes for drawing
	if (DoBoxesHaveIntersection(
		zoomed_place, 
		b_min_x, b_max_x, b_min_y, b_max_y))
	{
		draw_line(
			b_min_x, b_min_y,
			b_min_x, b_max_y,
			color,
			only_background);

		draw_line(
			b_min_x, b_max_y,
			b_max_x, b_max_y,
			color,
			only_background);

		draw_line(
			b_max_x, b_min_y,
			b_max_x, b_max_y,
			color,
			only_background);

		draw_line(
			b_min_x, b_min_y,
			b_max_x, b_min_y,
			color,
			only_background);
	}
}

/*! \brief Function will draw edges of box into image.
 *  If (only_background) then pixels will be changed only if their "red"/first value 
 *  is equal to base.
 *
 */
void Painter::draw_box_edges(
	const Box& box,
	const Color& color,
	const bool only_background)
{
	// we will select only relevant boxes for drawing
	if (DoBoxesHaveIntersection(
		zoomed_place,
		box))
	{
		draw_line(
			box.get_x().get_fst(), box.get_y().get_fst(),
			box.get_x().get_fst(), box.get_y().get_snd(),
			color,
			only_background);

		draw_line(
			box.get_x().get_fst(), box.get_y().get_snd(),
			box.get_x().get_snd(), box.get_y().get_snd(),
			color,
			only_background);

		draw_line(
			box.get_x().get_snd(), box.get_y().get_fst(),
			box.get_x().get_snd(), box.get_y().get_snd(),
			color,
			only_background);

		draw_line(
			box.get_x().get_fst(), box.get_y().get_fst(),
			box.get_x().get_snd(), box.get_y().get_fst(),
			color,
			only_background);
	}
}

/*! \brief Function will draw edges of all boxes in vector into image.
 *  If (only_background) then pixels will be changed only if their "red"/first value 
 *  is equal to base.
 *
 */
void Painter::draw_box_edges(
	const std::vector<Box>& boxes,
	const Color& color,
	const bool only_background)
{
	for (auto& box : boxes)
	{
		draw_box_edges(
			box,
			color,
			only_background);
	}
}

/*! \brief Function will draw edges of content of DataSetItem into image.
 *  If (only_background) then pixels will be changed only if their "red"/first value 
 *  is equal to base.
 *
 */
void Painter::draw_box_edges(
	const DataSetItem& dsi,
	const Color& color,
	const bool only_background)
{
	draw_box_edges(
		*dsi,
		color,
		only_background);
}

/*! \brief Function will draw edges of contents of all DataSetItems of vector into image.
 *  If (only_background) then pixels will be changed only if their "red"/first value 
 *  is equal to base.
 *
 */
void Painter::draw_box_edges(
	const DataSetItemVector& dsiv,
	const Color& color,
	const bool only_background)
{
	for (auto& dsi : dsiv)
	{
		draw_box_edges(
			dsi,
			color,
			only_background);
	}
}

/*! \brief Function will initiate 4-direction (left, right, down, up) bounded 
 *  floodfill in image. Only pixels with base value will be filled. Pixels with 
 *  other "red"/first values than base will stop floodfill.
 *
 */
void Painter::draw_fill_from_pixel(
	const std::size_t x,
	const std::size_t y,
	const Color& color,
	const std::size_t x_lower_bound,
	const std::size_t x_upper_bound,
	const std::size_t y_lower_bound,
	const std::size_t y_upper_bound)
{
	draw_fill_pixel_by_pixel(
		(int)x, (int)y,
		color,
		x_lower_bound, x_upper_bound,
		y_lower_bound, y_upper_bound);
}

/*! \brief Function will initiate 4-direction (left, right, down, up) floodfill 
 *  in image. Only pixels with base value will be filled. Pixels with other 
 *  "red"/first values than base will stop floodfill.
 *
 */
void Painter::draw_fill_from_pixel(
	const std::size_t x,
	const std::size_t y,
	const Color& color)
{
	draw_fill_pixel_by_pixel(
		(int)x, (int)y,
		color);
}

/*! \brief Function will initiate 4-direction (left, right, down, up) bounded 
 *  floodfill in image. Only pixels with base value will be filled. Pixels with 
 *  other "red"/first values than base will stop floodfill.
 *
 */
void Painter::draw_fill_from_coordinates(
	const DataType x,
	const DataType y,
	const Color& color,
	const DataType x_lower_bound,
	const DataType x_upper_bound,
	const DataType y_lower_bound,
	const DataType y_upper_bound)
{
	std::pair<int, int> pixel =
		get_pixel_with_coordinates(x, y);
	std::pair<int, int> lower_bound =
		get_pixel_with_coordinates(x_lower_bound, y_lower_bound);
	std::pair<int, int> upper_bound =
		get_pixel_with_coordinates(x_upper_bound, y_upper_bound);

	draw_fill_pixel_by_pixel(
		pixel.first, pixel.second,
		color,
		lower_bound.first, upper_bound.first,
		lower_bound.second, upper_bound.second);
}

/*! \brief Function will initiate 4-direction (left, right, down, up) floodfill 
 *  in image. Only pixels with base value will be filled. Pixels with other 
 *  "red"/first values than base will stop floodfill.
 *
 */
void Painter::draw_fill_from_coordinates(
	const DataType x,
	const DataType y,
	const Color& color)
{
	std::pair<int, int> pixel = 
		get_pixel_with_coordinates(x, y);
	draw_fill_pixel_by_pixel(
		pixel.first, pixel.second, 
		color);
}

/*! \brief Function will initiate 4-direction (left, right, down, up) bounded 
 *  floodfill in image. Only pixels with base value will be filled. Pixels with 
 *  other "red"/first values than base will stop floodfill.
 *
 */
void Painter::draw_fill_from_coordinates(
	const Point& point,
	const Color& color,
	const DataType x_lower_bound,
	const DataType x_upper_bound,
	const DataType y_lower_bound,
	const DataType y_upper_bound)
{
	draw_fill_from_coordinates(
		point.get_x(), point.get_y(),
		color,
		x_lower_bound, x_upper_bound,
		y_lower_bound, y_upper_bound);
}

/*! \brief Function will initiate 4-direction (left, right, down, up) floodfill 
 *  in image. Only pixels with base value will be filled. Pixels with other 
 *  "red"/first values than base will stop floodfill.
 *
 */
void Painter::draw_fill_from_coordinates(
	const Point& point,
	const Color& color)
{
	draw_fill_from_coordinates(
		point.get_x(), point.get_y(), 
		color);
}