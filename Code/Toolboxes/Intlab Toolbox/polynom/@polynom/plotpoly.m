function [X,y,z] = plotpoly(p,xl,xr,kmax)
%PLOTPOLY     Plot routine for real (interval) polynomial in one or two variables
%
%For univariate polynomial p, 
%   plotpoly(p)
%plots p within [-r,r], where r is a rootbound for p. For interval polynomial p,
%the lower and upper bound is plotted in blue and red, respectively.
%   plotpoly(p,xl,xr)
%plots p within [xl,xr], both with 100 meshpoints. 
%   [x,y] = plotpoly(p,xl,xr,kmax)
%plots p within [xl,xr] with kmax meshpoints (see below). Optional output parameters store the
%vectors of x- and y-values, where y is an interval vector for interval polynomial p.
%The x-axis is displayed if within the plot.
%
%This routine is for getting an impression of the plot of a polynomial, the
%plot is not verified. However, specifying negative values for kmax for
%univariate polynomials has the same functionality as before (using |kmax|
%meshpoints), but showing a verified plot. Specifying kmax=0 shows a
%verified plot with the default value kmax=100.
%
%For polynomial p in two unknowns, 
%   plotpoly(p,lb,ub,kmax)
%plots p within lb and ub, where lb and ub are two-vectors specifying the lower and upper
%bound for the two variables, respectively. Input parameter kmax is optional, default is 100.
%Input kmax may also be two-vector specifiying number of meshpoints for first and second variable.
%   Z = plotpoly(p,lb,ub)
%gives back matrix Z of polynomial values, and 
%   [X,Y,Z] = plotpoly(p,lb,ub)
%gives back vectors X and Y of values of first and second variable, respectively, and matrix Z of
%polynomial values, such that surf(X,Y,Z) produces polynomial plot (for interval polynomial use
%  surf(X,Y,Z.inf), hold on, surf(X,Y,Z.sup), hold off ).
%

% written  09/14/00     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/20/05     S.M. Rump  faster check for rounding to nearest
% modified 11/05/07     S.M. Rump  zero line added
% modified 05/18/14     S.M. Rump  code optimization
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
% modified 11/02/16     F. Bünger  verified plot of upper and lower bounds
%

  rndold = getround;
  if rndold
    setround(0)
  end

  if ~isreal(p)
    error('polynomial must be real (point or interval)')
  end
  
  if size(p.e,2)==1                   % univariate polynomial
    
    if nargin==1
      xl = -rootbound(p);
      xr = -xl;
    end
    
    if isnan(xl) | ( xr-xl==0 )
      xl = -1;
      xr = 1;
    end
    
    if nargin<4                 % default number of meshpoints
      kmax = 100;
    end
    
    if kmax==0                  % verified plot with default number of meshpoints
      kmax = -100;
    end
    
    x = linspace(xl,xr,abs(kmax));
    if nargout>0
      X = x;
    end
    
    if isa(p.c,'intval')        % univariate interval polynomial
      y = polyval(p,x);
      
      if kmax>0                 % non-verified plot
        
        plot( x , y.inf , 'b', x , y.sup , 'r' )
        
      else
        ddp = pderiv(p,2);                   % second derivative p'' of p
        d_upper = (y.sup(2:end)-y.sup(1:end-1))./diff(x); % non-verified computation of the slopes of piecewise linear upper bound curve
        d_lower = (y.inf(2:end)-y.inf(1:end-1))./diff(x); % non-verified computation of the slopes of piecewise linear lower bound curve
        
        N = length(x);
        y_low = zeros(N-1,2);
        y_up = zeros(N-1,2);
        kmax2 = 1000;       %<---- kmax2 might become a new input parameter
        for i = 1:N-1
          xx = linspace(x(i),x(i+1),kmax2);
          x_ = infsup(xx(1:end-1),xx(2:end));
          
          % begin of construction of lower bound curve
          z = polyval(ddp,x_);
          if max(z.sup) <= 0  % p is concave on [x(i),x(i+1)] so that the line connecting y.inf(i) and y.inf(i+1) is a verified lower bound
            y_low(i,:) = [y.inf(i),y.inf(i+1)];
          else
            q1 = p - d_lower(i) * polynom(intval([1, -x(i)]));
            q2 = p - d_lower(i) * polynom(intval([1, -x(i+1)]));
            z1 = polyval(q1,x_); % z1 + d_lower(i) * (x-x(i))   <= p(x) for all x in x_iv
            z2 = polyval(q2,x_); % z2 + d_lower(i) * (x-x(i+1)) <= p(x) for all x in x_iv
            y_low(i,:) = [min(z1.inf),min(z2.inf)];
          end
          
          % begin of construction of upper bound curve
          if min(z.inf) >= 0  % p is convex on [x(i),x(i+1)] so that the line connecting y.sup(i) and y.sup(i+1) is a verified upper bound
            y_up(i,:) = [y.sup(i),y.sup(i+1)];
          else
            q1 = p - d_upper(i) * polynom(intval([1, -x(i)]));
            q2 = p - d_upper(i) * polynom(intval([1, -x(i+1)]));
            z1 = polyval(q1,x_); % z1 + d_upper(i) * (x-x(i))   >= p(x) for all x in x_iv
            z2 = polyval(q2,x_); % z2 + d_upper(i) * (x-x(i+1)) >= p(x) for all x in x_iv
            y_up(i,:) = [max(z1.sup),max(z2.sup)];
          end
        end
        
        % At the gridpoints the piecewise lower and upper bounds should meet continuously.
        y_lower = [y_low(1,1);
          min(y_low(2:end,1),y_low(1:end-1,2));
          y_low(end,2)];
        
        y_upper = [y_up(1,1);
          max(y_up(2:end,1),y_up(1:end-1,2));
          y_up(end,2)];
        
        plot( x , y_lower , '-b', x , y_upper , '-g' )
        
      end
      
    else                                 % non-interval polynomial
      plot( x , polyval(p.c,x) , 'r' )
    end
    
    A = axis;
    if ( A(3)<=0 ) & ( 0 <= A(4) )
      hold on
      plot(A(1:2),[0 0])
      hold off
    end
    
  elseif size(p.e,2)==2         % multivariate polynomial in two unknowns
    
    if nargin<4
      xmax = 100;
      ymax = 100;
    else
      kmax = abs(kmax);
      if length(kmax)==1
        xmax = kmax;
        ymax = kmax;
      elseif length(kmax)==2
        xmax = kmax(1);
        ymax = kmax(2);
      else
        error('invalid parameter kmax')
      end
    end
    if length(xl)==1
      xl = repmat(xl,1,2);
    end
    if length(xr)==1
      xr = repmat(xr,1,2);
    end
    if ( length(xl)~=2 ) || ( length(xr)~=2 )
      error('invalid input parameters for plotpoly')
    end
    x = linspace(xl(1),xr(1),xmax);
    y = linspace(xl(2),xr(2),ymax);
    xx = repmat(x,ymax,1);
    yy = repmat(y',1,xmax);
    z = reshape( polyval(p,[xx(:) yy(:)]) , ymax , xmax );
    
    if isa(p.c,'intval')
      surf(x,y,z.inf)
      hold on
      surf(x,y,z.sup)
      hold off
    else
      surf(x,y,z)
    end
    xlabel(p.v(1));
    ylabel(p.v(2));
    
    if nargout==1
      X = z;
    elseif nargout~=0
      X = x;
    end
    
  else
    error('polynomial plot only for polynomials in one or two unknowns')
  end
  
  setround(rndold)

