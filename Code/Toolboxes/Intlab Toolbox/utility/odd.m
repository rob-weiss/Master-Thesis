function res = odd(n)
%ODD          Boolean function: n odd?
%
%   res = 1    n odd
%   res = 0    n even or NaN
%
%   res = odd(n);
%

% written  10/29/97     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 04/04/04     S.M. Rump  output logical
% modified 05/18/14     S.M. Rump  code optimization
%

  index = isnan(n);
  if any(index(:))
    res = false(size(n));
    index = ~index;
    res(index) = logical(mod(n(index),2));
  else
    res = logical(mod(n,2));
  end
