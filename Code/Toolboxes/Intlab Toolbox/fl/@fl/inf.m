function c = inf(A)
%INF          Implements  inf(A) 
%
%   c = inf(A)
%
% On return, inf(A) <= alpha for all entries alpha in A, same as A.inf
%

% written  11/07/13     S.M. Rump
%

  if isa(A.value,'intval')
    c = A.value.inf;
  else
    c = A.value;
  end
