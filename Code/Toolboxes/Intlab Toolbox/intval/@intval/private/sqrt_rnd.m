function y = sqrt_rnd(x,rnd)
%SQRT_RND     Rigorous bounds for sqrt(x) according to round
%
%   y = sqrt_rnd(x,rnd)
%
% x may be vector, assumed to be nonnegative, rnd is -1 or +1.
% Routine necessary because Matlab-sqrt computes round to nearest independent of 
% rounding mode. 
% Rounding remains setround(rnd) after execution
%

% written  01/20/03     S.M. Rump
% modified 09/06/07     S.M. Rump  improved performance
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/19/14     S.M. Rump  rounding unaltered
%

  INTLAB_INTVAL_ETA = realmin*eps;
  y = sqrt(x);
  rndold = getround;
  
  switch rnd
    case -1
      setround(1)
      index = ( y.*y>x );
      if any(index(:))
        setround(-1)
        y(index) = y(index) - INTLAB_INTVAL_ETA;
      end
    case 1
      setround(-1)
      index = ( y.*y<x );
      if any(index(:))
        setround(1)
        y(index) = y(index) + INTLAB_INTVAL_ETA;
      end
  end
  setround(rndold)
  