function r = times(a,b)
%TIMES        Hessian elementwise multiplication  a .* b
%

% written  04/04/04     S.M. Rump
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/04/14     S.M. Rump  affari added
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
% modified 08/01/14     S.M. Rump  Octave bug
% modified 08/03/14     S.M. Rump  sparse and empty devatives
% modified 12/12/15     S.M. Rump  prod(size) to numel(s)
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
        
  rndold = getround;
  if rndold
    setround(0)
  end

  N = INTLAB_CONST.HESSIAN_NUMVAR;
 
  if ~isa(a,'hessian')
    m = numels(a);
    if m==1                     % non-hessian scalar .* hessian
      r.x = a * b.x;
      r.dx = a * b.dx;
      r.hx = a * b.hx;
    else                        % non-hessian array .* hessian
      n = numels(b.x);
      if n==1                   % non-hessian array .* hessian scalar
        r.x = a * b.x;
        ax = a(:).';
        if issparse(b.hx)
          ax = sparse(ax);
        end
        r.dx = b.dx * ax;
        r.hx = b.hx * ax;
      else                      % non-hessian array .* hessian array
        if ~isequal(size(a),size(b))
          error('hessian .* : dimensions not compatible')
        end
        r.x = a .* b.x;
        if issparse(b.hx)
          [ib,jb,sb] = find(b.dx);
          if isempty(ib)
            r.dx = sparse([],[],[],N,n);
            if isa(r.x,'intval')
              r.dx = intval(r.dx);
            elseif isa(r.x,'affari')
              r.dx = affari(r.dx);
            end
          else
            r.dx = sparse(ib,jb,reshape(a(jb),size(sb)).*sb,N,n);
          end
          [ib,jb,sb] = find(b.hx);
          if isempty(ib)
            r.hx = sparse([],[],[],N^2,n);
            if isa(r.x,'intval')
              r.hx = intval(r.hx);
            elseif isa(r.x,'affari')
              r.hx = affari(r.hx);
            end
          else
            r.hx = sparse(ib,jb,reshape(a(jb),size(sb)).*sb,N^2,n);
          end
        else
          ax = repmat(a(:).',N^2,1);
          r.dx = ax(1:N,:) .* b.dx;
          r.hx = ax .* b.hx;
        end          
      end
    end
  elseif ~isa(b,'hessian')      % hessian times non-hessian
    r = b .* a;  
    if rndold
      setround(rndold)
    end
    return
  else                          % both factors hessian
    m = numels(a.x);
    n = numels(b.x);
    sparse_ = issparse(a.hx) | issparse(b.hx);
    if m==1                     % scalar hessian .* hessian
      if n==1                   % scalar hessian .* scalar hessian
        r.x = a.x * b.x;
        r.dx = a.dx * b.x + a.x * b.dx;
        if sparse_
          r.hx = a.hx * b.x + reshape(sparse(a.dx) * sparse(b.dx.'),N^2,1) + a.x * b.hx;
        else
          r.hx = a.hx * b.x + reshape(a.dx * b.dx.',N^2,1) + a.x * b.hx;
        end
      else                      % scalar hessian .* array hessian
        r.x = a.x * b.x;
        if sparse_
          bx = sparse(b.x(:).');
          r.dx = a.dx * bx + b.dx * a.x;
          r.hx = a.hx * bx + reshape(sparse(a.dx)*sparse(b.dx(:).'),N^2,n) + a.x * b.hx ;
        else
          r.dx = a.dx * b.x(:).' + b.dx * a.x;
          r.hx = a.hx * b.x(:).' + reshape(a.dx*(b.dx(:).'),N^2,n) + a.x * b.hx ;
        end
      end
    else                        % array hessian .* hessian
      if n==1                   % array hessian .* scalar hessian
        r.x = a.x * b.x;
        if sparse_
          ax = sparse(a.x(:).');
          r.dx = b.dx * ax + a.dx * b.x;
          r.hx = b.hx * ax + reshape(sparse(b.dx)*sparse(a.dx(:).'),N^2,m) + b.x * a.hx;
        else
          r.dx = b.dx * a.x(:).' + a.dx * b.x;
          r.hx = b.hx * a.x(:).' + reshape(b.dx*(a.dx(:).'),N^2,m) + b.x * a.hx;
        end
      else                      % array hessian .* array hessian
        if ~isequal(size(a),size(b))
          error('dimensions not compatible for hessian .*');
        end
        r.x = a.x .* b.x;
        if issparse(a.hx) || issparse(b.hx)
          [ia,ja,sa] = find(a.dx);
          [ib,jb,sb] = find(b.dx);
          if isempty(sa) && isempty(sb)
            r.dx = sparse([],[],[],N,m);
            if isa(r.x,'intval')
              r.dx = intval(r.dx);
            elseif isa(r.x,'affari')
              r.dx = affari(r.dx);
            end
          else
            r.dx = sparse(ia,ja,reshape(b.x(ja),size(sa)).*sa,N,m) + ...
                   sparse(ib,jb,reshape(a.x(jb),size(sb)).*sb,N,m);
          end
          r.hx = adx2rhx(N,m,a.dx,b.dx);
          [ia,ja,sa] = find(a.hx);
          [ib,jb,sb] = find(b.hx);
          if isempty(sa) && isempty(sb)
            if isa(r.x,'intval')
              r.hx = intval(r.hx);
            elseif isa(r.x,'affari')
              r.hx = affari(r.hx);
            end
          else            
            r.hx = r.hx + sparse(ia,ja,reshape(b.x(ja),size(sa)).*sa,N^2,m) + ...
                          sparse(ib,jb,reshape(a.x(jb),size(sb)).*sb,N^2,m);
          end
        else
          ax = repmat(a.x(:).',N^2,1);
          bx = repmat(b.x(:).',N^2,1);
          r.dx = a.dx .* bx(1:N,:) + ax(1:N,:) .* b.dx;
          index = repmat( 1:N , N , 1 );
          r.hx = a.hx .* bx + ax .* b.hx + a.dx(index,:) .* b.dx(index',:);
        end
      end
    end
  end

  r = class(r,'hessian');
  
  if rndold
    setround(rndold)
  end
