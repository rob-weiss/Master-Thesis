function v = gershgorin(A)
%GERSHGORIN   Complex interval vector containing eigenvalues of matrix A
%
%   v = Gershgorin(A)
%
% mid(v) = diag(mid(A)),  rad(v) computed by Gershgorin circles
%

% written  10/16/98     S.M. Rump
% modified 08/07/02     S.M. Rump  abss instead of abs
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 04/04/14     S.M. Rump  function name
% modified 07/30/16     S.M. Rump  rounding upwards 
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  rndold = getround;

  v.complex = 1;
  v.inf = [];
  v.sup = [];
  v.mid = mid(diag(A));
  setround(1)
  v.rad = sum( mag( A - diag(v.mid) ) , 2 );

  v = class(v,'intval');
  
  setround(rndold)
