function [ fy , J ] = newton(y)
%NEWTON       Function value and Jacobian for Newton iteration
%
% For slope variable y, the sizes of y.x and y.dx are adapted to be
% suitable for Newton iteration.
% After execution, the value of  fy = mid(y.c)  and  J = mid(y.s)  are
% in vector and matrix form such that  J\fy is the Newton correction.
% For a given approximate value xs, a Newton iteration is
%
%    ys = f(xs);
%    [ fy , J ] = newton(ys);
%    xs = xs - reshape( J\fy , size(xs));
%

% written  09/28/01     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/04/14     S.M. Rump  function name
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
%

  global INTLAB_CONST

  INTLAB_SLOPE = INTLAB_CONST.SLOPE;

  fy = mid(y.r(:,1));
  J = reshape( y.s.mid , prod(y.size) , INTLAB_SLOPE.NUMVAR );
