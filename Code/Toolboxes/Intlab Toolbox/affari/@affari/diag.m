function c = diag(a,k)
%DIAG         Implements  diag(a,k)  for intervals
%
%   c = diag(a,k)
%
% functionality as Matlab function diag for matrices
%

% written  09/03/14     S.M. Rump
% modified 05/17/14     S.M. Rump  code optimization
% modified 05/17/14     S.M. Rump  All zero sparse: 1-by-1
% modified 12/09/15     S.M. Rump  prod(size) to numel
%

  if nargin==1
    k = 0;
  end

  c = a;
  [m n] = size(a.mid);
  
  if ( m==1 ) || ( n==1 )        % input vector, create matrix
    index = find(diag(reshape(1:m*n,m,n),k));
    c.mid = diag(a.mid,k);
    len = numel(c.mid);
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if nnz(a.err)
      c.err = sparse([],[],[],size(a.err,1),len);
      c.err(:,index) = a.err;
    else
      c.err = [];
    end
    if issparse(a.rnderr)
      c.rnderr = sparse([],[],[],1,len);
    else
      c.rnderr = zeros(1,len);
    end
    c.rnderr(index(:)') = a.rnderr;
    c.range = diag(a.range,k);
  else                          % input matrix, take diagonal
    index = diag(reshape(1:m*n,m,n),k);
    if isempty(index)
      c = affari([]);
    else
      c.mid = diag(a.mid,k);
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(a.err)
        c.err = a.err(:,index);
      else
        c.err = [];
      end
      c.rnderr = a.rnderr(index(:)');
      c.range = diag(a.range,k);
    end
  end
  