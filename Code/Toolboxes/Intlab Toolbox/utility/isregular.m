function res = isregular(A,prob)
%ISREGULAR    Proves that an ill-conditioned matrix A is regular
%
%   res = isregular(A)
%
%Result  res  1  It is verified that det(A)~=0
%             0  It might be det(A)=0
%
%First, a standard method is chosen to prove real or complex, point or 
%interval matrix A is regular. This method works until about condition 
%number 1e15.
%
%Matrices with condition number beyond 1e15 can only be proved to be
%regular for point matrices.
%
%If the first check fails, a second method working for arbitrarily 
%ill-conditioned matrices based on a mod-p calculation of a nonzero 
%multiple of det(A) is applied. Hence res==1 verifies that A is regular. 
%The second method requires A to be a point matrix.
%For res==0 the chances are about 1/p that det(A)~=0, where p is of the 
%order sqrt(2^53/n). For n=1000 this means p~3e6, so in one out of three 
%million cases A is regular.
%
%If you have the symbolic toolbox you may check
%   n = 50; 
%   cnd = 1e200; 
%   digits(400)
%   A = randmat(n,cnd); 
%   tic, Cnd = norm(A,inf)*norm(double(inv(sym(A,'f'))),inf), toc
%   tic, isregular(A), toc
%
%A typical output is
%   Cnd =
%       6.027590699564198e+250
%   Elapsed time is 4.654352 seconds.
%   ans =
%        1
%   Elapsed time is 0.008942 seconds.
%
%The chances of failure, i.e. it cannot be proved that A is regular although
%it is, may be diminished by choosing several primes p1,p2,...
%With the extra parameter prob
%
%   res = isregular(A,prob)
%
%sufficiently many primes are used so that the chances are about prob that A is
%regular in case res=0. For a chance 1e-20 call rr=isregular(A,1e-20). Note
%that the chance is not zero, so A may still be regular if rr=0. When
%called with the extra parameter prob, only the second stage is applied.
%

% written  06/19/13     S.M. Rump
% modified 04/04/14     S.M. Rump  end function
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 07/17/15     S.M. Rump  rewritten, complex and interval input
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
% modified 08/01/16     S.M. Rump  interval input, rounding 
%

  global INTLAB_CONST
  
  if nargin==1
    prob = 1;
  end
  
  if ( prob<=0 ) || ( prob>1 )    % chance must be within (0,1]
    error('parameter for chance must be within (0,1].')
  end
  
  rndold = getround;
  if rndold
    setround(0)
  end
    
  res = isreg(A);       % Standard test
  if res==1
    if rndold
      setround(rndold)
    end
    return
  end
  
  if ~isreal(A)
    A = [real(A) -imag(A);imag(A) real(A)];
  end
  
  if isintval(A)        % no check for extremely ill-conditioned interval matrix      
    if ~isequal(A.inf,A.sup)
      if rndold
        setround(rndold)
      end
      return
    end
    A = mid(A);
  end
  
  setround(0)
  p = 3001171;
  n = dim(A);
  
  if ( n*p^2>=2^53 )
    P = primes(floor(sqrt(2^53/max(n,100))));
    K = 0;
    p = P(end);             % current prime P(end-K)
    prime_data = GenPrimData(p);
  else
    prime_data = INTLAB_CONST.PRIMEDATA;
    K = -1;                 % no primes yet generated
  end
  
  prodp = 1;                % product of all treated primes
  res = 0;
  
  while 1
    
    % split A into mantissa and exponent
    [fA,eA] = log2(A);        % A = 2^53*fA .* 2.^(eA-53) with integer 2^53*fA
  
    % calculate A mod p
    pA = mod( mod(2^53*fA,p) .* prime_data(eA-53+1075) , p );
    
    % reduce to tringular form
    for i=1:n-1
      j = i+1:n;
      if pA(i,i)==0
        k = find(pA(j,i)~=0);
        if any(k)
          row = pA(i,:);
          pA(i,:) = pA(i+k(1),:);
          pA(i+k(1),:) = row;
        else
          res = 0;
          break
        end
      end
      pA(j,:) = pA(i,i)*pA(j,:) - pA(j,i)*pA(i,:);
      pA = mod(pA,p);
    end
    
    % calculate nonzero multiple of determinant modulo p
    d = pA(1,1);
    for i=2:n
      d = mod(d*pA(i,i),p);
    end
    
    % finish if regularity proven
    if d~=0
      res = 1;          % matrix is regular
      if rndold
        setround(rndold)
      end
      return
    end
    
    prodp = prodp * p;
    if prodp*prob>=1    % sufficient chances
      if rndold
        setround(rndold)
      end
      return
    end
    
    if K==-1            % no primes yet generated
      P = primes(floor(sqrt(2^53/max(n,100))));
    end
    
    K = K+1;
    p = P(end-K);
    if p==3001171       % already used
      K = K+1;
      p = P(end-K);
    end
    prime_data = GenPrimData(p);
    
  end
  
  if rndold
    setround(rndold)
  end
  
end  % function isregular

  
function modp = GenPrimData(p)
% generate prime data with n*p^2<2^53 and prod(p)*prob>=1

  modp = ones(1075+1024,1);   % 2^k = modp(k+1075) mod p
  % calculate positive powers of 2
  for i=1:1024
    modp(i+1075) = mod( 2*modp(i-1+1075) , p );
  end
  
  r = (p+1)/2;                % correct for odd p
  modp(-1+1075) = r;
  
  % calculate negative powers of 2
  for i=-2:-1:-1074
    modp(i+1075) = mod( r*modp(i+1+1075) , p );
  end
  
end  % function GenPrimData


function res = isreg(A)
% Standard method based on preconditioning and Perron-Frobenius Theory
% res=1 implies matrix A is regular
  res = 0;
  setround(0)
  % store warning mode
  wng = warning;
  warning off
  R = inv(mid(A));
  n = size(R,1);
  C = mag(eye(n)-R*intval(A));
  x = ones(n,1);
  setround(1)
  for i=1:5
    y = C*x;
    if all(y<x)
      setround(0)
      res = 1;
      break
    else
      y = y/norm(y,inf);
    end
  end
  % restore warning and exception mode
  warning(wng)
end  % function isreg

