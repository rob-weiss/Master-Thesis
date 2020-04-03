function r = nnz(A)
%NNZ          Implements  nnz(a)  for sparse fl-type matrix
%
%   r = nnz(A)
%
%Functionality as in Matlab.
%

% written  10/21/13     S.M. Rump
%

  r = nnz(spones(A.value));
