function Z = max(X,Y,dim)
%MAX          Largest element for affaris
%
%Given affaris A,B are treated as intervals. Then the maximum is defined as
%  max(A,B) := { max(a,b) : a in A, b in B }
%The definition extends to the maximum of more than two intervals. Matlab's
%calling conventions
% 
%  Z = max(X)
%  Z = max(X,Y)
%  Z = max(Y,[],dim)
%
%are adopted; non-interval arguments are treated as point intervals. The
%result is always an interval quantity. Note that the index of maxima is
%not unique, so [Z,I]=max(X) makes no sense.
%

% written  03/11/14     S.M. Rump 
%

  if nargin==1
    Z = max(intval(X));
  elseif nargin==2
    Z = max(intval(X),intval(Y));
  else
    if isempty(Y)
      Z = max(intval(X),[],dim);
    else
      error('invalid call of affari max')
    end
  end
