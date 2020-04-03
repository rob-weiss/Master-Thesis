#include "WrongInputFormatException.h"

#include <exception>

#ifndef _MSC_VER
#define NOEXCEPT noexcept
#else
#define NOEXCEPT
#endif

WrongInputFormatException::WrongInputFormatException() NOEXCEPT
{}

WrongInputFormatException::WrongInputFormatException(const char* msg) NOEXCEPT
: _msg(msg)
{ }

WrongInputFormatException& WrongInputFormatException::operator=(
	const WrongInputFormatException& other) NOEXCEPT
{
	_msg = other._msg;
	return *this;
}

const char* WrongInputFormatException::what() const NOEXCEPT
{
	return _msg;
}

WrongInputFormatException::~WrongInputFormatException()
{ }

