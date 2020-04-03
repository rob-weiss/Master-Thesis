function r = exp(a,see)
%EXP          Affine arithmetic elementwise exponential  exp(a)
%
%For scalar affari interval a, 
%
%  y = exp(a,1)
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
  
  X = a.range;
  r = struct(a);
  rndold = getround;                        % save rounding mode
  
  % treat all components, take care of zero components later
  x1 = X.inf;
  X2 = intval(X.sup);
  if INTLAB_CONST.AFFARI_APPROX
    % min-range approximation px+q +/- delta on [x1,x2]
%       p = f'(x1)  for f convex increasing  or  f concave decreasing
%       q = ( f(x1)+f(x2) - p*(x1+x2) ) / 2
%       delta = abs( ( f(x2)-f(x1) - p*(x2-x1) ) / 2 )
    p = exp(intval(x1));                    % inclusion of slope
    fx2 = exp(X2);
    q = 0.5*(p+fx2-p.*(x1+X2));             % inclusion of offset
    delta = mag( 0.5*(fx2-p-p.*(X2-x1)) );  % upper bound of error
  else
    % Chebyshev approximation px+q +/- delta on [x1,x2]
%       p = ( f(x2)-f(x1) ) / ( x2-x1 )
%       xi s.t. f'(xi) = p
%       delta = ( f(xi) - f(x1) - p*(xi-x1) ) / 2
%       q = f(x1) - p*x1 + delta
%       delta = abs(delta)
    fx1 = exp(intval(x1));
    fx2 = exp(X2);
    p = (fx2-fx1)./(X2-x1);                % inclusion of slope
    xi = log(p);                            % f'(xi) = p
    index = in(0,p(:)) | isnan(p(:)) | isinf(p(:));
    if any(index(:))                        % slope in f'(X)
      p(index) = exp(X(index));
      xi(index) = X(index);
    end
    delta = 0.5*(p - fx1 - p.*(xi-x1));  
    q = fx1 - p.*x1 + delta;                % inclusion of offset
    delta = mag(delta);                     % upper bound of error
  end
  
  if see && ( numel(x1)==1 )
    showgraph('exp(x)',p,q,delta,X)
  end
  
  % affine approximation
  select = 0;                               % all indices
  r = rangeapprox(r,a,0,select,p,q,delta); 
    
  % improve range
  setround(1)
  r = intersectNaN( r , exp(a.range) );
  setround(rndold)
  
  % possibly extra error term for rounding error
  if INTLAB_CONST.AFFARI_ROUNDINGERRORS
    r = rnderrintoerrterm(r);
  end
  
  r = class(r,'affari');
