function display(a,name,restricted)
%DISPLAY      Command window display of affine arithmetic
%

% written  04/04/14   S.M. Rump
% modified 04/23/14   S.M. Rump  set/getappdata replaced by global
% modified 05/21/14   S.M. Rump  All zero sparse: 1-by-1
% modified 09/23/15   S.M. Rump  avoid get(0,... in Octave
%

  global INTLAB_CONST

  if nargin<2
    name = inputname(1);
    if isempty(name)                    % happens for display(affari(random))
      name = 'ans';
    end
  end
  
  if nargin<3
    restricted = 0;
  end
  
  if restricted
    title = name;
  else
    title = [ 'affari ' name ];
  end

  if INTLAB_CONST.AFFARI_DISPLAY        % display intervals (default)

    if ~restricted
      disp([ title ' = ' ])
    end
    display(intval(a),[],1);

  else
    
    a = struct(a);
    disp([ title '.mid = ' ])
    disp(a.mid)
    
    disp([ title '.err = ' ])
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if nnz(a.err)
      disp(a.err);
    else
      disp('    []')
    end
    
    disp([ title '.rnderr = ' ])
    disp(a.rnderr);

    disp([ title '.range = ' ])
    disp(a.range);

  end

  if ~INTLAB_CONST.OCTAVE
    if strcmp(get(0,'FormatSpacing'),'loose')
      disp(' '); 
    end
  end
  