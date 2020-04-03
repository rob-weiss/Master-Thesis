function a = abs(a)
%ABS          Gradient absolute value abs(a)
%
%   c = abs(a)
%
%Result is convex hull of left and right derivative. This allows
%also input containing zero. The expansion
%  f(x) = f(xs) + f'(zeta)*(x-xs)
%for some zeta in ch(x,xs) is still valid
%

% written  10/16/98     S.M. Rump
% modified 06/24/99     S.M. Rump  multi-dimensional arrays
% modified 07/08/02     S.M. Rump  adapted to intval\abs, error for real zero input
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    improved performance
%                                    real and complex zero input allowd
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 05/23/06     S.M. Rump  complex arguments (thanks to Sébastien Loisel)
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 03/07/10     S.M. Rump  result real
% modified 04/17/14     S.M. Rump  repmat(nan,...
% modified 05/01/14     S.M. Rump  affari added
% modified 05/18/14     S.M. Rump  code optimization
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  if ~isreal(a.x)
    a.x = abs(a.x);
    a.dx = NaN(size(a.dx));
    if isa(a.x,'intval')
      a.dx = intval(a.dx);
    end
    return
  end

  rndold = getround;
  if rndold
    setround(0)
  end

  ax = a.x(:);
  index = ( ax<0 );
  a.x = abs(a.x);
  a.dx(index,:) = -a.dx(index,:);
  if isa(ax,'intval') || isa(ax,'affari')
    index = in0(0,ax);
    a.dx(index,:) = infsup(-1,1)*a.dx(index,:);
  end

  if rndold
    setround(rndold)
  end
