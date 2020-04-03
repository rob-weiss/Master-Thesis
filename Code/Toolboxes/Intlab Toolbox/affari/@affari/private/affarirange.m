function r = affarirange(a)
%AFFARIRANGE  Interval range of given affari structure, assumes setround(1) !!
%
%   r = affarirange(a)
%

% written  11/03/13  S.M. Rump
% modified 05/21/14  S.M. Rump  All zero sparse: 1-by-1
%

  % take care of "All zero sparse: 1-by-1": do not use 'isempty'
  if nnz(a.err)
    E = reshape( sum(abs(a.err),1) + a.rnderr , size(a.mid) );
  else
    E = reshape(a.rnderr,size(a.mid));
  end
  
  if issparse(a.mid)
    r = midrad(a.mid,sparse(E));
  else
    r = midrad(a.mid,full(E));
  end
