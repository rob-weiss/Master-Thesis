function y = gamma(x)
%GAMMA        Implements  gamma(x)  for real intervals
%
%   y = gamma(x)
%
%interval standard function implementation
%
% Matlab bug: Careful with arguments slightly larger than -1:
% e = 1e-7; x = linspace(-1,-1+e,100000);
% y = gamma(x); Y = gamma(intval(x));
% close, semilogy( x,abs((y-Y.mid)./(y+Y.mid)), x,relerr(Y) )
%

% written  06/19/13     S.M. Rump
% modified 08/05/13     S.M. Rump  Highly accurate results
% modified 08/07/13     S.M. Rump  special values
% modified 01/11/14     S.M. Rump  minimum
% modified 02/10/14     S.M. Rump  range reduction
% modified 03/06/14     S.M. Rump  negativ intervals (thanks to Prof. Kashiwagi)
% modified 03/30/14     S.M. Rump  Matlab bug in comment
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 07/21/15     S.M. Rump  old RealStdFctsExcptnIgnore/Occurred deleted
%                                    new design hidden from user
% modified 10/11/15     S.M. Rump  global variables
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST

  if x.complex
    error('Gamma function only for real arguments')
  end
  wng = warning;
  warning off
  
  if issparse(x)
    index = ( x==0 );
    if any(index(:))                    % treat zero indices
      y = intval(NaN(size(x)));
      index = ~index;
      %VVVV  y(index) = gamma(full(x(index)));
      s.type = '()'; s.subs = {index}; y = subsasgn(y,s,gamma(full(subsref(x,s))));
      %AAAA  Matlab bug fix
    else
      y = gamma(full(x));
    end
    warning(wng);
    return
  end
  
  indexnan = ( isnan(x.inf) | isnan(x.sup) );
  index =  ( ( x.inf<=0 ) & ( ceil(x.inf)<=floor(x.sup) ) ) | ...
    indexnan | ( x.inf==-inf ) | ( x.sup==-inf );
  if any(index)                             % non-negative integers
    if INTLAB_CONST.RealStdFctsExcptnIgnore
      INTLAB_CONST.RealStdFctsExcptnOccurred = 1;
      y = x;
      y.inf(index) = -inf;
      y.sup(index) = inf;
      Index = index & ( ( x.inf==x.sup ) | indexnan ); % true exception
      if any(Index(:))
        y.inf(Index) = NaN;
        y.sup(Index) = NaN;
      end
    else
      y = x;
      y.inf(index) = NaN;
      y.sup(index) = NaN;
    end
    index = ~index;
    yy = gamma(intval(x.inf(index),x.sup(index),'infsup'));
    y.inf(index) = yy.inf;
    y.sup(index) = yy.sup;
    warning(wng);
    return
  end

  rndold = getround;
  if rndold
    setround(0)
  end
  
  y = x;                                    % x positive or negative
  
  if all( x.inf(:)==x.sup(:) )              % thin input
    
    xx = x.inf(:);
    index = ( xx<-184 );                    % gamma(x) only in sub-underflow
    if any(index)
      y.inf(index) = 0;
      y.sup(index) = 0;  
      floor_xx = floor(xx);
      indexeven = ( floor_xx==round(floor_xx/2)*2 );
      y.inf(~indexeven) = -subrealmin;
      y.sup(indexeven) = subrealmin;
    end
    
    index1 = ( xx>=1 );                     % treated later
    
    index = ( xx>=-184 ) & ( ~index1 );
    if any(index)                           % treat indices with x<1
      xxx = xx(index);
      len = length(xxx);                    % number of elements
      col = 1 - floor(xxx);
      maxcol = max(col);
      factor = repmat(xxx,1,maxcol) + repmat(0:(maxcol-1),len,1);
      factor(factor>1) = 1;
      % accurate product   F = prod(intval(factor),2);
      [e,f] = Split(factor(:,1));
      Fhi = e;
      Flo = f;
      indexscale = [];            % possible indices for scaling to avoid overflow by splitting
      setround(0)
      for i=2:maxcol
        index_ = find( xxx < 2-i );
        if i==150
          scale = 2^300;
          indexscale = index_;
          Fhi(indexscale) = Fhi(indexscale)/scale;
          Flo(indexscale) = Flo(indexscale)/scale;
        end
        eindex_ = e(index_)+i-1;
        findex = f(index_);
        FhiIndex = Fhi(index_);
        p = FhiIndex.*eindex_;
        q = FhiIndex.*findex + Flo(index_).*factor(index_,i);
        [Fhi(index_),s] = Split(p);
        Flo(index_) = s + q;
      end
      err = 4.97e-24*col.^2.*abs(Fhi+Flo);
      F = Fhi + ( Flo + midrad(0,err) );
      index_ = ( -0.5<xxx ) & ( xxx<0 );
      if any(index_)                        % x+1 may not be exactly representable
        xx_ = xxx(index_);
        setround(-1)
        F.sup(index_) = - ( (-xx_).*(xx_+1) );
        setround(1)
        F.inf(index_) = - ( (-xx_).*(xx_+1) );
        setround(0)
      end
      xxx = intval(xxx) + col;                % x > 1
      [yinf,ysup] = gamma_rnd(xxx.inf,[]);
      index0 = ( xxx.inf~=xxx.sup );
      if any(index0)
        [y2inf,y2sup] = gamma_rnd(xxx.sup(index0),[]);
        yinf(index0) = min(yinf(index0),min(y2inf,y2sup));
        ysup(index0) = max(ysup(index0),max(y2inf,y2sup));
      end
      yy = intval(yinf,ysup,'infsup')./F;
      if ~isempty(indexscale)
        setround(-1)                    % take care of underflow!
        yy.inf(indexscale) = yy.inf(indexscale)/scale;
        setround(1)
        yy.sup(indexscale) = yy.sup(indexscale)/scale;
      end
      y.inf(index) = yy.inf;
      y.sup(index) = yy.sup;
    end
    
    if any(index1)                          % direct formula for x>=1
      [y.inf(index1),y.sup(index1)] = gamma_rnd(xx(index1),[]);    % lower and upper bound
    end
    
  else                                      % thick input
    
    xinf = x.inf(:);                        % no non-positive integer in x
    xsup = x.sup(:);
    xmin = hex2num('3ff762d86356be3f');     % gamma'(xmin) < 0 < gamma'(succ(xmin))
    gammamin = hex2num('3fec56dc82a74aee'); % gamma(x)>gammamin for x in [1,2]
    
    index = ( xinf<-184 );                  % gamma(x) only in sub-underflow
    if any(index)
      y.inf(index) = 0;
      y.sup(index) = 0;
      floor_xinf = floor(xinf);
      indexeven = ( floor_xinf==round(floor_xinf/2)*2 );
      y.inf(~indexeven) = -subrealmin;
      y.sup(indexeven) = subrealmin;
    end
    
    index = ( xinf>0 ) & ( xinf<1 );
    if any(index)                           % x.inf in (0,1)
      index1 = index & ( xsup<=xmin);       % minimum not in x
      if any(index1)
        y1 = gamma(intval(xinf(index1)));
        y2 = gamma(intval(xsup(index1)));
        y.inf(index1) = y2.inf;
        y.sup(index1) = y1.sup;
      end
      index1 = index & ( xmin<xsup);        % minimum in x
      if any(index1)
        y.inf(index1) = gammamin;
        y.sup(index1) = max(sup(gamma(intval(xinf(index1)))),gamma_rnd(xsup(index1),1));
      end
    end
    
    index = ( xinf>1 );
    if any(index)                           % x >= 1
      index1 = index & ( xsup<=xmin);       % x left of minimum
      if any(index1)
        y.inf(index1) = gamma_rnd(xsup(index1),-1);
        y.sup(index1) = gamma_rnd(xinf(index1),1);
      end
      index1 = index & ( xmin<xinf);       % x right of minimum
      if any(index1)
        y.inf(index1) = gamma_rnd(xinf(index1),-1);
        y.sup(index1) = gamma_rnd(xsup(index1),1);
      end
      index1 = index & ( xinf<=xmin) & ( xmin<xsup);  % minimum in x
      if any(index1)
        y.inf(index1) = gammamin;
        y.sup(index1) = max(gamma_rnd(xinf(index1),1),gamma_rnd(xsup(index1),1));
      end
    end
    
    index = ( xinf>-184 ) & ( xinf<0 );     % x negative w/o integer in x
    if any(index)                           
      gamma_min = INTLAB_CONST.GAMMAMIN;
      xxinf = xinf(index);
      xxsup = xsup(index);
      y1 = gamma(intval(xxinf));
      y2 = gamma(intval(xxsup));
      k = -floor(xxinf);                    % same as floor(xxsup)
      index1 = find( ( xxinf<=gamma_min(k,1) ) & ( gamma_min(k,1)<xxsup ) );
      if any(index1)
        y1.inf(index1) = min(y1.inf(index1),gamma_min(k(index1),2));
        y1.sup(index1) = max(y1.sup(index1),gamma_min(k(index1),2));
        y2.inf(index1) = min(y2.inf(index1),gamma_min(k(index1),2));
        y2.sup(index1) = max(y2.sup(index1),gamma_min(k(index1),2));
      end
      y.inf(index) = min(y1.inf,y2.inf);
      y.sup(index) = max(y1.sup,y2.sup);
    end
            
  end

  y.inf = reshape(y.inf,size(x.inf));
  y.sup = reshape(y.sup,size(x.sup));
  
  warning(wng);
  setround(rndold)  
