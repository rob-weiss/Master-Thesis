function y = psi(x,index)
%PSI          Implements  psi(x)  for real intervals (digamma function)
%
%   y = psi(x)
%
%interval standard function implementation
%

%Extra index for psi1 and psi2 function [careful, arguments permuted]
%

% written  10/11/15     S.M. Rump
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  if nargin==2
    if x==1
      y = psi1(index);
    else
      y = psi2(index);
    end
    return
  end

  global INTLAB_CONST

  if x.complex
    error('Digamma function only for real arguments')
  end
  
  wng = warning;
  warning off
  
  if issparse(x.inf)
    x.inf = full(x.inf);
    x.sup = full(x.sup);
  end
  
  y = x;
  if INTLAB_CONST.RealStdFctsExcptnIgnore
    index = ( x.sup<=0 );
    if any(index(:))
      INTLAB_CONST.RealStdFctsExcptnOccurred = 1;
      y.inf(index) = NaN;
      y.sup(index) = NaN;
      index = ~index;
      yy = psi(intval(x.inf(index),x.sup(index),'infsup'));
      y.inf(index) = yy.inf;
      y.sup(index) = yy.sup;
      warning(wng);
      return
    end
    index = ( x.inf<0 );
    if any(index(:))
      INTLAB_CONST.RealStdFctsExcptnOccurred = 1;
      x.inf(index) = 0;
      yy = psi(intval(x.inf(index),x.sup(index),'infsup'));
      y.inf(index) = yy.inf;
      y.sup(index) = yy.sup;
      warning(wng);
      return
    end
  else
    index = ( x.inf<0 );
    if any(index(:))                          % negative entries
      y = x;
      y.inf(index) = NaN;
      y.sup(index) = NaN;
      index = ~index;                         % x non-negative
      yy = psi(intval(x.inf(index),x.sup(index),'infsup'));
      y.inf(index) = yy.inf;
      y.sup(index) = yy.sup;
      warning(wng);
      return
    end
  end

  rndold = getround;
  if rndold
    setround(0)
  end
  
  psidata = INTLAB_CONST.PSIDATA;
  
  for rnd=[-1 1]
    
    if rnd==-1
      xx = x.inf(:);
    else
      xx = x.sup(:);
    end
    yy = xx;
    
    index = ( ( 0 <= xx ) & ( xx <= 1 ) ) | ( ( 2 <= xx ) & ( xx < 7 ) );
    if any(index)
      xxx = xx(index);
      yy(index) = psi_rnd(xxx,1,rnd);
    end
    
    index = ( 1 < xx ) & ( xx <= psidata.x1 );
    if any(index)
      xxx = xx(index);
      yy(index) = psi_rnd(xxx,2,rnd);
    end
    
    index = ( psidata.x2 <= xx ) & ( xx < 2 );
    if any(index)
      xxx = xx(index);
      yy(index) = psi_rnd(xxx,3,rnd);
    end
    
    index = ( 7 <= xx ) & ( xx < 30 );
    if any(index)
      xxx = xx(index);
      yy(index) = psi_rnd(xxx,4,rnd);
    end
    
    index = ( 30 <= xx );
    if any(index)
      xxx = xx(index);
      yy(index) = psi_rnd(xxx,5,rnd);
    end
    
    if rnd==-1
      y.inf = yy;
    else
      y.sup = yy;
    end
    
  end

  y.inf = reshape(y.inf,size(x.inf));
  y.sup = reshape(y.sup,size(x.sup));
  
  warning(wng);
  setround(rndold)  
