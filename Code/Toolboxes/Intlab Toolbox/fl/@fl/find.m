function [I,J,V] = find(A)
%FIND         Implements  find(a)  for (sparse) fl-type matrix
%
%   I = find(A)
%   [I,J] = find(A)
%   [I,J,V] = find(A)
%
%Functionality as in Matlab.
%

% written  10/21/13     S.M. Rump
%

  if nargout<=1
    I = find(A.value);
  elseif nargout==2
    [I,J] = find(A.value);
  else
    [I,J,V] = find(A.value);
  end
  