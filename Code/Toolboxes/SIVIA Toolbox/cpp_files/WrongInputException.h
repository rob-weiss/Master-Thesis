#ifndef _WRONGINPUTEXCEPTION_HPP
#define _WRONGINPUTEXCEPTION_HPP

#include <exception>

#ifndef _MSC_VER
#define NOEXCEPT noexcept
#else
#define NOEXCEPT
#endif

class WrongInputException : public std::exception
{
private:
	const char* _msg;
public:
	WrongInputException() NOEXCEPT;
	WrongInputException(const char*) NOEXCEPT;

	WrongInputException& operator=(
		const WrongInputException& other) NOEXCEPT;

	virtual const char* what() const NOEXCEPT;

	virtual ~WrongInputException();
};

#endif // _WRONGINPUTEXCEPTION_HPP