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

  if isa(a,'gradient')
    a = a.x;
  end
  if isa(b,'gradient')
    b = b.x;
  end

  res = qdist(a,b);
