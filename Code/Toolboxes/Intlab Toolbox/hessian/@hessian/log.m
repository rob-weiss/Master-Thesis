function r = log(a)
%LOG          Hessian (elementwise) logarithm
%

% written  04/04/04     S.M. Rump
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 12/09/15     S.M. Rump  prod(size) to numel(s)
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST
  
  rndold = getround;
  if rndold
    setround(0)
  end

  K = numels(a.x);
  if K==1                   % scalar hessian
    
    r.x = log(a.x);
    ax1 = 1 / a.x;
    r.dx = a.dx * ax1;
    r.hx = a.hx * ax1 - reshape((0.5*r.dx) * r.dx.',size(a.hx));
    
  else                      % matrix hessian
    
    N = INTLAB_CONST.HESSIAN_NUMVAR;
    N2 = N^2;
    
    r.x = log(a.x);
    if issparse(a.hx)               % input sparse
      
      ax = 1./a.x(:);
      sizeax = length(ax);
      [ia,ja,sa] = find(a.dx);
      % check for emptyness: cures Matlab bug
      % a=sparse([],[],[],2,1), [i,j,s]=find(a), s(i).*s(:)  yields error
      if isempty(ia)
        r.dx = sparse([],[],[],N,sizeax);
        r.hx = sparse([],[],[],N2,sizeax);
      else
        if isa(a.x,'intval')          % sparse intval
          rdx = times(ax(ja),sa(:),0);
          if rdx.complex
            r.dx = intval( sparse(ia,ja,rdx.mid,N,sizeax) , sparse(ia,ja,rdx.rad,N,sizeax) , 'midrad' );
          else
            r.dx = intval( sparse(ia,ja,rdx.inf,N,sizeax) , sparse(ia,ja,rdx.sup,N,sizeax) , 'infsup' );
          end
        else                          % sparse point  
          r.dx = sparse(ia,ja,ax(ja).*sa(:),N,sizeax);        
        end                           
        r.hx = adx2rhx(N,sizeax,-0.5*r.dx,r.dx);
      end
      [ia,ja,sa] = find(a.hx);         % sparse point or intval
      % check for emptyness: cures Matlab bug
      % a=sparse([],[],[],2,1), [i,j,s]=find(a), s(i).*s(:)  yields error
      if ~isempty(ia)
        if isa(a.x,'intval')
          rhx = times(ax(ja),sa(:),0);
          if rhx.complex
            r.hx = r.hx + intval( sparse(ia,ja,rhx.mid,N2,sizeax) , sparse(ia,ja,rhx.rad,N2,sizeax) , 'midrad' );
          else
            r.hx = r.hx + intval( sparse(ia,ja,rhx.inf,N2,sizeax) , sparse(ia,ja,rhx.sup,N2,sizeax) , 'infsup' );
          end
        else
          r.hx = r.hx + sparse(ia,ja,ax(ja).*sa(:),N2,sizeax);
        end
      end
      
    else                            % input full
      
      r.x = log(a.x);
      ax = 1 ./ a.x(:).';
      ax = ax(ones(N*N,1),:);
      r.dx = a.dx .* ax(1:N,:);
      rdx = 0.5*r.dx;
      r.hx = a.hx .* ax - rdx(repmat(1:N,N,1),:) .* r.dx(repmat(1:N,1,N),:);
      
    end
    
  end
  
  r = class(r,'hessian');
  
  if rndold
    setround(rndold)
  end
