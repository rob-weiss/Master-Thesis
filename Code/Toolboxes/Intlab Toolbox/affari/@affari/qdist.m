function c = qdist(a,b)
%QDIST        Implements  q(a,b)  metrical distance
%
%The name  qdist  is used to avoid ambiguities with variable  q
% 
%      res = qdist(a,b)
%

% written  03/08/14     S.M. Rump
% modified 05/17/14     S.M. Rump  code optimization
%

  if isempty(a) && isempty(b)
    c = 0;
  else
    c = qdist(intval(a),intval(b));
  end
