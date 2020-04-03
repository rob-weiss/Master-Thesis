function [ X , xs , Y ] = verifyconstraintlocalmin(funfcnf,funfcng,xs,see,varargin)
%VERIFYCONSTRAINTLOCALMIN   Verified constrained local minimization
%
%   [ X , xs , Y ] = verifyconstraintlocalmin(f,g,xs,see,P1,P2,...)
%
%Minimize the function f:R^n->R with initial approximation xs subject to 
%g(x)=0, where g:R^m->R and m<n.
%Result X is an inclusion of xhat near xs with f'(xhat)=0 and g(xhat)=0.
%  Result is NaN if no inclusion could be computed.
%
% optional input    see     see intermediate results 
%                   P1,...  extra parameters for function evaluation
%                           f(x,P1,P2,...)
%
% optional output   xs      improved approximation (column vector)
%                   Y       see below
%                           
%If the inclusion of a minimum is successful, then Y=X.
%If not, but inclusion of a stationary point is successful, then
%this inclusion is stored in Y where X is a vector of NaN's.
%If neither inclusion is successful, then both X and Y are NaN's.
%

% written  02/27/17     S.M. Rump
%

  rndold = getround;
  if rndold
    setround(0)
  end
  
  % store warning mode
  wng = warning;
  warning off
  
  % store standard function exception mode
  RealStdFctsExcptnMode = intvalinit('RealStdFctsExcptn',0);
  intvalinit('RealStdFctsExcptnNaN',0);

  xs = xs(:);
  
  if ( nargin<4 ) || isempty(see)
    see = 0;
  end
  
  % Convert to inline function as needed
  strfunf = fcnchk(funfcnf,length(varargin));
  strfung = fcnchk(funfcng);
  n = length(xs);                   % number of variables
  m = length(feval(strfung,xs));    % number of constraints
  if m>=n
    error('There should be less equality constraints than unknowns.')
  end
  
  % floating point Newton iteration
  sqrt_n = sqrt(n);
  dxs = zeros(size(xs));
  dxsnew = abs(xs);
  k = 0;
  lambda = [];
  while ( any(dxsnew<.5*dxs) && ( norm(dxsnew)>=sqrt_n*1e-14*norm(xs) ) && ( k<100 ) ) || ( k<3 )
    k = k+1;                     % at most 100, at least 3 iterations performed
    dxs = dxsnew;
    xsold = xs;
    [y,lambda,Hb] = cminfeval(strfunf,strfung,xs,lambda,m,varargin{:});
    update = Hb \ y;
    xs = xs - update(1:n);
    lambda = lambda - update(n+1:end);
    if see
      disp(['residual norm of update, floating point iteration ' sprintf('%d',k)])
      norm(update)
    end
    dxsnew = abs(xs-xsold);
  end
      
  % full interval iteration
  R = inv(Hb);
  y = cminfeval(strfunf,strfung,intval(xs),lambda,m,varargin{:});
  Z = - R*y;
  X = Z;
  ready = 0; k = 0; kmax = 10;
  while ( ~ready ) && ( k<kmax ) && ( ~any(isnan(X)) )
    k = k+1;
    if see
      disp(['interval iteration ' sprintf('%d',k)])
    end
    X = hull( X , 0 );              % epsilon inflation
    Y = X + 0.1*rad(X)*hull(-1,1) + midrad(0,realmin);
    X = xs + Y(1:n);
    Lambda = lambda + Y(n+1:end);
    % older Matlab version do not accept [~,...] = ...
    [dummy1,dummy2,Hb,H,Jg] = cminfeval(strfunf,strfung, ...
      xs+Y(1:n),lambda+Y(n+1:end),m,varargin{:});
    C = eye(n+m) - R * Hb;          % automatic hessians
    i = 0;
    while ( ~ready ) && ( i<2 )     % improved interval iteration
      i = i+1;
      X = Z + C * Y;
      if any(isnan(X(:)))
        ready = 0;
        break
      end
      ready = all(all(in0(X,Y)));
    end
  end
  
  X = intval(NaN(n,1));         % intialization
  if ready && isempty(find(isnan(Y) | isinf(Y) ,1))
    Y = xs + Y(1:n);            % verified inclusion of stationary point
    if islocalmin(n,m,Jg,H)
      X = Y;
    end
  else
    Y = X;
  end
  
  % restore warning and exception mode
  warning(wng)
  % restore out-of-range exception mode
  intvalinit(RealStdFctsExcptnMode,0);
  
  if rndold
    setround(rndold)
  end
  
end  % verifyconstraintlocalmin


function res = islocalmin(n,m,Jg,H)
% verify stationary point is local minimum
  if m==1
    % verification of local minimum
    % older Matlab version do not accept [~,...] = ...
    [dummy,p] = max(abs(mid(Jg))); % choose pivot
    % Compute basis of null space
    T = eye(n-1);
    T = [ T(1:p-1,:) ; -Jg([1:p-1 p+1:n])/Jg(p) ; T(p:n-1,:) ];
  else
    % verification of local minimum
    % older Matlab version do not accept [~,...] = ...
    [dummy1,dummy2,p] = lu(mid(Jg)','vector'); % choose good partitioning
    B = Jg(:,p);
    % Compute basis of null space
    T = [ -verifylss(B(:,1:m),B(:,m+1:end)) ; eye(n-m) ];
    T = T(p,:);               % undo permutation
  end
  res = isspd(T'*H*T,[],[],1);   % no sym check
end  % function islocalmin


function [y,lambda,Jb,J,Jg] = cminfeval(f,g,x,lambda,m,varargin)
%function evaluation for verifyconstraintlocalmin
%Bordered system F:R^(n+m)->R^(n+m) where n=length(x)
%  df + lambda^T dg = 0
%                 g = 0
% 
% input  f       f:R^n->R function to be minimized
%                  (possibly with extra parameters in varargin)
%        g       g:R^m->R constraints g(x)=0
%        x       argument for f
%        lambda  Lagrange multipliers
% output y       function value of bordered system
%        Jb      Jacobian of bordered system
%        J       Jacobian of unbordered system
%        Jg      Jacobian of g
%
  xh = hessianinit(x);
  if isempty(varargin)
    yf = feval(f,xh);
  else
    yf = feval(f,xh,varargin{:});
  end
  yg = feval(g,xh);
  if isempty(lambda)
    lambda = -(yg.dx')\(yf.dx'); % initialize Lagrange multipliers
  end
  y = [ yf.dx'+yg.dx'*lambda ; yg.x ];
  if nargout==1                 % Call to initialize inclusion iteration
    return
  end
  if m==1
    J = yf.hx + lambda*yg.hx;
    Jb = [ J yg.dx' ; yg.dx 0 ];
  else
    J = yf.hx;
    for i=1:m
      J = J + lambda(i)*yg(i).hx;
    end
    Jb = [ J yg.dx' ; yg.dx zeros(m) ];
  end
  Jg = yg.dx;

end  % function cminfeval
