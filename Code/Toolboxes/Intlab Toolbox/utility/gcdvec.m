function res = gcdvec(a)
%GCD          gcd of all elements of vector or matrix
%
%   res = gcdvec(a);
%

% written  05/17/98     S.M. Rump
%

  a = a(:);
  res = a(1);
  for i=2:length(a)
    res = gcd(res,a(i));
  end
