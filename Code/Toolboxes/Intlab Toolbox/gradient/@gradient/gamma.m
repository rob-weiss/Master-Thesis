function a = gamma(a)
%GAMMA        Gradient gamma function
%

% written  10/15/15     S.M. Rump
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
  ax = full(a.x);
  a.x = gamma(ax);
  ax = ax(:);
  ax = gamma(ax).*psi(ax);
  if issparse(a.dx)
    sizeax = size(a.dx,1);
    [ia,ja,sa] = find(a.dx);
    if isa(a.x,'intval')
      adx = times(ax(ia),sa,0);
      a.dx = intval( sparse(ia,ja,adx.inf,sizeax,N) , sparse(ia,ja,adx.sup,sizeax,N) , 'infsup' );
    else
      if isempty(ia)
        a.dx = sparse([],[],[],sizeax,N);
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
