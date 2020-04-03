function r = cot(a,see)
%COT          Affine arithmetic elementwise cotangent  cot(a)
%
%For scalar affari interval a, 
%
%  y = cot(a,1)
%
%plots the function together with its affine approximation.
%

% written  04/04/14     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/17/14     S.M. Rump  code optimization
% modified 05/18/14     S.M. Rump  range improvement
% modified 05/21/14     S.M. Rump  All zero sparse: 1-by-1
% modified 05/22/14     S.M. Rump  small rad(X)
% modified 12/09/15     S.M. Rump  prod(size) to numel
%

  global INTLAB_CONST
  
  if nargin==1
    see = 0;
  end
  
  rndold = getround;                        % save rounding mode

  % status of interval standard functions
  RealStdFctsExcptn = intvalinit('RealStdFctsExcptn');
  intvalinit('RealStdFctsExcptnNaN',0);
  
  % transform into [0,pi]
  if see
    INTLAB_CONST.ORIGINAL_RANGE = a.range;
  end
  fX = cot(a.range);                % before range reduction
  a = rangereduction(a,2);
  X = a.range;

  % PI.PI2INF <= pi/2 <= PI.PI2SUP
  Pi = intval('pi');
  PI = INTLAB_CONST.STDFCTS_PI;
  
  % identify components out of range
  indexnan = isinf(fX) | isnan(fX) | isnan(a.mid);
  notindexnan = ~indexnan;
  
  r = struct(a);
  
  if INTLAB_CONST.AFFARI_APPROX     % min-range approximation

    % treat entries x<pi/2
    index = ( a.range.sup<=PI.PI2INF ) & notindexnan;
    if all(index(:))
      r = cotleft(r,0,a,see);
    elseif any(index(:))
      aa.mid = a.mid(index);
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(a.err)
        aa.err = a.err(:,index);
      else
        aa.err = [];
      end
      aa.rnderr = a.rnderr(index);
      aa.range = a.range(index);
      r = cotleft(r,index,aa,see);
    end
    
    % treat entries x>pi/2
    index = ( a.range.inf>=PI.PI2SUP ) & notindexnan;
    if all(index(:))
      r = cotright(r,0,a,see);
    elseif any(index(:))
      aa.mid = a.mid(index);
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(a.err)
        aa.err = a.err(:,index);
      else
        aa.err = [];
      end
      aa.rnderr = a.rnderr(index);
      aa.range = a.range(index);
      r = cotright(r,index,aa,see);
    end
    
    % treat entries pi/2 in x
    index0 = ( ~emptyintersect( a.range , intval('pi')/2 ) ) & notindexnan;
    if all(index0(:))
      r = cot0(r,0,a,see);
    elseif any(index0(:))
      aa.mid = a.mid(index0);
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(a.err)
        aa.err = a.err(:,index0);
      else
        aa.err = [];
      end
      aa.rnderr = a.rnderr(index0);
      aa.range = a.range(index0);
      r = cot0(r,index0,aa,see);
    end
    
  else                                      % Chebyshev approximation
    
    % Chebyshev approximation px+q +/- delta on [x1,x2]
    %  b) f with at most one zero of f" in X
    %       p = ( f(x2)-f(x1) ) / ( x2-x1 )
    %       i)  exactly one xi in X with f'(xi) = p: as in IIa)
    %           q = ( f(x1)+f(xi) - p*(x1+xi) ) / 2
    %           delta = abs( f(xi) - f(x1) - p*(xi-x1) ) / 2
    %       ii) xi1, xi2 in X with f'(xi1) = f'(xi2) = p
    %           1) f general
    %              q = ( f(xi1)+f(xi2) - p*(xi1+xi2) ) / 2
    %              delta = abs( f(xi1) - f(xi2) + p*(xi2-xi1) ) / 2

    x1 = X.inf;
    X2 = intval(X.sup);
    fx1 = cot(intval(x1));
    fx2 = cot(X2);
    p = ( fx2-fx1 ) ./ ( X2-x1 );           % inclusion of slope
    p = intersect(p,-1-sqr(fX));            % small rad(X)
    xi = acot(sqrt( intersect( -1-p , infsup(0,inf) ) ));
    narrow = in(0,p(:)) | isnan(p(:)) | isinf(p(:)) | ...
      in(0,xi(:)) | isnan(xi(:)) | isinf(xi(:));
    if any(narrow(:))                        % slope in f'(X)
      p(narrow) = -1 - sqr(fX(narrow));
      xi(narrow) = X(narrow);
      narrow = reshape(narrow,size(x1));
    else
      narrow = 0;
    end
    % ~in(pi-xi,X) implies in(xi,X)
    index1 = emptyintersect(Pi-xi,X);
    index1 = index1 | narrow;
    fxi = cot(xi);
    if all(index1(:))                       % only xi in X or narrow
      q = 0.5*( fx1+fxi - p.*(x1+xi) );     % inclusion of offset
      delta = mag( 0.5*( fxi - fx1 + p.*(x1-xi) ) );
    else                                    % some -xi in X
      xis = intval('pi') - xi;              % f(xis) = -f(xi)
      index2 = emptyintersect(xi,X);
      if all(index2(:))                     % only -xi in X
        q = 0.5*( fx1-fxi - p.*(x1+xis) );  % inclusion of offset
        delta = mag( 0.5*( fxi + fx1 - p.*(x1-xis) ) );
      else                                  % some -xi and some xi in X
        q = -p.*(0.5*intval('pi'));         % init: -xi and xi in X
        delta = mag( fxi + p.*(0.5*intval('pi')-xi) );
        I = ( ~index1 ) & index2 ;          % treat -xi in X
        q(I) = 0.5*( fx1(I)-fxi(I) - p(I).*(x1(I)+xis(I)) );
        delta(I) = mag( 0.5*( fxi(I) + fx1(I) + p(I).*(x1(I)-xis(I)) ) );
        J = index1 & ( ~index2 ) ;          % treat xi in X
        q(J) = 0.5*( fx1(J)+fxi(J) - p(J).*(x1(J)+xi(J)) );   
        delta(J) = mag( 0.5*( fxi(J) - fx1(J) + p(J).*(x1(J)-xi(J)) ) );
      end
    end
    
    if see && ( numel(a.mid)==1 )
      showgraph('cot(x)',p,q,delta,a.range)
    end

    % affine approximation
    select = 0;                         	% all indices of a and r
    r = rangeapprox(r,a,0,select,p,q,delta); 

  end
  
  % improve range
  setround(1)
  r = intersectNaN( r , fX );
  setround(rndold)
  
  % possibly extra error term for rounding error
  if INTLAB_CONST.AFFARI_ROUNDINGERRORS
    r = rnderrintoerrterm(r,notindexnan);
  end
  
  % take care of nan components
  if any(indexnan(:))   
    r = setvalueindex(r,indexnan,NaN);
  end
  
  % retrieve status of interval standard functions
  intvalinit(RealStdFctsExcptn,0);
  
  r = class(r,'affari');
  
