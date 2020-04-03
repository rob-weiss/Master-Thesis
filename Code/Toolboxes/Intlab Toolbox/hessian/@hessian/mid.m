function a = mid(a)
%MID          Hessian midpoint
%
%  r = mid(a)
%

% written  04/04/04     S.M. Rump
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 04/04/14     S.M. Rump  affari added
%

  if isa(a.x,'intval') || isa(a.x,'affari')
    a.x = mid(a.x);
    a.dx = mid(a.dx);
    a.hx = mid(a.hx);
  end
