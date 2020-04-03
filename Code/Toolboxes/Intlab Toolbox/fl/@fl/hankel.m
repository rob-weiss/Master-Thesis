function A = hankel(A,r)
%HANKEL       Implements  hankel(c,r)  for fl-type
%
%   A = hankel(c,r)
%
% functionality as Matlab function toeplitz
%

% written  10/21/13     S.M. Rump
% 

  A = fl(A);
  if nargin==2
    r = fl(r);
  end

  if nargin==1
    A.value = hankel(A.value);
  else
    A.value = hankel(A.value,r.value);
  end
