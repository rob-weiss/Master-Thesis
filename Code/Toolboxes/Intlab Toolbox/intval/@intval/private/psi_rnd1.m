function y = psi_rnd1(x,index,rnd)
% input x real non-negative column vector
% rnd    -1   y = lower bound for erf(x)
%         1   y = upper bound for erf(x)
% index   1   [0,10]
%         2   (10,60]
%         3   (60,inf)
% rounding may be altered after leaving psi_rnd2
%

% written  10/11/15     S.M. Rump
%

  if index==1
    d = 9;
    setround(-rnd)
    xd = x + d;
    xd2 = xd.^2;
    setround(rnd)
    y = 1./xd + (0.5)./xd2;
    xx = - (-1)./( (x+d).^2 );
  else
    setround(-rnd)
    xx = x.*x;
    setround(rnd)
    y = 1./x + (0.5)./xx;
    xx = - ( (-1)./(x.^2) );
    xd = x;
  end
  
  % [ 85085 -17017  12155 -17017 38675 -129217 595595 -3620617] / 510510
  if index<3
    if rnd==1
      s = 595595;
    else
      s = (-3620617)*xx + 595595;
    end
    s = (( s.*xx - 129217 ).*xx + 38675 ).*xx - 17017;
  else
    if rnd==1
      s = 0;
    else
      s = -17017;
    end
  end
  y = y + ( (( s.*xx + 12155 ).*xx - 17017 ).*xx + 85085 ).*xx./xd/510510;
  
  if index==1
    s = 0;
    for dd=d-1:-1:1
      s = s + ( (-1) ./ ( (-x)-dd ) ).^2;
    end
    s = s + (-1)./( (-x).*x );
    y = y + s;
  end
      