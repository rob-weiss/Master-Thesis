function k = nnz(p)
%NNZ          Number of nonzero coefficients
%
%   k = nnz(p)
%

% written  10/04/02     S.M. Rump 
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 04/04/14     S.M. Rump  function name
%

  k = nnz(p.c);
