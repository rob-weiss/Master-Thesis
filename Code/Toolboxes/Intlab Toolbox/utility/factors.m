function L = factors(n)
%FACTORS      List of factors of n (including 1, excluding n)
%
%   L = factors(n)
%
%Uses factorization of n; may be slow for large values of n.
%For perfect numbers, n=sum(factors(n)).
%

% written  08/09/03     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 02/22/07     S.M. Rump  comment
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 02/01/14     S.M. Rump  corrected for prime input (thanks to John Pryce)
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  rndold = getround;
  if rndold
    setround(0)
  end

  P = factor(n);        % prime factors of n
  lP = length(P);
  if lP==1              % input is prime
    L = 1;
  else
    L = [ 1 P ];
    for k=2:lP-1
      L = [ L prod(P(nchoosek(1:lP,k)),2)' ];
    end
    L = unique(L);
  end
   
  if rndold
    setround(rndold)
  end
