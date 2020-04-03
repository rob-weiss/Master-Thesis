function c = minus(a,b)
%MINUS        Implements  a - b  for intervals
%

% written  10/16/98     S.M. Rump
% modified 09/02/00     S.M. Rump  rounding unchanged after use
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    remove check for 'double'
%                                    take care of huge arrays
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/20/05     S.M. Rump  faster check for rounding to nearest
% modified 05/16/14     S.M. Rump  Octave precedence
% modified 05/15/14     S.M. Rump  code optimization
% modified 12/10/15     F. Buenger code optimization
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST

  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    if isa(b,'fl')
      c = minus(fl(a),b);
      return
    elseif isa(b,'gradient')
      c = minus(gradient(a),b);
      return
    elseif isa(b,'hessian')
      c = minus(hessian(a),b);
      return
    elseif isa(b,'polynom')
      c = minus(polynom(a),b);
      return
    elseif isa(b,'slope')
      c = minus(slope(a),b);
      return
    elseif isa(b,'taylor')
      c = minus(taylor(a),b);
      return
    elseif isa(b,'affari')
      c = minus(affari(a),b);
      return
    end
  end
    
  rndold = getround;
  if rndold~=1                          % rounding upwards
    setround(1)
  end

  if ~isa(a,'intval')                   % a is double
    if ~isreal(a) || b.complex          % complex case
      if ~b.complex                     % C - IR
        b.mid = b.inf + 0.5*(b.sup-b.inf);
        b.rad = b.mid - b.inf;
      end
      c = INTLAB_CONST.COMPLEXINTERVAL;  % R - IC  or  C - IC
      c1 = -(b.mid - a);
      c.mid = a - b.mid;
      if isequal(b.rad,0)
        c.rad = abs(c.mid-c1);
      else
        c.rad = abs(c.mid-c1) + b.rad;
      end
      if isequal(c.rad,0)
        c.rad = 0;
      end
    else                                  % real case  R - IR
      c = INTLAB_CONST.REALINTERVAL;
      c.complex = 0;
      c.inf = -(b.sup-  a) ;
      c.sup = a - b.inf;
    end
  elseif ~isa(b,'intval')                 % b is double
    if a.complex || ~isreal(b)            % complex case
      if ~a.complex                       % IR - C
        a.mid = a.inf + 0.5*(a.sup-a.inf);
        a.rad = a.mid - a.inf;
      end
      c = INTLAB_CONST.COMPLEXINTERVAL;    % IC - R  or  IC - C
      c1 = -(b - a.mid);
      c.mid = a.mid - b;
      if isequal(a.rad,0)
        c.rad = abs(c.mid-c1);
      else
        c.rad = abs(c.mid-c1) + a.rad;
      end
      if isequal(c.rad,0)
        c.rad = 0;
      end
    else                                  % real case  IR - R
      c = a;
      c.inf = -(b - a.inf);
      c.sup = a.sup - b;
    end
  else                                    % both a and b interval
    if a.complex || b.complex             % complex case
      if ~a.complex
        a.mid = a.inf + 0.5*(a.sup-a.inf);
        a.rad = a.mid - a.inf;
      end
      if ~b.complex
        b.mid = b.inf + 0.5*(b.sup-b.inf);
        b.rad = b.mid - b.inf;
      end
      c = INTLAB_CONST.COMPLEXINTERVAL;   % IC - IC
      c1 = -(b.mid - a.mid);
      c.mid = a.mid - b.mid;
      c.rad = abs(c.mid-c1);
      if ~isequal(a.rad,0)
        c.rad = c.rad + a.rad;
      end
      if ~isequal(b.rad,0)
        c.rad = c.rad + b.rad;
      end
      if isequal(c.rad,0)
        c.rad = 0;
      end
    else                                  % real case  IR - IR
      c = a;
      c.inf = -(b.sup - a.inf);
      c.sup = a.sup - b.inf;
    end
  end

  if rndold ~= 1
      setround(rndold)
  end
end
