function y = cot(x)
%COT          Implements  cot(x)  for intervals
%
%   y = cot(x)
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
% modified 12/04/05     S.M. Rump  extreme values for approximate part
% modified 09/06/07     S.M. Rump  approximate std fcts removed
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 10/20/08     S.M. Rump  check for zero omitted
% modified 10/18/08     S.M. Rump  StdFctsException ignore/NaN
% modified 08/26/12     S.M. Rump  global variables removed
% modified 10/13/12     S.M. Rump  INTLAB_INTVAL_STDFCTS
% modified 04/04/14     S.M. Rump  result NaN if (k+0.5)*pi in X
% modified 04/04/14     S.M. Rump  diameter near pi
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/15/14     S.M. Rump  code optimization
% modified 07/21/15     S.M. Rump  old RealStdFctsExcptnIgnore/Occurred deleted
%                                    new design hidden from user
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST

  rndold = getround;
  if rndold
    setround(0)
  end

  if x.complex
    if issparse(x.mid)
      x.mid = full(x.mid);
      x.rad = full(x.rad);
    end
    y = cos(x)./sin(x);
    if rndold
      setround(rndold)
    end
    return
  end

  INTLAB_STDFCTS_PI = INTLAB_CONST.STDFCTS_PI;
  if issparse(x.inf)
    x.inf = full(x.inf);
    x.sup = full(x.sup);
  end

  y = x;

  % transform x.inf and x.sup mod pi/2
  [ xinfinf , xinfsup , Sinf ] = modpi2(x.inf);
  [ xsupinf , xsupsup , Ssup ] = modpi2(x.sup);

  % indices with result +/- inf
  setround(1)
  delta = x.sup-x.inf;
  Tinf = Sinf + 2;
  Tinf(Tinf>7) = Tinf(Tinf>7) - 8;
  Tsup = Ssup + 2;
  Tsup(Tsup>7) = Tsup(Tsup>7) - 8;
  indexinf = ( delta >= INTLAB_STDFCTS_PI.PISUP ) | ...
    ( floor(Tinf/4) ~= floor(Tsup/4) ) | ...
    ( ( x.inf<=0 ) & ( x.sup>=0 ) );
  Sinf(Sinf>3) = Sinf(Sinf>3) - 4;
  Ssup(Ssup>3) = Ssup(Ssup>3) - 4;

  % transformation of input arguments by modpi2:
  %   [ xinf,xsup,s ] = modpi2(y)  ==>  0 <= s <= 7, 0 <= x <= pi/4 and
  %   x = -pi/2 + y + s*pi/4 + 2k*pi        for s even
  %   x =       - y + (s-1)*pi/4 + 2k*pi    for s odd

  y.inf(:) = NaN;
  y.sup(:) = NaN;

  % treat non-infinity intervals
  Sinf(indexinf) = -1;
  Ssup(indexinf) = -1;

  % save warning status
  wng = warning;
  warning off

  % treat infimum
  index = ( Ssup==0 );
  if any(index(:))
    y.inf(index) = - tan_pos(xsupsup(index),1);
  end
  index = ( Ssup==1 );
  if any(index(:))
    y.inf(index) = 1 ./ ( - tan_pos(xsupinf(index),-1) );
  end
  index = ( Ssup==2 );
  if any(index(:))
    res = tan_pos(xsupsup(index),1);
    setround(-1)
    y.inf(index) = 1 ./ res;
  end
  index = ( Ssup==3 );
  if any(index(:))
    y.inf(index) = tan_pos(xsupinf(index),-1);
  end

  % treat supremum
  index = ( Sinf==0 );
  if any(index(:))
    y.sup(index) = - tan_pos(xinfinf(index),-1);
  end
  index = ( Sinf==1 );
  if any(index(:))
    y.sup(index) = 1 ./ ( - tan_pos(xinfsup(index),1) );
  end
  index = ( Sinf==2 );
  if any(index(:))
    res = tan_pos(xinfinf(index),-1);
    setround(1)
    y.sup(index) = 1 ./ res;
  end
  index = ( Sinf==3 );
  if any(index(:))
    y.sup(index) = tan_pos(xinfsup(index),1);
  end

  % restore warning status
  warning(wng);
  setround(0)                       % set rounding to nearest

  INTLAB_STDFCTS_EXCPTN = INTLAB_CONST.STDFCTS_EXCPTN;
  if INTLAB_CONST.RealStdFctsExcptnIgnore % ignore input out of range (ignore-mode)
    if any(indexinf(:))             % exceptional arguments to NaN
      INTLAB_CONST.RealStdFctsExcptnOccurred = 1;
      y.inf(indexinf) = -inf;
      y.sup(indexinf) = inf;
    end
    index = ( x.inf==0 ) & ( x.sup==0 );
    if any(index(:))                % completely exceptional arguments to NaN
      y.inf(index) = NaN;
      y.sup(index) = NaN;
    end
  elseif INTLAB_STDFCTS_EXCPTN==2   % any input out of range to NaN (NaN-mode)
    index = ( x.inf<=0 ) & ( 0<=x.sup );
    if any(index(:))                % exceptional arguments to NaN
      y.inf(index) = NaN;
      y.sup(index) = NaN;
    end
  end
  
  index = isnan(x.inf);
  if any(index(:))
    y.inf(index) = NaN;
    y.sup(index) = NaN;
  end
  setround(rndold)
