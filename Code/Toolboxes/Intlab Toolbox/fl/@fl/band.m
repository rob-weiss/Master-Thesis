function A = band(A,p,q)
%BAND         Extract band from fl-type matrix A, lower bandwidth p, upper bandwidth q
%   if parameter q is omitted, q:=p
%
%   A = band(A,p,q)
%

% written  10/21/13    S.M. Rump
% modified 05/17/05    S.M. Rump  take care of Octave
%

  global INTLAB_CONST

  if nargin<3
    q = p;
  end

  if INTLAB_CONST.OCTAVE
    [m n] = size(A.value);
    p = min(max(-p,m),n);
    q = min(max(-q,m),n);
  end
  
  A.value = tril(triu(A.value,-p),q);
  