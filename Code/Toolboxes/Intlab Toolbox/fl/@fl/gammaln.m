function A = gammaln(A)
%GAMMALN         Implements  gammaln(x)  for fl-type (intervals)
%
%  y = gammaln(x)
%

% written  04/22/14     S.M. Rump
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  if isa(A.value,'intval')
    RealStdFctsExcptn = intvalinit('RealStdFctsExcptn',0);
    intvalinit('RealStdFctsExcptnNaN',0);
    A = fl(gammaln(A.value));
    intvalinit(RealStdFctsExcptn,0);
  else                      % double input
    
    rndold = getround;
    if rndold
      setround(0)
    end
    
    y = gammaln(A.value);   % make sure rounding to nearest
    if isreal(y)
      A = fl(y);
    else
      index = ( imag(y(:))~=0 );
      if any(index)
        y(index) = NaN;
      end
      A = fl(real(y));
    end
    
    if rndold               % restore rounding mode
      setround(rndold)
    end
    
  end
  