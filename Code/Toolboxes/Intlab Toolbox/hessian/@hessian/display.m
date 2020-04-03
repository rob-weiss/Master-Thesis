function display(c,name)
%DISPLAY      Command window display of hessian
%
%First and second derivative of Hessians are stored sparse if the number of dependent variables
%exceeds a certain constant (or details, see hessianinit).
%
%To change the display of a hessian variable "u" use
%
%   full(u)   or   sparse(u) .
%
%Careful, if the number of independent variables is large and full storage of second derivatives is
%chosen, output may become large.
%

%Second parameter name for internal purposes
%

% written  04/04/04     S.M. Rump
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 02/11/06     S.M. Rump  SparseInfNanFlag removed
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/04/14     S.M. Rump  complete redesign, affari added
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
% modified 09/23/15     S.M. Rump  avoid get(0,... in Octave
%

  global INTLAB_CONST
  
  if nargin<2
    name = inputname(1);
    if isempty(name)                    % happens for display(hessianinit(random))
      name = 'ans';
    end
  end
  
  INTLAB_HESSIAN_NUMVAR = INTLAB_CONST.HESSIAN_NUMVAR;

  if INTLAB_CONST.OCTAVE
    loose = false;
  else
    loose = strcmp(get(0,'FormatSpacing'),'loose');
  end
  
  numvar = size(c.dx,1);
  if numvar~=INTLAB_HESSIAN_NUMVAR      % this should never happen
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
  disp([ type 'Hessian value ' name '.x = ' ])
  if isempty(type)
    disp(c.x);
  else
    display(c.x,[],1);
  end
  
  % display .dx
  if loose, disp(' '); end
  if ( sizecx(2)==1 ) && ( length(sizecx)==2 )   % scalar or column vector
    disp([ type 'Hessian derivative(s) ' name '.dx = ' ])
    if isempty(type)
      disp(c.dx);
    else
      display(c.dx,[],1);
    end
  else
    title = [ type 'Hessian derivative(s) ' ];
    index = ones(1,length(sizecx));
    for i=1:prod(sizecx)
      temp = reshape(c.dx(:,i),1,numvar);
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
  
  % display .hx
  if loose, disp(' '); end
  nn = prod(sizecx);
  if nn==1                  % one variable
    temp = reshape(c.hx,numvar,numvar);
    temp = temp + transpose(temp);
    disp([ type 'Hessian second derivative(s) value ' name '.hx = ' ])
    if loose, disp(' '); end
    if isempty(type)
      disp(temp);
    else
      display(temp,[],1);
    end
  else                      % several variables
    title = [ type 'Hessian second derivative(s) ' ];
    index = ones(1,length(sizecx));
    for i=1:nn
      % cures Matlab bug:  a=sparse([],[],[],1,1); reshape(a,1,1)*2  is not zero
      if any(find(c.hx(:,i)))
        temp = reshape(c.hx(:,i),numvar,numvar);
        temp = temp + transpose(temp);
      else
        if issparse(c.hx)
          temp = sparse([],[],[],numvar,numvar);
        else
          temp = zeros(numvar);
        end
        if isa(c.hx,'intval')
          temp = intval(temp);
        elseif isa(c.hx,'affari')
          temp = affari(temp);
        end
      end
      str = [title name '.hx('];
      for j=1:length(index)
        str = [str int2str(index(j)) ','];
      end
      disp([str ':,:) = '])
      if isempty(type)
        disp(temp);
      else
        display(temp,title,1);
      end
      index = nextindex(index,sizecx);
    end
  end
  
  if loose, disp(' '); end

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
