function res = norm(a,r)
%NORM         Inclusion of norm of a matrix or vector
%
%   res = norm(a,r)
%
%   r in {1,2,inf}         for vector a
%   r in {1,2,inf,'fro'}   for matrix a
%
% default for r is 2
%
%See intval/norm, applied to intval(a).
%

% written  04/26/14     S.M. Rump
%

  if nargin==1
    res = norm(intval(a));
  else
    res = norm(intval(a),r);
  end
  