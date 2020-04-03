function y = backward(U,b)
%BACKWARD     Backward substitution using upper triangular matrix U, generic routine
%
%   y = backward(U,b);
%
%U is assumed to be quadratic upper triangular and nonsingular. rhs b may be matrix
%
%Input U may be double, complex, intval, fl, affari, gradient or hessian.
%In either case the backward substitution is performed in the corresponding 
%arithmetic. 
%
%To solve a linear system with partial pivoting use  solvewpp(A,b).
%

% written  11/08/94   S.M. Rump
% modified 12/01/97   S.M. Rump   adapted for interval input
% modified 03/10/14   S.M. Rump   type adjustment
% modified 08/04/14   S.M. Rump   Octave bug
%

  global INTLAB_CONST

  n = dim(U);
  if INTLAB_CONST.OCTAVE
    b = typeadj(b,typeof(U));
  end

  if isa(U,'double')
    y = b;
  else
    eval(['y = ' class(U) '(b);'])
  end
  if isintval(U)
    y = intval(y);
  end

  y(n,:) = b(n,:) / U(n,n);
  for i=n-1:-1:1
    y(i,:) = ( b(i,:) - U(i,i+1:n)*y(i+1:n,:) ) / U(i,i);
  end
  