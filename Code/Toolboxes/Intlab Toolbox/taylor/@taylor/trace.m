function c = trace(a)
%TRACE        Implements  trace(a)  for Taylor
%
%   c = trace(a)
%

% written  05/21/09     S.M. Rump
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  rndold = getround;
  if rndold
    setround(0)
  end

  c = sum( diag( a ) );
  
  if rndold
    setround(rndold)
  end
