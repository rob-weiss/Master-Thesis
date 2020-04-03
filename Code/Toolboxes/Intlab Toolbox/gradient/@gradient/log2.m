function a = log2(a)
%LOG2         Gradient logarithm  log2(a)
%

% written  04/04/14     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST
  
  rndold = getround;
  if rndold
    setround(0)
  end

  N = INTLAB_CONST.GRADIENT_NUMVAR;

  wng = warning;
  warning off

  % use full(a.x(:)): cures Matlab V6.0 bug
  % a=7; i=[1 1]; x=a(i), b=sparse(a); y=b(i)  yields row vector x but column vector y
  % ax is full anyway
  if isa(a.x,'intval')
    INTLAB_STDFCTS_LOG2_ = INTLAB_CONST.STDFCTS_LOG2_;
    clog2 = infsup(INTLAB_STDFCTS_LOG2_.INF,INTLAB_STDFCTS_LOG2_.SUP);
    ax = clog2 ./ full(a.x(:));
  else
    ax = 1./( log(2) * full(a.x(:)) );
  end    
  a.x = log2(a.x);
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
  
  warning(wng)
  
  if rndold
    setround(rndold)
  end
