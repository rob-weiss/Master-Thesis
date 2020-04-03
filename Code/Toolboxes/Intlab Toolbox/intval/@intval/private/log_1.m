function x = log_1(x,rnd)
%LOG_         Rigorous calculation of  log(1+x)  for 0<=x<=1 according to rnd
%
%   y = log_1(x)
%
%Internal function
%Rounding remains setround(rnd) after execution
%

% written  12/30/98     S.M. Rump
% modified 08/31/98     S.M. Rump  improved accuracy
% modified 08/26/12     S.M. Rump  global variables removed
% modified 10/13/12     S.M. Rump  INTLAB_INTVAL_STDFCTS
% modified 04/22/14     S.M. Rump  rounding unaltered
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
%

  global INTLAB_CONST

  INTLAB_STDFCTS_LOG = INTLAB_CONST.STDFCTS_LOG;

  rndold = getround;
  xs = pow2( floor(x*2^13) , -13 );    % first 13 bits
  log1xs = log(1+xs);                  % 1+xs exactly representable in 14 bits

  setround(rnd)
  d = ( x - xs ) ./ (1+xs);            % 0 <= d < 2^-13

  % log(1+x) = log( (1+xs) * (1+d) ) ,   0 <= err <= d^5/5 < 4.45e-17*d
  if rnd==-1
    log1d = ((( (-d)/4 + 1/3 ).*d - 0.5 ).*d).*d + d;
    x = log1xs + ( log1d + (-INTLAB_STDFCTS_LOG.EPS)*abs(log1xs) );
  else
    log1d = (((( d/5 - .25 ).*d + 1/3 ).*d - 0.5 ).*d).*d + d;
    x = log1xs + ( log1d + INTLAB_STDFCTS_LOG.EPS*abs(log1xs) );
  end

  setround(rndold)
