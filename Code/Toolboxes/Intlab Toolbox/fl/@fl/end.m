function i = end(x,k,n)
%END          Overloaded functions end, specifies last index
%

% written  10/21/13     S.M. Rump
%

  xx = x.value;
  if n==1           % call as one-dimensional array
    i = length(xx(:));
  else
    i = size(xx,k);
  end
