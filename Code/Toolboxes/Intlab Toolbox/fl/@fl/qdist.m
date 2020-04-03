function res = qdist(A,B)
%QDIST        Implements  q(A,B)  metrical distance for fl-type
%  name  qdist  is used to avoid ambiguities with variable  q
%
%     res = qdist(A,B)          max( abs(inf(A)-inf(B)) , abs(sup(A)-sup(B)) )
%

% written  11/06/13     S.M. Rump
%

  if isa(A,'fl')
    if isa(B,'fl')
      res = qdist(A.value,B.value);
    else
      res = qdist(A.value,B);
    end
  else
    res = qdist(A,B.value);
  end
