#include "DataRedefinitionException.h"

#include <exception>

#ifndef _MSC_VER
#define NOEXCEPT noexcept
#else
#define NOEXCEPT
#endif

DataRedefinitionException::DataRedefinitionException() NOEXCEPT
{ }

DataRedefinitionException::DataRedefinitionException(const char* msg) NOEXCEPT
: _msg(msg)
{ }

DataRedefinitionException& DataRedefinitionException::operator=(
	const DataRedefinitionException& other) NOEXCEPT
{
	_msg = other._msg;
	return *this;
}

const char* DataRedefinitionException::what() const NOEXCEPT
{
	return _msg;
}

DataRedefinitionException::~DataRedefinitionException()
{ }

