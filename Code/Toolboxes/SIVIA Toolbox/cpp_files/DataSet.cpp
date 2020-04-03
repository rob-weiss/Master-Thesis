// REWORK -> USING BOXPROCESSOR's FUNCTIONS

#include "DataSet.h"

#include <map>
#include <set>
#include <utility>
#include <vector>

#include "Box.h"
#include "BoxKind.h"
#include "BoxProcessor.h"
#include "DataType.h"
#include "DataRedefinitionException.h"
#include "DataSetItem.h"
#include "Input.h"
#include "WrongInputFormatException.h"

/*
 ******************************************************************************
 ********************************* CONSTRUCTORS  ******************************
 ******************************************************************************
 */

/*! \brief This constructor have files containing separated coordinates of 
 *  boxes. Files have to be in order: 
 *  ... unknown min x, unknown max x, unknown min y, unknown max y
 *  ... excluded min x, excluded max x, excluded min y, excluded max y
 *  ... included min x, included max x, included min y, included max y
 *
 */
DataSet::DataSet(
	const BoxProcessor& bp,
	const std::vector<std::string>& files)
  : _box_processor(bp)
{ 
	load_data_from_file(files);
	get_data_ready();
}

/*! \brief This constructor have files containing separated boxes. First file
 *  is containing true boxes, second file is containing unknown files, third 
 *  file is containing false boxes.
 *
 */
DataSet::DataSet(
	const BoxProcessor& bp,
	const std::string& t_file,
	const std::string& u_file,
	const std::string& f_file)
  : _box_processor(bp)
{ 
	load_data_from_file(t_file, u_file, f_file);
	get_data_ready();
}

/*! \brief This constructor have vectors containing separated coordinates of 
 *  boxes. Vectors have to be in order: 
 *  ... unknown min x, unknown max x, unknown min y, unknown max y
 *  ... excluded min x, excluded max x, excluded min y, excluded max y
 *  ... included min x, included max x, included min y, included max y
 *
 */
DataSet::DataSet(
	const BoxProcessor& bp,
	const std::vector<std::vector<DataType> >& vectors)
  : _box_processor(bp)
{
	get_data_from_values(vectors);
	get_data_ready();
}

/*! \brief This constructor have vectors containing separated true boxes, 
 *  unknown boxes and false boxes.
 *
 */
DataSet::DataSet(
	const BoxProcessor& bp,
	const std::vector<Box>& t_boxes,
	const std::vector<Box>& u_boxes,
	const std::vector<Box>& f_boxes)
  : _box_processor(bp)
{
	insert_data(t_boxes, BoxKind::TRUE_BOX);
	insert_data(u_boxes, BoxKind::UNKNOWN_BOX);
	insert_data(f_boxes, BoxKind::FALSE_BOX);

	_extremes_set = false;
	_edges_added = false;
	_components_built = false;
	_neighbourhoods_built = false;
	_data_loaded = true;

	get_data_ready();
}

/*
 ******************************************************************************
 ******************************* OBTAINING EXTREMES ***************************
 ******************************************************************************
 */

/*! \brief This method will set minimum bound on x-axis of domain.
 *
 */
void DataSet::set_min_x()
{
	DataType min = DataType_max();
	for (auto& item : _boxes)
	{
		if (item.get_x().get_fst() < min)
			min = item.get_x().get_fst();
	}
	_min_x = min;
}

/*! \brief This method will set minimum bound on y-axis of domain.
 *
 */
void DataSet::set_min_y()
{
	DataType min = DataType_max();
	for (auto& item : _boxes)
	{
		if (item.get_y().get_fst() < min)
			min = item.get_y().get_fst();
	}
	_min_y = min;
}

/*! \brief This method will set maximum bound on x-axis of domain.
 *
 */
void DataSet::set_max_x()
{
	DataType max = DataType_min();
	for (auto& item : _boxes)
	{
		if (item.get_x().get_snd() > max)
			max = item.get_x().get_snd();
	}
	_max_x = max;
}

