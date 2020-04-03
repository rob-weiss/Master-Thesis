function res = ge(a,b)
%GE           Implements  a >= b  entrywise for affaris a and b
%

% written  08/03/14     S.M. Rump
% modified 05/16/14     S.M. Rump  Octave precedence
% modified 08/04/14     S.M. Rump  Octave taylor
%

  global INTLAB_CONST

  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    if isa(b,'gradient') || isa(b,'hessian')
      res = ge(intval(a),b.x);
      return
    elseif isa(b,'taylor')
      res = ge(intval(a),reshape(b.tt(1,:),size(b)));
      return
    end
  end

  res = ( intval(a)>=intval(b) );
  