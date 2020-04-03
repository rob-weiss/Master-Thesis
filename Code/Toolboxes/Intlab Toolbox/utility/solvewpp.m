function x = solvewpp(A,b)
%SOLVEWPP     Solution of square linear system by GE with partial pivoting, generic routine
%Solution of linear system using Gaussian elimination with partial pivoting
%
%    x = solvewpp(A,b);
%
%A is square, b may be matrix of right hand sides.
%Input A may be double, complex, intval, fl, affari, gradient or hessian.
%In either case the linear system is solved in the corresponding arithmetic. 
%

% written  09/25/94     S.M. Rump
% modified 12/01/97     S.M. Rump    adapted for interval input
% modified 07/02/09     S.M. Rump    multiple right hand side and interval input
% modified 08/04/14     S.M. Rump    Octave bug
%

  global INTLAB_CONST

  if INTLAB_CONST.OCTAVE
    b = typeadj(b,typeof(A));
  end

  [L,U,perm] = luwpp(A);

  y = forward(L,b(perm,:));
  x = backward(U,y);