/*! \brief This method will set maximum bound on y-axis of domain.
 *
 */
void DataSet::set_max_y()
{
	DataType max = DataType_min();
	for (auto& item : _boxes)
	{
		if (item.get_y().get_snd() > max)
			max = item.get_y().get_snd();
	}
	_max_y = max;
}

/*! \brief This method set extremes.
 *
 */
void DataSet::set_extremes()
{
	if (_extremes_set)
	{
		throw new DataRedefinitionException("Extremes already set");
		return;
	}

	set_min_x();
	set_min_y();
	set_max_x();
	set_max_y();
	_extremes_set = true;
}

/*
 ******************************************************************************
 ********************************* OBTAINING EDGES ****************************
 ******************************************************************************
 */

/*! \brief This method will add domain edges to _boxes.
 *
 */
void DataSet::add_edges()
{
	if (_edges_added)
	{
		throw new DataRedefinitionException("Edges added");
		return;
	}

	const DataType
		min_x = get_min_x(),
		max_x = get_max_x(),
		min_y = get_min_y(),
		max_y = get_max_y();

	_boxes.emplace_back(Box(min_x, min_x, min_y, max_y));
	_boxes.emplace_back(Box(max_x, max_x, min_y, max_y));
	_boxes.emplace_back(Box(min_x, max_x, min_y, min_y));
	_boxes.emplace_back(Box(min_x, max_x, max_y, max_y));
	_boxes_kinds.emplace_back(BoxKind::EDGE_BOX);
	_boxes_kinds.emplace_back(BoxKind::EDGE_BOX);
	_boxes_kinds.emplace_back(BoxKind::EDGE_BOX);
	_boxes_kinds.emplace_back(BoxKind::EDGE_BOX);

	_edges_added = true;
	_neighbourhoods_built = false;
	_components_built = false;
}

/*
 ******************************************************************************
 ****************************** OBTAINING COMPONENTS **************************
 ******************************************************************************
 */

/*! \brief This method will recursivelly change values with not_assigned_value
 *  if they have any intersection with current component.
 *
 */
void DataSet::build_components_recursion(
	const std::size_t which_element,
	const std::size_t not_assigned_value)
{
	// could be done faster!
	//if (_neighbourhoods_built)
	//{
	//}
	//else
	//{
	for (std::size_t i = 0; i < _boxes.size(); ++i)
	{
		if (_components[i] == not_assigned_value)
		{
			if (_boxes_kinds[i] == _boxes_kinds[which_element])
			{
				if (_boxes[i].has_intersection_with(_boxes[which_element]))
				{
					_components[i] = _components[which_element];
					build_components_recursion(i, not_assigned_value);
				}
			}
		}
	}
	//}
}

/*! \brief This method will find first position of what in vector where.
 *  If what is not in where, then where.size() will be returned.
 *
 */
std::size_t DataSet::build_components_find_what_where(
	const std::size_t what,
	const std::vector<std::size_t>& where)
{
	for (std::size_t i = 0; i < where.size(); ++i)
	{
		if (where[i] == what)
		{
			return i;
		}
	}
	return where.size();
}

/*! \brief This method will build components.
 *
 */
void DataSet::build_components()
{
	if (_components_built)
	{
		throw new DataRedefinitionException("Components already built");
		return;
	}

	if (_components.size() > 0)
		_components.clear();

	std::size_t not_assigned_value = 0;
	_components = std::vector<std::size_t>(_boxes.size(), not_assigned_value);

	std::size_t component_number = 1;
	for (;;)
	{
		std::size_t element_of_component =
			build_components_find_what_where(not_assigned_value, _components);
		if (element_of_component == _components.size())
			break;
		_components[element_of_component] = component_number;
		build_components_recursion(element_of_component, not_assigned_value);
		++component_number;
	}

	_components_built = true;
}

