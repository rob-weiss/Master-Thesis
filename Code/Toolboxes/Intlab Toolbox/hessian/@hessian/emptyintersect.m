function [empty,a] = emptyintersect(a,b)
%EMPTYINTERSECT    Compute intersection and check for empty components
%
%   [empty,c] = emptyintersect(a,b)
%
%Result c is that of intersect(a,b), and 
%  empty(i) = 1     intersection of a(i) and b(i) is empty
%                     or at least one of a(i) and b(i) is NaN
%             0     intersection of a(i) and b(i) is not empty
%
%Intersection is taken for a.x and b.x part, derivatives remain unchanged.
%Input a and b must be both real or both complex
%

% written  04/23/12   S.M. Rump  (Thanks to Kolumbán Sándor for pointing
%                                   to that missing function)
% modified 05/18/14   S.M. Rump  code optimization
% modified 08/01/14   S.M. Rump  Octave bug
% modified 07/17/14   S.M. Rump  NaN intersection
%

  global INTLAB_CONST

  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    if isaffari(a)
      a = intval(a);
    end
    if isaffari(b)
      b = intval(b);
    end
  end
        
  a = hessian(a);
  b = hessian(b);

  if isa(a.x,'intval') || isa(b.x,'intval')
    a = intval(a);
  end

  [empty,a.x] = emptyintersect(a.x,b.x);
  