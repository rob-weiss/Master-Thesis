function a = mrdivide(a,b)
%MRDIVIDE     Implements  a / b  for slopes
%

% written  12/06/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    improved performance
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 12/12/15     S.M. Rump  prod(size) to numel(s)
%

  if numels(b)~=1
    error('slope division only for scalar denominator')
  end
  a = a ./ b;
