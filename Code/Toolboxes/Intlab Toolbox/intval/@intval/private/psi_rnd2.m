function y = psi_rnd2(x,index,rnd)
% input x real non-negative column vector
% rnd    -1   y = lower bound for erf(x)
%         1   y = upper bound for erf(x)
% index   1   [0,12]
%         2   (12,70]
%         3   (70,inf)
% rounding may be altered after leaving psi_rnd2
%

% written  10/11/15     S.M. Rump
%

  setround(rnd)
  if index==1
    d = 8;
    xd = x + d;
    xx = -( (-1)./( xd.^2 ) );
  else
    xx = - ( (-1)./(x.^2) );
    xd = x;
  end
  y = -xx + (-xx)./xd;
  
  % [ -105 35 -35 63 -175 691 -3675 25319 ] / 210
  if index<3
    if rnd==1
      s = 25319*xx - 3675;
    else
      s = -3675;
    end
    s = (( s.*xx + 691 ).*xx - 175 ).*xx + 63;
  else
    if rnd==1
      s = 63;
    else
      s = 0;
    end
  end
  y = y + ( (( s.*xx - 35 ).*xx + 35 ).*xx - 105 ).*xx.*xx / 210;
  
  if index==1
    s = 0;
    for dd=d-1:-1:1
      s = s + (-2) ./ ( ( x+dd ).^3 );
    end
    s = s + (-2)./( x.^3 );
    y = y + s;
  end
      