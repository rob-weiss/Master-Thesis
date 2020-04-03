function res = relerr(a,b)
%RELERR       Entrywise relative error
%             c  may be interval scalar, vector or matrix
%
%   res = relerr(c)
%
% if 0 not in c     rad/abs(mid)
% if 0 in c         rad
%
%
%For two input arguments,
%
%   res = relerr(c,d)
%
%with  res = max(relerr(c.inf,d.inf),relerr(c.sup,d.sup))
%

% written  08/09/02     S.M. Rump 
%

  if nargin==1
    res = relerr(intval(a));
  else
    res = relerr(intval(a),intval(b));
  end
  