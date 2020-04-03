function [ X , xs , k ] = verifynlss(funfcn,xs,param,see,varargin)
%VERIFYNLSS   Verified solution of nonlinear system
%
%   [ X , xs , k ] = verifynlss(f,xs,param,see,P1,P2,...)
%
%f is name of function, to be called by f(xs), xs is approximation.
%If param is 'g' or 's', then f:R^n->R^n ;
%Result X is an inclusion of xhat near xs with f(xhat)=0 or f'(xhat)=0.
%  Result is NaN if no inclusion could be computed.
%By default, the function is expanded by gradients. If param is 
%  specified 's', slopes are used instead.
%Former parameter 'h' to solve f'(x)=0: Please use verifylocalmin.
%This function is designed for simple roots; for multiple roots use
%  "verifynlss2".
%
% optional input    param   'g'  use gradient, proves uniqueness
%                           's'  use slopes, better, but w/o uniqueness
%                           'gSparseSPD', 'sSparseSPD' same as above but
%                               using sparse linear system solver
%                           'gSparse', 'sSparse' same as above but
%                               using sparse linear system solver to normal
%                               equations, thus limiting cond(Jacobian) to about 1e8
%                   see     see intermediate results 
%                   P1,...  extra parameters for function evaluation
%                           f(x,P1,P2,...)
%
% optional output   xs      improved approximation (column vector)
%                   k       interval iteration steps
%
%
%Simple, one-dimensional nonlinear functions which can be written in one
%formula string, can be entered directly. The unknown must be 'x'. E.g.,
%    X = verifynlss('x*exp(x)-1',.6)
%evaluates an inclusion of the zero of x*exp(x)-1=0 near xs=.6.
%
%Nonlinear system solver based on the Krawcyzk operator, see
%  R. Krawczyk: Newton-Algorithmen zur Bestimmung von Nullstellen mit
%    Fehlerschranken, Computing 4, 187-201, 1969.
%  R.E. Moore: A Test for Existence of Solutions for Non-Linear Systems,
%    SIAM J. Numer. Anal. 4, 611-615, 1977.
%with modifications for enclosing the error with respect to an approximate
%solution, an iteration scheme, epsilon-inflation and an improved interval
%iteration as in
%  S.M. Rump: Solving Algebraic Systems with High Accuracy, in "A New
%    Approach to Scientific Computation", eds. U. Kulisch and W. Miranker,
%    Academic Press, 51-120, 1983.
%  S.M. Rump: Verification methods for dense and sparse systems of equations, 
%    in : J. Herzberger (ed.), Topics in Validated Computations - Studies in 
%    Computational Mathematics, Elsevier, Amsterdam, 63-136, 1994.
%
%Using gradient verifies existence and uniqueness of a zero of the nonlinear
%  function within the inclusion interval. This also implies multiplicity 1 of
%  the zero, and nonsingularity of the Jacobian at the zero.
%Using slopes implies existence but not uniqueness of a zero. This allows
%  inclusion of zero clusters and multiple zeros. For details, see
%    S.M. Rump: Inclusion of Zeros of Nowhere Differentiable n-dimensional
%      Functions, Reliable Computing, 3:5-16 (1997).
%

