function r = power(a,b)
%POWER        Implements  a .^ b  for affari
%

% written  04/03/14     S.M. Rump
% modified 05/16/14     S.M. Rump  Octave precedence
% modified 05/17/14     S.M. Rump  code optimization
% modified 08/01/14     S.M. Rump  integer power
% modified 12/09/15     S.M. Rump  prod(size) to numel(s)
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST
    
  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    if isa(b,'gradient')
      r = power(gradient(a),b);
      return
    elseif isa(b,'hessian')
      r = power(hessian(a),b);
      return
    elseif isa(b,'taylor')
      r = power(taylor(a),b);
      return
    end
  end
  
  rndold = getround;
  if rndold
    setround(0)
  end
  
  if ~( isreal(a) && isreal(b) )
    error('affari power only for real operands')
  end

  intpower = 0;
  if isa(b,'double')
    if numels(b)==1 & b==round(b)
      intpower = 1;
    end
  end
  
  if intpower
    if b==0
      r = affari(ones(size(a)));
      %VVVV r(isnan(a)) = NaN;
      s.type = '()'; s.subs = {isnan(a)}; r = subsasgn(r,s,NaN);
      %AAAA Matlab V5.2 bug fix
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
