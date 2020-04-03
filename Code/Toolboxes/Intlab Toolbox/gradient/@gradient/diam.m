function r = diam(a)
%DIAM         Gradient diameter
%
%  r = diam(a)
%

% written  10/16/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    accelaration for sparse input
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 04/04/14     S.M. Rump  output float
%

  r = diam(a.x);
