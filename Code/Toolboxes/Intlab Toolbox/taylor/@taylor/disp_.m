function disp_(c)
%DISP_        Display of interval Taylor in "_" notation
%
%   disp_(c)
%

% written  05/21/09     S.M. Rump
% modified 08/26/12     S.M. Rump  global variables removed
% modified 10/07/12     S.M. Rump  complete redesign
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
%

  global INTLAB_CONST
  

  INTLAB_TAYLOR_ORDER = INTLAB_CONST.TAYLOR_ORDER;
 
  name = inputname(1);
  if isempty(name)                    % happens for display(taylorinit(random))
    name = 'ans';
  end

  numvar = size(c.t,1)-1;
  if numvar~=INTLAB_TAYLOR_ORDER
    warning('**** number of dependent variables and partial derivatives do not coincide')
  end

  INTLAB_INTVAL_DISPLAY = INTLAB_CONST.INTVAL_DISPLAY;
  INTLAB_CONST.INTVAL_DISPLAY = 'Display_';
  display(c,name)
  INTLAB_CONST.INTVAL_DISPLAY = INTLAB_INTVAL_DISPLAY;
