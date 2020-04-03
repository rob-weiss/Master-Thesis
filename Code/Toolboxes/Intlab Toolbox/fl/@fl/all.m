function res = all(A,dim)
%ALL          Like Matlab function "all" for fl-type
%
%Call
%
%   L = all(A)
%   L = all(A,dim)
%
%Same functionality as Matlab/all for fl-type A
%

% written  10/21/13  S.M. Rump
%

  if nargin==1
    res = all(A.value);
  else
    res = all(A.value,dim);
  end
  