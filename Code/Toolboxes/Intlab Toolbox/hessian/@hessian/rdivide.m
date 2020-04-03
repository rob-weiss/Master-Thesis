function r = rdivide(a,b)
%RDIVIDE      Hessian elementwise right division  a ./ b
%

% written  04/04/04     S.M. Rump
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
% modified 08/01/14     S.M. Rump  Octave bug
% modified 12/09/15     S.M. Rump  prod(size) to numel(s)
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST

  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    if isaffari(a)
      a = intval(a);
    end
    if isaffari(b)
      b = intval(b);
    end
  end
        
  if numels(b)==1               % scalar denominator
    r = a / b;
    return
  end

  rndold = getround;
  if rndold
    setround(0)
  end

  scalar_a = ( numels(a)==1 );
  if ( ~scalar_a ) && ( ~isequal(size(a),size(b)) )
    error('dimensions do not match in hessian elementwise division')
  end
  
  N = INTLAB_CONST.HESSIAN_NUMVAR;
  
  % check for emptyness: cures Matlab bug
  % a=sparse([],[],[],2,1), [i,j,s]=find(a), s(i).*s(:)  yields error
  % throughout this routine use e.g.  sparse(ib,jb,reshape(D(jb),size(sb)).*sb,N,m);
  % rather than  sparse(ib,jb,D(jb).*sb(:),N,m);
  
  if ~isa(a,'hessian')              % non-hessian (scalar or array) ./ hessian array
    if issparse(b.hx)
      m = numels(b.x);
      r.x = a ./ b.x;
      D = -r.x ./ b.x;
      [ib,jb,sb] = find(b.dx);
      r.dx = sparse(ib,jb,reshape(D(jb),size(sb)).*sb,N,m);
      bdx = sparse(ib,jb,reshape(1./b.x(jb),size(sb)).*sb,N,m);
      r.hx = adx2rhx(N,m,bdx,b.dx);
      [ib,jb,sb] = find(b.hx-r.hx);
      r.hx = sparse(ib,jb,reshape(D(jb),size(sb)).*sb,N^2,m);
    else
      r.x = a ./ b.x;
      D = r.x ./ b.x;
      D = repmat(-D(:).',N^2,1);
      r.dx = D(1:N,:) .* b.dx;
      bdx1 = b.dx./repmat(b.x(:).',N,1);
      index = repmat(1:N,N,1);
      r.hx = D .* ( b.hx - bdx1(index,:).*b.dx(index',:) );
    end
  elseif ~isa(b,'hessian')          % hessian ./ non-hessian array
    r.x = a.x ./ b;
    bb = 1 ./ (b(:).');
    if scalar_a                     % hessian scalar ./ non-hessian array
      r.dx = a.dx * bb;
      r.hx = a.hx * bb;
    else                            % hessian array ./ non-hessian array
      if issparse(a.hx)
        m = numels(a.x);
        [ia,ja,sa] = find(a.dx);
        r.dx = sparse(ia,ja,reshape(bb(ja),size(sa)).*sa,N,m);
        [ia,ja,sa] = find(a.hx);
        r.hx = sparse(ia,ja,reshape(bb(ja),size(sa)).*sa,N^2,m);
      else
        bb = repmat(bb,N^2,1);
        r.dx = a.dx .* bb(1:N,:);
        r.hx = a.hx .* bb;
      end
    end
  else                              % hessian ./ hessian array
    m = numels(b.x);
    r.x = a.x ./ b.x;
    if scalar_a                     % hessian scalar ./ hessian array
      if issparse(a.hx) | issparse(b.hx)
        bx = sparse(b.x(:));
        D = 1 ./ sqr(bx);
        Num = a.dx * bx.' - a.x * b.dx;
        [i,j,s] = find(Num);
        r.dx = sparse(i,j,s.*reshape(D(j),size(s)),N,m);
        Num = sparse(i,j,s./reshape(bx(j),size(s)),N,m);
        r.hx = a.hx * sparse(bx.') - adx2rhx(N,m,b.dx,Num) - a.x * b.hx;
        [i,j,s] = find(r.hx);
        r.hx = sparse(i,j,s.*reshape(D(j),size(s)),N^2,m);
      else
        Num = a.dx * b.x(:).' - a.x * b.dx;
        D = repmat( sqr((1./b.x(:)).') , N^2 , 1 );
        r.dx = Num .* D(1:N,:);
        index = repmat(1:N,N,1);
        Num = Num ./ repmat(b.x(:).',N,1);
        r.hx = ( a.hx * b.x(:).' - reshape(b.dx(index,:) .* Num(index',:),size(b.hx)) - a.x * b.hx ) .* D;
      end
    else                            % hessian array ./ hessian array
      if issparse(a.hx) || issparse(b.hx)
        [ia,ja,sa] = find(a.dx);
        [ib,jb,sb] = find(b.dx);
        ax = a.x(:);
        bx = b.x(:);
        Num = sparse(ia,ja,reshape(bx(ja),size(sa)).*sa,N,m) - sparse(ib,jb,reshape(ax(jb),size(sb)).*sb,N,m);
        D = sqr( 1 ./ bx );
        [ia,ja,sa] = find(Num);
        r.dx = sparse(ia,ja,reshape(D(ja),size(sa)).*sa,N,m);
        Num = sparse(ia,ja,sa./reshape(bx(ja),size(sa)),N,m);
        [ia,ja,sa] = find(a.hx);
        [ib,jb,sb] = find(b.hx);
        r.hx = sparse(ia,ja,reshape(bx(ja),size(sa)).*sa,N^2,m) - adx2rhx(N,m,b.dx,Num) - ...
               sparse(ib,jb,reshape(ax(jb),size(sb)).*sb,N^2,m);
        [ia,ja,sa] = find(r.hx);
        r.hx = sparse(ia,ja,sa.*reshape(D(ja),size(sa)),N^2,m);
      else
        ax = repmat(a.x(:).',N^2,1);
        bx = repmat(b.x(:).',N^2,1);
        Num = a.dx .* bx(1:N,:) - ax(1:N,:) .* b.dx;
        D = repmat( sqr((1./b.x(:)).') , N^2 , 1 );
        r.dx = Num .* D(1:N,:);
        index = repmat(1:N,N,1);
        Num = Num ./ bx(1:N,:);
        r.hx = ( a.hx .* bx - reshape(b.dx(index,:) .* Num(index',:),size(a.hx)) - ax .* b.hx ) .* D;
      end
    end
  end

  r = class(r,'hessian');
  
  if rndold
    setround(rndold)
  end
