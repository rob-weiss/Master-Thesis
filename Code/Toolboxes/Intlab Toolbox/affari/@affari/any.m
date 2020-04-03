function res = any(A,dim)
%ANY          Like Matlab function "any" for affari
%
%Call
%
%   L = any(A)
%   L = any(A,dim)
%
%Same functionality as Matlab/any for affari quantity A
%
% written  08/03/14  S.M. Rump
%

  if nargin==1
    res = any(intval(A));
  else
    res = any(intval(A),dim);
  end
  