function [p,q] = bandwidth(A)
%BANDWIDTH    Upper and lower bandwidth of affari matrix A
%
%   A   = 0  for  i-j > p  or j-i > q
%    ij
%
%    [p,q] = bandwidth(A);
%
%When called with 1 output argument, the result is max(p,q).
%

% written  08/09/02     S.M. Rump 
% modified 05/17/14     S.M. Rump  code optimization
%

  if nargout==2
    [p,q] = bandwidth(intval(A));
  else
    p = bandwidth(intval(A));
  end
