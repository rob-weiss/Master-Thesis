function r = gradient(a,str)
%GRADIENT     Gradient class constructor for affari input
%
%   r = gradient(a)
%
%An explicit call of the constructor is only necessary to initialize
%  a constant to be of type gradient. Otherwise, any operation
%  with a dependent variable produces a result of type gradient.
%

% written  04/18/14     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
%

  global INTLAB_CONST
  
  INTLAB_GRADIENT_NUMVAR = INTLAB_CONST.GRADIENT_NUMVAR;

  if INTLAB_GRADIENT_NUMVAR==0
    error('no dependent variables initialized for use of gradient')
  end

  dummy.init = a;
  if nargin==1
    r = gradient(dummy,'gradientaff');
  else
    r = gradient(dummy,str);
  end
