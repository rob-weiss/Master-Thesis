function r = coth(a,see)
%COTH         Affine arithmetic elementwise hyperbolic cotangent  coth(a)
%
%For scalar affari interval a, 
%
%  y = coth(a,1)
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
  
  r = struct(a);
  rndold = getround;                        % save rounding mode
  
  % treat entries x>=0
  indexpos = ( a.range.inf>=0 );
  if all(indexpos(:))
    r = cothpos(r,0,neg,a,see);
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
    r = cothpos(r,indexpos,neg,aa,see);
  end
    
  % improve range
  setround(1)
  r = intersectNaN( r , coth(a.range) );
  setround(rndold)
  
  % possibly extra error term for rounding error
  if INTLAB_CONST.AFFARI_ROUNDINGERRORS
    r = rnderrintoerrterm(r);
  end
  
  % take care of negative components
  if any(indexneg(:))   
    r = setvalueindex(r,indexneg,-1);
  end

  % treat entries 0 in x
  index0 = ( a.range.inf<0 );
  if any(index0(:))
    r = setvalueindex(r,index0,NaN);
  end

  % retrieve status of interval standard functions
  intvalinit(RealStdFctsExcptn,0);
  
  r = class(r,'affari');
  
end  % function coth
  
  
function r = cothpos(r,indexpos,neg,a,see)
% non-negative arguments
  global INTLAB_CONST
  x1 = a.range.inf;
  X2 = intval(a.range.sup);
  fx1 = coth(intval(x1));
  fx2 = coth(X2);
  if INTLAB_CONST.AFFARI_APPROX
    % min-range approximation px+q +/- delta on [x1,x2]
    % p = f'(x2)
    % q = ( f(x1)+f(x2) - p*(x1+x2) ) / 2
    % delta = abs( ( f(x2)-f(x1) - p*(x2-x1) ) / 2 )
    p = 1 - sqr(coth(X2));                    % inclusion of slope
    q = 0.5*( fx1 + fx2 - p.*(x1+X2) );       % inclusion of offset
    delta = 0.5*mag( fx2 - fx1 - p.*(X2-x1) ); % upper bound of error
  else
    % Chebyshev approximation px+q +/- delta on [x1,x2]
    % p = ( f(x2)-f(x1) ) / ( x2-x1 )
    % xi s.t. f'(xi) = p
    % delta = ( f(xi) - f(x1) - p*(xi-x1) ) / 2
    % q = f(x1) - p*x1 + delta
    p = ( fx2-fx1)./(X2-x1);                  % inclusion of slope
    xi = acoth(sqrt( intersect( 1-p , infsup(1,inf) ) ));
    index = in(0,p(:)) | isnan(p(:)) | isinf(p(:)) | ...
            in(0,xi(:)) | isnan(xi(:)) | isinf(xi(:));
    if any(index(:))                          % slope in f'(X)
      p(index) = 1 - sqr(coth(a.range(index)));
      xi(index) = a.range(index);
    end
    delta = 0.5*( coth(xi) - fx1 - p.*(xi-x1) );
    q = fx1 - p.*x1 + delta;                  % inclusion of offset
    delta = mag(delta);                       % upper bound of error
  end
  
  if see && ( numel(a.mid)==1 )
    if neg
      showgraph('coth(x)',p,-q,delta,-a.range)
    else
      showgraph('coth(x)',p,q,delta,a.range)
    end
  end
  
  % affine approximation
  if isequal(indexpos,0)
    select = 0;                                % all indices
  else
    select = 1;                                % all indices of a, r(index)
  end
  
  r = rangeapprox(r,a,indexpos,select,p,q,delta);
  
end  % function cothpos
