function r = sqrt(a,see)
%SQRT         Affine arithmetic elementwise square root  sqrt(a)
%
%For scalar affari interval a, 
%
%  y = sqrt(a,1)
%
%plots the function together with its affine approximation.
%

% written  04/04/14     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/17/14     S.M. Rump  code optimization
% modified 05/21/14     S.M. Rump  All zero sparse: 1-by-1
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
  indexneg = find( X.inf<0 );
  
  r = struct(a);
  rndold = getround;                        % save rounding mode
  
  % treat all components, take care of zero components later
  x1 = X.inf;
  x2 = X.sup;
  if INTLAB_CONST.AFFARI_APPROX
    % min-range approximation px+q +/- delta on [x1,x2]
    % p = f'(x2)
    % q = ( f(x1)+f(x2) - p*(x1+x2) ) / 2
    % delta = abs( ( f(x2)-f(x1) - p*(x2-x1) ) / 2 )
    sx1 = sqrt(intval(x1));
    sx2 = sqrt(intval(x2));
    p = 0.5 ./ sx2 ;                        % inclusion of slope
    q = 0.5*sx1 - 0.25*(x1./sx2) + 0.25*sx2;  % inclusion of offset
    delta = mag( 0.25*(sx1-sx2).^2./sx2 );  % upper bound of error
  else
    % Chebyshev approximation px+q +/- delta on [x1,x2]
    % p = ( f(x2)-f(x1) ) / ( x2-x1 )
    % xi s.t. f'(xi) = p
    % delta = ( f(xi) - f(x1) - p*(xi-x1) ) / 2
    % q = f(x1) - p*x1 + delta
    sx1 = sqrt(intval(x1));
    sx2 = sqrt(intval(x2));
    N = sx1 + sx2;
    p = 1./N;                               % inclusion of slope
    q = 0.125*N + 0.5*p.*sx1.*sx2;          % inclusion of offset
    delta = mag( 0.125*(sx2-sx1).^2 ./ N ); % upper bound of error
    index = in(0,N);
    if any(index(:))                        % only for X=0, then p=q=delta=0
      p(index) = 0;
      q(index) = 0;
      delta(index) = 0;
    end
  end
  
  % affine approximation
  select = 0;                               % all indices
  r = rangeapprox(r,a,0,select,p,q,delta); 
    
  fX = sqrt(X);
  index = ( isnan(q) | isnan(delta) ) & ( ~isnan(fX) );
  if any(index(:))
    r.mid(index) = mid(fX(index));
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if nnz(r.err)
      r.err(:,index) = 0;
      if ~any(r.err(:))
        r.err = [];
      end    
    end
    r.rnderr(index) = rad(fX(index));
    r.range(index) = fX(index);
  end

  if see && ( numel(a.mid)==1 )
    showgraph('sqrt(x)',p,q,delta,a.range)
  end
  
  % improve range
  setround(1)
  r = intersectNaN( r , fX );
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
