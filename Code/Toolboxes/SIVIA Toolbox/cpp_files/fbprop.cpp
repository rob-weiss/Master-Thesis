#include <cmath>
#include <iostream>
#include <stack>
#include <set>
#include <cctype>

// MATLAB header files
#include <mex.h>
#include <matrix.h>

#include "fbprop.h"

using namespace std;
using namespace boost::numeric;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	// compute the number of variables
	mxArray* intvalVect = mxDuplicateArray(prhs[1]);
	mxArray* dimArr[1];
	mexCallMATLAB(1, dimArr, 1, &intvalVect, "length");
	int DIM = mxGetScalar(dimArr[0]);
	string expr = mxArrayToString(prhs[0]); // load the expression (equation/inequality)
	vector<Interval> box;
	mxArray* infs = mxGetField(prhs[1], 0, "inf"); // load the vector of lower bounds
	mxArray* sups = mxGetField(prhs[1], 0, "sup"); // load the vector of upper bounds
	double* firstInf = mxGetPr(infs);
	double* firstSup = mxGetPr(sups);
	for (int i = 0; i < DIM; ++i) // construct C++ intervals
	{
		Interval intval(*(firstInf+i), *(firstSup+i));
		box.push_back(intval);
	}
	
	Parser p;
	vector<Interval> nbox = p.fbProp(expr, box);
	
	mwSize dims[2] = {1, (mwSize) DIM };
	char* fields[2] = {"inf", "sup"};
	plhs[0] = mxCreateCellArray(2, dims);
	for (int i = 0; i < DIM; i++)
	{
		mxArray* ret[1]; // return value (MATLAB intval type)
		mxArray* infSup[2] = { mxCreateDoubleScalar(nbox[i].lower()), mxCreateDoubleScalar(nbox[i].upper()) }; // computed values (C++ Interval type)
		mexCallMATLAB(1, ret, 2, infSup, "infsup");
		mxSetCell(plhs[0], i, ret[0]);
	} 
}

