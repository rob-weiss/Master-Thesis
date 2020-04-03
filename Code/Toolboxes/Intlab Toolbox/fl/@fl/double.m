function a = double(A)
%DOUBLE       Conversion and type cast for fl-type
%
%  d = double(A)
%
%converts the fl-quantity f into a double precision number. Since the set of
%fl-quantities is by definition a subset of the double precision numbers, the
%conversion is error-free.
%An fl-type interval is converted into an interval with double precision
%endpoints.
%

% written  10/17/13  S.M. Rump
%

  a = A.value;
  