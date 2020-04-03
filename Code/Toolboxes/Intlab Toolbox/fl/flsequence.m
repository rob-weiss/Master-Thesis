function res = flsequence(xmin,xmax)
%FLSEQUENCE   The sequence of all fl-numbers between bounds
%
%  res = flsequence(xmin,xmax)
%
%produces the set of all fl-numbers f of the current format as initialized by
%flinit with
%
%  xmin <= f <= xmax .
%
%For example, flsequence(1,pred(2)) is the set of all fl-numbers with
%exponent 1, and 
%  res = flsequence( succ(fl(0)) , pred(realmin('fl')) )
%produces all positive denormalized fl-numbers. To see the bit-pattern, use
%  getbits(fl(res'))
%Finally, 
%  flsequence(-inf,inf) 
%produces all fl-numbers of the current format. The minimal such set is
%produces for the initialization flinit(1,1), i.e. 1-bit arithmetic and
%exponents 0 and 1.
%Note that for larger k and larger intervals the result may have many elements. 
%

% written  11/06/13   S.M. Rump
% modified 04/23/14   S.M. Rump  set/getappdata replaced by global
% modified 10/08/14   S.M. Rump  result of type fl
% modified 07/30/16   S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST

  if xmin>xmax
    res = [];
    return
  elseif ( xmin<0 ) & ( xmax>0 )        % xmin, xmax of opposite sign
    res = [ -fliplr(flsequence(realmin,-xmin)) flsequence(0,xmax) ];
    return
  elseif xmax<=0
    res = -fliplr(flsequence(-xmax,-xmin));
    return
  end
  
  rndold = getround;
  if rndold
    setround(0)
  end
  
  % be sure bounds xmin, xmax are of type double
  xmin = double(xmin);
  xmax = double(xmax);

  % flsequence(xmin,xmax) with 0 <= xmin <= xmax
  const = INTLAB_CONST.FL_CONST;
  
  % all fl-numbers with exponent 1
  r = 1 + (0:(2^(const.prec-1)-1))*2^(-const.prec+1);
  emin = floor(log2(xmin));
  emax = floor(log2(xmax));
  
  % initialization
  if emin<-const.expBias+1      % denormalized numbers included
    res = (0:(2^(const.prec-1)-1))*const.subrealmin;
  else
    res = [];
  end
  
  % take care of all exponents
  for e=max(emin,(-const.expBias+1)):min(emax,const.expBias)
    res = [ res 2^e*r ];
  end
  
  % cover overflow
  if emax>const.expBias
    res = [ res inf ];
  end
  
  % take suitable subset
  res = fl( res( ( xmin<=res ) & ( res<=xmax ) ) );
  
  % reset rounding mode
  if rndold
    setround(rndold)
  end
