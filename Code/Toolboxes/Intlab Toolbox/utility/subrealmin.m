function res = subrealmin(type)
%SUBREALMIN   Smallest denormalized positive floating-point number
%
%   res = subrealmin
%

% written  08/07/10     S.M. Rump
% modified 08/26/12     S.M. Rump  global variables removed
% modified 10/17/13     S.M. Rump  single precision
% modified 11/06/13     S.M. Rump  correction and fl-numbers
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
%

  global INTLAB_CONST

  if nargin==0
    type = 'double';
  end
  
  if isequal(type,'fl')
    const = INTLAB_CONST.FL_CONST;
    res = fl(const.subrealmin);
  else
    res = realmin(type)*eps(type);
  end
  