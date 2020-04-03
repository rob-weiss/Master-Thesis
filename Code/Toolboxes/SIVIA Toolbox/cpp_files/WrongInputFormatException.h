#ifndef _WRONGINPUTFORMATEXCEPTION_HPP
#define _WRONGINPUTFORMATEXCEPTION_HPP

#include <exception>

#ifndef _MSC_VER
#define NOEXCEPT noexcept
#else
#define NOEXCEPT
#endif

class WrongInputFormatException : public std::exception
{
private:
	const char* _msg;
public:
	WrongInputFormatException() NOEXCEPT;
	WrongInputFormatException(const char*) NOEXCEPT;

	WrongInputFormatException& operator=(
		const WrongInputFormatException& other) NOEXCEPT;

	virtual const char* what() const NOEXCEPT;

	virtual ~WrongInputFormatException();
};

#endif // _WRONGINPUTFORMATEXCEPTION_HPP