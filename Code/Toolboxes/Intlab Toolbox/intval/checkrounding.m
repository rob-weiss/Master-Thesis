function fail = checkrounding(see)
%CHECKROUNDING    Extensive check of correctly changing the rounding mode
%
%   fail = checkrounding(see)
%
%   input   see  1    display result message (default)
%                0    no output message
%   output  fail 0    no error detected
%                1    changing the rounding mode not correct
%
%A typical call is
%
%   checkrounding;
%
%A message tells whether the rounding check was successful or not. Using
%
%   if checkrounding(0)
%     error('changing the rounding mode not correct')
%   end
%
%one may check the rounding mode with action only in case of failure.
%

% written  06/11/15     S.M. Rump
% modified 07/22/15     S.M. Rump  intvalinit
%

  if nargin==0
    see = 1;
  end
  if see
    disp(' ')
  end
  
  fail = intvalinit('checkrounding',see,'checkrounding');
  if see
    if fail
      disp('** Errors in switching of rounding mode detected!                  ')
      disp('** INTLAB routines may produce **erreneous** results! ')
      disp(' ')
    else
      disp('No errors in changing the rounding mode detected.')
    end
  end
  