function r = abs(a,see)
%ABS          Affine arithmetic elementwise absolute value  abs(a)
%
%For scalar affari interval a, 
%
%  y = abs(a,1)
%
%plots the function together with its affine approximation.
%

% written  04/04/14     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/09/14     S.M. Rump  index access
% modified 05/17/14     S.M. Rump  code optimization
% modified 05/21/14     S.M. Rump  All zero sparse: 1-by-1
% modified 12/09/15     S.M. Rump  prod(size) to numel(s)
%

  global INTLAB_CONST
  
  if nargin==1
    see = 0;
  end
  
  % change sgn of negative components
  index = find( sup(a.range)<0 );           % negative components: (-a)^2=a^2
  if any(index)
    a = setvalueindex(a,index,-1);
    neg = 1;                                % only for show
  else
    neg = 0;
  end
  A = a.range;
  
  r = struct(a);
  rndold = getround;                        % save rounding mode
  index = find( inf(A)<0 ) ;                % zero components
  index = index(:);
  
  if any(index)                             % treat zero components
    X = A(index);
    % min-range approximation also if chebyshev-approx desired
    fX = abs(X);                            % f(X)
    % min-range approximation mid(f(X)) +/- rad(f(X))
    if see && ( numels(X)==1 )
      showgraph('abs(x)',0,mid(fX),rad(fX),X)
    end
    r.mid(index) = mid(fX);
    % put errors into new error terms
    % put errors into new error terms
    K = length(index);                % a.err cannot be empty
    MN = numel(r.mid);
    N = INTLAB_CONST.AFFARI;
    %       r.err(N+1:N+K,index) = spdiags(rad(fX(:)),0,K,K);
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if nnz(r.err)
      r.err(:,index) = 0;
      r.err = [ r.err ; sparse(N-size(r.err,1),MN) ; sparse(1:K,index,rad(fX(:)),K,MN) ];
    else
      r.err = [ sparse(N,MN) ; sparse(1:K,index,rad(fX(:)),K,MN) ];
    end
    INTLAB_CONST.AFFARI = N+K;
    r.rnderr(index) = 0;
    r.range(index) = fX;
  else
    if see && ( numels(a.range)==1 )
      if neg
        showgraph('abs(x)',-1,0,0,-A)
      else
        showgraph('abs(x)',1,0,0,A)
      end
    end
  end
  
  % no extra error term for rounding error
%   if INTLAB_CONST.AFFARI_ROUNDINGERRORS
%     r = rnderrintoerrterm(r);
%   end
  
  % improve range
  setround(1)
  r = intersectNaN( r , abs(a.range) );
  setround(rndold)
  
  r = class(r,'affari');
