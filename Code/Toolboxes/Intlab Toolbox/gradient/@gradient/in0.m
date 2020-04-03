function res = in0(a,b)
%IN0          Implements  a in0 b  entrywise for gradients a and b, compares only a.x and b.x
%
%  res = in0(a,b)
%
%Second argument b must be intval.
%

% written  04/04/14     S.M. Rump
% modified 05/18/14     S.M. Rump  code optimization
%

  if ( ~isintval(b) ) && ( ~isaffari(b) )
    error('invalid call')
  end
  
  if isa(a,'gradient')
    if isa(b,'gradient')
      res = in0(a.x,b.x);
    else
      res = in0(a.x,b);
    end
  else
    res = in0(a,b.x);
  end
