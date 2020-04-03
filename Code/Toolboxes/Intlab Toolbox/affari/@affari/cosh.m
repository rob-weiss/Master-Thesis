function r = cosh(a,see)
%COSH         Affine arithmetic elementwise hyperbolic cosine  cosh(a)
%
%For scalar affari interval a, 
%
%  y = cosh(a,1)
%
%plots the function together with its affine approximation.
%

% written  04/04/14     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/09/14     S.M. Rump  index access
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
  
  % change sgn of negative components
  index = find( sup(a.range)<0 );           % negative components: (-a)^2=a^2
  if any(index)
    a = setvalueindex(a,index,-1);
    neg = 1;                                % only for show
  else
    neg = 0;
  end
  X = a.range;
  
  r = struct(a);
  rndold = getround;                        % save rounding mode
  index0 = ( inf(X)>=0 ) ;                  % non-negative components
  index0 = index0(:);
  if any(index0)
    
    % treat all components, take care of zero components later
    X1 = intval(X.inf);
    x2 = X.sup;
    fx1 = cosh(X1);
    fx2 = cosh(intval(x2));
    if INTLAB_CONST.AFFARI_APPROX
      % min-range approximation px+q +/- delta on [x1,x2]
      % p = f'(x1)
      % q = ( f(x1)+f(x2) - p*(x1+x2) ) / 2
      % delta = ( f(x2)-f(x1) - p*(x2-x1) ) / 2
      p = sinh(X1);                             % inclusion of slope
      q = 0.5*( fx1+fx2 - p.*(X1+x2) );         % inclusion of offset
      delta = 0.5*mag( fx2-fx1 - p.*(x2-X1) );  % upper bound of error
    else
      % Chebyshev approximation px+q +/- delta on [x1,x2]
      % p = ( f(x2)-f(x1) ) / ( x2-x1 )
      % xi s.t. f'(xi) = p
      % delta = ( f(xi) - f(x1) - p*(xi-x1) ) / 2
      % q = f(x1) - p*x1 + delta
      p = ( fx2-fx1 ) ./ ( x2-X1 );             % inclusion of slope
      xi = asinh(p);
      index = in(0,p(:)) | isnan(p(:)) | isinf(p(:));
      if any(index(:))                        % slope in f'(X)
        p(index) = sinh(X(index));
        xi(index) = X(index);
      end
      delta = 0.5*( cosh(xi) - fx1 - p.*(xi-X1) );
      q = fx1 - p.*X1 + delta;                  % inclusion of offset
      delta = mag(delta);                       % upper bound of error
    end
    
    if see && ( numel(a.mid)==1 )
      if neg
        showgraph('cosh(x)',-p,q,delta,-X)
      else
        showgraph('cosh(x)',p,q,delta,X)
      end
    end
    
    % affine approximation
    select = 0;                               % all indices
    r = rangeapprox(r,a,0,select,p,q,delta);  
    
  end
  
  % take care of zero components
  index = find(~index0);                % zero components

  if any(index)                         % treat zero components
    Xindex = X(index);
    if INTLAB_CONST.AFFARI_APPROX
      fXindex = cosh(Xindex);           % f(Xindex)
      % min-range approximation mid(f(Xindex)) +/- rad(f(Xindex))
      if see && ( numel(a.mid)==1 )
%         p = 0;
%         q = mid(acosh(Xindex));
%         delta = rad(acosh(Xindex));
        showgraph('cosh(x)',0,mid(fXindex),rad(fXindex),Xindex)
      end
      r.mid(index) = mid(fXindex);
      % put errors into new error terms
      K = length(index);                % a.err cannot be empty
      MN = numel(r.mid);
      N = INTLAB_CONST.AFFARI;
%       r.err(N+1:N+K,index) = spdiags(rad(fXindex(:)),0,K,K);
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(r.err)
        r.err(:,index) = 0;
        r.err = [ r.err ; sparse(N-size(r.err,1),MN) ; sparse(1:K,index,rad(fXindex(:)),K,MN) ];
      else
        r.err = [ sparse(N,MN) ; sparse(1:K,index,rad(fXindex(:)),K,MN) ];
      end
      INTLAB_CONST.AFFARI = N+K;
      r.rnderr(index) = 0;
      r.range(index) = fXindex;
    else
      % Chebyshev representation p*x+q +/- delta
      % p = ( f(x2)-f(x1) ) / ( x2-x1 )
      % xi s.t. f'(xi) = p
      % delta = ( f(xi) - f(x1) - p*(xi-x1) ) / 2
      % q = f(x1) - p*x1 + delta
      % delta = abs(delta)
      X1 = intval(Xindex.inf);
      x2 = Xindex.sup;
      fx1 = cosh(X1);
      fx2 = cosh(intval(x2));
      p = ( fx2-fx1 ) ./ ( x2-X1 );
      xi = asinh(p);
      delta = 0.5*( cosh(xi) - fx1 - p.*(xi-X1) );
      q = fx1 - p.*X1 + delta;
      delta = mag(delta);
      
      if see && ( numel(a.mid)==1 )
        if neg
          showgraph('cosh(x)',-p,q,delta,-Xindex)
        else
          showgraph('cosh(x)',p,q,delta,Xindex)
        end
      end
      
      % affine approximation    
      select = 2;                                   % selected indices
      r = rangeapprox(r,a,index,select,p,q,delta); 
      
    end
    
  end
  
  % improve range
  setround(1)
  r = intersectNaN( r , cosh(a.range) );
  setround(rndold)
  
  % possibly extra error term for rounding error
  if INTLAB_CONST.AFFARI_ROUNDINGERRORS
    r = rnderrintoerrterm(r);
  end
  
  % retrieve status of interval standard functions
  intvalinit(RealStdFctsExcptn,0);
  
  r = class(r,'affari');
