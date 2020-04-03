function A = mag(A)
%MAG          Absolute value for fl-type, result double also for interval input
%
%  d = mag(f)
%
%Same functionality as mag for intervals.
%

% written  10/21/13  S.M. Rump
%

  A = mag(A.value);

  