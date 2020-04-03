function c = trace(a)
%TRACE        Implements  trace(a)  for affari matrices
%
%   c = trace(a)
%

% written  08/09/02     S.M. Rump 
%
  
  c = sum( diag( a ) );
  