/* Methods for building an expression tree */
Node* Parser::parseExpr(const string& expr, vector<Interval>& box) 
// build a tree by converting to postfix
{
	string func;
	stack<string> op;
	stack<Node*> tree;
	unsigned int i = 0;
	bool binary = 0;
	int varNr = 0;
	set<string> variables;

	// defining primitive functions
	map<string, Triple<string, string, int>> functions;
	typedef Triple<string, string, int> funcType;
	functions.insert(make_pair("+", funcType("binary", "left", 10)));
	functions.insert(make_pair("-", funcType("both", "", 0)));
	functions.insert(make_pair("u-", funcType("unary", "right", 30)));
	functions.insert(make_pair("b-", funcType("binary", "left", 10)));
	functions.insert(make_pair("*", funcType("binary", "left", 20)));
	functions.insert(make_pair("/", funcType("binary", "left", 20)));
	functions.insert(make_pair("=", funcType("binary", "left", 0)));
	functions.insert(make_pair(">", funcType("binary", "left", 0)));
	functions.insert(make_pair("<", funcType("binary", "left", 0)));
	functions.insert(make_pair("^", funcType("binary", "right", 40)));
	functions.insert(make_pair("root", funcType("binary", "left", 40)));
	functions.insert(make_pair("sin", funcType("unary", "right", 50)));
	functions.insert(make_pair("cos", funcType("unary", "right", 50)));
	functions.insert(make_pair("tan", funcType("unary", "right", 50)));
	functions.insert(make_pair("sqr", funcType("unary", "right", 50)));
    functions.insert(make_pair("sqrt", funcType("unary", "right", 50)));
	functions.insert(make_pair("abs", funcType("unary", "right", 50)));
	functions.insert(make_pair("exp", funcType("unary", "right", 50)));
	functions.insert(make_pair("log", funcType("unary", "right", 50)));
	functions.insert(make_pair("(", funcType("", "left", -1)));

	while (i < expr.length())
	{
		char c = expr[i];
		if (isdigit(c)) // read a number and push it onto the tree stack
		{
			string number;
			while (i < expr.length() && (isdigit(expr[i]) || expr[i] == '.'))
			{
				number += expr[i];
				i++;
			}
			--i;
			Interval ival(atof(number.c_str()));
			tree.push(new LeafNode(ival, number, true));
			binary = true;
		}
		else if (isoperator(c)) // read an operator and check its priority against the top of the stack
		{
			func = c;
			if ((functions[func].fst() == "both") && binary) func = "b" + func;
			else if ((functions[func].fst() == "both") && !binary) func = "u" + func;

			if ((func != ">" && func != "<") && (op.empty() || functions[op.top()].trd() < functions[func].trd())) // higher priority -> push the operator onto the stack
			{
				op.push(func);
			}
			else // apply operators with higher priority first
			{
				while (!op.empty() && (((functions[func].snd() == "left") && functions[op.top()].trd() == functions[func].trd()) || 
									   (functions[op.top()].trd() > functions[func].trd())))
				{
					Interval ival; ival.set_whole();
					if (functions[op.top()].fst() == "binary") // create a new tree with a binary operation
					{
						Node* right = tree.top(); tree.pop();
						Node* left = tree.top(); tree.pop();
						tree.push(new BinaryOpNode(ival, op.top(), left, right));
					}
					else if (functions[op.top()].fst() == "unary") // create a new tree with a unary operation
					{
						Node* left = tree.top(); tree.pop();
						tree.push(new UnaryOpNode(ival, op.top(), left));
					}
					op.pop();
				}
				// convert an inequality to an equation by adding a slack variable
				if (c == '<' && expr[i+1] == '=') 
				{
					Interval iv(0, numeric_limits<double>::infinity());
					LeafNode* slack = new LeafNode(iv, "_slack", false);
					BinaryOpNode* plus = new BinaryOpNode(Interval::whole(), "+");
					plus->setChild(tree.top(), 'l');
					plus->setChild(slack, 'r');
					tree.pop();
					tree.push(plus);
					i++;
					func = "=";
				}
				else if (c == '>' && expr[i+1] == '=')
				{
					Interval iv(0, numeric_limits<double>::infinity());
					LeafNode* slack = new LeafNode(iv, "_slack", false);
					BinaryOpNode* minus = new BinaryOpNode(Interval::whole(), "b-");
					minus->setChild(tree.top(), 'l');
					minus->setChild(slack, 'r');
					tree.pop();
					tree.push(minus);
					i++;
					func = "=";
				}
				op.push(func);
			}
			binary = false;
		}
		else if (isalpha(c))
		{
			func = "";
			while (i < expr.length() && isalpha(expr[i])) // read a string
			{
				func += expr[i];
				i++;
			}
			--i;
			if (i + 1 == expr.length() || isoperator(expr[i+1]) || expr[i+1] == ')' || isspace(expr[i+1]) || expr[i+1] == ',') // the string is a variable
			{
				Interval ival;
				variables.insert(func);
				tree.push(new LeafNode(ival, func, false));
				binary = true;
			}
			else if (op.empty() || (functions[op.top()].trd() < functions[func].trd()))
			{
				op.push(func);
				binary = false;
			}
			else
			{
				while (!op.empty() && (((functions[func].snd() == "left") && functions[op.top()].trd() == functions[func].trd()) ||
					(functions[op.top()].trd() > functions[func].trd())))
				{
					Interval ival; ival.set_whole();
					Node* left = tree.top(); tree.pop();
					tree.push(new UnaryOpNode(ival, op.top(), left));
					op.pop();
				}
				op.push(func);
				binary = false;
			}
		}
		else if (c == '(') // push a left bracket onto the op stack
		{
			func = c;
			op.push(func);
			binary = false;
		}
		else if (c == ')') // perform all operations from op stack until a left bracket is found
		{
			while (op.top() != "(")
			{
				Interval ival; ival.set_whole();
				if (isoperator(op.top()))
				{
					Node* right = tree.top(); tree.pop();
					Node* left = tree.top(); tree.pop();
					tree.push(new BinaryOpNode(ival, op.top(), left, right));
				}
				else
				{
					Node* left = tree.top(); tree.pop();
					tree.push(new UnaryOpNode(ival, op.top(), left));
				}
				op.pop();
			}
			binary = true;
			op.pop();
		}
		i++;
	}
	while (!op.empty()) // whole expression is read, perform all remaining operations
	{
		Interval ival; ival.set_whole();
		if (functions[op.top()].fst() == "binary")
		{
			Node* right = tree.top(); tree.pop();
			Node* left = tree.top(); tree.pop();
			tree.push(new BinaryOpNode(ival, op.top(), left, right));
		}
		else if (functions[op.top()].fst() == "unary")
		{
			Node* left = tree.top(); tree.pop();
			tree.push(new UnaryOpNode(ival, op.top(), left));
		}
		op.pop();
	}
	
	// assign interval domains to variables
	set<string>::iterator it = variables.begin();
	for (int i = 0; i < box.size(); ++i)
	{
		string name = *it;
		Interval ival = box[i];
		vars.insert(make_pair(name, ival));
		it++;
	}

	return tree.top();
}

