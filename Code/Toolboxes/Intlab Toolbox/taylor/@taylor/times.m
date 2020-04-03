function r = times(a,b)
%TIMES        Taylor multiplication  a .* b
%

% written  05/21/09     S.M. Rump
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/04/14     S.M. Rump  affari added
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 12/12/15     S.M. Rump  prod(size) to numel(s)
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
% modified 10/21/17     S.M. Rump  size of result
%

  global INTLAB_CONST
  
  rndold = getround;
  if rndold
    setround(0)
  end

  K1 = INTLAB_CONST.TAYLOR_ORDER + 1;

  if ~isa(a,'taylor')           % non-taylor times taylor
    r = b;
    if isa(a,'intval')
      r.t = intval(r.t);
    elseif isa(a,'affari')
      r.t = affari(r.t);
    end
    m = numels(a);
    if m==1                     % non-taylor scalar .* taylor
      r.t = a*r.t;
    else                        % non-taylor array .* taylor
      n = prod(b.size);
      if n==1                   % non-taylor array .* taylor scalar
        r.size = size(a);
        r.t = repmat(a(:).',K1,1) .* repmat(b.t,1,m);
      else                      % non-taylor array .* taylor array
        if ~isequal(size(a),b.size)
          error('Taylor multiplication : dimensions not compatible')
        end
        r.t = repmat(a(:).',K1,1) .* b.t;
      end
    end
  elseif ~isa(b,'taylor')       % taylor times non-taylor
    r = a;
    if isa(b,'intval')
      r.t = intval(r.t);
    elseif isa(b,'affari')
      r.t = affari(r.t);
    end
    m = numels(b);
    if m==1                     % taylor scalar .* non-taylor
      r.t = r.t*b;
    else                        % taylor array .* non-taylor
      n = prod(a.size);
      if n==1                   % taylor array .* non-taylor scalar
        r.t = repmat(a.t,1,m) .* repmat(b(:).',K1,1);
        r.size = size(b);
      else                      % non-taylor array .* taylor array
        if ~isequal(size(b),a.size)
          error('Taylor multiplication : dimensions not compatible')
        end
        r.t = a.t .* repmat(b(:).',K1,1);
      end
    end
  else                          % both factors taylor
    m = prod(a.size);
    n = prod(b.size);
    if m==1                     % taylor scalar .* taylor
      r = b;
      if isa(a.t,'intval')
        r.t = intval(r.t);
      elseif isa(a.t,'affari')
        r.t = affari(r.t);
      end
      for j=1:K1
        r.t(j,:) = sum(repmat(a.t(1:j),1,n).*b.t(j:-1:1,:),1);
      end
    else                        % taylor array .* taylor
      r = a;
      if isa(b.t,'intval')
        r.t = intval(r.t);
      elseif isa(b.t,'affari')
        r.t = affari(r.t);
      end
      if n==1                   % taylor array .* taylor scalar
        for j=1:K1
          r.t(j,:) = sum(a.t(1:j,:).*repmat(b.t(j:-1:1),1,m),1);
        end
      else                      % taylor array .* taylor array
        if ~isequal(a.size,b.size)
          error('Taylor multiplication : dimensions not compatible')
        end
        for j=1:K1
          r.t(j,:) = sum(a.t(1:j,:).*b.t(j:-1:1,:),1);
        end
      end
    end
  end
  
  if rndold
    setround(rndold)
  end
