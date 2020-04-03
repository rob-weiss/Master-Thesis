function [Z,I] = min(X,Y,dim)
%MIN          Smallest component, same functionality as Matlab's min
%
%The calls are as usual
%
%  min(X)
%  Y = min(X)
%  min(X,Y)
%  Y = min(X,[],DIM)
%
%However, calls with two output arguments
%
%  [Y,I] = min(X)
%
%are only allowe for non-interval X, see intval/min.
%

% written  03/11/14     S.M. Rump
% modified 05/18/14     S.M. Rump  code optimization
% modified 08/04/14     S.M. Rump  nargin==2
%

  if nargin==3                      % call min(X,[],DIM)
    if isempty(Y)           
      if isintval(X)                % X is intval
        if nargout==2
          error('Two output arguments only for non-interval input')
        else
          Z = min(double(X),[],dim);
        end
      else                          % X is not intval
        if nargout==2
          [Z,I] = min(double(X),[],dim);
        else
          Z = min(double(X),[],dim);
        end
      end
    else                            % Y is not empty
      error('invalid call')
    end
  elseif nargin==2                  % call min(X,Y)
    if nargout==2
      [Z,I] = min(double(X),double(Y))
    else
      Z = min(double(X),double(Y));
    end
  else                              % call min(X)
    if isintval(X)              	% X is intval
      if nargout==2
        error('Two output arguments only for non-interval input')
      else
        Z = min(double(X));
      end
    else                            % X is not intval
      if nargout==2
        [Z,I] = min(double(X));
      else
        Z = min(double(X));
      end
    end
  end  
  
  Z = fl(Z);            % no rounding error
  