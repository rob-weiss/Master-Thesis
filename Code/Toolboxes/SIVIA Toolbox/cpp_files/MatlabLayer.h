#ifndef _MATLAB_LAYER_HPP
#define _MATLAB_LAYER_HPP

#include <string>
#include <vector>

/*
 ******************************************************************************
 *********************************** FOR MATLAB *******************************
 ******************************************************************************
 */

#ifdef MATLAB_RELEASE

#include <mex.h>
#include <matrix.h>

#include "WrongInputFormatException.h"

mxArray* GetMexArray(const std::vector<double>& v);

std::vector<double> GetVector(const mxArray* input);

std::string GetString(const mxArray* input);

double GetDouble(const mxArray* input);

std::string RunSavingDialog();

void ExportString(const std::string& str);

void ExportString(const char* arr);

#endif // MATLAB_RELEASE

/*
 ******************************************************************************
 ********************************* FOR non-MATLAB *****************************
 ******************************************************************************
 */

#ifndef MATLAB_RELEASE

#include <iostream>

std::string RunSavingDialog();

void ExportString(const std::string& str);

void ExportString(const char* arr);

#endif // not MATLAB_RELEASE

#endif // _MATLAB_LAYER_HPP