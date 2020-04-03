function c = trace(a)
%TRACE        Implements  trace(a)  for gradients
%
%   c = trace(a)
%

% written  10/16/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
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
