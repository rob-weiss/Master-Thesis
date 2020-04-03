function A = prod(A,dim)
%PROD         Implements  prod(a,dim)  for fl-type
%
%   c = prod(a,dim)
%
% functionality as Matlab function prod for matrices, parameter dim optional
%

% written  10/21/13     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
%

  global INTLAB_CONST

  const = INTLAB_CONST.FL_CONST;        % initialize constants
  [m,n] = size(A.value);

  if nargin==1,
    if m==1
      dim=2;
    else
      dim=1;
    end
  end
  
  if dim==1
    P = A.value(1,:);
    for i=2:m
      P = flround(P.*A.value(i,:),const.prec,const.expBias);
    end
  else
    P = A.value(:,1);
    for i=2:n
      P = flround(P.*A.value(:,i),const.prec,const.expBias);
    end   
  end
    
  A.value = P;
  