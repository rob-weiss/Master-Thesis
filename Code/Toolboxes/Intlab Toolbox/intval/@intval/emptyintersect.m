function [empty,c] = emptyintersect(a,b)
%EMPTYINTERSECT    Compute intersection and check for empty components
%
%   [empty,c] = emptyintersect(a,b)
%
%Result c is that of intersect(a,b), and 
%  empty(i) = 1     intersection of a(i) and b(i) is empty OR
%                     at least one of a(i) and b(i) is NaN
%             0     intersection of a(i) and b(i) is not empty
%
%Input a and b must be both real or both complex
%

% written  04/22/09   S.M. Rump
% modified 05/14/09   S.M. Rump  identical midpoints
% modified 11/06/13   S.M. Rump  comments
% modified 04/04/14   S.M. Rump  Result 0 for Nan operands
% modified 05/15/14   S.M. Rump  code optimization
% modified 07/17/14   S.M. Rump  NaN intersection
% modified 07/17/14   F. Buenger code optimization
% modified 07/30/16   S.M. Rump  zero radius
%

  if numels(a)>1
    if numels(b)==1
      if issparse(a)
        b = b*spones(a);
      else
        b = b*ones(size(a));
      end
    end
  else
    if numels(b)>1
      if issparse(b)
        a = a*spones(b);
      else
        a = a*ones(size(b));
      end
    end
  end

  sizea = size(a);
  if ~isequal(sizea,size(b))
    error('intersect called with non-matching dimensions')
  end

  if ~isa(a,'intval')
    a = intval(a);
  end
  if ~isa(b,'intval')
    b = intval(b);
  end

  if a.complex && b.complex

    if isequal(a.rad,0)
      a.rad = zeros(sizea);
    end
    if isequal(b.rad,0)
      b.rad = zeros(sizea);
    end
    c = b;
    empty = zeros(sizea);

    v = b.mid - intval(a.mid);         % connection of midpoints    c = class(c,'intval');
 
    d2 = sqr(intval(real(v))) + sqr(intval(imag(v)));
    d = sqrt(d2);                      % inclusion of distance of midpoints
    arad = intval(a.rad);
    Delta = (arad+b.rad).*(arad-b.rad);
    wng = warning;
    warning off
    sumrad = arad+b.rad;
    index = ( d.inf > sumrad.sup );    % empty intersection
    if any(index(:))
      empty(index) = 1;
      c.mid(index) = NaN;
      c.rad(index) = NaN;
    end
    index0 = ( Delta.inf <= -d2 );
    if any(index0(:))                  % diameter of a in intersection
      c.mid(index0) = a.mid(index0);
      c.rad(index0) = a.rad(index0);
    end
    index1 = ( Delta.sup >= d2 );
    if any(index1(:))                  % diameter of b in intersection
      c.mid(index1) = b.mid(index1);
      c.rad(index1) = b.rad(index1);
    end
    index = ~( index | index0 | index1 );
    if any(index(:))
      x = ( 1 + Delta./d2 )/2;
      %VVVV  cmid = a.mid(index) + x(index).*v(index);
      %VVVV  c.mid(index) = mid(cmid);
      %VVVV  c.rad(index) = sup( rad(cmid) + sqrt(sqr(arad(index))-sqr(x(index).*d(index))) );
      s.type = '()'; s.subs = {index}; 
      cmid = a.mid(index) + subsref(x,s).*subsref(v,s);
      c.mid = subsasgn(c.mid,s,mid(cmid));
      c.rad = subsasgn(c.rad,s,sup( rad(cmid) + sqrt(abs(sqr(subsref(arad,s))-sqr(subsref(x,s).*subsref(d,s)))) ));
      %AAAA  Matlab bug fix      
    end
    warning(wng);
    
    index = isnan(a.mid) | isnan(a.rad) | isnan(b.mid) | isnan(b.rad);
    if any(index(:))
      empty(index) = 1;
      c.mid(index) = NaN;
      c.rad(index) = NaN;
    end
    
  elseif ( ~a.complex ) && ( ~b.complex )    % two real intervals
    
    c = a;   
    c.inf = max(a.inf,b.inf);
    c.sup = min(a.sup,b.sup);
    empty = zeros(size(a.inf));
    index = ( c.inf>c.sup );        % empty intersection
    if any(index(:))
      empty(index) = 1;
      c.inf(index) = NaN;
      c.sup(index) = NaN;
    end
    index = isnan(a.inf) | isnan(a.sup) | isnan(b.inf) | isnan(b.sup);
    if any(index(:))
      empty(index) = 1;
      c.inf(index) = NaN;
      c.sup(index) = NaN;
    end    
  else
    error('operands of intersect must be both real or both complex')
  end
end
  
