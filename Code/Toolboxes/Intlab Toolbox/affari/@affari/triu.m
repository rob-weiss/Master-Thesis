function a = triu(a,k)
%TRIU         Implements  triu(a,k)  for affaris
%
%   c = triu(a,k)
%
% functionality as Matlab function triu for matrices
%

% written  08/09/02     S.M. Rump 
% modified 05/21/21     S.M. Rump  All zero sparse: 1-by-1
%

  if nargin==1
    k = 0;
  end

  a.mid = triu(a.mid,k);
  index = ( triu( ones(size(a.mid)) , k ) == 0 );
  % take care of "All zero sparse: 1-by-1": do not use 'isempty'
  if nnz(a.err)
    a.err(:,index) = 0;
  end
  a.rnderr(index) = 0;
  a.range = triu(a.range,k);
  