function r = cot(a)
%COT          Taylor cotangent  cot(a)
%
%Thanks to George Corliss for providing the Taylor expansion
%

% written  06/03/09     S.M. Rump
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
 
  r = a;
  ct = a.t;
  N = size(a.t,2);
  r.t(1,:) = cot(a.t(1,:));
  ct(1,:) = 1+r.t(1,:).^2;     % 1+a^2
  r.t(2,:) = - ct(1,:) .* a.t(2,:);
  for i=2:K
    ct(i,:) = sum( r.t(1:i,:).*r.t(i:-1:1,:) , 1 );
    r.t(i+1,:) = - sum( ct(1:i,:).*a.t(i+1:-1:2,:).*repmat((i:-1:1)',1,N) , 1 )/i;
  end

  if rndold
    setround(rndold)
  end
