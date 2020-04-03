// DO TO !!! rework sample_borders - tak aby bordery boli spravne!
// DO TO !!! prepisat algoritmus subdivision!!! 
// DO TO !!! popridavat vsade aj borders medzi true/false
// DO TO !!! DataSet prerobit na vyuzivanie BoxProccessoru
// DO TO !!! Input.h tasks
// DO TO !!! Painter.h tasks
// DO TO !!! Sampler.h tasks
// DO TO !!! SetApproximer.h tasks
// DO TO !!! Math.h tasks
// DO TO !!! Visualiser.h tasks
// DO TO !!! Composer.h tasks
// DO TO !!! StreamReader - premenovat #define alebo streamreader
// DO TO !!! StreamReader - odchytavanie vynimky
// DO TO !!! resizing
// DO TO !!! spravit po selecte boxov, aby ked tak boli lepsie poi
//           napriklad tym, ze cesty dodatocne splitnem, ak je treba
// DO TO !!! exceptions pre matlab!!!!
// DO TO !!! odchytavanie vynimiek
// DO TO !!! main_hander vyriesit
// DO TO !!! Composer show_settings
// DO TO !!! run saving dialog in command line?
// DO TO !!! nieco na status riesenia (v composeri vyrobit)
// DO TO !!! try catch block na dispatch()
// DO TO !!! utIsInterruptPending()
// DO TO !!! SetApproximer -> zakomentovat throw new WrongDataException("BoxKind of polygon is ambigious"); 
//           a nastavit tam nejaku special fail hodnotu

//std::string s_ellipse("D:\\testing\\bc_testing_run\\elipse_");
//std::string s_line("D:\\testing\\bc_testing_run\\line_");
//std::string s_parabola("D:\\testing\\bc_testing_run\\parabola_");
//std::string s_scurve("D:\\testing\\bc_testing_run\\scurve_");
//std::string s_hearth("D:\\testing\\bc_testing_run\\hearth_");
//std::string s_inverse("D:\\testing\\bc_testing_run\\inverse_");
//std::string s_sincos("D:\\testing\\bc_testing_run\\sincos_");
//std::string s_scarab("D:\\testing\\bc_testing_run\\scarab_");

// 1 300 300 "filenp" "D:\testing\bc_testing_run\elipse_" ".txt"
// 1 300 300 "fileb" "D:\testing\text_t.txt" "D:\testing\text_u.txt" "D:\testing\text_f.txt"

#include "Handlers.h"

#include <iostream>
#include <string>
#include <sstream>
#include <vector>

#include "Composer.h"
#include "MatlabLayer.h"
#include "WrongDataException.h"
#include "WrongInputFormatException.h"

using namespace cimg_library;

/*! \brief main handler. This is handler for main function called from 
 *  the command line catching exceptions.
 *
 *  1. parameter => count of the visualisations
 *  2. parameter => size_of_x
 *  3. parameter => size_of_y
 *  next parameters => type of input, parameters for input; ....
 */
int main_handler_tc(int argc, char * argv[])
{
	try
	{
		return main_handler(argc, argv);
	}
	catch (std::exception e)
	{
		ExportString(e.what());
		throw e;
	}
	return 0;
}

/*! \brief main handler. This is handler for main function called from 
 *  the command line.
 *
 *  1. parameter => count of the visualisations
 *  2. parameter => size_of_x
 *  3. parameter => size_of_y
 *  next parameters => type of input, parameters for input; ....
 */
