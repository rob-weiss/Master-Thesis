function rmax = realmax(classname)
%REALMAX      Largest finite floating point number.
%   REALMAX returns the largest finite floating point number in IEEE double
%   precision.
%
%   REALMAX('double') is the same as REALMAX.
%
%   REALMAX('single') returns the largest finite floating point number in
%   IEEE single precision.
%
%   REALMIN('fl') returns the largest finit normalized fl-number in the 
%   precision specified by flinit.
%
%   See also EPS, REALMIN, INTMAX.
%
%main part copied from Matlab(realmax)
%

% written  10/21/13     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 02/02/17     S.M. Rump  move to @char
%

  global INTLAB_CONST

  if nargin == 0 || strcmp(classname, 'double')
    rmax = pow2(2-eps,1023);
  elseif strcmp(classname, 'single')
    rmax = pow2(2-eps('single'),127);
  elseif strcmp(classname, 'fl')
    const = INTLAB_CONST.FL_CONST;    if isempty(const)
      error('fl-package not intialized')
    end
    rmax = fl(const.realmax);  
  else
    error(message('MATLAB:realmax:invalidClassName'));
  end
