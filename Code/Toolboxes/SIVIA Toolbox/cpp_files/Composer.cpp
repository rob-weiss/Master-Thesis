#include "Composer.h"

#include <utility>
#include <vector>

#include "CImg.h"
#include "MatlabLayer.h"
#include "NotAllowedOperationException.h"
#include "Painter.h"
#include "Visualiser.h"

/*
 ******************************************************************************
 ********************************** CONSTRUCTORS ******************************
 ******************************************************************************
 */

/*! \brief Constructor, where visualiser_count is maximum possible count of 
 *  visualisers.
 *
 */
Composer::Composer(const std::size_t visualiser_count)
{
	max_size_of_viss = visualiser_count;
	viss.reserve(visualiser_count);
}

/*
 ******************************************************************************
 ********************* COORDINATES AND SELECTION OF VISUALISER ****************
 ******************************************************************************
 */

/*! \brief Returns position / id of visualiser on position of x,y in composed 
 *  image. Value -1 will be returned, if point belongs to none visualiser.
 *
 */
int Composer::which_visualiser(
	const int x,
	const int y) const
{
	int selected = -1;

	for (std::size_t i = 0; i < starting_x.size(); ++i)
	{
		if (starting_x[i] <= x &&
			x < starting_x[i] + (int)viss[i].get_size_of_x() &&
			starting_y[i] <= y &&
			y < starting_y[i] + (int)viss[i].get_size_of_y())
		{
			selected = (int)i;
		}
	}

	return selected;
}

/*! \brief Returns coordinates of pixel of visualiser on position of x,y 
 *  in composed image. 
 *  Value -1 will be returned, if coordinates does not belongs 
 *  to the visualiser on position / id which_vis.
 *
 */
std::pair<int, int> Composer::which_point_of_picture(
	const int x,
	const int y,
	const int which_vis) const
{
	if (which_vis < 0 || which_vis >= (int)viss.size())
		return std::make_pair(-1, -1);

	int x_in = -1;
	if (starting_x[which_vis] <= x &&
		x < starting_x[which_vis] + (int)viss[which_vis].get_size_of_x())
		x_in = x - starting_x[which_vis];

	int y_in = -1;
	if (starting_y[which_vis] <= y &&
		y < starting_y[which_vis] + (int)viss[which_vis].get_size_of_y())
		y_in = y - starting_y[which_vis];

	return std::make_pair(x_in, y_in);
}

/*
 ******************************************************************************
 ************************************* ZOOMING ********************************
 ******************************************************************************
 */

/*! \brief Gets 2 pixels of composed image on input. If pixels belongs to the 
 *  same visualisation, then position of the possible zoomed region 
 *  in corresponding visualisation are returned as pair. If pixels are not  
 *  in the same visualisation, then values -1 occur in the returned value.
 *
 *  Returned possible zoomed region holds the same x:y as the original image of
 *  visualisation. The shorter side will be used for evaluation of zoomed x:y. 
 */
std::pair<std::pair<int, int>, std::pair<int, int> > Composer::gain_possible_selection(
	const int fst_x,
	const int fst_y,
	const int snd_x,
	const int snd_y)
{
	int which_vis_startpoint = which_visualiser(fst_x, fst_y);
	int which_vis_endpoint = which_visualiser(snd_x, snd_y);

	const std::pair<int, int> startp = which_point_of_picture(fst_x, fst_y, which_vis_startpoint);
	const std::pair<int, int> endp = which_point_of_picture(snd_x, snd_y, which_vis_startpoint);

	const int
		xs0 = std::min(startp.first, endp.first),
		ys0 = std::min(startp.second, endp.second),
		xs1 = std::max(startp.first, endp.first),
		ys1 = std::max(startp.second, endp.second);

	if (which_vis_startpoint != which_vis_endpoint ||
		which_vis_startpoint == -1 ||
		which_vis_endpoint == -1 ||
		xs0 == -1 || 
		ys0 == -1 ||
		xs1 == -1 ||
		ys1 == -1)
	{
		return std::make_pair(
			std::make_pair(-1, -1), 
			std::make_pair(-1, -1));
	}

	const int y_due_x = (int)(
		(double)(xs1 - xs0) *
		(double)viss[which_vis_startpoint].get_size_of_y() /
		(double)viss[which_vis_startpoint].get_size_of_x());
	const int x_due_y = (int)(
		(double)(ys1 - ys0) *
		(double)viss[which_vis_startpoint].get_size_of_x() /
		(double)viss[which_vis_startpoint].get_size_of_y());

	std::size_t
		x_diff = 0,
		y_diff = 0;

	// we will take the one with lesser volume
	if ((x_due_y) * (ys1 - ys0) < (xs1 - xs0) * (y_due_x))
	{
		x_diff = x_due_y;
		y_diff = ys1 - ys0;
	}
	else
	{
		x_diff = xs1 - xs0;
		y_diff = y_due_x;
	}

	std::pair<int, int>	res_endp = std::make_pair(
		startp.first <= endp.first ? startp.first + x_diff : startp.first - x_diff,
		startp.second <= endp.second ? startp.second + y_diff : startp.second - y_diff);

	return std::make_pair(startp, res_endp);
}

/*! \brief Zooms into region of visualised image on position which_vis. Region 
 *  is defined by pixels of visualised image on position which_vis. 
 *
 */
void Composer::zoom(
	int which_vis,
	int sx,
	int sy,
	int ex,
	int ey)
{
	if (which_vis == -1)
		return;

	if (sx < 0 ||
		sy < 0 ||
		ex < 0 ||
		ey < 0 ||
		sx >= (int)viss[which_vis].get_size_of_x() ||
		sy >= (int)viss[which_vis].get_size_of_y() ||
		ex >= (int)viss[which_vis].get_size_of_x() ||
		ey >= (int)viss[which_vis].get_size_of_y())
	{
		return;
	}

	viss[which_vis].zoom(sx, ex, sy, ey);
}

/*! \brief Moves zoomed region of visualisation on position cur_vis
 *  by move_constant * (length of corresponding axis) in specified direction.
 *
 */
