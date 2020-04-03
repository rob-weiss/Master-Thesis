function res = all(A,dim)
%ALL          Like Matlab function "all" for affari
%
%Call
%
%   L = all(A)
%   L = all(A,dim)
%
%Same functionality as Matlab/all for affari quantity A
%
% written  08/03/14  S.M. Rump
%

  if nargin==1
    res = all(intval(A));
  else
    res = all(intval(A),dim);
  end
  