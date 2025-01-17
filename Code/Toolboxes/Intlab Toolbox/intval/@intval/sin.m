function y = sin(x)
%SIN          Implements  sin(x)  for intervals
%
%   y = sin(x)
%
%interval standard function implementation
%

% written  12/30/98     S.M. Rump
% modified 08/31/99     S.M. Rump  complex allowed, NaN input, array input,
%                                  sparse input, major revision,
%                                  improved accuracy
% modified 09/02/00     S.M. Rump  rounding unchanged after use
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    accelaration for sparse input
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/06/07     S.M. Rump  approximate std fcts removed
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 05/15/14     S.M. Rump  code optimization
% modified 03/24/16     S.M. Rump  range [-1,1] (Thanks to M. Kashiwagi)
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  if issparse(x)
    [ix,jx,sx] = find(x);
    [m,n] = size(x);
    y = sparse(ix,jx,sin(full(sx)),m,n);
    return
  end

  rndold = getround;
  if rndold
    setround(0)
  end

  if x.complex
    y = ( exp(1i*x) - exp(-1i*x) ) / (2*1i);  
    if rndold
      setround(rndold)
    end
    return
  end

  y = x;

  % transform x.inf and x.sup mod pi/2
  [ xinfinf , xinfsup , Sinf ] = modpi2(x.inf(:));
  [ xsupinf , xsupsup , Ssup ] = modpi2(x.sup(:));

  [ yinf , ysup ] = sin_(x.inf(:),xinfinf,xinfsup,Sinf,  ...
    x.sup(:),xsupinf,xsupsup,Ssup );
  index = ~isfinite(x.inf) | ~isfinite(x.sup);
  if any(index(:))
    yinf(index) = -1;
    ysup(index) = 1;
  end

  yinf = max(yinf,-1);
  ysup = min(ysup,1);

  y.inf = reshape(yinf,size(x.inf));
  y.sup = reshape(ysup,size(x.inf));

  index = isnan(x.inf);
  if any(index(:))
    y.inf(index) = NaN;
    y.sup(index) = NaN;
  end
  
  setround(rndold)
