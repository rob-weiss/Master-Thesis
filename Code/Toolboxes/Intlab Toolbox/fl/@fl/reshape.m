function A = reshape(A,varargin)
%RESHAPE      Reshape for fl-type vectors/matrices
%
%   r = reshape(a,vector)  or  r = reshape(a,n1,n2,...)
%
% functionality as Matlab function reshape
%

% written  10/21/13     S.M. Rump
%

  A.value = reshape(A.value,varargin{:});
