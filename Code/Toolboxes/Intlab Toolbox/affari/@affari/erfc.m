function r = erfc(a,see)
%ERFC         Affine arithmetic elementwise complementary error function  erfc(a)
%
%For scalar affari interval a, 
%
%  y = erfc(a,1)
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
  indexneg = find( a.range.sup<0 );         % completely negative components
  if any(indexneg(:))
    a = setvalueindex(a,indexneg,-1);
    neg = 1;                                % only for show
  else
    neg = 0;
  end
  X = a.range;
  
  r = struct(a);
  rndold = getround;                    % save rounding mode
  
  if INTLAB_CONST.AFFARI_APPROX         % min-range approximation

    % treat entries x>=0
    indexpos = ( a.range.inf>=0 );
    if all(indexpos(:))
      r = erfcpos(r,0,neg,a,see);
    elseif any(indexpos(:))
      aa.mid = a.mid(indexpos);
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(a.err)
        aa.err = a.err(:,indexpos);
      else
        aa.err = [];
      end
      aa.rnderr = a.rnderr(indexpos);
      aa.range = a.range(indexpos);
      r = erfcpos(r,indexpos,neg,aa,see);
    end
    
    % treat entries 0 in x
    index0 = ( a.range.inf<0 );
    if all(index0(:))
      r = erfc0(r,0,a,see);
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
      r = erfc0(r,index0,aa,see);
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
    fx1 = erfc(intval(x1));
    fx2 = erfc(X2);
    p = ( fx2-fx1 ) ./ ( X2-x1 );           % inclusion of slope
    xi = sqrt( log( -2./( sqrt(intval('pi'))*p ) ));
    narrow = in(0,p(:)) | isnan(p(:)) | isinf(p(:)) | ...
      in(0,xi(:)) | isnan(xi(:)) | isinf(xi(:));
    if any(narrow(:))                        % slope in f'(X)
      p(narrow) = -2 ./ ( sqrt(intval('pi'))*exp(sqr(X(narrow))) );
      xi(narrow) = X(narrow);
      narrow = reshape(narrow,size(x1));
    else
      narrow = 0;
    end
    % X.sup>=0, therefore ~in(-xi,X) implies in(xi,X)
    index1 = emptyintersect(-xi,X);
    index1 = index1 | narrow;
    fxi = erfc(xi);
    if all(index1(:))                       % only xi in X or narrow
      q = 0.5*( fx1+fxi - p.*(x1+xi) );     % inclusion of offset
      delta = mag( 0.5*( fxi - fx1 + p.*(x1-xi) ) );
    else                                    % some -xi in X
      fxis = 2 - fxi;
      index2 = emptyintersect(xi,X);
      if all(index2(:))                     % only -xi in X
        q = 0.5*( fx1+fxis - p.*(x1-xi) );  % inclusion of offset
        delta = mag( 0.5*( fxis - fx1 + p.*(x1+xi) ) );
      else                                  % some -xi and some xi in X
        q = intval(ones(size(x1)));         % init: -xi and xi in X
        delta = mag( fxi - 1 - p.*xi );
        I = ( ~index1 ) & index2 ;          % treat -xi in X
        q(I) = 0.5*( fx1(I)+fxis(I) - p(I).*(x1(I)-xi(I)) );
        delta(I) = mag( 0.5*( fxis(I) - fx1(I) + p(I).*(x1(I)+xi(I)) ) );
        J = index1 & ( ~index2 ) ;          % treat xi in X
        q(J) = 0.5*( fx1(J)+fxi(J) - p(J).*(x1(J)+xi(J)) );   
        delta(J) = mag( 0.5*( fxi(J) - fx1(J) + p(J).*(x1(J)-xi(J)) ) );
      end
    end
    
    if see && ( nume(a.mid)==1 )
      if neg
        showgraph('erfc(x)',p,2-q,delta,-a.range)
      else
        showgraph('erfc(x)',p,q,delta,a.range)
      end
    end

    % affine approximation
    select = 0;                         	% all indices of a and r
    r = rangeapprox(r,a,0,select,p,q,delta); 

  end
    
  % improve range
  setround(1)
  r = intersectNaN( r , erfc(a.range) );
  setround(rndold)
  
  % possibly extra error term for rounding error
  if INTLAB_CONST.AFFARI_ROUNDINGERRORS
    r = rnderrintoerrterm(r);
  end
  
  % take care of negative components
  if any(indexneg(:))  
    rmidindexneg = intval(2) - r.mid(indexneg);
    r.mid(indexneg) = rmidindexneg.mid;
    % rounding upwards
    r.rnderr(indexneg) = r.rnderr(indexneg) + rmidindexneg.rad(:)';
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if nnz(r.err)
      r.err(:,indexneg) = r.err(:,indexneg);
    end
    r.range(indexneg) = 2 - r.range(indexneg);
  end
  setround(rndold)
  
  % retrieve status of interval standard functions
  intvalinit(RealStdFctsExcptn,0);
  
  r = class(r,'affari');
  
