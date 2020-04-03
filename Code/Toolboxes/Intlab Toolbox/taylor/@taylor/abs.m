function a = abs(a)
%ABS          Taylor absolute value abs(a)
%
%   c = abs(a)
%
%Result is convex hull of left and right derivative. This allows
%also input containing zero. The expansion
%  f(x) = f(xs) + f'(zeta)*(x-xs)
%for some zeta in ch(x,xs) is still valid
%

% written  05/21/09     S.M. Rump
% modified 04/17/14     S.M. Rump  repmat(nan,...
% modified 05/25/16     S.M. Rump  hard error for zero intervals (Thanks to A. Mahboubi, 
%                                  G. Melquiond and T. Sibut-Pinote1 for pointing to that problem)
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  if ~isreal(a.t)
    a.t = abs(a.t);
    a.t(2:end,:) = NaN(size(a.t(2:end,:)));
    return
  end

  rndold = getround;
  if rndold
    setround(0)
  end

  at = a.t(1,:);
  index = ( at<0 );
  a.t(:,index) = -a.t(:,index);
  if isa(at,'intval')
    if any(in0(0,at(1,:)))
      error('taylor/abs called with interval argument containg zero')
    end
  end

  if rndold
    setround(rndold)
  end
