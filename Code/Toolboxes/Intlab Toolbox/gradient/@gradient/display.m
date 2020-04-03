function display(c,name)
%DISPLAY      Command window display of gradient
%
%Gradients of row vectors are 3-dimensional arrays. Therefore the gradient .dx
%  of a sparse array with more than one column is displayed as full gradient.
%

%Second parameter name for internal purposes
%

% written  10/16/98     S.M. Rump
% modified 11/06/99     S.M. Rump  omit ans
% modified 03/07/04     S.M. Rump  output changed to gradients of individual components
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    take care of Matlab sparse Inf/NaN bug
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 02/11/06     S.M. Rump  SparseInfNanFlag removed
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 08/26/12     S.M. Rump  global variables removed
% modified 10/05/12     S.M. Rump  comment to sparse data
% modified 04/04/14     S.M. Rump  affari added
% modified 04/04/14     S.M. Rump  end function
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

  INTLAB_GRADIENT_NUMVAR = INTLAB_CONST.GRADIENT_NUMVAR;

  if INTLAB_CONST.OCTAVE
    loose = false;
  else
    loose = strcmp(get(0,'FormatSpacing'),'loose');
  end

  if nargin<2
    name = inputname(1);
    if isempty(name)                    % happens for display(gradientinit(random))
      name = 'ans';
    end
  end

  numvar = size(c.dx,2);
  if numvar~=INTLAB_GRADIENT_NUMVAR
    warning('**** number of dependent variables and partial derivatives do not coincide')
  end

  sizecx = size(c.x);
  if isa(c.x,'intval')
    type = 'intval ';
  elseif isa(c.x,'affari')
    type = 'affari ';
  else
    type = '';
  end
  
  % display .x
  if loose, disp(' '); end
  disp([ type 'gradient value ' name '.x = ' ])
  if isempty(type)
    disp(c.x);
  else
    display(c.x,[],1);
  end
  
  % display .dx
  if loose, disp(' '); end
  if ( sizecx(2)==1 ) && ( length(sizecx)==2 )   % scalar or column vector
    disp([ type 'gradient derivative(s) ' name '.dx = ' ])
    if isempty(type)
      disp(c.dx);
    else
      display(c.dx,[],1);
    end
  else
    title = [ type 'gradient derivative(s) ' ];
    index = ones(1,length(sizecx));
    for i=1:prod(sizecx)
      temp = reshape(c.dx(i,:),1,numvar);
      str = [title name '.dx('];
      for j=1:length(index)
        str = [str int2str(index(j)) ','];
      end
      disp([str ':) = '])
      if isempty(type)
        disp(temp);
      else
        display(temp,title,1);
      end
      index = nextindex(index,sizecx);
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
