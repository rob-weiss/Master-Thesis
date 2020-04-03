function spy(A)
%SPY          Spy fl-type matrix
%
%   spy(A)
%

% written  11/07/13     S.M. Rump
%

  if isa(A.value,'intval')
    spy(mag(double(A)))
  else
    spy(double(A))
  end
