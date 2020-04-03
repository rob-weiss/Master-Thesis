function r = isreal(a)
%ISREAL       returns 1 if a is real
%
%   r = isreal(a)
%
%For completeness:  returns 1 anyway because only real slopes allowed
%

% written  09/02/00     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 05/18/14     S.M. Rump  code optimization
%

  r = true;
