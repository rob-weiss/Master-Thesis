function C = times(A,B)
%TIMES        fl-type elementwise multiplication  A .* B
%

% written  10/21/13     S.M. Rump
%

  if isa(A,'fl')
    A = A.value;
  end

  if isa(B,'fl')
    B = B.value;
  end

  C = fl( A .* B );
  
  