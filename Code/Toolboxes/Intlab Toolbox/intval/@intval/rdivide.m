function c = rdivide(a,b)
%RDIVIDE      Interval elementwise right division a ./ b
%

% written  10/16/98     S.M. Rump
% modified 11/30/98     S.M. Rump  modified for infinity
% modified 06/06/98     S.M. Rump  modified for NaN+Nan*i
% modified 09/02/00     S.M. Rump  rounding unchanged after use
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    remove check for 'double'
%                                    take care of Matlab sparse Inf/NaN bug
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/03/05     S.M. Rump  sparse flag corrected
% modified 11/20/05     S.M. Rump  faster check for rounding to nearest
% modified 02/11/06     S.M. Rump  SparseInfNanFlag removed
%                                    improved performance
% modified 05/23/06     S.M. Rump  sparse Inf/NaN bug corrected in Version 7.2+
% modified 12/03/06     S.M. Rump  Sparse Bug global flag (thanks to Arnold)
% modified 10/23/07     S.M. Rump  complex numbers
% modified 02/18/09     S.M. Rump  NaN performance improved
% modified 05/15/14     S.M. Rump  code optimization
% modified 05/16/14     S.M. Rump  Octave precedence
% modified 07/21/15     S.M. Rump  old RealStdFctsExcptnIgnore/Occurred deleted
%                                    new design hidden from user
% modified 10/15/15     S.M. Rump  redefinition of division by zero (thanks
%                                    for triggering that to David Hait, OptionMetrics LLC)
% modified 12/09/15     S.M. Rump  prod(size) to numel
% modified 12/10/15     F. Buenger code optimization
% modified 12/12/15     S.M. Rump  prod(size) to numel(s)
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
% modified 07/31/16     S.M. Rump  division by zero for large arrays
%

  global INTLAB_CONST

  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    if isa(b,'fl') 
      c = rdivide(fl(a),b);
      return
    elseif isa(b,'gradient') 
      c = rdivide(gradient(a),b);
      return
    elseif isa(b,'hessian') 
      c = rdivide(hessian(a),b);
      return
    elseif isa(b,'polynom')
      c = rdivide(polynom(a,b.v),b);
      return
    elseif isa(b,'slope')
      c = rdivide(slope(a),b);
      return
    elseif isa(b,'taylor')
      c = rdivide(taylor(a),b);
      return
    elseif isa(b,'affari')
      c = rdivide(affari(a),b);
      return
    end
  end
    
  rndold = getround;
  if rndold~=1                            % rounding upwards
    setround(1)
  end
  
  % no need to take care about huge matrices: result would be almost full anyway
  % also no care necessary about previous Matlab sparse NaN bug (would be helpful, in fact)
  % make sure a full except b is scalar, b full anyway
  if isa(b,'intval')
    bcomplex = b.complex;
    if bcomplex
      b.mid = full(b.mid);
      b.rad = full(b.rad);
      makefull = ( numel(b.mid)~=1 );
      nanindex = isnan(b.mid) | isnan(b.rad);
    else
      b.inf = full(b.inf);
      b.sup = full(b.sup);
      makefull = ( numel(b.inf)~=1 );
      nanindex = isnan(b.inf) | isnan(b.sup);
    end
  else
    bcomplex = ~isreal(b);
    b = full(b);
    makefull = ( numels(b)~=1 );
    nanindex = isnan(b);
  end
