function [mu,List,ListS,ListData] = verifyconstraintglobalmin(f,g,x0,opt,varargin)
%VERIFYCONSTRAINTGLOBALMIN  Global constraint minimum
%
%Finds global minima of a function f:R^n->R subject to g(x)=0 for g:R^n->R^m
%within the box x0. If knownval is non-empty, f(x)<=knownval is an
%additional constraint. If knownval=inf, it is assumed that the feasibility
%set is non-empty. 
%If f(x)>knownval for all x in x0, the result is empty.
%Regardless of knownval, mu is an inclusion of the global minimum of f 
%subject to g(x)=0 within x0.
%
%The function f needs to be in "vectorized form", i.e. [f(x) f(y)] and f([x y]) 
%must be equal. To achieve that, replace operations "o" by ".o" and replace 
%direct access to components x(i) by x(i,:). The same applies to g.
%If f is a function handle or a character string, this may be achieved 
%by funvec(f); if f is an inline function, it is converted automatically. 
%
%Standard calls
%
%   [ mu , X , XS ] = verifyconstraintglobalmin(f,g,x0)               or
%   [ mu , X , XS , Data ] = verifyconstraintglobalmin(f,g,x0)
%
%or with optional parameters
%
%   [ mu , X , XS , Data ] = verifyconstraintglobalmin(f,x0,opt)
%
%The output parameter Data stores data to continue the search, for example by
%
%   [ mu , X , XS ] = verifyconstraintglobalmin(Data)             or by
%   for k=1:kmax
%     [ mu , X , XS , Data ] = verifyconstraintglobalmin(Data)
%   end
%
%or, similarly,
%
%   [ mu , X , XS , Data] = verifyconstraintglobalmin(Data,opt)
%
%Similarly,
%
%   [ mu , X , XS ] = verifyconstraintglobalmin(f,g,x0,opt,param1,param2,...)    or
%   [ mu , X , XS , Data] = verifyconstraintglobalmin(f,g,x0,opt,param1,param2,...)
%
%evaluates the function f with extra paramaters.
%
%Upon completion, X is an n x K array, each column containing a local minimum
%of f in x0 s.t. g(x)=0, i.e. stationary points with symmetric positive definite 
%Hessian on the tangent space of g. Moreover, XS is an n x L array, each column 
%possibly containing a local minimum, in particular points on the boundary of x0.
%The global minimum point(s) of f on x0 s.t. g(x)=0 and f(x)<=knownval are 
%within the boxes on X and XS.
%If XS is empty, then the global minimum is in one of the boxes in X. If X
%consists of one box, then this is an inclusion of the unique global minimum 
%point of f in x0 subject to g(x)=0.
%If X and XS are not empty, the global minimum need not to be contained in
%a box in X. That happens if the global minimum is on the boundary of x0
%and/or the global minimum could not be verified to be a stationary point.
%
%input    f         f:R^n->R, function to find all zeros in x0
%         g         g:R^n->R^m, constraint function
%         x0        box to be searched
%         opt.fields  optional, if not specified, default values are used
%             Display   0    no extra display (default)
%                       1    see information on the iteration progress
%                       'x'   for 1<=n<=3, plots of the iteration progress,
%                               boxes filled with color 'x'
%                       '~'   same but with random color
%                       's'   same but only skeleton
%                       '.p'  same as above but with pause after some iterations
%             Knownval  optional known upper bound for the minimum, default is []
%             Boxes     'bisection' into boxes subboxes, default 16
%             iFunMax   maximal number of function evaluations, default 1e6
%             MidpointRule   Mode of function evaluation over intervals (default 0)
%                       0  direct evaluation
%                       1  using also midpoint rule
%             TolFun    Termination tolerance on global minimum
%             TolXAbs   Termination absolute tolerance on inclusions X
%             TolXRel   Termination relative tolerance on inclusions X
%             NIT       optional, default nit = 5
%             ND        optional, default nd  = 3
%output:  mu        inclusion of constraint global minimum
%         X         n x K array of K inclusion boxes local minima of f within x0
%                     s.t. g(x)=0
%         XS        n x L array of L possible inclusion boxes
%         Data      Data to continue search
%
%Parameters in opt may conveniently set by "verifyoptimset":
%   opt = verifyoptimset('knownval',-0.5,'boxes',256);
%The List XS of possible inclusion boxes might be long. To collect boxes
%with a significant part in common, use 
%   XS = collectList(XS);
%For long lists that might take a considerable amout of computing time,
%depending on the structure of XS. Therefore, collection in not included
%here. For details and examples, see collectList.
%
%Internally the algorithm is repeated recursively NIT times, where all
%boxes on the list are bisected ND times into opt.Boxes subboxes. 
%
%Using strategies introduced in 
%  O. Knüppel: Einschließungsmethoden zur Bestimmung der Nullstellen 
%     nichtlinearer Gleichungssysteme und ihre Implementierung. 
%     PhD thesis, Hamburg University of Technology, 1994.
%

