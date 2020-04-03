function res = isreal(a)
%ISREAL         returns 1 if a is real (for completeness)
%
%   res = isreal(a)
%

% written  08/03/14  S.M. Rump
%

  res = isreal(intval(a));
  