void Composer::move_zoom(
	const DIRECTION_MOVE direction,
	const std::size_t cur_vis,
	const double move_constant)
{
	if (direction == DIRECTION_MOVE::LEFT)
	{
		const double d =
			std::fabs(viss[cur_vis].get_zoomed_max_x() -
				viss[cur_vis].get_zoomed_min_x()) * move_constant;
		if (viss[cur_vis].is_x_reverse())
		{
			if (viss[cur_vis].get_zoomed_max_x() + d < viss[cur_vis].get_total_max_x())
			{
				viss[cur_vis].set_zoomed_min_x() += d;
				viss[cur_vis].set_zoomed_max_x() += d;
			}
			else
			{
				const double nd =
					std::fabs(viss[cur_vis].get_total_max_x() -
						viss[cur_vis].get_zoomed_max_x());
				viss[cur_vis].set_zoomed_min_x() += nd;
				viss[cur_vis].set_zoomed_max_x() += nd;
			}
		}
		else
		{
			if (viss[cur_vis].get_zoomed_min_x() - d > viss[cur_vis].get_total_min_x())
			{
				viss[cur_vis].set_zoomed_min_x() -= d;
				viss[cur_vis].set_zoomed_max_x() -= d;
			}
			else
			{
				const double nd =
					std::fabs(viss[cur_vis].get_total_min_x() -
						viss[cur_vis].get_zoomed_min_x());
				viss[cur_vis].set_zoomed_min_x() -= nd;
				viss[cur_vis].set_zoomed_max_x() -= nd;
			}
		}
	}

	if (direction == DIRECTION_MOVE::RIGHT)
	{
		const double d =
			std::fabs(viss[cur_vis].get_zoomed_max_x() -
				viss[cur_vis].get_zoomed_min_x()) * move_constant;
		if (viss[cur_vis].is_x_reverse())
		{
			if (viss[cur_vis].get_zoomed_min_x() - d > viss[cur_vis].get_total_min_x())
			{
				viss[cur_vis].set_zoomed_min_x() -= d;
				viss[cur_vis].set_zoomed_max_x() -= d;
			}
			else
			{
				const double nd =
					std::fabs(viss[cur_vis].get_total_min_x() -
						viss[cur_vis].get_zoomed_min_x());
				viss[cur_vis].set_zoomed_min_x() -= nd;
				viss[cur_vis].set_zoomed_max_x() -= nd;
			}
		}
		else
		{
			if (viss[cur_vis].get_zoomed_max_x() + d < viss[cur_vis].get_total_max_x())
			{
				viss[cur_vis].set_zoomed_min_x() += d;
				viss[cur_vis].set_zoomed_max_x() += d;
			}
			else
			{
				const double nd =
					std::fabs(viss[cur_vis].get_total_max_x() -
						viss[cur_vis].get_zoomed_max_x());
				viss[cur_vis].set_zoomed_min_x() += nd;
				viss[cur_vis].set_zoomed_max_x() += nd;
			}
		}
	}

	if (direction == DIRECTION_MOVE::UP)
	{
		const double d =
			std::fabs(viss[cur_vis].get_zoomed_max_y() -
				viss[cur_vis].get_zoomed_min_y()) * move_constant;
		if (viss[cur_vis].is_y_reverse())
		{
			if (viss[cur_vis].get_zoomed_max_y() + d < viss[cur_vis].get_total_max_y())
			{
				viss[cur_vis].set_zoomed_min_y() += d;
				viss[cur_vis].set_zoomed_max_y() += d;
			}
			else
			{
				const double nd =
					std::fabs(viss[cur_vis].get_total_max_y() -
						viss[cur_vis].get_zoomed_max_y());
				viss[cur_vis].set_zoomed_min_y() += nd;
				viss[cur_vis].set_zoomed_max_y() += nd;
			}
		}
		else
		{
			if (viss[cur_vis].get_zoomed_min_y() + d < viss[cur_vis].get_total_min_y())
			{
				viss[cur_vis].set_zoomed_min_y() -= d;
				viss[cur_vis].set_zoomed_max_y() -= d;
			}
			else
			{
				const double nd =
					std::fabs(viss[cur_vis].get_total_min_y() -
						viss[cur_vis].get_zoomed_min_y());
				viss[cur_vis].set_zoomed_min_y() -= nd;
				viss[cur_vis].set_zoomed_max_y() -= nd;
			}
		}
	}

	if (direction == DIRECTION_MOVE::DOWN)
	{
		const double d =
			std::fabs(viss[cur_vis].get_zoomed_max_y() -
				viss[cur_vis].get_zoomed_min_y()) * move_constant;
		if (viss[cur_vis].is_y_reverse())
		{
			if (viss[cur_vis].get_zoomed_min_y() - d > viss[cur_vis].get_total_min_y())
			{
				viss[cur_vis].set_zoomed_min_y() -= d;
				viss[cur_vis].set_zoomed_max_y() -= d;
			}
			else
			{
				const double nd =
					std::fabs(viss[cur_vis].get_total_min_y() -
						viss[cur_vis].get_zoomed_min_y());
				viss[cur_vis].set_zoomed_min_y() -= nd;
				viss[cur_vis].set_zoomed_max_y() -= nd;
			}
		}
		else
		{
			if (viss[cur_vis].get_zoomed_max_y() - d > viss[cur_vis].get_total_max_y())
			{
				viss[cur_vis].set_zoomed_min_y() += d;
				viss[cur_vis].set_zoomed_max_y() += d;
			}
			else
			{
				const double nd =
					std::fabs(viss[cur_vis].get_total_max_y() -
						viss[cur_vis].get_zoomed_max_y());
				viss[cur_vis].set_zoomed_min_y() += nd;
				viss[cur_vis].set_zoomed_max_y() += nd;
			}
		}
	}

	viss[cur_vis].update_zoom();
}

// not implemented yet
void Composer::resize(
	const std::size_t width,
	const std::size_t height)
{
	display.resize((int)width, (int)height);

	const std::size_t modded_width = width % viss.size();
	std::size_t result_width = modded_width == 0 ? width : width - modded_width;
	std::size_t width_per_element = result_width / viss.size();

	std::size_t width_of_element = width_per_element - 2 * border_size;
	std::size_t height_of_element = height - 2 * border_size;

	starting_x.clear();
	starting_y.clear();
	for (std::size_t i = 0; i < viss.size(); ++i)
	{
		viss[i].resize(width_of_element, height_of_element);
		starting_x.push_back((int)(i*width_per_element + border_size));
		starting_y.push_back((int)border_size);
	}

	size_of_x = result_width;
	size_of_y = height;
}

/*
 ******************************************************************************
 *************************** ADDITIONAL INFORMATIONS INTO IMG *****************
 ******************************************************************************
 */

/*! \brief Changes color of the image border in visualisation in position 
 *  which_vis.
 *
 */
void Composer::change_color_of_border(
	const int which_vis,
	const Color& color)
{
	if (which_vis == -1 ||
		border_size == 0)
		return;

	// upper side
	img.draw_rectangle(
		starting_x[which_vis] - (int)border_size,
		starting_y[which_vis] - (int)border_size,
		starting_x[which_vis] + (int)border_size + (int)viss[which_vis].get_size_of_x() - 1,
		starting_y[which_vis] - 1,
		color.get_data());
	// lower side
	img.draw_rectangle(
		starting_x[which_vis] - (int)border_size,
		starting_y[which_vis] + (int)viss[which_vis].get_size_of_y(),
		starting_x[which_vis] + (int)border_size + (int)viss[which_vis].get_size_of_x() - 1,
		starting_y[which_vis] + (int)border_size + (int)viss[which_vis].get_size_of_y() - 1,
		color.get_data());
	// left side
	img.draw_rectangle(
		starting_x[which_vis] - (int)border_size,
		starting_y[which_vis] - (int)border_size,
		starting_x[which_vis] - 1,
		starting_y[which_vis] + (int)border_size + (int)viss[which_vis].get_size_of_y() - 1,
		color.get_data());
	// right side
	img.draw_rectangle(
		starting_x[which_vis] + (int)viss[which_vis].get_size_of_x(),
		starting_y[which_vis] - (int)border_size,
		starting_x[which_vis] + (int)border_size + (int)viss[which_vis].get_size_of_x() - 1,
		starting_y[which_vis] + (int)border_size + (int)viss[which_vis].get_size_of_y() - 1,
		color.get_data());
}

/*! \brief Shows help menu in visualisation in position which_vis.
 *
 */
