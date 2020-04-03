function k = longprecision(k)
%LONGPRECISION  Sets/gets maximum precision for long number arithmetic
%
%   k = longprecision       gets precision in decimals
%   longprecision(k)        sets precision (approximately) in decimals
%                             and gives back actual precision
%   longprecision(0)        sets precision to minimum precision necesary
%                             to store doubles w/o error
%

% written  12/30/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
%

  global INTLAB_CONST

  INTLAB_LONG_LOGBETA = INTLAB_CONST.LONG_LOGBETA;

  if ( nargout==0 ) && ( nargin==1 )        % set precision

    RequiredPrecision = ceil( k*log(10)/log(2)/INTLAB_LONG_LOGBETA );
    MimimumPrecision = ceil(52/INTLAB_LONG_LOGBETA) + 1 ;
    INTLAB_LONG_PRECISION = max( RequiredPrecision , MimimumPrecision );
    k = floor( INTLAB_LONG_PRECISION*INTLAB_LONG_LOGBETA*log10(2) );
    INTLAB_CONST.LONG_PRECISION = INTLAB_LONG_PRECISION;

  elseif ( nargout<=1 ) && ( nargin==0 )    % get precision

    INTLAB_LONG_PRECISION = INTLAB_CONST.LONG_PRECISION;
    k = floor( INTLAB_LONG_PRECISION*INTLAB_LONG_LOGBETA*log10(2) );

  else
    error('invalid call of longprecision')
  end
