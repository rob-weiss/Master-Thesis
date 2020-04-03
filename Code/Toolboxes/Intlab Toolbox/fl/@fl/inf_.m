function c = inf_(A)
%INF_         Implements  inf(A)  (cures problems with inf)
%
%   c = inf(A)
%
% On return, inf(A) <= alpha for all entries alpha in A, same as A.inf
%
%************************************************************************
%********  due to conflict with internal variable inf (infinity)  *******
%********                    use function inf_                    *******
%************************************************************************
%

% written  11/07/13     S.M. Rump
%

  if isa(A.value,'intval')
    c = A.value.inf;
  else
    c = A.value;
  end