void Composer::show_help_menu(
	const int which_vis)
{
	if (which_vis == -1)
		return;

	const int x_offset = 2;
	const int y_offset = 2;

	const unsigned char white[] = { 255, 255, 255 };
	static CImg<unsigned char>
		help = CImg<unsigned char>().draw_text(0, 0, "\n"
		"  Use mouse selection to zoom into desired region  \n"
		"  Click right mouse button to abort selection  \n"
		"  Click left mouse button to unzoom  \n"
		"  TAB           Select another visualisation  \n"
		"  Arrows        Move in zoom  \n"
		"  T             Set same zoom to all visualisations \n"
		"  R             Resize window to default resolution \n"
		"  H             Show/Hide help  \n"
		"  G             Show/Hide edges of boxes \n"
		"  A             Show/Hide approximation lines \n"
		"  C             Show/Hide coordinates of mouse \n"
		"  1             Default original view  \n"
		"  2             Approximation settings \n"
		"  3             Change points closering \n"
		"  F             Change approximation fill \n"
		"  D             Enable/Disable deep evaluation \n"
		"  E             Enable/Disable exact filling \n"
		"  X             Allow/Deny changes of T and F boxes \n"
		"  S             Open saving dialog for current vis \n"
		"  O             Open saving dialog for all vis \n"
		"  Q or Esc      To end.  \n",
		white).resize(-100, -100, 1, 3);
	help.draw_rectangle(
		x_offset, y_offset, 
		help.width() - x_offset - 1, help.height() - y_offset - 1, 
		white, 1, ~0U);
	
	const int pos_x = (int)viss[which_vis].get_size_of_x() - help.width();
	const int pos_y = 0;

	shown[which_vis].draw_image(
		pos_x,
		pos_y,
		help, 
		0.7f);
}

/*! \brief Shows visualisation type selection menu in visualisation 
 *  in position which_vis.
 *
 */
int Composer::show_visualisation_types(const int which_vis)
{
	if (which_vis == -1)
		return - 1;

	return show_settings(
		which_vis,
		viss[which_vis].get_visualisation_types());
}

/*! \brief Shows sampling method selection menu in visualisation 
 *  in position which_vis.
 *
 */
int Composer::show_sampling_methods(const int which_vis)
{
	if (which_vis == -1)
		return -1;

	return show_settings(
		which_vis,
		viss[which_vis].get_sampling_methods());
}

/*! \brief Shows approximating method selection menu in visualisation 
 *  in position which_vis.
 *
 */
int Composer::show_approximating_methods(const int which_vis)
{
	if (which_vis == -1)
		return -1;

	return show_settings(
		which_vis,
		viss[which_vis].get_approximating_methods());
}

/*! \brief Shows selection menu of settings in visualisation in position 
 *  which_vis. -1 is returned, if storno is selected.
 *
 */
int Composer::show_settings(
	const int which_vis,
	const available_settings& settings,
	const bool with_storno_option)
{
	if (settings.size() == 0 ||
		which_vis == -1)
		return -1;

	int aprox_number = -1;

	std::size_t font_size = 13;
	std::size_t header_size = 26;

	// used colors
	const unsigned char
		white[] = { 255, 255, 255 }, green[] = { 30, 200, 70 };

	// where headline starts
	int offset_header_x = 20;
	int offset_header_y = 20;
	int offset_menu_header_x = 20;
	int offset_menu_header_y = 10;
	int headline_x = offset_header_x;
	int headline_y = offset_header_y;
	int settings_menu_x = offset_menu_header_x;
	int settings_menu_y = headline_y + (int)header_size + offset_menu_header_y;

	// IMAGE PARTS
	CImg<unsigned char>
		background((int)viss[which_vis].get_size_of_x(), (int)viss[which_vis].get_size_of_y(), 1, 3, 0),
		headline,
		settings_menu;

	// CREATING HEADLINE
	headline.draw_text(
		0, 0,
		" SELECTION MENU ",
		white,
		0, 1, (int)header_size)
		.resize(-100, -100, 1, 3);

	// CREATING SETTINGS MENU
	std::stringstream ss; 
	for (std::size_t i = 0; i < settings.size() - 1; ++i)
	{
		ss 
			<< settings[i].first 
			<< " = " 
			<< settings[i].second
			<< std::endl;
	}

	// we add storno, if storno is asked
	if (with_storno_option)
	{
		ss
			<< settings[settings.size() - 1].first
			<< " = "
			<< settings[settings.size() - 1].second
			<< std::endl;
		ss  << "storno selection";
	}
	else
	{
		ss
			<< settings[settings.size() - 1].first
			<< " = "
			<< settings[settings.size() - 1].second;
	}

	settings_menu.draw_text(
		0, 0, 
		ss.str().c_str(), 
		white, 
		0, 1, (int)font_size)
		.resize(-100, -100, 1, 3);

	// ADDING HEADLINE TO BACKGROUND
	update(
		background,
		headline,
		(std::size_t)headline_x,
		(std::size_t)headline_y,
		(std::size_t)headline_x + (std::size_t)headline.width(),
		(std::size_t)headline_y + (std::size_t)headline.height(),
		(std::size_t)0,
		(std::size_t)0,
		(std::size_t)headline.width(),
		(std::size_t)headline.height());

	// ADDING SETTINGS MENU TO BACKGROUND
	update(
		background,
		settings_menu,
		(std::size_t)settings_menu_x,
		(std::size_t)settings_menu_y,
		(std::size_t)settings_menu_x + (std::size_t)settings_menu.width(),
		(std::size_t)settings_menu_y + (std::size_t)settings_menu.height(),
		(std::size_t)0,
		(std::size_t)0,
		(std::size_t)settings_menu.width(),
		(std::size_t)settings_menu.height());

	// MENU SHOW UP
	update(
		img,
		background,
		(std::size_t)starting_x[which_vis],
		(std::size_t)starting_y[which_vis],
		(std::size_t)starting_x[which_vis] + (std::size_t)background.width(),
		(std::size_t)starting_y[which_vis] + (std::size_t)background.height(),
		(std::size_t)0,
		(std::size_t)0,
		(std::size_t)background.width(),
		(std::size_t)background.height());

	while (
		aprox_number == -1 && 
		!display.is_closed() && 
		!display.is_keyQ() &&
		!display.is_keyESC())
	{
		update(
			img,
			background,
			starting_x[which_vis],
			starting_y[which_vis] + settings_menu_y,
			starting_x[which_vis] + background.width(),
			starting_y[which_vis] + settings_menu_y + settings_menu.height(),
			0,
			settings_menu_y,
			background.width(),
			settings_menu_y + settings_menu.height());

		int my = display.mouse_y();
		int mx = display.mouse_x();

		if (mx >= starting_x[which_vis] && 
			mx < starting_x[which_vis] + (int)viss[which_vis].get_size_of_x() &&
			my >= starting_y[which_vis] + settings_menu_y && 
			my < std::min(
			 	 starting_y[which_vis] + settings_menu_y + settings_menu.height(), 
				 starting_y[which_vis] + (int)viss[which_vis].get_size_of_y()))
		{
			// highlight selection
			int y = ((my - starting_y[which_vis] - settings_menu_y) / (int)font_size) * (int)(font_size);
			img.draw_rectangle(
				starting_x[which_vis],
				y + starting_y[which_vis] + settings_menu_y,
				starting_x[which_vis] + (int)viss[which_vis].get_size_of_x() - 1,
				y + (int)font_size + (int)starting_y[which_vis] + settings_menu_y - 1,
				green,
				0.4f);


			// selection
			if (display.button())
			{
				aprox_number = y / (int)font_size;
			}
		}

		display.set_key();
		display
			.resize(display, false)
			.display(img)
			.wait(25);
	}

	// check for storno
	if (aprox_number == settings.size() && with_storno_option)
		return -1;

	return aprox_number;
}

