function r = randomc(varargin)
%RANDOMC      Complex random numbers in M+i*M with M=[min,max], default [-1,+1]
%
% Calling conventions as function  random
%

% written  03/18/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 05/18/14     S.M. Rump  code optimization
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  rndold = getround;
  if rndold
    setround(0)
  end

  if isempty(varargin)
    r = random(NaN) + sqrt(-1)*random(NaN);
  else
    r = random(NaN, varargin) + sqrt(-1)*random(NaN,varargin);
  end
  
  if rndold
    setround(rndold)
  end
