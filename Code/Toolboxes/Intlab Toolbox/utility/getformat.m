function f = getformat
%GETFORMAT    current display format
%
%  f = getformat
%
%format short      short
%format short e    shorte
%format long       long
%format long e     longe
% 
% avoid get(0,... in Octave; thanks to Kai Ohlhus for this nice method.
%

% written  09/23/15     S.M. Rump
%

  global INTLAB_CONST

  if INTLAB_CONST.OCTAVE
    f = 'short';
    L = int32(length(disp(pi)));
    if L==18
      f = 'long';
    elseif L==14
      f = 'shorte';
    elseif L==24
      f = 'longe';
    end
  else
    f = lower(get(0,'format'));
  end
