function c = plus(a,b)
%PLUS         Implements  a + b  for intervals
%

% written  10/16/98     S.M. Rump
% modified 09/02/00     S.M. Rump  rounding unchanged after use
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    remove check for 'double'
%                                    take care of huge arrays
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/20/05     S.M. Rump  faster check for rounding to nearest
% modified 03/16/10     S.M. Rump  typo
% modified 05/16/14     S.M. Rump  Octave precedence
% modified 05/15/14     S.M. Rump  code optimization
% modified 12/10/15     F. Buenger code optimization
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST

  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    if isa(b,'fl')
      c = plus(fl(a),b);
      return
    elseif isa(b,'gradient')
      c = plus(gradient(a),b);
      return
    elseif isa(b,'hessian')
      c = plus(hessian(a),b);
      return
    elseif isa(b,'polynom')
      c = plus(polynom(a),b);
      return
    elseif isa(b,'slope')
      c = plus(slope(a),b);
      return
    elseif isa(b,'taylor')
      c = plus(taylor(a),b);
      return
    elseif isa(b,'affari')
      c = plus(affari(a),b);
      return
    end
  end
    
  rndold = getround;
  if rndold~=1                            % rounding upwards
    setround(1)
  end

  if ~isa(a,'intval')                     % a is double
    if ~isreal(a) || b.complex            % complex case
      if ~b.complex                       % C + IR -> C + IC
        b.mid = b.inf + 0.5*(b.sup-b.inf);
        b.rad = b.mid - b.inf;
      end
      c = INTLAB_CONST.COMPLEXINTERVAL;   % R + IC  or  C + IC
      c1 = -((-a) + (-b.mid));
      c.mid = a + b.mid;
      if isequal(b.rad,0)
        c.rad = abs(c.mid-c1);
      else
        c.rad = abs(c.mid-c1) + b.rad;
      end
      if isequal(c.rad,0)                 % avoid sparse zero
        c.rad = 0;
      end
    else                                  % real case  R + IR
      c = b;
      c.sup = a + b.sup;      
      c.inf = -((-a) + (-b.inf));
    end
  elseif ~isa(b,'intval')                 % b is double
    if a.complex || ( ~isreal(b) )        % complex case
      if ~a.complex                       % IR + C -> IC + C
        a.mid = a.inf + 0.5*(a.sup-a.inf);
        a.rad = a.mid - a.inf;
      end
      c = INTLAB_CONST.COMPLEXINTERVAL;    % IC + R  or  IC + C
      c1 = -((-a.mid) + (-b));
      c.mid = a.mid + b;
      if isequal(a.rad,0)  
        c.rad = abs(c.mid-c1);
      else
        c.rad = abs(c.mid-c1) + a.rad;
      end
      if isequal(c.rad,0)
        c.rad = 0;
      end
    else                                  % real case  IR + R
      c = a;
      c.sup = a.sup + b;
      c.inf = -((-a.inf) + (-b));      
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
      c = INTLAB_CONST.COMPLEXINTERVAL;    % IC + IC
      c1 = -((-a.mid) + (-b.mid));
      c.mid = a.mid + b.mid;
      c.rad = abs(c.mid-c1);
      if isequal(a.rad,0)
        if isequal(b.rad,0)
          if isequal(c.rad,0)
            c.rad = 0;
          end
        else
          c.rad = c.rad + b.rad;
        end
      else
        if isequal(b.rad,0)
          c.rad = c.rad + a.rad;
        else
          c.rad = c.rad + ( a.rad + b.rad );
        end
      end
    else                                  % real case  IR + IR
      c = a;
      c.sup = a.sup + b.sup;
      c.inf = -((-a.inf) + (-b.inf));
    end
  end
  
  if rndold ~= 1
      setround(rndold)
  end

end
