function r = issparse(A)
%ISSPARSE     Returns 1 if A is sparse
%
%  r = issparse(A)
%

% written  10/21/13     S.M. Rump
%

  r = issparse(A.value);
