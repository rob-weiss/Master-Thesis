function r = plus(a,b)
%PLUS         Affine arithmetic addition  a + b
%

% written  12/06/13  S.M. Rump
% modified 05/15/14  S.M. Rump  code optimization
% modified 05/21/14  S.M. Rump  Octave bug preference
% modified 05/21/14  S.M. Rump  All zero sparse: 1-by-1
%

  global INTLAB_CONST

  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    if isa(b,'gradient')
      r = plus(gradient(a),gradient(b));
      return
    elseif isa(b,'hessian')
      r = plus(hessian(a),hessian(b));
      return
    elseif isa(b,'taylor')
      r = plus(taylor(a),taylor(b));
      return
    end
  end

  a = affari(a);
  b = affari(b);
  
  sa = size(a);                     % both a and b affari
  sb = size(b);
  if ~isequal(sa,sb)                % adapt size
    if prod(sa)==1                  % a scalar
      a = repmat(a,sb);
      sa = sb;                      % size of result
    elseif prod(sb)==1              % b is scalar
      b = repmat(b,sa);
    else
      error('not matching dimensions for affari plus')
    end
  end                               % size of result is sa

  S = intval(a.mid) + b.mid;        % interval sum
  r.mid = mid(S);                   % result midpoint 
  E = 0;
  % take care of "All zero sparse: 1-by-1": do not use 'isempty'
  if ~nnz(a.err)
    r.err = b.err;
  elseif ~nnz(b.err)
    r.err = a.err;
  else
    ea = size(a.err,1);             % adapt number of error terms
    eb = size(b.err,1);
    if ea<eb
      a.err(eb,1) = 0;
    elseif eb<ea
      b.err(ea,1) = 0;
    end
    E = a.err + intval(b.err);
    r.err = mid(E);                 % result error
  end
  
  rndold = getround;
  setround(1)                       % result rounding error
  r.rnderr = a.rnderr + b.rnderr + reshape(rad(S),1,prod(sa)) + sum(rad(E),1);
  r = intersectNaN( r , a.range+b.range );
  setround(rndold) 

  % no extra error term for rounding error
%   if INTLAB_CONST.AFFARI_ROUNDINGERRORS
%     r = rnderrintoerrterm(r);
%   end
  
  r = class(r,'affari');
  