/*
 ******************************************************************************
 ***************************** OBTAINING NEIGHBOURHOODS ***********************
 ******************************************************************************
 */

/*! \brief This method will build neighbourhoods.
 *
 *  O(_boxes^2)
 */
void DataSet::build_neighbourhoods()
{
	if (_neighbourhoods_built)
	{
		throw new DataRedefinitionException("Neighbourhoods already built");
		return;
	}

	if (_neighbourhoods.size() > 0)
		_neighbourhoods.clear();

	for (std::size_t i = 0; i < _boxes.size(); ++i)
	{
		std::vector<std::size_t> neigh_for_i;
		for (std::size_t j = 0; j < _boxes.size(); ++j)
		{
			if (i != j && _boxes[i].has_intersection_with(_boxes[j]))
				neigh_for_i.push_back(j);
		}
		_neighbourhoods.emplace(i, neigh_for_i);
	}

	_neighbourhoods_built = true;
}

/*
 ******************************************************************************
 ********************************* DATA OBTAINING *****************************
 ******************************************************************************
 */

/*! \brief This method add boxes with specific BoxKind.
 *
 */
void DataSet::insert_data(
	const std::vector<Box>& boxes,
	const BoxKind bk)
{
	for (auto& b : boxes)
	{
		_boxes.emplace_back(b);
		_boxes_kinds.emplace_back(bk);
	}
}

/*! \brief This method add boxes from 12 separated files into _boxes. Files
 *  have to be in order: 
 *  ... included min x, included max x, included min y, included max y
 *  ... unknown min x, unknown max x, unknown min y, unknown max y
 *  ... excluded min x, excluded max x, excluded min y, excluded max y
 *
 */
void DataSet::load_data_from_file(const std::vector<std::string>& files)
{
	if (files.size() != 12)
	{
		throw new WrongInputFormatException("Wrong number of files");
		return;
	}

	if (_data_loaded)
	{
		throw new DataRedefinitionException("Data has already been loaded");
		return;
	}

	if (_boxes.size() > 0)
	{
		_boxes.clear();
		_boxes_kinds.clear();
	}

	std::vector<Box> tru =
		get_boxes_impl_from_files<DataType>(files[0], files[1], files[2], files[3]);
	insert_data(tru, BoxKind::TRUE_BOX);

	std::vector<Box> unk = 
		get_boxes_impl_from_files<DataType>(files[4], files[5], files[6], files[7]);
	insert_data(unk, BoxKind::UNKNOWN_BOX);

	std::vector<Box> fal = 
		get_boxes_impl_from_files<DataType>(files[8], files[9], files[10], files[11]); 
	insert_data(fal, BoxKind::FALSE_BOX);

	_extremes_set = false;
	_edges_added = false;
	_components_built = false;
	_neighbourhoods_built = false;
	_data_loaded = true;
}

/*! \brief This method add boxes from 3 separated files into _boxes. First file
 *  is containing true boxes, second file is containing unknown files, third 
 *  file is containing false boxes.
 *
 */
void DataSet::load_data_from_file(
	const std::string& t_file,
	const std::string& u_file,
	const std::string& f_file)
{
	if (_data_loaded)
	{
		throw new DataRedefinitionException("Data has already been loaded");
		return;
	}

	if (_boxes.size() > 0)
	{
		_boxes.clear();
		_boxes_kinds.clear();
	}

	std::vector<Box> tru =
		get_boxes_impl_from_file<DataType>(t_file);
	insert_data(tru, BoxKind::TRUE_BOX);

	std::vector<Box> unk = 
		get_boxes_impl_from_file<DataType>(u_file);
	insert_data(unk, BoxKind::UNKNOWN_BOX);

	std::vector<Box> fal = 
		get_boxes_impl_from_file<DataType>(f_file);
	insert_data(fal, BoxKind::FALSE_BOX);

	_extremes_set = false;
	_edges_added = false;
	_components_built = false;
	_neighbourhoods_built = false;
	_data_loaded = true;
}

