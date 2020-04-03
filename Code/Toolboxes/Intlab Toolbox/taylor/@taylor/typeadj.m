function c = typeadj(A,TYPE)
%TYPEADJ      typecast of  A  to type TYPE
%
%   c = typeadj(A,TYPE)
%
%For details, see intval\typeof and intval\typeadj.
%

% written  05/22/09     S.M. Rump
% modified 04/04/14     S.M. Rump  affari added
%

% taylor\@taylor\typeadj:  a  must be taylor (superior to intval)
  switch TYPE
    case 'double',       c = mid(A);
    case 'taylor',       if isa(A.x,'intval')
                           c = taylor(mid(A)); 
                         else
                           c = A; 
                         end
    case 'taylorintval', c = intval(A);
    case 'affari',       c = affari(A);
    case 'tayloraffari', c = affari(A);
  otherwise
    error('invalid type in call of typeadj')
  end
