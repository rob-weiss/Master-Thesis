#ifndef _WRONGDATAEXCEPTION_HPP
#define _WRONGDATAEXCEPTION_HPP

#include <exception>

#ifndef _MSC_VER
#define NOEXCEPT noexcept
#else
#define NOEXCEPT
#endif

class WrongDataException : public std::exception
{
private:
	const char* _msg;
public:
	WrongDataException() NOEXCEPT;
	WrongDataException(const char*) NOEXCEPT;

	WrongDataException& operator=(
		const WrongDataException& other) NOEXCEPT;

	virtual const char* what() const NOEXCEPT;

	virtual ~WrongDataException();
};

#endif // _WRONGDATAEXCEPTION_HPP