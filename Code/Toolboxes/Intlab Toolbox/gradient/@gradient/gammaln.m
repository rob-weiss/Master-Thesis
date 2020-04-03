function a = gammaln(a)
%GAMMALN      Gradient log(gamma) function
%

% written  02/22/17     S.M. Rump
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
  a.x = gammaln(ax);
  ax = ax(:);
  ax = psi(ax);
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
