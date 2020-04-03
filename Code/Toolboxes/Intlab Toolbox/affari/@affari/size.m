function [m,n] = size(a,dim)
%SIZE         Affine arithmetic size
%

% written  12/06/13  S.M. Rump
%

  if nargin==1
    if nargout<=1
      m = size(a.mid);
    else
      [m,n] = size(a.mid);
    end
  else
    if nargout<=1
      m = size(a.mid,dim);
    else
      [m,n] = size(a.mid,dim);
    end
  end
  