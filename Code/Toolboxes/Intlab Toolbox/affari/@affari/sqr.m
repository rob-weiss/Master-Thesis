function r = sqr(a,see)
%SQR          Affine arithmetic elementwise square  sqr(a)
%
%For scalar affari interval a, 
%
%  y = sqr(a,1)
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
  
  % change sgn of negative components
  indexneg = find( sup(a.range)<0 );        % negative components: (-a)^2=a^2
  if any(indexneg)
    a = setvalueindex(a,indexneg,-1);
    neg = 1;                                % only for show
  else
    neg = 0;
  end
  A = a.range;
  
  r = struct(a);
  rndold = getround;                        % save rounding mode
  index = ( inf(A)>=0 ) ;                   % non-negative components
  index = index(:);
  if any(index)
    
    % treat all components, take care of zero components later
    x1 = a.range.inf;
    x2 = a.range.sup;
    X1 = intval(x1);
    if INTLAB_CONST.AFFARI_APPROX
      % min-range approximation px+q +/- delta on [x1,x2]
      % p = f'(x1)
      % q = ( f(x1)+f(x2) - p*(x2-x1) ) / 2
      % delta = ( f(x2)-f(x1) - p*(x2-x1) ) / 2
      p = 2*X1;                               % inclusion of slope
      delta = mag( (X1-x2).^2/2 );            % upper bound of error
      q = (intval(x2).^2 - X1.^2)/2 - X1.*x2; % inclusion of offset
    else
      % Chebyshev approximation px+q +/- delta on [x1,x2]
      % p = ( f(x2)-f(x1) ) / ( x2-x1 )
      % xi s.t. f'(xi) = p
      % delta = ( f(xi) - f(x1) - p*(xi-x1) ) / 2
      % q = f(x1) - p*x1 - delta
      X1 = intval(x1);
      p = X1+x2;                              % inclusion of slope
%       xi = p/2;
      delta = mag( (X1-x2).^2/8 );            % upper bound of error
      q = -delta - X1.*x2;                    % inclusion of offset
    end
    
      if see && ( numel(a.mid)==1 )
        if neg
          showgraph('sqr(x)',-p,q,delta,-a.range)
        else
          showgraph('sqr(x)',p,q,delta,a.range)
        end
      end
    
    % affine approximation
    select = 0;                               % all indices
    r = rangeapprox(r,a,0,select,p,q,delta);  
    
  end
  
  % take care of zero components
  index = find(~index);                 % zero components

  if any(index)                         % treat zero components
    X = A(index);
    if INTLAB_CONST.AFFARI_APPROX
      A0 = sqr(X);                      % f(X)
      % min-range approximation mid(f(X)) +/- rad(f(X))
      if see && ( numel(a.mid)==1 )
%         p = 0;
%         q = mid(sqr(X));
%         delta = rad(sqr(X));
        showgraph('sqr(x)',0,mid(A0),rad(A0),X)
      end
      r.mid(index) = mid(A0);
      % put errors into new error terms
      K = length(index);                 % a.err cannot be empty
      MN = numel(r.mid);
      N = INTLAB_CONST.AFFARI;
%       r.err(N+1:N+K,index) = spdiags(rad(A0(:)),0,K,K);
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(r.err)
        r.err(:,index) = 0;
        r.err = [ r.err ; sparse(N-size(r.err,1),MN) ; sparse(1:K,index,rad(A0(:)),K,MN) ];
      else
        r.err = [ sparse(N,MN) ; sparse(1:K,index,rad(A0(:)),K,MN) ];
      end
      INTLAB_CONST.AFFARI = N+K;
      r.rnderr(index) = 0;
      r.range(index) = A0;
    else
      % Chebyshev representation p*x+q +/- delta
      % p = ( f(x2)-f(x1) ) / ( x2-x1 )
      % xi s.t. f'(xi) = p
      % delta = ( f(xi) - f(x1) - p*(xi-x1) ) / 2
      % q = f(x1) - p*x1 + delta
      % delta = abs(delta)
      X1 = intval(X.inf);
      x2 = X.sup;
      p = X1 + x2;
%       xi = mid(p);
      delta = sqr(X1-x2)/8;
      q = -X1.*x2 - delta;
      delta = mag(delta);
      
      if see && ( numel(a.mid)==1 )
        if neg
          showgraph('sqr(x)',-p,q,delta,-X)
        else
          showgraph('sqr(x)',p,q,delta,X)
        end
      end

      % affine approximation    
      select = 2;                                   % selected indices
      r = rangeapprox(r,a,index,select,p,q,delta); 
      
    end
    
  end
  
  % improve range
  setround(1)
  r = intersectNaN( r , sqr(a.range) );
  setround(rndold)
  
  % possibly extra error term for rounding error
  if INTLAB_CONST.AFFARI_ROUNDINGERRORS
    r = rnderrintoerrterm(r);
  end
  
  r = class(r,'affari');
