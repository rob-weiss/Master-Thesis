function a = sparse(a)
%SPARSE       Convert hessian first and second derivative to sparse
%

% written  04/04/04     S.M. Rump
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 12/06/05     S.M. Rump  .x part also sparse
% modified 10/03/12     S.M. Rump  sparse up to 2 dimensions
% modified 12/12/15     S.M. Rump  Matlab 6.5 bug
%

  if length(size(a))>2
    error('sparse arrays only up to 2 dimensions')
  end
  
  a.x = sparse(a.x);
  a.dx = sparse(a.dx);
  a.hx = sparse(a.hx);
