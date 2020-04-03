function r = intersect(a,b)
%INTERSECT    Intersection of intervals; empty components set to NaN
%
%   r = intersect(a,b)
%

% written  08/03/14     S.M. Rump 
%

  r = intersect(intval(a),intval(b));
