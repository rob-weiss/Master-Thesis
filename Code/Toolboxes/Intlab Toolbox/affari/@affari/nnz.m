function c = nnz(a)
%DIAM         number of nonzero elements for affine arithmetic
%
%  c = nnz(a);
%

% written  03/08/14     S.M. Rump
%

  c = nnz(intval(a));
