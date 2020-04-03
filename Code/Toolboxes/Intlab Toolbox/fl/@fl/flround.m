function [f,exact] = flround(d,K,E)
%FLROUND      Rounding of fl-type quantity into k-bit double 
%
%Same functionality as flround for double input.
%

% written  10/11/13   S.M. Rump
% modified 04/23/14   S.M. Rump  set/getappdata replaced by global
% modified 10/08/14   S.M. Rump  FL_CONST
%

  global INTLAB_CONST

  if nargin==2
    const = INTLAB_CONST.FL_CONST;     % initialize constants
    if isempty(const)
      error('fl-package must be initialized, see "help flinit"')
    end
    E = const.expBias;
  end
  
  if nargout==2
    [f,exact] = flround(d.value,K,E);
  else
    f = flround(d.value,K,E);
  end
    