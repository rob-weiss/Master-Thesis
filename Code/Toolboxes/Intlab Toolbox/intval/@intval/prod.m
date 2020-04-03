function c = prod(a,dim)
%PROD         Implements  prod(a,dim)  for intervals
%
%   c = prod(a,dim)
%
% functionality as Matlab function prod for matrices, parameter dim optional
%

% written  10/16/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 08/28/15     S.M. Rump  complete redesign (thanks to Florian Bünger)
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  rndold = getround;
  if rndold
    setround(0)
  end

  [m n] = size(a);
  if nargin==1,
    if m==1
      dim = 2;
    else
      dim = 1;
    end
  end
  
  if isreal(a)                      % real input
    if all(all(a.inf==a.sup))       % point interval input
      setround(-1)
      cinf = prod(a.inf,dim);
      setround(1)
      csup = prod(a.inf,dim);
      c = intval(cinf,csup,'infsup');
    else                            % thick interval input
      s = 0;
      ainf = a.inf;
      asup = a.sup;
      index = ( asup<0 );
      if any(index(:))              % make sure asup>=0
        c = ainf(index);
        ainf(index) = -asup(index);
        asup(index) = -c;
        s = sum(index,dim);         % sign information
      end
      index = ( abs(ainf)>abs(asup) );
      if any(index(:))              % make sure asup >= -ainf >= 0
        c = ainf(index);
        ainf(index) = -asup(index);
        asup(index) = -c;
        s = s + sum(index,dim);    	% sign information
      end
      setround(-1)
      cinf = prod(abs(ainf),dim);   % correct for ainf>0 subject to sign
      setround(1)
      csup = prod(asup,dim);        % largest absolute value
      index = ( ainf<0 );
      if any(index(:))              % treat (proper) zero intervals
        N = NaN(size(ainf));        % ignore ~index
        D = N;
        N(index) = abs(ainf(index));
        D(index) = abs(asup(index));
        q = max(N./D,[],dim);       % NaN is ignored; bound correct because setround(1)
        index0 = isnan(q);          % not affected indices
        if any(index0)
          c = cinf;
          cinf = -( q.*csup );
          cinf(index0) = c(index0); % recover not affected indices
        else
          cinf = -( q.*csup );
        end
      end
      index = ( 2*round(s/2)~=s );
      if any(index)                 % correct sign
        c = cinf(index);
        cinf(index) = -csup(index);
        csup(index) = -c;
      end
      index = ( isnan(cinf) | isnan(csup) ) & ( ~any(isnan(a),dim) );
      if any(index(:))              % take care of 0*inf
        cinf(index) = -inf;
        csup(index) = inf;
      end
      c = intval(cinf,csup,'infsup');
    end
  else                              % complex input
    if dim==1                       % use for-loops
      c = ones(1,n);
      for i=1:m
        %VVVV c = c .* a(i,:);
        s.type = '()'; s.subs = {i,':'}; c = c .* subsref(a,s);
        %AAAA Matlab V5.2 bug fix
      end
    else
      c = ones(m,1);
      for i=1:n
        %VVVV c = c .* a(:,i);
        s.type = '()'; s.subs = {':',i}; c = c .* subsref(a,s);
        %AAAA Matlab V5.2 bug fix
      end
    end
  end
  
  setround(rndold)
  
end  % function prod
