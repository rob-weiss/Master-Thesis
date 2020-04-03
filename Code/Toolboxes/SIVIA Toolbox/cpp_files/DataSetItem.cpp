#include "DataSetItem.h"

#include "DataSet.h"

/*
 ******************************************************************************
 *********************************** CONSTRUCTORS *****************************
 ******************************************************************************
 */

/*! \brief Constructor.
 *
 */
DataSetItem::DataSetItem(const DataSet & dataset, std::size_t position)
: _dataset(dataset), _pos(position)
{ }

/*
 ******************************************************************************
 ************************************ OPERATORS *******************************
 ******************************************************************************
 */

/*! \brief Operator * returning corresponding box by const reference.
 *
 */
const Box & DataSetItem::operator *() const
{
	return _dataset[_pos];
}

/*! \brief Operator -> returning const ptr to corresponing box.
 *
 */
const Box * DataSetItem::operator ->() const
{
	return &_dataset[_pos];
}

/*! \brief Equality operator.
 *
 */
bool DataSetItem::operator ==(const DataSetItem& bi) const
{
	if (&(_dataset) == &(bi._dataset) &&
		_pos == bi._pos)
		return true;
	return (*bi) == *(*this);
}

/*! \brief Nonequality operator.
 *
 */
bool DataSetItem::operator !=(const DataSetItem& bi) const
{
	return (!((*this) == bi));
}

/*
 ******************************************************************************
 ************************************ FUNCTIONS *******************************
 ******************************************************************************
 */

/*! \brief Returns true, if corresponding box has neighbour of specific BoxKind.
 *
 */
bool DataSetItem::has_specific_neighbour(
	const BoxKind bk) const
{
	return _dataset.has_specific_neighbour(_pos, bk);
}

/*! \brief Returns all neighbours of specific BoxKind of corresponding box.
 *
 */
DataSetItemVector DataSetItem::get_specific_neighbours(
	const BoxKind bk) const
{
	return _dataset.get_specific_neighbours(_pos, bk);
}

/*! \brief Copies the corresponding box.
 *
 */
Box DataSetItem::get_content()
{
	return _dataset[_pos];
}

/*! \brief Checks, if corresponding box is in the same component
 *  as corresponding box of bi.
 *
 */
bool DataSetItem::is_in_same_component_as(
	const DataSetItem& bi) const
{
	return 
		_dataset._components[_pos] == _dataset._components[bi._pos];
}

/*! \brief Checks, if box exists in corresponding box exists in corresponding 
 *  DataSet. Does not check, if corresponding DataSet exists.
 *
 */
bool DataSetItem::is_valid() const
{
	return _pos < _dataset._boxes.size();
}