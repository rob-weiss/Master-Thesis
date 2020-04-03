function Z = max(X,Y,dim)
%MAX          Largest element for real intervals
%
%For a given intervals A,B, the maximum is defined as
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

% written  03/11/14     S.M. Rump  Thanks to David Hait for pointing to that missing function
%

  if nargin==3              % call max(X,[],dim)
    if ~isempty(Y)
      error('invalid call of intval max')
    end
    if X.complex
      error('intval maximum only for real quantities')
    end
    Z = intval(max(inf_(X),[],dim),max(sup(X),[],dim),'infsup');
  elseif nargin==2          % call max(X,Y)
    if isa(X,'intval')
      if X.complex
        error('intval maximum only for real quantities')
      end
      if isa(Y,'intval')    % both X and Y interval quantities
        if X.complex
          error('intval maximum only for real quantities')
        end
        Z = intval(max(inf_(X),inf_(Y)),max(sup(X),sup(Y)),'infsup');
      else                  % X is interval, Y is not
        if ~isreal(Y)
          error('intval maximum only for real quantities')
        end
        Z = intval(max(inf_(X),Y),max(sup(X),Y),'infsup');
      end
    else                    % X is not interval, Y must be interval
      if ~isreal(X)
        error('intval maximum only for real quantities')
      end
      if Y.complex
        error('intval maximum only for real quantities')
      end
      Z = intval(max(X,inf_(Y)),max(X,sup(Y)),'infsup');
    end
  else                      % call max(X)
    if X.complex
      error('intval maximum only for real quantities')
    end
    Z = intval(max(inf_(X)),max(sup(X)),'infsup');
  end
  