function a = erfc(a)
%ERFC         Gradient complementary error function erfc(a)
%

% written  05/31/13     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/01/14     S.M. Rump  affari added
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST
  
  rndold = getround;
  if rndold
    setround(0)
  end

  N = INTLAB_CONST.GRADIENT_NUMVAR;
  % factorLB <= 2/sqrt(pi) <= factorUB
  INTLAB_STDFCTS_ERF = INTLAB_CONST.STDFCTS_ERF;
  factorLB = INTLAB_STDFCTS_ERF.TWO_SQRTPIINF;  % round to nearest
  factorUB = INTLAB_STDFCTS_ERF.TWO_SQRTPISUP;  % ~ 1.12

  % use full(a.x(:)): cures Matlab V6.0 bug
  % a=7; i=[1 1]; x=a(i), b=sparse(a); y=b(i)  yields row vector x but column vector y
  % ax is full anyway
  a.x = full(a.x);
  ax = exp(-a.x(:).^2);
  a.x = erfc(a.x);
  if issparse(a.dx)
    sizeax = size(a.dx,1);
    [ia,ja,sa] = find(a.dx);
    if isa(a.x,'intval')
      adx = times(ax(ia),sa,0);
      a.dx = intval(-factorUB,-factorLB,'infsup') * ...
          intval( sparse(ia,ja,adx.inf,sizeax,N) , sparse(ia,ja,adx.sup,sizeax,N) , 'infsup' );
    else
      if isempty(ia)
        a.dx = sparse([],[],[],sizeax,N);
        if isa(a.x,'affari')
          a.dx = affari(a.dx);
        end
      else
        a.dx = (-factorLB) * sparse(ia,ja,ax(ia).*sa,sizeax,N);
      end
    end
  else
    if isa(a.x,'intval')
      ax = intval(-factorUB,-factorLB,'infsup') * ax;
      a.dx = a.dx .* ax(:,ones(1,N));
    else
      ax = (-factorLB) * ax;
      a.dx = a.dx .* ax(:,ones(1,N));
    end
  end
  
  if rndold
    setround(rndold)
  end
