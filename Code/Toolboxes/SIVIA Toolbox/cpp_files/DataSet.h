#ifndef _DATASET_HPP
#define _DATASET_HPP

#include <map>
#include <set>
#include <utility>
#include <vector>

#include "Box.h"
#include "BoxKind.h"
#include "BoxProcessor.h"
#include "DataType.h"
#include "DataSetItem.h"
#include "Input.h"
#include "WrongInputFormatException.h"

class DataSetItem;
typedef std::vector<DataSetItem> DataSetItemVector;

class DataSet
{

protected:
	friend class DataSetItem;

/*
 ******************************************************************************
 ************************************ RAW DATA ********************************
 ******************************************************************************
 */

protected:
	// METHODS HOLDER
	const BoxProcessor& _box_processor;

	// RAW DATA
	std::vector<Box> _boxes;
	std::vector<BoxKind> _boxes_kinds;
	bool _data_loaded = false;

	// EDGES
	bool _edges_added = false;

	// COMPONENTS
	std::vector<std::size_t> _components; // 0 ~ unassigned
	bool _components_built = false;
	
	// NEIGHBOURHOODS
	std::map<std::size_t, std::vector<std::size_t> > _neighbourhoods;
	bool _neighbourhoods_built = false;
	
	// EXTREMES
	DataType _min_x;
	DataType _min_y;
	DataType _max_x;
	DataType _max_y;
	bool _extremes_set = false;

/*
 ******************************************************************************
 ********************************* CONSTRUCTORS  ******************************
 ******************************************************************************
 */

public:
	DataSet(
		const BoxProcessor& bp, 
		const std::vector<std::string>& files);

	DataSet(
		const BoxProcessor& bp,
		const std::string& t_file,
		const std::string& u_file,
		const std::string& f_file);

	DataSet(
		const BoxProcessor& bp,
		const std::vector<std::vector<DataType> >& vectors);

	DataSet(
		const BoxProcessor& bp,
		const std::vector<Box>& t_boxes,
		const std::vector<Box>& u_boxes,
		const std::vector<Box>& f_boxes);

private:
	//DataSet(const DataSet& v) = delete;

	//DataSet(DataSet&& v) = delete;

/*
 ******************************************************************************
 ************************************ OPERATORS *******************************
 ******************************************************************************
 */

private:
	//DataSet operator= (const DataSet& c) = delete;

	//DataSet operator= (DataSet&& c) = delete;

/*
 ******************************************************************************
 ******************************* OBTAINING EXTREMES ***************************
 ******************************************************************************
 */

public:
	void set_min_x();

	void set_min_y();

	void set_max_x();

	void set_max_y();

	void set_extremes();

/*
 ******************************************************************************
 ********************************* OBTAINING EDGES ****************************
 ******************************************************************************
 */

public:
	void add_edges();

/*
 ******************************************************************************
 ****************************** OBTAINING COMPONENTS **************************
 ******************************************************************************
 */

public:
	void build_components_recursion(
		const std::size_t which_element,
		const std::size_t not_assigned_value);

	std::size_t build_components_find_what_where(
		const std::size_t what,
		const std::vector<std::size_t>& where);

	void build_components();

/*
 ******************************************************************************
 ***************************** OBTAINING NEIGHBOURHOODS ***********************
 ******************************************************************************
 */

public:
	void build_neighbourhoods();

/*
 ******************************************************************************
 ********************************* DATA OBTAINING *****************************
 ******************************************************************************
 */

protected:
	void insert_data(
		const std::vector<Box>& values,
		const BoxKind bk);

public:
	void load_data_from_file(const std::vector<std::string>& files);

	void load_data_from_file(
		const std::string& t_file,
		const std::string& u_file,
		const std::string& f_file);

	void get_data_from_values(
		const std::vector<std::vector<DataType> >& vectors);

/*
 ******************************************************************************
 ******************************** DATA PREPARATION ****************************
 ******************************************************************************
 */

public:
	bool data_ready() const;

	void get_data_ready(); 
	

/*
 ******************************************************************************
 ****************************** DATASETITEM QUERIES ***************************
 **************** queries should be not used if data_ready == false ***********
 ******************************************************************************
 */

protected:
	std::size_t find_position(const Box&) const;

	const Box & operator [](const std::size_t) const;

	bool has_specific_neighbour(
		const std::size_t k,
		const BoxKind bk) const;

	DataSetItemVector get_specific_neighbours(
		const std::size_t item,
		const BoxKind bk) const;

/*
 ******************************************************************************
 ******************************** DATABASE QUERIES ****************************
 **************** queries should be not used if data_ready == false ***********
 ******************************************************************************
 */

	// DB QUERIES - queries should be not used if data_ready == false

protected:
	bool is_in(const Box& b, std::size_t& pos) const;

public:
	DataType get_min_x() const;

	DataType get_min_y() const;

	DataType get_max_x() const;

	DataType get_max_y() const;

	DataSetItemVector get_specific_boxes(
		const BoxKind bk) const;

	std::vector<DataSetItemVector> get_specific_components(
		const BoxKind bk) const;

	bool is_in(const Box& b) const;

	std::vector<bool> find_and_add(
		const std::vector<Box>& boxes,
		DataSetItemVector& result) const;
};

#endif // _DATASETSOURCES_HPP