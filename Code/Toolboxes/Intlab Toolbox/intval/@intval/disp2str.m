function out = disp2str(x)
%DISP2STR     Output of intval x into out
%
%The output produced by disp_(x(:)), infsup(x(:)), or midrad(x(:)),
%  according to the format in use, is returned into  out  as follows:
%
% out.exp  empty if no common exponent printed, otherwise
%            string of common exponent
% out.str  column array of strings representing to x(:)
%

% written  08/29/00     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 12/12/15     S.M. Rump  prod(size) to numel(s)
%

  global INTLAB_CONST

  INTLAB_INTVAL_DISPLAY = INTLAB_CONST.INTVAL_DISPLAY;
%VVVV x = x(:);
  x = reshape(x,numels(x),1);
%AAAA Matlab V5.2 bug fix
  switch INTLAB_INTVAL_DISPLAY
    case 'DisplayInfsup', out = infsup(x,[],[]);
    case 'DisplayMidrad', out = midrad(x,[],[]);
    case 'Display_', out = disp_(x,[],[]);
  end
