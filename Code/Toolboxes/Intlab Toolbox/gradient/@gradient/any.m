function res = any(a,dim)
%ANY          Like Matlab function "any" for gradient
%
%Call
%
%   L = any(A)
%   L = any(A,dim)
%
%Same functionality as Matlab/any for intval quantity A
%

% written  12/06/05     S.M. Rump
% modified 04/04/14     S.M. Rump  applies only to a.x
%

  if nargin==1
    res = any(a.x);
  else
    res = any(a.x,dim);
  end
