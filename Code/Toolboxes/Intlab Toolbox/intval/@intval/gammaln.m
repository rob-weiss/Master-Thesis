function y = gammaln(x)
%GAMMALN      Implements  gammaln(x)  for real non-negative intervals
%
%   y = gammaln(x)
%
%interval standard function implementation
%

% written  01/11/14     S.M. Rump
% modified 07/21/15     S.M. Rump  old RealStdFctsExcptnIgnore/Occurred deleted
%                                    new design hidden from user
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST

  if x.complex
    error('log(Gamma) function only for non-negative real arguments')
  end
  wng = warning;
  warning off
  
  if issparse(x)
    index = ( x==0 );
    if any(index(:))                    % treat zero indices
      y = intval(NaN(size(x)));
      index = ~index;
      %VVVV  y(index) = gamma(full(x(index)));
      s.type = '()'; s.subs = {index}; y = subsasgn(y,s,gammaln(full(subsref(x,s))));
      %AAAA  Matlab bug fix
    else
      y = gammaln(full(x));
    end
    warning(wng);
    return
  end
  
  if INTLAB_CONST.RealStdFctsExcptnIgnore
    index = ( x.inf<0 );
    if any(index(:))
      INTLAB_CONST.RealStdFctsExcptnOccurred = 1;
      x.inf(index) = 0;
    end
    index = ( x.sup<=0 );
    if any(index(:))
      INTLAB_CONST.RealStdFctsExcptnOccurred = 1;
      x.sup(index) = 0;
    end
  else
    index = ( x.inf<0 );
    if any(index(:))                          % negative entries
      y = x;
      y.inf(index) = NaN;
      y.sup(index) = NaN;
      index = ~index;                         % x non-negative
      yy = gammaln(intval(x.inf(index),x.sup(index),'infsup'));
      y.inf(index) = yy.inf;
      y.sup(index) = yy.sup;
      warning(wng);
      return
    end
  end

  rndold = getround;
  if rndold
    setround(0)
  end
  
  y = x;                                    % x non-negative
  
  if all( x.inf(:)==x.sup(:) );             % thin input
    
    xx = x.inf(:);
    yinf = xx;
    ysup = xx;
    index = ( xx>0.5 ) & ( xx<2.5 );        % (0.5,2.5)
    if any(index)
      xxx = xx(index);
      yinf(index) = gammaln_rnd(xxx,-1);
      ysup(index) = gammaln_rnd(xxx,+1);
    end
    
    index1 = ~index;                        % [0,0.5] and [2.5,inf]

    index = ( xx>=40 ) & ( index1 );        % [40,inf]
    if any(index(:))                        % treat indices with x>=40
      xxx = xx(index);
      yy = ( intval(xxx)-0.5) .* log(intval(xxx)) - xxx;
      log2pi2inf = hex2num('3fed67f1c864beb4');
      log2pi2sup = hex2num('3fed67f1c864beb5');
      b = [ 12 -360 1260 -1680];            % B_2k/(2k(2k-1))
      for rnd=[-1 1]
        setround(rnd)
        t = 1./xxx;
        xx2 = xxx.*xxx;
        s = t/12;
        for k=2:3
          t = t./xx2;
          s = s + t/b(k);
        end
        err = t./(xx2*b(4));
        if rnd==-1
          yinf(index) = yy.inf + ( s + ( log2pi2inf + min(0,err) ) );
        else
          ysup(index) = yy.sup + ( s + ( log2pi2sup + max(0,err) ) );
        end
      end      
    end
    
    index = ( xx<40 ) & ( index1 );         % [0,0.5] and [2.5,40)
    if any(index(:))
      yy = log(gamma(intval(xx(index))));
      yinf(index) = yy.inf;
      ysup(index) = yy.sup;
    end

    y = intval(yinf,ysup,'infsup');
    
  else                                      % thick input
    
    xinf = x.inf(:);                        % no non-positive integer in x
    xsup = x.sup(:);
    xmin = hex2num('3ff762d86356be3f');     % gamma'(xmin) < 0 < gamma'(succ(xmin))
    ymin = hex2num('bfbf19b9bcc38a42');     % gammaln(x)>ymin for x>0
    
    index = ( xsup<=xmin);                  % x left of minimum
    if any(index(:))
      y.inf(index) = inf(gammaln(intval(xsup(index))));
      y.sup(index) = sup(gammaln(intval(xinf(index))));
    end
    index = ( xmin<xinf);                   % x right of minimum
    if any(index(:))
      y.inf(index) = inf(gammaln(intval(xinf(index))));
      y.sup(index) = sup(gammaln(intval(xsup(index))));
    end
    index = ( xinf<=xmin) & ( xmin<xsup);   % minimum in x
    if any(index(:))
      y.inf(index) = ymin;
      y.sup(index) = max(sup(gammaln(intval(xinf(index)))),sup(gammaln(intval(xsup(index)))));
    end
        
  end

  if INTLAB_CONST.RealStdFctsExcptnIgnore
    index = ( x.inf==0 );
    if any(index(:))
      INTLAB_CONST.RealStdFctsExcptnOccurred = 1;
      y.sup(index) = inf;
    end
    index = index & ( x.sup==0 );
    if any(index(:))
      y.inf(index) = NaN;
      y.sup(index) = NaN;
    end
  end
  
  y.inf = reshape(y.inf,size(x.inf));
  y.sup = reshape(y.sup,size(x.sup));
  
  warning(wng);
  setround(rndold)  
