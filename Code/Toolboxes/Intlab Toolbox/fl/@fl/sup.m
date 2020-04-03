function c = sup(A)
%SUP          Implements  sup(A)  for fl-type intervals
%
%   c = sup(A)
%
% On return, alpha <= sup(A) for all alpha in A; same as A.sup
%

% written  11/07/13     S.M. Rump
%

  if isa(A.value,'intval')
    c = A.value.sup;
  else
    c = A.value;
  end
