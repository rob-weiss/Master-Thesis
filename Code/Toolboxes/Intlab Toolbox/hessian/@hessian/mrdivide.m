function r = mrdivide(a,b)
%MRDIVIDE     Hessian division  a / b
%

% written  04/04/04     S.M. Rump
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
    setround(0)
  end

  if numels(b)~=1
    error('Hessian division only for scalar denominator')
  end

  N = INTLAB_CONST.HESSIAN_NUMVAR;

  if ~isa(a,'hessian')          % non-hessian / hessian scalar
    r.x = a / b.x;
    n = numels(a);
    if n==1                     % non-hessian scalar / hessian scalar
      D = -a / sqr(b.x);
      r.dx = b.dx * D;
      r.hx = ( b.hx - reshape((b.dx/b.x)*b.dx.',N^2,1) ) * D;
    else                        % non-hessian array / hessian scalar
      D = 1 / sqr(b.x);
      if issparse(b.hx)
        ax = sparse(-a(:).');
      else
        ax = -a(:).';
      end
      r.dx = ( b.dx * D ) * ax;
      r.hx = ( ( b.hx - reshape((b.dx/b.x)*b.dx.',N^2,1) ) * D ) * ax;
    end
  elseif ~isa(b,'hessian')      % hessian / non-hessian scalar    
    r.x = a.x / b;
    r.dx = a.dx / b;
    r.hx = a.hx / b;
  else                          % hessian / hessian scalar
    r.x = a.x / b.x;
    D = 1 / sqr(b.x);
    n = numels(a.x);
    if n==1                     % hessian scalar / hessian scalar
      Num = a.dx * b.x - a.x * b.dx;
      r.dx = Num * D;
      r.hx = ( a.hx * b.x - reshape((b.dx/b.x) * Num.',N^2,1) - a.x * b.hx ) * D;
    else                        % hessian array / hessian scalar
      if issparse(a.hx)
        ax = sparse(a.x(:).');
      else
        ax = a.x(:).';
      end
      Num = a.dx * b.x - b.dx * ax;
      r.dx = Num * D;
      bdx = b.dx / b.x;
      r.hx = ( a.hx * b.x - reshape( bdx*Num(:).' , N^2,n ) - b.hx * ax ) * D;
    end
  end

  r = class(r,'hessian');
  
  if rndold
    setround(rndold)
  end
