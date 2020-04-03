function a = asin(a)
%ASIN         Gradient inverse sine asin(a)
%

% written  10/16/98     S.M. Rump
% modified 10/14/00     S.M. Rump  use Tony's trick
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    accelaration for sparse input
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/20/05     S.M. Rump  faster check for rounding to nearest
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 10/08/08     S.M. Rump  improved sparse multiplication: not using intval data type
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/18/14     S.M. Rump  empty .dx
% modified 04/04/14     S.M. Rump  affari added
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST
  
  rndold = getround;
  if rndold
    setround(0)
  end

  N = INTLAB_CONST.GRADIENT_NUMVAR;

  % use full(a.x(:)): cures Matlab V6.0 bug
  % a=7; i=[1 1]; x=a(i), b=sparse(a); y=b(i)  yields row vector x but column vector y
  % ax is full anyway
  ax = 1 ./ sqrt( 1 - sqr(full(a.x(:))) );
  a.x = asin(a.x);
  if issparse(a.dx)
    sizeax = size(a.dx,1);
    [ia,ja,sa] = find(a.dx);
    if isa(a.x,'intval')
      adx = times(ax(ia),sa,0);
      if adx.complex
        a.dx = intval( sparse(ia,ja,adx.mid,sizeax,N) , sparse(ia,ja,adx.rad,sizeax,N) , 'midrad' );
      else
        a.dx = intval( sparse(ia,ja,adx.inf,sizeax,N) , sparse(ia,ja,adx.sup,sizeax,N) , 'infsup' );
      end
    else
      if isempty(ia)
        a.dx = sparse([],[],[],sizeax,N);
        if isa(a.x,'affari')
          a.dx = affari(a.dx);
        end
      else
        a.dx = sparse(ia,ja,ax(ia).*sa,sizeax,N);
      end
    end
  else
    a.dx = a.dx .* ax(:,ones(1,N));
  end

  if rndold  
    setround(rndold)
  end
