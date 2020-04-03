function res = any(A,dim)
%ANY          Like Matlab function "any" for fl-type
%
%Call
%
%   L = any(A)
%   L = any(A,dim)
%
%Same functionality as Matlab/any for fl-type A
%

% written  10/21/13  S.M. Rump
%

  if nargin==1
    res = any(A.value);
  else
    res = any(A.value,dim);
  end
  