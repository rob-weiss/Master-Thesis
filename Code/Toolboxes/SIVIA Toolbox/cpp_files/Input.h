#ifndef _INPUT_HPP
#define _INPUT_HPP

#include <istream>
#include <fstream>
#include <vector>
#include <string>
#include <ctype.h>

#include "Box.h"
#include "Interval.h"
#include "StreamReader.h"
#include "WrongInputException.h"

/*! \brief Returns intvals created from data of type T in vectors.
 *
 */
template <typename T>
std::vector<Interval> get_intvals_impl_from_input(
	const std::vector<T>& first, 
	const std::vector<T>& second)
{
	std::vector<Interval> intvals;
	if (first.size() == second.size())
	{
		for (size_t i = 0; i < first.size(); ++i)
		{
			Interval n = Interval(first[i], second[i]);
			intvals.push_back(n);
		}
	}
	else
	{
		throw WrongInputException("Input.h -> std::vector<Interval> get_intvals_impl_from_files(std::string&,std::string&) ... files do not contain the same count of intvals");
	}
	return intvals;
};

/*! \brief Returns boxes created from data of type T in vectors.
 *
 */
template <typename T>
std::vector<Box> get_boxes_impl_from_input(
	const std::vector<T>& x_first, 
	const std::vector<T>& x_second, 
	const std::vector<T>& y_first, 
	const std::vector<T>& y_second)
{
	std::vector<Interval> x_coordinate(get_intvals_impl_from_input<T>(x_first, x_second));
	std::vector<Interval> y_coordinate(get_intvals_impl_from_input<T>(y_first, y_second));

	std::vector<Box> boxes;
	if (x_coordinate.size() == y_coordinate.size())
	{
		for (size_t i = 0; i < x_coordinate.size(); ++i)
		{
			Box n = Box(x_coordinate[i], y_coordinate[i]);
			boxes.push_back(n);
		}
	}
	else
	{
		throw WrongInputException("Input.h -> std::vector<Box> get_boxes_impl_from_files(std::string&,std::string&,std::string&,std::string&) ... input files do not contain the same count of intvals");
	}
	return boxes;
};

/*! \brief Returns data of type T from stream.
 *
 */
template <typename T>
std::vector<T> get_typenames_from_stream(
	std::istream& input)
{
	StreamReader<T> reader = StreamReader<T>(input);
	reader.read_content();
	std::vector<T> content = reader.get_content();
	return content;
}

/*! \brief Returns data of type T from file.
 *
 */
template <typename T>
std::vector<T> get_typenames_from_file(
	std::ifstream& input)
{
	return get_typenames_from_stream<T>(input);
}

/*! \brief Returns data of type T from file with filename input.
 *
 */
template <typename T>
std::vector<T> get_typenames_from_file(
	const std::string& input)
{
	std::ifstream ifs(input.c_str());
	if (!ifs.good())
	{
		throw WrongInputException("Input.h -> std::vector<T> get_typename_from_file(std::string&) ... missing input file or cannot read input file or damaged file");
	}
	std::vector<T> read_typenames(get_typenames_from_file<T>(ifs));
	ifs.close();
	return read_typenames;
}

/*! \brief Returns intervals created from data of type T from streams.
 *
 */
template <typename T>
std::vector<Interval> get_intvals_impl_from_streams(
	std::istream& first, 
	std::istream& second)
{
	std::vector<T> new_first(get_typenames_from_stream<T>(first));
	std::vector<T> new_second(get_typenames_from_stream<T>(second));

	std::vector<Interval> intvals;
	if (new_first.size() == new_second.size())
	{
		for (size_t i = 0; i < new_first.size(); ++i)
		{
			Interval n = Interval(new_first[i], new_second[i]);
			intvals.push_back(n);
		}
	}
	else
	{
		throw WrongInputException("Input.h -> std::vector<<Interval> get_intvals_impl_from_streams(std::stream&,std::stream&) ... input streams or files does not contain the same count of intvals");
	}
	return intvals;
};

/*! \brief Returns intervals created from data of type T from files.
 *
 */
template <typename T>
std::vector<Interval> get_intvals_impl_from_files(
	std::ifstream& first, 
	std::ifstream& second)
{
	return get_intvals_impl_from_streams<T>(first, second);
}

/*! \brief Returns intervals created from data of type T from files with 
 *  filenames first and second.
 *
 */
