function c = typeadj(A,TYPE)
%TYPEADJ      typecast of  A  to type TYPE
%
%   c = typeadj(A,TYPE)
%
%For details, see intval\typeof and intval\typeadj.
%

% written  10/16/98     S.M. Rump
% modified 12/06/98     S.M. Rump
% modified 12/18/02     S.M. Rump  Hessians added
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 04/04/14     S.M. Rump  fl and affari added
%

% intval\@intval\typeadj:  a  must be intval
  switch TYPE
    case 'double',         c = mid(A);
    case 'intval',         c = A;
    case 'fl',             c = fl(mid(A));
    case 'flintval',       c = fl(A);
    case 'affari',         c = affari(A);
    case 'gradient',       c = gradient(mid(A));
    case 'gradientintval', c = gradient(A);
    case 'gradientaffari', c = gradient(affari(A));
    case 'hessian',        c = hessian(mid(A));
    case 'hessianintval',  c = hessian(A);
    case 'taylor',         c = taylor(mid(A));
    case 'taylorintval',   c = taylor(A);
    case 'slope',          c = slope(A);
    case 'polynom',        c = polynom(mid(A));
    case 'polynomintval',  c = polynom(A);
  otherwise
    error('invalid type in call of typeadj')
  end
