function r = times(a,b,dummy)
%TIMES        Implements  a .* b  for intervals
%

% written  10/16/98     S.M. Rump
% modified 09/02/00     S.M. Rump  rounding unchanged after use
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    remove check for 'double'
%                                    extra argument for non-interval output (internal use only)
%                                    take care of Matlab sparse Inf/NaN bug
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/20/05     S.M. Rump  faster check for rounding to nearest
% modified 02/11/06     S.M. Rump  SparseInfNanFlag removed
%                                    sparse radius for complex data
% modified 05/23/06     S.M. Rump  sparse Inf/NaN bug corrected in Version 7.2+
% modified 12/03/06     S.M. Rump  Sparse Bug global flag (thanks to Arnold)
% modified 12/05/06     S.M. Rump  0*infsup(0,inf) (thanks to Arnold)
% modified 01/19/07     S.M. Rump  zero radius for huge arrays
% modified 05/22/07     S.M. Rump  check for sparse zero factor
% modified 10/21/07     S.M. Rump  Matlab bug for sparse(0)*inf
% modified 10/18/08     S.M. Rump  abss replaced by mag, improved performance
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/17/14     S.M. Rump  repmat(nan,...
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/16/14     S.M. Rump  Octave precedence
% modified 05/15/14     S.M. Rump  code optimization
% modified 05/21/14     S.M. Rump  logical index
% modified 09/06/15     S.M. Rump  0*inf
% modified 12/09/15     S.M. Rump  0/0 etc.
% modified 12/10/15     S.M. Rump  huge moved (thanks to F. Buenger)
% modified 12/12/15     S.M. Rump  prod(size) to numel(s)
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
% modified 11/15/16     S.M. Rump  0*inf
% 

  global INTLAB_CONST
  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    if isa(b,'fl')
      r = times(fl(a),b);
      return
    elseif isa(b,'gradient')
      r = times(gradient(a),b);
      return
    elseif isa(b,'hessian')
      r = times(hessian(a),b);
      return
    elseif isa(b,'polynom')
      r = times(polynom(a),b);
      return
    elseif isa(b,'slope')
      r = times(slope(a),b);
      return
    elseif isa(b,'taylor')
      r = times(taylor(a),b);
      return
    elseif isa(b,'affari')
      r = times(affari(a),b);
      return
    end
  end

  rndold = getround;
  if rndold~=1                            % rounding upwards
    setround(1)
  end

  if ~isa(a,'intval')                     % a is double
    if ~isreal(a) || b.complex            % complex case
      if ~b.complex
        b.mid = b.inf + 0.5*(b.sup-b.inf);
        b.rad = b.mid - b.inf;
      end
      c = INTLAB_CONST.COMPLEXINTERVAL; 
      if isreal(a) || ~b.complex          % R .* IC  or  C .* IC
        c1 = -((-a) .* b.mid);
        c2 = a .* b.mid;
      else                                % C .* IC
        setround(-1)
        c1 = real(a) .* real(b.mid) + (-imag(a)) .* imag(b.mid) + ...
             ( real(a) .* imag(b.mid) + imag(a) .* real(b.mid) ) * 1i;
        setround(1)                
        c2 = real(a) .* real(b.mid) + (-imag(a)) .* imag(b.mid) + ...
             ( real(a) .* imag(b.mid) + imag(a) .* real(b.mid) ) * 1i;
      end   
      % rounding is upwards in any case
      c.mid = c1 + 0.5*(c2-c1);           % R .* IC  or  C .* IC
      c.rad = abs(c.mid-c1);
      if ~isequal(b.rad,0)                % make sure c.rad remains sparse
        c.rad = c.rad + abs(a) .* b.rad;
      end
      % too rare, improvement doesn't pay
%       if huge
%         [cradi,cradj] = find(c.rad);
%         if ~any(find(cradi))              % take care of huge arrays
%           c.rad = 0;
%         end
%       else
%         if ~any(find(c.rad))
%           c.rad = 0;
%         end
%       end
    else                                  % real case  R .* IR
      c = b;  
      P1 = -((-a).*b.inf);
      P2 = -((-a).*b.sup);
      isnanP1 = isnan(P1);                % take care of 0*inf
      isnanP2 = isnan(P2);
      indexnan = isnanP1 | isnanP2;
      if any(indexnan(:))
        P1(isnanP1) = 0;
        P2(isnanP2) = 0;
      end
      c.inf = min(P1,P2);
      P1 = a.*b.inf;
      P2 = a.*b.sup;
      if any(indexnan(:))
        P1(isnanP1) = 0;
        P2(isnanP2) = 0;
      end
      c.sup = max(P1,P2);
      if issparse(a)
        index = isnan(a) | isnan(sparse(b.inf)) | isnan(sparse(b.sup));
      elseif issparse(b.inf)
        index = isnan(sparse(a)) | isnan(b.inf) | isnan(b.sup);
      else
        index = isnan(a) | isnan(b.inf) | isnan(b.sup);
      end
      if any(index(:))
        c.inf(index) = NaN;
        c.sup(index) = NaN;
      end
    end
  elseif ~isa(b,'intval')                 % b is double
    if a.complex || ~isreal(b)            % complex case
      if ~a.complex
        a.mid = a.inf + 0.5*(a.sup-a.inf);
        a.rad = a.mid - a.inf;
      end
      c = INTLAB_CONST.COMPLEXINTERVAL;
      if ~a.complex || isreal(b)          % IC .* R  or  IC .* C
        c1 = -(a.mid .* (-b));
        c2 = a.mid .* b;
      else                                % IC .* C
        setround(-1)
        c1 = real(a.mid) .* real(b) + (-imag(a.mid)) .* imag(b) + ...
             ( real(a.mid) .* imag(b) + imag(a.mid) .* real(b) ) * 1i;
        setround(1)
        c2 = real(a.mid) .* real(b) + (-imag(a.mid)) .* imag(b) + ...
             ( real(a.mid) .* imag(b) + imag(a.mid) .* real(b) ) * 1i;
      end
      % rounding is upwards in any case
      c.mid = c1 + 0.5*(c2-c1);           % R .* IC  or  C .* IC
      c.rad = abs(c.mid-c1);
      if ~isequal(a.rad,0)                % make sure c.rad remains sparse
        c.rad = c.rad + a.rad .* abs(b) ;
      end
      % too rare, improvement doesn't pay
%       if huge
%         [cradi,cradj] = find(c.rad);
%         if ~any(find(cradi))              % take care of huge arrays
%           c.rad = 0;
%         end
%       else
%         if ~any(find(c.rad))
%           c.rad = 0;
%         end
%       end
    else                                  % real case  IR .* R
      c = a;
      P1 = -(a.inf.*(-b));
      P2 = -(a.sup.*(-b));
      isnanP1 = isnan(P1);                % take care of 0*inf
      isnanP2 = isnan(P2);
      indexnan = isnanP1 | isnanP2;
      if any(indexnan(:))
        P1(isnanP1) = 0;
        P2(isnanP2) = 0;
      end
      c.inf = min(P1,P2);
      P1 = a.inf.*b;
      P2 = a.sup.*b;
      if any(indexnan(:))
        P1(isnanP1) = 0;
        P2(isnanP2) = 0;
      end
      c.sup = max(P1,P2);
      if issparse(a.inf)
        index = isnan(a.inf) | isnan(a.sup) | isnan(sparse(b));
      elseif issparse(b)
        index = isnan(sparse(a.inf)) | isnan(sparse(a.sup)) | isnan(b);
      else
        index = isnan(a.inf) | isnan(a.sup) | isnan(b);
      end
      if any(index(:))
        c.inf(index) = NaN;
        c.sup(index) = NaN;
      end
    end
  else                                    % both a and b interval
    if a.complex || b.complex             % complex case
      if ~a.complex
        c = b;
        a.mid = a.inf + 0.5*(a.sup-a.inf);
        a.rad = a.mid - a.inf;
      else
        c = a;
      end
      if ~b.complex
        b.mid = b.inf + 0.5*(b.sup-b.inf);
        b.rad = b.mid - b.inf;
      end
      if ~a.complex || ~b.complex         % one real factor
        c1 = -((-a.mid) .* b.mid);
        c2 = a.mid .* b.mid;
      else
        setround(-1)
        c1 = real(a.mid) .* real(b.mid) + (-imag(a.mid)) .* imag(b.mid) + ...
             ( real(a.mid) .* imag(b.mid) + imag(a.mid) .* real(b.mid) ) * 1i;
        setround(1)
        c2 = real(a.mid) .* real(b.mid) + (-imag(a.mid)) .* imag(b.mid) + ...
             ( real(a.mid) .* imag(b.mid) + imag(a.mid) .* real(b.mid) ) * 1i;
      end
      % rounding is upwards in any case
      c.mid = c1 + 0.5*(c2-c1);           % IR .* IC  or  IC .* IC
      c.rad = abs(c.mid-c1);
      if ~isequal(a.rad,0)                % make sure c.rad remains sparse
        if ~isequal(b.rad,0)
          c.rad = c.rad + a.rad .* ( abs(b.mid) + b.rad );
        else
          c.rad = c.rad + a.rad .* abs(b.mid);
        end
      end
      if ~isequal(b.rad,0)
        c.rad = c.rad + abs(a.mid) .* b.rad;
      end
      % too rare, improvement doesn't pay
%       if huge
%         [cradi,cradj] = find(c.rad);
%         if ~any(find(cradi))              % take care of huge arrays
%           c.rad = 0;
%         end
%       else
%         if ~any(find(c.rad))
%           c.rad = 0;
%         end
%       end
    else                                  % real case  IR .* IR
      c = a;
      P1 = -((-a.inf).*b.inf);
      P2 = -((-a.inf).*b.sup);
      isnanP1 = isnan(P1);                % take care of 0*inf
      isnanP2 = isnan(P2);
      indexnan12 = isnanP1 | isnanP2;
      if any(indexnan12(:))
        P1(isnanP1) = 0;
        P2(isnanP2) = 0;
      end
      c12 = min(P1,P2);
      P3 = -((-a.sup).*b.inf);
      P4 = -((-a.sup).*b.sup);
      isnanP3 = isnan(P3);
      isnanP4 = isnan(P4);
      indexnan34 = isnanP3 | isnanP4;
      if any(indexnan34(:))
        P3(isnanP3) = 0;
        P4(isnanP4) = 0;
      end
      c34 = min(P3,P4);
      c.inf = min(c12,c34);
      P1 = a.inf.*b.inf;
      P2 = a.inf.*b.sup;
      isnanP1 = isnan(P1);
      isnanP2 = isnan(P2);
      indexnan12 = isnanP1 | isnanP2;
      if any(indexnan12(:))
        P1(isnanP1) = 0;
        P2(isnanP2) = 0;
      end
      c12 = max(P1,P2);
      P3 = a.sup.*b.inf;
      P4 = a.sup.*b.sup;
      isnanP3 = isnan(P3);
      isnanP4 = isnan(P4);
      indexnan34 = isnanP3 | isnanP4;
      if any(indexnan34(:))
        P3(isnanP3) = 0;
        P4(isnanP4) = 0;
      end
      c34 = max(P3,P4);
      c.sup = max(c12,c34);
      if issparse(a.inf)
        index = isnan(a.inf) | isnan(a.sup) | isnan(sparse(b.inf)) | isnan(sparse(b.sup));
      elseif issparse(b.inf)
        index = isnan(sparse(a.inf)) | isnan(sparse(a.sup)) | isnan(b.inf) | isnan(b.sup);
      else
        index = isnan(a.inf) | isnan(a.sup) | isnan(b.inf) | isnan(b.sup);
      end
      if any(index(:))
        c.inf(index) = NaN;
        c.sup(index) = NaN;
      end
    end
  end
  
  % Octave bug: SPARSE_BUG is true
  if INTLAB_CONST.SPARSE_BUG
    % take care of Matlab sparse NaN bug
    huge = ( max(numels(a),numels(b))>1e9 );
    if huge                                       % huge linear indices, for simplicity inf*x=NaN
      if c.complex
        [m,n] = size(c.mid);
      else
        [m,n] = size(c.inf);
      end
      if issparse(a)
        index = any( isnan(b) | isinf(b) );
        if any(index(:))                          % keep linear index small
          [indexi,indexj] = find(isnan(b));
          cNaN = sparse(indexi,indexj,NaN,m,n);
          [ia,ja,aa] = find(mag(a));
          [ib,jb,bb] = find(mag(b));
          ab = sparse([ia;ib],[ja;jb],[complex(aa(:),0);complex(0,bb(:))],m,n);
          [indexi,indexj,ab] = find(ab);
          index = isinf(imag(ab));
          ab = real(ab);
          ab(index & (ab==0)) = NaN;
          ab(~isnan(ab)) = 0;
          cNaN = cNaN + sparse(indexi,indexj,ab,m,n);
          if c.complex
            c.mid = c.mid + cNaN;
            if isequal(c.rad,0)
              c.rad = cNaN;                       % scalar + sparse = full also for scalar=0
            else
              c.rad = c.rad + cNaN;
            end
          else
            c.inf = c.inf + cNaN;
            c.sup = c.sup + cNaN;
          end
        end
      end
      if issparse(b)
        index = any( isnan(a) | isinf(a) );
        if any(index(:))                          % keep linear index small
          [indexi,indexj] = find(isnan(a));
          cNaN = sparse(indexi,indexj,NaN,m,n);
          [ia,ja,aa] = find(mag(a));
          [ib,jb,bb] = find(mag(b));
          ab = sparse([ia;ib],[ja;jb],[complex(0,aa(:));complex(bb(:),0)],m,n);
          [indexi,indexj,ab] = find(ab);
          index = isinf(imag(ab));
          ab = real(ab);
          ab(index & (ab==0)) = NaN;
          ab(~isnan(ab)) = 0;
          cNaN = cNaN + sparse(indexi,indexj,ab,m,n);
          if c.complex
            c.mid = c.mid + cNaN;
            if isequal(c.rad,0)
              c.rad = cNaN;                      % scalar + sparse = full also for scalar=0
            else
              c.rad = c.rad + cNaN;
            end
          else
            c.inf = c.inf + cNaN;
            c.sup = c.sup + cNaN;
          end
        end
      end 
    else                % not huge
      Index = false; 
      if issparse(a) && ( numels(a)~=1 )    % sparse scalar is handled correctly by Matlab
        Index = isnan(b);
        if any(Index(:))
          if numels(b)==1
            Index = find( a==0 );               % may be almost full
          end
        end
        index = find(isinf(b));
        if any(index)
          if numels(b)==1                   % a is scalar
            index = find( a==0 );               % may be almost full
          else                                  % a and b not scalar, same size
            if isa(a,'intval')
              if a.complex
                if isequal(a.rad,0)
                  index( a.mid(index)~=0 ) = [];
                else
                  index( ( a.mid(index)~=0 ) | ( a.rad(index)~=0 ) ) = [];
                end
              else
                index( ( a.inf(index)~=0 ) | ( a.sup(index)~=0 ) ) = [];
              end
            else
              index( a(index)~=0 ) = [];
            end
          end
          Index(index) = true;
        end
      end
      if issparse(b) && ( numels(b)~=1 )    % sparse scalar is handled correctly by Matlab
        Index = Index | isnan(a);
        if any(Index(:))
          if numels(a)==1
            Index = find( b==0 );               % may be almost full
          end
        end
        index = find(isinf(a));
        if any(index)
          if numels(a)==1                       % a is scalar
            index = find( b==0 );               % may be almost full
          else                                  % a and b not scalar, same size
            if isa(b,'intval')
              if b.complex
                if isequal(b.rad,0)
                  index( b.mid(index)==0 ) = [];
                else
                  index( ( b.mid(index)~=0 ) | ( b.rad(index)~=0 ) ) = [];
                end
              else
                index( ( b.inf(index)~=0 ) | ( b.sup(index)~=0 ) ) = [];
              end
            else
              index( b(index)~=0 ) = [];
            end
          end
          Index(index) = true;
        end
      end
      if any(Index(:))
        if c.complex
          c.mid(Index) = NaN;
          if isequal(c.rad,0)
            [m,n] = size(c.mid);
            c.rad = sparse([],[],[],m,n);
          end
          c.rad(Index) = NaN;
        else
          c.inf(Index) = NaN;
          c.sup(Index) = NaN;
        end
      end
    end
  end
  
  if nargin==2
    r = c;
  else % non-interval output for performance improvement for hessians
    r.complex = c.complex;  
    r.mid = c.mid;
    r.rad = c.rad;
    r.inf = c.inf;    
    r.sup = c.sup;    
  end
  if rndold ~= 1
    setround(rndold)
  end
end
