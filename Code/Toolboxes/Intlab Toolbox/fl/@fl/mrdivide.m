function C = mrdivide(A,B)
%MRDIVIDE     fl-type division  A / B
%

% written  10/21/13     S.M. Rump
% modified 12/09/15     S.M. Rump  prod(size) to numel(s)
%

  if isa(A,'fl')
    A = A.value;
  end

  if isa(B,'fl')
    B = B.value;
  end

  if numels(B)~=1
    error('division only for scalar divisor.')
  end
  
  C = fl( A / B );
  