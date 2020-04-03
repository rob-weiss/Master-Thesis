function y = Brown(x)
%BROWN        Brown's almost linear function
%
%   y = Brown(x)
%

% written  09/05/15     S.M. Rump
% modified 01/15/16     S.M. Rump  rounding
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  rndold = getround;
  if rndold
    setround(0)
  end
  
  % Brown's almost linear function 
  % approximation x0 = 0.5*ones(n,1)
  y = x;
  n = size(x,1);
  for k=1:n-1
    y(k,:) = x(k,:) + sum(x,1) - (n+1);
  end
  y(n,:) = prod(x,1) - 1;
  
  if rndold
    setround(rndold)
  end
  