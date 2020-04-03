function R = inv(A)
%INV          Replaces built-in inv.m
%
%In recent Matlab releases the built-in inv.m is very inaccurate
%

% written  07/21/15  S.M. Rump
%

  [L U] = lu(A);
  R = builtin('inv',U)/L;
