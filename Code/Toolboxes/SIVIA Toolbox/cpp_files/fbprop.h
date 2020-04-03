#ifndef FBPROP_H
#define FBPROP_H

#include <boost/numeric/interval.hpp>
#include <vector>
#include <map>

using namespace boost::numeric;
typedef interval<double, interval_lib::policies<interval_lib::save_state<interval_lib::rounded_transc_std<double> >, interval_lib::checking_base<double> > > Interval;

static const double pi = 3.141592653589793238462643383279502884197;

/* Inverse interval operations for supported functions */
Interval invPlus(const Interval&, const Interval&, const Interval&);
Interval invMinus(const Interval&, const Interval&, const Interval&);
Interval invMinusR(const Interval&, const Interval&, const Interval&);
Interval invMult(const Interval&, const Interval&, const Interval&);
Interval invDiv(const Interval&, const Interval&, const Interval&);
Interval invDivR(const Interval&, const Interval&, const Interval&);
Interval invEq(const Interval&, const Interval&, const Interval&);
Interval invPow(const Interval&, const Interval&, const Interval&);
Interval invPowR(const Interval&, const Interval&, const Interval&);
Interval invRoot(const Interval&, const Interval&, const Interval&);
Interval invRootR(const Interval&, const Interval&, const Interval&);
Interval invAbs(const Interval&, const Interval&);
Interval invSqr(const Interval&, const Interval&);
Interval invSqrt(const Interval&, const Interval&);
Interval invSin(const Interval&, const Interval&);
Interval invCos(const Interval&, const Interval&);
Interval invTan(const Interval&, const Interval&);
Interval invASin(const Interval&, const Interval&);
Interval invACos(const Interval&, const Interval&);
Interval invATan(const Interval&, const Interval&);
Interval invLog(const Interval&, const Interval&);
Interval invExp(const Interval&, const Interval&);
Interval invUMinus(const Interval&, const Interval&);

// inverse integer power and root operations, take the lower bound of the second interval
Interval powInt(const Interval&, const Interval&);
Interval rootInt(const Interval&, const Interval&);

template <class T1, class T2, class T3>
class Triple { 
public:
	Triple() {};
	Triple(T1 v1, T2 v2, T3 v3) : val1(v1), val2(v2), val3(v3) {};
	T1 fst() { return val1; };
	T2 snd() { return val2; };
	T3 trd() { return val3; };
private:
	T1 val1;
	T2 val2;
	T3 val3;
};

/* Node class and derived classes */
class Node {
public:
	Node();
	Node(Interval intval, const std::string& s);
	void setIntval(Interval i) { intval_ = i; };
	void setName(const std::string& s) { name_ = s; };
	void setChild(Node* child, char lr) { if (lr == 'l') leftChild = child; else if (lr == 'r') rightChild = child; };
	Interval getIntval() { return intval_; };
	std::string getName() { return name_; };
	// Node* getChild(char lr) { if (lr == 'l') return leftChild; else if (lr == 'r') return rightChild; };
	void fProp(std::map<std::string, Interval>&);
	std::multimap<std::string, Interval> bProp(std::multimap<std::string, Interval>&);
	virtual Interval evaluate(const Interval&, const Interval&) { return intval_; };
	virtual Interval evaluateInv(const Interval&, const Interval&, const Interval&) { return intval_; };
	virtual bool isConst() { return false; }
	//void printNode();
protected:
	Interval intval_;
	std::string name_;
	Node* leftChild;
	Node* rightChild;
	bool isLeaf;
	bool status;
};

class LeafNode : public Node {
public:
	LeafNode(Interval intval, const std::string& s, bool isConst);
	bool isConst() { return isConst_; }
private:
	bool isConst_;
};

class UnaryOpNode : public Node {
public:
	UnaryOpNode(Interval intval, const std::string& s, Node* left = NULL);
	Interval evaluate(const Interval& i1, const Interval& i2) { return eval(i1); }
	Interval evaluateInv(const Interval& i1, const Interval& i2, const Interval& i3) { if (status == 0) return invEval(i1, i3); else return invEvalR(i1, i3); };
private:
	Interval (*eval) (const Interval&);
	Interval (*invEval) (const Interval&, const Interval&);
	Interval (*invEvalR) (const Interval&, const Interval&);
};

class BinaryOpNode : public Node {
public:
	BinaryOpNode(Interval intval, const std::string& s, Node* left = NULL, Node* right = NULL);
	Interval evaluate(const Interval& i1, const Interval& i2) { return eval(i1, i2); };
	Interval evaluateInv(const Interval& i1, const Interval& i2, const Interval& i3) { if (status == 0) return invEval(i1, i2, i3); else return invEvalR(i1, i2, i3); };
private:
	Interval (*eval) (const Interval&, const Interval&);
	Interval (*invEval) (const Interval&, const Interval&, const Interval&);
	Interval (*invEvalR) (const Interval&, const Interval&, const Interval&);
};


/* Parser class for building an expression tree */
class Parser {
public:
	Parser() : vars() {};
	Node* parseExpr(const std::string& expr, std::vector<Interval>& box);
	std::vector<Interval> fbProp(const std::string& expr, std::vector<Interval>& box);
	bool isoperator(char c);
	bool isoperator(const std::string& s);
private:
	std::map<std::string, Interval> vars;
};

#endif