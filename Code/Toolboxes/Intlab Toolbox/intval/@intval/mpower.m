function r = mpower(a,b)
%MPOWER       Implements  a ^ b  for intervals
%
% either a and b are (interval) scalar or, b is scalar integer
%

% written  10/16/98     S.M. Rump
% modified 12/30/98     S.M. Rump  improved performance and even exponent
% modified 05/20/02     S.M. Rump  interval integer exponent checked
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    NaN corrected
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 05/16/14     S.M. Rump  Octave precedence
% modified 05/21/14     S.M. Rump  Matlab bug
% modified 12/12/15     S.M. Rump  prod(size) to numel(s)
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST
    
  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    if isa(b,'fl')
      r = mpower(fl(a),b);
      return
    elseif isa(b,'gradient')
      r = mpower(gradient(a),b);
      return
    elseif isa(b,'hessian')
      r = mpower(hessian(a),b);
      return
    elseif isa(b,'polynom')
      r = mpower(polynom(a),b);
      return
    elseif isa(b,'slope')
      r = mpower(slope(a),b);
      return
    elseif isa(b,'taylor')
      r = mpower(taylor(a),b);
      return
    elseif isa(b,'affari')
      r = mpower(affari(a),b);
      return
    end
  end
  
  % for both a and b scalars, use .^ with improved diameter for even exponent
  if ( numels(a)==1 ) & ( numels(b)==1 )
    r = a .^ b ;
    return
  end
  
  rndold = getround;
  if rndold
    setround(0)
  end

  % Check integer exponent
  if isa(b,'intval') & all(inf(b)==sup(b)) 
    b = b.inf; 
    if ~isreal(b)
      error('invalid call of intval mpower ^')
    end
    a = intval(a);
  end
  
  if isa(b,'double') & isreal(b) & numels(b)==1 & b==round(b)
    [m n] = size(a);
    if m~=n
      error('intval mpower of non-square matrix')
    end
    if b==0
      if issparse(a)
        r = intval(speye(size(a)));
      else
        r = intval(eye(size(a)));
      end
      index = isnan(a) & ( b==0 );
      if any(index(:))
        %VVVV  r(index) = NaN;
        s.type = '()'; s.subs = {index}; r = subsasgn(r,s,NaN);
        %AAAA  Matlab bug fix
      end
    else                        % b is integer
      b_is_negative = b<0;
      b = abs(b) - 1;           % abs(b) is at least 1
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
      if b_is_negative
        r = inv(r);
      end
    end
  else
    error('invalid call of intval mpower ^')
  end
    
  if rndold
    setround(rndold)
  end
