function Z = min(X,Y,dim)
%MIN          Smallest element for real intervals
%
%For a given intervals A,B, the minimum is defined as
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

% written  03/11/14     S.M. Rump  Thanks to David Hait for pointing to that missing function
%

  if nargin==3              % call min(X,[],dim)
    if ~isempty(Y)
      error('invalid call of intval min')
    end
    if X.complex
      error('intval minimum only for real quantities')
    end
    Z = intval(min(inf_(X),[],dim),min(sup(X),[],dim),'infsup');
  elseif nargin==2          % call min(X,Y)
    if isa(X,'intval')
      if X.complex
        error('intval minimum only for real quantities')
      end
      if isa(Y,'intval')    % both X and Y interval quantities
        if X.complex
          error('intval minimum only for real quantities')
        end
        Z = intval(min(inf_(X),inf_(Y)),min(sup(X),sup(Y)),'infsup');
      else                  % X is interval, Y is not
        if ~isreal(Y)
          error('intval minimum only for real quantities')
        end
        Z = intval(min(inf_(X),Y),min(sup(X),Y),'infsup');
      end
    else                    % X is not interval, Y must be interval
      if ~isreal(X)
        error('intval minimum only for real quantities')
      end
      if Y.complex
        error('intval minimum only for real quantities')
      end
      Z = intval(min(X,inf_(Y)),min(X,sup(Y)),'infsup');
    end
  else                      % call min(X)
    if X.complex
      error('intval minimum only for real quantities')
    end
    Z = intval(min(inf_(X)),min(sup(X)),'infsup');
  end
  