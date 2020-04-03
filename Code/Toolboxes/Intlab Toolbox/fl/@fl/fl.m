function [res,exact] = fl(d)
%FL           Conversion and type cast for fl-type
%
%  f = fl(d)
%
%converts the double precision number d into fl-type according to the
%defined precision and exponent range by flinit. If d is outside the
%floating-point range for the specified precision, the result is zero 
%or +/- inf, respectively. The result of fl(NaN) is NaN. 
%Note that fl respects the rounding mode. For example, fl(succ(1)) in 
%rounding upwards is the fl-successor of 1, the same as succ(fl(1)).
%
%The call 
%  [f,exact] = fl(d)
%yields exact=1 if mathematically f=d, and exact=0 otherwise. In particular
%exact=0 in case d=NaN.
%

%fl-numbers are stored in double precision numbers with limited mantissa
%and exponent range.
%

% written  10/11/13     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
%

  global INTLAB_CONST

  if exist('intvalinit','file')
    superiorto('intval');
  end
  
  if isa(d,'fl')
    res = d;
    if nargout==2
      exact = true(size(res.value));
    end
  else
    const = INTLAB_CONST.FL_CONST;      % initialize constants
    if isempty(const)
      error('fl-package must be initialized, see "help flinit"')
    end
    if ~isreal(d)
      error('fl-type only for real quantities')
    end
    % double or intval input
    res.value = flround(d,const.prec,const.expBias);
    res = class(res,'fl');
    if nargout==2
      exact = ( res.value==d );
    end
  end
