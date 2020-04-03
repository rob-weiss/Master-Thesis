function y = log2(x)
%LOG2         Implements  log2(x)  for intervals (binary logarithm)
%
%   y = log2(x)
%
%interval standard function implementation
%
% Matlab bug: Careful with arguments slightly larger than 1:
% e = 1e-7; x = linspace(1-e,1+e,100000);
% y = log2(x); Y = log2(intval(x));
% close, semilogy( x,abs((y-Y.mid)./(y+Y.mid)), x,relerr(Y) )
%

% written  11/08/07     S.M. Rump
% modified 08/26/12     S.M. Rump  global variables removed
% modified 10/13/12     S.M. Rump  INTLAB_INTVAL_STDFCTS
% modified 03/30/14     S.M. Rump  Matlab bug in comment
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 07/21/15     S.M. Rump  old RealStdFctsExcptnIgnore/Occurred deleted
%                                    new design hidden from user
% modified 02/22/17     S.M. Rump  x=0
%

  global INTLAB_CONST

  INTLAB_STDFCTS_LOG2_ = INTLAB_CONST.STDFCTS_LOG2_;

  % log(x) * ( 1/log(2) )
  y = log(x) * infsup(INTLAB_STDFCTS_LOG2_.INF , ...
                      INTLAB_STDFCTS_LOG2_.SUP );
  index = ( x==0 );
  if any(index(:))
    y.inf(index) = -inf;
    y.sup(index) = -inf;
  end
