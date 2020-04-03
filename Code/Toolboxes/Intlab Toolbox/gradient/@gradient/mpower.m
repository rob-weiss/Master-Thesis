function r = mpower(a,b)
%MPOWER       Implements  a ^ b  for gradients
%
% either a and b are (interval) scalar or, b is integer
%

% written  10/16/98     S.M. Rump
% modified 12/30/98     S.M. Rump  improved performance and even exponent
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 04/18/14     S.M. Rump  type adjustment
% modified 05/18/14     S.M. Rump  code optimization
% modified 08/01/14     S.M. Rump  Octave bug
% modified 12/09/15     S.M. Rump  prod(size) to numel(s)
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST

  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    if isaffari(a)
      a = intval(a);
    end
    if isaffari(b)
      b = intval(b);
    end
  end
        
  % for scalars use .^ with improved diameter for even exponent
  if ( numels(a)==1 ) && ( numels(b)==1 )
    r = a .^ b ;
    return
  end

  rndold = getround;
  if rndold
    setround(0)
  end

  intpower = 0;
  if isa(b,'double')
    intpower = isreal(b) & numels(b)==1 & b==round(b);
  end
  
  if intpower
    [m n] = size(a);
    if m~=n
      error('gradient mpower of non-square matrix')
    end
    if b==0
        r = gradient( typeadj( gradient(eye(size(a))) , typeof(a) ) );
    elseif b<0                  % b is negative integer
      error('negative gradient matrix power')
    else                        % b is integer
      b = b - 1;                % b is at least 1
      r = a;
      while b>0
        if mod(b,2)==1
          r = r*a;
        end
        b = floor(b/2);
        if b~=0
          a = a*a;
        end
      end
    end
  else
    error('invalid call of gradient mpower ^')
  end
  
  if rndold
    setround(rndold)
  end
