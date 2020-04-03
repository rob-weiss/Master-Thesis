function r = log10(a,see)
%LOG10        Affine arithmetic elementwise decimal logarithm  log10(a)
%
%For scalar affari interval a, 
%
%  y = log10(a,1)
%
%plots the function together with its affine approximation.
%

% written  04/04/14     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/17/14     S.M. Rump  code optimization
% modified 12/09/15     S.M. Rump  prod(size) to numel
%

  global INTLAB_CONST

  if nargin==1
    see = 0;
  end
  
  % status of interval standard functions
  RealStdFctsExcptn = intvalinit('RealStdFctsExcptn');
  intvalinit('RealStdFctsExcptnNaN',0);
  
  % identify negative components
  X = a.range;
  indexneg = find( X.inf<=0 );
  
  r = struct(a);
  rndold = getround;                        % save rounding mode
  
  % treat all components, take care of zero components later
  x1 = X.inf;
  X2 = intval(X.sup);
  fx1 = log10(intval(x1));
  fx2 = log10(X2);
  if INTLAB_CONST.AFFARI_APPROX
    % min-range approximation px+q +/- delta on [x1,x2]
    % p = f'(x2)
    % q = ( f(x1)+f(x2) - p*(x2-x1) ) / 2
    % delta = ( f(x2)-f(x1) - p*(x2-x1) ) / 2
    p = 1./(intval('log10')*X2);             % inclusion of slope
    q = 0.5*( fx1 + fx2 - p.*(x1+X2) );     % inclusion of offset
    delta = 0.5*mag( fx2 - fx1 - p.*(X2-x1) );   % upper bound of error
  else
    % Chebyshev approximation px+q +/- delta on [x1,x2]
    % p = ( f(x2)-f(x1) ) / ( x2-x1 )
    % xi s.t. f'(xi) = p
    % delta = ( f(xi) - f(x1) - p*(xi-x1) ) / 2
    % q = f(x1) - p*x1 - delta
    p = (fx2-fx1)./(X2-x1);                 % inclusion of slope
    xi = 1./(intval('log10')*p);
    index = in(0,p(:)) | isnan(p(:)) | isinf(p(:));
    if any(index(:))                        % slope in f'(X)
      p(index) = 1./(intval('log10')*X(index));
      xi(index) = X(index);
    end
    delta = 0.5*( log10(xi) - fx1 - p.*(xi-x1) );
    q = fx1 - p.*x1 + delta;                % inclusion of offset
    delta = mag(delta);                     % upper bound of error
  end
  
  if see && ( numel(a.mid)==1 )
    showgraph('log10(x)',p,q,delta,X)
  end
  
  % affine approximation
  select = 0;                               % all indices
  r = rangeapprox(r,a,0,select,p,q,delta);
    
  % improve range
  setround(1)
  r = intersectNaN( r , log10(X) );
  setround(rndold)
  
  % possibly extra error term for rounding error
  if INTLAB_CONST.AFFARI_ROUNDINGERRORS
    r = rnderrintoerrterm(r);
  end
  
  % take care of negative components
  if any(indexneg(:))   
    r = setvalueindex(r,indexneg,NaN);
  end
  
  % retrieve status of interval standard functions
  intvalinit(RealStdFctsExcptn,0);
  
  r = class(r,'affari');
