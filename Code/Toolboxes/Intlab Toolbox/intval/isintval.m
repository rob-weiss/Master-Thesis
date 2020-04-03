function r = isintval(a)
%ISINTVAL     Returns 1 if  a  is intval
%
%   r = isintval(a)
%

% written  09/02/00     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 05/15/14     S.M. Rump  code optimization
%

  r = false;
