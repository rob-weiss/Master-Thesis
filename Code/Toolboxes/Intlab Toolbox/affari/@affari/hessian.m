function r = hessian(a,str)
%HESSIAN      Hessian class constructor for affari input
%
%   r = hessian(a)
%
%An explicit call of the constructor is only necessary to initialize
%  a constant to be of type gradient. Otherwise, any operation
%  with a dependent variable produces a result of type gradient.
%

% written  04/18/14     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
%

  global INTLAB_CONST
  
  INTLAB_HESSIAN_NUMVAR = INTLAB_CONST.HESSIAN_NUMVAR;

  if INTLAB_HESSIAN_NUMVAR==0
    error('no dependent variables initialized for use of hessian')
  end

  dummy.init = a;
  if nargin==1
    r = hessian(dummy,'hessianaff');
  else
    r = hessian(dummy,str);
  end
