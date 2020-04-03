function t = erf(a)
%ERF          Taylor error function  erf(a)
%

% written  03/14/16     S.M. Rump
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST
  
  rndold = getround;
  if rndold
    setround(0)
  end
  
  K1 = INTLAB_CONST.TAYLOR_ORDER + 1;
  if isa(a.t,'intval')
    factor = infsup(INTLAB_CONST.STDFCTS_PI.REC2SQRT_PIINF, ...
                    INTLAB_CONST.STDFCTS_PI.REC2SQRT_PISUP);
  else
    factor = 2/sqrt(pi); 
  end
  
  r = a;
  s = r;
  t = s;
  N = size(a.t,2);
  
  r.t(1,:) = - sqr(a.t(1,:));
  s.t(1,:) = exp(r.t(1,:));
  t.t(1,:) = erf(a.t(1,:));
  for j=2:K1
    r.t(j,:) = - sum(a.t(1:j,:).*a.t(j:-1:1,:),1);
    s.t(j,:) = sum( repmat((1:j-1)',1,N).*s.t(j-1:-1:1,:).*r.t(2:j,:) , 1 ) ./ (j-1);
    t.t(j,:) = factor*sum( repmat((1:j-1)',1,N).*s.t(j-1:-1:1,:).*a.t(2:j,:) , 1 ) ./ (j-1);
  end

  if rndold
    setround(rndold)
  end
