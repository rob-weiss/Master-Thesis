function A = sqr(A)
%SQR          Implements (elementwise)  sqr(x)  for fl-type intervals
%
%   C = sqr(A)
%

% written  11/07/13     S.M. Rump
%

  A = fl(sqr(A.value));
  