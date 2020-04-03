function c = mrdivide(a,b)
%MRDIVIDE     Implements  a / b  for intervals
%

% written  10/16/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 12/12/15     S.M. Rump  prod(size) to numel(s)
%

  if numels(b)==1
    c = a ./ b;
  else
    c = ( b' \ a' )' ;
  end
