#include "WrongDataException.h"

#include <exception>

#ifndef _MSC_VER
#define NOEXCEPT noexcept
#else
#define NOEXCEPT
#endif

WrongDataException::WrongDataException() NOEXCEPT
{ }

WrongDataException::WrongDataException(const char* msg) NOEXCEPT
	: _msg(msg)
{ }

WrongDataException& WrongDataException::operator=(
	const WrongDataException& other) NOEXCEPT
{
	_msg = other._msg;
	return *this;
}

const char* WrongDataException::what() const NOEXCEPT
{
	return _msg;
}

WrongDataException::~WrongDataException()
{ }

