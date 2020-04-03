function r = mtimes(a,b)
%MTIMES       Taylor matrix multiplication  a * b 
%

% written  05/21/09     S.M. Rump
% modified 10/21/17     S.M. Rump  matrixwise multiplication
%

  rndold = getround;
  if rndold
    setround(0)
  end
  
  [m,k] = size(a);
  [k1,n] = size(b);
  
  if m*k==1         % a is scalar
    r = times(repmat(a,k1,n),b);
  elseif k1*n==1    % b is scalar
    r = times(a,repmat(b,m,k));
  else              % neither a nor b scalar
    if k~=k1        % dimensions incompatible
      error('inner dimensions not compatible')
    end
    r = taylor(zeros(m,n));
    for i=1:k
      %VVVV c = c .* a(i,:);
      s.type = '()'; s.subs = {':',i}; acol = subsref(a,s);
      s.type = '()'; s.subs = {i,':'}; brow = subsref(b,s);
      %AAAA Matlab V5.2 bug fix
      r = r + times(repmat(acol,1,n),repmat(brow,m,1));
    end
  end

  if rndold
    setround(rndold)
  end
  