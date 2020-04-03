function a = mid(a)
%MID          Taylor midpoint
%
%  r = mid(a)
%

% written  05/21/09     S.M. Rump
% modified 04/04/14     S.M. Rump  affari added
% modified 05/18/14     S.M. Rump  code optimization
%

  if isa(a.t,'intval') || isa(a.t,'affari')
    a.t = mid(a.t);
  end
