function options = verifynlssparamset(varargin)
%VERIFYNLSSPARAMSET   Create/alter nlssparam OPTIONS structure, adapted from Matlab
%
%   OPTIONS = VERIFYNLSSPARAMSET('PARAM1',VALUE1,'PARAM2',VALUE2,...) creates an
%   nlssparam options structure OPTIONS in which the named parameters have
%   the specified values.  Any unspecified parameters are set to their default.
%
%   OPTIONS = VERIFYNLSSPARAMSET(OLDOPTS,'PARAM1',VALUE1,...) creates a copy of OLDOPTS
%   with the named parameters altered with the specified values.
%
%   VERIFYNLSSPARAMSET with no input arguments and no output arguments displays the 
%   default values when verifynlssparamall is called without or with empty parameter 
%   OPTIONS.
%
%   OPTIONS = OPTIMSET (with no input arguments) creates an options structure
%   OPTIONS where all the fields are set to their default.
%
%OPTIMSET PARAMETERS for INTLAB
%  Display   0    no extra display (default)
%            1    for 1<=n<=3, plots of the solution set
%            inf  plot also discarded boxes
%  Boxes     64   each step bisection into how many boxes
%  Method    Evaluation method
%              'intval'   standard interval evaluation
%              'midrule'  standard interval evaluation together with
%                            midpoint rule
%              'slope'    slope evaluation
%              'affari'   affine arithmetic evaluation
%  iFunMax   maximal number of function evaluations, default 1e5
%  TolXAbs   Termination absolute tolerance solution boxes, default 1e-5
%  TolXRel   Termination relative tolerance solution boxes, default 1e-3
%

% written  02/27/17     S.M. Rump
% modified 07/30/17     S.M. Rump  maximum number of evaluations
% modified 10/09/17     S.M. Rump  default number of subboxes
% modified 11/17/17     S.M. Rump  variable names
%

  global INTLAB_CONST

  if nargin==0      % no input arguments
    if nargout==0   % no output arguments, display values
      disp('Parameters of parameter identification routine verifynlssparamset with default')
      disp('    Display  - 0          Level of display (see help verifynlssparamset)')
      disp('    Boxes    - 64         Each step bisection into how many boxes')
      disp('    Method   - ''intval''   Method of evaluation (see help verifynlssparamset)')
      disp('    iFunMax  - 1e5        maximal number of function evaluations')
      disp('    TolXAbs  - 1e-5       Termination absolute tolerance on X [ positive scalar ]')
      disp('    TolXRel  - 1e-3       Termination relative tolerance on X [ positive scalar ]')
      disp(' ')
    else            % one output argument, new options structure, all fields set to their default
      options = [];
      options = setfield(options,'Display',0);
      options = setfield(options,'Boxes',64);
      options = setfield(options,'Method','intval');
      options = setfield(options,'iFunMax',1e5);
      options = setfield(options,'TolXAbs',1e-5);
      options = setfield(options,'TolXRel',1e-3);
    end
    return
  end
  
  % at least one input argument
  if isstruct(varargin{1})        % change existing structure
    options = varargin{1};
    Index = 2:2:length(varargin);
  else                            % create new structure
    options = INTLAB_CONST.PARAMSET;
    Index = 1:2:length(varargin);
  end
  for i=Index
    switch lower(varargin{i})
      case 'display', options.Display = varargin{i+1};
      case 'boxes', options.Boxes = varargin{i+1};
      case 'method', options.Method = varargin{i+1};
      case 'ifunmax', options.iFunMax = varargin{i+1};
      case 'tolxabs', options.TolXAbs = varargin{i+1};
      case 'tolxrel', options.TolXRel = varargin{i+1};
      otherwise
        error('invalid option for verifynlssparamset')
    end
  end
end  % verifynlssparamset
