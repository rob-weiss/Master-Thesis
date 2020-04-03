function A = toeplitz(A,r)
%TOEPLITZ     Implements  toeplitz(c,r)  for fl-type
%
%   A = toeplitz(c,r)
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
    A.value = toeplitz(A.value);
  else
    A.value = toeplitz(A.value,r.value);
  end
  