function A = full(A)
%FULL         type cast to full fl-type matrix
%
%   B = full(A)
%

% written  10/21/13     S.M. Rump
%

  A.value = full(A.value);
