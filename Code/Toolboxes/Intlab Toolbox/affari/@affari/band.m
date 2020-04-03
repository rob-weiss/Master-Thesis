function c = band(a,p,q)
%BAND         Extract band from matrix a, lower bandwidth p, upper bandwidth q
%   if parameter q is omitted, q:=p
%
%   c = band(a,p,q)
%

% written  08/09/02     S.M. Rump 
%

  if nargin<3
    q = p;
  end

  c = tril(triu(a,-p),q);
  