function res = all(a,dim)
%ANY          Like Matlab function "all" for Taylor
%
%Call
%
%   L = all(A)
%   L = all(A,dim)
%
%Same functionality as Matlab/all for intval quantity A
%

% written  05/21/09     S.M. Rump
% modified 04/27/14     S.M. Rump  any
%

  if nargin==1
    res = all(reshape(any(a.t),a.size));
  else
    res = all(reshape(any(a.t),a.size),dim);
  end
