function [ X , xs ] = verifynlssderiv(funfcn,xs,kderiv,see,varargin)
%VERIFYNLSSDERIV  Verified solution of f^(k)=0
%
%   [ X , xs ] = verifynlssderiv(f,xs,k,see,P1,P2,...)
%
%For univariate f:R->R, an inclusion of a root of the k-th derivative 
%f^(k)(x) of f is computed based on an approximation xs.
%
% optional input    see     see intermediate results 
%                   P1,...  extra parameters for function evaluation
%                           f(x,P1,P2,...)
%
% optional output   xs      improved approximation (column vector)
%

% written  02/27/17     S.M. Rump
%

  rndold = getround;
  if rndold
    setround(0)
  end
  
  % store warning mode
  wng = warning;
  warning off
  
  % store standard function exception mode
  RealStdFctsExcptnMode = intvalinit('RealStdFctsExcptn',0);
  intvalinit('RealStdFctsExcptnNaN',0);

  xs = xs(:);
  if length(xs)>1
    error('roots of higher derivatives only for univariate functions')
  end
  
  if round(kderiv)~=kderiv
    error('f^(k)(x)=0 is solved but the specified value for k is not integer')
  end
  
  if kderiv<1
    error('f^(k)(x)=0 is solved but k must be positive integer')
  end
  
  if kderiv==1
    warning('f''(x)=0 is solved; you might use verifylocalmin for that allowing multivariate functions')
  end
  
  if ( nargin<4 ) || isempty(see)
    see = 0;
  end
  
  % Convert to inline function as needed
  strfun = fcnchk(funfcn,length(varargin));
  n = length(xs);                   % number of variables
  
  % floating point Newton iteration
  sqrt_n = sqrt(n);
  dxs = zeros(size(xs));
  dxsnew = abs(xs);
  k = 0;
  while ( any(dxsnew<.5*dxs) && ( norm(dxsnew)>=sqrt_n*1e-14*norm(xs) ) && ( k<100 ) ) || ( k<3 )
    k = k+1;                     % at most 100, at least 3 iterations performed
    dxs = dxsnew;
    xsold = xs;
    y = feval(strfun,taylorinit(xs,kderiv+1),varargin{:});
    xs = xs - (kderiv+1)*y{kderiv+1}\y{kderiv};  % solution of f^(kderiv)(x)=0
    if see
      disp(['residual norm(f^(' int2str(kderiv) ')(xs_k)), floating point iteration ' sprintf('%d',k)])
      norm(y{kderiv})
    end
    dxsnew = abs(xs-xsold);
  end
      
  % full interval iteration
  R = 1/((kderiv+1)*y{kderiv+1});
  Y = feval(strfun,taylorinit(intval(xs),kderiv),varargin{:});
  Z = - R * Y{kderiv};
  X = Z;
  ready = 0; k = 0; kmax = 10;
  while ( ~ready ) && ( k<kmax ) && ( ~any(isnan(X)) )
    k = k+1;
    if see
      disp(['interval iteration ' sprintf('%d',k)])
    end
    X = hull( X , 0 );              % epsilon inflation
    Y = X + 0.1*rad(X)*hull(-1,1) + midrad(0,realmin);
    Yold = Y;
    x = taylorinit(xs+Y,kderiv+1);  % f^(kderiv)(x)/k!=0
    y = feval(strfun,x,varargin{:});
    C = 1 - R * ( (kderiv+1)*y{kderiv+1} );   % automatic Taylor expansion
    i = 0;
    while ( ~ready ) && ( i<2 )     % improved interval iteration
      i = i+1;
      X = Z + C * Y;
      if any(isnan(X(:)))
        ready = 0;
        break
      end
      ready = all(all(in0(X,Y)));
      Y = intersect(X,Yold);
    end
  end
  
  X = intval(NaN(n,1));         % intialization
  if ready && isempty(find(isnan(Y) | isinf(Y) ,1))
    X = xs + Y(1:n);            % verified inclusion of stationary point
  end
  
  % restore warning and exception mode
  warning(wng)
  % restore out-of-range exception mode
  intvalinit(RealStdFctsExcptnMode,0);
  
  if rndold
    setround(rndold)
  end
  
end  % verifynlssderiv
