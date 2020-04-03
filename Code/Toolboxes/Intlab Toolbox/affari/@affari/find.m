function [I,J,V] = find(a)
%FIND         Implements  find(a)  for sparse affari matrix
%
%   I = find(a)
%   [I,J] = find(a)
%   [I,J,V] = find(a)
%
%Functionality as in Matlab.
%

% written  08/09/02     S.M. Rump 
%

  if nargout<=1
    I = find(intval(a));
  elseif nargout==2
    [I,J] = find(intval(a));
  elseif nargout==3
    [I,J,V] = find(intval(a));
  end
  