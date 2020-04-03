function c = diam(a)
%DIAM         implements  diam(a)
%
%   c = diam(a)
%

% written  10/16/98     S.M. Rump
% modified 11/30/98     S.M. Rump  treats infinity intervals
% modified 09/02/00     S.M. Rump  rounding unchanged after use
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 04/06/05     S.M. Rump  faster check for rounding to nearest
% modified 04/27/14     S.M. Rump  complex diameter
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
      c = 2*a.rad;
    end
  else
    rndold = getround;
    setround(1)
    c = a.sup - a.inf;
    setround(rndold)              % set rounding to previous value
  end
