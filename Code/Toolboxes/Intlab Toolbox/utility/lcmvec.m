function res = lcmvec(a)
%GCD          lcm of all elements of vector or matrix
%
%   res = lcmvec(a);
%

% written  05/17/98     S.M. Rump
%

  a = a(:);
  res = a(1);
  for i=2:length(a)
    res = abs(lcm(res,a(i)));
  end
