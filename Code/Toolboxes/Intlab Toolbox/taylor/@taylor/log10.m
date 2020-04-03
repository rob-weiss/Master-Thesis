function a = log10(a)
%LOG10        Taylor logarithm  log10(a)
%

% written  05/22/09     S.M. Rump
% modified 08/26/12     S.M. Rump  global variables removed
% modified 10/13/12     S.M. Rump  INTLAB_INTVAL_STDFCTS
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
%

  global INTLAB_CONST

  a = log(a);
  if isa(a.t,'intval')
    INTLAB_STDFCTS_LOG10_ = INTLAB_CONST.STDFCTS_LOG10_;
    a.t = a.t .* infsup(INTLAB_STDFCTS_LOG10_.INF,INTLAB_STDFCTS_LOG10_.SUP);
  else
    a.t = a.t / log(10);
  end
  