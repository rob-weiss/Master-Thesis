function A = repmat(A,varargin)
%REPMAT       Implements  repmat(A)  for fl-type data
%
%Functionality as in Matlab.
%

% written  10/21/13     S.M. Rump 
%

  A.value = repmat(A.value,varargin{:});
  