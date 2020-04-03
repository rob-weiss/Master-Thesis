#include <string>
#include <vector>

#include "Composer.h"
#include "WrongDataException.h"
#include "WrongInputFormatException.h"

int main_handler_tc(int argc, char * argv[]);

int main_handler(int argc, char * argv[]);

#ifdef MATLAB_RELEASE

#include "MatlabLayer.h"

#include <matrix.h>
#include <mex.h>

void mexFunction_handler_tc(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);

void mexFunction_handler(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);

#endif // MATLAB_RELEASE