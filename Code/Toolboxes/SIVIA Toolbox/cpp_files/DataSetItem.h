#ifndef _DATASETITEM_HPP
#define _DATASETITEM_HPP

#include <utility>
#include <vector>

#include "Box.h"
#include "BoxKind.h"
#include "DataSet.h"

class DataSet;
class DataSetItem;

typedef std::vector<DataSetItem> DataSetItemVector;

class DataSetItem
{
	friend class DataSet;

/*
 ******************************************************************************
 ************************************ RAW DATA ********************************
 ******************************************************************************
 */

protected:
	// WHICH DATASET
	const DataSet & _dataset;

	// POSITION / ID OF ELEMENT IN DATASET
	const std::size_t _pos;

/*
 ******************************************************************************
 *********************************** CONSTRUCTORS *****************************
 ******************************************************************************
 */

public:
	DataSetItem(const DataSet & data, std::size_t position);

/*
 ******************************************************************************
 ************************************ OPERATORS *******************************
 ******************************************************************************
 */

public:
	const Box & operator *() const;

	const Box * operator ->() const;

	bool operator ==(const DataSetItem& bi) const;

	bool operator !=(const DataSetItem& bi) const;

/*
 ******************************************************************************
 ************************************ FUNCTIONS *******************************
 ******************************************************************************
 */

public:
	bool has_specific_neighbour(
		const BoxKind bk) const;
	
	DataSetItemVector get_specific_neighbours(
		const BoxKind bk) const;

	Box get_content();

	bool is_in_same_component_as(
		const DataSetItem& bi) const;

	bool is_valid() const;
};

#endif