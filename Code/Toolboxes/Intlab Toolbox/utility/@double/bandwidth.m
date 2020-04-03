function [p,q] = bandwidth(A)
%BANDWIDTH    Upper and lower bandwidth of matrix A
%
%   A   = 0  for  i-j > p  or j-i > q
%    ij
%
%    [p,q] = bandwidth(A);
%
%When called with 1 output argument, the result is max(p,q).
%

% Moved to @double to cure Matlab bug

% written  10/16/98     S.M. Rump
% modified 09/21/02     S.M. Rump  zero matrix and one output argument corrected
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 10/21/13     S.M. Rump  comment
% modified 05/15/14     S.M. Rump  code optimization
% modified 12/10/15     S.M. Rump  Moved to @double to cure Matlab bug
%

  if isequal(A,0)
    p = 0;
    q = 0;
  else
    [i j] = find(A);
    d = i-j;
    if isempty(d)
      p = 0;
      q = 0;
    else
      p = max(d);
      q = -min(d);
    end
  end

  if nargout<=1
    p = max(abs(p),abs(q));
  end
  