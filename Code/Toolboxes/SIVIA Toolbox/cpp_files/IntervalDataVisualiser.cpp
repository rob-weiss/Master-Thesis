#include "Handlers.h"

/*! \mainpage IVIZ Documentation
 *
 * \section intro_sec Information about compilation
 *
 * For complitation as MEX file, define MATLAB_RELEASE for preprocessor, please.
 *
 */

/*! \brief This is main function for calling from command line.
 *
 *  1. parameter => count of the visualisations
 *  2. parameter => size_of_x
 *  3. parameter => size_of_y
 *  next parameters => type of input, parameters for input; ....
 */
extern "C"
int main(int argc, char * argv[])
{
	return main_handler_tc(argc, argv);
}

#ifdef MATLAB_RELEASE

#include <matrix.h>
#include <mex.h>

/*! \brief mexFunction. This is main function of Mex files called from MATLAB.
 *
 *  nlhs ~ Number of expected output mxArrays.
 *  plhs ~ Array of pointers to the expected output mxArrays.
 *  nrhs ~ Number of input mxArrays.
 *  prhs ~ Array of pointers to the input mxArrays. Do not modify any prhs values in your MEX-file. Changing the data in these read-only mxArrays can produce undesired side effects.
 *  For further details see http://www.mathworks.com/help/matlab/apiref/mexfunction.html.
 *  1. parameter => count of the visualisations
 *  2. parameter => size_of_x
 *  3. parameter => size_of_y
 *  next parameters => type of input, parameters for input; ....
 */
extern "C"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	mexFunction_handler_tc(nlhs, plhs, nrhs, prhs);
}

#endif // MATLAB_RELEASE