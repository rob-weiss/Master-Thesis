function [mu,List,ListS,ListData] = verifyglobalmin(f,x0,opt,varargin)
%VERIFYGLOBALMIN  Global nonlinear system solver
%
%Finds all global minima of a function f:R^n->R within the box x0 and subject 
%to f(x)<=knownval. If f(x)>knownval for all x in x0, the result is empty.
%Regardless of knownval, mu is an inclusion of the global minimum of f within x0.
%
%The function f needs to be in "vectorized form", i.e. [f(x) f(y)] and f([x y]) 
%must be equal. To achieve that, replace operations "o" by ".o" and replace 
%direct access to components x(i) by x(i,:), see "globaldemo" in the
%demo-files.
%If f is a function handle or a character string, this may be achieved 
%by funvec(f); if f is an inline function, it is converted automatically. 
%
%Standard calls
%
%   [ mu , X , XS ] = verifyglobalmin(f,x0)               or
%   [ mu , X , XS , Data ] = verifyglobalmin(f,x0)
%
%or with optional parameters
%
%   [ mu , X , XS , Data ] = verifyglobalmin(f,x0,opt)
%
%The output parameter Data stores data to continue the search, for example by
%
%   [ mu , X , XS ] = verifyglobalmin(Data)
%   for k=1:kmax
%     [ mu , X , XS , Data ] = verifyglobalmin(Data)
%   end
%   
%or, similarly,
%
%   [ mu , X , XS , Data] = verifyglobalmin(Data,opt)
%
%Similarly,
%
%   [ mu , X , XS ] = verifyglobalmin(f,x0,opt,param1,param2,...)   or
%   [ mu , X , XS , Data ] = verifyglobalmin(f,x0,opt,param1,param2,...)
%
%evaluates the function f with extra paramaters.
%
%Upon completion, X is an n x K array, each column containing a local minimum,
%i.e. stationary point with symmetric positive definite Hessian. Moreover, 
%XS is an n x L array with columns possibly containing a local minimum, in 
%particular points on the boundary of x0.
%The global minimum point(s) of f on x0 s.t. f(x)<=knownval are within the 
%boxes on X and XS.
%If X consists of one element and XS is empty, then X is an inclusion of the 
%unique global minimum point of f in x0.
%
%input    f         f:R^n->R, function to find all zeros in x0
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
%             TolFun    Termination tolerance on global minimum
%             TolXAbs   Termination absolute tolerance on inclusions X
%             TolXRel   Termination relative tolerance on inclusions X
%             NIT       optional, default nit = 5
%             ND        optional, default nd  = 3
%output   X         n x K array of K inclusion boxes of unique zeros of f within x0
%         XS        n x L array of L possible inclusion boxes
%         Data      Data to continue search
%
%Parameters in opt may be set by "verifyoptimset":
%   opt = verifyoptimset('knownval',-0.5,'boxes',256);
%or directly
%   [mu,X,Xs] = verifyglobalmin(@(x)gamma(x)-psi(x),infsup(1,5),verifyoptimset('tolxrel',1e-12))
%The List XS of possible inclusion boxes might be long. To collect boxes
%with a significant part in common, use 
%   XS = collectList(XS);
%For long lists that might take a considerable amout of computing time,
%depending on the structure of XS. Therefore, collection in not included
%here. For details and examples, see collectList.
%
%Internally the algorithm is repeated recursively NIT times, where all
%boxes on the list are bisected ND times, respectively. 
%
%Using ideas in
%  O. Knüppel: Einschließungsmethoden zur Bestimmung der Nullstellen 
%     nichtlinearer Gleichungssysteme und ihre Implementierung. 
%     PhD thesis, Hamburg University of Technology, 1994.
%

