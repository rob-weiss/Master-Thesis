function c = diam(A)
%DIAM         implements  diam(A)  for fl-type
%
%   c = diam(A)
%

% written  11/06/13     S.M. Rump
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  A = A.value;
  if isa(A,'intval')
    rndold = getround;
    setround(1)
    c = fl(A.sup)-A.inf;
    setround(rndold)
  else
    c = fl(0);
  end
    