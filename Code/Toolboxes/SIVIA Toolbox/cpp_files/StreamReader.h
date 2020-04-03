#ifndef _FILEREADER_HPP
#define _FILEREADER_HPP

#include <iostream>
#include <sstream>
#include <string>
#include <vector>

#include "WrongInputFormatException.h"

template <typename T>
class StreamReader
{
/*
 ******************************************************************************
 ************************************ RAW DATA ********************************
 ******************************************************************************
 */
protected:
	std::vector<T> content;
	std::istream& input;

/*
 ******************************************************************************
 ************************************ CONSTRUCTORS ****************************
 ******************************************************************************
 */
public:
/*! \brief Copy constructor.
 *
 */
	StreamReader<T>(const StreamReader<T> & i) : content(i.content), input(i.input) {}

/*! \brief Move constructor.
 *
 */
//	StreamReader<T>(StreamReader<T> && i) : content(std::move(i.content)), input(std::move(i.input)) {}

/*! \brief Constructor with stream.
 *
 */
	StreamReader<T>(std::istream& i) : input(i) {}

/*! \brief Constructor without stream.
 *
 */
	StreamReader<T>() {}

/*
 ******************************************************************************
 *********************************** OPERATORS *******************************
 ******************************************************************************
 */

/*! \brief Assign operator.
 *
 */
	StreamReader<T> & operator= (const StreamReader<T> & i)
	{
		content = i.content;
		input = i.input;
		return *this;
	}

/*! \brief Move assignment operator.
 *
 */
//	StreamReader<T>& operator= (StreamReader<T> && i)
//	{
//		content = std::move(i.content);
//		input = std::move(i.input);
//		return *this;
//	}

/*
 ******************************************************************************
 *********************************** FUNCTIONS ********************************
 ******************************************************************************
 */
private:
/*! \brief Help function that will try to save the word into content.
 *
 *  May throw an exception.
 */
	int try_flush_word(std::string& word)
	{
		try
		{
			T x;
			std::stringstream(word) >> x;
			content.push_back(x);
			word = "";
		}
		catch (std::exception& e)
		{
			std::stringstream ss(e.what());
			ss << " | Reader.h -> private: bool try_flush_word(std::string&) ... probably unsuccessful conversion from stringstream to typename T";
			throw WrongInputFormatException(ss.str().c_str());
			return -1;
		}
		return 0;
	}

public:
/*! \brief Returns content of reader by reference.
 *
 */
	std::vector<T>& get_content() 
	{ 
		return content; 
	}

/*! \brief Read words separated with empty spaces and tries to covert them
 *  into the vector<T>.
 *
 */
	int read_content()
	{
		char c;
		bool in_word = false;
		std::string word = "";

		for (;;)
		{
			if (input.fail()) 
				break;
			input.get(c);

			if (!isspace(c))
			{
				in_word = true;
				word += c;
			}
			else
			{
				if (in_word)
				{
					if (try_flush_word(word) != 0) 
						return -1;
				}
				in_word = false;
			}
		}

		if (in_word)
		{
			if (try_flush_word(word) != 0) 
				return -1;
		}

		return 0;
	}

};

#endif