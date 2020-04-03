function c = mldivide(a,b)
%MLDIVIDE     Implements  a \ b
%

% written  10/16/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 08/03/14     S.M. Rump  Octave precedence
% modified 07/24/15     S.M. Rump  scalar denominator
% modified 12/12/15     S.M. Rump  prod(size) to numel(s)
%

  global INTLAB_CONST
  if numels(a)==1
    c = b/a;
    return
  end

  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    if isa(b,'fl')
      c = mldivide(fl(a),b);
      return
    elseif isa(b,'gradient')
      c = mldivide(gradient(a),b);
      return
    elseif isa(b,'hessian')
      c = mldivide(hessian(a),b);
      return
    elseif isa(b,'polynom')
      c = mldivide(polynom(a),b);
      return
    elseif isa(b,'slope')
      c = mldivide(slope(a),b);
      return
    elseif isa(b,'taylor')
      c = mldivide(taylor(a),b);
      return
    elseif isa(b,'affari')
      c = mldivide(affari(a),b);
      return
    end
  end
    

  c = verifylss(a,b);
