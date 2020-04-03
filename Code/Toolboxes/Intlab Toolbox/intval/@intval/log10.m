function y = log10(x)
%LOG10        Implements  log10(x)  for intervals (logarithm to base 10)
%
%   y = log10(x)
%
%interval standard function implementation
%

% written  10/16/98     S.M. Rump
% modified 11/30/98     S.M. Rump  improved speed
% modified 08/31/99     S.M. Rump  complex allowed, sparse input,
%                                  major revision, improved accuracy
% modified 09/02/00     S.M. Rump  rounding unchanged after use
% modified 04/07/04     S.M. Rump  accelaration for sparse input
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 12/03/05     S.M. Rump  completely simplified
% modified 10/18/08     S.M. Rump  out-of-range flag
% modified 08/26/12     S.M. Rump  global variables removed
% modified 10/13/12     S.M. Rump  INTLAB_INTVAL_STDFCTS
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 07/21/15     S.M. Rump  old RealStdFctsExcptnIgnore/Occurred deleted
%                                    new design hidden from user
% modified 02/22/17     S.M. Rump  x=0
%

  global INTLAB_CONST

  INTLAB_STDFCTS_LOG10_ = INTLAB_CONST.STDFCTS_LOG10_;

  % log(x) * ( 1/log(10) )
  y = log(x) * infsup(INTLAB_STDFCTS_LOG10_.INF , ...
                      INTLAB_STDFCTS_LOG10_.SUP );
  index = ( x==0 );
  if any(index(:))
    y.inf(index) = -inf;
    y.sup(index) = -inf;
  end
