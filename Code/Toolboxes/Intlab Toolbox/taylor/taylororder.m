function k = taylororder
%TAYLORORDER  Order of Taylor evaluations
%
%   k = taylororder
%
%In the current initialization of the Taylor package, Taylor coefficients
%up to order k will be calculated. Result is -1 if Taylor package is not
%yet initialized.
%

% written  05/21/09     S.M. Rump
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
%

  global INTLAB_CONST
  
  if isempty(INTLAB_CONST.TAYLOR_ORDER)
    k = -1;        % Taylor package not yet initialized
  else
    k = INTLAB_CONST.TAYLOR_ORDER;
  end
