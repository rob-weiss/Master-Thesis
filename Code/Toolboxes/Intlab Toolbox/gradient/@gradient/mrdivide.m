function r = mrdivide(a,b)
%MRDIVIDE     Implements  a / b  for gradient
%

% written  10/16/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    complete redesign
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
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
    setround(0);
  end

  if numels(b)~=1
    error('Gradient division only for scalar denominator');
  end

  N = INTLAB_CONST.GRADIENT_NUMVAR;

  if ~isa(a,'gradient')          % non-gradient / gradient scalar
    r.x = a / b.x;
    n = numels(a);
    if n==1                     % non-gradient scalar / gradient scalar
      D = -a / sqr(b.x);
      r.dx = b.dx * D;
    else                        % non-gradient array / gradient scalar
      D = 1 / sqr(b.x);
      if issparse(b.dx)
        ax = sparse(-a(:));
      else
        ax = -a(:);
      end
      r.dx = ax * ( b.dx * D );
    end
  elseif ~isa(b,'gradient')      % gradient / non-gradient scalar    
    r.x = a.x / b;
    r.dx = a.dx / b;
  else                          % gradient / gradient scalar
    r.x = a.x / b.x;
    D = 1 / sqr(b.x);
    n = numels(a.x);
    if n==1                     % gradient scalar / gradient scalar
      Num = a.dx * b.x - a.x * b.dx;
      r.dx = Num * D;
    else                        % gradient array / gradient scalar
      if issparse(a.dx)
        ax = sparse(a.x(:));
      else
        ax = a.x(:);
      end
      Num = a.dx * b.x - ax * b.dx;
      r.dx = Num * D;
    end
  end

  r = class(r,'gradient');
  
  if rndold
    setround(rndold);
  end