% written  02/27/17  S.M. Rump
% modified 07/06/17  S.M. Rump  Final check for vectorization: f = @(x) g(g(x))
%                                 may fail (thanks to Thomas Wanner)
% modified 07/19/17  S.M. Rump  Comment midpoint rule
% modified 07/21/17  S.M. Rump  computation of mu
% modified 07/30/17  S.M. Rump  maximal number of function evaluations
% modified 10/09/17  S.M. Rump  default number of subboxes
% modified 12/12/17  S.M. Rump  check call with correct data
%

  global INTLAB_NLSS
  global INTLAB_CONST
  
  rndold = getround;
  if rndold
    setround(0)
  end
  
  % ignore input out of range; NaN ~ empty
  INTLAB_CONST.RealStdFctsExcptnIgnore = 1;
  % make sure that is reset
  dummy = onCleanup(@()restore);
  
  refine = isstruct(f);
  
  if refine                             % refinement call
    
    Data = f;
    if ~isequal(Data.Filename,mfilename)    % check for data
      error(['Stored data was generated by ' Data.Filename])
    end
    INTLAB_NLSS = Data.INTLAB_NLSS;
    INTLAB_NLSS.mu = intval(Data.mu.sup);
    if ( nargin>1 ) && ( ~isempty(g) )
      opt = verifyoptimset(g);
    else 
      opt = INTLAB_NLSS.opt;
    end
    
  else
    
    if ( ~isintval(x0) ) && ( ~isaffari(x0) )
      error('Constraint box must be intval or affari')
    end
    if size(x0,2)~=1
      error('Input box must be column vector')
    end
    
    INTLAB_NLSS = [];
    initconstants;

    INTLAB_NLSS.NLSSALL = 0;
    INTLAB_NLSS.GLOBOPT = 0;
    INTLAB_NLSS.CONSTRAINT = 1;
    
    if nargin<5
      param = {};
    else
      param = varargin;
    end
    INTLAB_NLSS.param = param;
    
    INTLAB_NLSS.F = funvec(f,mid(x0),[],param);  % vectorize f
    try
      checkfunvec(INTLAB_NLSS.F,x0,param);  % check f is vectorized
    catch
      INTLAB_NLSS.F = f;                    % use original function
      checkfunvec(INTLAB_NLSS.F,x0,param);  % check f is vectorized
    end      
    
    INTLAB_NLSS.G = funvec(g,mid(x0),[],param);  % vectorize g
    try
      M = checkfunvec(INTLAB_NLSS.G,x0);    % check g is vectorized
    catch
      INTLAB_NLSS.G = g;                    % use original function
      M = checkfunvec(INTLAB_NLSS.G,x0);    % check f is vectorized
    end      
    
    INTLAB_NLSS.N = size(x0,1);             % number of unknowns
    INTLAB_NLSS.M = M;                      % number of constraints
    INTLAB_NLSS.M2 = 2^M;                   % number of systems to be solved
    
    x0 = x0(:);                             % create column vector
    e = 1e-12;      % increas lambda interval slightly to cover lambda=1
    INTLAB_NLSS.X0 = [ x0 ; repmat(infsup(-1-e,1+e),M,1) ];
    % define slightly extended region
    INTLAB_NLSS.X0_ = INTLAB_NLSS.X0*midrad(1,0.001);
    INTLAB_NLSS.X0rad = rad(INTLAB_NLSS.X0(1:end-M));
    
    INTLAB_NLSS.GLOBMIN = inf;
    INTLAB_NLSS.mu = intval(inf);
    INTLAB_NLSS.CurrentX0 = INTLAB_NLSS.X0;
    INTLAB_NLSS.CurrentX0_ = INTLAB_NLSS.X0*midrad(1,1e-8);
    INTLAB_NLSS.kappa = [];          % stores unique solutions and function values
    INTLAB_NLSS.ismin = logical([]); % true if stationary point is minimum
    INTLAB_NLSS.GAMMA = intval([]);  % expanded kapa
    INTLAB_NLSS.DAME = intval([]);   % don't run local optimizer
    
    if ( nargin<4 ) || isempty(opt)
      opt = verifyoptimset;
    else
      opt = verifyoptimset(opt);
    end
    
    if isempty(opt.Knownval)
      INTLAB_NLSS.GLOBMIN = inf;
      INTLAB_NLSS.feasible = false;
    else
      INTLAB_NLSS.feasible = true;
    end
    
  end
  
  INTLAB_NLSS.opt = opt;
  INTLAB_NLSS.IFUN = 0;
  
  INTLAB_NLSS.SEE = opt.Display;
  INTLAB_NLSS.BOXES = opt.Boxes;
  INTLAB_NLSS.IFUNMAX = opt.iFunMax;
  if ~isempty(opt.Knownval)
    INTLAB_NLSS.GLOBMIN = min(INTLAB_NLSS.GLOBMIN,opt.Knownval);
  end
  INTLAB_NLSS.MIDPOINTRULE = opt.MidpointRule;
  INTLAB_NLSS.TOLFUN = opt.TolFun;
  INTLAB_NLSS.TOLXABS = opt.TolXAbs;
  INTLAB_NLSS.TOLXREL = opt.TolXRel;
  INTLAB_NLSS.NIT = opt.NIT;
  INTLAB_NLSS.ND = opt.ND;
  
  if ischar(INTLAB_NLSS.SEE) && ( INTLAB_NLSS.N>3 )
    warning('Graphical output up to 3 unknowns')
    INTLAB_NLSS.SEE = 1;
  end
    
  if ( nargin>=5 ) && refine
    error('parameters already specified.')
  end
  
  INTLAB_NLSS.Fb = @cminfeval;

  if refine
    see = INTLAB_NLSS.SEE;
    if ischar(see)
      INTLAB_NLSS.SEE = 1; % possibly many boxes for refinement
    end
    ListData = Data;
    mu = intval(ListData.mu.sup);
    for j=1:INTLAB_NLSS.M2
      INTLAB_NLSS.Lindex = j;
      ListData = verifyglobalrefine(ListData);
      mu = min(mu,ListData.mu);
    end
    INTLAB_NLSS.SEE = see;
  else      % first call
    mu = inf;
    ListData.Filename = mfilename;
    ListData.DAME = [];
    ListData.kappa = [];
    ListData.GAMMA = [];
    ListData.ismin = [];
    for j=1:INTLAB_NLSS.M2
      INTLAB_NLSS.Lindex = j;
      ListData = verifyglobal(INTLAB_NLSS.X0,ListData);
      mu = min(mu,ListData.mu);
    end
  end
  
  % combine results
  ListData.mu = mu;

  ListS = ListData.ListS{1};
  for i=2:length(ListData.ListS)
    ListS = [ ListS ListData.ListS{i}];
  end
  
  if isempty(ListData.kappa)
    List = [];
  else
    List = ListData.kappa(1:end-INTLAB_NLSS.M-1,ListData.ismin);
    ListS = [ ListS ListData.kappa(:,~ListData.ismin) ];
  end
  
  if isempty(ListS)
    ListS = [];
  else
    ListS = ListS(1:end-INTLAB_NLSS.M-1,:);
    if size(ListS,2)<1e4        % may be slow
      ListS = collectList(ListS);
    end
  end
  
  if ischar(INTLAB_NLSS.SEE) && ( ~refine )  % first call, not refinement
    fig = gcf;
    if ~isreal(fig)
      fig = fig.Number;
    end
    for i=fig-INTLAB_NLSS.M2+1:fig
      figure(i)
      plotsmallboxes(List,ListS)
    end
  end
  
  setround(rndold)

