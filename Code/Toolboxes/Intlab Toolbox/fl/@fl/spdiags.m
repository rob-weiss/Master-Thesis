function [C,d] = spdiags(A,varargin)
%SPDIAGS      Implements  spdiags  for fl-type intervals
%
% functionality as Matlab function spdiags for matrices
%

% written  11/07/13     S.M. Rump
%

  if nargout==2
    [C,d] = spdiags(A.value,varargin{:});
  else
    C = spdiags(A.value,varargin{:});
  end
  C = fl(C);
  