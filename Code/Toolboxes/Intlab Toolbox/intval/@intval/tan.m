function y = tan(x)
%TAN          Implements  tan(x)  for intervals
%
%   y = tan(x)
%
%interval standard function implementation
%

% written  12/30/98     S.M. Rump
% modified 09/13/99     S.M. Rump  complex allowed, sparse input, NaN input,
%                                  major revision, improved accuracy
% modified 09/02/00     S.M. Rump  rounding unchanged after use
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    accelaration for sparse input
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/20/05     S.M. Rump  faster check for rounding to nearest
% modified 12/04/05     S.M. Rump  extreme values for approximate part
% modified 09/06/07     S.M. Rump  approximate std fcts removed
% modified 08/26/12     S.M. Rump  global variables removed
% modified 10/13/12     S.M. Rump  INTLAB_INTVAL_STDFCTS
% modified 04/04/14     S.M. Rump  result NaN if k*pi in X
% modified 04/04/14     S.M. Rump  interval diameter pi
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 07/21/15     S.M. Rump  old RealStdFctsExcptnIgnore/Occurred deleted
%                                    new design hidden from user
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST

  if issparse(x)
    [ix,jx,sx] = find(x);
    [m,n] = size(x);
    y = sparse(ix,jx,tan(full(sx)),m,n);
    return
  end

  rndold = getround;
  if rndold
    setround(0)
  end

  if x.complex
    y = sin(x)./cos(x);  
    setround(rndold)
    return
  end

  INTLAB_STDFCTS_PI = INTLAB_CONST.STDFCTS_PI;

  y = x;

  % transform x.inf and x.sup mod pi/2
  [ xinfinf , xinfsup , Sinf ] = modpi2(x.inf);
  [ xsupinf , xsupsup , Ssup ] = modpi2(x.sup);

  % indices with result NaN
  setround(1)
  delta = x.sup-x.inf;
  indexinf = ( delta >= INTLAB_STDFCTS_PI.PISUP ) | ...
    ( floor(Sinf/4) ~= floor(Ssup/4) );
  Sinf(Sinf>3) = Sinf(Sinf>3) - 4;
  Ssup(Ssup>3) = Ssup(Ssup>3) - 4;

  % transformation of input arguments by modpi2:
  %   [ xinf,xsup,s ] = modpi2(y)  ==>  0 <= s <= 7, 0 <= x <= pi/4 and
  %   x = -pi/2 + y + s*pi/4 + 2k*pi        for s even
  %   x =       - y + (s-1)*pi/4 + 2k*pi    for s odd

  if INTLAB_CONST.RealStdFctsExcptnIgnore
    y.inf(:) = -inf;
    y.sup(:) = inf;
  else
    y.inf(:) = NaN;
    y.sup(:) = NaN;
  end
  
  % treat non-infinity intervals
  Sinf(indexinf) = -1;
  Ssup(indexinf) = -1;

  % save warning status
  wng = warning;
  warning off

  % treat infimum
  index = ( Sinf==0 );
  if any(index(:))
    y.inf(index) = 1 ./ ( - tan_pos(xinfinf(index),-1) );
  end
  index = ( Sinf==1 );
  if any(index(:))
    y.inf(index) = - tan_pos(xinfsup(index),1);
  end
  index = ( Sinf==2 );
  if any(index(:))
    y.inf(index) = tan_pos(xinfinf(index),-1);
  end
  index = ( Sinf==3 );
  if any(index(:))
    res = tan_pos(xinfsup(index),1);
    setround(-1)
    y.inf(index) = 1 ./ res;
  end

  % treat supremum
  index = ( Ssup==0 );
  if any(index(:))
    y.sup(index) = 1 ./ ( - tan_pos(xsupsup(index),1) );
  end
  index = ( Ssup==1 );
  if any(index(:))
    y.sup(index) = - tan_pos(xsupinf(index),-1);
  end
  index = ( Ssup==2 );
  if any(index(:))
    y.sup(index) = tan_pos(xsupsup(index),1);
  end
  index = ( Ssup==3 );
  if any(index(:))
    res = tan_pos(xsupinf(index),-1);
    setround(1)
    y.sup(index) = 1 ./ res;
  end

  % restore warning status
  warning(wng);

  index = isnan(x.inf);
  if any(index(:))
    y.inf(index) = NaN;
    y.sup(index) = NaN;
  end

  setround(rndold)
  