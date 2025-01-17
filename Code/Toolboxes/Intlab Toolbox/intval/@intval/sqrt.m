function y = sqrt(x)
%SQRT         Implements  sqrt(x)  for intervals
%
%   y = sqrt(x)
%
%interval standard function implementation
%

% written  10/16/98     S.M. Rump
% modified 11/30/98     S.M. Rump  improved speed
% modified 06/24/99     S.M. Rump  complex allowed, following N.C. Boersken:
%                                  Komplexe Kreis-Standardfunktionen,
%                                  Freiburger Intervallberichte 78/2,
%                                  sparse input
% modified 12/06/99                branch cut with warning
% modified 09/02/00     S.M. Rump  rounding unchanged after use
% modified 01/20/03     S.M. Rump  sqrt_rnd added because Matlab doesn't use IEEE sqrt (thanks to George Corliss for pointing to this)
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    accelaration for sparse input
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/20/05     S.M. Rump  faster check for rounding to nearest
% modified 12/04/05     S.M. Rump  'realstdfctsexcptnignore' added and
%                                     some improvements
% modified 09/06/07     S.M. Rump  approximate std fcts removed, exceptional arguments
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 10/18/08     S.M. Rump  StdFctsException ignore/NaN
% modified 08/26/12     S.M. Rump  global variables removed
% modified 10/13/12     S.M. Rump  INTLAB_INTVAL_STDFCTS
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/15/14     S.M. Rump  code optimization
% modified 06/25/15     S.M. Rump  sqrtR
% modified 07/21/15     S.M. Rump  old RealStdFctsExcptnIgnore/Occurred deleted
%                                    new design hidden from user
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
% modified 02/22/17     S.M. Rump  x=0 
%

  global INTLAB_CONST

  if issparse(x)
    [ix,jx,sx] = find(x);
    [m,n] = size(x);
    y = sparse(ix,jx,sqrt(full(sx)),m,n);
    return
  end

  rndold = getround;
  if rndold
    setround(0)
  end

  if x.complex

    y = x;                              % input x full

    if ~isequal(size(y.mid),size(y.rad))
      y.rad = x.rad * ones(size(y.mid));
    end

