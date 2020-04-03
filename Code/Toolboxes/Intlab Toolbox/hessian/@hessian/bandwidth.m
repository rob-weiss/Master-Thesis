function [p,q] = bandwidth(A)
%BANDWIDTH    Upper and lower bandwidth of matrix A
%
%   A   = 0  for  i-j > p  or j-i > q
%    ij
%
%    [p,q] = bandwidth(A)
%
%When called with 1 output argument, the result is max(p,q).
%


% written  04/04/04     S.M. Rump
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 10/21/13     S.M. Rump  comment
%

  [p,q] = bandwidth(A.x);
