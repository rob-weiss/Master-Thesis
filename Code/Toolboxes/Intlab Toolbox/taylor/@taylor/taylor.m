function r = taylor(a,str)
%TAYLOR       Taylor class constructor
%
%  r = taylor(a)
%
%An explicit call of the constructor is only necessary to initialize
%  a constant to be of type taylor. Otherwise, any operation
%  with a dependent variable produces a result of type taylor.
%
%For more details try
%
%  help taylorinit
%
%and demotaylor.
%

%taylor.size is size of input
%taylor.t stored as column vector of length INTLAB_TAYLOR_ORDER; in case of 
%vector or matrix input, columns of taylor.t are the Taylor coefficients
%

% written  05/21/09     S.M. Rump
% modified 02/28/10     S.M. Rump  rounding
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/04/14     S.M. Rump  affari added
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 04/27/14     S.M. Rump  empty variable
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST

  superiorto('intval');
  superiorto('affari');

  if nargin==0
    r.size = [];
    r.t = [];
    r = class(r,'taylor');
    return
  end
  
  INTLAB_TAYLOR_ORDER = INTLAB_CONST.TAYLOR_ORDER;

  if INTLAB_TAYLOR_ORDER==0
    error('no dependent variables initialized for use of Taylor')
  end

  rndold = getround;
  if rndold
    setround(0)
  end

  if nargin==1

    if isa(a,'taylor')
      r = a;
    else
      r.size = size(a);      
      len = prod(r.size);
      r.t = [ a(:).' ; zeros(INTLAB_TAYLOR_ORDER,len) ];
      r = class(r,'taylor');
    end

  elseif nargin==2
    
    if ischar(str)
      
      if isequal(str,'taylorinit')         % call by taylorinit
        
        r.size = size(a.init);
        len = prod(r.size);
        r.t = [ a.init(:).' ; ones(1,len) ; zeros(INTLAB_TAYLOR_ORDER-1,len) ];
        r = class(r,'taylor');

      elseif isequal(str,'taylor')         % call by @intval\taylor
        
        r.size = size(a.init);
        len = prod(r.size);
        r.t = intval([ a.init(:).' ; zeros(INTLAB_TAYLOR_ORDER,len) ]);
        r = class(r,'taylor');
        
      elseif isequal(str,'taylorintval')   % call by @intval\intval
        
        r = a;
        r.t = intval(r.t);
        
      elseif isequal(str,'tayloraffari')   % call by @affari\affari
        
        r = a;
        r.t = affari(r.t);
        
      elseif isequal(str,'random')          % generates .t randomly, only for test purposes
        
        if isa(a,'struct')                  % input interval
          a = a.init;
        end
        r.size = size(a);
        len = prod(r.size);
        r.t = [ a(:).' ; randn(INTLAB_TAYLOR_ORDER,len) ];
        r = class(r,'taylor');
        
      else
        error('invalid call of taylor constructor')
      end
      
    end
      
  else
    
    error('invalid call of constructor taylor')
    
  end
  
  if rndold
    setround(rndold)
  end