/*! \brief Shows info, that recompution is in progress in visualiser 
 *  in position which_vis.
 *
 */
void Composer::show_info_about_recomputing(const int which_vis)
{
	if (which_vis == -1)
		return;

	std::size_t header_size = 26;

	// used colors
	const unsigned char
		white[] = { 255, 255, 255 };
		
	// IMAGE PARTS
	CImg<unsigned char>
		background((int)viss[which_vis].get_size_of_x(), (int)viss[which_vis].get_size_of_y(), 1, 3, 0),
		headline;

	// where headline starts
	int offset_header_x = 20;
	int offset_header_y = 20;
	int headline_x = offset_header_x;
	int headline_y = offset_header_y;

	// CREATING HEADLINE
	headline.draw_text(
		0, 0,
		" Recomputing ",
		white,
		0, 1, (int)header_size)
		.resize(-100, -100, 1, 3);

	// ADDING HEADLINE TO BACKGROUND
	update(
		background,
		headline,
		(std::size_t)headline_x,
		(std::size_t)headline_y,
		(std::size_t)headline_x + (std::size_t)headline.width(),
		(std::size_t)headline_y + (std::size_t)headline.height(),
		(std::size_t)0,
		(std::size_t)0,
		(std::size_t)headline.width(),
		(std::size_t)headline.height());

	// INFORMATION SHOW UP
	update(
		img,
		background,
		(std::size_t)starting_x[which_vis],
		(std::size_t)starting_y[which_vis],
		(std::size_t)starting_x[which_vis] + (std::size_t)background.width(),
		(std::size_t)starting_y[which_vis] + (std::size_t)background.height(),
		(std::size_t)0,
		(std::size_t)0,
		(std::size_t)background.width(),
		(std::size_t)background.height());

	display.display(img);
}

/*! \brief Clears selected region, if start point and end point are in the same
 *  visualisation.
 *
 */
void Composer::clear_selection(
	const int start_x,
	const int start_y,
	const int end_x,
	const int end_y)
{
	int which_vis_startpoint = which_visualiser(start_x, start_y);
	int which_vis_endpoint = which_visualiser(end_x, end_y);

	// check, if selection could be viable
	if (which_vis_startpoint != which_vis_endpoint ||
		which_vis_startpoint == -1 ||
		which_vis_endpoint == -1)
	{
		return;
	}
	
	std::pair<std::pair<int, int>, std::pair<int, int> > sel_zoom =
		gain_possible_selection(start_x, start_y, end_x, end_y);

	const int
		fst_x = sel_zoom.first.first,
		fst_y = sel_zoom.first.second,
		snd_x = sel_zoom.second.first,
		snd_y = sel_zoom.second.second;

	// check, if selection is really viable
	if (fst_x != -1 &&
		fst_y != -1 &&
		snd_x != -1 &&
		snd_y != -1)
	{
		update_image(
			which_vis_endpoint,
			std::min(fst_x, snd_x), std::max(fst_x, snd_x) + 1,
			std::min(fst_y, snd_y), std::max(fst_y, snd_y) + 1);
	}
	
}

/*! \brief Draws selected region, if start point and end point are in the same
 *  visualisation.
 *
 */
void Composer::draw_selection(
	const int start_x,
	const int start_y,
	const int end_x,
	const int end_y,
	const Color& color)
{
	int which_vis_startpoint = which_visualiser(start_x, start_y);
	int which_vis_endpoint = which_visualiser(end_x, end_y);

	// check, if selection could be viable
	if (which_vis_startpoint != which_vis_endpoint ||
		which_vis_startpoint == -1 ||
		which_vis_endpoint == -1)
	{
		return; 
	}
		
	std::pair<std::pair<int, int>, std::pair<int, int> > sel_zoom =
			gain_possible_selection(start_x, start_y, end_x, end_y);

	const int
		fst_x = sel_zoom.first.first,
		fst_y = sel_zoom.first.second,
		snd_x = sel_zoom.second.first,
		snd_y = sel_zoom.second.second;

	// check, if selection is really viable
	if (fst_x != -1 &&
		fst_y != -1 &&
		snd_x != -1 &&
		snd_y != -1)
	{
		const int
			fst_x_img = fst_x + starting_x[which_vis_startpoint],
			fst_y_img = fst_y + starting_y[which_vis_startpoint],
			snd_x_img = snd_x + starting_x[which_vis_endpoint],
			snd_y_img = snd_y + starting_y[which_vis_endpoint];

		img.draw_rectangle(
			fst_x_img, fst_y_img,
			snd_x_img, snd_y_img,
			color.get_data(),
			0.18f);
		img.draw_line(
			fst_x_img, fst_y_img,
			fst_x_img, snd_y_img,
			color.get_data());
		img.draw_line(
			fst_x_img, fst_y_img,
			snd_x_img, fst_y_img,
			color.get_data());
		img.draw_line(
			snd_x_img, fst_y_img,
			snd_x_img, snd_y_img,
			color.get_data());
		img.draw_line(
			fst_x_img, snd_y_img,
			snd_x_img, snd_y_img,
			color.get_data());
	}
}

/*! \brief Clears all additional information text in visualisation in position 
 *  which_vis.
 *
 */
void Composer::clear_all_information(
	const int which_vis,
	const std::size_t font_size)
{
	clear_information(which_vis, font_size, true);
	clear_information(which_vis, font_size, false);
}

/*! \brief Clears upper or lower information text in visualisation in position 
 *  which_vis.
 *
 */
void Composer::clear_information(
	const int which_vis,
	const std::size_t font_size,
	const bool up)
{
	if (which_vis == -1)
		return;

	if (up)
	{
		update_image(
			which_vis,
			0, shown[which_vis].width(),
			0, font_size);
	}
	// ! up
	else
	{
		update_image(
			which_vis,
			0, shown[which_vis].width(),
			shown[which_vis].height() - font_size, shown[which_vis].height());
	}
}

/*! \brief Adds upper or lower information text in visualisation in position 
 *  which_vis.
 *
 */
void Composer::put_information(
	const std::string& str,
	const Color& color,
	const int which_vis,
	const std::size_t font_size,
	const bool up)
{
	if (which_vis == -1)
		return;

	const std::size_t pos_x_in_img =
		(std::size_t)starting_x[which_vis];
	const std::size_t pos_y_in_img =
		up ?
		(std::size_t)starting_y[which_vis] :
		(std::size_t)starting_y[which_vis] + viss[which_vis].get_size_of_y() - font_size;

	CImg<unsigned char> text_img(
		(int)viss[which_vis].get_size_of_x(),
		(int)font_size, 1, 3, 0);
	update(
		text_img,
		img,
		0, 0,
		text_img.width(), text_img.height(),
		pos_x_in_img, pos_y_in_img,
		pos_x_in_img + viss[which_vis].get_size_of_x(), pos_y_in_img + viss[which_vis].get_size_of_y());
	text_img.draw_text(0, 0, str.c_str(), color.get_data());
	update(
		img,
		text_img,
		pos_x_in_img, pos_y_in_img,
		pos_x_in_img + viss[which_vis].get_size_of_x(), pos_y_in_img + viss[which_vis].get_size_of_y(),
		0, 0,
		text_img.width(), text_img.height());
}

