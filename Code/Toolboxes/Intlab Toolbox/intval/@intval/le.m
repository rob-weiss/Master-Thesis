function res = le(a,b)
%LE           Implements  a <= b  elementwise for intervals a and b
%
%  if true,  a  is definitely less than or equal to  b
%

% written  10/16/98     S.M. Rump
% modified 11/30/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 05/15/14     S.M. Rump  code optimization
% modified 05/16/14     S.M. Rump  Octave precedence
%

  global INTLAB_CONST

  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    if isa(b,'fl')
      res = le(fl(a),b);
      return
    elseif isa(b,'gradient')
      res = le(gradient(a),b);
      return
    elseif isa(b,'hessian')
      res = le(hessian(a),b);
      return
    elseif isa(b,'polynom')
      res = le(polynom(a),b);
      return
    elseif isa(b,'slope')
      res = le(slope(a),b);
      return
    elseif isa(b,'taylor')
      res = le(taylor(a),b);
      return
    elseif isa(b,'affari')
      res = le(a,intval(b));
      return
    end
  end
    
  if ~isa(a,'intval')
    a = intval(a);
  end
  if ~isa(b,'intval')
    b = intval(b);
  end

  if a.complex || b.complex
    res = real(sup(a)) <= real(inf(b)) & imag(sup(a)) <= imag(inf(b)) ;
  else
    res = sup(a) <= inf(b) ;
  end
