function r = gammaln(a)
%GAMMALN      Hessian (elementwise) logarithmic gamma function
%

% written  02/22/17     S.M. Rump
%

  global INTLAB_CONST
  
  rndold = getround;
  if rndold
    setround(0)
  end
  
  axfull = full(a.x);

  K = numels(a.x);
  if K==1                   % scalar hessian
    
    r.x = gammaln(axfull);
    psiax = psi(axfull);
    r.dx = psiax * a.dx;
    r.hx = psiax * a.hx + reshape( (0.5*psi(1,axfull)*a.dx) * a.dx.' , size(a.hx) );
    
  else                      % matrix hessian
    
    N = INTLAB_CONST.HESSIAN_NUMVAR;
    N2 = N^2;
    
    if issparse(a.hx)               % input sparse
      
      a.x = full(a.x);
      ax = gammaln(a.x(:));
      r.x = reshape(ax,size(a.x));
      sizeax = length(ax);
      [ia,ja,sa] = find(a.dx);
      psiax = psi(a.x(:));
      % check for emptyness: cures Matlab bug
      % a=sparse([],[],[],2,1), [i,j,s]=find(a), s(i).*s(:)  yields error
      if isempty(ia)
        r.dx = sparse([],[],[],N,sizeax);
        r.hx = sparse([],[],[],N2,sizeax);
      else
        ax1 = psiax;
        adx1 = 0.5*psi(1,a.x(:));
        if isa(a.x,'intval')          % sparse intval
          rdx = times(ax1(ja),sa(:),0);
          adx1 = times(adx1(ja),sa(:),0);
          r.dx = intval( sparse(ia,ja,rdx.inf,N,sizeax) , sparse(ia,ja,rdx.sup,N,sizeax) , 'infsup' );
          adx1 = intval( sparse(ia,ja,adx1.inf,N,sizeax) , sparse(ia,ja,adx1.sup,N,sizeax) , 'infsup' );
        else                          % sparse point  
          r.dx = sparse(ia,ja,ax1(ja).*sa(:),N,sizeax);        
          adx1 = sparse(ia,ja,adx1(ja).*sa(:),N,sizeax);        
        end                           
        r.hx = adx2rhx(N,sizeax,adx1,a.dx);
      end
      [ia,ja,sa] = find(a.hx);        % sparse point or intval
      % check for emptyness: cures Matlab bug
      % a=sparse([],[],[],2,1), [i,j,s]=find(a), s(i).*s(:)  yields error
      if ~isempty(ia)
        ax = psi(1,a.x(:));
        if isa(a.x,'intval')
          rhx = times(ax(ja),sa(:),0);
          r.hx = r.hx + intval( sparse(ia,ja,rhx.inf,N2,sizeax) , sparse(ia,ja,rhx.sup,N2,sizeax) , 'infsup' );
        else
          r.hx = r.hx + sparse(ia,ja,ax(ja).*sa(:),N2,sizeax);
        end
      end
      
    else                            % input full
      
      r.x = gammaln(axfull);
      ax = axfull(:).';
      rx = r.x(:).';
      psiax = psi(ax);
      psiax = psiax(ones(N*N,1),:);
      r.dx = a.dx .* psiax(1:N,:);
      adx = repmat(0.5*psi(1,ax),N,1) .* a.dx;
      r.hx = a.hx .* psiax + adx(repmat(1:N,N,1),:) .* a.dx(repmat(1:N,1,N),:);
      
    end
    
  end
  
  r = class(r,'hessian');
  
  if rndold
    setround(rndold)
  end