% written  10/16/98     S.M. Rump
% modified 10/12/99     S.M. Rump  output NaN-vector in case of failure,
%                                  interval iteration stops if NaN occurred
% modified 06/26/02     S.M. Rump  output always of type intval, also for NaN
% modified 01/09/04     S.M. Rump  stopping criterion for fl-pt iteration changed following
%                                    a proposal by Arnold Neumaier
% modified 04/04/04     S.M. Rump  hessians and zeros of f' added, improved fl-pt stopping criterion
%                                    set round to nearest for safety
%                                    sparse Jacobian/Hessian
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 05/16/07     S.M. Rump  see intermediate result for parameter 'h'
% modified 09/06/07     S.M. Rump  warning supressed
% modified 10/27/07     S.M. Rump  check for NaN in iteration
% modified 11/14/07     S.M. Rump  solve for normal equations added
% modified 03/09/08     S.M. Rump  check for parameter corrected
% modified 09/23/08     S.M. Rump  stdfct exception corrected
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 10/19/08     S.M. Rump  StdFctsException ignore/NaN, check for inf
% modified 05/24/09     S.M. Rump  k-th derivative using Taylor package
% modified 10/05/09     S.M. Rump  parameter check
% modified 08/02/12     S.M. Rump  comment verifynlss2
% modified 04/17/14     S.M. Rump  repmat(nan,...
% modified 05/15/14     S.M. Rump  code optimization
% modified 07/29/15     S.M. Rump  epsilon-inflation
% modified 09/01/15     S.M. Rump  options 'h' and k removed; use verifylocalmin
%                                     or verifynlssderiv
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
% modified 02/19/17     S.M. Rump  epsilon-inflation, improved inclusion
% modified 05/08/17     S.M. Rump  parameter check and omit 'h'
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
    param = 'g';
  else
    if isequal(param,'h')
      error('This option has been removed; please use verifylocalmin')
    elseif isnumeric(param) && (length(param)==1) && ( param>=0 ) && ( param==round(param) )
      error('This option has been removed; please use verifynlssderiv')
    else
      param = lower(param);
    end
  end
  
  % parameter check
  if ~ismember(param,{'g','s','gsparse','ssparse','gsparsespd','ssparsespd'})
    error('invalid parameter in verifynlss')
  end
  
  if ( nargin<4 ) || isempty(see)
    see = 0;
  end
  
  % Convert to inline function as needed
  strfun = fcnchk(funfcn,length(varargin));
  
  % floating point Newton iteration
  n = length(xs);
  sqrt_n = sqrt(n);
  dxs = zeros(size(xs));
  dxsnew = abs(xs);
  k = 0;
  while ( any(dxsnew<.5*dxs) && ( norm(dxsnew)>=sqrt_n*1e-14*norm(xs) ) && k<100 ) || ( k<3 )
    k = k+1;                     % at most 100, at least 3 iterations performed
    dxs = dxsnew;
    xsold = xs;
    y = feval(strfun,gradientinit(xs),varargin{:});
    xs = xs - y.dx\y.x;
    if see
      disp(['residual norm(f(xs_k)), floating point iteration ' sprintf('%d',k)])
      norm(y.x)
    end
    dxsnew = abs(xs-xsold);
  end
  
  % check full or sparse case
  if length(param)>1
    sparse_ = ~isempty(strfind(param,'sparse'));
  else
    sparse_ = 0;
  end
  
  if sparse_
    
    % sparse interval iteration
    Z = - feval(strfun,intval(xs),varargin{:});
    X = Z;
    ready = 0; k = 0; kmax = 10;
    while ( ~ready ) && ( k<kmax ) && ( ~any(isnan(X)) )
      k = k+1;
      if see
        disp(['interval iteration ' sprintf('%d',k)])
      end
      X = hull( X , 0 );              % epsilon inflation
      Y = X + 0.1*rad(X)*hull(-1,1) + midrad(0,realmin);
      Yold = Y;
      if isequal(param(1),'g')        % use gradients
        x = gradientinit(xs+Y);
        y = feval(strfun,x,varargin{:});
        M = y.dx;                  % automatic gradients
      elseif isequal(param(1),'s')    % use slopes
        x = slopeinit(xs,xs+Y);
        y = feval(strfun,x,varargin{:});
        M = y.s;                   % automatic slopes
      end
      solve_spd = isequal(param(end-2:end),'spd');
      if solve_spd
        % solve s.p.d. system
        X = verifylss(M.mid,Z+mag(M.rad)*abs(Y));
      else
        % solve normal equations
        X = verifylss(intval(M.mid')*M.mid,M.mid'*(Z+mag(M.rad)*abs(Y)));
      end
      ready = all(all(in0(X,Y)));
      if ~ready
        Ys = intersect(X,Yold); % intersection, therefore M still valid
        if solve_spd
          % solve s.p.d. system
          Xs = verifylss(M.mid,Z+mag(M.rad)*abs(Ys));
        else
          % solve normal equations
          Xs = verifylss(intval(M.mid')*M.mid,M.mid'*(Z+mag(M.rad)*abs(Ys)));
        end
        if any(isnan(Xs(:)))
          ready = 0;
        else
          ready = all(all(in0(Xs,Ys)));
          if ready
            X = Xs;
          end
        end
      end
    end
    
  else
    
    % full interval iteration
    R = inv(y.dx);
    Z = - R * feval(strfun,intval(xs),varargin{:});
    X = Z;
    ready = 0; k = 0; kmax = 10;
    while ( ~ready ) && ( k<kmax ) && ( ~any(isnan(X)) )
      k = k+1;
      if see
        disp(['interval iteration ' sprintf('%d',k)])
      end
      X = hull( X , 0 );              % epsilon inflation
      Y = X + 0.1*rad(X)*hull(-1,1) + midrad(0,realmin);
      Yold = Y;
      if isequal(param(1),'g')
        x = gradientinit(xs+Y);
        y = feval(strfun,x,varargin{:});
        C = eye(n) - R * y.dx;        % automatic gradients
      elseif isequal(param(1),'s')    % use slopes
        x = slopeinit(xs,xs+Y);
        y = feval(strfun,x,varargin{:});
        C = eye(n) - R * y.s;         % automatic slopes
      end
      X = Z + C * Y;
      if any(isnan(X(:)))
        ready = 0;
        break
      end
      ready = all(all(in0(X,Y)));
      if ~ready
        Ys = intersect(X,Yold);
        Xs = Z + C * Ys;
        if any(isnan(Xs(:)))
          ready = 0;
        else
          ready = all(all(in0(Xs,Ys)));
          if ready
            X = Xs;
          end
        end
      end
    end
    
  end
  
  if ready && isempty(find(isnan(Y) | isinf(Y) ,1))
    X = xs+X;                    % verified inclusion
  else
    X = intval(NaN(n,1));        % inclusion failed
  end
  
  % restore warning and exception mode
  warning(wng)
  % restore out-of-range exception mode
  intvalinit(RealStdFctsExcptnMode,0);
  
  if rndold
    setround(rndold)
  end
  
end  % verifynlss