bool Parser::isoperator(char c) 
{
	string ops = "+-*/^=><";
	return (ops.find(c) != ops.npos);
}

bool Parser::isoperator(const string& s) 
{
	string ops = "+-*/^=><";
	return (ops.find(s) != ops.npos) || s == "b-";
}

/* Constructors for the Node class and derived classes */
Node::Node(Interval intval, const std::string& s)
{
	intval_ = intval;
	name_ = s;
	leftChild = rightChild = NULL;
	isLeaf = false;
}

Node::Node()
{
	intval_ = Interval::empty();
	name_ = "";
	leftChild = rightChild = NULL;
	isLeaf = false;
}

LeafNode::LeafNode(Interval intval, const string& s, bool isConst)
{
	intval_ = intval;
	name_ = s;
	leftChild = rightChild = NULL;
	isLeaf = true;
	isConst_ = isConst;
}

BinaryOpNode::BinaryOpNode(Interval intval, const string& s, Node* left, Node* right)
{
	intval_ = intval;
	name_ = s;
	leftChild = left;
	rightChild = right;
	status = 0;
	isLeaf = false;
	// assign evaluate, left and right inverse operators
	if		(name_ == "+") { eval = operator+; invEval = invEvalR = invPlus; }
	else if (name_ == "b-") { eval = operator-; invEval = invMinus; invEvalR = invMinusR; }
	else if (name_ == "*") { eval = operator*; invEval = invEvalR = invMult; }
	else if (name_ == "/") { eval = operator/; invEval = invDiv; invEvalR = invDivR; }
	else if (name_ == "=") { eval = intersect; invEval = invEvalR = invEq; }
	else if (name_ == "^") { eval = powInt; invEval = invPow; invEvalR = invPowR; }
	else if (name_ == "root") { eval = rootInt; invEval = invRoot; invEvalR = invRootR; }
	else eval = NULL;
}

UnaryOpNode::UnaryOpNode(Interval intval, const string& s, Node* left)
{
	intval_ = intval;
	name_ = s;
	leftChild = left;
	rightChild = NULL;
	status = 0;
	isLeaf = false;
	// assign evaluate and inverse operators
	if		(name_ == "sin")  { eval = sin; invEval = invSin; }
	else if (name_ == "cos")  { eval = cos; invEval = invCos; }
	else if (name_ == "tan")  { eval = tan; invEval = invTan; }
	else if (name_ == "asin") { eval = asin; invEval = invASin; }
	else if (name_ == "acos") { eval = acos; invEval = invACos; }
	else if (name_ == "atan") { eval = atan; invEval = invATan; }
	else if (name_ == "exp")  { eval = exp; invEval = invExp; }
	else if (name_ == "log")  { eval = log; invEval = invLog; }
	else if (name_ == "sqr")  { eval = square; invEval = invSqr; }
    else if (name_ == "sqrt") { eval = sqrt; invEval = invSqrt; }
	else if (name_ == "abs")  { eval = abs; invEval = invAbs; }
	else if (name_ == "u-")	  { eval = operator-; invEval = invUMinus; }
	else eval = NULL;
}


/* Methods for Forward-backward propagation */
vector<Interval> Parser::fbProp(const string& expr, vector<Interval>& box)
{
	Node* root = parseExpr(expr, box);
	root->fProp(vars);
	multimap<string, Interval> newBox;
	newBox = root->bProp(newBox);
	vector<Interval> results;
	multimap<string, Interval>::iterator it = newBox.begin();
	while (it != newBox.end()) // check all unique multimap keys
	{
		Interval resIntval(it->second);
		int counter = newBox.count(it->first);
		for (int j = 0; j < counter; j++) // compute the resulting interval for a given variable
		{
			resIntval = intersect(resIntval, it->second);
			++it;
		}
		results.push_back(resIntval);
	}
	return results;
}

