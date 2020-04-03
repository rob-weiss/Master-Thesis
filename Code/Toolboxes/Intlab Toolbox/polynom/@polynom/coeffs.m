function r = coeffs(p)
%COEFFS       (row) vector of coefficients of univariate polynomial
%
%   r = coeffs(p)      % same as vector(p)
%

% written  07/29/16     S.M. Rump
%

  if size(p.e,2)>1
    error('input multivariate polynomial')
  else
    r = p.c;
  end
