function options = verifyoptimset(varargin)
%VERIFYOPTIMSET   Create/alter optimization OPTIONS structure, adapted from Matlab
%
%   OPTIONS = OPTIMSET('PARAM1',VALUE1,'PARAM2',VALUE2,...) creates an
%   optimization options structure OPTIONS in which the named parameters have
%   the specified values.  Any unspecified parameters are set to their default.
%
%   OPTIONS = OPTIMSET(OLDOPTS,'PARAM1',VALUE1,...) creates a copy of OLDOPTS
%   with the named parameters altered with the specified values.
%
%   OPTIMSET with no input arguments and no output arguments displays the 
%   default values when verifyglobalmin or verifyconstraintglobalmin is
%   called without or with empty parameter OPTIONS.
%
%   OPTIONS = OPTIMSET (with no input arguments) creates an options structure
%   OPTIONS where all the fields are set to their default.
%
%OPTIMSET PARAMETERS for INTLAB
%  Display  - Level of display (default 0)
%               1    see information on the iteration progress
%               'x'   for 1<=n<=3, plots of the iteration progress,
%                        boxes filled with color 'x'
%               '~'   same but with random color
%               's'   same but only skeleton
%               '.p'  same as above but with pause after some iterations
%  Knownval - known upper bound for the minimum (default [])
%  Boxes    - number of bisection subboxes (default 16)
%  iFunMax  - maximum number of function evaluations (default 1e6)
%  MidpointRule  - Mode of function evaluation over intervals, only effective
%                    for verifyconstraintglobalmin (default 0)
%             0  direct evaluation
%             1  using also midpoint rule
%  TolFun   - Termination tolerance on global minimum [ positive scalar ] (default 1e-8)
%  TolXAbs  - Termination absolute tolerance on inclusions X [ positive scalar ] (default inf)
%  TolXRel  - Termination relative tolerance on inclusions X [ positive scalar ] (default inf)
%  NIT      - Maximum number of global iterations [ positive integer ] (default 3)
%  ND       - Maximum number of local iterations [ positive integer ] (default 2)
%

% written  02/27/17     S.M. Rump
% modified 07/30/17     S.M. Rump  maximum number of evaluations
% modified 10/09/17     S.M. Rump  default number of subboxes
%

  global INTLAB_CONST

  % optFields = {'Display','Knownval','Boxes','iFunMax','MidpointRule','TolFun','TolXAbs','TolXRel','NIT','ND'};
  if nargin==0      % no input arguments
    if nargout==0   % no output arguments, display default values
      disp('Parameters of verified optimization with default')
      disp('    Display      - 0      Level of display (see help verifyoptimset)')
      disp('    Knownval     - []     known upper bound for the minimum')
      disp('    Boxes        - 16     number of bisection subboxes')
      disp('    iFunMax      - 1e6    number of function evaluations')
      disp('    MidpointRule - 0      direct interval evaluation')
      disp('    TolFun       - 1e-8   Termination tolerance on the function value [ positive scalar ]')
      disp('    TolXAbs      - inf    Termination absolute tolerance on X [ positive scalar ]')
      disp('    TolXRel      - inf    Termination relative tolerance on X [ positive scalar ]')
      disp('    NIT          - 3      Maximum number of global iterations [ positive integer ]')
      disp('    ND           - 2      Maximum number of local iterations [ positive integer ]')
      disp(' ')
    else            % one output argument, new options structure, all fields set to their default
      options = [];
      options = setfield(options,'Display',0);
      options = setfield(options,'Knownval',[]);
      options = setfield(options,'Boxes',16);
      options = setfield(options,'iFunMax',1e6);
      options = setfield(options,'MidpointRule',0);
      options = setfield(options,'TolFun',1e-8);
      options = setfield(options,'TolXAbs',inf);
      options = setfield(options,'TolXRel',inf);
      options = setfield(options,'NIT',3);
      options = setfield(options,'ND',2);
    end
    return
  end
  
  % input structure with some values
  if isstruct(varargin{1}) && ( nargin==1 )
    str = varargin{1};
    options = verifyoptimset;
    fields = fieldnames(str);
    for i=1:length(fields)
      options = setfield(options,fields{i},getfield(str,fields{i}));
    end
    return
  end
  
  % at least one input argument
  if isstruct(varargin{1})        % change existing structure
    options = varargin{1};
    Index = 2:2:length(varargin);
  else
    options = INTLAB_CONST.OPTIMSET;
    Index = 1:2:length(varargin);
  end
  for i=Index
    switch lower(varargin{i})
      case 'display', options.Display = varargin{i+1};
      case 'knownval', options.Knownval = varargin{i+1};
      case 'boxes', options.Boxes = varargin{i+1};
      case 'ifunmax', options.iFunMax = varargin{i+1};
      case 'midpointrule', options.MidpointRule = varargin{i+1};
      case 'tolfun', options.TolFun = varargin{i+1};
      case 'tolxabs', options.TolXAbs = varargin{i+1};
      case 'tolxrel', options.TolXRel = varargin{i+1};
      case 'nit', options.NIT = varargin{i+1};
      case 'nd', options.ND = varargin{i+1};
      otherwise
        error('invalid option for verifyoptimset')
    end
  end
end  % verifyoptimset
