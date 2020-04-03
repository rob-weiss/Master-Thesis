#ifndef _BOXKIND_HPP
#define _BOXKIND_HPP

enum class BoxKind : char
{
	UNDEFINED,		// undefinied computation / ambigious result of computation
	TRUE_BOX,		// element of included set 
	FALSE_BOX,		// element of excluded set
	UNKNOWN_BOX,	// element of undecided set
	EDGE_BOX		// whole element out / on the edge of the computed domain
};

#endif // _BOXKIND_HPP