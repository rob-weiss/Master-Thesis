function C = infsup(A,B)
%INFSUP       interval of fl-type by infimum/supremum representation
%
%  X = infsup(A,B)
%
%Note that A,B are first rounded into k-bit fl-type, then the interval X
%is produced. 
%

% written  10/21/13     S.M. Rump
% modified 05/18/14     S.M. Rump  code optimization
%

  if isintval(A) || isintval(B)
    error('invalid call')
  end

  if isa(A,'fl')
    A = A.value;
  end

  if isa(B,'fl')
    B = B.value;
  end

  C = fl( infsup(A,B) );  
  