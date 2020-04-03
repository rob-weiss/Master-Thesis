#ifndef _DATAREDEFINITIONEXCEPTION_HPP
#define _DATAREDEFINITIONEXCEPTION_HPP

#include <exception>

#ifndef _MSC_VER
#define NOEXCEPT noexcept
#else
#define NOEXCEPT
#endif

class DataRedefinitionException : public std::exception
{
private:
	const char* _msg;
public:
	DataRedefinitionException() NOEXCEPT;
	DataRedefinitionException(const char*) NOEXCEPT;

	DataRedefinitionException& operator=(
		const DataRedefinitionException& other) NOEXCEPT;

	virtual const char* what() const NOEXCEPT;

	virtual ~DataRedefinitionException();
};

#endif // _DATAREDEFINITIONEXCEPTION_HPP