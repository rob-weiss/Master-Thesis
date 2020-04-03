function r = sqr(a)
%SQR          Taylor (elementwise) square  sqr(a)
%

% written  05/21/09     S.M. Rump
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST
  
  rndold = getround;
  if rndold
    setround(0)
  end

  K1 = INTLAB_CONST.TAYLOR_ORDER + 1;

  r = a;
  r.t(1,:) = sqr(a.t(1,:));
  for j=2:K1
    r.t(j,:) = sum(a.t(1:j,:).*a.t(j:-1:1,:),1);
  end

  if rndold
    setround(rndold)
  end
