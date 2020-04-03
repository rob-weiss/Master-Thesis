function s = getbits(x,bits)
%GETBITS      Nice printing of bits for double, single and fl-type
%
%   str = getbits(x)
%
%Input may be single or double, real or complex, scalar or array, point or intval. 
%Input may be fl-format as well, scalar or array, point or intval, but not complex.
%
%Output is a pretty print of the bit representation, e.g. getbits(single(13)) produces
%  ans =
%   + 1.10100000000000000000000 * 2^3
%Correspondingly, the call 
%  flinit(7,100); getbits(fl(13))
%produces
%  ans =
%   + 1.101000 * 2^3
%The output is always a column of results.
%
%For x being an array, output are the bits of x(:).
%For x being complex, output are the bits of real(x(:)) and imag(x(:)).
%For real interval, output are the bits of x.inf(:) and x.sup(:).
%For complex interval, output are the bits of x.mid(:) and x.rad(:).
%

%internal use: bits<0 corresponds to getbits for fl-number 

% written  06/12/98     S.M. Rump
% modified 08/16/99     S.M. Rump  rounding restored
% modified 10/13/01     S.M. Rump  interval input added
% modified 10/17/07     S.M. Rump  option array of bits added
% modified 10/18/13     S.M. Rump  fl-format added
% modified 04/04/14     S.M. Rump  end function
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 12/09/15     S.M. Rump  prod(size) to numel
%

  global INTLAB_CONST

  % determine input type
  if isa(x,'double')
    inputType = 'd';
    if nargin==1
      mantBits = 52;
    else
      if bits<0             % input was fl-number
        inputType = 'f';
        mantBits = -bits - 1;
      else
        mantBits = bits - 1;
      end
    end
  elseif isa(x,'single')
    inputType = 's';
    mantBits = 23;
  elseif isa(x,'fl')
    x = double(x);
    if isa(x,'intval')
      s = strvcat( 'infimum',getbits(fl(x.inf)), 'supremum',getbits(fl(x.sup)) );
      return
    end
    inputType = 'f';
    const = INTLAB_CONST.FL_CONST;      % initialize constants
    mantBits = const.prec - 1;
  elseif isa(x,'intval')
    if isreal(x)
      s = strvcat( 'infimum',getbits(x.inf), 'supremum',getbits(x.sup) );
    else
      s = strvcat( 'midpoint',getbits(x.mid), 'radius',getbits(x.rad) );
    end
    return
  else
    error('invalid input type for getbits.')
  end

  if ~isequal(inputType,'f')
    if ~isreal(x)
      s = strvcat( 'real part',getbits(real(x)), 'imaginary part',getbits(imag(x)) );
      return
    end
  end
  
  rnd = getround;
  setround(0)
  s = '';
  for i=1:numel(x)
    v = getbits_(x(i),inputType);
    str = sprintf('%d',v);
    % s = [ s ; [ str(1) ' ' str(2:12) ' ' str(13:64) ] ];
    % nice print
    s = strvcat( s , nice(str,inputType,mantBits) );
  end
  setround(rnd)
  
end  % function getbits
  
  
function v = getbits_(x,inputType)
% replaces .dll file getbits_
  if isequal(inputType,'s')
    v = bitget(typecast(x,'uint32'), 32:-1:1);
  else          % also for fl-format
    v = bitget(typecast(x,'uint64'), 64:-1:1);
  end
end  % function getbits_

  
function str = nice(bits,inputType,mantBits)
% print bits in a nice format
  global INTLAB_CONST
  if isequal(inputType,'s')
    expBias = 127;
    expBias_ = 127;
  elseif isequal(inputType,'d')
    expBias = 1023;
    expBias_ = 1023;
  else
    const = INTLAB_CONST.FL_CONST;
    expBias = const.expBias;
    expBias_ = 1023;
  end
  
  if isequal(inputType,'s')
    e = bin2dec(bits(2:9)) - 127;
    mantRange = 10:32;
    mantRange1 = mantRange;
  else
    e = bin2dec(bits(2:12)) - 1023;
    mantRange = 13:(12+mantBits);
    mantRange1 = 13:64;
  end
  sign = '+';
  if isequal(bits(1),'1')
    sign = '-';
  end
  if e==expBias_+1                  % inf or NaN
    if bin2dec(bits(mantRange1))==0
      str = [ ' ' sign 'Inf' ];   
    else
      str = '  NaN';
    end
  elseif e==-expBias_               % denormalized fl-number, or zero
    str = [ ' ' sign '0.' bits(mantRange) ];
    if any(bits(mantRange)~='0')
      str = [ str ' * 2^' int2str(e+1) ];
    end
  else
    if isequal(inputType,'f') & ( e<=-expBias )  % (nonzero) denormalized fl-number
      bits_ = [ char(48*ones(1,-expBias-e)) '1' bits(13:(11+mantBits+e+expBias)) ];
      str = [ ' ' sign '0.' bits_ ' * 2^' int2str(-expBias+1) ];
    else                              % normalized number
      str = [ ' ' sign '1.' bits(mantRange) ' * 2^' int2str(e) ];
    end
  end
  
end  % function nice
