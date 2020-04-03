function res = acosh(z)
%ACOSH        Functionality as atanh with imaginary part adapted to Matlab
%

% written  08/07/14  S.M. Rump
%

  global INTLAB_CONST
  
  res = builtin('acosh',z);

  if INTLAB_CONST.OCTAVE    
    if isreal(z)
      index = ( imag(res)~=0 );
      if any(index(:))
%       Octave bug: complex(.,.) leads sometimes to hard stop        
%       res(index) = complex(-real(res(index)),imag(res(index)));
        res(index) = -real(res(index)) + 1i*imag(res(index));
      end
    else
      index = ( real(z)<0 );
      if any(index(:))
        res(index) = -res(index);
      end
    end
  end
