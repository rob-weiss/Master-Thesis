function [f,exact] = flround(d,K,E)
%FLROUND      Rounding of double precision into k-bit
%
%  f = fl(d,k,E)   or   f = fl(d,k)
%
%converts the double precision number d into k-bit format according to the
%format defined by  flinit(k,E). The default for E is the current value
%initialized by flinig. The result f is of type double.
%
%The input d may be of fl-type, the result is always of type double.
%Although the precision of fl-numbers is limited to k=26 bits and exponent
%E<=484, whereas flround accepts values 1<=k<=52 and E<=970.
%
%If d is outside the range defined by (k,E), the result is zero or +/- inf, 
%respectively. The result of fl(NaN) is NaN. 
%Note that fl respects the rounding mode. For example, fl(succ(1)) in 
%rounding upwards is the successor of 1 in (k,E)-format.
%
%The call 
%  [f,exact] = fl(d)
%yields exact=1 if mathematically f=d, and exact=0 otherwise. In particular
%exact=0 in case d=NaN.
%

% written  10/11/13     S.M. Rump
% modified 04/04/14     S.M. Rump  end function
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
% modified 09/25/16     S.M. Rump  interval component access 
%

  global INTLAB_CONST

  if nargin==2
    const = INTLAB_CONST.FL_CONST;      % initialize constants
    if isempty(const)
      error('fl-package must be initialized, see "help flinit"')
    end
    eminK = const.realmin;
    realmaxK = const.realmax;
  else
    if E>970
      error('exponent range too large')
    end
    eminK = 2^(1-E);
    realmaxK = (1-2^(-K))*2^(E+1);
  end
  
  if isa(d,'fl')            % check input type
    d = d.value;
  end
  
  if ( K<1 ) || ( K>52 ) || ( round(K)~=K )
    error('invalid call of flround: precision limited to 1<=K<=52.')
  else
    factor = 2^(53-K);
  end
  
  rndold = getround;
  if rndold
    setround(0)
  end
  
  if isa(d,'intval')
    finf = flround_(struct(d).inf,eminK,factor,realmaxK,-1);
    fsup = flround_(struct(d).sup,eminK,factor,realmaxK,1);
    f = intval(finf,fsup,'infsup');
  else
    f = flround_(d,eminK,factor,realmaxK,rndold);
  end
  
  % reset rounding mode
  setround(rndold)
  
  if nargout==2
    exact = ( f == d );
  end
  
end  % function flround
  
  
function f = flround_(d,eminK,factor,realmaxK,rnd)
  % conversion taking care of underflow with rounding rnd, faster by ufp
  setround(0)
  psi = 1-2^-53;
  q = (2^52+1)*d;
  e = abs(q-psi*q);    % ufp(d) = e
  b = sign(d).*(max(e,eminK)*factor);

  % simulated k-bit rounding with possibly directed rounding
  if rnd~=0
    setround(rnd)
  end
  f = ( d + b ) - b;
  
  % take care of signed zero
  index = ( f(:)==0 ); 
  if any(index)
    f(index) = 0*d(index);
  end
  
  % take care of overflow
  index = ( abs(f)>realmaxK );
  if any(index(:))
    f(index) = sign(f(index))*inf;
  end
    
end  % function flround_
