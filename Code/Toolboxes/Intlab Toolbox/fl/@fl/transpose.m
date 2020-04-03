function A = transpose(A)
%TRANSPOSE    Implements  A.'  for fl-type (not conjugate)
%
%  C = A.'
%

% written  10/21/13     S.M. Rump
%

  A.value = A.value.';
