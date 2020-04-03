function midrad(c)
%MIDRAD       Display of interval gradients in midrad notation
%
%   midrad(c)
%

% written  10/16/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    take care of Matlab sparse Inf/NaN bug
% modified 02/11/06     S.M. Rump  SparseInfNanFlag removed
% modified 06/04/09     S.M. Rump  Comment
% modified 08/26/12     S.M. Rump  global variables removed
% modified 10/05/12     S.M. Rump  complete redesign
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
%

  global INTLAB_CONST
  
  INTLAB_GRADIENT_NUMVAR = INTLAB_CONST.GRADIENT_NUMVAR;

  numvar = size(c.dx,2);
  if numvar~=INTLAB_GRADIENT_NUMVAR
    warning('**** number of dependent variables and partial derivatives do not coincide')
  end
  
  name = inputname(1);
  if isempty(name)                    % happens for display(gradientinit(random))
    name = 'ans';
  end

  INTLAB_INTVAL_DISPLAY = INTLAB_CONST.INTVAL_DISPLAY;
  INTLAB_CONST.INTVAL_DISPLAY = 'DisplayMidrad';
  display(c,name)
  INTLAB_CONST.INTVAL_DISPLAY = INTLAB_INTVAL_DISPLAY;
  