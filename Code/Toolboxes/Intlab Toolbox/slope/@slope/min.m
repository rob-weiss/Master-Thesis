function u = min(a,b)
%MIN          Slope minimum of a and b
%

% written  02/02/17     S.M. Rump
%

  u = 0.5 * ( a+b - abs(a-b) );
  