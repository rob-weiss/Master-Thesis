function r = mrdivide(a,b)
%MRDIVIDE     Affine arithmetic division  a / b   (b must be scalar)
%

% written  12/06/13  S.M. Rump
% modified 12/09/15     S.M. Rump  prod(size) to numel(s)
%

  if numels(b)~=1
    error('affine arithmetic division only for scalar denominator')
  end
  
  r = a./b;
  