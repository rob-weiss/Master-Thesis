function a = transpose(a)
%TRANSPOSE    Implements  a.'  for affaris
%
%  c = a.'
%

% written  09/03/14     S.M. Rump
% written  05/21/14     S.M. Rump  All zero sparse: 1-by-1
%

  [m n] = size(a.mid);
  a.mid = a.mid.';
  index = reshape(1:m*n,m,n)';
  index = index(:)';
  % take care of "All zero sparse: 1-by-1": do not use 'isempty'
  if nnz(a.err)
    a.err = a.err(:,index);
  end
  a.rnderr = a.rnderr(index);
  a.range = a.range.';
