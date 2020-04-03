function C = omitleadingzeros(C)
%OMITLEADINGZEROS  internal function for normalization
%

% written  12/30/98     S.M. Rump
% modified 11/15/04     S.M. Rump  exponent update for error
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
%

  % zero mantissa
  indexzero = all( C.mantissa==0 , 2 );

  index = ~indexzero & ( C.mantissa(:,1)==0 );
  while any(index)
    C.mantissa(index,:) = [ C.mantissa(index,2:end) zeros(sum(index),1) ];
    C.exponent(index) = C.exponent(index) - 1;
    index = index & ( C.mantissa(:,1)==0 );
  end

  C.exponent(indexzero) = -inf;
