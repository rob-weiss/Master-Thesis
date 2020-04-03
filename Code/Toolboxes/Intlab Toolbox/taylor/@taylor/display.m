function display(c,name)
%DISPLAY      Command window display of Taylor
%

%Second parameter name for internal purposes
%

% written  05/21/09     S.M. Rump
% modified 08/26/12     S.M. Rump  global variables removed
% modified 10/07/12     S.M. Rump  complete redesign
% modified 04/04/14     S.M. Rump  end function
% modified 04/04/14     S.M. Rump  affari added
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
% modified 09/23/15     S.M. Rump  avoid get(0,... in Octave
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST
  
  rndold = getround;
  if rndold
    setround(0)
  end

  INTLAB_TAYLOR_ORDER = INTLAB_CONST.TAYLOR_ORDER;

  if INTLAB_CONST.OCTAVE
    loose = false;
  else
    loose = strcmp(get(0,'FormatSpacing'),'loose');
  end

  if nargin<2
    name = inputname(1);
    if isempty(name)                    % happens for display(taylorinit(random))
      name = 'ans';
    end
  end

  numvar = size(c.t,1)-1;
  if numvar~=INTLAB_TAYLOR_ORDER
    warning('**** number of dependent variables and partial derivatives do not coincide')
  end

  if isa(c.t,'intval')
    type = 'intval ';
  elseif isa(c.t,'affari')
    type = 'affari ';
  else
    type = '';
  end
      
  if loose, disp(' '); end
  disp([ type 'Taylor ' name '.t =' ])
  if isempty(c)
    disp('   empty Taylor variable')
    if rndold
      setround(rndold)
    end
    return
  end
  if ( c.size(2)==1 ) && ( length(c.size)==2 )   % scalar or column vector
    if isempty(type)
      disp(c.t.');
    else
      display(c.t.',[],1);
    end
  else
    NN = size(c.t,1);
    index = ones(1,length(c.size));
    for i=1:prod(c.size)
      temp = reshape(c.t(:,i),1,NN);
      str = [name '.t('];
      for j=1:length(index)
        str = [str int2str(index(j)) ','];
      end
      disp([str ':) = '])
      if isempty(type)
        disp(temp);
      else
        display(temp,[],1);
      end
      index = nextindex(index,c.size);
    end
  end
  
  if loose, disp(' '); end
  
  if rndold
    setround(rndold)
  end
  
end  % function display

  
function index = nextindex(index,size)
% compute next multi-index subject to size
  i=1;
  while i<=length(size)
    index(i) = index(i)+1;
    if index(i)<=size(i)
      return
    end
    index(i) = 1;
    i = i+1;
  end
end  % function nextindex
  