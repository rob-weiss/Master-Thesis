function r = tanh(a,see)
%TANH         Affine arithmetic elementwise hyperbolic tangent  tanh(a)
%
%For scalar affari interval a, 
%
%  y = tanh(a,1)
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
  rndold = getround;                        % save rounding mode
  
  if INTLAB_CONST.AFFARI_APPROX             % min-range approximation

    % treat entries x>=0
    indexpos = ( a.range.inf>=0 );
    if all(indexpos(:))
      r = tanhpos(r,0,neg,a,see);
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
      r = tanhpos(r,indexpos,neg,aa,see);
    end
    
    % treat entries 0 in x
    index0 = ( a.range.inf<0 );
    if all(index0(:))
      r = tanh0(r,0,a,see);
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
      r = tanh0(r,index0,aa,see);
    end

  else                                      % Chebyshev approximation
    
    % Chebyshev approximation px+q +/- delta on [x1,x2]
    %  b) f with at most one zero of f" in X
    %       p = ( f(x2)-f(x1) ) / ( x2-x1 )
    %       i)  exactly one xi in X with f'(xi) = p: as in IIa)
    %           q = ( f(x1)+f(xi) - p*(x1+xi) ) / 2
    %           delta = abs( f(xi) - f(x1) - p*(xi-x1) ) / 2
    %       ii) xi1, xi2 in X with f'(xi1) = f'(xi2) = p
    %           2) f(-x) = -f(x)
    %              q = 0
    %              delta = abs( f(xi1) - p*xi1 )

    x1 = X.inf;
    X2 = intval(X.sup);
    fx1 = tanh(intval(x1));
    fx2 = tanh(X2);
    p = ( fx2-fx1 ) ./ ( X2-x1 );           % inclusion of slope
    xi = atanh(sqrt( intersect( 1-p , infsup(0,1) ) ));
    narrow = in(0,p(:)) | isnan(p(:)) | isinf(p(:)) | ...
      in(0,xi(:)) | isnan(xi(:)) | isinf(xi(:));
    if any(narrow(:))                        % slope in f'(X)
      p(narrow) = intersect( 1-tanh(X(narrow)) , infsup(0,1) );
      xi(narrow) = X(narrow);
      narrow = reshape(narrow,size(x1));
    else
      narrow = 0;
    end
    % X.sup>=0, therefore ~in(-xi,X) implies in(xi,X)
    index1 = emptyintersect(-xi,X);
    index1 = index1 | narrow;
    fxi = tanh(xi);
    if all(index1(:))                       % only xi in X or narrow
      q = 0.5*( fx1+fxi - p.*(x1+xi) );     % inclusion of offset
      delta = mag( 0.5*( fxi - fx1 + p.*(x1-xi) ) );
    else                                    % some -xi in X
      index2 = emptyintersect(xi,X);
      if all(index2(:))                     % only -xi in X
        q = 0.5*( fx1-fxi - p.*(x1-xi) );   % inclusion of offset
        delta = mag( 0.5*( fxi + fx1 - p.*(x1+xi) ) );
      else                                  % some -xi and some xi in X
        delta = mag( fxi - p.*xi );         % init: -xi and xi in X
        q = intval(zeros(size(delta))); 
        I = ( ~index1 ) & index2 ;          % treat -xi in X
        xi(I) = -xi(I);
        IJ = I | ( index1 & ( ~index2 ) );          % treat xi in X
        q(IJ) = 0.5*( fx1(IJ)-fxi(IJ) - p(IJ).*(x1(IJ)-xi(IJ)) );
        delta(IJ) = mag( 0.5*( fxi(IJ) + fx1(IJ) - p(IJ).*(x1(IJ)+xi(IJ)) ) );
      end
    end
    
    if see && ( numel(a.mid)==1 )
      if neg
        showgraph('tanh(x)',p,-q,delta,-a.range)
      else
        showgraph('tanh(x)',p,q,delta,a.range)
      end
    end

    % affine approximation
    select = 0;                         	% all indices of a and r
    r = rangeapprox(r,a,0,select,p,q,delta); 

  end
  
  % improve range
  setround(1)
  r = intersectNaN( r , tanh(a.range) );
  setround(rndold)
  
  % possibly extra error term for rounding error
  if INTLAB_CONST.AFFARI_ROUNDINGERRORS
    r = rnderrintoerrterm(r);
  end
  
  % take care of negative components
  if any(indexneg(:))   
    r = setvalueindex(r,indexneg,-1);
  end

  % retrieve status of interval standard functions
  intvalinit(RealStdFctsExcptn,0);
  
  r = class(r,'affari');
  
end  % function tanh
  
  
function r = tanhpos(r,indexpos,neg,a,see)
% non-negative arguments for min-range approximation
  x1 = a.range.inf;
  X2 = intval(a.range.sup);
  fx1 = tanh(intval(x1));
  fx2 = tanh(X2);
  % min-range approximation px+q +/- delta on [x1,x2]
  % p = f'(x2)
  % q = ( f(x1)+f(x2) - p*(x1+x2) ) / 2
  % delta = abs( ( f(x2)-f(x1) - p*(x2-x1) ) / 2 )
  p = 1 - sqr(fx2);                           % inclusion of slope
  q = 0.5*( fx1 + fx2 - p.*(x1+X2) );         % inclusion of offset
  delta = 0.5*mag( fx2 - fx1 - p.*(X2-x1) );  % upper bound of error
  
  if see && ( numel(a.mid)==1 )
    if neg
      showgraph('tanh(x)',p,-q,delta,-a.range)
    else
      showgraph('tanh(x)',p,q,delta,a.range)
    end
  end
  
  % affine approximation
  if isequal(indexpos,0)
    select = 0;                                % all indices
  else
    select = 1;                                % all indices of a, r(index)
  end
  r = rangeapprox(r,a,indexpos,select,p,q,delta);
    
end  % function tanhpos


function r = tanh0(r,index0,a,see)
% arguments enclosing zero  for min-range approximation
  % treat all components, take care of zero components later
  X = a.range;
  fX = tanh(X);
  % min-range approximation px+q +/- delta on [x1,x2]
  % p = 1
  % q = 0.5*(f(x1)-x1+f(x2)-x2))
  % delta = 0.5*(f(x2)-f(x1)-(x2-x1))
  if X.sup>-X.inf
    p = 1 - sqr(intval(fX.sup));
  else
    p = 1 - sqr(intval(fX.inf));
  end
  fXinf = intval(fX.inf);
  Xsup = intval(X.sup);
  q = 0.5*( ( fXinf+fX.sup ) - p.*( X.inf+Xsup ) );    % inclusion of offset
  delta = mag( 0.5*( ( fX.sup-fXinf ) + p.*( X.inf-Xsup ) ) );  % upper bound of error
  
  if see && ( numel(a.mid)==1 )
    showgraph('tanh(x)',p,q,delta,a.range)
  end
    
  % affine approximation
  if isequal(index0,0)
    select = 0;                             % all indices
  else
    select = 1;                             % all indices of a, r(index)
  end
  r = rangeapprox(r,a,index0,select,p,q,delta);   % range p*x+q +/- delta
  
end  % function tanh0
