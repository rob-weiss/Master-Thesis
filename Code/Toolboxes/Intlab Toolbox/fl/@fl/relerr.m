function res = relerr(A,B)
%RELERR       Entrywise relative error for fl-type
%
%   res = relerr(A,B)
%

% written  10/21/13     S.M. Rump
%

  if isa(A,'fl')
    if isa(B,'fl')
      res = relerr(A.value,B.value);
    else
      res = relerr(A.value,B);
    end
  else
    res = relerr(A,B.value);
  end