int main_handler(int argc, char * argv[])
{
	std::vector<std::string> params(argv, argv + argc);
	// since first argument is name of file or empty string, we will delete it
	params.erase(params.begin());

	if (params.size() <= 3)
	{
		throw new WrongInputFormatException("Not enough parameters");
		return 0;
	}

	int vis_count = 0;
	std::stringstream ss_name(params[0]);
	ss_name >> vis_count;

	int size_of_x = 0;
	std::stringstream ss_x_size(params[1]);
	ss_x_size >> size_of_x;

	int size_of_y = 0;
	std::stringstream ss_y_size(params[2]);
	ss_y_size >> size_of_y;

	if (vis_count <= 0 ||
		size_of_x <= 0 ||
		size_of_y <= 0)
	{
		throw new WrongDataException("Wrong basic parameters");
		return 0;
	}

	Composer composer(vis_count);

	int vis_done = 0;
	std::size_t param = 3;
	for (;; ++param)
	{
		if (vis_done >= vis_count || param >= params.size())
		{
			break;
		}

		std::string vis_input_type = params[param];

		// ..., "file", name of 12 files, ...
		//		Tx1, Tx2, Ty1, Ty2, Ux1, Ux2, Uy1, Uy2, Fx1, Fx2, Fy1, Fy2
		//		files hold separated values of solver in that order
		if (vis_input_type == "file")
		{
			if (param + 12 >= params.size())
			{
				throw new WrongInputFormatException("Not enough parameters");
				return 0;
			}

			++param;
			const std::string
				tx1 = params[param++],
				tx2 = params[param++],
				ty1 = params[param++],
				ty2 = params[param++],
				ux1 = params[param++],
				ux2 = params[param++],
				uy1 = params[param++],
				uy2 = params[param++],
				fx1 = params[param++],
				fx2 = params[param++],
				fy1 = params[param++],
				fy2 = params[param];

			const std::vector<std::string> files{
				tx1, tx2, ty1, ty2,
				ux1, ux2, uy1, uy2,
				fx1, fx2, fy1, fy2 };

			composer.add_visualiser(files);
			++vis_done;
		}

		// ..., "filenp", name of files, postfix of files, ...
		//		12 files on disc will be searched as name+type+postfix, 
		//		where type is in variable file_desc in this if
		if (vis_input_type == "filenp")
		{
			if (param + 2 >= params.size())
			{
				throw new WrongInputFormatException("Not enough parameters");
				return 0;
			}

			++param;
			const std::string
				file_name = params[param++],
				file_postfix = params[param];

			std::vector<std::string> file_desc = {
				"tx1", "tx2", "ty1", "ty2",
				"ux1", "ux2", "uy1", "uy2",
				"fx1", "fx2", "fy1", "fy2"
			};

			std::stringstream ss;
			std::vector<std::string> file_names;
			for (int i = 0; i < 12; ++i)
			{
				ss.str(std::string());
				ss << file_name << file_desc[i] << file_postfix;
				file_names.push_back(ss.str());
			}

			composer.add_visualiser(file_names);
			++vis_done;
		}

		// ..., "fileb", name of 3 files (T, U, F), ...
		//		files contain boxes from solver as x1, x2, y1, y2 
		//		each value of x1 in separated row, then x2, y1, y2
		if (vis_input_type == "fileb")
		{
			if (param + 3 >= params.size())
			{
				throw new WrongInputFormatException("Not enough parameters");
				return 0;
			}

			++param;
			const std::string
				t_name = params[param++],
				u_name = params[param++],
				f_name = params[param];

			composer.add_visualiser(t_name, u_name, f_name);
			++vis_done;
		}

	}

	if (vis_done != vis_count && param != params.size())
	{
		throw new WrongInputFormatException("Not enough parameters");
		return 0;
	}

	composer.visualise(size_of_x, size_of_y);

	return 0;
}

#ifdef MATLAB_RELEASE

#include <matrix.h>
#include <mex.h>

/*! \brief mexFunction handler. This is handler for main function of Mex files 
 *  called in matlab catching expcetions.
 *
 *  1. parameter => count of the visualisations
 *  2. parameter => size_of_x
 *  3. parameter => size_of_y
 *  next parameters => type of input, parameters for input; ....
 */
void mexFunction_handler_tc(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	try
	{
		mexFunction_handler(nlhs, plhs, nrhs, prhs);
		return;
	}
	catch (std::exception e)
	{
		std::stringstream ss;
		ss << e.what() << std::endl;
		ExportString(ss.str());
		throw e;
	}
	return;
}

/*! \brief mexFunction handler. This is handler for main function of Mex files 
 *  called in matlab.
 *
 *  1. parameter => count of the visualisations
 *  2. parameter => size_of_x
 *  3. parameter => size_of_y
 *  next parameters => type of input, parameters for input; ....
 */
