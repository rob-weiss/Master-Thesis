function res = nonzeros(a)
%NONZEROS     Implements  nonzeros(a)  for sparse affari matrix
%
%   res = nonzeros(a)
%

% written  08/09/02     S.M. Rump 
% modified 05/17/14     S.M. Rump  code optimization
%

  res = nonzeros(intval(a));
  