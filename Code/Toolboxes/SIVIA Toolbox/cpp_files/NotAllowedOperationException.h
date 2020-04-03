#ifndef _NOTALLOWEDOPERATIONEXCEPTION_HPP
#define _NOTALLOWEDOPERATIONEXCEPTION_HPP

#include <exception>

#ifndef _MSC_VER
#define NOEXCEPT noexcept
#else
#define NOEXCEPT
#endif

class NotAllowedOperationException : public std::exception
{
private:
	const char* _msg;
public:
	NotAllowedOperationException() NOEXCEPT;
	NotAllowedOperationException(const char*) NOEXCEPT;

	NotAllowedOperationException& operator=(
		const NotAllowedOperationException& other) NOEXCEPT;

	virtual const char* what() const NOEXCEPT;

	virtual ~NotAllowedOperationException();
};

#endif // _NOTALLOWEDOPERATIONEXCEPTION_HPP