function c = typeadj(A,TYPE)
%TYPEADJ      typecast of  a  to type TYPE
%
%   c = typeadj(A,TYPE)
%
%For details, see intval\typeof and intval\typeadj.
%

% written  04/04/14     S.M. Rump
%

% gradient\@gradient\typeadj:  a  must be gradient (superior to intval)
  switch TYPE
    case 'double',         c = mid(A);
    case 'intval',         c = intval(A);
    case 'affari',         c = A;
    case 'gradient',       c = gradient(mid(A));
    case 'gradientintval', c = gradient(intval(A));
    case 'gradientaffari', c = gradient(A);
    case 'hessian',        c = hessian(mid(A));
    case 'hessianintval',  c = hessian(intval(A));
    case 'hessianaffari',  c = hessian(A);
    case 'taylor',         c = taylor(mid(A));
    case 'taylorintval',   c = taylor(intval(A));
    case 'tayloraffari',   c = taylor(A);
  otherwise
    error('invalid type in call of typeadj')
  end
