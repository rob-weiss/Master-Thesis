function r = mtimes(a,b,dummy)
%MTIMES       Implements  a * b  for intervals
%

% written  10/16/98     S.M. Rump
% modified 12/30/98     S.M. Rump  improved performance
% modified 09/02/00     S.M. Rump  rounding unchanged after use
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    major revision
%                                    remove check for 'double', sparse input
%                                    extra argument for non-interval output (internal use only)
%                                    improved performance for outer products
%                                    take care of Matlab sparse Inf/NaN bug
% modified 08/24/04     S.M. Rump  IR x IR for sharp multiplication 
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/20/05     S.M. Rump  faster check for rounding to nearest
% modified 02/11/06     S.M. Rump  SparseInfNanFlag removed
% modified 05/23/06     S.M. Rump  sparse Inf/NaN bug corrected in Version 7.2+
% modified 12/03/06     S.M. Rump  Sparse Bug global flag (thanks to Arnold)
% modified 12/05/06     S.M. Rump  Fast sharp multiplication if one factor contains no zero-IVs
% modified 05/09/09     S.M. Rump  thin intervals with equal NaNs
% modified 08/20/12     S.M. Rump  performance improvement, in particular for SharpIVMult 
%                                    (thanks to Adam Kleiner for pointing to this), and 
%                                    access to sparse submatrices
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/17/14     S.M. Rump  isequaln
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/16/14     S.M. Rump  Octave precedence
% modified 05/15/14     S.M. Rump  code optimization
% modified 12/10/15     F. Buenger code optimization, rounding
% modified 12/10/15     S.M. Rump  rounding in R * IR
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
% modified 02/19/17     S.M. Rump  ignore input out of range 0*inf etc.
%

  global INTLAB_CONST

  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    if isa(b,'fl')
      r = mtimes(fl(a),b);
      return
    elseif isa(b,'gradient')
      r = mtimes(gradient(a),b);
      return
    elseif isa(b,'hessian')
      r = mtimes(hessian(a),b);
      return
    elseif isa(b,'polynom')
      r = mtimes(polynom(a),b);
      return
    elseif isa(b,'slope')
      r = mtimes(slope(a),b);
      return
    elseif isa(b,'taylor')
      r = mtimes(taylor(a),b);
      return
    elseif isa(b,'affari')
      r = mtimes(affari(a),b);
      return
    end
  end
    
  [m , n] = size(a); 
  [n1 , n2] = size(b);
  
  if ( m*n==1 ) || ( n1*n2==1 )
    if nargin==2
      r = a .* b;
    else
      r = times(a,b,0);
    end
    return
  end

  if n~=n1
    error('matrices not compatible for multiplication')
  end
  
  % Both matrices not scalar and compatible
  persistent first                  % initialized emtpy
  if isempty(first)                 % check for NaNs
    aisnan = any(isnan(a),2);
    bisnan = any(isnan(b),1);
    if any(aisnan) | any(bisnan)    % treat NaNs separately
      %VVVV as = a(~aisnan,:);
      s.type = '()'; s.subs = {~aisnan,':'}; as = subsref(a,s);
      %AAAA Matlab V5.2 bug fix
      %VVVV bs = b(:,~bisnan);
      s.type = '()'; s.subs = {':',~bisnan}; bs = subsref(b,s);
      %AAAA Matlab V5.2 bug fix
      first = 0;
      if nargin==2
        rs = mtimes(as,bs);
      else
        rs = mtimes(as,bs,0);
      end
      first = [];
      r = rs;
      %VVVV r(m,n2) = 0;
      s.type = '()'; s.subs = {m,n2}; r = subsasgn(r,s,0);
      %AAAA Matlab V5.2 bug fix
      %VVVV r(~aisnan,~bisnan) = cs;
      s.type = '()'; s.subs = {~aisnan,~bisnan}; r = subsasgn(r,s,rs);
      %AAAA Matlab V5.2 bug fix
      %VVVV r(aisnan,:) = NaN;
      s.type = '()'; s.subs = {aisnan,':'}; r = subsasgn(r,s,NaN);
      %AAAA Matlab V5.2 bug fix
      %VVVV r(:,bisnan) = NaN;
      s.type = '()'; s.subs = {':',bisnan}; r = subsasgn(r,s,NaN);
      %AAAA Matlab V5.2 bug fix
      return
    end
  else
    first = [];
  end
  
  % No NaNs in both a and b, product NaN must be 0*inf
  if INTLAB_CONST.RealStdFctsExcptnIgnore   % ignore input out of range
    % input must be both real arrays, at least one interval
    % check for special treatment of 0*inf by inf0
    zeroinf =  any(any(isinf(a))) | any(any(isinf(b)));
    if zeroinf                  % special treatment of 0*inf
      rnd = getround;
      setround(-1);               % switch rounding downwards
      if isa(a,'intval')          % a is interval
        if isequal(a.inf,a.sup)   % a is point interval
          a = a.inf;              % a is point
          if isa(b,'intval')      % a is point, b is interval
            bpoint = isequal(b.inf,b.sup);
            if bpoint
              b = b.inf;
            end
          else
            bpoint = true;
          end
          if bpoint
            % a is point, b is point
            rinf = a*b;
            rsup = (-a)*b;
            if zeroinf
              rinf = inf0(zeroinf,rinf);
              rsup = inf0(zeroinf,rsup);
            end
          else
            % a is point, b is thick interval
            binf = b.inf;
            bsup = b.sup;
            rinf = 0;
            rsup = 0;
            if zeroinf
              for i=1:n
                f1 = a(:,i);
                f2 = binf(i,:);
                p1 = f1*f2;
                p1 = inf0(zeroinf,p1);
                q1 = (-f1)*f2;
                q1 = inf0(zeroinf,q1);
                f2 = bsup(i,:);
                p2 = f1*f2;
                p2 = inf0(zeroinf,p2);
                q2 = (-f1)*f2;
                q2 = inf0(zeroinf,q2);
                rinf = rinf + min(p1,p2);
                rsup = rsup + min(q1,q2);
              end
            else
              for i=1:n
                f1 = a(:,i);
                f2 = binf(i,:);
                p1 = f1*f2;
                q1 = (-f1)*f2;
                f2 = bsup(i,:);
                p2 = f1*f2;
                q2 = (-f1)*f2;
                rinf = rinf + min(p1,p2);
                rsup = rsup + min(q1,q2);
              end
            end
          end
        else                      % a is thick interval
          if isa(b,'intval')      % a is thick interval, b is interval
            bpoint = isequal(b.inf,b.sup);
            if bpoint
              b = b.inf;          %  b is point
            end
          else
            bpoint = true;
          end
          if bpoint
            % a is thick interval, b is point
            ainf = a.inf;
            asup = a.sup;
            rinf = 0;
            rsup = 0;
            if zeroinf
              for i=1:n
                f1 = ainf(:,i);
                f2 = b(i,:);
                p1 = f1*f2;
                p1 = inf0(zeroinf,p1);
                q1 = (-f1)*f2;
                q1 = inf0(zeroinf,q1);
                f1 = asup(:,i);
                p2 = f1*f2;
                p2 = inf0(zeroinf,p2);
                q2 = (-f1)*f2;
                q2 = inf0(zeroinf,q2);
                rinf = rinf + min(p1,p2);
                rsup = rsup + min(q1,q2);
              end
            else
              for i=1:n
                f1 = ainf(:,i);
                f2 = b(i,:);
                p1 = f1*f2;
                q1 = (-f1)*f2;
                f1 = asup(:,i);
                p2 = f1*f2;
                q2 = (-f1)*f2;
                rinf = rinf + min(p1,p2);
                rsup = rsup + min(q1,q2);
              end
            end
          else
            % a is thick interval, b is thick interval
            ainf = a.inf;
            asup = a.sup;
            binf = b.inf;
            bsup = b.sup;
            rinf = 0;
            rsup = 0;
            if zeroinf
              for i=1:n
                f1 = ainf(:,i);         % ainf*binf
                f2 = binf(i,:);
                p1 = f1*f2;
                p1 = inf0(zeroinf,p1);
                q1 = (-f1)*f2;
                q1 = inf0(zeroinf,q1);
                f2 = bsup(i,:);
                p2 = f1*f2;             % ainf*bsup
                p2 = inf0(zeroinf,p2);
                p1 = min(p1,p2);
                q2 = (-f1)*f2;
                q2 = inf0(zeroinf,q2);
                q1 = min(q1,q2);
                f1 = asup(:,i);         % asup*bsup
                p2 = f1*f2;
                p2 = inf0(zeroinf,p2);
                p1 = min(p1,p2);
                q2 = (-f1)*f2;
                q2 = inf0(zeroinf,q2);
                q1 = min(q1,q2);
                f2 = binf(i,:);         % asup*binf
                p2 = f1*f2;
                p2 = inf0(zeroinf,p2);
                q2 = (-f1)*f2;
                q2 = inf0(zeroinf,q2);
                rinf = rinf + min(p1,p2);
                rsup = rsup + min(q1,q2);
              end
            else
              for i=1:n
                f1 = ainf(:,i);         % ainf*binf
                f2 = binf(i,:);
                p1 = f1*f2;
                q1 = (-f1)*f2;
                f2 = bsup(i,:);
                p2 = f1*f2;             % ainf*bsup
                p1 = min(p1,p2);
                q2 = (-f1)*f2;
                q1 = min(q1,q2);
                f1 = asup(:,i);         % asup*bsup
                p2 = f1*f2;
                p1 = min(p1,p2);
                q2 = (-f1)*f2;
                q1 = min(q1,q2);
                f2 = binf(i,:);         % asup*binf
                p2 = f1*f2;
                q2 = (-f1)*f2;
                rinf = rinf + min(p1,p2);
                rsup = rsup + min(q1,q2);
              end
            end
          end
        end
      else                        % a is point, b is interval
        if isequal(b.inf,b.sup)
          b = b.inf;
          % a is point, b is point
          rinf = a*b;
          rsup = (-a)*b;
          if zeroinf
            rinf = inf0(zeroinf,rinf);
            rsup = inf0(zeroinf,rsup);
          end
        else
          % a is point, b is thick interval
          binf = b.inf;
          bsup = b.sup;
          rinf = 0;
          rsup = 0;
          if zeroinf
            for i=1:n
              f1 = a(:,i);
              f2 = binf(i,:);
              p1 = f1*f2;
              p1 = inf0(zeroinf,p1);
              q1 = (-f1)*f2;
              q1 = inf0(zeroinf,q1);
              f2 = bsup(i,:);
              p2 = f1*f2;
              p2 = inf0(zeroinf,p2);
              q2 = (-f1)*f2;
              q2 = inf0(zeroinf,q2);
              rinf = rinf + min(p1,p2);
              rsup = rsup + min(q1,q2);
            end
          else
            for i=1:n
              f1 = a(:,i);
              f2 = binf(i,:);
              p1 = f1*f2;
              q1 = (-f1)*f2;
              f2 = bsup(i,:);
              p2 = f1*f2;
              q2 = (-f1)*f2;
              rinf = rinf + min(p1,p2);
              rsup = rsup + min(q1,q2);
            end
          end
        end
      end
      % construct final result
      r.complex = 0;
      r.inf = rinf;
      r.sup = -rsup;
      r.mid = 0;
      r.rad = 0;
      if nargin==2
        r = class(r,'intval');
      end
      setround(rnd);              % restore rounding mode
    else                        % 0*inf does not occur
      INTLAB_CONST.RealStdFctsExcptnIgnore = 0;
      first = 0;                % no check for NaN
      if nargin==2
        r = mtimes(a,b);
      else
        r = mtimes(a,b,0);
      end
      INTLAB_CONST.RealStdFctsExcptnIgnore = 1;
    end
    return
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
      c = INTLAB_CONST.COMPLEXINTERVAL;   % R * IC  or  C * IC
      if isreal(a) || ~b.complex          % one real factor
        c1 = -((-a) * b.mid);
        c2 = a * b.mid;
      else                                % C * IC
        setround(-1)
        c1 = real(a) * real(b.mid) + (-imag(a)) * imag(b.mid) + ...
             ( real(a) * imag(b.mid) + imag(a) * real(b.mid) ) * 1i;
        setround(1)
        c2 = real(a) * real(b.mid) + (-imag(a)) * imag(b.mid) + ...
             ( real(a) * imag(b.mid) + imag(a) * real(b.mid) ) * 1i;
      end
      % rounding is upwards in any case
      c.mid = c1 + 0.5*(c2-c1);           % R * IC  or  C * IC
      if isequal(b.rad,0)
        c.rad = abs(c.mid-c1);
        if ~any(find(c.rad))              % take care of huge arrays
          c.rad = 0;
        end
      else
        c.rad = abs(c.mid-c1) + abs(a) * b.rad;
      end
    else                                  % real case  R * IR
      c = b;
      bthin = isequaln(b.inf,b.sup);
      if bthin                            % R * R with directed rounding
        c.inf = -((-a) * b.inf);
        c.sup = a*b.inf;
      else                                % R * IR
        bmid = b.inf + 0.5*(b.sup-b.inf);
        brad = bmid - b.inf;
        crad = abs(a) * brad;
        c.inf = 0;                        % preserve order of definition of intval c
        c.sup = a * bmid + crad;
        c.inf = -(crad + ((-a) * bmid));
      end
    end
  elseif ~isa(b,'intval')                 % b is double
    if a.complex || ~isreal(b)            % complex case
      if ~a.complex
        a.mid = a.inf + 0.5*(a.sup-a.inf);
        a.rad = a.mid - a.inf;
      end
      c = INTLAB_CONST.COMPLEXINTERVAL;   % IC * R  or IC * C
      if ~a.complex || isreal(b)          % one real factor
        c1 = -(a.mid * (-b));             % IC * R  
        c2 = a.mid * b;
      else                                % IC * C
        setround(-1)
        c1 = real(a.mid) * real(b) + (-imag(a.mid)) * imag(b) + ...
             ( real(a.mid) * imag(b) + imag(a.mid) * real(b) ) * 1i;
        setround(1)
        c2 = real(a.mid) * real(b) + (-imag(a.mid)) * imag(b) + ...
             ( real(a.mid) * imag(b) + imag(a.mid) * real(b) ) * 1i;
      end
      % rounding is upwards in any case
      c.mid = c1 + 0.5*(c2-c1);           % IC * R  or  IC * C
      if isequal(a.rad,0)
        c.rad = abs(c.mid-c1);
        if ~any(find(c.rad))              % take care of huge arrays
          c.rad = 0;
        end
      else
        c.rad = abs(c.mid-c1) + a.rad * abs(b);
      end
    else                                  % real case  IR * R
      c = a;
      athin = isequaln(a.inf,a.sup);
      if athin                            % R * R with directed rounding
        c.inf = -(a.inf * (-b));
        c.sup = a.inf*b;
      else
        amid = a.inf + 0.5*(a.sup-a.inf); % IR * R
        arad = amid - a.inf;
        crad = arad * abs(b);
        c.inf = 0;                        % preserve order of definition of intval c
        c.sup = amid * b + crad;
        c.inf = -(crad + amid * (-b)) ;   %equivalent to setround(-1); c.inf = amid * b - crad;
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
        c1 = -((-a.mid) * b.mid);
        c2 = a.mid * b.mid;
      else                                % IC * IC
        setround(-1)
        c1 = real(a.mid) * real(b.mid) + (-imag(a.mid)) * imag(b.mid) + ...
             ( real(a.mid) * imag(b.mid) + imag(a.mid) * real(b.mid) ) * 1i;
        setround(1)
        c2 = real(a.mid) * real(b.mid) + (-imag(a.mid)) * imag(b.mid) + ...
             ( real(a.mid) * imag(b.mid) + imag(a.mid) * real(b.mid) ) * 1i;
      end
      c.mid = c1 + 0.5*(c2-c1);           % IC * IC
      if isequal(a.rad,0)
        if isequal(b.rad,0)
          c.rad = abs(c.mid-c1);
          if ~any(find(c.rad))            % take care of huge arrays
            c.rad = 0;
          end
        else
          c.rad = abs(c.mid-c1) + abs(a.mid) * b.rad;
        end
      elseif isequal(b.rad,0)
        c.rad = abs(c.mid-c1) + a.rad * abs(b.mid);
      else
        c.rad = abs(c.mid-c1) + ...
                  a.rad * ( abs(b.mid) + b.rad ) + abs(a.mid) * b.rad;
      end
    else                                  % real case,  IR * IR
      c = a;
      athin = isequaln(a.inf,a.sup);
      bthin = isequaln(b.inf,b.sup);
      if athin && bthin                   % R * R  with directed rounding
        c.inf = -((-a.inf) * b.inf);
        c.sup = a.inf*b.inf;
      elseif athin
        bmid = b.inf + 0.5*(b.sup-b.inf); % R * IR 
        brad = bmid - b.inf;
        crad = abs(a.inf) * brad;
        c.inf = 0;                        % preserve order of definition of intval c
        c.sup = a.inf * bmid + crad;
        c.inf = -(crad + a.inf * (-bmid));% equivalent to  setround(-1); c.inf = a.inf * bmid - crad;
      elseif bthin
        amid = a.inf + 0.5*(a.sup-a.inf); % IR * R
        arad = amid - a.inf;
        crad = arad * abs(b.inf);
        c.inf = 0;                        % preserve order of definition of intval c
        c.sup = amid * b.inf + crad;
        c.inf = -(crad + (-amid) * b.inf);% equvalent to  setround(-1); c.inf = amid * b.inf - crad; 
      else                                  % IR * IR
        if INTLAB_CONST.INTVAL_IVMULT || (n==1)  % interval mtimes interval by outer product
          % index sets for first factor (also necessary for both factors containing proper zero intervals)
          index_ainf_neg = (a.inf<0);       % entries containing negative numbers
          index_asup_pos = (a.sup>0);       % entries containing positive numbers
          index_a_0 = (index_ainf_neg & index_asup_pos);   % proper zero intervals
          % index sets for second factor (also necessary for both factors containing proper zero intervals)
          index_binf_neg = (b.inf<0);       % entries containing negative numbers
          index_bsup_pos = (b.sup>0);       % entries containing positive numbers
          index_b_0 = (index_binf_neg & index_bsup_pos);   % proper zero intervals
          if ~any(any(index_a_0))           % first factor does not contain proper zero intervals
            % additional index sets for second factor
            index_binf_pos = (b.inf>0);     % positive entries 
            index_bsup_neg = (b.sup<0);     % negative entries
            if any(index_ainf_neg(:))       % there are non-positive intervals
              if issparse(a.inf)
                dd = a.sup;
                dd(a.inf<0) = -1;
                dd(a.sup>0) = 1;
                index = ( dd<0 );
                ainf = sparse([],[],[],m,n);
                ainf(index) = a.inf(index);
              else
                ainf = a.inf;
                ainf(index_asup_pos) = 0;   % only non-positive entries
              end
              if issparse(a.sup)
                [ia,ja,sa] = find(a.sup);
                index = ( sa<=0 );
                asup = sparse(ia(index),ja(index),sa(index),m,n);
              else
                asup = a.sup;
                asup(index_asup_pos) = 0;   % only non-positive entries
              end
                                            % lower bound, factor is b.sup
              if any(index_bsup_neg(:))
                if issparse(b.sup)
                  [ia,ja,sa] = find(b.sup);
                  index = ( sa<=0 );
                  bsup = sparse(ia(index),ja(index),sa(index),n,n2);
                else
                  bsup = b.sup;
                  bsup(index_bsup_pos) = 0;
                end
                c.inf = -(-asup)*bsup;
              else
                if issparse(asup)
                  c.inf = sparse([],[],[],m,n2);
                else
                  c.inf = zeros(m,n2);
                end
              end
              if any(index_bsup_pos(:))
                if issparse(b.sup)
                  [ia,ja,sa] = find(b.sup);
                  index = ( sa>=0 );
                  bsup = sparse(ia(index),ja(index),sa(index),n,n2);
                else
                  bsup = b.sup;
                  bsup(index_bsup_neg) = 0;
                end
                c.inf = -((-c.inf) + (-ainf)*bsup); % equivalent to setround(-1); c.inf = c.inf + ainf*bsup;
              end
                                                    % upper bound, factor is b.inf
              if any(index_binf_neg(:))
                if issparse(b.inf)
                  [ia,ja,sa] = find(b.inf);
                  index = ( sa<=0 );
                  binf = sparse(ia(index),ja(index),sa(index),n,n2);
                else
                  binf = b.inf;
                  binf(index_binf_pos) = 0;
                end
                c.sup = ainf*binf;
              else
                if issparse(ainf)
                  c.sup = sparse([],[],[],m,n2);
                else
                  c.sup = zeros(m,n2);
                end
              end
              if any(index_binf_pos(:))
                if issparse(b.inf)
                  [ia,ja,sa] = find(b.inf);
                  index = ( sa>=0 );
                  binf = sparse(ia(index),ja(index),sa(index),n,n2);
                else
                  binf = b.inf;
                  binf(index_binf_neg) = 0;
                end
                c.sup = c.sup + asup*binf;
              end
            else
              if issparse(a.inf)
                c.inf = sparse([],[],[],m,n2);
              else                
                c.inf = zeros(m,n2);
              end
              c.sup = c.inf;
            end
            if any(index_asup_pos(:))     % there are non-positive intervals
              if issparse(a.inf)
                [ia,ja,sa] = find(a.inf);
                index = ( sa>=0 );
                ainf = sparse(ia(index),ja(index),sa(index),m,n);
              else
                ainf = a.inf;
                ainf(index_ainf_neg) = 0;   % only non-negative entries
              end
              if issparse(a.sup)
                dd = a.inf;
                dd(a.sup>0) = 1;
                dd(a.inf<0) = -1;
                index = ( dd>0 );
                asup = sparse([],[],[],m,n);
                asup(index) = a.sup(index);
              else
                asup = a.sup;
                c.mid = [];
                c.rad = [];
                asup(index_ainf_neg) = 0;   % only non-negative entries
              end
                                            % lower bound
              if any(index_binf_neg(:))
                if issparse(b.inf)
                  [ia,ja,sa] = find(b.inf);
                  index = ( sa<=0 );
                  binf = sparse(ia(index),ja(index),sa(index),n,n2);
                else
                  binf = b.inf;
                  binf(index_binf_pos) = 0;
                end
                c.inf = -((-c.inf) + (-asup)*binf);   % equivalent to  setround(-1); c.inf = c.inf + asup*binf;
              end
              if any(index_binf_pos(:))
                if issparse(b.inf)
                  [ia,ja,sa] = find(b.inf);
                  index = ( sa>=0 );
                  binf = sparse(ia(index),ja(index),sa(index),n,n2);
                else
                  binf = b.inf;
                  binf(index_binf_neg) = 0;
                end
                c.inf = -((-c.inf) + (-ainf)*binf);    % equivalent to  setround(-1); c.inf = c.inf + ainf*binf; 
                c.mid = [];
                c.rad = [];
              end
              % upper bound
              if any(index_bsup_neg(:))
                if issparse(b.sup)
                  [ia,ja,sa] = find(b.sup);
                  index = ( sa<=0 );
                  bsup = sparse(ia(index),ja(index),sa(index),n,n2);
                else
                  bsup = b.sup;
                  bsup(index_bsup_pos) = 0;
                end
                c.sup = c.sup + ainf*bsup;
              end
              if any(index_bsup_pos(:))
                if issparse(b.sup)
                  [ia,ja,sa] = find(b.sup);
                  index = ( sa>=0 );
                  bsup = sparse(ia(index),ja(index),sa(index),n,n2);
                else
                  bsup = b.sup;
                  bsup(index_bsup_neg) = 0;
                end
                c.sup = c.sup + asup*bsup;
              end
            end
          elseif ~any(any(index_b_0))     % second factor does not contain proper zero intervals
            % zero_a=1, i.e. a contains proper zero intervals
            % additional index sets for second factor
            index_ainf_pos = (a.inf>0);       % positive entries 
            index_asup_neg = (a.sup<0);       % negative entries
            if any(index_binf_neg(:))     % there are non-positive intervals
              if issparse(b.inf)
                dd = b.sup;
                dd(b.inf<0) = -1;
                dd(b.sup>0) = 1;
                index = ( dd<0 );
                binf = sparse([],[],[],n,n2);
                binf(index) = b.inf(index);
              else
                binf = b.inf;
                binf(index_bsup_pos) = 0;   % only non-positive entries
              end
              if issparse(b.sup)
                [ia,ja,sa] = find(b.sup);
                index = ( sa<=0 );
                bsup = sparse(ia(index),ja(index),sa(index),n,n2);
              else
                bsup = b.sup;
                bsup(index_bsup_pos) = 0;   % only non-positive entries
              end
                                            % lower bound, factor is a.sup
              if any(index_asup_neg(:))
                if issparse(a.sup)
                  [ia,ja,sa] = find(a.sup);
                  index = ( sa<=0 );
                  asup = sparse(ia(index),ja(index),sa(index),m,n);
                else
                  asup = a.sup;
                  asup(index_asup_pos) = 0;
                end
                c.inf = -(-asup)*bsup;
              else
                if issparse(bsup)
                  c.inf = sparse([],[],[],m,n2);
                else
                  c.inf = zeros(m,n2);
                end
              end
              if any(index_asup_pos(:))
                if issparse(a.sup)
                  [ia,ja,sa] = find(a.sup);
                  index = ( sa>=0 );
                  asup = sparse(ia(index),ja(index),sa(index),m,n);
                else
                  asup = a.sup;
                  asup(index_asup_neg) = 0;
                end
                c.inf = -((-c.inf) + (-asup)*binf);   % equivalent to  setround(-1); c.inf = c.inf + asup*binf;
              end
                                                      % upper bound, factor is a.inf
              if any(index_ainf_neg(:))
                if issparse(a.inf)
                  [ia,ja,sa] = find(a.inf);
                  index = ( sa<=0 );
                  ainf = sparse(ia(index),ja(index),sa(index),m,n);
                else
                  ainf = a.inf;
                  ainf(index_ainf_pos) = 0;
                end
                c.sup = ainf*binf;
              else
                if issparse(binf)
                  c.sup = sparse([],[],[],m,n2);
                else
                  c.sup = zeros(m,n2);
                end
              end
              if any(index_ainf_pos(:))
                if issparse(a.inf)
                  [ia,ja,sa] = find(a.inf);
                  index = ( sa>=0 );
                  ainf = sparse(ia(index),ja(index),sa(index),m,n);
                else
                  ainf = a.inf;
                  ainf(index_ainf_neg) = 0;
                end
                c.sup = c.sup + ainf*bsup;
              end
            else
              if issparse(a.inf)
                c.inf = sparse([],[],[],m,n2);
              else                
                c.inf = zeros(m,n2);
              end
              c.sup = c.inf;
            end
            if any(index_bsup_pos(:))     % there are non-positive intervals
              if issparse(b.inf)
                [ia,ja,sa] = find(b.inf);
                index = ( sa>=0 );
                binf = sparse(ia(index),ja(index),sa(index),n,n2);
              else
                binf = b.inf;
                binf(index_binf_neg) = 0;   % only non-negative entries
              end
              if issparse(b.sup)
                dd = b.inf;
                dd(b.sup>0) = 1;
                dd(b.inf<0) = -1;
                index = ( dd>0 );
                bsup = sparse([],[],[],n,n2);
                bsup(index) = b.sup(index);
              else
                bsup = b.sup;
                bsup(index_binf_neg) = 0;   % only non-negative entries
              end
                                            % lower bound, factor is a.inf
              if any(index_ainf_neg(:))
                if issparse(a.inf)
                  [ia,ja,sa] = find(a.inf);
                  index = ( sa<=0 );
                  ainf = sparse(ia(index),ja(index),sa(index),m,n);
                else
                  ainf = a.inf;
                  ainf(index_ainf_pos) = 0;
                end
                c.inf = -((-c.inf) + (-ainf)*bsup);  % equivalent to setround(-1); c.inf = c.inf + ainf*bsup;
              end
              if any(index_ainf_pos(:))
                if issparse(a.inf)
                  [ia,ja,sa] = find(a.inf);
                  index = ( sa>=0 );
                  ainf = sparse(ia(index),ja(index),sa(index),m,n);
                else
                  ainf = a.inf;
                  ainf(index_ainf_neg) = 0;
                end
                c.inf = -((-c.inf) + (-ainf)*binf);  % equivalent to setround(-1); c.inf = c.inf + ainf*binf;
              end
                                                     % upper bound, factor is a.sup
              if any(index_asup_neg(:))
                if issparse(a.sup)
                  [ia,ja,sa] = find(a.sup);
                  index = ( sa<=0 );
                  asup = sparse(ia(index),ja(index),sa(index),m,n);
                else
                  asup = a.sup;
                  asup(index_asup_pos) = 0;
                end
                c.sup = c.sup + asup*binf;
              end
              if any(index_asup_pos(:))
                if issparse(a.sup)
                  [ia,ja,sa] = find(a.sup);
                  index = ( sa>=0 );
                  asup = sparse(ia(index),ja(index),sa(index),m,n);
                else
                  asup = a.sup;
                  asup(index_asup_neg) = 0;
                end
                c.sup = c.sup + asup*bsup;
              end
            end
          else                            % both factors contain proper zero intervals
            % index sets for first factor already computed
            % index_ainf_neg = ( a.inf < 0);  
            % index_asup_pos = ( a.sup > 0);
            % index_a_0 = (index_ainf_neg & index_asup_pos);
            % submatrices of first factor
            if issparse(a.inf)
              % avoid matrix(index)=0, very slow for sparse matrices with not so few elements
              % ainf_neg = a.inf; ainf_neg(index_asup_pos) = 0;         
              dd = a.sup;
              dd(a.inf<0) = -1;
              dd(a.sup>0) = 1;
              index = ( dd<0 );
              ainf_neg = sparse([],[],[],m,n);
              ainf_neg(index) = a.inf(index);
              % ainf_pos = a.inf; ainf_pos(index_ainf_neg) = 0;
              [ia,ja,sa] = find(a.inf);
              index = ( sa>=0 );
              ainf_pos = sparse(ia(index),ja(index),sa(index),m,n);
              % asup_neg = a.sup; asup_neg(index_asup_pos) = 0;
              [ia,ja,sa] = find(a.sup);
              index = ( sa<=0 );
              asup_neg = sparse(ia(index),ja(index),sa(index),m,n);
              % asup_pos = a.sup; asup_pos(index_ainf_neg) = 0;              
              dd = a.inf;
              dd(a.sup>0) = 1;
              dd(a.inf<0) = -1;
              index = ( dd>0 );
              asup_pos = sparse([],[],[],m,n);
              asup_pos(index) = a.sup(index);
              % prepare for ainf_0 and asup_0         
              ainf_0 = sparse([],[],[],m,n,0);
            else
              ainf_neg = a.inf; ainf_neg(index_asup_pos) = 0;         
              ainf_pos = a.inf; ainf_pos(index_ainf_neg) = 0;
              asup_neg = a.sup; asup_neg(index_asup_pos) = 0;
              asup_pos = a.sup; asup_pos(index_ainf_neg) = 0;
              % prepare for ainf_0 and asup_0   
              ainf_0 = zeros(m,n);
            end
            asup_0 = ainf_0;
            ainf_0(index_a_0) = a.inf(index_a_0); 
            asup_0(index_a_0) = a.sup(index_a_0);
            % index sets for second factor already computed
            % index_binf_neg = ( b.inf < 0); 
            % index_bsup_pos = ( b.sup > 0);
            % index_b_0 = (index_binf_neg & index_bsup_pos);
            % submatrices of second factor  
            if issparse(b.inf)
              % avoid matrix(index)=0, very slow for sparse matrices with not so few elements
              % binf_neg = b.inf; binf_neg(index_bsup_pos) = 0;
              dd = b.sup;
              dd(b.inf<0) = -1;
              dd(b.sup>0) = 1;
              index = ( dd<0 );
              binf_neg = sparse([],[],[],n,n2);
              binf_neg(index) = b.inf(index);
              % binf_pos = b.inf; binf_pos(index_binf_neg) = 0;
              [ia,ja,sa] = find(b.inf);
              index = ( sa>=0 );
              binf_pos = sparse(ia(index),ja(index),sa(index),n,n2);
              % bsup_neg = b.sup; bsup_neg(index_bsup_pos) = 0;
              [ia,ja,sa] = find(b.sup);
              index = ( sa<=0 );
              bsup_neg = sparse(ia(index),ja(index),sa(index),n,n2);
              % bsup_pos = b.sup; bsup_pos(index_binf_neg) = 0;
              dd = b.inf;
              dd(b.sup>0) = 1;
              dd(b.inf<0) = -1;
              index = ( dd>0 );
              bsup_pos = sparse([],[],[],n,n2);
              bsup_pos(index) = b.sup(index);
              % prepare for binf_0 and bsup_0         
              binf_0 = sparse([],[],[],n,n2,0);
            else
              binf_neg = b.inf; binf_neg(index_bsup_pos) = 0;
              binf_pos = b.inf; binf_pos(index_binf_neg) = 0;
              bsup_neg = b.sup; bsup_neg(index_bsup_pos) = 0;
              bsup_pos = b.sup; bsup_pos(index_binf_neg) = 0;
              % prepare for binf_0 and bsup_0   
              binf_0 = zeros(n,n2);
            end
            bsup_0 = binf_0;
            binf_0(index_b_0) = b.inf(index_b_0); 
            bsup_0(index_b_0) = b.sup(index_b_0);
            % check existence of both proper zero intervals
            index0 = find( any(index_a_0,1) & any(index_b_0',1) );
            % lower bound            
            setround(-1)
            % everything except proper zero intervals
            c.inf = asup_neg*bsup_neg + (ainf_neg+ainf_0)*bsup_pos + ainf_neg*bsup_0 + ...
              (asup_0+asup_pos)*binf_neg + asup_pos*binf_0 + ainf_pos*binf_pos;
            % lower bound of product of proper zero intervals
            if issparse(c.inf)              % sparse product
              delta = sparse(0);            % sparse initialization
              len0 = length(index0);
              % faster summation by unrolled loop adding sparse matrices with fewer elements
              N = 6;                        % terms in unrolled loop
              for kk=1:N:(len0-N+1)
                k = index0(kk);
                k1 = index0(kk+1);
                k2 = index0(kk+2);
                k3 = index0(kk+3);
                k4 = index0(kk+4);
                k5 = index0(kk+5);
                delta = delta + ...
                  ( min( ainf_0(:,k)*bsup_0(k,:) , asup_0(:,k)*binf_0(k,:) ) + ...
                  min( ainf_0(:,k1)*bsup_0(k1,:) , asup_0(:,k1)*binf_0(k1,:) ) + ...
                  min( ainf_0(:,k2)*bsup_0(k2,:) , asup_0(:,k2)*binf_0(k2,:) ) + ...
                  min( ainf_0(:,k3)*bsup_0(k3,:) , asup_0(:,k3)*binf_0(k3,:) ) + ...
                  min( ainf_0(:,k4)*bsup_0(k4,:) , asup_0(:,k4)*binf_0(k4,:) ) + ...
                  min( ainf_0(:,k5)*bsup_0(k5,:) , asup_0(:,k5)*binf_0(k5,:) ) );
              end
              % take care of possibly remaining terms
              for kk=(N*floor(len0/N)+1):len0
                k = index0(kk);
                delta = delta + min( ainf_0(:,k)*bsup_0(k,:) , asup_0(:,k)*binf_0(k,:) );
              end
              c.inf = c.inf + delta;
            else                            % full product
              for k=index0
                c.inf = c.inf + min( ainf_0(:,k)*bsup_0(k,:) , asup_0(:,k)*binf_0(k,:) );
              end
            end
            setround(1)
            % everything except proper zero intervals
            c.sup = asup_neg*binf_pos + (ainf_neg+ainf_0)*binf_neg + ainf_neg*binf_0 + ...
              (asup_0+asup_pos)*bsup_pos + asup_pos*bsup_0 + ainf_pos*bsup_neg;
            % upper bound of product of proper zero intervals
            if issparse(c.sup)              % sparse product
              delta = sparse(0);            % sparse initialization
              % faster summation by unrolled loop adding sparse matrices with fewer elements
              for kk=1:N:(len0-N+1)
                k = index0(kk);
                k1 = index0(kk+1);
                k2 = index0(kk+2);
                k3 = index0(kk+3);
                k4 = index0(kk+4);
                k5 = index0(kk+5);
                delta = delta + ...
                  ( max( ainf_0(:,k)*binf_0(k,:) , asup_0(:,k)*bsup_0(k,:) ) + ...
                  max( ainf_0(:,k1)*binf_0(k1,:) , asup_0(:,k1)*bsup_0(k1,:) ) + ...
                  max( ainf_0(:,k2)*binf_0(k2,:) , asup_0(:,k2)*bsup_0(k2,:) ) + ...
                  max( ainf_0(:,k3)*binf_0(k3,:) , asup_0(:,k3)*bsup_0(k3,:) ) + ...
                  max( ainf_0(:,k4)*binf_0(k4,:) , asup_0(:,k4)*bsup_0(k4,:) ) + ...
                  max( ainf_0(:,k5)*binf_0(k5,:) , asup_0(:,k5)*bsup_0(k5,:) ) );
              end
              % take care of possibly remaining terms
              for kk=(N*floor(len0/N)+1):len0
                k = index0(kk);
                delta = delta + max( ainf_0(:,k)*binf_0(k,:) , asup_0(:,k)*bsup_0(k,:) );
              end
              c.sup = c.sup + delta;
            else                            % full product
              for k=index0
                c.sup = c.sup + max( ainf_0(:,k)*binf_0(k,:) , asup_0(:,k)*bsup_0(k,:) );
              end
            end
          end
        else
          % Rounding is upwards in any case.                                    
          amid = a.inf + 0.5*(a.sup-a.inf);  % fast interval mtimes interval thru mid/rad arithmetic
          arad = amid - a.inf;
          bmid = b.inf + 0.5*(b.sup-b.inf);
          brad = bmid - b.inf;
          crad = arad * ( abs(bmid) + brad ) + abs(amid) * brad ;
          c.inf = 0;                    % preserve order of definition of intval c
          c.sup = amid*bmid + crad;
          c.inf = -(crad + (-amid)*bmid); % equivalent to setround(-1); c.inf = amid*bmid - crad;
        end
      end
    end
  end
  
  % non-interval output for performance improvement for hessians
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
  
end  % function mtimes


function a = inf0(zeroinf,a)
% replace NaN (caused by 0*inf) by 0 
  if zeroinf
    index = isnan(a);
    if any(index(:))
      global INTLAB_CONST
      INTLAB_CONST.RealStdFctsExcptnOccurred = 1;
      a(index) = 0;
    end
  end
end  % function inf0
  