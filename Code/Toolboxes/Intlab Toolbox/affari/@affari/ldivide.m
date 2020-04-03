function r = ldivide(a,b)
%LDIVIDE      Hessian elementwise left division  a .\ b
%

% written  11/02/05     S.M. Rump  For Octave bug
%

  r = b ./ a;
