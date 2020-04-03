function c = rad(a)
%RAD          Implements  rad(a)  for intervals
%
%   c = rad(a)
%
% mid(a) and rad(a) computed such that
%    alpha  in  < mid(a) , rad(a) >  for all alpha in a      (*)
%
%As has been pointed out by G. Mayer, Rostock, this implies a peculiarity.
%For an interval X with bound differing by one bit, the result of rad(X)
%and diam(X) is the same. For example, 
%
%   x = infsup(1,1+eps), rx = rad(x), dx = diam(x)
%
%yields
% 
% intval x = 
%     1.0000
% rx =
%   2.2204e-016
% dx =
%   2.2204e-016
%
%to assure (*). So for comparing the quality of interval inclusions I recommend
%  to use diam.
%

% written  10/16/98     S.M. Rump
% modified 06/22/99     S.M. Rump  for sparse matrices
% modified 09/02/00     S.M. Rump  rounding unchanged after use
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 06/29/05     S.M. Rump  comment rad/diam added
% modified 11/20/05     S.M. Rump  faster check for rounding to nearest
% modified 09/10/07     S.M. Rump  performance, huge arrays
% modified 07/23/09     S.M. Rump  changed formula (thanks to Gerhard Heindl for pointing to this)
% modified 04/04/14     S.M. Rump  infinite bounds
% modified 04/27/14     S.M. Rump  complex radius
% modified 06/25/15     S.M. Rump  R2015b does not like large indices
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  if a.complex
    if isequal(a.rad,0)
      if issparse(a.mid)
        [m n] = size(a.mid);
        c = sparse([],[],[],m,n);
      else
        c = zeros(size(a.mid));
      end
    else
      c = a.rad;
    end
  else
    rndold = getround;
    m = mid(a);
    setround(1)
    c = max( m-a.inf , a.sup-m );
    setround(rndold)
    % Matlab bug: do not use index(:)
    c( isinf(a.inf) | isinf(a.sup) ) = inf;
    % Careful with sparse arrays: do not use ~isnan(...)
    c( isnan(a.inf) | isnan(a.sup) ) = NaN;
  end