end  % function cot
  
  
function r = cotleft(r,index,a,see)
% non-negative arguments for min-range approximation
  x1 = a.range.inf;
  X2 = intval(a.range.sup);
  fx1 = cot(intval(x1));
  fx2 = cot(X2);
  % min-range approximation px+q +/- delta on [x1,x2]
  % p = f'(x2)
  % q = ( f(x1)+f(x2) - p*(x1+x2) ) / 2
  % delta = abs( ( f(x2)-f(x1) - p*(x2-x1) ) / 2 )
  p = 1 + sqr(cot(X2));                       % inclusion of slope
  q = 0.5*( fx1 + fx2 - p.*(x1+X2) );         % inclusion of offset
  delta = 0.5*mag( fx2 - fx1 - p.*(X2-x1) );  % upper bound of error
  
  if see && ( numel(a.mid)==1 )
    showgraph('cot(x)',p,q,delta,a.range)
  end
  
  % affine approximation
  if isequal(index,0)
    select = 0;                                % all indices
  else
    select = 1;                                % all indices of a, r(index)
  end
  r = rangeapprox(r,a,index,select,p,q,delta);
  
end  % function cotleft
    

function r = cotright(r,index,a,see)
% non-negative arguments for min-range approximation
  X1 = intval(a.range.inf);
  x2 = a.range.sup;
  fx1 = cot(X1);
  fx2 = cot(intval(x2));
  % min-range approximation px+q +/- delta on [x1,x2]
  % p = f'(x1)
  % q = ( f(x1)+f(x2) - p*(x1+x2) ) / 2
  % delta = abs( ( f(x2)-f(x1) - p*(x2-x1) ) / 2 )
  p = 1 + sqr(cot(X1));                       % inclusion of slope
  q = 0.5*( fx1 + fx2 - p.*(X1+x2) );         % inclusion of offset
  delta = 0.5*mag( fx2 - fx1 - p.*(x2-X1) );  % upper bound of error
  
  if see && ( numel(a.mid)==1 )
    showgraph('cot(x)',p,q,delta,a.range)
  end
  
  % affine approximation
  if isequal(index,0)
    select = 0;                                % all indices
  else
    select = 1;                                % all indices of a, r(index)
  end
  r = rangeapprox(r,a,index,select,p,q,delta);
  
end  % function cotright
    

function r = cot0(r,index0,a,see)
% arguments enclosing zero for min-range approximation
  % treat all components, take care of zero components later
  X = a.range;
  fX = cot(X);
  % min-range approximation px+q +/- delta on [x1,x2]
  % p = -1
  % q = 0.5*(f(x1)+f(x2)+x1+x2))
  % delta = 0.5*(f(x2)-f(x1)-(x2-x1))
  p = repmat(intval(-1),size(X.inf));
  fXinf = intval(fX.inf);
  Xsup = intval(X.sup);
  q = 0.5*( ( fXinf+fX.sup ) + ( X.inf+Xsup ) );    % inclusion of offset
  delta = mag( 0.5*( ( fX.sup-fXinf ) + ( X.inf-Xsup ) ) );  % upper bound of error
  
  if see && ( numel(a.mid)==1 )
    showgraph('cot(x)',p,q,delta,a.range)
  end
  
  % affine approximation
  if isequal(index0,0)
    select = 0;                             % all indices
  else
    select = 1;                             % all indices of a, r(index)
  end
  r = rangeapprox(r,a,index0,select,p,q,delta);   % range p*x+q +/- delta
  
end  % function cot0
