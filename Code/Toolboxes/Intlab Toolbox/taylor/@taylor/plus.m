function r = plus(a,b)
%PLUS         Taylor addition  a + b
%

% written  05/21/09     S.M. Rump
% modified 04/04/14     S.M. Rump  affari added
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%
  
  rndold = getround;
  if rndold
    setround(0)
  end

  if ~isa(a,'taylor')               % non-Taylor plus Taylor
    r = b;
    if isa(a,'intval')
      r.t = intval(r.t);
    elseif isa(a,'affari')
      r.t = affari(r.t);
    end
    if isscalar(a)
      r.t(1,:) = r.t(1,:) + a;
    else
      sizeb = prod(b.size);
      if prod(sizeb)==1
        r.size = size(a);
        r.t = repmat(r.t,prod(r.size));
        r.t(1,:) = r.t(1,:) + a(:).';
      else
        if ~isequal(size(a),b.size)
          error('operands of different size')
        end
        r.t(1,:) = r.t(1,:) + a(:).';
      end
    end
  elseif ~isa(b,'taylor')           % Taylor plus non-Taylor
    r = a;
    if isa(b,'intval')
      r.t = intval(r.t);
    elseif isa(b,'affari')
      r.t = affari(r.t);
    end
    if isscalar(b)
      r.t(1,:) = r.t(1,:) + b;
    else
      sizea = prod(a.size);
      if prod(sizea)==1
        r.size = size(b);
        r.t = repmat(r.t,prod(r.size));
        r.t(1,:) = r.t(1,:) + b(:).';
      else
        if ~isequal(size(b),a.size)
          error('operands of different size')
        end
        r.t(1,:) = r.t(1,:) + b(:).';
      end
    end
  else                              % Taylor plus Taylor
    r = a;
    if isa(b.t,'intval')
      r.t = intval(r.t);
    elseif isa(b.t,'affari')
      r.t = affari(r.t);
    end
    sa = prod(a.size);
    sb = prod(b.size);
    if sa==1                        % a is scalar
      if sb~=1                      % b is not scalar
        r.size = b.size;
        a.t = repmat(a.t,1,sb);
      end
    else                            % a is not scalar
      if sb==1                      % b is scalar
        b.t = repmat(b.t,1,sa);
      else
        if ~isequal(a.size,b.size)
          error('operands of different size')
        end
      end
    end
    r.t = a.t + b.t;
  end
  
  if rndold
    setround(rndold)
  end
