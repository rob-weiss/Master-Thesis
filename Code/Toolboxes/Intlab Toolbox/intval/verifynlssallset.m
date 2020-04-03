function options = verifynlssallset(varargin)
%VERIFYNLSSALLSET   Create/alter verifynlssall OPTIONS structure, adapted from Matlab
%
%   OPTIONS = VERIFYNLSSALLSET('PARAM1',VALUE1,'PARAM2',VALUE2,...) creates an
%   nlss options structure OPTIONS in which the named parameters have
%   the specified values.  Any unspecified parameters are set to their default.
%
%   OPTIONS = VERIFYNLSSALLSET(OLDOPTS,'PARAM1',VALUE1,...) creates a copy of OLDOPTS
%   with the named parameters altered with the specified values.
%
%   VERIFYNLSSALLSET with no input arguments and no output arguments displays the 
%   default values when verifynlssall is called without or with empty parameter 
%   OPTIONS.
%
%   OPTIONS = OPTIMSET (with no input arguments) creates an options structure
%   OPTIONS where all the fields are set to their default.
%
%OPTIMSET PARAMETERS for INTLAB
%  Display  - Level of display
%               1    see information on the iteration progress
%               'x'   for 1<=n<=3, plots of the iteration progress,
%                        boxes filled with color 'x'
%               '~'   same but with random color
%               's'   same but only skeleton
%               '.p'  same as above but with pause after some iterations
%  Boxes    - number of bisection subboxes, default 64
%  iFunMax   maximal number of function evaluations, default 1e5
%  TolXAbs  - Termination absolute tolerance on inclusions X [ positive scalar ]
%  TolXRel  - Termination relative tolerance on inclusions X [ positive scalar ]
%  NIT      - Maximum number of global iterations [ positive integer ]
%  ND       - Maximum number of local iterations [ positive integer ]
%

% written  02/27/17     S.M. Rump
% modified 07/30/17     S.M. Rump  maximum number of evaluations
% modified 10/09/17     S.M. Rump  default number of subboxes
%

  global INTLAB_CONST

  if nargin==0      % no input arguments
    if nargout==0   % no output arguments, display values
      disp('Parameters of verifynlssall with default')
      disp('    Display  - 0     Level of display (see help verifynlssallset)')
      disp('    Boxes    - 64    number of bisection subboxes')
      disp('    iFunMax  - 1e5   maximal number of function evaluations')
      disp('    TolXAbs  - 1e-8  Termination absolute tolerance on X [ positive scalar ]')
      disp('    TolXRel  - 1e-4  Termination relative tolerance on X [ positive scalar ]')
      disp('    NIT      - 5     Maximum number of global iterations [ positive integer ]')
      disp('    ND       - 3     Maximum number of local iterations [ positive integer ]')
      disp(' ')
    else            % one output argument, new options structure, all fields set to their default
      options = [];
      options = setfield(options,'Display',0);
      options = setfield(options,'Boxes',64);
      options = setfield(options,'iFunMax',1e5);
      options = setfield(options,'TolXAbs',1e-8);
      options = setfield(options,'TolXRel',1e-4);
      options = setfield(options,'NIT',5);
      options = setfield(options,'ND',3);
    end
    return
  end
  
  % at least one input argument
  if isstruct(varargin{1})        % change existing structure
    options = varargin{1};
    Index = 2:2:length(varargin);
  else                            % create new structure
    options = INTLAB_CONST.NLSSALLSET;
    Index = 1:2:length(varargin);
  end
  for i=Index
    switch lower(varargin{i})
      case 'display', options.Display = varargin{i+1};
      case 'boxes', options.Boxes = varargin{i+1};
      case 'ifunmax', options.iFunMax = varargin{i+1};
      case 'tolxabs', options.TolXAbs = varargin{i+1};
      case 'tolxrel', options.TolXRel = varargin{i+1};
      case 'nit', options.NIT = varargin{i+1};
      case 'nd', options.ND = varargin{i+1};
      otherwise
        error('invalid option for verifynlssallset')
    end
  end
end  % verifynlssallset
