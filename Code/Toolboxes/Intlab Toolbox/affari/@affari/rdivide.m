function r = rdivide(a,b,see)
%RDIVIDE      Affine arithmetic elementwise division  a ./ b
%
%For scalar affari intervals a and b,
%
%  y = rdivide(a,b,1)
%
%plots the function together with its affine approximation.
%

% written  04/04/14     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/17/14     S.M. Rump  code optimization
% modified 05/21/14     S.M. Rump  All zero sparse: 1-by-1
% modified 05/21/14     S.M. Rump  Octave bug preference
% modified 12/09/15     S.M. Rump  prod(size) to numel
%

  global INTLAB_CONST

  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    if isa(b,'gradient')
      r = rdivide(gradient(a),gradient(b));
      return
    elseif isa(b,'hessian')
      r = rdivide(hessian(a),hessian(b));
      return
    elseif isa(b,'taylor')
      r = rdivide(taylor(a),taylor(b));
      return
    end
  end

  if nargin==2
    see = 0;
  end
  
  % status of interval standard functions
  RealStdFctsExcptn = intvalinit('RealStdFctsExcptn');
  intvalinit('RealStdFctsExcptnNaN',0);
  
  if isa(b,'affari')        % compute reciprocal 1/b
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if ~nnz(b.err)          % no affari error terms
      r = affari(a.*(1./b.range));
    else                    % b is affari with error terms
      indexneg = ( sup(b.range)<0 );
      if any(indexneg(:))
        b.mid(indexneg) = -b.mid(indexneg);
        % take care of "All zero sparse: 1-by-1": do not use 'isempty'
        if nnz(b.err)
          b.err(:,indexneg(:)') = -b.err(:,indexneg(:)');
        end
        b.range(indexneg) = -b.range(indexneg);
      end
      index0NaN = in(0,b.range);
      x1 = b.range.inf;
      x2 = b.range.sup;
      
      if INTLAB_CONST.AFFARI_APPROX
        % min-range approximation px+q +/- delta on [x1,x2]
        % p = f'(x2)  for f convex decreasing  or  f concave increasing
        % q = ( f(x1)+f(x2) - p*(x1+x2) ) / 2
        % delta = abs( ( f(x2)-f(x1) - p*(x2-x1) ) / 2 )
        % p = -1/x2^2
        % q = (x1 + x2)^2/(2*x1*x2^2)
        % delta = (x1 - x2)^2/(2*x1*x2^2)
        X2 = intval(x2);
        x22 = X2.^2;
        Den = 1./(2*x1.*x22);
        p = -1./x22;                                % inclusion of slope
        q = (x1 + X2).^2.*Den;                      % inclusion of offset
        delta = mag((x1 - X2).^2.*Den);             % upper bound of error
      else
        % Chebyshev approximation px+q +/- delta on [x1,x2]
        %   p = ( f(x2)-f(x1) )/ ( x2-x1 )
        %   xi s.t. f'(xi) = p
        %   delta = ( f(xi) - f(x1) - p*(xi-x1) ) / 2
        %   q = f(x1) - p*x1 + delta
        %   delta = abs(delta)
        % simplified:
        %   xi = (x1*x2)^(1/2)
        %   p = -1/(x1*x2)        
        %   q = 1/xi + 1/(2*x1) + 1/(2*x2)
        %   delta = abs( 1/(2*x1) - 1/xi + 1/(2*x2) )
        Half = intval(0.5);
        x12 = intval(x1).*x2;
        x1i2 = Half./x1;
        x2i2 = Half./x2;
        xi = sqrt(x12);
        p = -1./x12;                                % inclusion of slope
        xi1 = 1./xi;
        q = xi1 + x1i2 + x2i2;                      % inclusion of offset
        delta = mag( x1i2 - xi1 + x2i2 );           % upper bound of error
      end
      
      if see && ( numel(b.mid)==1 )
        showgraph('1/(x)',p,q,delta,b.range)
      end
      
      % affine approximation
      rndold = getround;                % save rounding mode     
      r = struct(b);
      select = 0;                       % all indices
      r = rangeapprox(r,b,0,select,p,q,delta);

      r = intersectNaN( r , 1./b.range );
      setround(rndold)                  % retrieve rounding mode
      
      if any(indexneg(:))
        r.mid(indexneg) = -r.mid(indexneg);
        % take care of "All zero sparse: 1-by-1": do not use 'isempty'
        if nnz(r.err)
          r.err(:,indexneg(:)') = -r.err(:,indexneg(:)');
        end
        r.range(indexneg) = -r.range(indexneg);
      end      
      if any(index0NaN(:))
        r.mid(index0NaN) = NaN;
        % take care of "All zero sparse: 1-by-1": do not use 'isempty'
        if nnz(r.err)
          r.err(:,index0NaN) = 0;
        end
        r.rnderr(index0NaN) = inf;
        r.range(index0NaN) = intval(-inf,inf,'infsup');
      end
      % possibly extra error term for rounding error
      if INTLAB_CONST.AFFARI_ROUNDINGERRORS
        r = rnderrintoerrterm(r);
      end
      r = a.*class(r,'affari');
    end
  else                      % b is not affari
    r = affari(a.*(1./intval(b)));
  end

  % retrieve status of interval standard functions
  intvalinit(RealStdFctsExcptn,0);
    