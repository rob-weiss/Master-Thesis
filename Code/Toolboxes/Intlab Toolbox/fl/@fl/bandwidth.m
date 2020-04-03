function [p,q] = bandwidth(A)
%BANDWIDTH    Upper and lower bandwidth of fl-type matrix A
%
%   A   = 0  for  i-j > p  or j-i > q
%    ij
%
%    [p,q] = bandwidth(A)
%
%When called with 1 output argument, the result is max(p,q).
%

% written  10/21/13  S.M. Rump
%

  [p,q] = bandwidth(A.value);

  if nargout<=1
    p = max(abs(p),abs(q));
  end
