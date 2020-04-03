function c = typeadj(A,TYPE)
%TYPEADJ      typecast of  A  to type TYPE
%
%   c = typeadj(A,TYPE)
%
%For details, see intval\typeof and intval\typeadj.
%

% written  04/04/14     S.M. Rump

%

% intval\@intval\typeadj:  a  must be intval
  switch TYPE
    case 'double',         c = mid(double(A));
    case 'intval',         c = intval(double(A));
    case 'fl',             c = mid(A);
    case 'flintval',       c = intval(A);
  otherwise
    error('invalid type in call of typeadj')
  end
