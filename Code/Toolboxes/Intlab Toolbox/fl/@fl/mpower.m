function r = mpower(a,b)
%MPOWER       fl-type integer power  A ^ k
%

% written  03/06/14     S.M. Rump
% modified 05/18/14     S.M. Rump  code optimization
% modified 05/08/14     S.M. Rump  Matlab bug
%

  if ( ~isreal(b) ) || ( b~=round(b) )
    error('fl-type power only for integer exponents')
  end
  
  if b==0
    r = fl(ones(size(a)));
    isnana = isnan(a);
    if any(isnana)
      %VVVV  r(isnan(a)) = NaN;
      s.type = '()'; s.subs = {isnana}; r = subsasgn(r,s,NaN);
      %AAAA  Matlab bug fix
    end
  else                        % b is integer
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
    while b>0
      if mod(b,2)==1
        r = r.*a;
      end
      b = floor(b/2);
      if b~=0
        a = sqr(a);
      end
    end
    if b_is_even
      r = sqr(r);
    end
    if b_is_negative
      r = 1./r;
    end
  end