end  % function erfc
  
  
function r = erfcpos(r,indexpos,neg,a,see)
% non-negative arguments for min-range approximation
  x1 = a.range.inf;
  X2 = intval(a.range.sup);
  fx1 = erfc(intval(x1));
  fx2 = erfc(X2);
  % min-range approximation px+q +/- delta on [x1,x2]
  % p = fs(x2)
  % q = ( f(x1)+f(x2) - p*(x1+x2) ) / 2
  % delta = abs( ( f(x2)-f(x1) - p*(x2-x1) ) / 2 )
  p =  -2 ./ ( sqrt(intval('pi'))*exp(sqr(X2)) ); % inclusion of slope
  q = 0.5*( fx1 + fx2 - p.*(x1+X2) );        % inclusion of offset
  delta = 0.5*mag( fx2 - fx1 - p.*(X2-x1) ); % upper bound of error
  
  if see && ( numel(a.mid)==1 )
    if neg
      showgraph('erfc(x)',p,2-q,delta,-a.range)
    else
      showgraph('erfc(x)',p,q,delta,a.range)
    end
  end
  
  % affine approximation
  if isequal(indexpos,0)
    select = 0;                                % all indices
  else
    select = 1;                                % all indices of a, r(index)
  end
  r = rangeapprox(r,a,indexpos,select,p,q,delta);
  
end  % function erfcpos
    

function r = erfc0(r,index0,a,see)
% arguments enclosing zero for min-range approximation
  % treat all components, take care of zero components later
  global INTLAB_CONST
  X = a.range;
  fX = erfc(X);
  % min-range approximation px+q +/- delta on [x1,x2]
  % p = 0
  % q = mid(f(X))
  % delta = rad(f(X))
  C = -infsup( INTLAB_CONST.STDFCTS_PI.REC2SQRT_PIINF , INTLAB_CONST.STDFCTS_PI.REC2SQRT_PIINF );
  if X.sup>-X.inf
    p = C*exp(-sqr(intval(X.sup)));
  else
    p = C*exp(-sqr(intval(X.inf)));
  end
  fXinf = intval(fX.inf);
  Xsup = intval(X.sup);
  q = 0.5*( ( fXinf+fX.sup ) - p.*( X.inf+Xsup ) );    % inclusion of offset
  delta = mag( 0.5*( ( fX.sup-fXinf ) - p.*( X.inf-Xsup ) ) );  % upper bound of error
  
  if see && ( numel(a.mid)==1 )
    showgraph('erfc(x)',p,q,delta,a.range)
  end
  
  % affine approximation
  if isequal(index0,0)
    select = 0;                             % all indices
  else
    select = 1;                             % all indices of a, r(index)
  end
  r = rangeapprox(r,a,index0,select,p,q,delta);   % range p*x+q +/- delta
  
end  % function erfc0
