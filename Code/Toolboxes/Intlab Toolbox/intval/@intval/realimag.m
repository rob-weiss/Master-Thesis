function realimag(c,name,restricted)
%REALIMAG     Separate display of real and imaginary part
%
%  realimag(c)
%

%for internal use:
%  name                name of output variable
%  restricted == 1     no header, no extra lines output
%

% written  10/16/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    take care of Matlab sparse Inf/NaN bug
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 02/11/06     S.M. Rump  SparseInfNanFlag removed
% modified 05/15/14     S.M. Rump  code optimization
% modified 09/23/15     S.M. Rump  avoid get(0,... in Octave
%

  global INTLAB_CONST

  if nargin<2
    name = inputname(1);
  end

  if INTLAB_CONST.OCTAVE
    loose = false;
  else
    loose = strcmp(get(0,'FormatSpacing'),'loose');
  end

  if c.complex
    if loose, disp(' '); end
    disp([ 'intval real part ' name ' = ' ])
    if loose, disp(' '); end
    display(real(c),'',1)

    if loose, disp(' '); end
    disp([ 'intval imaginary part ' name ' = ' ])
    if loose, disp(' '); end
    display(imag(c),'',1)
  else
    display(c,name,0)
  end

