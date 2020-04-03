function c = prod(a,dim)
%PROD         Implements  prod(a,dim)  for Taylor
%
%   c = prod(a,dim)
%
% functionality as Matlab function prod for matrices, parameter dim optional
%

% written  05/21/09     S.M. Rump
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  rndold = getround;
  if rndold
    setround(0)
  end

  [m n] = size(a);
  if nargin==1,
    if m==1
      dim=2;
    else
      dim=1;
    end
  end

  if dim==1
    c = ones(1,n);
    for i=1:m
%VVVV c = c .* a(i,:);
      s.type = '()'; s.subs = {i,':'}; c = c .* subsref(a,s);
%AAAA Matlab V5.2 bug fix
    end
  else
    c = ones(m,1);
    for i=1:n
%VVVV c = c .* a(:,i);
      s.type = '()'; s.subs = {':',i}; c = c .* subsref(a,s);
%AAAA Matlab V5.2 bug fix
    end
  end
  
  if rndold
    setround(rndold)
  end
