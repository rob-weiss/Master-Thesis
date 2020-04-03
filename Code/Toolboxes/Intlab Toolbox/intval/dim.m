function n = dim(A)
%DIM          Dimension of a square matrix
%
%    n = dim(A);
%

% written  10/16/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 05/15/14     S.M. Rump  code optimization
%

  [m,n] = size(A);
  if m~=n,
    error('*** function dim called with non-square matrix ***')
  end;
