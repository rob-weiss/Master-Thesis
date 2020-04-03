function r = gradient(a,str)
%GRADIENT     Gradient class constructor
%
%  r = gradient(a)
%
%An explicit call of the constructor is only necessary to initialize
%  a constant to be of type gradient. Otherwise, any operation
%  with a dependent variable produces a result of type gradient.
%
%For more details try
%
%  help gradientinit
%

%gradient.x stored as is, for example, as vector, matrix, 3D array
%gradient.dx always corresponds to gradient.x(:), stored as column vector
%gradient.dx display: 
%   scalar gradient.x   scalar gradient.dx
%   column gradient.x   matrix gradient.dx, each row is gradient of gradient.x(i)
%   in general          gradient (row) vectors to gradient.x(i,j)               
%

% written  10/16/98     S.M. Rump
% modified 11/30/98     S.M. Rump
% modified 03/22/04     S.M. Rump  random generation for test purposes added
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    sparse gradients
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/24/07     S.M. Rump  isstr replaced by ischar
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/04/14     S.M. Rump  affari added
%

% modified 08/08/04     S.M. Rump  undocumented possibility to set gradient vars individually
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 08/02/14     S.M. Rump  take care of Octave
% modified 08/17/14     S.M. Rump  cure of Matlab6.5 bug deleted
% modified 12/09/15     S.M. Rump  prod(size) to numel(s)
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST
  
  superiorto('intval');
  superiorto('affari');

  if nargin==0
    r.x = [];
    r.dx = [];
    r = class(r,'gradient');
    return
  end
  
  rndold = getround;
  if rndold
    setround(0)
  end

  N = INTLAB_CONST.GRADIENT_NUMVAR;

  if ( N==0 ) && ( nargin<2 )
    error('no dependent variables initialized for use of gradient')
  end

  if nargin==1

    if isa(a,'gradient')
      r = a;
    else
      r.x = a;
      len = numels(r.x);
      INTLAB_GRADIENT_SPARSE = INTLAB_CONST.GRADIENT_SPARSE;
      if N<INTLAB_GRADIENT_SPARSE
        r.dx = zeros(len,N);
      else
        r.dx = sparse([],[],[],len,N);
      end
      r = class(r,'gradient');
    end

  elseif nargin==2
    
    if ischar(str)
      
      if isequal(str,'gradientinit')         % call by gradientinit
        
        r.x = a.init;
        INTLAB_GRADIENT_SPARSE = INTLAB_CONST.GRADIENT_SPARSE;
        if N<INTLAB_GRADIENT_SPARSE
          r.dx = eye(N);
        else
          r.dx = speye(N);
        end
        if isa(r.x,'intval')
          r.dx = intval(r.dx);
        elseif isa(r.x,'affari')
          r.dx = affari(r.dx);
        end
        r = class(r,'gradient');
        
      elseif isequal(str,'gradient')         % call by @intval\gradient
        
        r.x = a.init;
        len = numels(r.x);
        INTLAB_GRADIENT_SPARSE = INTLAB_CONST.GRADIENT_SPARSE;
        if N<INTLAB_GRADIENT_SPARSE
          r.dx = intval(zeros(len,N));
        else
          r.dx = intval(sparse([],[],[],len,N));
        end
        r = class(r,'gradient');
        
      elseif isequal(str,'gradientaff')      % call by @affari\gradient
        
        r.x = a.init;
        len = numels(r.x);
        INTLAB_GRADIENT_SPARSE = INTLAB_CONST.GRADIENT_SPARSE;
        if N<INTLAB_GRADIENT_SPARSE
          r.dx = affari(zeros(len,N));
        else
          r.dx = affari(sparse([],[],[],len,N));
        end
        r = class(r,'gradient');
        
      elseif isequal(str,'gradientintval')   % call by @intval\intval
        
        r.x = intval(a.x);
        r.dx = intval(a.dx);
        r = class(r,'gradient');
        
      elseif isequal(str,'gradientaffari')   % call by @affari\affari
        
        r.x = affari(a.x);
        r.dx = affari(a.dx);
        r = class(r,'gradient');
        
      elseif isequal(str,'random')          % generates .dx randomly, only for test purposes
        
        if isa(a,'struct')                  % input interval
          a = a.init;
        end
        r.x = a;
        len = numels(r.x);
        INTLAB_GRADIENT_SPARSE = INTLAB_CONST.GRADIENT_SPARSE;
        if N<INTLAB_GRADIENT_SPARSE          
          if isreal(r.x)
            r.dx = random(len,N);
          else
            r.dx = randomc(len,N);
          end
        else
          den = max(.2/len,1/N/len);
          if isreal(r.x)
            r.dx = 2*sprand(len,N,den);
            r.dx = r.dx - spones(r.dx);
          else
            r.dx = 2 * ( sprand(len,N,den) + sqrt(-1)*sprand(len,N,den) );
            r.dx = r.dx - (1+sqrt(-1))*spones(r.dx);
          end
        end
        if isa(r.x,'intval')
          r.dx = intval(r.dx);
        elseif isa(r.x,'affari')
          r.dx = affari(r.dx);
        end
        r = class(r,'gradient');
        
      elseif isequal(str,'matrixofvectors')   % special call for global routines
        
        if isstruct(a)
          a = a.init;
        end
        [N,M] = size(a);
        INTLAB_CONST.GRADIENT_NUMVAR = N;
        r.x = a;
        if M==1
          r.dx = eye(N);
        else
          r.dx = repmat(eye(N),M,1);
        end
        if isa(a,'intval')
          r.dx = intval(r.dx);
        end
        r = class(r,'gradient');
        
      else
        error('invalid call of gradient constructor')
      end
      
    else  % individual specification of independent variables
      
      if isstruct(a)
        a = a.init;
      end
      if ~isequal(size(a),size(str))
        error('input "a" and index vector of independent variables have different size')
      end
      if ~isequal(round(str),str)
        error('index vector of independent variables not integer')
      end
      if ( min(str(:))<1 ) | ( max(str(:))>N )
        error('index of independent variables out of range')
      end
      r.x = a;
      len = numels(r.x);
      index = 1:len;
      str = str(:);
      r.dx = sparse(index,str,1,len,N);
      INTLAB_GRADIENT_SPARSE = INTLAB_CONST.GRADIENT_SPARSE;
      if N<INTLAB_GRADIENT_SPARSE
        r.dx = full(r.dx);
      end
      if isa(a,'intval')
        r.dx = intval(r.dx);
      end
      r = class(r,'gradient');
      
    end
    
  else
    
    error('invalid call of constructor gradient')
  end
  
  if rndold
    setround(rndold)
  end
