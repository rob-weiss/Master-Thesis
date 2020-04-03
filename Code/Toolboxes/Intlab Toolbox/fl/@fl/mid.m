function c = mid(A)
%RAD          Implements  mid(A)  for fl-type intervals
%
%   c = mid(A)
%
% mid(A) and rad(A) computed such that
%    alpha  in  < mid(A) , rad(A) >  for all alpha in A 
% see intval/mid
%

% written  11/06/13     S.M. Rump
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  a = A.value;
  if isa(a,'intval')
    rndold = getround;
    setround(1)
    c = a.inf + 0.5*(fl(a.sup)-a.inf);
    setround(rndold)
  else
    c = A;
  end
  