function [I,J] = getfunindex
% Kopie in verifyglobal für Octave, das private files nicht von private aufruft
% indices for constraint function
  global INTLAB_NLSS
  I = INTLAB_NLSS.Lindex;    % this is fun
  if nargout==1
    return
  end
  M = INTLAB_NLSS.M;
  base2 = dec2bin(I-1,M)-48; % choose function g
  I = find(~base2);  % fun=1 corresponds to original system
  J = find(base2);
end  % function getfunindex
