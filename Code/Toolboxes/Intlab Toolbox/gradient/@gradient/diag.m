function c = diag(a,k)
%DIAG         Implements  diag(a,k)  for gradients
%
%   c = diag(a,k)
%
% functionality as Matlab function diag for matrices
%

% written  10/16/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    accelaration for sparse input
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/04/14     S.M. Rump  affari added
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
% modified 12/09/15     S.M. Rump  prod(size) to numel
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST
  
  rndold = getround;
  if rndold
    setround(0)
  end

  if nargin==1
    k = 0;
  end

  c.x = diag(a.x,k);
  [m n] = size(a.x);
  if m==1 || n==1
    index = diag(ones(1,m*n),k);
    c.dx = zeros(numel(index),INTLAB_CONST.GRADIENT_NUMVAR);
    if isa(a.x,'intval')
      c.dx = intval(c.dx);
    elseif isa(a.x,'affari')
      c.dx = affari(c.dx);
    end
    c.dx(index~=0,:) = a.dx;
  else
    index = diag( reshape( 1:(m*n) , m , n ) , k );
    c.dx = a.dx( index(:) , : );
  end

  c = class(c,'gradient');
  
  if rndold
    setround(rndold)
  end
