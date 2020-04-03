function [e,C,v] = tounivariate(e,c,v)
%TOUNIVARIATE Transformation to univariate polynomial
%
%On input,
% e   m x 1 array of exponents, possibly with rows occuring several times
% c   m x 1 array of corresponding (polynomial) coefficients (sparse)
% v   string or 1-item cell array of string
%
%On output, polynomial data is transformed to univariate format
%

% written  07/21/02     S.M. Rump
% modified 04/04/14     S.M. Rump  function name
%

n = max(e);           % degree of polynomial        
C = zeros(1,n+1);
if isa(c,'intval')
  C = intval(C);
end
C(n+1-e) = c;
e = n;
if iscell(v)
  v = v{1};
end
