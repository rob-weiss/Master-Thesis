function realimag(c)
%REALIMAG     Display real and imaginary part of interval Taylor separately
%
%   realimag(c)
%

% written  05/21/09     S.M. Rump
% modified 09/23/15     S.M. Rump  avoid get(0,... in Octave
%

  global INTLAB_CONST
  
  if INTLAB_CONST.OCTAVE
    loose = false;
  else
    loose = strcmp(get(0,'FormatSpacing'),'loose');
  end

  name = inputname(1);
  if isempty(name)                    % happens for display(taylorinit(random))
    name = 'ans';
  end
  
  if isreal(c.t)
    display(c,name)
  else
    if loose, disp(' '); end
    display(real(c),['real(' name ')'])
    if loose, disp(' '); end

    if loose, disp(' '); end
    display(imag(c),['imag(' name ')'])
    if loose, disp(' '); end
  end

  