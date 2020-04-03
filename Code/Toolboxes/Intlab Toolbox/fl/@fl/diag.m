function A = diag(A,k)
%DIAG         Implements  diag(a,k)  for fl-type matrices
%
%   c = diag(a,k)
%
% functionality as Matlab function diag for matrices
%

% written  10/21/13  S.M. Rump
%

  if nargin==1
    k = 0;
  end

  A.value = diag(A.value,k);
  