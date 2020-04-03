function c = typeadj(A,TYPE)
%TYPEADJ      typecast of  A  to type TYPE
%
%   c = typeadj(A,TYPE)
%
%For details, see intval\typeof and intval\typeadj.
%

% written  12/06/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 04/04/14     S.M. Rump  type double
%

% slope\@slope\typeadj:  a  must be slope
  switch TYPE
    case 'double',         c = mid(A);
    case 'slope',          c = A;
  otherwise
    error('invalid type in call of typeadj')
  end