end  % verifyconstraintglobalmin


function [y,yy,lambda,Jb,J,Jg] = cminfeval(f,g,x,index)
%function evaluation for verifyconstraintglobalmin
%Bordered system F:R^(n+m)->R^(n+m)
%  df + lambda*dg = 0
%               g = 0
% 
% input  f       f:R^n->R function to be minimized
%        g       g:R^n->R^m constraint g(x)=0
%        x       argument for bordered f (including lambda)
%        index   intersection for lambda
%        fun     first or second function
% output y       function value of bordered system
%        yy.f    function value of original system
%        yy.g    function value of constraint
%        lambda  improved multiplier
%        Jb      Jacobian of bordered system
%        J       Jacobian of unbordered system
%        Jg      Jacobian of g
%

  global INTLAB_NLSS
  N = INTLAB_NLSS.N;
  M = INTLAB_NLSS.M;

  lambda = x(end-M+1:end,:);
  if ( index==-1 )
    xh = gradient(x(1:N,:),'matrixofvectors');
  else
    xh = hessianinit(x(1:N));     % must be scalar
  end
  if isempty(INTLAB_NLSS.param)
    yf = feval(f,xh);
  else
    yf = feval(f,xh,INTLAB_NLSS.param{:});
  end
  yg = feval(g,xh);
  if INTLAB_NLSS.MIDPOINTRULE && isa(x,'intval')  % midpoint evaluation
    if size(x,2)==1
      Jf = yf.dx';
      Jg = yg.dx';
    else
      Jf = permute(yf.dx,[2 3 1])';
      Jg = permute(yg.dx,[2 3 1])';
    end
    xs = mid(xh.x);
    yy.f = intersect( f(intval(xs)) + sum(Jf.*(xh.x-xs),1) , yf.x );
    yy.g = intersect( g(intval(xs)) + sum(Jg.*(xh.x-xs),1) , yg.x );
  else
    yy.f = yf.x;
    yy.g = yg.x;
  end
  yy.gdx = yg.dx;
  if M==1                 % one constraint
    fun = getfunindex;    % current function
    %   yfdx = squeeze(yf.dx)'; % problems in older Matlab versions
    %   ygdx = squeeze(yg.dx)';
    if size(x,2)==1
      yfdx = yf.dx';
      ygdx = yg.dx';
    else
      yfdx = permute(yf.dx,[2 3 1])';
      ygdx = permute(yg.dx,[2 3 1])';
    end
    if index              % initial lambda will be sharpened
      if fun==1
        Num = -yfdx;
        Den = ygdx;
      else
        Num = -ygdx;
        Den = yfdx;
      end
      q = Num./Den;
      I = in(0,Den) & ( ~in(0,Num) ) & ( ~isnan(Num) ) & ( ~isnan(Den) );
      if any(I)         % special treatment of a/0
        q(I) = zeroQuotient(Num(I),Den(I));
      end
      % take care of Den=0 (input out of range of division,
      % but here check whether suitable lambda exists
      I = ( Den==0 ) & in(0,Num);
      if any(I)
        q(I) = infsup(-1,1);
      end
      % min/max not correct; NaN is checked by isnan(lambda)
      nanindex = isnan(lambda);
      lambdainf = max(bsxfun(@max,lambda.inf,q.inf),[],1);
      lambdasup = min(bsxfun(@min,lambda.sup,q.sup),[],1);
      lambda = intval(lambdainf,lambdasup,'infsup');
      nanindex = nanindex | ( lambdainf > lambdasup );
      if any(nanindex)
        lambda(nanindex) = NaN;
      end
      % if 0 in ygdx, then mu=0 solves the second system [mu*f'+g';g]=0
    end
    if fun==1
      y = [ yfdx+repmat(lambda,N,1).*ygdx ; yg.x ];
    else
      y = [ repmat(lambda,N,1).*yfdx+ygdx ; yg.x ];
    end
    if nargout<=3         % Call to initialize inclusion iteration or bisection
      return
    end
    if fun==1
      J = yf.hx + lambda*yg.hx;   % only for K=1
      Jb = [ J yg.dx' ; yg.dx 0 ];
    else
      J = lambda*yf.hx + yg.hx;   % only for K=1
      Jb = [ J yf.dx' ; yg.dx 0 ];
    end
    Jg = yg.dx;
  else                          % several constraints
    K = size(x,2);
    [I,J] = getfunindex;
    %   yfdx = squeeze(yf.dx)'; % problems in older Matlab versions
    %   ygdx = squeeze(yg.dx)';
    if K==1
      yfdx = yf.dx';
      ygdx = yg.dx';
    else
      yfdx = permute(yf.dx,[2 3 1])';
      yfdx = yfdx(:);
      ygdx = reshape(permute(yg.dx,[3 2 1]),N*K,M);
    end
    cont = 1;
    while cont
      lambdaold = lambda;
      if index                % initial lambda will be sharpened
        for i=1:M             % try to sharpen lambda(i)
          if ismember(i,J)    % lambda_i is factor for nabla f
            factor = lambda;
            factor(J,:) = 1;
            factor_g = reshape(repmat(factor,N,1),M,N*K)';
            g_part = sum(ygdx.*factor_g,2);
            JJ = setdiff(J,i);
            if isempty(JJ)
              Num = -g_part;
              Den = yfdx;
            else
              factor_f = repmat(prod(lambda(JJ,:),1),N,1);
              Num =  -g_part;
              Den = factor_f(:).*yfdx;
            end
          else                % lambda_i is factor for nabla_i g
            factor_f = repmat(prod(lambda(J,:),1),N,1);
            f_part = factor_f(:).*yfdx;
            factor = lambda;
            factor(J,:) = 1;
            factor(i,:) = 0;
            factor_g = reshape(repmat(factor,N,1),M,N*K)';
            g_part = sum(ygdx.*factor_g,2);
            Num =  -( f_part + g_part );
            Den = ygdx(:,i);
          end
          q = reshape( Num ./ Den , N,K );    % Num,Den column vectors
          I = ( ~in(0,Num) ) & in(0,Den) & ( ~isnan(Num) ) & ( ~isnan(Den) );
          if any(I)         % special treatment of a/0, I is matrix
            q(I) = zeroQuotient(Num(I),Den(I));
          end
          % take care of Den=0 (input out of range of division, 
          % but here check whether suitable lambda exists
          I = ( Den==0 ) & in(0,Num);
          if any(I)
            q(I) = infsup(-1,1);
          end
          % min/max not correct; NaN is checked by isnan(lambda)
          nanindex = any(isnan(lambda),1);
          lambdainf = max(bsxfun(@max,lambda.inf(i,:),q.inf),[],1);
          lambdasup = min(bsxfun(@min,lambda.sup(i,:),q.sup),[],1);
          lambda(i,:) = intval(lambdainf,lambdasup,'infsup');
          nanindex = nanindex | any( lambdainf > lambdasup ,1) | any(isnan(q),1);
          if any(nanindex)
            lambda(i,nanindex) = NaN;
          end
        end
      end
      cont = ~isequalwithequalnans(lambda,lambdaold);
    end
    factor_f = repmat(prod(lambda(J,:),1),N,1);
    f_part = factor_f(:).*yfdx;
    factor = lambda;
    factor(J,:) = 1;
    factor_g = reshape(repmat(factor,N,1),M,N*K)';
    g_part = sum(ygdx.*factor_g,2);
    y = [ reshape(f_part+g_part,N,K); yg.x ];
    if nargout<=3           % Call to initialize inclusion iteration or bisection
      return
    end
    yghx = reshape(yg.hx,N,N,M);    % only for K=1
    if isempty(J)
      J = yf.hx;
    else
      J = prod(lambda(J))*yf.hx;
    end
    for i=1:M
      if ismember(i,I)
        J = J + yghx(:,:,i)*lambda(i);
      else
        J = J + yghx(:,:,i);
      end
    end
    Jb = [ J yg.dx' ; yg.dx zeros(M) ];
    Jg = yg.dx;
  end
  
end  % function cminfeval


function q = zeroQuotient(N,D)
% N and D vectors of same size, ~in(0,N), in(0,D)
% possible q in [-1,1] s.t. q*D=N
  q = intval(inf(size(N)));
  Den = hull(D.inf,-realmin);
  Q1 = intersect(N./Den,infsup(-1,1));
  notnanQ1 = ( ~isnan(Q1) ) & ( D.inf~=0 );
  Den = hull(realmin,D.sup);
  Q2 = intersect(N./Den,infsup(-1,1));
  notnanQ2 = ( ~isnan(Q2) ) & ( D.sup~=0 );
  q(notnanQ1) = Q1(notnanQ1);
  q(notnanQ2) = Q2(notnanQ2);
  q(notnanQ1 & notnanQ2) = infsup(-1,1);
end  % function zeroQuotient
