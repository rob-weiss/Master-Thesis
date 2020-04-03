function r = mpower(p,k)
%MPOWER       Implements  p ^ k  for polynom p and nonnegative integer k
%


% written  10/25/02     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 12/09/15     S.M. Rump  prod(size) to numel
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  rndold = getround;
  if rndold
    setround(0)
  end

  % Check nonnegative integer exponent
  if ( ~isa(k,'double') ) | ( numel(k)~=1 ) | ( k~=round(k) ) | ( k<0 )
    error('polynomial exponentiation only for nonnegative integer exponents')
  end
  
  if k==0
    r = polynom(1);
  elseif k==1
    r = p;
  else                          % k is positive integer >= 2
    k = k-1;                    % abs(b) is at least 1
    r = p;
    while k>0
      if mod(k,2)==1
        r = r*p;
      end
      k = floor(k/2);
      if k~=0
        p = p*p;
      end
    end
  end
  
  if rndold
    setround(rndold)
  end
