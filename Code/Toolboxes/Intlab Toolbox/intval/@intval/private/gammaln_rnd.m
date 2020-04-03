function [yinf,ysup] = gammaln_rnd(x,rnd)
% input 0.5<x<2.5 real column vector
% rnd  -1  y = lower bound for gamma(x)
%       1  y = upper bound for gamma(x)
%      []  [y,ysup] inclusion of gamma(x)
% rounding may be altered after leaving gamma_rnd
%

% written  01/11/14     S.M. Rump
% modified 04/04/14     S.M. Rump  function name
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 10/11/15     S.M. Rump  global variables
%

  global INTLAB_CONST
  
  gammaln_data = INTLAB_CONST.GAMMALNDATA;
  AppGammaxs = gammaln_data.AppGammaxs;       % approximate values gamma(xs)
  N = gammaln_data.Nd(1);                     % grid 0.5+i*h, h=1/N
  AppPoly = gammaln_data.AppPoly;             % Approximating polynomials
  d = gammaln_data.Nd(2);                     % degree of polynomials
  minerr = 3.09e-17;       % AppGammaxs-minerr <= gamma(xs) <= AppGammaxs+maxerr
  maxerr = 5.29e-17;
  ii = round(N*(x-0.5)/2);                    % 0.5 <= x < 2.5, no rounding error
  xs = 0.5 + 2*ii/N;
  ii = ii + 1;
  delta = x - xs;
 
  if isempty(rnd) | ( rnd==-1 )
    setround(-1)
    y = AppPoly(ii,1);
    for k=2:d
      y = y.*delta + AppPoly(ii,k);
    end
    yinf = AppGammaxs(ii) + ( y.*delta - minerr );
    j = find( xs==1 );
    if any(j)
      yinf(j) = y(j).*delta(j) - 2.94e-16*abs(delta(j)) ;
    end
    j = find( xs==2 );
    if any(j)
      yinf(j) = y(j).*delta(j) - 1.30e-16*abs(delta(j)) ;
    end
  end
  
  if isempty(rnd) | ( rnd==1 )
    setround(+1)
    y = AppPoly(ii,1);
    for k=2:d
      y = y.*delta + AppPoly(ii,k);
    end
    ysup = AppGammaxs(ii) + ( y.*delta + maxerr );
    j = find( xs==1 );
    if any(j)
      ysup(j) = y(j).*delta(j) + 2.94e-16.*abs(delta(j)) ;
    end
    j = find( xs==2 );
    if any(j)
      ysup(j) = y(j).*delta(j) + 1.30e-16.*abs(delta(j)) ;
    end
  end
  
  if rnd==1
    yinf = ysup;
  end
    