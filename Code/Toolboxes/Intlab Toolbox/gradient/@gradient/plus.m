function r = plus(a,b)
%PLUS         Gradient addition  a + b
%

% written  10/16/98     S.M. Rump
% modified 11/30/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    improved performance
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 05/23/06     S.M. Rump  comments corrected
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 04/04/14     S.M. Rump  affari added
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
        
  rndold = getround;
  if rndold
    setround(0)
  end

  if ~isa(a,'gradient')         % non-gradient plus gradient
    r.x = a + b.x;
    if numels(b.x)>1            % b is not scalar
      r.dx = b.dx;
    else                        % b is scalar, a may be array
      r.dx = b.dx(ones(numels(r.x),1),:);
    end
    if isa(a,'intval') && isa(b.x,'double')
      r.dx = intval(r.dx);
    end
    if isa(a,'affari') && isa(b.x,'affari')
      r.dx = affari(r.dx);
    end
  elseif ~isa(b,'gradient')     % gradient plus non-gradient
    r.x = a.x + b;
    if numels(a.x)>1            % a is not scalar
      r.dx = a.dx;
    else                        % a is scalar, b may be array
      r.dx = a.dx(ones(numels(r.x),1),:);
    end
    if isa(b,'intval') && isa(a.x,'double')
      r.dx = intval(r.dx);
    end
    if isa(b,'affari') && isa(a.x,'affari')
      r.dx = affari(r.dx);
    end
  else                          % gradient plus gradient
    r.x = a.x + b.x;
    if numels(a.x)==1           % scalar gradient plus gradient
      r.dx = a.dx(ones(size(b.dx,1),1),:) + b.dx;
    elseif numels(b.x)==1
      r.dx = a.dx + b.dx(ones(size(a.dx,1),1),:);
    else
      r.dx = a.dx + b.dx;
    end
  end

  r = class(r,'gradient');
  
  if rndold
    setround(rndold)
  end
