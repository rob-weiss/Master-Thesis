function v = base2vec(i,b,n)
%BASE2VEC     Convert integer into vector of digits to base b
%
%  v = base2vec(i,b,n);
%
%gives last n digits of base b representation of i
%on return,  i mod b^n = sum(i=0..n-1, v(i)*b^i )
%

% written  10/29/97     S.M. Rump
% modified 11/07/97     S.M. Rump
% modified 12/26/00     S.M. Rump  improved performance

  v = dec2base(i,b,n) - 48;        % double('0') = 48
  ll=length(v);
  if ll>n
    v = v(ll-n+1:ll);
  end