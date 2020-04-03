function a = rnderrintoerrterm(a,index)
%RNDERRINTOERRTERM  Put .rnderr into new error term and set .rnderr to zero for struct a
%
%   a = rnderrintoerrterm(a,index)
%
%Second paramater index optional, must be logical
%

% written  11/03/13     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/09/14     S.M. Rump  faster use of vertcat, thanks to M. Lange
% modified 05/21/14     S.M. Rump  All zero sparse: 1-by-1
% modified 12/09/15     S.M. Rump  prod(size) to numel
%

  global INTLAB_CONST

  % put rounding errors into error term
  N = INTLAB_CONST.AFFARI;
  if nargin==1              % all indices
    K = numel(a.mid);
    if any(a.rnderr(:))
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(a.err)
%         a.err(N+1:N+K,:) = spdiags(a.rnderr(:),0,K,K);
        v = 1:K;
        a.err = [ a.err ; sparse(N-size(a.err,1),K) ; sparse(v,v,a.rnderr(:),K,K) ];
      else
        a.err = sparse(N+1:N+K,1:K,a.rnderr,N+K,K);
      end
      a.rnderr = zeros(1,K);
      INTLAB_CONST.AFFARI = N+K;
    end
  else                      % selected indices
    index = index(:);
    if any(a.rnderr(index))
      K = nnz(index);
      M = numel(a.mid);
%       a.err(N+1:N+K,index) = spdiags(a.rnderr(index)',0,K,K);  
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(a.err)
        a.err = [ a.err ; sparse(N-size(a.err,1),M) ; sparse(1:K,find(index),a.rnderr(index),K,M) ];
      else
        a.err = [ sparse(N,M) ; sparse(1:K,find(index),a.rnderr(index),K,M) ];
      end
      a.rnderr(index) = zeros(1,K);
      INTLAB_CONST.AFFARI = N+K;
    end
  end

