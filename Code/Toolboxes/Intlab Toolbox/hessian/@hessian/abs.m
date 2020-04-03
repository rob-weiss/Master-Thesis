function a = abs(a)
%ABS          Hessian absolute value abs(a)
%
%Result is convex hull of left and right derivatives. This allows
%also input containing zero. The expansion
%  f(x) = f(xs) + f'(zeta)*(x-xs)
%for some zeta in ch(x,xs) is still valid
%

% written  04/04/04     S.M. Rump
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 05/23/06     S.M. Rump  complex arguments (thanks to Sébastien Loisel)
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 03/07/10     S.M. Rump  result real
% modified 04/17/14     S.M. Rump  repmat(nan,...
% modified 08/02/14     S.M. Rump  affari added
% modified 05/25/16     S.M. Rump  hard error for zero intervals (Thanks to A. Mahboubi, 
%                                  G. Melquiond and T. Sibut-Pinote1 for pointing to that problem)
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b
%

  if ~isreal(a.x)
    a.x = abs(a.x);
    a.dx = NaN(size(a.dx));
    a.hx = NaN(size(a.hx));
    if isa(a.x,'intval')
      a.dx = intval(a.dx);
      a.hx = intval(a.hx);
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
  a.dx(:,index) = -a.dx(:,index);
  a.hx(:,index) = -a.hx(:,index);
  if isa(ax,'intval') || isa(ax,'affari')
    if any(in0(0,ax(:)))
      error('hessian/abs called with interval argument containg zero')
    end
  end
    
  if rndold
    setround(rndold)
  end
