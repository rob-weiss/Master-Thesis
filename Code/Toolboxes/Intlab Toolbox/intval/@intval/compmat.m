function res = compmat(A)
%COMPMAT      Comparison matrix for interval matrices
%
%   Ac = compmat(A)
%

% written  11/09/98     A. Neumaier
% modified 08/07/02     S.M. Rump    abss instead of abs
% modified 04/04/04     S.M. Rump    set round to nearest for safety
% modified 04/06/05     S.M. Rump    rounding unchanged
% modified 09/28/08     S.M. Rump    check for rounding to nearest improved
% modified 11/10/13     S.M. Rump    infinite elements
% modified 08/03/14     S.M. Rump    dimension check
% modified 05/15/14     S.M. Rump  code optimization
%

  [m n] = size(A);
  if m~=n
    error('Comparison matrix only for square matrices')
  end
  
  res = -mag(A);
  res(1:n+1:n*n) = mig(diag(A));  