void Node::fProp(std::map<std::string, Interval>& vars) 
// forward propagation, starts in leaves and sets values in nodes
{
	Interval lval, rval;
	if (leftChild != NULL) 
	{ 
		leftChild->fProp(vars); 
		lval = leftChild->getIntval(); 
	}
	if (rightChild != NULL) 
	{ 
		rightChild->fProp(vars); 
		rval = rightChild->getIntval(); 
	}
	if (!isLeaf) setIntval(evaluate(lval, rval));
	else if (isLeaf && !isConst() && (name_ != "_slack")) setIntval(vars[name_]);
}

multimap<string, Interval> Node::bProp(multimap<string, Interval>& box) 
// backward propagation, starts in the root and computes a new value for children nodes
{
	bool lexists, rexists;
	lexists = rexists = false;
	Interval lval, rval;
	if (leftChild != NULL) 
	{ 
		lval = leftChild->getIntval(); 
		lexists = true;
	}
	if (rightChild != NULL) 
	{ 
		rval = rightChild->getIntval();  
		rexists = true;
	}
	if (lexists)
	{
		leftChild->setIntval(evaluateInv(intval_, rval, lval)); 
		box = leftChild->bProp(box); 
		lval = leftChild->getIntval();
		status = 1;
	}
	if (rexists)
	{
		rightChild->setIntval(evaluateInv(intval_, lval, rval));
		box = rightChild->bProp(box);
	}
	if (isLeaf && !isdigit(name_[0]) && name_ != "_slack") { box.insert(make_pair(name_, intval_));}
	return box;
}

Interval powInt(const Interval& i1, const Interval& i2)
{
	return pow(i1, (int)i2.lower());
}

Interval rootInt(const Interval& i1, const Interval& i2)
{
	return nth_root(i1, (int)i2.lower());
}

/* Definitions of inverse interval operations */
Interval invPlus(const Interval& i1, const Interval& i2, const Interval& i3)
{
	return intersect(operator-(i1, i2), i3);
}

Interval invMinus(const Interval& i1, const Interval& i2, const Interval& i3)
{
	return intersect(operator+(i1, i2), i3);
}

Interval invMinusR(const Interval& i1, const Interval& i2, const Interval& i3)
{
	return intersect(operator-(i2, i1), i3);
}

Interval invUMinus(const Interval& i1, const Interval& i2)
{
	return intersect(operator-(i1), i2);
}

Interval invMult(const Interval& i1, const Interval& i2, const Interval& i3)
{
    if (in(0.0, i2))
        { return i3; } // denominator contains 0
    else
        { return intersect(operator/(i1, i2), i3); } 
}

Interval invDiv(const Interval& i1, const Interval& i2, const Interval& i3)
{
	return intersect(operator*(i1, i2), i3);
}

Interval invDivR(const Interval& i1, const Interval& i2, const Interval& i3)
{
     if (in(0.0, i2))
        { return i3; } // denominator contains 0
    else
        { return intersect(operator/(i2, i1), i3); }
}

Interval invEq(const Interval& i1, const Interval& i2, const Interval& i3)
{
	return intersect(i1, i2);
}

Interval invPow(const Interval& i1, const Interval& i2, const Interval& i3)
{
    double intpart;
    if ((modf(i2.lower(), &intpart) == 0.0) && i2.lower() > 0) // positive integer value
    {
        int n = (int)i2.lower();
        Interval root1 = intersect(nth_root(i1, n), i3);
        Interval root2 = intersect(-nth_root(i1, n), i3);
            if (root1.lower() != root1.lower()) // NaN
                return root2;
            else if (root2.lower() != root2.lower()) 
                return root1;
            else
                return hull(root1, root2); 
    }
    else
        return i3;
}

Interval invPowR(const Interval& i1, const Interval& i2, const Interval& i3)
{
	return i3;
}

Interval invRoot(const Interval& i1, const Interval& i2, const Interval& i3)
{
	int n = (int)i2.lower();
	return intersect(pow(i1, n), i3);
}

Interval invRootR(const Interval& i1, const Interval& i2, const Interval& i3)
{
	return i3;
}

Interval invSqr(const Interval& i1, const Interval& i2)
{
	return hull(intersect(sqrt(i1), i2), intersect(-sqrt(i1), i2));
}

