function r = times(a,b)
%TIMES        Affine arithmetic elementwise multiplication  a .* b
%

% written  12/06/13     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/15/14     S.M. Rump  code optimization
% modified 05/21/14     S.M. Rump  Octave bug preference
% modified 05/21/14     S.M. Rump  All zero sparse: 1-by-1
%

  global INTLAB_CONST

  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    if isa(b,'gradient')
      r = times(gradient(a),gradient(b));
      return
    elseif isa(b,'hessian')
      r = times(hessian(a),hessian(b));
      return
    elseif isa(b,'taylor')
      r = times(taylor(a),taylor(b));
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
      error('not matching dimensions for affari times')
    end
  end                               % size of result is sa
    
  % take care of "All zero sparse: 1-by-1": do not use 'isempty'
  if ~nnz(a.err)                    % no error terms in a, possibly rounding errors
    Amag = mag(a.range(:));         % maximum absolute value of a
    P = a.range .* b.mid;           % includes a.rnderr.*b.mid
    r.mid = mid(P);
    rndold = getround;              % save rounding mode
    if any(b.err(:))                % error terms in a and b
      [m,n] = size(b.err);
      [I,J,S] = find(b.err);
      amid = a.mid(:);
      Q = amid(J).*intval(S(:));
      r.err = sparse(I,J,mid(Q),m,n);
      rerrrad = sparse(I,J,rad(Q),m,n);
      setround(1)
      r.rnderr = mag(Amag').*b.rnderr + ( reshape(rad(P),1,prod(sa)) + sum(rerrrad,1) );
    else
      r.err = [];
      setround(1)
      r.rnderr = mag(Amag').*b.rnderr + reshape(rad(P),1,prod(sa));
    end
    r = intersectNaN( r , a.range.*b.range );
    setround(rndold)                % retrieve rounding mode
    % no extra error term for rounding error because isempty(a.err)
%     if INTLAB_CONST.AFFARI_ROUNDINGERRORS
%       r = rnderrintoerrterm(r);
%     end
    r = class(r,'affari');
    return
  else                              % a has error terms
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if ~nnz(b.err)                  % b has no error terms
      Bmag = mag(b.range(:));       % maximum absolute value of a
      P = a.mid .* b.range;         % includes a.mid.*b.rnderr
      r.mid = mid(P);
      rndold = getround;            % save rounding mode
      setround(1)
      [m,n] = size(a.err);          % a has error terms
      [I,J,S] = find(a.err);
      bmid = b.mid(:);
      Q = intval(S(:)).*bmid(J);
      r.err = sparse(I,J,mid(Q),m,n);
      rerrrad = sparse(I,J,rad(Q),m,n);
      setround(1)
      r.rnderr = a.rnderr.*mag(Bmag') + ( reshape(rad(P),1,prod(sa)) + sum(rerrrad,1) );
      r = intersectNaN( r , a.range.*b.range );
      setround(rndold)                % retrieve rounding mode
      % no extra error term for rounding error because isempty(b.err)
%       if INTLAB_CONST.AFFARI_ROUNDINGERRORS
%         r = rnderrintoerrterm(r);
%       end
      r = class(r,'affari');
      return
    end
  end
  
  % a and b have error terms
  P = intval(a.mid) .* b.mid;       % interval product
  r.mid = mid(P);                   % both a and b have error terms
  
  ea = size(a.err,1);               % adapt number of error terms
  eb = size(b.err,1);
  if ea<eb
    a.err(eb,prod(sa)) = 0;
  elseif eb<ea
    b.err(ea,prod(sa)) = 0;
  end
  
  [m,n] = size(a.err);
  amid = a.mid(:);
  bmid = b.mid(:);
  [I,J,S] = find(a.err);            % a.err*b.mid
  rerrempty = ( isempty(I) | isempty(J) );
  if ~rerrempty
    rerr = sparse(I,J,intval(S(:)).*bmid(J),m,n);
  end
  [I,J,S] = find(b.err);            % a.mid*b.err
  if ( ~isempty(I) ) && ( ~isempty(J) )
    if rerrempty
      rerrempty = 0;
      rerr = sparse(I,J,amid(J).*intval(S(:)),m,n);
    else
      rerr = rerr + sparse(I,J,amid(J).*intval(S(:)),m,n);
    end
  end
  rndold = getround;                % save rounding mode
  setround(1)
  if rerrempty
    r.err = [];
    radrerr = 0;
  else
    r.err = mid(rerr);
    radrerr = sum(rad(rerr),1);
  end
  Amag = mag(a);
  Bmags = abs(b.mid(:)') + sum(abs(b.err),1);       % w/o b.rnderr
  % improvement for product possible, but ratio improement/performance
  % seems not favorite
  errerr = sum(abs(a.err),1).*sum(abs(b.err),1);
  r.rnderr = Amag(:)'.*b.rnderr + ( a.rnderr.*Bmags(:)' + ...
        ( errerr + reshape(rad(P),1,prod(sa)) + radrerr ) );    
  r = intersectNaN( r , a.range.*b.range );
  setround(rndold)                  % retrieve rounding mode
  
  % possibly extra error term for rounding error
  if INTLAB_CONST.AFFARI_ROUNDINGERRORS
    r = rnderrintoerrterm(r);
  end
  
  r = class(r,'affari');
