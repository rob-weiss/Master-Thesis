function res = all(a,dim)
%ALL          Like Matlab function "all" for hessian
%
%Call
%
%   L = all(A)
%   L = all(A,dim)
%
%Same functionality as Matlab/all for intval quantity A
%

% written  12/06/05     S.M. Rump
% modified 04/04/14     S.M. Rump  applies only to a.x
%

  if nargin==1
    res = all(a.x);
  else
    res = all(a.x,dim);
  end
