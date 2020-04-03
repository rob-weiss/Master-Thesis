function r = cos(a,see)
%COS          Affine arithmetic elementwise cosine  cos(a)
%
%For scalar affari interval a, 
%
%  y = cos(a,1)
%
%plots the function together with its affine approximation.
%

% written  04/04/14     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/17/14     S.M. Rump  code optimization
% modified 05/21/14     S.M. Rump  All zero sparse: 1-by-1
% modified 05/22/14     S.M. Rump  small rad(X)
% modified 12/09/15     S.M. Rump  prod(size) to numel
% modified 02/08/17     S.M. Rump  huge diameter input
%

  global INTLAB_CONST
  
  if nargin==1
    see = 0;
  end
  
  rndold = getround;                        % save rounding mode

  % status of interval standard functions
  RealStdFctsExcptn = intvalinit('RealStdFctsExcptn');
  intvalinit('RealStdFctsExcptnNaN',0);
  
  % transform into [-pi,pi]
  if see
    INTLAB_CONST.ORIGINAL_RANGE = a.range;
  end
  Pi = intval('pi');
  fX = cos(a.range);                % before range reduction
  [a,huge,Sinf,Ssup] = rangereduction(a,4);

  X = a.range;
  
  r = struct(a);
  
  if INTLAB_CONST.AFFARI_APPROX     % min-range approximation

    % treat entries in even quartil
    indexsmall = ( Sinf==Ssup ) & ( ~huge );
    index = indexsmall & even(Sinf);
    if all(index(:))
      r = cos_(r,0,0,a,see);
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
      r = cos_(r,index,0,aa,see);
    end
    
    % treat entries in even quartil
    index = indexsmall & odd(Sinf);
    if all(index(:))
      r = cos_(r,0,1,a,see);
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
      r = cos_(r,index,1,aa,see);
    end
    
    % treat entries 0 in x
    index0 = ~indexsmall;
    if all(index0(:))
      r = cos0(r,0,a,see);
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
      r = cos0(r,index0,aa,see);
    end
    
  else                                      % Chebyshev approximation
    
    if any(~huge)
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
      fx1 = cos(intval(x1));
      fx2 = cos(X2);
      p = ( fx2-fx1 ) ./ ( X2-x1 );         % inclusion of slope
      p = intersect(p,-sin(X));             % small rad(X)
      xi1 = -asin(p);                       % in [-pi/2,pi/2]
      xi2 = intval(10)*ones(size(p.inf));   % far away
      % -1 <= Sinf,Ssup <= 2
      % quartil k: (k-1)*pi/2 .. k*pi/2
      % in any case sin(xi2)=-sin(xi1) 
      index = ( Sinf==0 );                  % 0<=Ssup<=3
      if any(index)
        xi2(index) = Pi - xi1(index);       % in quartil 2..3
      end
      % 0 in p treated as 'narrow'
      index = ( Sinf==1 ) & ( p(:)<0 );     % 1<=Ssup<=4
      if any(index)
        xi2(index) = Pi - xi1(index);       % in quartil 2
      end
      index = ( Sinf==1 ) & ( p(:)>0 );     % 1<=Ssup<=4
      if any(index)
        xi2(index) = Pi - xi1(index);       % in quartil 3
        xi1(index) = 2*Pi - xi1(index);     % in quartil 4
      end
      index = ( Sinf==2 );                  % 2<=Ssup<=5
      if any(index)
        xi2(index) = Pi - xi1(index);       % in quartil 2..3
        xi1(index) = 2*Pi + xi1(index);     % in quartil 4..5
      end
      % 0 in p treated as 'narrow'
      index = ( Sinf==3 ) & ( p(:)>0 );     % 3<=Ssup<=6
      if any(index)
        xi2(index) = Pi - xi1(index);       % in quartil 3
        xi1(index) = 2*Pi + xi1(index);     % in quartil 4
      end
      index = ( Sinf==3 ) & ( p(:)<0 );     % 3<=Ssup<=6
      if any(index)
        xi2(index) = 3*Pi + xi1(index);     % in quartil 6
        xi1(index) = 2*Pi + xi1(index);     % in quartil 5
      end
      narrow = in(0,p(:)) | isnan(p(:)) | isinf(p(:)) | ...
        in(0,xi1(:)) | isnan(xi1(:)) | isinf(xi1(:));
      if any(narrow(:))                     % slope in f'(X)
        p(narrow) = -sin(X(narrow));
        xi1(narrow) = X(narrow);            % xi2 not needed
        xi2(narrow) = 10;
      end
      % ~in(xi1,X) implies in(xi2,X)
      index1 = emptyintersect(xi1,X);
      fxi1 = cos(xi1);
      if all(index1(:))                     % only xi2 in X or narrow
        q = 0.5*( fx1-fxi1 - p.*(x1+xi2) ); % inclusion of offset
        delta = mag( 0.5*( fxi1 + fx1 + p.*(xi2-x1) ) );
      else                                  % some xi1 in X
        index2 = emptyintersect(xi2,X);
        if all(index2(:))                   % only xi1 in X
          q = 0.5*( fx1+fxi1 - p.*(x1+xi1) ); % inclusion of offset
          delta = mag( 0.5*( fxi1 - fx1 - p.*(xi1-x1) ) );
        else                                % some xi1 and some xi2 in X
          delta = mag( fxi1 + 0.5*p.*(xi2-xi1) );  % init: xi1 and xi2 in X
          q = -0.5*p.*(xi1+xi2);
          I = ( ~index1 ) & index2 ;        % treat xi1 in X
          q(I) = 0.5*( fx1(I) + fxi1(I) - p(I).*(x1(I)+xi1(I)) );
          delta(I) = mag( 0.5*( fxi1(I) - fx1(I) - p(I).*(xi1(I)-x1(I)) ) );
          J = ( index1 & ( ~index2 ) );     % treat xi2 in X
          q(J) = 0.5*( fx1(J) - fxi1(J) - p(J).*(x1(J)+xi2(J)) );
          delta(J) = mag( 0.5*( fxi1(J) + fx1(J) + p(J).*(xi2(J)-x1(J)) ) );
        end
      end
    end
    
    if any(huge)
      if all(huge(:))
        p = repmat(intval(0),size(a.mid));
        q = p;
        delta = ones(size(a.mid));
      else
        p(huge) = intval(0);
        q(huge) = intval(0);
        delta(huge) = 1;    
      end
    end
    
    if see && ( numel(a.mid)==1 )
      showgraph('cos(x)',p,q,delta,a.range)
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
    r = rnderrintoerrterm(r);
  end
  
  % take care of nan components
  indexnan = isnan(a.mid);
  if any(indexnan(:))   
    r = setvalueindex(r,indexnan,NaN);
  end
  
  % retrieve status of interval standard functions
  intvalinit(RealStdFctsExcptn,0);
  
  r = class(r,'affari');
  