%   nanindex = sparse(nanindex);      % careful: full(True) | sparse = full
  if isa(a,'intval')
    acomplex = a.complex;
    if acomplex
      if makefull
        a.mid = full(a.mid);
        a.rad = full(a.rad);
      end
      nanindex = nanindex | isnan(a.mid) | isnan(a.rad);
    else
      if makefull
        a.inf = full(a.inf);
        a.sup = full(a.sup);
      end
      nanindex = nanindex | isnan(a.inf) | isnan(a.sup);
    end
  else
    acomplex = ~isreal(a);
    if makefull
      a = full(a);
    end
    nanindex = nanindex | isnan(a);
  end
  anynanindex = any(nanindex);
  anynanindex = any(anynanindex(:));

  ws = warning;
  warning off

  if acomplex || bcomplex               % numerator complex
    b = intval(b);                      % make sure b is interval
    if ~bcomplex                        % denominator is real
      c = a.*(1./b);
      if rndold ~= 1
        setround(rndold)
      end
      return
    end
    x = real(b.mid);                    % denominator is complex
    y = imag(b.mid);
    Ninf = -((-x).*x + (-y).*y + b.rad.*b.rad); % equivalent to setround(-1); Ninf = x.*x + y.*y + (-b.rad).*b.rad;
    index = ( Ninf<=0 );
    Nsup = x.*x + y.*y + (-b.rad).*b.rad;
    x2 = max( x./Ninf , x./Nsup );
    y2 = max( y./Ninf , y./Nsup );
    x1 = max( -((-x)./Ninf) , -((-x)./Nsup) );
    y1 = max( -((-y)./Ninf) , -((-y)./Nsup) );
    c1 = -(1i*y2 - x1);
    c2 = x2 - 1i*y1;
    binv = INTLAB_CONST.COMPLEXINTERVAL;
    binv.mid = c1 + 0.5*(c2-c1);
    binv.rad = abs( binv.mid - c1 ) + b.rad./Ninf;
    index = index | ( binv.rad<0 );
    if any(index(:))                          % division by zero
      binv.mid(index) = complex(NaN,NaN);
      binv.rad(index) = NaN;
    end
    c = a.*binv;
    if anynanindex
      c.mid(nanindex) = NaN;
      c.rad(nanindex) = NaN;                  % radius for sparse cannot be 0
    end
  else                                        % both a and b real
    if ~isa(a,'intval')                       % R ./ IR
      c = b;  
      % be sure min/max works correct for zero upper bounds in b
      index1 = ( b.inf==0 );
      if any(index1(:))
        b.inf(index1) = 0*sign(b.sup(index1));
      end
      index2 = ( b.sup==0 );
      index = [];
      if any(index2(:))
        b.sup(index2) = 0*sign(b.inf(index2));
        index = index1 & index2;
        if any(index)
          b.inf(index) = 0;
        end
      end
      index0 = ( b.inf<0 ) & ( b.sup>0 );
      if any(index0(:))
        b.inf(index0) = -0;
        b.sup(index0) = +0;
      end
      c.inf = min( -((-a)./b.inf) , -((-a)./b.sup) );
      c.sup = max( a./b.inf , a./b.sup );
      if INTLAB_CONST.RealStdFctsExcptnIgnore 
        if any(index(:))
          if numels(b)==1
            c.inf = NaN(size(c.inf));
            c.sup = c.inf;
          else
            c.inf(index) = NaN;
            c.sup(index) = NaN;
          end
        end
        if any(index0(:))
          if numels(b)==1
            index = ( a==0 );
          else
            index = index0 & ( a==0 );
          end
          if any(index(:))                    % b=0
            INTLAB_CONST.RealStdFctsExcptnOccurred = true;
            c.inf(index) = 0;
            c.sup(index) = 0;
          end
        end
      else
        index = ( a==0 ) & ( b.inf<=0 ) & ( b.sup>=0 );    % 0 in b
        if any(index(:)) 
          c.inf(index) = NaN;
          c.sup(index) = NaN;
        end
      end
      if anynanindex
        c.inf(nanindex) = NaN;
        c.sup(nanindex) = NaN;
      end
    elseif ~isa(b,'intval')                     % IR ./ R
      c = a;  
      index = ( b==0 );                         % numerator/0
      if any(index)
        b(index) = 0;
      end
      c.inf = min( -(a.inf./(-b)) , -(a.sup./(-b)) );
      c.sup = max( a.inf./b , a.sup./b );
      if any(index(:))
        if INTLAB_CONST.RealStdFctsExcptnIgnore % true exception a/0
          INTLAB_CONST.RealStdFctsExcptnOccurred = true;
          if numels(b)==1
            c.inf = NaN(size(a.inf));
            c.sup = NaN(size(a.inf));
          else
            c.inf(index) = NaN;
            c.sup(index) = NaN;
          end
        else
          if numels(b)==1
            index = ( a.inf<=0 ) & ( 0<=a.sup );
          else
            index = index & ( a.inf<=0 ) & ( 0<=a.sup );
          end
          if any(index(:))
            c.inf(index) = NaN;
            c.sup(index) = NaN;
          end
        end
        if anynanindex
          c.inf(nanindex) = NaN;
          c.sup(nanindex) = NaN;
        end
      end
    else                                        % IR ./ IR
      c = a;  
      % be sure min/max works correct for zero upper bounds in b
      index1 = ( b.inf==0 );
      if any(index1(:))
        b.inf(index1) = 0*sign(b.sup(index1));
      end
      index2 = ( b.sup==0 );
      if any(index2(:))
        b.sup(index2) = 0*sign(b.inf(index2));
      end
      index = ( b.inf<0 ) & ( 0<b.sup );
      if any(index(:))
        b.inf(index) = -0;
        b.sup(index) = +0;
      end
      c.inf = min( -((-a.inf)./b.inf) , -((-a.inf)./b.sup) );
      c.inf = min( c.inf , -((-a.sup)./b.inf) );
      c.inf = min( c.inf , -((-a.sup)./b.sup) );
      c.sup = max( a.inf./b.inf , a.inf./b.sup );
      c.sup = max( c.sup , a.sup./b.inf );
      c.sup = max( c.sup , a.sup./b.sup );      
      if INTLAB_CONST.RealStdFctsExcptnIgnore 
        if any(index(:))
          if numels(b)==1
            index = ( a.inf==0 ) & ( a.sup==0 );
          else
            index = index & ( a.inf==0 ) & ( a.sup==0 );
          end
          if any(index(:))
            c.inf(index) = 0;
            c.sup(index) = 0;
          end
        end
        index = index1 & index2;    % 0/0
        if any(index(:))
          INTLAB_CONST.RealStdFctsExcptnOccurred = true;
          if numels(b)==1
            c.inf = NaN(size(c.inf));
            c.sup = c.inf;
          else
            c.inf(index) = NaN;
            c.sup(index) = NaN;
          end
        end
      else
        % beware of huge sparse arrays:
        index = ( b.inf<=0 ) & ( b.sup>=0 );    % 0 in b
        index = index & ( a.inf<=0 ) & ( a.sup>=0 );
        if any(index(:)) 
          c.inf(index) = NaN;
          c.sup(index) = NaN;
        end
      end
      if anynanindex
        c.inf(nanindex) = NaN;
        c.sup(nanindex) = NaN;
      end
    end
  end
  
  if issparse(b) && ( numels(c) ~= 1 )
    c = sparse(c);
  end

  warning(ws)
  
  if rndold ~= 1
    setround(rndold)
  end
end
  