%   y.mid = sqrt(x.mid);
%   y.rad = abs( sqrt(abs(x.mid)-x.rad) - sqrt(abs(x.mid)) );

    INTLAB_STDFCTS_PI = INTLAB_CONST.STDFCTS_PI;

    xmidre = real(x.mid);
    xmidim = imag(x.mid);
    Xmidim = intval(xmidim);
    Phi = atan(Xmidim./xmidre);   % -pi/2 <= Phi <= pi/2

    % special treatment of imaginary axis
    index = ( xmidre==0 );
    if any(index(:))
      Phi.inf(index) = INTLAB_STDFCTS_PI.PI2INF;          % pi/2
      Phi.sup(index) = INTLAB_STDFCTS_PI.PI2SUP;
      indexneg = index & ( xmidim<0 );
      if any(indexneg(:))
        Phi.inf(indexneg) = -INTLAB_STDFCTS_PI.PI2SUP;    % -pi/2
        Phi.sup(indexneg) = -INTLAB_STDFCTS_PI.PI2INF;
      end
    end

    index = ( xmidre==0 ) & ( xmidim==0 );
    if any(index(:))
      Phi.inf(index) = 0;
      Phi.sup(index) = 2*INTLAB_STDFCTS_PI.PISUP;
    end

    index = ( xmidre < 0 );
    if any(index(:))
      Pi = infsup( INTLAB_STDFCTS_PI.PIINF, ...
                   INTLAB_STDFCTS_PI.PISUP );
      signxmidim = sign(xmidim(index));
      corr = Pi.*(signxmidim+(signxmidim==0));
      Phi.inf(index) = Phi.inf(index) + corr.inf;
      Phi.sup(index) = Phi.sup(index) + corr.sup;
    end
    R.complex = 0;
    R.inf = abs(x.mid);
    R.sup = R.inf;
    R.mid = [];
    R.rad = [];
    R = class(R,'intval');          % abs(x.mid) in R,  x in R*exp(i*Phi)
    sqrtR = sqrt(abs(x.mid));       % sqrt(abs(x.mid)) in sqrtR
    Mre = sqrtR .* cos(Phi/2);
    Mim = sqrtR .* sin(Phi/2);      % sqrt(x.mid) in Mre + i*Mim
    setround(1)
    mre = Mre.inf + 0.5*(Mre.sup-Mre.inf);
    mim = Mim.inf + 0.5*(Mim.sup-Mim.inf);
    y.mid = mre + 1i*mim;
    mrad = abs( mre-Mre.inf + 1i*(mim-Mim.inf) );
    C = R - x.rad;
    index = ( C.inf>=0 );           % 0 ~in x
    if any(index(:))
      sqrtC = sqrt_rnd(C.inf(index),-1);
      setround(1)
      y.rad(index) = ( sqrt_rnd(R.sup(index),1) - sqrtC ) + mrad(index);
    end

    index = ~index;
    if any(index(:))
      setround(1)
      y.rad(index) = abs( sqrt_rnd(R.sup(index),1) + 1i*sqrt_rnd(-C.inf(index),1) ) + ...
                     mrad(index);
    end

    index = index | ( ( xmidre<0 ) & ( xmidim>=0 ) & ( x.rad>xmidim ) ) ...
                      | ( ( xmidre<0 ) & ( xmidim<0 ) & ( x.rad>=-xmidim ) ) ;
    if any(index(:))
      warning('Complex Sqrt: Input interval intersects with branch cut')
    end
    
    setround(rndold)
    
    return
  end

  % input x real and full
  % real range of definition:  [0,inf]

  if INTLAB_CONST.RealStdFctsExcptnIgnore
    index = ( x.inf<0 );
    if any(index(:))
      INTLAB_CONST.RealStdFctsExcptnOccurred = 1;
      x.inf(index) = 0;
    end
    index = index & ( x.sup<=0 );   % non-positive interval
    y = x;
    % treat non-exceptional cases
    y.inf = sqrt_rnd(x.inf,-1);
    y.sup = sqrt_rnd(x.sup,1);
    % set non-positive intervals to NaN
    y.inf(index) = NaN;
    y.sup(index) = NaN;
    if rndold
      setround(rndold)
    end
    return    
  end
  
  INTLAB_STDFCTS_EXCPTN = INTLAB_CONST.STDFCTS_EXCPTN;
  index = ( x.inf<0 );                  % (partially) exceptional indices
  if any(index(:))                      % handle input out-of-range
    if INTLAB_STDFCTS_EXCPTN<=1  % out-of-range input handled as complex
      if INTLAB_STDFCTS_EXCPTN==1
        warning('SQRT: Real interval input out of range changed to be complex')
      end
      y = x;
      %VVVV  y(index) = sqrt(cintval(x(index)));
      s.type = '()'; s.subs = {index}; y = subsasgn(y,s,sqrt(cintval(subsref(x,s))));
      %AAAA  Matlab bug fix
      index = ~index;
      if any(index(:))
        %VVVV  y(index) = sqrt(x(index));
        s.type = '()'; s.subs = {index}; y = subsasgn(y,s,sqrt(subsref(x,s)));
        %AAAA  Matlab bug fix
      end
      if rndold
        setround(rndold)
      end
      return
    end
  else
    indexneg = [];                      % make sure indexneg is not undefined
  end

  % input x real and full, exceptions in index
  y = x;  
  wng = warning;
  warning off
  
  % treat non-exceptional indices
  y.inf = sqrt_rnd(x.inf,-1);
  y.sup = sqrt_rnd(x.sup,1);
  
  if any(index(:))                    % exceptional arguments to NaN
    y.inf(index) = NaN;
    y.sup(index) = NaN;
  end
  
  warning(wng)
  setround(rndold)
