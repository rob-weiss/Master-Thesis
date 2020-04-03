function res = atanh(z)
%ATANH        Functionality as atanh with imaginary part adapted to Matlab
%

% written  08/06/14  S.M. Rump
%

  global INTLAB_CONST
  
  res = builtin('atanh',z);

  if INTLAB_CONST.OCTAVE    
    if isreal(z) && ( ~isreal(res) )
      res = complex(real(res),-imag(res));
    end
  end
