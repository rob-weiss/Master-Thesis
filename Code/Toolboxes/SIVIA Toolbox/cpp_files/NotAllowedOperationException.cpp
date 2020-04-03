#include "NotAllowedOperationException.h"

#include <exception>

#ifndef _MSC_VER
#define NOEXCEPT noexcept
#else
#define NOEXCEPT
#endif

NotAllowedOperationException::NotAllowedOperationException() NOEXCEPT
{ }

NotAllowedOperationException::NotAllowedOperationException(const char* msg) NOEXCEPT
: _msg(msg)
{ }

NotAllowedOperationException& NotAllowedOperationException::operator=(
	const NotAllowedOperationException& other) NOEXCEPT
{
	_msg = other._msg;
	return *this;
}

const char* NotAllowedOperationException::what() const NOEXCEPT
{
	return _msg;
}

NotAllowedOperationException::~NotAllowedOperationException()
{ }

