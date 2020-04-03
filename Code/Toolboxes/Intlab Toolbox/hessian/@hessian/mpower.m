function r = mpower(a,b)
%MPOWER       Hessian power  a ^ n
%

% written  04/04/04     S.M. Rump
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
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
    if b<0
      error('negative exponent in mpower')
    end
    [m n] = size(a);
    if m~=n
      error('hessian mpower of non-square matrix')
    end
    if b==0
      if issparse(a)
        r = typeadj( hessian(speye(size(a))) , typeof(a) );
      else
        r = typeadj( hessian(eye(size(a))) , typeof(a) );
      end
    else                        % b is integer, at least 1
      b = b - 1;
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
    error('invalid call of hessian mpower ^')
  end
  
  if rndold
    setround(rndold)
  end
