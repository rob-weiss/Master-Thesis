function res = issparse(a)
%ISSPARSE       Returns 1 if c is sparse
%
%   res = issparse(a)
%

% written  08/03/14  S.M. Rump
%

  res = issparse(a.mid);
  