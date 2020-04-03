function A = ctranspose(A)
%CTRANSPOSE   Implements  a'  for fl-type matrices  (conjugate)
%
%   c = a'
%

% written  10/21/13  S.M. Rump
%

  A.value = A.value';
  