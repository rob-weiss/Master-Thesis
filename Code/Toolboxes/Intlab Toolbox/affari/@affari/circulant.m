function A = circulant(c)
%CIRCULANT    Implements  circulant(c)  for affaris
%
%   A = circulant(c)
%
% functionality as INTLAB/intval function circulant
%

% written  04/04/14     S.M. Rump 
% modified 05/21/14     S.M. Rump  All zero sparse: 1-by-1
%
  
  m = length(c);
  index = circulant(1:m);
  A.mid = circulant(c.mid);
  % take care of "All zero sparse: 1-by-1": do not use 'isempty'
  if nnz(c.err)
    A.err = c.err(:,index);
  else
    A.err = [];
  end
  A.rnderr = c.rnderr(index(:)');
  A.range = circulant(c.range);
  
  A = class(A,'affari');
