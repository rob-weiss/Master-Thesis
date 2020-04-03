function c = typeadj(A,TYPE)
%TYPEADJ      typecast of  A  to type TYPE
%
%   c = typeadj(A,TYPE)
%
%Adjust type of  A  to be TYPE. For possible values of TYPE, see intval\typeof.
%Typical application:
%   c = typeadj(A,typeof(x));
%then  c = A  but with c being of type of x.
%Adjustment of c is as follows:
%
%    typeof(a)\TYPE  |    d     i     f      fi     a      g      gi      ga       h      hi     ha      s      p       pi     t     ti     ta
%  ----------------------------------------------------------------------------------------------------------------------------------------
%         d          |    *    i(A)  f(A)  f(i(A)) a(A)  g(A)   g(i(A)) g(a(A))   h(A)  h(i(A)) h(a(A)) s(A)   p(A)   p(i(A)) t(A) t(i(A))  t(a(A))
%         i          |   m(A)   *   f(m(A)) f(A)   a(A) g(m(A))  g(A)   g(a(A)) h(m(A))  h(A)   h(a(A)) s(A)  p(m(A))  p(A)  t(m(A)) t(A)   t(a(A)) 
%         f          |   d(A) i(d(A)) *     i(A)    -      -       -       -       -      -       -      -      -       -      -      -       -  
%         fi         | m(d(A)) d(A)  m(A)     *     -      -       -       -       -      -       -      -      -       -      -      -       -
%         a          |   m(A)  i(A)   -       -     *   g(m(A)) g(i(A))  g(A)      -      -       -      -      -       -      -      -       -  
%         g          |   m(A)   -     -       -     -      *     i(A)    a(A)      -      -       -      -      -       -      -      -       -
%         gi         |   m(A)   -     -       -     -     m(A)     *     a(A)      -      -       -      -      -       -      -      -       -
%         ga         |   m(A)   -     -       -     -     m(A)   i(A)      *       -      -       -      -      -       -      -      -       -
%         h          |   m(A)   -     -       -     -      -       -       -       *    h(i(A)) h(a(A))  -      -       -      -      -       -
%         hi         |   m(A)   -     -       -     -      -       -       -      m(A)    *     h(a(A))  -      -       -      -      -       -
%         ha         |   m(A)   -     -       -     -      -       -       -      m(A)  h(i(A))   *      -      -       -      -      -       -
%         s          |   m(A)   -     -       -     -      -       -       -       -      -       -      *      -       -      -      -       -       -
%         p          |   m(A)   -     -       -     -      -       -       -       -      -       -      -      *    p(i(A))   -      -       -
%         pi         |   m(A)   -     -       -     -      -       -       -       -      -       -     m(A)    -       *      -      -       -
%         t          |   m(A)   -     -       -     -      -       -       -       -      -       -      -       -      -      *     t(A)    a(A)
%         ti         |   m(A)   -     -       -     -      -       -       -       -      -       -      -       -      -      m(A)   *      a(A)
%         ta         |   m(A)   -     -       -     -      -       -       -       -      -       -      -       -      -      m(A)  t(A)     *
%
%with   *    c = A;
%      d(A)  double(A)
%      m(A)  mid(A)
%      f(A)  fl(A)
%      i(A)  intval(A)
%      a(A)  affari(A)
%      g(A)  gradient(A)
%      h(A)  hessian(A)
%      s(A)  slope(A)
%      p(A)  polynom(A)
%      t(A)  taylor(A)
%       -    not applicable (error)
%

% written  10/16/98     S.M. Rump
% modified 12/06/98     S.M. Rump
% modified 12/18/02     S.M. Rump  Hessians added
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 05/22/09     S.M. Rump  taylor added
% modified 04/04/14     S.M. Rump  fl and affari added
%

% intval\typeadj:  a  must be double
  switch TYPE
    case 'double',         c = A;
    case 'intval',         c = intval(A);
    case 'fl',             c = fl(A);
    case 'flintval',       c = fl(intval(A));
    case 'affari',         c = affari(A);
    case 'gradient',       c = gradient(A);
    case 'gradientintval', c = gradient(intval(A));
    case 'gradientaffari', c = gradient(affari(A));
    case 'hessian',        c = hessian(A);
    case 'hessianintval',  c = hessian(intval(A));
    case 'hessianaffari',  c = hessian(affari(A));
    case 'slope',          c = slope(A);
    case 'polynom',        c = polynom(A);
    case 'polynomintval',  c = polynom(intval(A));
    case 'taylor',         c = taylor(A);
    case 'taylorintval',   c = taylor(intval(A));
    case 'tayloraffari',   c = taylor(affari(A));
  otherwise
    error('invalid type in call of typeadj')
  end
  