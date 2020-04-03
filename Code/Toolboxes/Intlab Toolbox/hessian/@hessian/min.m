function [X,I] = min(X,Y,dim)
%MIN          Smallest element for non-interval hessians
%
%Calling conventions are as in Matlab, i.e.
%
%   min(X)
%   [Z,I] = min(X)
%   [Z,I] = min(X,[],dim)
%   Z = min(X,Y)
%
%The minimum is taken based on the .x components of hessians. For min(X,Y)
%one parameter may be scalar. The result is a hessian quantity.
%
%For intval (non-hessian) quantities the minimum is defined as
%  min(A,B) := { min(a,b) : a in A, b in B }
%Since the indices of the minimum is not unique, min for interval hessians 
%makes no sense.
%

% written  04/04/14     S.M. Rump 
% modified 05/18/14     S.M. Rump  code optimization
%

  if isintval(X) || isaffari(X)
    error('min not for interval or affari hessians')
  end
  
  if nargin>=2
    if isintval(Y) || isaffari(Y)
      error('min not for interval or affari hessians')
    end
  end
  
  if nargin==3
    if ~isempty(Y)
      error('invalid call')
    end
  end
  
  if nargin==2              % Z = min(X,Y)    
    sX = size(X);
    sY = size(Y);
    if ~isequal(sX,sY)
      if prod(sX)==1
        X = repmat(X,sY);
        sX = sY;
      elseif prod(sY)==1
        Y = repmat(Y,sX);
      else
        error('size not compatible')
      end
    end
    %VVVV  Z = [ X(:) Y(:) ];
    s.type = '()'; s.subs = {':'}; Z = [ subsref(X,s) subsref(Y,s) ];
    %AAAA  Matlab bug fix
    [dummy,I] = min(Z.x,[],2);
    K = prod(sX); 
    index = (1:K)'+(I-1)*K;
    %VVVV  X = Z(I);
    s.type = '()'; s.subs = {index}; X = subsref(Z,s);
    %AAAA  Matlab bug fix
    X = reshape(X,sX);
  else                      % [Z,I] = min(X)  or  [Z,I] = min(X,[],dim)
    [m,n] = size(X.x);
    if nargin==1
      [dummy,I] = min(X.x);
      if m==1
        %VVVV  X = X(I);
        s.type = '()'; s.subs = {I}; X = subsref(X,s);
        %AAAA  Matlab bug fix
      else
        index = I + (0:n-1)*m;
        %VVVV  X = X(index);
        s.type = '()'; s.subs = {index}; X = subsref(X,s);
        %AAAA  Matlab bug fix
      end
    else                        % nargin==3
      [dummy,I] = min(X.x,[],dim);
      if dim==1
        index = I + (0:n-1)*m;
      else
        index = (I-1)*m + (1:m)';
      end
      %VVVV  X = X(index);
      s.type = '()'; s.subs = {index}; X = subsref(X,s);
      %AAAA  Matlab bug fix
    end
  end
  