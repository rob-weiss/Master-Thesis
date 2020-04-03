function t = typeof(A)
%TYPEOF       Type of A
%
%   t = typeof(A)
%
%For details, see intval\typeof and intval\typeadj.
%

% written  04/04/14     S.M. Rump
%

% fl\@fl\typeof:  a  must be fl
  if isintval(A.value)
    t = 'flintval';
  else
    t = 'fl';
  end
