#include "DataType.h"

#include <limits>

DataType DataType_min()
{
	return std::numeric_limits<DataType>::min();
}

DataType DataType_max()
{
	return std::numeric_limits<DataType>::max();
}