function c = sup(a)
%SUP          Implements  sup(a)  for intervals
%
%   c = sup(a)
%
% On return, alpha <= sup(a) for all alpha in a
%

% written  10/16/98     S.M. Rump
% modified 09/02/00     S.M. Rump  rounding unchanged after use
% modified 10/03/02     S.M. Rump  impovement for sparse input
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/20/05     S.M. Rump  faster check for rounding to nearest
% modified 09/07/07     S.M. Rump  huge sparse arrays
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  if a.complex
    if isequal(a.rad,0)                  % faster for sparse matrices
      c = a.mid;
    else
      rndold = getround;
      setround(1)
      if issparse(a.rad)
        [m,n] = size(a.rad);
        [I,J,arad] = find(a.rad);
        c = a.mid + sparse(I,J,complex(arad,arad),m,n);
      else
        c = a.mid + complex(a.rad,a.rad);
      end
      setround(rndold)
    end
  else
    c = a.sup;
  end
