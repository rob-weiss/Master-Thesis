function r = diam(a)
%DIAM         Taylor diameter
%
%  r = diam(a)
%

% written  05/21/09     S.M. Rump
% modified 04/04/14     S.M. Rump  output float
%

  r = reshape(diam(a.t(1,:)),a.size);
  