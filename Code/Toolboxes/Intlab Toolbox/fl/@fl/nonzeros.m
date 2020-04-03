function A = nonzeros(A)
%NONZEROS     Implements  nonzeros(a)  for fl-type matrix
%
%   C = nonzeros(A)
%
%Functionality as in Matlab.
%

% written  11/06/13     S.M. Rump
%

  A.value = nonzeros(A.value);
  