Interval invSqrt(const Interval& i1, const Interval& i2)
{
	return intersect(square(i1), i2);
}

Interval invAbs(const Interval& i1, const Interval& i2) 
{
	return hull(intersect(i1, i2), intersect(-i1, i2));
}

Interval invSin(const Interval& i1, const Interval& i2)
{
	double a = i2.lower();
	double b = i2.upper();
	Interval c = asin(i1);
	Interval d = pi - asin(i1);
	double rlow, rupp, rlow2, rupp2;

	int k_a = floor((a - c.lower()) / (2*pi));
	int k_b = ceil((b - c.upper()) / (2*pi));
	if ((a >= c.lower() + 2*k_a*pi) && (a <= c.upper() + 2*k_a*pi)) rlow = a;
	else rlow = c.lower() + 2*(k_a + 1)*pi;
	if ((b >= c.lower() + 2*k_b*pi) && (b <= c.upper() + 2*k_b*pi)) rupp = b;
	else rupp = c.upper() + 2*(k_b - 1)*pi;

	k_a = floor((a - d.lower()) / (2*pi));
	k_b = ceil((b - d.upper()) / (2*pi));
	if ((a >= d.lower() + 2*k_a*pi) && (a <= d.upper() + 2*k_a*pi)) rlow2 = a;
	else rlow2 = d.lower() + 2*(k_a + 1)*pi;
	if ((b >= d.lower() + 2*k_b*pi) && (b <= d.upper() + 2*k_b*pi)) rupp2 = b;
	else rupp2 = d.upper() + 2*(k_b - 1)*pi;

	Interval result(hull(Interval(rlow, rupp), Interval(rlow2, rupp2)));
	return result;
}

Interval invCos(const Interval& i1, const Interval& i2)
{
	double a = i2.lower();
	double b = i2.upper();
	Interval c = acos(i1);
	Interval d = -acos(i1);
	double rlow, rupp, rlow2, rupp2;

	int k_a = floor((a - c.lower()) / (2*pi));
	int k_b = ceil((b - c.upper()) / (2*pi));
	if ((a >= c.lower() + 2*k_a*pi) && (a <= c.upper() + 2*k_a*pi)) rlow = a;
	else rlow = c.lower() + 2*(k_a + 1)*pi;
	if ((b >= c.lower() + 2*k_b*pi) && (b <= c.upper() + 2*k_b*pi)) rupp = b;
	else rupp = c.upper() + 2*(k_b - 1)*pi;

	k_a = floor((a - d.lower()) / (2*pi));
	k_b = ceil((b - d.upper()) / (2*pi));
	if ((a >= d.lower() + 2*k_a*pi) && (a <= d.upper() + 2*k_a*pi)) rlow2 = a;
	else rlow2 = d.lower() + 2*(k_a + 1)*pi;
	if ((b >= d.lower() + 2*k_b*pi) && (b <= d.upper() + 2*k_b*pi)) rupp2 = b;
	else rupp2 = d.upper() + 2*(k_b - 1)*pi;

	Interval result(hull(Interval(rlow, rupp), Interval(rlow2, rupp2)));
	return result;
}

Interval invTan(const Interval& i1, const Interval& i2)
{
	double a = i2.lower();
	double b = i2.upper();
	Interval c = atan(i1);
	Interval result;
	double rlow, rupp;

	int k_a = floor((a - c.lower()) / pi);
	int k_b = ceil((b - c.upper()) / pi);

	if ((a >= c.lower() + k_a*pi) && (a <= c.upper() + k_a*pi)) rlow = a;
	else rlow = c.lower() + (k_a + 1)*pi;
	if ((b >= c.lower() + k_b*pi) && (b <= c.upper() + k_b*pi)) rupp = b;
	else rupp = c.upper() + (k_b - 1)*pi;

	result.set(rlow, rupp);
	return result;
}

Interval invASin(const Interval& i1, const Interval& i2)
{
	return intersect(sin(i1), i2);
}

Interval invACos(const Interval& i1, const Interval& i2)
{
	return intersect(cos(i1), i2);
}

Interval invATan(const Interval& i1, const Interval& i2)
{
	return intersect(tan(i1), i2);
}

Interval invExp(const Interval& i1, const Interval& i2)
{
	return intersect(log(i1), i2);
}

Interval invLog(const Interval& i1, const Interval& i2)
{
	return intersect(exp(i1), i2);
}