void mexFunction_handler(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if (nrhs <= 3)
	{
		throw new WrongInputFormatException("Not enough parameters");
		return;
	}

	int vis_count = (int)std::round(GetDouble(prhs[0]));
	int size_of_x = (int)std::round(GetDouble(prhs[1]));
	int size_of_y = (int)std::round(GetDouble(prhs[2]));

	if (vis_count <= 0 ||
		size_of_x <= 0 ||
		size_of_y <= 0)
	{
		throw new WrongDataException("Wrong basic parameters");
		return;
	}

	Composer composer(vis_count);
	
	int vis_done = 0;
	int param = 3;
	for (; ; ++param)
	{
		if (vis_done >= vis_count || param >= nrhs)
		{
			break;
		}

		std::string vis_input_type = GetString(prhs[param]);

		// ..., "matlab", 12 vectors, ...
		//		Tx1, Tx2, Ty1, Ty2, Ux1, Ux2, Uy1, Uy2, Fx1, Fx2, Fy1, Fy2
		//		files hold separated values of solver in that order
		if (vis_input_type == "matlab")
		{
			if (param + 12 >= nrhs)
			{
				throw new WrongInputFormatException("Not enough parameters");
				return;
			}

			++param;
			const std::vector<double> 
				tx1 = GetVector(*(prhs + (param++))),
				tx2 = GetVector(*(prhs + (param++))),
				ty1 = GetVector(*(prhs + (param++))),
				ty2 = GetVector(*(prhs + (param++))),
				ux1 = GetVector(*(prhs + (param++))),
				ux2 = GetVector(*(prhs + (param++))),
				uy1 = GetVector(*(prhs + (param++))),
				uy2 = GetVector(*(prhs + (param++))),
				fx1 = GetVector(*(prhs + (param++))),
				fx2 = GetVector(*(prhs + (param++))),
				fy1 = GetVector(*(prhs + (param++))),
				fy2 = GetVector(*(prhs + (param)));

			const std::vector<std::vector<double> > vectors { 
				tx1, tx2, ty1, ty2,
				ux1, ux2, uy1, uy2,
				fx1, fx2, fy1, fy2};

			composer.add_visualiser(vectors);
			++vis_done;
		}

		// ..., "file", name of 12 files, ...
		//		Tx1, Tx2, Ty1, Ty2, Ux1, Ux2, Uy1, Uy2, Fx1, Fx2, Fy1, Fy2
		//		files hold separated values of solver in that order
		if (vis_input_type == "file")
		{
			if (param + 12 >= nrhs)
			{
				throw new WrongInputFormatException("Not enough parameters");
				return;
			}

			++param;
			const std::string
				tx1 = GetString(prhs[param++]),
				tx2 = GetString(prhs[param++]),
				ty1 = GetString(prhs[param++]),
				ty2 = GetString(prhs[param++]),
				ux1 = GetString(prhs[param++]),
				ux2 = GetString(prhs[param++]),
				uy1 = GetString(prhs[param++]),
				uy2 = GetString(prhs[param++]),
				fx1 = GetString(prhs[param++]),
				fx2 = GetString(prhs[param++]),
				fy1 = GetString(prhs[param++]),
				fy2 = GetString(prhs[param]);

			const std::vector<std::string> files { 
				tx1, tx2, ty1, ty2,
				ux1, ux2, uy1, uy2,
				fx1, fx2, fy1, fy2};

			composer.add_visualiser(files);
			++vis_done;
		}

		// ..., "filenp", name of files, postfix of files, ...
		//		12 files on disc will be searched as name+type+postfix, 
		//		where type is in variable file_desc in this if
		if (vis_input_type == "filenp")
		{
			if (param + 2 >= nrhs)
			{
				throw new WrongInputFormatException("Not enough parameters");
				return;
			}

			++param;
			const std::string
				file_name    = GetString(prhs[param++]),
				file_postfix = GetString(prhs[param]);

			std::vector<std::string> file_desc = {
				"tx1", "tx2", "ty1", "ty2",
				"ux1", "ux2", "uy1", "uy2",
				"fx1", "fx2", "fy1", "fy2"
			};

			std::stringstream ss;
			std::vector<std::string> file_names;
			for (int i = 0; i < 12; ++i)
			{
				ss.str(std::string());
				ss << file_name << file_desc[i] << file_postfix;
				file_names.push_back(ss.str());
			}

			composer.add_visualiser(file_names);
			++vis_done;
		}

		// ..., "fileb", name of 3 files (T, U, F), ...
		//		files contain boxes from solver as x1, x2, y1, y2 
		//		each value of x1 in separated row, then x2, y1, y2
		if (vis_input_type == "fileb")
		{
			if (param + 3 >= nrhs)
			{
				throw new WrongInputFormatException("Not enough parameters");
				return;
			}

			++param;
			const std::string
				t_name = GetString(prhs[param++]),
				u_name = GetString(prhs[param++]),
				f_name = GetString(prhs[param]);

			composer.add_visualiser(t_name, u_name, f_name);
			++vis_done;
		}

	}

	if (vis_done != vis_count && param != nrhs)
	{
		throw new WrongInputFormatException("Not enough parameters");
		return;
	}

	composer.visualise(size_of_x, size_of_y);
}

//
////+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#endif // MATLAB_RELEASE