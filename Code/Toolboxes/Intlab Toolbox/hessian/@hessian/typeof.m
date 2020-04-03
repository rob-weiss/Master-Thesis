function t = typeof(A)
%TYPEOF       Type of A
%
%   t = typeof(A)
%
%For details, see intval\typeof and intval\typeadj.
%

% written  04/04/04     S.M. Rump
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 04/04/14     S.M. Rump  affari added
%

% hessian\@hessian\typeof:  input  a  must be hessian
  if isa(A.x,'intval')
    t = 'hessianintval';
  elseif isa(A.x,'affari')
    t = 'hessianaffari';
  else
    t = 'hessian';
  end
