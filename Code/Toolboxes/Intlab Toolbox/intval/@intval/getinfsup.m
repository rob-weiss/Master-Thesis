function [ainf,asup] = getinfsup(a)
%GETINFSUP    Access to infimum and supremum of an interval
%
%   [ainf,asup] = getinfsup(a)
%

% written  01/27/16     S.M. Rump
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  if a.complex                           % complex or thin interval
    if isequal(a.rad,0)                  % faster for sparse matrices
      ainf = a.mid;
      asup = a.mid;
    else
      rndold = getround;
      setround(1)
      if issparse(a.rad)
        [m,n] = size(a.rad);
        [I,J,arad] = find(a.rad);
        c = sparse(I,J,complex(arad,arad),m,n);
      else
        c = complex(a.rad,a.rad);
      end
      ainf = -( c - a.mid );
      asup = a.mid + c;
      setround(rndold)
    end
  else
    ainf = a.inf;
    asup = a.sup;
  end
  