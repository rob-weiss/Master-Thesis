function t = typeof(A)
%TYPEOF       Type of A
%
%   t = typeof(A)
%
%For details, see intval\typeof and intval\typeadj.
%

% written  05/22/09     S.M. Rump 
% modified 04/04/14     S.M. Rump  affari added
%

% taylor\@taylor\typeof:  a  must be taylor
  if isa(A.t,'intval')
    t = 'taylorintval';
  elseif isa(A.t,'affari')
    t = 'tayloraffari';
  else
    t = 'taylor';
  end
