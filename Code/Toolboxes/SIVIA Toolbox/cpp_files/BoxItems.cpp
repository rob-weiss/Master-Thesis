//#include "BoxItems.h"
//
//#include <utility>
//#include <vector>
//
//#include "Box.h"
//#include "BoxItem.h"
//#include "DataSet.h"
//
//BoxItems::BoxItems(DataSet & dataset, std::vector<std::size_t> & positions)
//	: _dataset(dataset), _pos(positions)
//{ }
//	
//bool BoxItems::is_in(Box b)
//{
//	for (std::size_t i = 0; i < _pos.size(); ++i)
//	{
//		if (b == _dataset[_pos[i]])
//			return true;
//	}
//	return false;
//}
//	
//bool BoxItems::is_in(BoxItem bi)
//{
//	if (&(_dataset) == &(bi._dataset)) // maybe not the best solution ever ...
//	{
//		for (std::size_t i = 0; i < _pos.size(); ++i)
//		{
//			if (i == _pos[i])
//				return true;
//		}
//	}
//	else
//	{
//		return is_in(bi._dataset[bi._pos]);
//	}
//	return false;
//}
//
//const Box & BoxItems::operator [](std::size_t p)
//{
//	return _dataset[_pos[p]];
//}
//
//std::vector<Box> BoxItems::get_content()
//{
//	std::vector<Box> v;
//	for (std::size_t i = 0; i < _pos.size(); ++i)
//	{
//		v.emplace_back(_dataset[_pos[i]]);
//	}
//	return v;
//}
//
