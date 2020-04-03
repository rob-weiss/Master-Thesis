function res = logical(A)
%LOGICAL      Like Matlab function "logical" for fl-type
%
%   L = logical(A)
%
%Same functionality as Matlab/logical for fl-type quantity A
%

% written  10/21/13     S.M. Rump
%

  res = logical(A.value);
