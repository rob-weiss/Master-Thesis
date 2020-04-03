function n = dim(A)
%DIM          Dimension of a square fl-type matrix
%
%    n = dim(A)
%

% written  10/21/13  S.M. Rump
%

  [m n] = size(A.value);

  if m ~= n
    error('function dim called with non-square matrix')
  end;
