function res = isfinite(a)
%ISFINITE       Array of 1's for finite components
%
%   res = isfinte(a)
%

% written  08/03/14  S.M. Rump
%

  res = isfinite(intval(a));
  