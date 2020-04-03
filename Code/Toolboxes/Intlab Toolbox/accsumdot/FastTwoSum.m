function [x,y] = FastTwoSum(a,b)
%FASTTWOSUM   Error-free transformation of a+b into x+y with x=fl(a+b)
%
%   [x,y] = FastTwoSum(a,b)
%
%On return, x+y=a+b and x=fl(a+b) provided ufp(b)<=ufp(a) .
%Input a,b may be vectors or matrices as well.
%
%Follows T.J. Dekker: A floating-point technique for extending the available
%  precision, Numerische Mathematik 18:224-242, 1971.
%Requires 3 flops.
%
%Reference implementation! Slow due to interpretation!
%

% written  03/03/07     S.M. Rump
% modified 05/09/09     S.M. Rump  rounding to nearest
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  rndold = getround;
  if rndold
    setround(0)
  end

  x = a + b;
  y = (a-x) + b;
  
  if rndold
    setround(rndold)
  end