end  % function cos
  
  
function r = cos_(r,index,left,a,see)
% min-range approximation
  X1 = intval(a.range.inf);
  x2 = a.range.sup;
  fx1 = cos(X1);
  fx2 = cos(intval(x2));
  % min-range approximation px+q +/- delta on [x1,x2]
  % p = f'(x1)  or  p = f'(x2)
  % q = ( f(x1)+f(x2) - p*(x1+x2) ) / 2
  % delta = abs( ( f(x2)-f(x1) - p*(x2-x1) ) / 2 )
  if left
    p = -sin(X1);                             % inclusion of slope
  else
    p = -sin(intval(x2));            
  end
  q = 0.5*( fx1 + fx2 - p.*(X1+x2) );         % inclusion of offset
  delta = 0.5*mag( fx2 - fx1 - p.*(x2-X1) );  % upper bound of error
  
  if see && ( numel(a.mid)==1 )
    showgraph('cos(x)',p,q,delta,a.range)
  end
  
  % affine approximation
  if isequal(index,0)
    select = 0;                                % all indices
  else
    select = 1;                                % all indices of a, r(index)
  end
  r = rangeapprox(r,a,index,select,p,q,delta);
  
end  % function cos_
    

function r = cos0(r,index0,a,see)
% arguments enclosing zero for min-range approximation
  % treat all components, take care of zero components later
  X = a.range;
  fX = cos(X);
  % min-range approximation px+q +/- delta on [x1,x2]
  % p = 0
  % q = mid(f(X))
  % delta = rad(f(X))
  p = 0;
  q = mid(fX);                            % inclusion of offset
  delta = rad(fX);                        % upper bound of error
  
  if see && ( numel(a.mid)==1 )
    showgraph('cos(x)',p,q,delta,a.range)
  end
  
  % affine approximation
  if isequal(index0,0)
    select = 0;                             % all indices
  else
    select = 1;                             % all indices of a, r(index)
  end
  r = rangeapprox(r,a,index0,select,p,q,delta);   % range p*x+q +/- delta
  
end  % function cos0
