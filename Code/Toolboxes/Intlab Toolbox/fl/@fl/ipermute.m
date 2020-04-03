function A = ipermute(A,order)
%IPERMUTE     Inverse permute array dimensions for fl-type
%
%Implements the Matlab function "ipermute", similar syntax and semantics
%

% written  11/06/13     S.M. Rump
%

  A.value = ipermute(A.value,order);
