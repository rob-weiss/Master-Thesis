function r = power(a,b)
%POWER        Implements  a .^ b  for Taylor
%

% written  05/21/09     S.M. Rump
% modified 08/04/14     S.M. Rump  Octave care
% modified 12/12/15     S.M. Rump  prod(size) to numel(s)
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
      r = typeadj( ones(size(a)) , typeof(a) );
      r(isnan(a)) = NaN;
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
