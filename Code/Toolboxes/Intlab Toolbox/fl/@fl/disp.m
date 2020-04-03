function outstr = disp(x)
%DISP         Display function for fl-type for pop-up windows in debugger
%
%Displays bit representation or double depending on flinit.
%Width of display is controlled by function displaywidth.
%

% written  10/21/13     S.M. Rump
% modified 04/04/14     S.M. Rump  end function
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 09/23/15     S.M. Rump  loose omitted
% modified 12/09/15     S.M. Rump  prod(size) to numel(s)
% modified 10/17/16     S.M. Rump  Do not display huge arrays
%

  global INTLAB_CONST
  
  if numels(x)<INTLAB_CONST.DISPLAY_POPUP
    display(x);
  else
    disp('Display suppressed.')
  end
    