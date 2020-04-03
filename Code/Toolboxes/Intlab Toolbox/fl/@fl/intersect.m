function C = intersect(A,B)
%INTERSECT    Intersection of intervals; empty components are set to NaN
%
%   C = intersect(A,B)
%
%For details, see intval/intersect
%

% written  11/06/13     S.M. Rump
%

  [empty,C] = emptyintersect(A,B);
