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

% written  05/21/09     S.M. Rump
% modified 10/21/13     S.M. Rump  comment
%

  [p,q] = bandwidth(reshape(A.t(1,:),A.size));
