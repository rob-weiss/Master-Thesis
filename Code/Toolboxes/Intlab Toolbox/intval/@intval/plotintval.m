function plotintval(a,color,kmax,fillcolor)
%PLOTINTVAL   Plots real or complex intervals
%
%  plotintval(X)  or  plotintval(X,color)
%
%color optional, default 'b'
%  color       '~'   random color
%              '%'   filled with specific color '%' in {'k','w','b','g','r','c','m','y'}
%              'n'   not filled, only skeleton
%
%Real X in IR^{n,K}:
%  Each box X(:,i) is plotted, 1<=n<=3
%
%Complex X (scalar, vector or matrix):
%  Each circle X(i,j) is plotted in the Gaussian plane, each based 
%  on kmax meshpoints (optional, default kmax=100)
%
%Plots into current axis if hold on is active. Aspect ratio is set equal so that
%  squares and circles appear as such.
%
%A real example showing the wrapping effect:
%  factor = 0.2; A = factor*[1 -2;3 -4], z = [1;1], rho(A), rho(abs(A)), close
%  x = infsup(-1,1)*ones(2,1); X = x;
%  for i=2:5, x = z + A*x; X(:,i) = x; end
%  plotintval(X)
%The spectral radius of A is 0.4, thus the real iteration z+Ax is convergent 
%for any starting value. The spectral radius of |A|, however, is 1.0745,
%thus the interval iteration is divergent for any starting value except, theoretically, 
%the point interval (I-A)\z. However, that is spoiled by rounding errors.
%
%Example displaying the complex wrapping effect:
%  a = midrad(0.8+0.7i,0.1); b = a; plotintval(a); hold on
%  for i=1:5, b = b*a, plotintval(b), end, hold off
%Another way to obtain the picture is
%  a = midrad(0.8+0.7i,0.1); for i=2:5, a(i) = a(i-1)*a(1); end, plotintval(a)
%A nice picture demonstrating overestimation of complex multiplication is generated as follows (data taken
%from Markus Neher: On the complex mean value form, SCAN 2002, Paris):
%
% kmax = 40; i = sqrt(-1); a=midrad(i,1); b=midrad(2+i,2); 
% plotintval(a*b); hold on
% phi = linspace(0,2*pi,kmax);
% [A,B] = meshgrid( mid(a)+rad(a)*exp(i*phi) , mid(b)+rad(b)*exp(i*phi) );
% plot(A.*B)
% hold off
%
%For another nice picture try a=midrad(1,1) and b=midrad(-1+i,1), presented by 
%Markus Grimmer from Wuppertal at the Dagstuhl meeting on Numerical Software with
%Result Verification, January 2003.
%

%  fillcolor   default 0
%              'o'   draw circle 'o', 1D or 2D
%

