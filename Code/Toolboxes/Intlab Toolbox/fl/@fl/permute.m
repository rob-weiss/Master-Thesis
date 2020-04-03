function A = permute(A,order)
%PERMUTE      Permute array dimensions
%
%Implements the Matlab function "permute", similar syntax and semantics
%

% written  11/06/13     S.M. Rump
%

  A.value = permute(A.value,order);