/*! \brief Clears information text about coordinates of mouse in visualisation.
 *
 */
void Composer::clear_coordinates_info(
	const int which_vis,
	const std::size_t font_size,
	const bool coordinates_up)
{
	clear_information(which_vis, font_size, coordinates_up);
}

/*! \brief Adds information text about coordinates of mouse in visualisation.
 *
 */
void Composer::draw_coordinates_info(
	const int mx,
	const int my,
	bool& coordinates_up,
	const std::size_t font_size,
	const Color& color)
{
	const int mouse_on_vis = which_visualiser(mx, my);

	if (mouse_on_vis == -1)
		return;

	if (my < (int)font_size)
	{
		coordinates_up = false;
	}
	if (my > starting_y[mouse_on_vis] +
		(int)(viss[mouse_on_vis].get_size_of_y() - font_size))
	{
		coordinates_up = true;
	}

	std::pair<int, int> pixel_in_solution =
		which_point_of_picture(mx, my, mouse_on_vis);
	Point coordinates_in_solution =
		viss[mouse_on_vis].get_coordinates_of_pixel(
		pixel_in_solution.first,
		pixel_in_solution.second);

	std::stringstream ss;
	ss << "Point ("
		<< coordinates_in_solution.get_x()
		<< ", "
		<< coordinates_in_solution.get_y()
		<< ")";
	ss << " Pixel ("
		<< pixel_in_solution.first
		<< ", "
		<< pixel_in_solution.second
		<< ")";
	ss << " PixelColors ("
		<< (int)img.atXYZC(mx, my, 0, 0)
		<< ", "
		<< (int)img.atXYZC(mx, my, 0, 1)
		<< ", "
		<< (int)img.atXYZC(mx, my, 0, 2)
		<< ")";
	std::string s = ss.str();

	put_information(s, color, mouse_on_vis, (int)font_size, coordinates_up);
}

/*! \brief Runs saving dialog for the currently selected visualisation.
 *
 */
void Composer::run_saving_dialog(
	const CImg<unsigned char>& saved_img,
	const Color& info_color)
{
	// Matlab cooperation part
	std::string out = RunSavingDialog();
	if (out == "")
		return;

	if (out.size() > 4)
	{
		std::string format = out.substr(out.length() - 4, 4);

		if (format == ".raw")
		{
			saved_img.save_raw(out.c_str());
		}
		else
		if (format == ".asc")
		{
			saved_img.save_ascii(out.c_str());
		}
		else
		if (format == ".hdr")
		{
			saved_img.save_analyze(out.c_str());
		}
		else
		if (format == ".inr")
		{
			saved_img.save_inr(out.c_str());
		}
		else
		if (format == ".bmp")
		{
			saved_img.save_bmp(out.c_str());
		}
		else
		if (format == ".pan")
		{
			saved_img.save_pandore(out.c_str());
		}
		else
		if (format == ".dlm")
		{
			saved_img.save_dlm(out.c_str());
		}
		else
		{
			std::stringstream ss;
			ss << "format for file "
				<< out
				<< " unrecognized\n";
			ExportString(ss.str());
		}
	}
	else
	{
		std::stringstream ss;

		ss << "save file "
			<< out
			<< " unsuccessful\n";
		ExportString(ss.str());
	}
}

/*! \brief Updates all solutions. Solution in position which_solution is updated
 *  from visualiser in position which_solution.
 *
 */
void Composer::update_all_solutions()
{
	for (std::size_t i = 0; i < viss.size(); ++i)
	{
		update_solution(i);
	}
}

/*! \brief Updates solution in position which_solution. Solution in position 
 *  which_solution is updated from visualiser in position which_solution.
 *
 */
void Composer::update_solution(std::size_t which_solution)
{
	solutions[which_solution] = viss[which_solution].get_visualisation();
}

/*! \brief Updates all showns. Shown in position which_solution is updated
 *  from visualiser in position solution.
 *
 */
void Composer::update_all_shown()
{
	for (std::size_t i = 0; i < viss.size(); ++i)
	{
		update_shown(i);
	}
}

/*! \brief Updates shown in position which_solution. Shown in position 
 *  which_solution is updated from solution in position which_solution.
 *
 */
void Composer::update_shown(std::size_t which_solution)
{
	shown[which_solution] = solutions[which_solution];
}

/*! \brief Updates all visualisations in composed image. Visualisation
 *  which_solution is updated from shown in position which_shown.
 *
 */
void Composer::compose_image()
{
	if (img.height() != (int)size_of_y ||
		img.width() != (int)size_of_x)
		img = CImg<unsigned char>((int)size_of_x, (int)size_of_y, 1, 3, 0);
	for (std::size_t i = 0; i < viss.size(); ++i)
	{
		update_image(i);
	}
}

/*! \brief Updates visualisation which_solution in composed image. Visualisation
 *  which_solution is updated from shown in position which_shown.
 *
 */
void Composer::update_image(std::size_t which_solution)
{
	cimg_forXYZC(shown[which_solution], x, y, z, c)
	{
		img(x + starting_x[which_solution], y + starting_y[which_solution], z, c) = 
			shown[which_solution](x, y, z, c);
	}
}

/*! \brief Updates visualisation which_solution in composed image. Visualisation
 *  which_solution is updated from shown in position which_shown. Pixels (x,y) 
 *  of shown, where sx <= x < ex and sy <= y < ey are updated into composed 
 *  image. 
 *
 */
void Composer::update_image(
	const int which_vis,
	const std::size_t sx,
	const std::size_t ex,
	const std::size_t sy,
	const std::size_t ey)
{
	if (which_vis == -1)
		return;

	for (int x = (int)sx; x < (int)ex; ++x)
	{
		for (int y = (int)sy; y < (int)ey; ++y)
		{
			for (int z = 0; z < shown[which_vis].depth(); ++z)
			{
				for (int c = 0; c < shown[which_vis].spectrum(); ++c)
				{
					img(x + starting_x[which_vis],
						y + starting_y[which_vis],
						z,
						c)
						= shown[which_vis](x, y, z, c);
				}
			}
		}
	}
}

/*! \brief Updates visualisation which_solution in composed image. Visualisation
 *  which_solution is updated from o. o has to have same
 *
 */
void Composer::update_image(
	const int which_vis,
	CImg<unsigned char>& o)
{
	if (which_vis == -1)
		return;

	if ((int)viss[which_vis].get_size_of_x() != o.width() ||
		(int)viss[which_vis].get_size_of_y() != o.height() ||
		img.spectrum() != o.spectrum() ||
		img.depth() != o.depth())
	{
		throw NotAllowedOperationException("updating visualisation from other CImg needs same width, height, spectrum, depth");
	}

	for (int x = 0; x < (int)viss[which_vis].get_size_of_x(); ++x)
	{
		for (int y = 0; y < (int)viss[which_vis].get_size_of_y(); ++y)
		{
			for (int z = 0; z < shown[which_vis].depth(); ++z)
			{
				for (int c = 0; c < shown[which_vis].spectrum(); ++c)
				{
					img(x + starting_x[which_vis],
						y + starting_y[which_vis],
						z,
						c)
						= o(x, y, z, c);
				}
			}
		}
	}
}

/*! \brief Updates CImg into from CImg from. Pixels are updated due to lower
 *  size of selected ranges.
 *
 */
