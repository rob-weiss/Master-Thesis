function r = cos(a)
%COS          Taylor cosine  cos(a)
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

  K = INTLAB_CONST.TAYLOR_ORDER;
  
  st = a.t;
  r = a;
  N = size(a.t,2);
  st(1,:) = sin(a.t(1,:));
  r.t(1,:) = cos(a.t(1,:));
  for j=2:K
    at_ = a.t(2:j,:);           % some 3 % faster 
    st(j,:) = sum( repmat((1:j-1)',1,N).*r.t(j-1:-1:1,:).*at_ , 1 ) ./ (j-1);
    r.t(j,:) = - sum( repmat((1:j-1)',1,N).*st(j-1:-1:1,:).*at_ , 1 ) ./ (j-1);
  end
  r.t(K+1,:) = - sum( repmat((1:K)',1,N).*st(K:-1:1,:).*a.t(2:K+1,:) , 1 ) ./ K;

  if rndold
    setround(rndold)
  end
