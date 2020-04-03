function A = circulant(A)
%TOEPLITZ     Implements  circulant(r)  for fl-type
%
%   A = circulant(r)
%
%fl-type circulant matrix with first row r
%

% written  10/21/13  S.M. Rump
%

  A.value = circulant(A.value);
