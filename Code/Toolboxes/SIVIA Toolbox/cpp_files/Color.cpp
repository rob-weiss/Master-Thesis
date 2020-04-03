#include "Color.h"

#include <utility>

/*
 ******************************************************************************
 ********************************** CONSTRUCTORS ******************************
 ******************************************************************************
 */

/*! \brief Constructor.
 *
 */
Color::Color()
{
	data[0] = 0; 
	data[1] = 0; 
	data[2] = 0;
}

/*! \brief Copy constructor.
 *
 */
Color::Color(const Color& c)
{
	data[0] = c.data[0]; 
	data[1] = c.data[1]; 
	data[2] = c.data[2];
}

/*! \brief Move constructor.
 *
 */
Color::Color(Color&& c)
{
	data[0] = c.data[0]; 
	data[1] = c.data[1]; 
	data[2] = c.data[2];
}

/*! \brief Creates color.
 *
 */
Color::Color(unsigned char red, 
			 unsigned char green, 
			 unsigned char blue)
{
	data[0] = red; 
	data[1] = green; 
	data[2] = blue;
}

/*
 ******************************************************************************
 *********************************** OPERATORS ********************************
 ******************************************************************************
 */

/*! \brief Returns color with reference. [0]~R(), [1]~G(), [2]~B()
 *
 */
unsigned char& Color::operator[](std::size_t k)
{
	return data[k];
}

/*! \brief Assign operator.
 *
 */
Color& Color::operator=(const Color& c)
{
	data[0] = c.data[0]; 
	data[1] = c.data[1]; 
	data[2] = c.data[2];
	return *this;
}

/*! \brief Move assignment operator.
 *
 */
Color& Color::operator=(Color&& c)
{
	data[0] = c.data[0];
	data[1] = c.data[1];
	data[2] = c.data[2];
	return *this;
}

/*
 ******************************************************************************
 ******************************** SAFE DATA ACCESS  ***************************
 ******************************************************************************
 */

/*! \brief Returns red color.
 *
 */
unsigned char Color::get_R() const
{
	return data[0];
}

/*! \brief Returns green color.
 *
 */
unsigned char Color::get_G() const
{
	return data[1];
}

/*! \brief Returns blue color.
 *
 */
unsigned char Color::get_B() const
{
	return data[2];
}

/*! \brief Returns data with const pointer.
 *
 */
const unsigned char* Color::get_data() const
{
	return data.data();
}

/*! \brief Returns red color with reference.
 *
 */
unsigned char& Color::set_R()
{
	return data[0];
}

/*! \brief Returns green color with reference.
 *
 */
unsigned char& Color::set_G()
{
	return data[1];
}

/*! \brief Returns blue color with reference.
 *
 */
unsigned char& Color::set_B()
{
	return data[2];
}

/*! \brief Returns data with pointer.
 *
 */
unsigned char* Color::set_data()
{
	return data.data();
}