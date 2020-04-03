function Z = min(X,Y,dim)
%MIN          Smallest element for affaris
%
%Given affaris A,B are treated as intervals. Then the minimum is defined as
%  min(A,B) := { min(a,b) : a in A, b in B }
%The definition extends to the minimum of more than two intervals. Matlab's
%calling conventions
% 
%  Z = min(X)
%  Z = min(X,Y)
%  Z = min(Y,[],dim)
%
%are adopted; non-interval arguments are treated as point intervals. The
%result is always an interval quantity. Note that the index of minima is
%not unique, so [Z,I]=min(X) makes no sense.
%

% written  03/11/14     S.M. Rump
%

  if nargin==1
    Z = min(intval(X));
  elseif nargin==2
    Z = min(intval(X),intval(Y));
  else
    if isempty(Y)
      Z = min(intval(X),[],dim);
    else
      error('invalid call of affari min')
    end
  end
