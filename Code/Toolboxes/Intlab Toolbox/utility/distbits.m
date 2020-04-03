function d = distbits(a,b)
%DISTBITS     Distance in bits of two reals
%
%   d = distbits(a,b)
%
%for  d > 0 :  d-fold successor of a is b
%for  d < 0 :  d-fold predecessor of a is b
%for  d = 0 :  a = b
%
%for performance reasons  abs(d)  limited to 100
%
%Alternative call:
%   d = distbits(A)
%for A being interval, same as  d = distbits(A.inf,A.sup)
%

% written  06/29/98     S.M. Rump
% modified 09/02/00     S.M. Rump  rounding unchanged after use
%                                  interval input allowed
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/20/05     S.M. Rump  faster check for rounding to nearest
% modified 08/26/12     S.M. Rump  global variables removed
% modified 08/23/13     S.M. Rump  infinity
% modified 05/18/14     S.M. Rump  code optimization
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  rndold = getround;
  if rndold
    setround(0)
  end

  INTLAB_INTVAL_ETA = realmin*eps;

  if ( nargin==1 ) && isa(a,'intval')
    b = sup(a);
    a = inf(a);
  end

  d = zeros(size(a==b));
  kmax = 100;

  v = ( a<b );
  index = d;
  if any(v(:))
    aold = a;
    setround(1)
    k = 0;
    while any(v(:)) && ( k<kmax )
      k = k + 1;
      a = a + INTLAB_INTVAL_ETA;
      w = ( a==b ) & ( ~index );
      index = index | w;
      d(w) = k;
      v = v & ~w;
    end
    d(v) = k+1;
    a = aold;
  end

  v = ( a>b );
  index = zeros(size(index));
  if any(v(:))
    setround(-1)
    k = 0;
    while any(v(:)) && ( k<kmax )
      k = k + 1;
      a = a - INTLAB_INTVAL_ETA;
      w = ( a==b ) & ( ~index );
      index = index | w;
      d(w) = -k;
      v = v & ~w;
    end
    d(v) = -k-1;
  end
  
  setround(rndold)
