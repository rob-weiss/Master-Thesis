function t = typeof(A)
%TYPEOF       Type of A
%
%   t = typeof(A)
%
%For details, see intval\typeof and intval\typeadj.
%

% written  10/16/98     S.M. Rump
% modified 12/06/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 04/04/14     S.M. Rump  affari added
%

% gradient\@gradient\typeof:  a  must be gradient
  if isa(A.x,'intval')
    t = 'gradientintval';
  elseif isa(A.x,'affari')
    t = 'gradientaffari';
  else
    t = 'gradient';
  end
