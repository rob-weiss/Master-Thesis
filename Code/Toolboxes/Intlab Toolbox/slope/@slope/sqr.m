function u = sqr(a)
%SQR          Slope square  sqr(a)
%

% written  12/06/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST

  rndold = getround;
  if rndold
    setround(0)
  end

  INTLAB_SLOPE = INTLAB_CONST.SLOPE;

  u = a;

  u.r = sqr(a.r);
  indexc = 1:INTLAB_SLOPE.NUMVAR;
  indexr = 2:INTLAB_SLOPE.NUMVAR+1;
  u.s = a.s .* (a.r(:,indexc)+a.r(:,indexr));
  
  if rndold
    setround(rndold)
  end