void Composer::update(
	CImg<unsigned char>& into,
	const CImg<unsigned char>& from,
	const std::size_t into_sx,
	const std::size_t into_sy,
	const std::size_t into_ex,
	const std::size_t into_ey,
	const std::size_t from_sx,
	const std::size_t from_sy,
	const std::size_t from_ex,
	const std::size_t from_ey) const
{
	if (into.spectrum() != from.spectrum() || 
		into.depth() != from.depth())
	{
		throw NotAllowedOperationException("Images in update are supposed to have same spectrum and depth");
		return;
	}

	if (into_sx > into_ex ||
		into_sy > into_ey ||
		from_sx > from_ex ||
		from_sy > from_ey)
	{
		throw WrongDataException("Zero update range");
		return;
	}

	const std::size_t
		isx = std::min((std::size_t)into.width(), into_sx),
		iex = std::min((std::size_t)into.width(), into_ex),
		isy = std::min((std::size_t)into.height(), into_sy),
		iey = std::min((std::size_t)into.height(), into_ey),
		fsx = std::min((std::size_t)from.width(), from_sx),
		fex = std::min((std::size_t)from.width(), from_ex),
		fsy = std::min((std::size_t)from.height(), from_sy),
		fey = std::min((std::size_t)from.height(), from_ey);
	
	const std::size_t
		x_diff = std::min(iex - isx, fex - fsx),
		y_diff = std::min(iey - isy, fey - fsy);

	for (int x = 0; x < (int)x_diff; ++x)
	{
		for (int y = 0; y < (int)y_diff; ++y)
		{
			for (int z = 0; z < into.depth(); ++z)
			{
				for (int c = 0; c < into.spectrum(); ++c)
				{
					into(x + (int)isx, y + (int)isy, z, c) =
						from(x + (int)fsx, y + (int)fsy, z, c);
				}
			}
		}
	}
}

/*! \brief Event dispatching method. This method drives whole GUI.
 *
 */
