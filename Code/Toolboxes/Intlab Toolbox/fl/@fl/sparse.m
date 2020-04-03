function A = sparse(A)
%SPARSE       type cast to sparse fl-type matrix
%
%   Y = sparse(X)
%

% written  10/21/13     S.M. Rump
%

  A.value = sparse(A.value);
