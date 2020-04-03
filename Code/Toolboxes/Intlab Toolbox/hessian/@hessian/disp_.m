function disp_(c)
%DISP_        Display of interval hessians in "_" notation
%
%   disp_(c)
%

% written  06/04/09     S.M. Rump
% modified 08/26/12     S.M. Rump  global variables removed
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
%

  global INTLAB_CONST
  

  if nargin<2
    name = inputname(1);
    if isempty(name)                    % happens for display(hessianinit(random))
      name = 'ans';
    end
  end
  
  INTLAB_INTVAL_DISPLAY = INTLAB_CONST.INTVAL_DISPLAY;
  INTLAB_CONST.INTVAL_DISPLAY = 'Display_';
  display(c,name)
  INTLAB_CONST.INTVAL_DISPLAY = INTLAB_INTVAL_DISPLAY;
  