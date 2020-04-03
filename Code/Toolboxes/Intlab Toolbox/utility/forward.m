function y = forward(L,b)
%FORWARD      Forward substitution using lower triangular matrix L, generic routine
%
%   y = forward(L,b);
%
%L is assumed to be quadratic lower tringular and nonsingular. b may be matrix of rhs.
%
%Input L may be double, complex, intval, fl, affari, gradient or hessian.
%In either case the forward substitution is performed in the corresponding 
%arithmetic. 
%
%Diag(L) is NOT assumed to be 1's
%
%To solve a linear system with partial pivoting use  solvewpp(A,b).
%

% written  11/08/94   S.M. Rump
% modified 12/01/97   S.M. Rump   adapted for interval input
% modified 03/10/14   S.M. Rump   type adjustment
% modified 08/04/14   S.M. Rump   Octave bug
%

  global INTLAB_CONST

  n = dim(L);
  if INTLAB_CONST.OCTAVE
    b = typeadj(b,typeof(L));
  end

  if isa(L,'double')
    y = b;
  else
    eval(['y = ' class(L) '(b);'])
  end
  if isintval(L)
    y = intval(y);
  end

  y(1,:) = b(1,:) / L(1,1);
  for i=2:n
    y(i,:) = ( b(i,:) - L(i,1:i-1)*y(1:i-1,:) ) / L(i,i);
  end
  