template <typename T>
std::vector<Interval> get_intvals_impl_from_files(
	const std::string& first, 
	const std::string& second)
{
	std::vector<T> new_first(get_typenames_from_file<T>(first));
	std::vector<T> new_second(get_typenames_from_file<T>(second));

	std::vector<Interval> intvals;
	if (new_first.size() == new_second.size())
	{
		for (size_t i = 0; i < new_first.size(); ++i)
		{
			Interval n = Interval(new_first[i], new_second[i]);
			intvals.push_back(n);
		}
	}
	else
	{
		throw WrongInputException("Input.h -> std::vector<Interval> get_intvals_impl_from_files(std::string&,std::string&) ... files do not contain the same count of intvals");
	}
	return intvals;
}

/*! \brief Returns intvals created from data of type T from file with
 *  filename name. 
 *
 */
template <typename T>
std::vector<Interval> get_intvals_impl_from_file(
	const std::string& name)
{
	std::vector<T> values(get_typenames_from_file<T>(name));

	if (values.size() % 2 != 0)
	{
		throw WrongInputException("Input.h -> std::vector<Interval> get_intvals_impl_from_file(std::string&) ... not possible to make intervals from file");
	}

	std::vector<Interval> intvals;
	std::size_t count = values.size() / 2;
	for (size_t i = 0; i < count; ++i)
	{
		Interval n = Interval(
			values[i],
			values[i + count]);
		intvals.push_back(n);
	}
	
	return intvals;
};


/*! \brief Returns boxes created from data of type T from streams.
 *
 */
template <typename T>
std::vector<Box> get_boxes_impl_from_streams(
	std::istream& x_first, 
	std::istream& x_second, 
	std::istream& y_first, 
	std::istream& y_second)
{
	std::vector<Interval> x_coordinate(get_intvals_impl_from_streams<T>(x_first, x_second));
	std::vector<Interval> y_coordinate(get_intvals_impl_from_streams<T>(y_first, y_second));

	std::vector<Box> boxes;
	if (x_coordinate.size() == y_coordinate.size())
	{
		for (size_t i = 0; i < x_coordinate.size(); ++i)
		{
			Box n = Box(x_coordinate[i], y_coordinate[i]);
			boxes.push_back(n);
		}
	}
	else
	{
		throw WrongInputException("Input.h -> std::vector<Box> get_boxes_impl_from_streams(std::stream&,std::stream&,std::stream&,std::stream&) ... input streams or files do not contain the same count of intvals");
	}
	return boxes;
};

/*! \brief Returns boxes created from data of type T from files.
 *
 */
template <typename T>
std::vector<Box> get_boxes_impl_from_files(
	std::ifstream& x_first, 
	std::ifstream& x_second, 
	std::ifstream& y_first, 
	std::ifstream& y_second)
{
	return get_boxes_impl_from_streams<T>(x_first, x_second, y_first, y_second);
}

/*! \brief Returns boxes created from data of type T from files with 
 *  filenames x_first, x_second and y_first, y_second.
 *
 */
template <typename T>
std::vector<Box> get_boxes_impl_from_files(
	const std::string& x_first, 
	const std::string& x_second, 
	const std::string& y_first, 
	const std::string& y_second)
{
	std::vector<Interval> x_coordinate(get_intvals_impl_from_files<T>(x_first, x_second));
	std::vector<Interval> y_coordinate(get_intvals_impl_from_files<T>(y_first, y_second));

	std::vector<Box> boxes;
	if (x_coordinate.size() == y_coordinate.size())
	{
		for (size_t i = 0; i < x_coordinate.size(); ++i)
		{
			Box n = Box(x_coordinate[i], y_coordinate[i]);
			boxes.push_back(n);
		}
	}
	else
	{
		throw WrongInputException("Input.h -> std::vector<Box> get_boxes_impl_from_files(std::string&,std::string&,std::string&,std::string&) ... input files do not contain the same count of intvals");
	}
	return boxes;
};

/*! \brief Returns boxes created from data of type T from file with
 *  filename name. 
 *
 */
template <typename T>
std::vector<Box> get_boxes_impl_from_file(
	const std::string& name)
{
	std::vector<T> values(get_typenames_from_file<T>(name));

	if (values.size() % 4 != 0)
	{
		throw WrongInputException("Input.h -> std::vector<Box> get_boxes_impl_from_file(std::string&) ... not possible to make boxes from file");
	}

	std::vector<Box> boxes;
	std::size_t count = values.size() / 4;
	for (size_t i = 0; i < count; ++i)
	{
		Box n = Box(
			values[i], 
			values[i + count], 
			values[i + 2 * count], 
			values[i + 3 * count]);
		boxes.push_back(n);
	}
	
	return boxes;
};

#endif