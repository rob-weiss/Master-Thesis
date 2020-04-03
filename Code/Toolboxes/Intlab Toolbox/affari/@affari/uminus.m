function a = uminus(a)
%UMINUS       Affine arithmetic monadic minus  - a
%

% written  12/06/13  S.M. Rump
%

  a.mid = - a.mid;
  a.err = - a.err;
  a.range = - a.range;
  