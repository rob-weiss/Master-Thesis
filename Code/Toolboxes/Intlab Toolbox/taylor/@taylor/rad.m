function r = rad(a)
%RAD          Taylor radius
%
%  r = rad(a)
%

% written  05/21/09     S.M. Rump
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/04/14     S.M. Rump  output float
%

  r = reshape(rad(a.t(1,:)),a.size);
