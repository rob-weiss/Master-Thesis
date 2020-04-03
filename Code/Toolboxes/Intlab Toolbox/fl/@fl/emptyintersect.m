function [empty,c] = emptyintersect(A,B)
%EMPTYINTERSECT    Compute intersection and check for empty components
%
%   [empty,C] = emptyintersect(A,B)
%
%For details, see intval/emptyintersect
%

% written  11/06/13     S.M. Rump
%

  if isa(A,'fl')
    if isa(B,'fl')
      [empty,c] = emptyintersect(A.value,B.value);
    else
      [empty,c] = emptyintersect(A.value,B);
    end
  else
    [empty,c] = emptyintersect(A,B.value);
  end
  c = fl(c);
  