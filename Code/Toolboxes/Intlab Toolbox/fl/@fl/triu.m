function A = triu(A,k)
%TRIU         Implements  triu(a,k)  for fl-type
%
%   C = triu(A,k)
%
% functionality as Matlab function triu for matrices
%

% written  10/21/13     S.M. Rump
%

  global INTLAB_CONST

  if nargin==1
    k = 0;
  end

  A.value = triu(A.value,k);
