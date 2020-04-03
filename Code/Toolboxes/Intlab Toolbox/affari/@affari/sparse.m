function X = sparse(varargin)
%SPARSE       Type cast to sparse affari matrix
%
%   r = sparse(a)
%
%Call
%   Y = sparse(X)
%is simple type cast of X to sparse Y
%
%Call
%   Y = sparse(i,j,s,m,n,nzmax)
%has same functionality as Matlab/sparse for affari quantity s; 
%  produces sparse affari quantity Y.
%

% written  04/04/14  S.M. Rump
% modified 05/21/14  S.M. Rump  All zero sparse: 1-by-1
%

  if length(varargin)==1          % simple type cast
    X = varargin{1};
    X.mid = sparse(X.mid);
    X.rnderr = sparse(X.rnderr);
  else                            % Matlab functionality
    if length(varargin)==5
      [I J S m n] = deal(varargin{1:5});
    else
      [I J S] = deal(varargin{1:3});
      m = max(I);
      n = max(J);
    end
    X.mid = sparse(I,J,S.mid,m,n);
    index = find(reshape(sparse(I,J,1,m,n),1,m*n));
    K = size(S.err,1);
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if nnz(S.err)
      X.err = sparse([],[],[],K,m*n);
      X.err(:,index) = S.err;
    else
      X.err = sparse([]);
    end
    X.rnderr = sparse(1,index,S.rnderr,1,m*n);
    X.range = sparse(I,J,S.range,m,n);   
    X = class(X,'affari');
  end
  