void Composer::dispatch()
{
	if (viss.size() == 0)
	{
		throw WrongDataException("Nothing to visualise");
		return;
	}

	Color
		white_color(255, 255, 255),
		grey_color(127, 127, 127),
		red_color(240, 30, 0);

	int cur_vis = 0;
	change_color_of_border(cur_vis, red_color);
	for (int i = 0; i < (int)viss.size(); ++i)
	{
		if (i != cur_vis)
			change_color_of_border(i, grey_color);
	}

	int mouse_on_vis_previous = -1;

	const std::size_t font_size = 13;

	// for zoom
	const std::size_t min_selectable_x = 1;
	const std::size_t min_selectable_y = 1;

	bool
		// main differences
		endflag = false,					// end of visualisation
		solution_change = false,			// important difference, need new evaluation
		shown_change = true,				// shown needs to be changed
		image_change = true,				// part of composed image needs to be changed
		coordinates_change = false,			// mouse has moved
		started_selection = false,			// started selection
		selection_interrupted = false,		// selection was interrupted by user
		cur_vis_change = false,				// change of current visualiser
		all_vis_zoom = false,				// atempt of zooming all visualisations to same zoom

		approximation_fill_change = false,	// change of filling pixels in approximation
		exact_fill_change = false,			// turning on and off exact filling
		deep_evaluation_change = false,		// turning on and off deep evaluation
		show_edges_change = false,			// change showing edges of boxes for cur_vis
		show_approx_lines_change = false,	// change showing approximation lines
		tf_changes_denial_change = false,	// change of possibility of changing true and false boxes
		point_closering_depth_change = false,// change of point closering depth

		// show options
		show_help = true,					// show help to user
		show_coordinates = true,			// show coordinates of the mouse
		coordinates_up = true,				// if coordinates are shown up or down

		// starting of saving dialog
		saving_dialog = false,				// saving dialog launched
		save_all = false					// if composed image should be saved
		;

	// after action, time waited for another action
	const int waiting_time = 80;

	// mouse position
	int
		mx = -1,
		my = -1;

	// starting position of selection 
	int
		mselx = -1,
		msely = -1;

	// last position during selection
	int lastselx = -1,
		lastsely = -1;

	// managing events -> aprox is the most important!, when its true, 
	// ... image needs to be redrawed
	for (; !endflag;)
	{
		// THIS WILL SET ALL VISUALISERS TO THE SAME ZOOM IF POSSIBLE
		if (all_vis_zoom)
		{
			bool action_is_possible = true;

			for (std::size_t v = 0; v < viss.size(); ++v)
			{
				if ((int)v == cur_vis)
					continue;

				if (viss[v].get_total_max_y() < viss[cur_vis].get_zoomed_min_y() ||
					viss[v].get_total_min_y() > viss[cur_vis].get_zoomed_max_y() ||
					viss[v].get_total_max_y() < viss[cur_vis].get_zoomed_min_x() ||
					viss[v].get_total_min_x() > viss[cur_vis].get_zoomed_max_x())
				{
					clear_all_information();
					put_information("NOT POSSIBLE TO ZOOM INTO", white_color, cur_vis, font_size);
					action_is_possible = false;
					break;
				}
			}

			if (! action_is_possible)
			{
				all_vis_zoom = false;
				continue;
			}

			for (std::size_t v = 0; v < viss.size(); ++v)
			{
				if ((int)v == cur_vis)
					continue;

				viss[v].set_zoomed_min_x() = viss[cur_vis].get_zoomed_min_x();
				viss[v].set_zoomed_max_x() = viss[cur_vis].get_zoomed_max_x();
				viss[v].set_zoomed_min_y() = viss[cur_vis].get_zoomed_min_y();
				viss[v].set_zoomed_max_y() = viss[cur_vis].get_zoomed_max_y();
				viss[v].update_zoom();

				update_solution(v);
				update_shown(v);
				update_image(v);
			}

			all_vis_zoom = false;
		}

		// THIS WILL OPEN SAVING DIALOG
		if (saving_dialog)
		{
			saving_dialog = false;
			if (save_all)
			{
				change_color_of_border(cur_vis, grey_color);
				for (int i = 0; i < (int)viss.size(); ++i)
					update_image(i, shown[i]);
				run_saving_dialog(img, white_color);
				change_color_of_border(cur_vis, red_color);
			}
			else 
				run_saving_dialog(solutions[cur_vis], white_color);
		}

		// CHANGE CURRENT VISUALISER
		if (cur_vis_change)
		{
			shown_change = true;
			cur_vis_change = false;

			change_color_of_border(cur_vis, grey_color);
			update_shown(cur_vis);
			update_image(cur_vis);

			++cur_vis;
			cur_vis = cur_vis % viss.size();
			
			change_color_of_border(cur_vis, red_color);
		}

		// REDRAW SOLUTION
		if (solution_change)
		{
			solution_change = false;
			shown_change = true;

			update_solution(cur_vis);
		}

		// REDRAW SHOWN
		if (shown_change)
		{
			shown_change = false;
			image_change = true;

			update_shown(cur_vis);

			if (show_help)
			{
				show_help_menu(cur_vis);
			}
		}

		// REDRAW COMPOSED IMAGE
		if (image_change)
		{
			image_change = false;

			update_image(cur_vis);
		}

		// REMOVING ADDITIONAL INFO AFTER SELECTION INTERUPTION
		if (selection_interrupted)
		{
			selection_interrupted = false;

			// (mselx, msely) is starting point of selection
			// (mx, my) is ending point of selection

			clear_selection(
				mselx, msely,
				mx, my);
		}

		// ADDITIONAL INFO DURING SELECTION
		if (started_selection)
		{
			// (mselx, msely) is starting point of selection
			// (mx, my) is ending point of selection

			clear_selection(
				mselx, msely,
				lastselx, lastsely);

			draw_selection(
				mselx, msely,
				mx, my,
				grey_color);

			// update lastsel for delete when next time we will move mouse
			lastselx = mx;
			lastsely = my;
		}

		// ADDITIONAL INFO ABOUT COORDINATES OF MOUSE
		if (show_coordinates &&
			coordinates_change &&
			mx >= 0 &&
			my >= 0 &&
			mx < (int)size_of_x &&
			my < (int)size_of_y)
		{
			// clear old coordinates!
			clear_coordinates_info(
				mouse_on_vis_previous,
				font_size,
				coordinates_up);

			// draw coordinates!
			draw_coordinates_info(
				mx,
				my,
				coordinates_up,
				font_size,
				white_color);

			const int mouse_on_vis = which_visualiser(mx, my);
			mouse_on_vis_previous = mouse_on_vis;
		}

		// ADDITIONAL INFO ABOUT CHANGES
		if (approximation_fill_change)
		{
			approximation_fill_change = false;

			clear_all_information(cur_vis, font_size);
			put_information(viss[cur_vis].get_approximation_fill(), white_color, cur_vis, font_size);
		}
		else
		if (exact_fill_change)
		{
			exact_fill_change = false;

			clear_all_information(cur_vis, font_size);
			if (viss[cur_vis].exact_filling_allowed())
				put_information("EXACT FILLING ENABLED", white_color, cur_vis, font_size);
			else 
				put_information("EXACT FILLING DISABLED", white_color, cur_vis, font_size);
		}
		else
		if (deep_evaluation_change)
		{
			deep_evaluation_change = false;

			clear_all_information(cur_vis, font_size);
			if (viss[cur_vis].deep_evaluation_allowed())
				put_information("DEEP EVALUATION ENABLED", white_color, cur_vis, font_size);
			else
				put_information("DEEP EVALUATION DISABLED", white_color, cur_vis, font_size);
		}
		else
		if (show_edges_change)
		{
			show_edges_change = false;

			clear_all_information(cur_vis, font_size);
			if (viss[cur_vis].deep_evaluation_allowed())
				put_information("BOX EDGES SHOWN", white_color, cur_vis, font_size);
			else
				put_information("BOX EDGES HIDDEN", white_color, cur_vis, font_size);
		}
		else
		if (show_approx_lines_change)
		{
			show_approx_lines_change = false;

			clear_all_information(cur_vis, font_size);
			if (viss[cur_vis].approximated_lines_being_shown())
				put_information("APPROX LINES SHOWN", white_color, cur_vis, font_size);
			else
				put_information("APPROX LINES HIDDEN", white_color, cur_vis, font_size);
		}
		else
		if (tf_changes_denial_change)
		{
			tf_changes_denial_change = false;

			clear_all_information(cur_vis, font_size);
			if (viss[cur_vis].tf_changes_being_denied())
				put_information("CHANGES OF TRUE AND FALSE BOXES ARE FORBIDDEN", white_color, cur_vis, font_size);
			else
				put_information("CHANGES OF TRUE AND FALSE BOXES ARE ALLOWED", white_color, cur_vis, font_size);
		}
		else
		if (point_closering_depth_change)
		{
			point_closering_depth_change = false;

			clear_all_information(cur_vis, font_size);
			std::stringstream ss;
			ss << "POINT CLOSERING DEPTH SET AS " << viss[cur_vis].get_point_closering_depth();
			put_information(ss.str(), white_color, cur_vis, font_size);
		}

		// SHOW IMAGE
		display.display(img);

		// WAITING FOR EVENT
		display.wait();

		// SELECTION BY MOUSE
		// Get rectangular shape from the user to define the zoomed region.
		const int
			nmx = display.mouse_x(),
			nmy = display.mouse_y();

		if (mx == nmx &&
			my == nmy)
		{
			coordinates_change = false;
		}
		else
		{
			coordinates_change = true;

			mx = nmx;
			my = nmy;
		}

		// check for continue
		bool cont = false;

		// selection has started now
		if (!started_selection && (display.button() & 1))
		{
			int in_which_vis = which_visualiser(mx, my);
			if (in_which_vis == cur_vis)
			{
				started_selection = true;

				mselx = mx;
				msely = my;
				lastselx = mx;
				lastsely = my;
			}
			else
			{
				if (in_which_vis != -1)
				{
					std::stringstream ss;
					ss << "Selection enabled only for selected visualisation";
					std::string s = ss.str();
					clear_all_information(in_which_vis, font_size);
					put_information(s, white_color, in_which_vis, font_size);
				}
			}

			cont = true;
		}

		// selection has started but was stopped now
		if (started_selection && (display.button() & 2))
		{
			selection_interrupted = true;
			started_selection = false;

			cont = true;
		}

		// selection has finished now
		if (started_selection && !(display.button() & 1))
		{
			started_selection = false;

			int start_vis = which_visualiser(mselx, msely);
			int end_vis = which_visualiser(nmx, nmy);

			if (cur_vis == start_vis &&
				cur_vis == end_vis)
			{
				std::pair<std::pair<int, int>, std::pair<int, int> > zoomed_coords =
					gain_possible_selection(mselx, msely, nmx, nmy);

				const int
					sx = zoomed_coords.first.first,
					sy = zoomed_coords.first.second,
					ex = zoomed_coords.second.first,
					ey = zoomed_coords.second.second;

				// ZOOMing
				if (sx != -1 &&
					sy != -1 &&
					ex != -1 &&
					ey != -1)
				{
					solution_change = true;

					if (ex - sx > min_selectable_x &&
						ey - sy > min_selectable_y)
					{
						zoom(cur_vis, sx, sy, ex, ey);
					}
					else
					{
						viss[cur_vis].reset_zoom();
					}
				}
			}

			cont = true;
		}

		// if cont then continue
		if (cont)
			continue;

		// KEYBOARD ACTION
		// Also, test if a key has been pressed.
		switch (display.key(0))
		{

			// ======= SELECTED VISUALISER CHANGE =======

			// Selecting next solution.
		case::cimg::keyTAB:
			cur_vis_change = true;
			display.wait(waiting_time);
			break;

			// ============ SOLUTION CHANGE =============

			// Draw original image.
		case cimg::key1:
			viss[cur_vis].set_visualisation_type(0);
			viss[cur_vis].set_sampling_method(0);
			viss[cur_vis].set_approximating_method(0);
			solution_change = true;
			display.wait(waiting_time);
			break;

		case cimg::key2:
			int sel_vt;
			int sel_sm;
			int sel_am;

			clear_coordinates_info(
				which_visualiser(mx, my), 
				font_size, 
				coordinates_up);

			sel_vt = show_visualisation_types(cur_vis);
			if (sel_vt == -1)
				break;
			// original was selected
			if (sel_vt == 0)
			{
				viss[cur_vis].set_visualisation_type(0);
				viss[cur_vis].set_sampling_method(0);
				viss[cur_vis].set_approximating_method(0);
				solution_change = true;
				display.wait(waiting_time);
				continue;
			}
			display.wait(waiting_time);

			sel_sm = show_sampling_methods(cur_vis);
			if (sel_sm == -1)
				break;
			display.wait(waiting_time);

			sel_am = show_approximating_methods(cur_vis);
			if (sel_am == -1)
				break;
			display.wait(waiting_time);

			solution_change = true;
			viss[cur_vis].set_visualisation_type(sel_vt);
			viss[cur_vis].set_sampling_method(sel_sm);
			viss[cur_vis].set_approximating_method(sel_am);
			
			break;

			// Change of point closering depth
		case cimg::key3:
			solution_change = true;
			point_closering_depth_change = true;

			if (viss[cur_vis].get_point_closering_depth() == 0)
				viss[cur_vis].set_point_closering_depth(2);
			else
			if (viss[cur_vis].get_point_closering_depth() == 2)
				viss[cur_vis].set_point_closering_depth(5);
			else 
			if (viss[cur_vis].get_point_closering_depth() == 5)
				viss[cur_vis].set_point_closering_depth(0);

			display.wait(waiting_time);
			break;

			// Resize picture on default value
		case cimg::keyR:
			solution_change = true;

			display.resize((int)base_size_of_x, (int)base_size_of_y);
			resize(base_size_of_x, base_size_of_y);
			display.wait(waiting_time);
			break;

			// Move zoomed window to the left
		case cimg::keyARROWLEFT:
			solution_change = true;

			move_zoom(DIRECTION_MOVE::LEFT, cur_vis);
			display.wait(waiting_time);
			break;

			// Move zoomed window to the right
		case cimg::keyARROWRIGHT:
			solution_change = true;

			move_zoom(DIRECTION_MOVE::RIGHT, cur_vis);
			display.wait(waiting_time);
			break;

			// Move zoomed window up
		case cimg::keyARROWUP:
			solution_change = true;

			move_zoom(DIRECTION_MOVE::UP, cur_vis);
			display.wait(waiting_time);
			break;

			// Move zoomed window down
		case cimg::keyARROWDOWN:
			solution_change = true;

			move_zoom(DIRECTION_MOVE::DOWN, cur_vis);
			display.wait(waiting_time);
			break;

			// Show/hide edges of boxes
		case cimg::keyG:
			show_edges_change = true;
			solution_change = true;

			if (! viss[cur_vis].boxes_edges_being_shown())
			{
				viss[cur_vis].show_boxes_edges();
			}
			else
			{
				viss[cur_vis].hide_boxes_edges();
			}
			display.wait(waiting_time);
			break;

			// Change approximation fill 
		case cimg::keyF:
			solution_change = true;
			approximation_fill_change = true;

			viss[cur_vis].change_approximation_fill();
			display.wait(waiting_time);
			break;

			// Enable/Disable exact filling 
		case cimg::keyE:
			solution_change = true;
			exact_fill_change = true;

			if (viss[cur_vis].exact_filling_allowed())
				viss[cur_vis].disable_exact_filling();
			else
				viss[cur_vis].enable_exact_filling();
			display.wait(waiting_time);
			break;

			// Enable/Disable deep evaluation
		case cimg::keyD:
			solution_change = true;
			deep_evaluation_change = true;

			if (viss[cur_vis].deep_evaluation_allowed())
				viss[cur_vis].disable_deep_evaluation();
			else
				viss[cur_vis].enable_deep_evaluation();
			viss[cur_vis].adjust_tolerance();

			display.wait(waiting_time);
			break;

			// Sets zooms all visualisations equal to zoom of current 
			// visualisation one if it's possible 
		case cimg::keyT:
			all_vis_zoom = true;
			display.wait(waiting_time);
			break;

			// Show/Hide approximated lines
		case cimg::keyA:
			solution_change = true;
			show_approx_lines_change = true;

			if (viss[cur_vis].approximated_lines_being_shown())
				viss[cur_vis].hide_approximated_lines();
			else
				viss[cur_vis].show_approximated_lines();
			display.wait(waiting_time);
			break;

			// Allow/Deny changes of true/false boxes
		case cimg::keyX:
			solution_change = true;
			tf_changes_denial_change = true;

			if (viss[cur_vis].tf_changes_being_denied())
				viss[cur_vis].allow_tf_changes();
			else
				viss[cur_vis].deny_tf_changes();
			display.wait(waiting_time);
			break;

			// ============== SHOWN CHANGE ==============

			// Show/Hide help.
		case cimg::keyH:
			shown_change = true;

			show_help = !show_help;
			display.wait(waiting_time);
			break;

			// Show/Hide coordinates information
		case cimg::keyC:
			shown_change = true;

			show_coordinates = !show_coordinates;
			break;

			// ============= SAVING DIALOG ==============

			// Run saving dialog
		case cimg::keyS: 
			save_all = false;
			saving_dialog = true;
			break;

			// Run saving dialog
		case cimg::keyO:
			save_all = true;
			saving_dialog = true;
			break;

		default: 
			//display.set_key();
			break;
		} // end switch

		// END OF VISUALISATION
		if (display.is_closed() ||
			display.is_keyQ() ||
			display.is_keyESC())
			endflag = true;

		display.set_key();
	} // end for
}

