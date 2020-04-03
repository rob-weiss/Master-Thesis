function A = sqrt(A)
%SQRT         square root for fl-type
%
%   R = sqrt(A)
%
%The function respects the rounding mode, that is R^2<=A in rounding
%downwards, etc.
%

% written  10/31/13     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
%

  global INTLAB_CONST

  if ~all( A.value(:)>=0 )
    error('fl-sqrt not for negative input')
  end

  const = INTLAB_CONST.FL_CONST;
  x = A.value;

  A.value = flround(sqrt(x),const.prec,const.expBias); 
  if ( const.prec==26 ) && ( ~isa(x,'intval') )    % precision == 26
    if getround==0                      % rounding to nearest
      [f,e] = log2(x);
      % check for the only exceptional value 
      index = ( 2*round(e/2)==e ) & ( f==(1-2^(-26)) ); 
      if any(index)
        A.value(index) = pow2(f(index),e(index)/2);
      end
    end
  end
      