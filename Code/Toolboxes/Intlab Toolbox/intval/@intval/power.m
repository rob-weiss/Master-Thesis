function r = power(a,b)
%POWER        Implements  a .^ b  for intervals
%
%For complex b, for complex a and non-integer b, and for components with negative real a 
%  and b containing non-integer, implementation by exp( b .* log(a) ).
%

% written  10/16/98     S.M. Rump
% modified 12/30/98     S.M. Rump  improved performance and even exponent
% modified 05/19/02     S.M. Rump  problem with vector b fixed (thanks to Arrigo)
% modified 08/06/02     S.M. Rump  complete redesign
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    NaN corrected
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 07/28/05     S.M. Rump  NaN corrected (thanks to John Pryce)
% modified 11/02/05     S.M. Rump  a^0 := 0 (thanks to J�rg Kubitz)
% modified 11/20/05     S.M. Rump  faster check for rounding to nearest
% modified 05/13/09     S.M. Rump  integer exponents, NaN^0
% modified 11/17/12     S.M. Rump  a^intval(b) correct (Thanks to T. Ogita)
% modified 04/04/14     S.M. Rump  end function
% modified 05/15/14     S.M. Rump  code optimization
% modified 05/16/14     S.M. Rump  Octave precedence
% modified 05/21/14     S.M. Rump  Matlab bug
% modified 12/10/15     F. Buenger code optimization
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
% modified 11/17/16     S.M. Rump  input out of range
% modified 02/24/17     S.M. Rump  odd and even power (thanks to Marcel Neumann
%                                    and Kai Ohlhus)
% modified 03/10/17     S.M. Rump  take care of NaN
% modified 05/08/17     S.M. Rump  debug information removed
%

  global INTLAB_CONST
    
  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    if isa(b,'fl')
      r = power(fl(a),b);
      return
    elseif isa(b,'gradient')
      r = power(gradient(a),b);
      return
    elseif isa(b,'hessian')
      r = power(hessian(a),b);
      return
    elseif isa(b,'polynom')
      r = power(polynom(a),b);
      return
    elseif isa(b,'slope')
      r = power(slope(a),b);
      return
    elseif isa(b,'taylor')
      r = power(taylor(a),b);
      return
    elseif isa(b,'affari')
      r = power(affari(a),b);
      return
    end
  end
  
  if isreal(b)
    if isa(b,'intval')
      if ( b.inf==b.sup )
        b = b.inf;
        a = intval(a);
      end
    end
    if isreal(a) && isa(b,'double') && isreal(b) && numel(b)==1  % real integer power
      if b==round(b)
        if b==0
          r = typeadj( ones(size(a)) , typeof(a) );
        else                        % b is integer
          rnd = getround;
          b_is_negative = b<0;
          % check b is even to ensure result is nonnegative
          if b==2*floor(b/2)
            b = b/2;
            b_is_even = 1;
          else
            b_is_even = 0;
          end
          b = abs(b) - 1;           % abs(b) is at least 1
          r = a;
          if b_is_even
            indexpos = ( a.inf >= 0 );
            indexneg = ( a.sup <= 0 );
            dummy = a.inf(indexneg);
            a.inf(indexneg) = -a.sup(indexneg);
            a.sup(indexneg) = -dummy;
            index = indexneg | indexpos;
            if any(index(:))
              ainf = a.inf(index);
              asup = a.sup(index);
              r.inf(index) = intpower(ainf,b,b_is_even,-1);
              r.sup(index) = intpower(asup,b,b_is_even,1);
            end
            index = ( ~index );
            if any(index(:))
              ainf = a.inf(index);
              asup = a.sup(index);
              r.inf(index) = 0;
              r.sup(index) = intpower(max(-ainf,asup),b,b_is_even,1);
            end
          else              % b is odd
            indexpos = ( a.inf >= 0 );
            if any(indexpos(:))
              ainf = a.inf(indexpos);
              asup = a.sup(indexpos);
              r.inf(indexpos) = intpower(ainf,b,b_is_even,-1);
              r.sup(indexpos) = intpower(asup,b,b_is_even,1);
            end
            indexneg = ( a.sup <= 0 );
            if any(indexneg(:))
              ainf = a.inf(indexneg);
              asup = a.sup(indexneg);
              r.inf(indexneg) = - intpower(-ainf,b,b_is_even,1);
              r.sup(indexneg) = - intpower(-asup,b,b_is_even,-1);
            end
            index = ~( indexneg | indexpos );
            if any(index(:))
              ainf = a.inf(index);
              asup = a.sup(index);
              r.inf(index) = - intpower(-ainf,b,b_is_even,1);
              r.sup(index) = intpower(asup,b,b_is_even,1);
            end
          end
          if b_is_negative
            r = 1./r;
          end
          setround(rnd)
        end
        %VVVV r(isnan(a)) = NaN;
        s.type = '()'; s.subs = {isnan(a)}; r = subsasgn(r,s,NaN);
        %AAAA Matlab V5.2 bug fix
        return
      end
    end
  end

  rndold = getround;
  if rndold~=1                            % rounding upwards
    setround(1)
  end
  
  % treat complex a or b
  if ( ~isreal(a) ) || ( ~isreal(b) )
    r = exp( b .* log(intval(a)) );  
    setround(rndold)
    return
  end
  
  % adjust sizes
  if length(a)~=1
    if length(b)~=1
      if ~isequal(size(a),size(b))
        error('sizes of mantissa and exponent do not match')
      end
    else
      b = repmat(full(b),size(a));
    end
  else
    if length(b)~=1
      a = repmat(full(a),size(b));
    end
  end
  
  wng = warning;
  warning off
  
  if isa(b,'intval')                  % exponent b real interval
    b_int = ( b.inf==b.sup ) & ( b.inf==round(b.inf) );
    if isa(a,'intval')                % a is interval, b interval
      if any(b_int(:))
        [rinfb_int , rsupb_int] = power1(a.inf(b_int),a.sup(b_int),b.inf(b_int));
      end
      aposbnonint = ( ~b_int ) & ( a.inf>=0 );
    else                              % a is non-interval, b interval
      if any(b_int(:))                % b integer
        [rinfb_int , rsupb_int] = power1(a(b_int),a(b_int),b.inf(b_int));
      end
      aposbnonint = ( ~b_int ) & ( a>=0 );
    end
  else                                % exponent b real non-interval
    b_int = ( b==round(b) );          % integer exponents
    if isa(a,'intval')                % a is interval, b not interval
      if any(b_int(:))
        [rinfb_int , rsupb_int] = power1(a.inf(b_int),a.sup(b_int),b(b_int));
      end
      aposbnonint = ( ~b_int ) & ( a.inf>=0 );
    else                              % a is non-interval, b not interval
      if any(b_int(:))                % b integer
        [rinfb_int , rsupb_int] = power1(a(b_int),a(b_int),b(b_int));
      end
      aposbnonint = ( ~b_int ) & ( a>=0 );
    end
  end
  
  r = intval(zeros(size(a)));  
  
  if any(b_int(:))            
    %VVVV r(b_int) = infsup(rinfb_int,rsupb_int);
    s.type = '()'; s.subs = {b_int}; r = subsasgn(r,s,infsup(rinfb_int,rsupb_int));
    %AAAA Matlab V5.2 bug fix
  end
  
  if INTLAB_CONST.RealStdFctsExcptnIgnore
    index = ( ~b_int );
    if any(index(:))
      aneg = min(a,0);
      apos = max(a,0);
      %VVVV rneg = exp(b(index).*log(-aneg(index)));
      s.type = '()'; s.subs = {index}; rneg = exp(subsref(b,s).*log(-subsref(aneg,s)));
      %AAAA Matlab V5.2 bug fix
      %VVVV rpos = exp(b(index).*log(apos(index)));
      s.type = '()'; s.subs = {index}; rpos = exp(subsref(b,s).*log(subsref(apos,s)));
      %AAAA Matlab V5.2 bug fix
      %VVVV r(index) = hull(-rneg,rneg,rpos);
      s.type = '()'; s.subs = {index}; r = subsasgn(r,s,hull(-rneg,rneg,rpos));
      s.type = '()'; s.subs = {index}; r = subsasgn(r,s,rpos);
      %AAAA Matlab V5.2 bug fix
    end
  else
    if any(aposbnonint(:))              % real result
      %VVVV r(aposbnonint) = exp(b(aposbnonint).*log(a(aposbnonint)));
      s.type = '()'; s.subs = {aposbnonint}; r = subsasgn(r,s,exp(subsref(b,s).*log(subsref(a,s))));
      %AAAA Matlab V5.2 bug fix
    end
    
    index = ~b_int & ~aposbnonint;      % possible complex result
    if any(index(:))
      %VVVV r(index) = exp(b(index).*log(a(index)));
      s.type = '()'; s.subs = {index}; r = subsasgn(r,s,exp(subsref(b,s).*log(subsref(a,s))));
      %AAAA Matlab V5.2 bug fix
    end
  end
  
  index0 = ( a==0 );
  if any(index0)
    b = intval(b);
    index = index0 & ( ~in(0,b) );
    %VVVV r(index) = 0;
    s.type = '()'; s.subs = {index}; r = subsasgn(r,s,0);
    %AAAA Matlab V5.2 bug fix
    index = index0 & ( in(0,b) );
    %VVVV r(index) = 0;
    s.type = '()'; s.subs = {index}; r = subsasgn(r,s,infsup(0,1));
    %AAAA Matlab V5.2 bug fix
    index = index0 & ( b==0 );
    %VVVV r(index) = 0;
    s.type = '()'; s.subs = {index}; r = subsasgn(r,s,1);
    %AAAA Matlab V5.2 bug fix
  end
    
  % take care of NaNs
  index = isnan(a) | isnan(b);
  if any(index(:))
    %VVVV r(index) = NaN;
    s.type = '()'; s.subs = {index}; r = subsasgn(r,s,NaN);
    %AAAA Matlab V5.2 bug fix
  end
  
  warning(wng)
    
  if rndold ~= 1
    setround(rndold)
  end
  
