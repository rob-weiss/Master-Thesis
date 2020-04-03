function c = abss(A)
%ABSS         Implements  abs(A)  for fl-type intervals, result real
%
%   c = abss(A)
%
%On return, abs(alpha) <= c for all alpha in A
%Obsolete, replaced by mag (thanks to Arnold for better naming).
%

% written  11/06/13     S.M. Rump
%

  c = mag(A);

