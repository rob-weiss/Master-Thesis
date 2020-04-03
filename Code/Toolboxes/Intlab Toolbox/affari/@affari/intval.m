function r = intval(a)
%INTVAL       Conversion affine arithmetic to interval
%
%   r = intval(a)
%

% written  12/06/13  S.M. Rump
% modified 08/03/14  S.M. Rump  preserve sparsity
%

  if issparse(a)
    r = sparse(a.range);
  else
    r = a.range;
  end
