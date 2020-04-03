function res = logical(a)
%LOGICAL      Like Matlab function "logical" for intval
%
%Call
%
%   L = logical(A)
%
%Same functionality as Matlab/logical for intval quantity A
%

% written  08/09/02     S.M. Rump 
%

  res = logical(intval(a));
  