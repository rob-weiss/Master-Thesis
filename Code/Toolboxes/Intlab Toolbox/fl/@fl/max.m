function [Z,I] = max(X,Y,dim)
%MAX          Largest component, same functionality as Matlab's max
%
%The calls are as usual
%
%  max(X)
%  Y = max(X)
%  max(X,Y)
%  Y = max(X,[],DIM)
%
%However, calls with two output arguments
%
%  [Y,I] = max(X)
%
%are only allowe for non-interval X, see intval/max.
%

% written  03/11/14     S.M. Rump
% modified 05/18/14     S.M. Rump  code optimization
% modified 08/04/14     S.M. Rump  nargin==2
%

  if nargin==3                      % call max(X,[],DIM)
    if isempty(Y)           
      if isintval(X)                % X is intval
        if nargout==2
          error('Two output arguments only for non-interval input')
        else
          Z = max(double(X),[],dim);
        end
      else                          % X is not intval
        if nargout==2
          [Z,I] = max(double(X),[],dim);
        else
          Z = max(double(X),[],dim);
        end
      end
    else                            % Y is not empty
      error('invalid call')
    end
  elseif nargin==2                  % call max(X,Y)
    if nargout==2
      [Z,I] = max(double(X),double(Y))
    else
      Z = max(double(X),double(Y));
    end
  else                              % call max(X)
    if isintval(X)              	% X is intval
      if nargout==2
        error('Two output arguments only for non-interval input')
      else
        Z = max(double(X));
      end
    else                            % X is not intval
      if nargout==2
        [Z,I] = max(double(X));
      else
        Z = max(double(X));
      end
    end
  end  
  
  Z = fl(Z);            % no rounding error
  