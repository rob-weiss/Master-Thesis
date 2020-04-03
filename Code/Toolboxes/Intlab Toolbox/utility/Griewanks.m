function y = Griewanks(x)
%GRIEWANKs    Derivative of Griewank's global optimization test function
%
%   y = Griewank(x)
%

% written  09/05/15     S.M. Rump
%

  rndold = getround;
  if rndold
    setround(0)                 % set rounding to nearest
  end
  
  n = size(x,1);
  y = x/2000;
  xx = x./repmat(sqrt(1:n)',1,size(x,2));
  for i=1:n
    v = [1:i-1 i+1:n];
    y(i,:) = y(i,:) + sin(xx(i,:))/sqrt(i) .* prod(cos(xx(v,:)),1);
  end

  if rndold
    setround(rndold)
  end
  