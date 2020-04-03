function [y,ysup] = gamma_rnd(x,rnd)
% input x>=1 real column vector with gamma(xmax) overflow
% rnd  -1  y = lower bound for gamma(x)
%       1  y = upper bound for gamma(x)
%      []  [y,ysup] inclusion of gamma(x)
% rounding may be altered after leaving gamma_rnd
%

% written  06/19/13     S.M. Rump
% modified 08/05/13     S.M. Rump  Highly accurate argument reduction
% modified 01/11/14     S.M. Rump  Integer arguments
% modified 03/06/14     S.M. Rump  overflow range
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 10/11/15     S.M. Rump  global variables
%

  global INTLAB_CONST

  xmax = hex2num('406573fae561f647');       % gamma(x) overflow for x>xmax ~ 171.6
  
  y = x;
  if nargout==2
    ysup = x;
  end
  
  index = ( x>xmax );                       % overflow
  if any(index)
    if isempty(rnd)
      y(index) = realmax;
      ysup(index) = inf;
    else
      if rnd==1
        y(index) = inf;
      else
        y(index) = realmax;
      end
    end
    index = ~index;
    if any(index)
      [y(index),ysup(index)] = gamma_rnd(x(index),rnd);
    end
    return
  end
  
  index = ( x==round(x) ) & ( x<24 );
  if any(index)
    xx = x(index)-1;
    M = max(xx);
    xx = repmat(xx,1,M-1) - repmat(0:(M-2),length(xx),1);
    xx(xx<2) = 1;
    y(index) = prod(xx,2);
    if nargout==2
      ysup(index) = y(index);
    end
    index = ~index;
    if any(index)
      [y(index),ysup(index)] = gamma_rnd(x(index),rnd);
    end
    return
  end
  
  % 1 <= x <= xmax
  len = length(x);                          % number of elements
  col = floor(x) - 1;
  maxcol = max(col);
  factor = repmat(x,1,maxcol) - repmat(1:maxcol,len,1);
  factor(factor<1) = 1;
  indexscale = [];            % possible indices for scaling to avoid overflow by splitting
  if isempty(factor)
    F = 1;
    Fsup = 1;
  else
    % Accurate scaling factors
    [e,f] = Split(factor(:,1));
    Fhi = e;
    Flo = f;
    setround(0)
    for i=2:maxcol
      index = find( x >= i+1 );
      if i==160
        scale = 2^30;
        indexscale = index;
        Fhi(indexscale) = Fhi(indexscale)/scale;
        Flo(indexscale) = Flo(indexscale)/scale;
      end
      eindex_ = e(index)-i+1;
      findex = f(index);
      FhiIndex = Fhi(index);
      p = FhiIndex.*eindex_;
      q = FhiIndex.*findex + Flo(index).*factor(index,i);
      [Fhi(index),s] = Split(p);
      Flo(index) = s + q;
    end
    err = 4.97e-24*col.^2.*abs(Fhi+Flo);    % error by argument reduction
    if isempty(rnd)
      setround(-1)
      F = Fhi + ( Flo - err);
      setround(1)
      Fsup = Fhi + ( Flo + err);
    else
      if rnd==-1
        setround(-1)
        F = Fhi + ( Flo - err);
      else
        setround(1)
        F = Fhi + ( Flo + err);
      end
    end
  end
  
  x = x - col;                              % 1 <= x < 2, no rounding error
  gamma_data = INTLAB_CONST.GAMMADATA;
  AppGammaxs = gamma_data.AppGammaxs;       % approximate values gamma(xs)
  N = gamma_data.Nd(1);                     % number of grid points 1+i*h, h=1/N
  AppPoly = gamma_data.AppPoly;             % Approximating polynomials
  d = gamma_data.Nd(2);                     % degree of polynomials
  minerr = 0.560e-16;       % AppGammaxs-minerr <= gamma(xs) <= AppGammaxs+maxerr
  maxerr = 0.563e-16;
  ii = round(N*(x-1));
  xs = ii/N + 1;
  ii = ii + 1;
  delta = x - xs;
  if isempty(rnd) || ( rnd==-1 )
    setround(-1)
    y = AppPoly(ii,1);
    for k=2:d
      y = y.*delta + AppPoly(ii,k);
    end
    y = ( AppGammaxs(ii) + ( y.*delta - minerr ) ) .* F;
    if ~isempty(indexscale)
      y(indexscale) = y(indexscale)*scale;
    end
  end
  if isempty(rnd) || ( rnd==1 )
    setround(1)
    ysup = AppPoly(ii,1);
    for k=2:d
      ysup = ysup.*delta + AppPoly(ii,k);
    end
    ysup = AppGammaxs(ii) + ( ysup.*delta + maxerr );
    if rnd==1
      ysup = ysup .* F;
    else
      ysup = ysup .* Fsup;
    end
    if ~isempty(indexscale)
      ysup(indexscale) = ysup(indexscale)*scale;
    end
  end
  if rnd==1
    y = ysup;
  end
  