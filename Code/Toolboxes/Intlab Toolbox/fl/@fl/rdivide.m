function C = rdivide(A,B)
%RDIVIDE      fl-type division  A ./ B
%

% written  10/21/13     S.M. Rump
%

  if isa(A,'fl')
    A = A.value;
  end

  if isa(B,'fl')
    B = B.value;
  end

  C = fl( A ./ B );
  
  