function res = gt(a,b)
%GT           Implements  a > b  for Taylor, compares only function value, not derivatives
%

% written  05/21/09     S.M. Rump
% modified 04/27/14     S.M. Rump  comment
%

  if ~isa(a,'taylor')
    res = ( a>reshape(b.t(1,:),b.size) );
  elseif ~isa(b,'taylor')
    res = ( reshape(a.t(1,:),a.size)>b );
  else
    res = ( reshape(a.t(1,:),a.size)>reshape(b.t(1,:),b.size) );
  end
