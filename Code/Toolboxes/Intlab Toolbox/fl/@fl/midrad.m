function C = midrad(A,B)
%MIDRAD       intval of fl-types by midpoint/radius representation
%
%  X = midrad(A,R)
%
%Note that A,R are first rounded into k-bit fl-quantities, then the interval X
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

  C = fl( midrad(A,B) );  
  