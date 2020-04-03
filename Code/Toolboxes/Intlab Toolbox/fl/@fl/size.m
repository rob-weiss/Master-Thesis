function [m,n] = size(A,dim)
%SIZE         Implements  size(a)  for fl-type
%
%   [m,n] = size(A,dim)
%
% functionality as Matlab function size, second argument dim optional
%

% written  10/21/13     S.M. Rump
%

  if nargout==2
    [m n] = size(A.value);
  else
    if nargin==1
      m = size(A.value);
    else
      m = size(A.value,dim);
    end
  end
