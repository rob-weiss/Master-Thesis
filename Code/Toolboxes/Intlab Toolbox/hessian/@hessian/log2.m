function a = log2(a)
%LOG2         Hessian (elementwise) logarithm
%

% written  02/22/17     S.M. Rump
%

  if isintval(a)    
    global INTLAB_CONST
    INTLAB_STDFCTS_LOG2_ = INTLAB_CONST.STDFCTS_LOG2_;
    a = log(a) * infsup(INTLAB_STDFCTS_LOG2_.INF , ...
                        INTLAB_STDFCTS_LOG2_.SUP );
  else
    a = log(a) / log(2);
  end
  