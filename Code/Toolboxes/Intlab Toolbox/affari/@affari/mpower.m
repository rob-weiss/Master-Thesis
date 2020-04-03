function r = mpower(a,b)
%MPOWER       Implements  a ^ b  for affari
%
% either a and b are (interval) scalar or, b is integer
%

% written  04/03/14     S.M. Rump
% modified 05/16/14     S.M. Rump  Octave precedence
% modified 05/17/14     S.M. Rump  code optimization
% modified 05/21/14     S.M. Rump  Matlab bug
% modified 12/09/15     S.M. Rump  prod(size) to numel(s)
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST
    
  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    if isa(b,'gradient')
      r = mpower(gradient(a),gradient(b));
      return
    elseif isa(b,'hessian')
      r = mpower(hessian(a),hessian(b));
      return
    elseif isa(b,'taylor')
      r = mpower(taylor(a),taylor(b));
      return
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

  if isa(b,'double') & isreal(b) & numels(b)==1 & b==round(b)
    [m n] = size(a);
    if m~=n
      error('affari mpower of non-square matrix')
    end
    if b==0
        r = affari(eye(size(a)));
    elseif b<0                  % b is negative integer
      error('negative affari matrix power')
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
    error('invalid call of affari mpower ^')
  end
  
  if rndold
    setround(rndold)
  end