% written  02/27/17  S.M. Rump
% modified 07/06/17  S.M. Rump  Final check for vectorization: f = @(x) g(g(x))
%                                 may fail (thanks to Thomas Wanner)
% modified 07/19/17  S.M. Rump  optimset
% modified 07/19/17  S.M. Rump  computation of mu
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
    if nargin>1
      opt = verifyoptimset(x0);
    end
    INTLAB_NLSS = Data.INTLAB_NLSS;
    INTLAB_NLSS.mu = intval(Data.mu.sup);
    
  else                                  % first call
    
    if ( ~isintval(x0) ) && ( ~isaffari(x0) )
      error('Constraint box must be intval or affari')
    end
    if size(x0,2)~=1
      error('Input box must be column vector')
    end
    
    INTLAB_NLSS = [];
    initconstants;
    
    INTLAB_NLSS.NLSSALL = 0;
    INTLAB_NLSS.GLOBOPT = 1;
    INTLAB_NLSS.CONSTRAINT = 0;
    
    if nargin<4
      param = {};
    else
      param = varargin;
    end
    INTLAB_NLSS.param = param;
    
    INTLAB_NLSS.F = funvec(f,mid(x0),[],param);  % vectorize f
    checkfunvec(INTLAB_NLSS.F,x0,param);  % check f is vectorized
    
    INTLAB_NLSS.N = size(x0,1);           % number of unknowns

    INTLAB_NLSS.X0 = x0;
    % define slightly extended region
    INTLAB_NLSS.X0_ = INTLAB_NLSS.X0*midrad(1,0.001);
    INTLAB_NLSS.X0rad = rad(INTLAB_NLSS.X0);
    
    % Apply local minimizer
    INTLAB_NLSS.GLOBMIN = inf;
    if nargin<4
      x = fminsearch(INTLAB_NLSS.F,x0.mid,optimset('Display','off'));
    else
      str = 'fparam = @(x) INTLAB_NLSS.F(x,varargin{1}';
      for i=2:length(varargin)
        str = [ str ',varargin{' int2str(i) '}' ];
      end
      eval([str ');'])
      x = fminsearch(fparam,x0.mid);
    end
    if all(in(x,x0))
      if nargin<4
        y = feval(INTLAB_NLSS.F,intval(x));
      else
        y = feval(INTLAB_NLSS.F,intval(x),varargin{:});
      end
      INTLAB_NLSS.GLOBMIN = y.sup;
    else
      INTLAB_NLSS.GLOBMIN = inf;
    end
    
    INTLAB_NLSS.mu = intval(inf);
    INTLAB_NLSS.CurrentX0 = INTLAB_NLSS.X0;
    INTLAB_NLSS.CurrentX0_ = INTLAB_NLSS.X0*midrad(1,1e-8);
    INTLAB_NLSS.kappa = [];          % stores unique solutions and function values
    INTLAB_NLSS.ismin = logical([]); % true if stationary point is minimum
    INTLAB_NLSS.GAMMA = intval([]);  % expanded kapa
    INTLAB_NLSS.DAME = intval([]);   % don't run local optimizer
    
  end 
  
  INTLAB_NLSS.IFUN = 0;
  if refine
    if ( nargin<3 ) || isempty(opt)
      opt = INTLAB_NLSS.opt;
    end
  else
    if ( nargin<3 ) || isempty(opt)
      opt = verifyoptimset;
    else
      opt = verifyoptimset(opt);
    end
  end
  INTLAB_NLSS.opt = opt;
  
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
  
  if INTLAB_NLSS.BOXES<2
    error('bisection into at least two subboxes')
  end
  
  if refine                % refinement
    see = INTLAB_NLSS.SEE;
    if ischar(see)
      INTLAB_NLSS.SEE = 0; % possibly many boxes for refinement
    end
    ListData = verifyglobalrefine(Data);
    INTLAB_NLSS.SEE = see;
  else
    ListData = verifyglobal(x0);
    ListData.Filename = mfilename;
  end
  
  % combine results
  mu = ListData.mu;
  
  ListS = ListData.ListS(1:end-1,:);
  
  if ~isempty(ListData.kappa)
    List = ListData.kappa(1:end-1,ListData.ismin);
    ListS = [ ListS ListData.kappa(1:end-1,~ListData.ismin) ];
  else
    List = [];
  end
  
  if isempty(ListS)
    ListS = [];
  end
  
  if ischar(INTLAB_NLSS.SEE) && ( ~refine )  % first call, not refinement
    plotsmallboxes(List,ListS)
  end
  
  setround(rndold)

end  % verifyglobalmin
