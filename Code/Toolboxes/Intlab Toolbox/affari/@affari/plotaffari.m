function plotaffari(a,color,box)
%PLOTAFFARI   Visualization of 2D or 3D affari vector
%
%  plotaffari(a)  or  plotaffari(a,color)
%
%The default is a filled area, the parameter color is optional, default 'b'
%  color       '~'   random color
%              '%'   filled with specific color '%' in {'k','w','b','g','r','c','m','y'}
%              'n'   not filled, only skeleton
%The call
%
%  plotaffari(a,color,box)  or  plotaffari(a,[],box)
%
%plots the range box as well.
%
%The algorithm due to M. Kashiwagi needs about O(K^2) or O(K^3) operations 
%for K error terms and 2-dimensional or 3-dimensional input vector,
%respectively.
%

% written  03/31/14     S.M. Rump
% modified 05/17/14     S.M. Rump  code optimization
% modified 12/09/15     S.M. Rump  prod(size) to numel
% modified 01/15/16     S.M. Rump  2-dimensional plot
% modified 05/03/16     S.M. Rump  Adaption of parameters
%

  % set default parameters
  if ( nargin<2 ) || isempty(color)   % use plot with blue boundary
    color = 'b';
  end
  skeleton = isequal(color,'n');
  
  if ( nargin<3 ) || isempty(box)
    box = 0;
  end
  
  N = numel(a.mid);
  if ( N<2 ) || ( N>3 )
    error('plotaffari for vectors of length 2 or 3')
  end
  
  % Generate vertices
  a.mid = reshape(a.mid,1,N);
  % delete small error rows to speed up
  index = find( sum(abs(a.err),2) > 1e-4*sum(abs(a.mid(:)')) ); 
  a.err = a.err(index,:);
  K = size(a.err,1);
  if K<=1
    warning('errors too small to produce picture of reasonable size')
    title('errors too small to produce picture of reasonable size')
    shg
    return
  else
%     P = zeros(2^K,N);             % exhaustive search
%     for i=1:2^K
%       v = 2*bin2vec(i,K)-1;
%       P(i,:) = a.mid + sum( a.err.*repmat(v',1,N) );
    if N==2                 % 2-dimensional input
      P = zeros(4,K,N);
      x = a.err(:,1);
      y = a.err(:,2);
      for j=1:K
        EE = x(j)*y-x*y(j);
        E = repmat( sign(EE) ,1,N);
        E(j,:) = -1;
        P(1,j,:) = a.mid + sum( a.err.*E );
        P(2,j,:) = a.mid - sum( a.err.*E );
        E(j,:) = 1;
        P(3,j,:) = a.mid + sum( a.err.*E );
        P(4,j,:) = a.mid - sum( a.err.*E );
        % treat zero error components
        EE(j) = 1;
        index = find(EE==0);
        if length(index)>14
          error('geometry of affari too ill-conditioned, plot would require very long computing time')
        end
        if any(index)
          L = length(index);
          for ell=1:2^L
            v = bin2vec(ell,L)';
            EE(index) = v;
            E = repmat( sign(EE) ,1,N);
            new = zeros(4,1,N);
            E(j,:) = -1;
            new(1,1,:) = a.mid + sum( a.err.*E );
            new(2,1,:) = a.mid - sum( a.err.*E );
            E(j,:) = 1;
            new(3,1,:) = a.mid + sum( a.err.*E );
            new(4,1,:) = a.mid - sum( a.err.*E );
            P = cat(2,P,new);
          end
        end
      end
    else                    % 3-dimensional input
      P = zeros(8,K*(K-1)/2,N);
      New = [];
      x = a.err(:,1);
      y = a.err(:,2);
      z = a.err(:,3);
      jk = 0;
      for j=1:K       
        for k=j+1:K
          jk = jk + 1;
          EE = ( y(j)*z(k) - y(k)*z(j) ) * x - ...
               ( x(j)*z(k) - x(k)*z(j) ) * y + ...
               ( x(j)*y(k) - x(k)*y(j) ) * z ;
          E = repmat( sign(EE) ,1,N);
          E(j,:) = -1;
          E(k,:) = -1;
          P(1,jk,:) = a.mid + sum( a.err.*E );
          P(2,jk,:) = a.mid - sum( a.err.*E );
          E(k,:) = 1;
          P(3,jk,:) = a.mid + sum( a.err.*E );
          P(4,jk,:) = a.mid - sum( a.err.*E );
          E(j,:) = 1;
          P(5,jk,:) = a.mid + sum( a.err.*E );
          P(6,jk,:) = a.mid - sum( a.err.*E );
          E(k,:) = -1;
          P(7,jk,:) = a.mid + sum( a.err.*E );
          P(8,jk,:) = a.mid - sum( a.err.*E );
          % treat zero error components
          EE(j) = 1;
          EE(k) = 1;
          index = find(EE==0);
          if length(index)>14
            error('geometry of affari too ill-conditioned, plot would require very long computing time')
          end
          if any(index)
            L = length(index);
            for ell=1:2^L
              v = bin2vec(ell,L)';
              EE(index) = v;
              E = repmat( sign(EE) ,1,N);
              new = zeros(8,N);
              E(j,:) = -1;
              E(k,:) = -1;
              new(1,:) = a.mid + sum( a.err.*E );
              new(2,:) = a.mid - sum( a.err.*E );
              E(k,:) = 1;
              new(3,:) = a.mid + sum( a.err.*E );
              new(4,:) = a.mid - sum( a.err.*E );
              E(j,:) = 1;
              new(5,:) = a.mid + sum( a.err.*E );
              new(6,:) = a.mid - sum( a.err.*E );
              E(k,:) = -1;
              new(7,:) = a.mid + sum( a.err.*E );
              new(8,:) = a.mid - sum( a.err.*E );
              New = [ New ; new ];
              if size(New,1)>10000
                New = New(convhull(New, 'simplify',true),:);
              end
            end
          end
        end
      end
      sizeP = size(P);
      P = [ reshape(P,prod(sizeP(1:2)),N) ; New ];
    end
  end
  % reshape P to N column vector
  sizeP = size(P);
  P = reshape(P,prod(sizeP(1:end-1)),N);
  
  % treat rounding errors
  if any( a.rnderr > 1e-4*max(abs(P(:))) )
    err = repmat(a.rnderr,size(P,1),1);
    P = [ P + err ; P - err ];
  end  
  
  holdmode = ishold; 
  hold on

  % convex hull covering Matlab bug of collinear points
  try
    I = convhull(P, 'simplify',true);
  catch
    I = (1:size(P,1))';
  end
    
  if N==2                           % 2-dimensional
    if skeleton
      plot(P(I,1),P(I,2),['-' color 'o'],'LineWidth',1.5)
    else
      if isequal(color,'~')
        c = rand(1,3);      % random color
      else
        c = ['-' color];
      end
      fill(P(I,1),P(I,2),c,'LineWidth',1.5)
    end
  else                              % 3-dimensional
    if skeleton
      for i=1:size(I,1)        
        plot3(P(I(i,:),1),P(I(i,:),2),P(I(i,:),3),'-o','LineWidth',1.5)
      end
    else
      trisurf(I,P(:,1),P(:,2),P(:,3), 'FaceAlpha',0.9, ...
        'FaceColor','interp','Linewidth',1.5);
    end
  end
  
  if box
    plotintval(a.range);
  end
  if ~holdmode
    hold off
    % determine size of plot and equal axis
    phi = 0.2;                % enlargement of range
    B = hull( infsup(min(P),max(P)) , a.range(:)' );
    D = rad(B);
    axis(reshape([ B.inf-phi*D; B.sup+phi*D ],1,2*N))
    axis equal
  end
  