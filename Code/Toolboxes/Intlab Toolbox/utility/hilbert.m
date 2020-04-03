function [A,c] = hilbert(n)
%HILBERT      Hilbert matrix with integer entries (exact for n<=21)
%
%   A = hilbert(n)
%
%or, if n<=21,
%
%   [A,c] = hilbert(n)
%
%to give also back 1-norm condition number (computed in Maple).
%

% written   07/13/94     S.M. Rump
% modified  03/33/03     S.M. Rump  condition number added
%

  A = round( lcmvec(1:2*n-1) * hilb(n) );
  if nargout==2
    if n<=21
      cond = [ 1.000000000000000e+00
               1.928147006790397e+01
               5.240567775860608e+02
               1.551373873893259e+04
               4.766072502425608e+05
               1.495105864013122e+07
               4.753673549881790e+08
               1.525757574164694e+10
               4.931549269715421e+11
               1.602628687021688e+13
               5.230677392429409e+14
               1.713228904697005e+16
               5.627942373760077e+17
               1.853381702347150e+19
               6.116565791619846e+20
               2.022345917674599e+22
               6.697438980557683e+23
               2.221190039477931e+25
               7.375951174004724e+26
               2.452156525724467e+28
               8.160691354161008e+29 ];
      c = cond(n);
    else
      error('condition number only for dimension not greater than 21.')
    end
  end

