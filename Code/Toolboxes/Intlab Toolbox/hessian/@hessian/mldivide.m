function r = mldivide(a,b)
%MLDIVIDE     Hessian left division  a \ b
%

% written  11/02/05     S.M. Rump
% modified 08/03/14     S.M. Rump  Octave precedence
%

  global INTLAB_CONST

  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    r = mrdivide(hessian(b),hessian(a));
    return
  end
  
  r = b / a;
  