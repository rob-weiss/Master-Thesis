#ifndef _COLOR_HPP
#define _COLOR_HPP

#include <array>
#include <utility>

class Color
{

/*
 ******************************************************************************
 ************************************ RAW DATA ********************************
 ******************************************************************************
 */

protected:
	// COLOR IN RGB
	std::array<unsigned char,3> data; // [red, green, blue]

/*
 ******************************************************************************
 ********************************** CONSTRUCTORS ******************************
 ******************************************************************************
 */

public:
	Color();

	Color(const Color& c);

	Color(Color&& c);

	Color(unsigned char red, unsigned char green, unsigned char blue);

/*
 ******************************************************************************
 *********************************** OPERATORS ********************************
 ******************************************************************************
 */

public:
	unsigned char& operator[](std::size_t k);

	Color& operator=(const Color& c);

	Color& operator=(Color&& c);

/*
 ******************************************************************************
 *********************************** DATA ACCESS ******************************
 ******************************************************************************
 */

public:
	unsigned char get_R() const;

	unsigned char get_G() const;

	unsigned char get_B() const;

	const unsigned char* get_data() const;

	unsigned char& set_R();

	unsigned char& set_G();

	unsigned char& set_B();

	unsigned char* set_data();
 
};

#endif