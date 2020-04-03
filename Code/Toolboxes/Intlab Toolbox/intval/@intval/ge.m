function res = ge(a,b)
%GE           Implements  a >= b  elementwise for intervals a and b
%
%  if true,  a  is definitely greater than or equal to  b
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
      res = ge(fl(a),b);
      return
    elseif isa(b,'gradient')
      res = ge(gradient(a),b);
      return
    elseif isa(b,'hessian')
      res = ge(hessian(a),b);
      return
    elseif isa(b,'polynom')
      res = ge(polynom(a),b);
      return
    elseif isa(b,'slope')
      res = ge(slope(a),b);
      return
    elseif isa(b,'taylor')
      res = ge(taylor(a),b);
      return
    elseif isa(b,'affari')
      res = ge(a,intval(b));
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
    res = real(inf(a)) >= real(sup(b)) & imag(inf(a)) >= imag(sup(b)) ;
  else
    res = inf(a) >= sup(b) ;
  end
