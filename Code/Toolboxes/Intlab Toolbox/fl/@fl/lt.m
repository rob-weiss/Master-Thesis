function res = lt(A,B)
%LT           Implements fl-type  A < B  elementwise comparison
%

% written  10/21/13     S.M. Rump
%

  if isa(A,'fl')
    if isa(B,'fl')
      res = ( A.value<B.value );
    else
      res = ( A.value<B );
    end
  else
    res = ( A<B.value );
  end
