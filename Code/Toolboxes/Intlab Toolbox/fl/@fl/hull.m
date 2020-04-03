function A = hull(varargin)
%HULL         fl-type interval hull
%
%   X = hull(A,B,C,...);
%

% written  11/06/13     S.M. Rump
%

  A = varargin{1};

  if nargin==2
    B = varargin{2};
    if isa(A,'fl')
      if isa(B,'fl')
        A = hull(A.value,B.value);
      else
        A = hull(A.value,B);
      end
    else
      A = hull(A,B.value);
    end
    A = fl(A);
  elseif nargin>2
    for i=2:length(varargin)
      A = hull(A,fl(varargin{i}));
    end
  end
  