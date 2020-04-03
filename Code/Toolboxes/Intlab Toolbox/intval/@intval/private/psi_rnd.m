function y = psi_rnd(x,index,rnd)
% input x real non-negative column vector
% rnd    -1   y = lower bound for erf(x)
%         1   y = upper bound for erf(x)
% index   1   (0,1] & [2,7)
%         2   (1,x1]
%         3   [x2,2)
%         4   [7,30)
%         5   [30,inf)
% rounding may be altered after leaving psi_rnd
%

% written  10/11/15     S.M. Rump
%

  global INTLAB_CONST
  psidata = INTLAB_CONST.PSIDATA;
  
  if index==2
    setround(0)
    y = polyval(psidata.p1,x-psidata.x1);
    y = y - rnd*y*3e-14;
    return
  end
    
  if index==3
    setround(0)
    y = polyval(psidata.p2,x-psidata.x2);
    y = y + rnd*y*7e-15;
    return
  end
  
  setround(rnd)
  if index==1
    d = 6;
    xd = x + d;
    xx = xd.^2;
    xx = - (-1)./xx;
  else
    xx = - ( (-1)./(x.^2) );
    xd = x;
  end
  y = log_rnd(xd,rnd) + (-0.5)./xd;
  
  % [ -2042040, 204204, -97240, 102102, -185640, 516868, -2042040, 10861851] / 24504480
  if index<5
    if rnd==1
      s = 10861851*xx - 2042040;
    else
      s = -2042040;
    end
    s = (( s.*xx + 516868 ).*xx - 185640 ).*xx + 102102;
  else
    if rnd==1
      s = 102102;
    else
      s = 0;
    end
  end
  y = y + ( (( s.*xx - 97240 ).*xx + 204204 ).*xx - 2042040 ).*xx / 24504480;
  
  if index==1
    s = 0;
    for dd=d-1:-1:1
      s = s + (-1) ./ ( x+dd );
    end
    s = s + (-1)./x;
    y = y + s;
  end
      