/*! \brief This method add boxes from 12 separated files into _boxes. Vectors
 *  have to be in order: 
 *  ... included min x, included max x, included min y, included max y
 *  ... unknown min x, unknown max x, unknown min y, unknown max y
 *  ... excluded min x, excluded max x, excluded min y, excluded max y
 *
 */
void DataSet::get_data_from_values(
	const std::vector<std::vector<DataType> >& vectors)
{
	if (vectors.size() != 12)
	{
		throw new WrongInputFormatException("Wrong number of files");
		return;
	}

	if (! (
		// S ~ included set
		vectors[0].size() == vectors[1].size() && 
		vectors[1].size() == vectors[2].size() &&
		vectors[2].size() == vectors[3].size() && 
		// B ~ unknown set
		vectors[4].size() == vectors[5].size() && 
		vectors[5].size() == vectors[6].size() && 
		vectors[6].size() == vectors[7].size() && 
		// N ~ excluded set
		vectors[8].size() == vectors[9].size() && 
		vectors[9].size() == vectors[10].size() && 
		vectors[10].size() == vectors[11].size()))
	{
		throw new WrongInputException("Dimensions of input does not match");
	}

	if (_data_loaded)
	{
		throw new DataRedefinitionException("Data has already been loaded");
		return;
	}

	if (_boxes.size() > 0)
	{
		_boxes.clear();
		_boxes_kinds.clear();
	}

	std::vector<Box> tru =
		get_boxes_impl_from_input<DataType>(vectors[0], vectors[1], vectors[2], vectors[3]);
	insert_data(tru, BoxKind::TRUE_BOX);

	std::vector<Box> unk =
		get_boxes_impl_from_input<DataType>(vectors[4], vectors[5], vectors[6], vectors[7]);
	insert_data(unk, BoxKind::UNKNOWN_BOX);

	std::vector<Box> fal =
		get_boxes_impl_from_input<DataType>(vectors[8], vectors[9], vectors[10], vectors[11]);
	insert_data(fal, BoxKind::FALSE_BOX);

	_extremes_set = false;
	_edges_added = false;
	_components_built = false;
	_neighbourhoods_built = false;
	_data_loaded = true;
}

/*
 ******************************************************************************
 ******************************** DATA PREPARATION ****************************
 ******************************************************************************
 */

/*! \brief Returns true, if data are ready to be used.
 *
 */
bool DataSet::data_ready() const 
{
	return
		_data_loaded &&
		_edges_added &&
		_neighbourhoods_built &&
		_components_built &&
		_extremes_set;
}

/*! \brief This method will ensure, that all needed changes will be made after
 *  Data Loading. Must not to be used twice.
 *
 */
void DataSet::get_data_ready()
{
	set_extremes();
	add_edges();
	build_neighbourhoods();
	build_components();
}

/*
 ******************************************************************************
 ****************************** DATASETITEM QUERIES ***************************
 **************** queries should be not used if data_ready == false ***********
 ******************************************************************************
 */

/*! \brief Returns position of box b in _boxes. If box b is not in _boxes, then
 *  _boxes.size() will be returned.
 *
 */
std::size_t DataSet::find_position(const Box& b) const
{
	for (std::size_t i = 0; i < _boxes.size(); ++i)
	{
		if (_boxes[i] == b)
			return i;
	}
	return _boxes.size();
}

/*! \brief Returns box on position p in _boxes by const reference.
 *
 */
const Box & DataSet::operator [](const std::size_t p) const
{
	return _boxes[p];
}

/*! \brief Returns true, if _boxes[k] has neighbour of specific boxkind.
 *
 */
bool DataSet::has_specific_neighbour(
	const std::size_t k,
	const BoxKind bk) const
{
	const std::vector<std::size_t>& neighbours =
		_neighbourhoods.find(k)->second;
	for (std::size_t i = 0; i < neighbours.size(); ++i)
	{
		if (_boxes_kinds[neighbours[i]] == bk)
			return true;
	}
	return false;
}

