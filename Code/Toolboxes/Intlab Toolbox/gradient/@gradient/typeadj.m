function c = typeadj(A,TYPE)
%TYPEADJ      typecast of  a  to type TYPE
%
%   c = typeadj(A,TYPE)
%
%For details, see intval\typeof and intval\typeadj.
%

% written  10/16/98     S.M. Rump
% written  12/06/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 04/04/14     S.M. Rump  affari added
%

% gradient\@gradient\typeadj:  a  must be gradient (superior to intval)
  switch TYPE
    case 'double',         c = mid(A);
    case 'gradient',       if isa(A.x,'intval')
                             c = gradient(mid(A)); 
                           else
                             c = A; 
                           end
    case 'gradientintval', c = intval(A);
    case 'affari',         c = affari(A);
    case 'gradientaffari', c = affari(A);
  otherwise
    error('invalid type in call of typeadj')
  end
