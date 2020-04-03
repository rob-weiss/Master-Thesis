function r = mtimes(a,b)
%MTIMES       Gradient multiplication  a * b
%

% written  10/16/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    case distinction for gradient / non-gradient input
%                                    complete redesign
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/02/05     S.M. Rump  improved performance (thanks to Joerg Kubitz, Hannover)
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
% modified 08/01/14     S.M. Rump  Octave bug
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
        
  if ( length(size(a))>2 ) || ( length(size(b))>2 )
    error('gradient multiplication * only for 2-dimensional arrays')
  end
  [m k] = size(a);              % first dimension
  [k1 n] = size(b);             % second dimension
  if m*k==1                     % one factor scalar
    r = a .* b;
    return
  elseif k1*n==1                % one factor scalar
    r = b .* a;
    return
  end
  
  rndold = getround;
  if rndold
    setround(0)
  end

  % both factors arrays
  if k~=k1
    error('inner dimensions do not match')
  end
  N = INTLAB_CONST.GRADIENT_NUMVAR;

  if ~isa(a,'gradient')      % non-gradient array * gradient array

    INTLAB_GRADIENT_SPARSE = INTLAB_CONST.GRADIENT_SPARSE;
    if N>=INTLAB_GRADIENT_SPARSE
      a = sparse(a);
    end
    r.x = a * b.x;
    e = b.dx.';
    e = reshape(reshape(e(:,reshape(1:k*n,k,n)'),N*n,k)*(a.'),N,m*n);
    r.dx = e(:,reshape(1:n*m,n,m)').';

  elseif ~isa(b,'gradient')          % gradient array * non-gradient array

    INTLAB_GRADIENT_SPARSE = INTLAB_CONST.GRADIENT_SPARSE;
    if N>=INTLAB_GRADIENT_SPARSE
      b = sparse(b);
    end
    r.x = a.x * b;
    r.dx = reshape(reshape(a.dx.',N*m,k)*b,N,m*n).';

  else                                  % gradient array * gradient array

    r.x = a.x * b.x;
    e = b.dx.';
    dims = m*n;
    e = reshape(reshape(e(:,reshape(1:k*n,k,n)'),N*n,k)*(a.x).',N,dims);
    r.dx = ( e(:,reshape(1:n*m,n,m)') + reshape(reshape(a.dx.',N*m,k)*(b.x),N,dims) ).';

  end

  if m*n==1                     % avoid Matlab sparse 1x1 bug
    r.x = full(r.x);
    if N==1
      r.dx = full(r.dx);
    end
  end
  r = class(r,'gradient');

  if rndold
    setround(rndold)
  end