/*! \brief Returns all specific neighbours of _boxes[k].
 *
 */
DataSetItemVector DataSet::get_specific_neighbours(
	const std::size_t k,
	BoxKind bk) const
{
	DataSetItemVector dsiv;
	const std::vector<std::size_t>& neighbours = _neighbourhoods.find(k)->second;
	for (std::size_t i = 0; i < neighbours.size(); ++i)
	{
		if (_boxes_kinds[neighbours[i]] == bk)
			dsiv.emplace_back(*this, neighbours[i]);
	}
	return dsiv;
}

/*
 ******************************************************************************
 ******************************** DATABASE QUERIES ****************************
 **************** queries should be not used if data_ready == false ***********
 ******************************************************************************
 */

/*! \brief Returns true, if box same box of any BoxKind is present in _boxes.
 *  In variable pos is exported location of the box in _boxes. If the box is 
 *  not present in _boxes, then pos will be _boxes.size().
 *
 */
bool DataSet::is_in(const Box& b, std::size_t& pos) const
{
	for (pos = 0; pos < _boxes.size(); ++pos)
	if (_boxes[pos] == b)
		return true;
	return false;
}

/*! \brief Returns domain lower bound on x-axis.
 *
 */
DataType DataSet::get_min_x() const
{
	return _min_x;
}

/*! \brief Returns domain lower bound on y-axis.
 *
 */
DataType DataSet::get_min_y() const
{
	return _min_y;
}

/*! \brief Returns domain upper bound on x-axis.
 *
 */
DataType DataSet::get_max_x() const
{
	return _max_x;
}

/*! \brief Returns domain upper bound on y-axis.
 *
 */
DataType DataSet::get_max_y() const
{
	return _max_y;
}

/*! \brief Returns all boxes of specific BoxKind.
 *
 */
DataSetItemVector DataSet::get_specific_boxes(
	const BoxKind bk) const
{
	DataSetItemVector bis;
	for (std::size_t i = 0; i < _boxes_kinds.size(); ++i)
	{
		if (_boxes_kinds[i] == bk)
			bis.emplace_back(*this, i);
	}
	return bis;
}

/*! \brief Returns all components of boxes of specific BoxKind 
 *  as DataSetItem vectors.
 *
 */
std::vector<DataSetItemVector> DataSet::get_specific_components(
	const BoxKind bk) const
{
	std::vector<DataSetItemVector> vbis;

	std::set<std::size_t> set;
	for (std::size_t i = 0; i < _boxes_kinds.size(); ++i)
	{
		if (_boxes_kinds[i] == bk)
		if (set.find(_components[i]) == set.end())
			set.insert(_components[i]);
	}

	std::vector<std::size_t> wanted_comps(set.begin(), set.end());
	for (std::size_t i = 0; i < wanted_comps.size(); ++i)
	{
		DataSetItemVector bis;
		for (std::size_t j = 0; j < _components.size(); ++j)
		{
			if (_components[j] == wanted_comps[i])
				bis.emplace_back(*this, j);
		}
		vbis.emplace_back(bis);
	}

	return vbis;
}

/*! \brief Returns true, if box same box of any BoxKind is present in _boxes.
 *
 */
bool DataSet::is_in(const Box& b) const
{
	std::size_t pos;
	return is_in(b, pos);
}

/*! \brief Returns vector of bools, where i-th element says, if boxes[i] was
 *  found in _boxes. DataSetItems are added into in vector result and i-th new
 *  element of result is viable, if i-th bool in vector is true.
 *
 */
std::vector<bool> DataSet::find_and_add(
	const std::vector<Box>& boxes,
	DataSetItemVector& result) const
{
	result.reserve(result.size() + boxes.size());
	std::vector<bool> success;
	std::size_t pos;
	for (auto& b : boxes)
	{
		success.push_back(is_in(b, pos));
		result.emplace_back(*this, pos);
	}
	return success;
}
