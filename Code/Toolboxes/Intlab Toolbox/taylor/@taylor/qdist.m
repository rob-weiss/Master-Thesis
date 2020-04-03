function res = qdist(a,b)
%QDIST        Implements  q(a,b)  metrical distance
%Name  qdist  is used to avoid ambiguities with variable  q
%This functions for non-interval input only for completeness
%
%   res = qdist(a,b)
%
%Compares a.x and b.x by qdist
%

% written  06/07/17     S.M. Rump
%

  if isa(a,'taylor')
    a = a.t';
  end
  if isa(b,'taylor')
    b = b.t';
  end

  res = qdist(a,b);
