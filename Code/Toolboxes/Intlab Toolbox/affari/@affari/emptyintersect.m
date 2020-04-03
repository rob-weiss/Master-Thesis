function [empty,c] = emptyintersect(a,b)
%EMPTYINTERSECT    Compute intersection and check for empty components
%
%   [empty,c] = emptyintersect(a,b)
%
%Result c is that of intersect(a,b), and 
%  empty(i) = 1     intersection of a(i) and b(i) is empty
%             0     intersection of a(i) and b(i) is not empty
%             NaN   at least one of a(i) and b(i) is NaN
%
%Input a and b must be both real or both complex
%

% written  09/03/14     S.M. Rump
%

  [empty,c] = emptyintersect(intval(a),intval(b));
