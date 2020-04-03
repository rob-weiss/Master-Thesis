function c = diag(a,k)
%DIAG         Implements  diag(a,k)  for hessians
%
%   c = diag(a,k)
%
% functionality as Matlab function diag for matrices
%

% written  04/04/04     S.M. Rump
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/04/14     S.M. Rump  affari added
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
% modified 12/09/15     S.M. Rump  prod(size) to numel
%

  global INTLAB_CONST
  

  INTLAB_HESSIAN_NUMVAR = INTLAB_CONST.HESSIAN_NUMVAR;

  if nargin==1
    k = 0;
  end

  [m n] = size(a.x);
  c.x = diag(a.x,k);
  if m==1 || n==1
    index = diag(ones(1,m*n),k);
    if issparse(a.hx)
      c.dx = sparse([],[],[],INTLAB_HESSIAN_NUMVAR,numel(index),0);
      c.hx = sparse([],[],[],INTLAB_HESSIAN_NUMVAR^2,numel(index),0);
    else
      c.dx = zeros(INTLAB_HESSIAN_NUMVAR,numel(index));
      c.hx = zeros(INTLAB_HESSIAN_NUMVAR^2,numel(index));
    end
    if isa(a.x,'intval')
      c.dx = intval(c.dx);
      c.hx = intval(c.hx);
    elseif isa(a.x,'affari')
      c.dx = affari(c.dx);
      c.hx = affari(c.hx);
    end
    c.dx(:,index~=0) = a.dx;
    c.hx(:,index~=0) = a.hx;
  else
    index = diag( reshape( 1:(m*n) , m , n ) , k );
    c.dx = a.dx(:,index(:));
    c.hx = a.hx(:,index(:));
  end

  c = class(c,'hessian');
  