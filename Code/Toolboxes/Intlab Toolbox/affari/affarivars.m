function res = affarivars
%AFFARIVARS   Current number of error terms
%
%   res = affarivars
%

% written  03/07/14  S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
%

  global INTLAB_CONST
  
  res = INTLAB_CONST.AFFARI;
