function r = exp(a)
%EXP          Taylor exponential  exp(a)
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
  N = size(a.t,2);
  r.t(1,:) = exp(a.t(1,:));
  for j=2:K1
    r.t(j,:) = sum( repmat((1:j-1)',1,N).*r.t(j-1:-1:1,:).*a.t(2:j,:) , 1 ) ./ (j-1);
  end

  if rndold
    setround(rndold)
  end
