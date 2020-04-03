function r = acoth(a,see)
%ACOTH        Affine arithmetic elementwise inverse hyperbolic cotangent  acoth(a)
%
%For scalar affari interval a, 
%
%  y = acoth(a,1)
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
  indexneg = find( a.range.sup<=-1 );       % components completely <=-1
  if any(indexneg(:))
    a = setvalueindex(a,indexneg,-1);
    neg = 1;                                % only for show
  else
    neg = 0;
  end
  X = a.range;

  % identify components out of range
  indexnan = ( a.range.inf<1 ) | isnan(a.mid);

  r = struct(a);
  rndold = getround;                        % save rounding mode
  
  % treat all components, take care of zero components later
  x1 = X.inf;
  X2 = intval(X.sup);
  fx1 = acoth(intval(x1));
  fx2 = acoth(X2);
  if INTLAB_CONST.AFFARI_APPROX
    % min-range approximation px+q +/- delta on [x1,x2]
    % p = f'(x2)
    % q = ( f(x1)+f(x2) - p*(x1+x2) ) / 2
    % delta = abs( ( f(x2)-f(x1) - p*(x2-x1) ) / 2 )
    p = intersect( 1./(1-sqr(X2)) , infsup(-inf,0) ); % inclusion of slope
    q = 0.5*( fx1+fx2 - p.*(x1+X2) );            % inclusion of offset
    delta = mag( 0.5*( fx2-fx1 - p.*(X2-x1) ) ); % upper bound of error
  else
    % Chebyshev approximation px+q +/- delta on [x1,x2]
    % p = ( f(x2)-f(x1) ) / ( x2-x1 )
    % xi s.t. f'(xi) = p
    % delta = ( f(xi) - f(x1) - p*(xi-x1) ) / 2
    % q = f(x1) - p*x1 + delta
    p = ( fx2-fx1 ) ./ ( X2-x1 );           % inclusion of slope
    xi = sqrt(intersect( 1 - 1./p , infsup(1,inf) ));
    narrow = in(0,p(:)) | isnan(p(:)) | isinf(p(:)) | ...
      in(0,xi(:)) | isnan(xi(:)) | isinf(xi(:));
    if any(narrow(:))                       % slope in f'(X)
      p(narrow) = intersect( 1./(1 - sqr(X(narrow))) , infsup(-inf,0) );
      xi(narrow) = X(narrow);
    end
    delta = 0.5*( acoth(xi) - fx1 - p.*(xi-x1) );
    q = fx1 - p.*x1 + delta;                 % inclusion of offset
    delta = mag( delta );                   % upper bound of error
  end

  if see && ( numel(a.mid)==1 )
    if neg
      showgraph('acoth(x)',p,-q,delta,-a.range)
    else
      showgraph('acoth(x)',p,q,delta,a.range)
    end
  end
  
  % affine approximation
  select = 0;                               % all indices
  r = rangeapprox(r,a,0,select,p,q,delta); 
    
  % improve range
  setround(1)
  r = intersectNaN( r , acoth(a.range) );
  setround(rndold)
  
  % possibly extra error term for rounding error
  if INTLAB_CONST.AFFARI_ROUNDINGERRORS
    r = rnderrintoerrterm(r);
  end
  
  % take care of negative components
  if any(indexneg(:))   
    r = setvalueindex(r,indexneg,-1);
  end
  
  % take care of nan components
  if any(indexnan(:))   
    r = setvalueindex(r,indexnan,NaN);
  end
  
  % retrieve status of interval standard functions
  intvalinit(RealStdFctsExcptn,0);
  
  r = class(r,'affari');
