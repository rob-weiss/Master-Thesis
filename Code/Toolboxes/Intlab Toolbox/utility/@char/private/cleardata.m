function cleardata(param)
%CLEAR        store/retrieve global data
%   param  0  store data
%          1  retrieve data
%

% written  05/19/14     S.M. Rump
%

  % store INTLAB_CONST at a safe place - out of reach of clear all
  global INTLAB_CONST
  if param
    INTLAB_CONST = getappdata(0,'INTLAB_CONST');
  else
    setappdata(0,'INTLAB_CONST',INTLAB_CONST);
  end
  