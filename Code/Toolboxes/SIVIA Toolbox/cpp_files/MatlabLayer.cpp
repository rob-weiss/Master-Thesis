#include "MatlabLayer.h"

#include <string>
#include <vector>

#include "WrongInputFormatException.h"

/*
 ******************************************************************************
 *********************************** FOR MATLAB *******************************
 ******************************************************************************
 */

#ifdef MATLAB_RELEASE

#include <mex.h>
#include <matrix.h>

/*! \brief Returns mxArray* created from vector of doubles.
 *
 */
mxArray* GetMexArray(const std::vector<double>& v)
{
	mxArray * mx = mxCreateDoubleMatrix(1, (int)v.size(), mxREAL);

	for (int i = 0; i < v.size(); ++i)
	{
		mxGetPr(mx)[i] = v[i];
	}

	return mx;
}

/*! \brief Returns vector of doubles created from mxArray*.
 *
 */
std::vector<double> GetVector(const mxArray* input)
{
	if (! mxIsDouble(input))
	{
		ExportString("input parameter is not vector of doubles");
		throw new WrongInputFormatException("input parameter is not string");
	}

	std::vector<double> nv;

	std::size_t dim = mxGetNumberOfElements(input);
	double* fst = mxGetPr(input);
	for (std::size_t i = 0; i < dim; ++i)
	{
		nv.push_back(*(fst + i));
	}

	return nv;
}

/*! \brief Returns string created from mxArray*.
 *
 */
std::string GetString(const mxArray* input)
{
	if (! mxIsChar(input))
	{
		ExportString("input parameter is not string");
		throw new WrongInputFormatException("input parameter is not string");
	}

	std::string s = mxArrayToString(input);
	return s;
}

/*! \brief Returns double created from mxArray*.
 *
 */
double GetDouble(const mxArray* input)
{
	if (! mxIsDouble(input))
	{
		ExportString("input parameter is not double");
		throw new WrongInputFormatException("input parameter is not double");
	}

	double * dp = mxGetPr(input);
	double d = *dp;
	return d;
}

/*! \brief Runs MATLAB saving dialog.
 *
 */
std::string RunSavingDialog()
{
	std::string file;
	std::string directory;

	mxArray * out[2];
	char* arg1 = "picture";
	char* arg2 = "destination";
	const char* rew1[1];
	const char* rew2[1];
	rew1[0] = arg1;
	rew2[0] = arg2;
	mxArray* in1 = mxCreateCharMatrixFromStrings(1, static_cast<const char**>(rew1));
	mxArray* in2 = mxCreateCharMatrixFromStrings(1, static_cast<const char**>(rew2));
	mxArray* in[2];
	in[0] = in1;
	in[1] = in2;
	mexCallMATLAB(2, out, 2, in, "uiputfile");

	double* fst_check = mxGetPr(out[0]);
	double* snd_check = mxGetPr(out[1]);
	if (*fst_check == 0 || *snd_check == 0)
	{
		ExportString("no file selected or wrong path\n");
		return "";
	}

	char *buf1 = mxArrayToString(out[0]);
	char *buf2 = mxArrayToString(out[1]);
	file.append(buf1);
	directory.append(buf2);
	mxFree(buf1);
	mxFree(buf2);

	std::string result;
	result.append(directory);
	result.append(file);
	return result;
}

/*! \brief Exports string to MATLAB.
 *
 */
void ExportString(const std::string& str)
{
	ExportString(str.c_str());
}

/*! \brief Exports string to MATLAB.
 *
 */
void ExportString(const char* arr)
{
	mexPrintf(arr);
	mexEvalString("drawnow;");
	//ssPrintf(arr);
}

#endif // MATLAB_RELEASE

/*
 ******************************************************************************
 ********************************* FOR non-MATLAB *****************************
 ******************************************************************************
 */

#ifndef MATLAB_RELEASE

#include <iostream>

/*! \brief Returns empty string. This method has not been implemented yet.
 *
 */
std::string RunSavingDialog()
{
	return "";
}

/*! \brief Exports string to std::cout.
 *
 */
void ExportString(const std::string& str)
{ 
	ExportString(str.c_str());
}

/*! \brief Exports string to std::cout.
 *
 */
void ExportString(const char* arr) 
{ 
	std::cout << arr << std::endl;
}

#endif // not MATLAB_RELEASE