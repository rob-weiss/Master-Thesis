function A = compmat(A)
%COMPMAT      Ostrowski's comparison matrix for fl-type matrices
%
%   Ac = compmat(A)
%

% written  10/21/13     S.M. Rump
% modified 05/18/14     S.M. Rump  code optimization
%

  [m n] = size(A.value);
  if m~=n
    error('Comparison matrix only for square matrices')
  end
  
  A = compmat(A.value);
