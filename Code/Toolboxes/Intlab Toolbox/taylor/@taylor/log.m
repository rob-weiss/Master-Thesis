function r = log(a)
%LOG          Taylor logarithm  log(a)
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
  r.t(1,:) = log(a.t(1,:));
  r.t(2,:) = a.t(2,:) ./ a.t(1,:);  % careful: sum(a-[])=0, not a !
  for j=3:K1
    r.t(j,:) = ( (j-1)*a.t(j,:) - sum( repmat((1:j-2)',1,N).*a.t(j-1:-1:2,:).*r.t(2:j-1,:) , 1 ) ) ...
                      ./ ((j-1)*a.t(1,:));
  end

  if rndold
    setround(rndold)
  end
