function [ X , xs , Y ] = verifylocalmin(funfcn,xs,param,see,varargin)
%VERIFYLOCALMIN  Verified local minimization
%
%   [ X , xs , Y ] = verifylocalmin(f,xs,param,see,P1,P2,...)
%
%Minimize the function f:R^n->R with initial approximation xs.
%Result X is an inclusion of xhat near xs with f'(xhat)=0 and f"(xhat)>0,
%i.e., there is a local minimum of f at xhat. Moreover, Y=X.
%If no inclusion could be computed, then the result for X is NaN.
%If f'(xhat)=0 can be verified but f"(xhat)>0 cannot, then xhat is a
%stationary point of f and xhat is included in Y.
%
% optional input    param   'SparseSPD' use Newton operator and sparse 
%                               linear system solver
%                           'Sparse' use Newton operator and normal equations, 
%                               thus limiting cond(Jacobian) to about 1e8
%                   see     see intermediate results 
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
%The option 'SparseSPD' is recommended for larger problems. Results are
%slightly less accurate, however, computational time is much less.
%The following example with 5000 unknowns
%
%   n = 5000;
%   tic
%   X = verifylocalmin('test_h',ones(n,1),[],0,2);
%   tfull = toc
%   max(relerr(X))
% 
%produces
%
% tfull =
%    10.4304
% ans =
%    5.9934e-16
%   
%whereas
%   
%   n = 5000;
%   tic
%   X = verifylocalmin('test_h',ones(n,1),'SparseSPD',0,2);
%   tsparse = toc
%   max(relerr(X))
% 
%produces
% 
% tsparse =
%     1.2266
% ans =
%    8.6483e-14
% 
% For details, see dhessian, the demo for hessians.
%


% written  02/27/17     S.M. Rump
% modified 05/08/17     S.M. Rump  parameter check
% modified 12/04/17     S.M. Rump  definition of X and Y
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
  
  if ( nargin<3 ) || isempty(param)
    param = 'f';
  else
    param = lower(param);
    % parameter check
    if ~ismember(param,{'sparse','sparsespd'})
      error('invalid parameter in verifylocalmin')
    end
    solve_spd = isequal(param(end-2:end),'spd');
  end
    
  if ( nargin<4 ) || isempty(see)
    see = 0;
  end
  
  % Convert to inline function as needed
  strfun = fcnchk(funfcn,length(varargin));
  n = length(xs);                   % number of variables
  
  % floating point Newton iteration
  sqrt_n = sqrt(n);
  dxs = zeros(size(xs));
  dxsnew = abs(xs);
  k = 0;
  while ( any(dxsnew<.5*dxs) && ( norm(dxsnew)>=sqrt_n*1e-14*norm(xs) ) && ( k<100 ) ) || ( k<3 )
    k = k+1;                     % at most 100, at least 3 iterations performed
    dxs = dxsnew;
    xsold = xs;
    y = feval(strfun,hessianinit(xs),varargin{:});
    xs = xs - y.hx\y.dx';    
    if see
      disp(['residual norm(f''(xs_k)), floating point iteration ' sprintf('%d',k)])
      norm(y.dx)
    end
    dxsnew = abs(xs-xsold);
  end
  
  if isequal(param(1),'s')
    
    % sparse interval iteration
    y = feval(strfun,hessianinit(intval(xs)),varargin{:});
    Z = - y.dx';
    X = Z;
    ready = 0; k = 0; kmax = 10;
    while ( ~ready ) && ( k<kmax ) && ( ~any(isnan(X)) )
      k = k+1;
      if see
        disp(['interval iteration ' sprintf('%d',k)])
      end
      X = hull( X , 0 );              % epsilon inflation
      Y = X + 0.1*rad(X)*hull(-1,1) + midrad(0,realmin);
      x = hessianinit(xs+Y);
      y = feval(strfun,x,varargin{:});
      M = y.hx;                  % automatic hessians
      if solve_spd
        % solve s.p.d. system
        X = verifylss(M.mid,Z+mag(M.rad)*abs(Y));
      else
        % solve normal equations
        X = verifylss(intval(M.mid')*M.mid,M.mid'*(Z+mag(M.rad)*abs(Y)));
      end
      ready = all(all(in0(X,Y)));
      % avoid the following, sometimes counterproductive
%       Y = intersect(X,Yold);     % intersection, therefore M still valid
    end
    
  else
    
    % full interval iteration
    R = inv(y.hx);
    y = feval(strfun,hessianinit(intval(xs)),varargin{:});
    Z = - R * y.dx';
    X = Z;
    ready = 0; k = 0; kmax = 10;
    while ( ~ready ) && ( k<kmax ) && ( ~any(isnan(X)) )
      k = k+1;
      if see
        disp(['interval iteration ' sprintf('%d',k)])
      end
      X = hull( X , 0 );              % epsilon inflation
      Y = X + 0.1*rad(X)*hull(-1,1) + midrad(0,realmin);
      x = hessianinit(xs+Y);
      y = feval(strfun,x,varargin{:});
      C = eye(n) - R * y.hx;          % automatic hessians
      i = 0;
      while ( ~ready ) && ( i<2 )     % improved interval iteration
        i = i+1;
        X = Z + C * Y;
        if any(isnan(X))
          ready = 0;
          break
        end
        ready = all(all(in0(X,Y)));
%         Y = intersect(X,Y);       % sometimes counterproductive
      end
    end
    
  end
  
  if ready && isempty(find(isnan(Y) | isinf(Y) ,1))
    Y = xs + Y;                     % verified inclusion of stationary point
    if isspd(y.hx,[],[],1)
      X = Y;
    else 
      X = intval(NaN(n,1));         % minimum not verified      
    end
  else
    X = intval(NaN(n,1));           % minimum not verified
    Y = X;                          % inclusion of stationary point
  end
  
  % restore warning and exception mode
  warning(wng)
  % restore out-of-range exception mode
  intvalinit(RealStdFctsExcptnMode,0);
  
  if rndold
    setround(rndold)
  end
  
end  % verifylocalmin