/*! \brief This method will start GUI.
 *
 */
void Composer::visualise(
	const std::size_t width,
	const std::size_t height)
{
	if (viss.size() == 0)
	{
		throw WrongDataException("Nothing to visualise");
		return;
	}

	if (viss.size() == 1)
	{
		border_size = 0;
	}

	resize(width, height);
	base_size_of_x = width;
	base_size_of_y = height;

	solutions.clear();
	for (std::size_t i = 0; i < viss.size(); ++i)
	{
		solutions.push_back(viss[i].get_visualisation());
		shown.push_back(solutions[i]);
	}

	compose_image();
	display = CImgDisplay((int)width, (int)height);
	display.display(img);

	dispatch();
}

/*! \brief This method will construct visualiser from files and add amongst 
 *  the other visualisers.
 *
 */
void Composer::add_visualiser(const std::vector<std::string>& file_names)
{
	if (max_size_of_viss == viss.size())
	{
		throw new NotAllowedOperationException("Maximum allowed visualisers already set");
		return;
	}

	viss.emplace_back(file_names);
}

/*! \brief This method will construct visualiser from files and add amongst 
 *  the other visualisers.
 *
 */
void Composer::add_visualiser(
	const std::string& t_file,
	const std::string& u_file,
	const std::string& f_file)
{
	if (max_size_of_viss == viss.size())
	{
		throw new NotAllowedOperationException("Maximum allowed visualisers already set");
		return;
	}

	viss.emplace_back(t_file, u_file, f_file);
}

/*! \brief This method will construct visualiser from values and add amongst 
 *  the other visualisers.
 *
 */
void Composer::add_visualiser(
	const std::vector<std::vector<DataType> >& vectors)
{
	if (max_size_of_viss == viss.size())
	{
		throw new NotAllowedOperationException("Maximum allowed visualisers already set");
		return;
	}

	viss.emplace_back(vectors);
}

/*! \brief This method will construct visualiser from values and add amongst 
 *  the other visualisers.
 *
 */
void Composer::add_visualiser(
	const std::vector<Box>& t_boxes,
	const std::vector<Box>& u_boxes,
	const std::vector<Box>& f_boxes)
{
	if (max_size_of_viss == viss.size())
	{
		throw new NotAllowedOperationException("Maximum allowed visualisers already set");
		return;
	}

	viss.emplace_back(t_boxes, u_boxes, f_boxes);
}