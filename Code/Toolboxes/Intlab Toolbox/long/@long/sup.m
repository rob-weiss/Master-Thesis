function A = sup(A)
%SUP          Supremum of long (only with error term)
%
%  C = sup(A)
%
%For A being a long scalar or column vector with error term (see long),
%  output C is the long upper bound
%

% written  11/06/99     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 09/20/04     S.M. Rump  E.sign fixed
% modified 11/19/04     S.M. Rump  exponent update for error
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 07/25/05     S.M. Rump  result improved, thanks to 
%                                      Nozomu Matsuda and Nobito Yamamoto
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST

  rndold = getround;
  if rndold
    setround(0)
  end

  INTLAB_LONG_ERROR = INTLAB_CONST.LONG_ERROR;
  
  if ~INTLAB_LONG_ERROR
    error('sup called for long without error term')
  end

  E = long(A.error.mant);
  E.exponent = E.exponent + A.error.exp;

  A.error.mant = 0;
  A.error.exp = 0;

  A = A + E;
  index = ( A.error.mant~=0 );
  if any(index)
    %VVVV  A(index) = sup(A(index));
    s.type = '()'; s.subs = {index}; A = subsasgn(A,s,sup(subsref(A,s)));
    %AAAA  Matlab bug fix
  end
  
  if rndold
    setround(rndold)
  end