% written  08/06/02     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/20/05     S.M. Rump  faster check for rounding to nearest
% modified 04/03/14     S.M. Rump  3D boxes
% modified 05/15/14     S.M. Rump  code optimization
% modified 07/20/15     S.M. Rump  omit plotting '*'
% modified 07/27/15     S.M. Rump  secret option color added
% modified 12/09/15     S.M. Rump  hold on
% modified 01/05/16     S.M. Rump  Linewidth, axis and nofill
% modified 05/03/16     S.M. Rump  Adaption of parameters
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  [dim,K] = size(a);    % dimension
  if dim>3
    error('maximum dimension is 3')
  end

  rndold = getround;
  if rndold
    setround(0)
  end
  
  if ( nargin<2 ) || isempty(color)   % use plot with blue boundary
    color = 'b';
  end
  
  if ( nargin<3 ) || isempty(kmax)
    kmax = 100;
  end
  
  if ( nargin<4 ) || isempty(fillcolor)
    fillcolor = 0;
  end
  
  if a.complex          % complex input
    phi = linspace(0,2*pi,kmax)';
    mid = ones(kmax,1)*( a.mid(:).' );
    x = real(mid) + cos(phi)*a.rad(:)';
    y = imag(mid) + sin(phi)*a.rad(:)';
    index = ( relerr(a)<0.01 );
    if isequal(color,'~')
      color = rand(1,3);      % random color
    end
    if any(index(:))
      plot( x,y, real(a.mid(index)),imag(a.mid(index)),'+','Color',color);
    else
      plot(x,y,'Color',color);
    end
    xmin = min(x(:));
    xmax = max(x(:));
    ymin = min(y(:));
    ymax = max(y(:));
    dx = 0.2*(xmax-xmin);
    dy = 0.2*(ymax-ymin);
    ax = axis;        % get current axis
    xmin = min(xmin,ax(1)+dx);
    xmax = max(xmax,ax(2)-dx);
    ymin = min(ymin,ax(3)+dy);
    ymax = max(ymax,ax(4)-dy);
    axis([xmin-dx xmax+dx ymin-dy ymax+dy]);
    axis equal
  else                  % real input
    ainf = a.inf;
    asup = a.sup;
    amin = min(ainf,[],2);
    amax = max(asup,[],2);
    d = 0.2*(amax-amin);
    ax = axis;
    if isequal(ax,[0 1 0 1])
      ax = repmat([inf -inf],1,3);
    else
      ax = [ ax inf -inf inf -inf];
    end
    if dim==1           % 1-dimensional plot
      axmin = min(amin(1)-d(1),ax(1));
      axmax = max(amax(1)+d(1),ax(2));
      axis([axmin axmax -1 1]);
      e = 0.01;         % a little thickness
      args = { [ainf;asup;asup;ainf;ainf],repmat([-e;-e;e;e;-e],1,K) };
    elseif dim==2       % 2-dimensional plot
      axmin = min(amin(1)-d(1),ax(1));
      axmax = max(amax(1)+d(1),ax(2));
      aymin = min(amin(2)-d(2),ax(3));
      aymax = max(amax(2)+d(2),ax(4));
      axis([axmin axmax aymin aymax]);
      args = { [ainf(1,:);asup(1,:);asup(1,:);ainf(1,:);ainf(1,:)], ...
               [ainf(2,:);ainf(2,:);asup(2,:);asup(2,:);ainf(2,:)] ...
             };
    elseif dim==3       % 3-dimensional plot
      axmin = min(amin(1)-d(1),ax(1));
      axmax = max(amax(1)+d(1),ax(2));
      aymin = min(amin(2)-d(2),ax(3));
      aymax = max(amax(2)+d(2),ax(4));
      azmin = min(amin(3)-d(3),ax(5));
      azmax = max(amax(3)+d(3),ax(6));
      axis([axmin axmax aymin aymax azmin azmax]);
      % define facets
      args{1} = { [ ainf(1,:);asup(1,:);asup(1,:);ainf(1,:);ainf(1,:) ] , ...
                  repmat(ainf(2,:),5,1), ...
                  [ ainf(3,:);ainf(3,:);asup(3,:);asup(3,:);ainf(3,:) ] };
      args{2} = { [ ainf(1,:);asup(1,:);asup(1,:);ainf(1,:);ainf(1,:) ] , ...
                  repmat(asup(2,:),5,1), ...
                  [ ainf(3,:);ainf(3,:);asup(3,:);asup(3,:);ainf(3,:) ] };
      args{3} = { repmat(ainf(1,:),5,1) , ...
                  [ ainf(2,:);asup(2,:);asup(2,:);ainf(2,:);ainf(2,:) ] , ...
                  [ ainf(3,:);ainf(3,:);asup(3,:);asup(3,:);ainf(3,:) ] };
      args{4} = { repmat(asup(1,:),5,1) , ...
                  [ ainf(2,:);asup(2,:);asup(2,:);ainf(2,:);ainf(2,:) ] , ...
                  [ ainf(3,:);ainf(3,:);asup(3,:);asup(3,:);ainf(3,:) ] };
      args{5} = { [ ainf(1,:);asup(1,:);asup(1,:);ainf(1,:);ainf(1,:) ] , ...
                  [ ainf(2,:);ainf(2,:);asup(2,:);asup(2,:);ainf(2,:) ] , ...
                  repmat(ainf(3,:),5,1) };
      args{6} = { [ ainf(1,:);asup(1,:);asup(1,:);ainf(1,:);ainf(1,:) ] , ...
                  [ ainf(2,:);ainf(2,:);asup(2,:);asup(2,:);ainf(2,:) ] , ...
                  repmat(asup(3,:),5,1) };
    end
    
    hold on
    
    if dim<3                            % 1- or 2-dimensional
      if isequal(fillcolor,'o')
        if size(a,1)==1
          scatter((ainf+asup)/2,zeros(size(ainf)),[color 'o'],'filled')
        else
          %VVVV  amid = a.mid;
          s.type = '.';
          s.subs = {'mid'}; amid = subsref(a,s);
          %AAAA  Matlab bug fix
          scatter(amid(1,:),amid(2,:),'r','filled')
        end
      else
        if isequal(color,'n')
          p = plot(args{:});
          set(p,'LineWidth',0.1)
        else
          if isequal(color,'~')
            color = rand(size(args{1}));  % random color
          elseif isempty(color)
            color = 'w';
          end
          if fillcolor
            patch(args{:},color)
          else
            p = patch(args{:},color);
            set(p,'LineWidth',0.1)
          end
        end
      end
    else                                % 3-dimensional
      if isequal(color,'~')
        color = rand(size(args{1}{1}));  % random color
      elseif isempty(color)
        color = 'w';
      end
      if fillcolor
        for i=1:6
          p = patch(args{i}{:},color);
          set(p,'FaceAlpha',0.05)
        end
      else
        for i=1:6
          patch(args{i}{:},color);
        end
      end
      view(3)
    end
  end
  
  setround(rndold)
  
end  % function plotintval
