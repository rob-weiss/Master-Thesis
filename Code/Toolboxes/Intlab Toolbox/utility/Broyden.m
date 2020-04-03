function y = Broyden(x)
%BROYDEN      Broyden's test function
%
%   y = test(x)
%

% written  05/01/14     S.M. Rump
% modified 05/18/14     S.M. Rump  code optimization
% modified 01/15/16     S.M. Rump  rounding
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  rndold = getround;
  if rndold
    setround(0)
  end
    
% Broyden
% approximation [ .6 ; 3 ]
% solution      [ .5 ; pi ]
  y = x;
  c1 = typeadj( 1 , typeof(x) );
  cpi = typeadj( midrad(3.14159265358979323,1e-16) , typeof(x) );
  y(1,:) = .5*sin(x(1,:).*x(2,:)) - x(2,:)/(4*cpi) - x(1,:)/2;
  y(2,:) = (1-1/(4*cpi))*(exp(2*x(1,:))-exp(c1)) + exp(c1)*x(2,:)/cpi - 2*exp(c1)*x(1,:);
  
  if rndold
    setround(rndold)
  end
  