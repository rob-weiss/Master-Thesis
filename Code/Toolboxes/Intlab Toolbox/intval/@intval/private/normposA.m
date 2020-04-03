function normbnd = normposA(A,normrelerr)
% upper bound for the 2-norm of a nonnegative matrix A up to normrelerr according to (3.1/2)
% For internal use in norm, cond

% written  08/17/99     S.M. Rump
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  normbnd = inf;
  cont = 1;
  x = sum(A,1)';
  if ~any(x)                % take care of A==0
    normbnd = 0;
    return
  end
  
  rndold = getround;
  setround(1)
  
  while cont & ( normbnd~=0 )   % use Collatz' lemma
    normold = normbnd;
    y = A'*(A*x);           % y_i=0 only for x==0
    normbnd = max(y./x);    % zero column of A produces NaN in y./x
    x = y/normbnd;
    cont = ( abs(normbnd-normold)>normrelerr*normbnd );
  end
  
  setround(rndold)          % reset rounding

  normbnd = sqrt(intval(normbnd));
