#include "WrongInputException.h"

#include <exception>

#ifndef _MSC_VER
#define NOEXCEPT noexcept
#else
#define NOEXCEPT
#endif

WrongInputException::WrongInputException() NOEXCEPT
{}

WrongInputException::WrongInputException(const char* msg) NOEXCEPT
: _msg(msg)
{ }

WrongInputException& WrongInputException::operator=(
	const WrongInputException& other) NOEXCEPT
{
	_msg = other._msg;
	return *this;
}

const char* WrongInputException::what() const NOEXCEPT
{
	return _msg;
}

WrongInputException::~WrongInputException()
{ }

