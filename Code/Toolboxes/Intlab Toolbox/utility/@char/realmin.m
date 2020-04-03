function rmin = realmin(classname)
%REALMIN Smallest positive normalized floating point number.
%   REALMIN returns the smallest positive normalized floating point number
%   in IEEE double precision.
%
%   REALMIN('double') is the same as REALMIN.
%
%   REALMIN('single') returns the smallest positive normalized floating
%   point number in IEEE single precision.
%
%   REALMIN('fl') returns the smallest positive normalized fl-number
%   in the precision specified by flinit.
%
%   See also EPS, REALMAX, INTMIN.
%
%main part copied from Matlab(realmin)
%

% written  10/21/13     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 02/02/17     S.M. Rump  move to @char
%

  global INTLAB_CONST

  if nargin == 0 || strcmp(classname, 'double')
    rmin = pow2(1,-1022);
  elseif strcmp(classname, 'single')
    rmin = pow2(single(1),-126);
  elseif strcmp(classname, 'fl')
    const = INTLAB_CONST.FL_CONST;
    if isempty(const)
      error('fl-package not intialized')
    end
    rmin = fl(const.realmin);
  else
    error(message('MATLAB:realmin:invalidClassName'));
  end
  