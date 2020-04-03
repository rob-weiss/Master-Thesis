function r = power(a,b)
%POWER        Implements  a .^ b  for gradients
%

% written  10/16/98     S.M. Rump
% modified 12/30/98     S.M. Rump  improved performance and even exponent
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 05/14/09     S.M. Rump  NaN^0
% modified 04/18/14     S.M. Rump  type adjustment
% modified 08/01/14     S.M. Rump  Octave bug
% modified 12/09/15     S.M. Rump  prod(size) to numel(s)
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  rndold = getround;
  if rndold
    setround(0)
  end
  
  intpower = 0;
  if isa(b,'double') 
    intpower = isreal(b) && numels(b)==1 && all(all(b==round(b)));
  end
  
  if intpower
    if b==0
      r = gradient( typeadj( ones(size(a)) , typeof(a) ) );
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
  else
    r = exp( b .* log(a) );
  end
  
  if rndold
    setround(rndold)
  end
