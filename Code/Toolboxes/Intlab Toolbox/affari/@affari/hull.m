function r = hull(varargin)
%HULL         interval hull
%
%   r = hull(a,b,c,...);
%
% variable parameter list
%

% written  08/03/14     S.M. Rump 
%

  len = length(varargin);
  if len==2
    r = hull(intval(varargin{1}),intval(varargin{2}));  % calls intval function hull
  elseif len>2
    r = intval(varargin{1});
    for i=2:len
      r = hull(r,intval(varargin{i}));          % calls intval function hull
    end
  elseif len==1
    r = intval(varargin(1));
  else
    error('hull called without parameter')
  end
    