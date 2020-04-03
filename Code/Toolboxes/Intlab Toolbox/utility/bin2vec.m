function v = bin2vec(i,n)
%BIN2VEC      Convert integer into vector of bits
%
%  v = bin2vec(i,n);
%
%gives last n bits of binary representation of i
%on return,  i mod 2^n = sum(i=0..n-1, v(i)*2^i )
%

% written  10/29/97     S.M. Rump
% modified 12/26/00     S.M. Rump  improved performance

  v = dec2bin(i,n) - 48;           % double('0') = 48
  ll=length(v);
  if ll>n
    v = v(ll-n+1:ll);
  end