end  % function power


function r = intpower(a,b,b_is_even,rnd)
% a^b in rounding rnd for positive a and b 
  r = a;
  setround(rnd)
  while b>0
    if mod(b,2)==1
      r = r.*a;
    end
    b = floor(b/2);
    if b~=0
      a = a.*a;
    end
  end
  if b_is_even
    r = r.*r;
  end
end  % function intpower


function [rinf,rsup] = power1(ainf,asup,b)
% interval a, integer b, size(a)=size(b)
% Rounding is already switched to upwards by caling function 'power'. 
  rinf = ones(size(ainf));
  rsup = rinf;
  b_0 = ( b==0 );
  if any(b_0(:))
    rinf(b_0) = 1;
    rsup(b_0) = 1;
  end
  b_even = ( mod(b,2)==0 ) & ~b_0;
  if any(b_even(:))
    a_0 = b_even & ( ainf<0 ) & (asup>0 );
    if any(a_0)                         % 0 in a  &  b even
      rinf(a_0) = 0;
      [lb,ub] = powerint(-ainf(a_0),asup(a_0),abs(b(a_0)),1,1);
      rsup(a_0) = max(lb,ub);
    end
    a_pos = b_even & (ainf>=0 );
    if any(a_pos(:))                       % a>=0  &  b even
      [rinf(a_pos) , rsup(a_pos)] = powerint(ainf(a_pos),asup(a_pos),abs(b(a_pos)),-1,1);
    end
    a_neg = b_even & (asup<=0 );
    if any(a_neg(:))                       % a<=0  &  b even
      [rinf(a_neg) , rsup(a_neg)] = powerint(-asup(a_neg),-ainf(a_neg),abs(b(a_neg)),-1,1);
    end
  end
  b_odd = ( mod(b,2)==1 );
  if any(b_odd(:))
    a_pos = b_odd & ( ainf>=0 );
    if any(a_pos)
      [rinf(a_pos) , rsup(a_pos)] = powerint(ainf(a_pos),asup(a_pos),abs(b(a_pos)),-1,1);
    end
    a_neg = b_odd & ( asup<=0 );
    if any(a_neg)             % careful with rounding
      [rinf(a_neg) , rsup(a_neg)] = powerint(-ainf(a_neg),-asup(a_neg),abs(b(a_neg)),1,-1);
      rinf(a_neg) = -rinf(a_neg);
      rsup(a_neg) = -rsup(a_neg);
    end
    a_0 = b_odd & ~a_pos & ~a_neg;
    if any(a_0)               % careful with rounding
      [rinf(a_0) , rsup(a_0)] = powerint(-ainf(a_0),asup(a_0),abs(b(a_0)),1,1);
      rinf(a_0) = -rinf(a_0);
    end
  end
  b_neg = ( b<0 );                      % treat negative b
  if any(b_neg(:))
    indexinv = b_neg & ( rinf<=0 ) & ( rsup>=0 );
    dummy = -((-1)./rsup(b_neg)); 
    rsup(b_neg) = 1./rinf(b_neg);
    rinf(b_neg) = dummy;
    if any(indexinv(:))
      rinf(indexinv) = -inf;
      rsup(indexinv) = inf;
    end
  end

end  % function power1


function [r1,r2] = powerint(a1,a2,b,rnd1,rnd2)
% non-negative a1,a2, positive integer b, size(a2)=size(b), result ri=ai.^b with rounding rndi
% Rounding is already switched to upwards by caling functions 'power1' and 'power'. 
 r1 = a1;
 r2 = a2;
 b = b(:)-1;
 while any(b>0)
   index = ( mod(b,2)==1 );
   if any(index)
     r1(index) = rnd1 * ( (rnd1 * r1(index)) .* a1(index) );  % equivalent to setround(rnd1); r1(index) = r1(index).*a1(index);
     r2(index) = rnd2 * ( (rnd2 *  r2(index)) .* a2(index) ); % equivalent to setround(rnd2); r2(index) = r2(index).*a2(index);
   end
   b = floor(b/2);
   index = ( b~=0 );
   if any(index)
     a1(index) = rnd1 * ( (rnd1 * a1(index)) .* a1(index) );  % equivalent to setround(rnd1); a1(index) = a1(index).*a1(index);
     a2(index) = rnd2 * ( (rnd2 * a2(index)) .* a2(index) );  % equivalent to setround(rnd2); a2(index) = a2(index).*a2(index);
   end
 end
end  % function powerint
