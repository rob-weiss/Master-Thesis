function u = exp(a)
%EXP          Slope exponential  exp(a)
%

% written  12/06/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  rndold = getround;
  if rndold
    setround(0)
  end

  u = a;

  u.r = exp(a.r);
  u.s = slopeconvexconcave('exp','exp(%)',a,1);
  
  if rndold
    setround(rndold)
  end
