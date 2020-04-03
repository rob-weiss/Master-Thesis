function res = ufp(x)
%UFP          unit in the first place (ufp) of real (vector, matrix) x
%
%   res = ufp(x)
%
%

% written  10/18/08     S.M. Rump
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  rndold = getround;
  if rndold
    setround(0)
  end
  
  [f,e] = log2(abs(x));                 % the easy way
  res = pow2(floor(2*f)/2,e);

  if rndold
    setround(rndold)
  end
