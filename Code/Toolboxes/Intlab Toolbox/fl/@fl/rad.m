function c = rad(A)
%RAD          Implements  rad(A)  for fl-type intervals
%
%   c = rad(A)
%
% mid(A) and rad(A) computed such that
%    alpha  in  < mid(A) , rad(A) >  for all alpha in A 
% see intval/rad
%

% written  11/06/13     S.M. Rump
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  A = A.value;
  if isa(A,'intval')
    rndold = getround;
    setround(1)
    c = A.inf + 0.5*(fl(A.sup)-A.inf);
    c = c - A.inf;
    setround(rndold)
  else
    c = fl(0);
  end
  