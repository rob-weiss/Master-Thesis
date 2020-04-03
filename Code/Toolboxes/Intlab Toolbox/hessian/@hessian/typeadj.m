function c = typeadj(A,TYPE)
%TYPEADJ      typecast of  A  to type TYPE
%
%   c = typeadj(A,TYPE)
%
%For details, see intval\typeof and intval\typeadj.
%

% written  04/04/04     S.M. Rump
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 04/04/14     S.M. Rump  affari added
%

% hessian\@hessian\typeadj:  input  a  must be hessian (superior to intval)
  switch TYPE
    case 'double',        c = mid(A);
    case 'hessian',       if isa(A.x,'intval')
                            c = hessian(mid(A)); 
                          else
                            c = A; 
                          end
    case 'hessianintval', c = intval(A);
    case 'affari',        c = affari(A);
    case 'hessianaffari', c = affari(A);
  otherwise
    error('invalid type in call of typeadj')
  end
