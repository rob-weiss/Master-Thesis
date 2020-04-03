function t = typeof(A)
%TYPEOF       Type of A
%
%   t = typeof(A)
%
%For details, see intval\typeof and intval\typeadj.
%

% written  08/28/00     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
%

% polynom\@polynom\typeof:  a  must be polynom
  if isa(A.c,'intval')
    t = 'polynomintval';
  else
    t = 'polynom';
  end
