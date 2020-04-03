function A = trace(A)
%TRACE        Implements  trace(A)  for fl-number matrices
%
%   T = trace(A)
%

% written  10/21/13     S.M. Rump
%

  A.value = sum( diag( A.value ) );
