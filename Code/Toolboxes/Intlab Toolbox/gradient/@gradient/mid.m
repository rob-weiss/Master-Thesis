function a = mid(a)
%MID          Gradient midpoint
%
%  r = mid(a)
%

% written  10/16/98     S.M. Rump
% modified 12/18/02     S.M. Rump  improved performance
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 04/04/14     S.M. Rump  affari added
% modified 05/18/14     S.M. Rump  code optimization
%

  if isa(a.x,'intval') || isa(a.x,'affari')
    a.x = mid(a.x);
    a.dx = mid(a.dx);
  end
