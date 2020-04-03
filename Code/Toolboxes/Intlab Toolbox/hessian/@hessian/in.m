function res = in(a,b)
%IN           Implements  a in b  entrywise for hessians a and b, compares only a.x and b.x
%
%  res = in(a,b)
%
%Second argument b must be intval.
%

% written  04/04/14     S.M. Rump
% modified 05/18/14     S.M. Rump  code optimization
%

  if ( ~isintval(b) ) && ( ~isaffari(b) )
    error('invalid call')
  end
  
  if isa(a,'hessian')
    if isa(b,'hessian')
      res = in(a.x,b.x);
    else
      res = in(a.x,b);
    end
  else
    res = in(a,b.x);
  end
