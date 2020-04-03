function y = atanh(x)
%ATANH        Implements  atanh(x)  for intervals
%
%   y = atanh(x)
%
%interval standard function implementation
%

% written  12/30/98     S.M. Rump
% modified 08/31/99     S.M. Rump  complex allowed, sparse input,
%                                  major revision, improved accuracy
% modified 09/02/00     S.M. Rump  rounding unchanged after use
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 12/04/05     S.M. Rump  'realstdfctsexcptnignore' added and some
%                                     improvements, tocmplx replaced by cintval
% modified 09/06/07     S.M. Rump  approximate std fcts removed, exceptional arguments
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 10/18/08     S.M. Rump  StdFctsException ignore/NaN
% modified 08/26/12     S.M. Rump  global variables removed
% modified 10/13/12     S.M. Rump  INTLAB_INTVAL_STDFCTS
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/15/14     S.M. Rump  code optimization
% modified 08/01/14     S.M. Rump  Octave bug
% modified 07/21/15     S.M. Rump  old RealStdFctsExcptnIgnore/Occurred deleted
%                                    new design hidden from user
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST

  if issparse(x)
    [ix,jx,sx] = find(x);
    [m,n] = size(x);
    y = sparse(ix,jx,atanh(full(sx)),m,n);
    return
  end
  
  rndold = getround;
  if rndold
    setround(0)
  end

  if x.complex
    y = log( 2./(1-x) - 1 )/2;
    if rndold
      setround(rndold)
    end
    return
  end

  % input x real and full
  % real range of definition:  [-1,1]
  
  if INTLAB_CONST.RealStdFctsExcptnIgnore % ignore input out of range (ignore-mode)
    indexneg = ( ( x.inf<-1 ) & ( x.sup<1 ) ); % (partially) exceptional indices
    if any(indexneg(:))
      INTLAB_CONST.RealStdFctsExcptnOccurred = 1;
      x.inf(indexneg) = -1;
      x.sup(indexneg) = max(x.sup(indexneg),-1);
    end
    indexpos = ( ( x.inf>-1 ) & ( x.sup>1 ) ); % (partially) exceptional indices
    if any(indexpos(:))
      INTLAB_CONST.RealStdFctsExcptnOccurred = 1;
      x.inf(indexpos) = min(x.inf(indexpos),1);
      x.sup(indexpos) = 1;
    end
    indexentire = ( x.inf<=-1 ) & ( x.sup>= 1 ); % entire range
    indexignore = ( x.sup<=-1 ) | ( x.inf>=1 );  % out of range
    index = ( indexneg | indexpos | indexentire | indexignore);
    if any(index(:))
      y = x;
      if any(indexneg(:))
        INTLAB_CONST.RealStdFctsExcptnOccurred = 1;
        %VVVV  y(index) = atanh(intval(x(index)));
        s.type = '()'; s.subs = {indexneg}; y = subsasgn(y,s,atanh(intval(subsref(x,s))));
        %AAAA  Matlab bug fix
      end
      if any(indexpos(:))
        INTLAB_CONST.RealStdFctsExcptnOccurred = 1;
        %VVVV  y(index) = atanh(intval(x(index)));
        s.type = '()'; s.subs = {indexpos}; y = subsasgn(y,s,atanh(intval(subsref(x,s))));
        %AAAA  Matlab bug fix
      end
      if any(indexentire(:))
        INTLAB_CONST.RealStdFctsExcptnOccurred = 1;
        y.inf(indexentire) = -inf;
        y.sup(indexentire) = inf;
      end
      if any(indexignore(:))
        y.inf(indexignore) = NaN;
        y.sup(indexignore) = NaN;
      end
      index = ~index;
      if any(index(:))
        %VVVV  y(index) = sec(x(index));
        s.type = '()'; s.subs = {index}; y = subsasgn(y,s,atanh(subsref(x,s)));
        %AAAA  Matlab bug fix
      end
      if rndold
        setround(rndold)
      end
      return
    end
  else
    indexneg = ( x.inf<-1 );               % (partially) exceptional indices
    indexpos = ( x.sup>1 );                % (partially) exceptional indices
    INTLAB_STDFCTS_EXCPTN = INTLAB_CONST.STDFCTS_EXCPTN;
    if any(indexneg(:)) || any(indexpos(:)) % handle input out-of-range
      if INTLAB_STDFCTS_EXCPTN<=1   % out-of-range input handled as complex
        if INTLAB_STDFCTS_EXCPTN==1
          warning('ATANH: Real interval input out of range changed to be complex')
        end
        y = x;
        index = indexneg | indexpos;
        %VVVV  y(index) = atanh(cintval(x(index)));
        s.type = '()'; s.subs = {index}; y = subsasgn(y,s,atanh(cintval(subsref(x,s))));
        %AAAA  Matlab bug fix
        index = ~index;
        if any(index(:))
          %VVVV  y(index) = atanh(x(index));
          s.type = '()'; s.subs = {index}; y = subsasgn(y,s,atanh(subsref(x,s)));
          %AAAA  Matlab bug fix
        end
        if rndold
          setround(rndold)
        end
        return
      end
    end
  end
  
  % input x real and full
  y = x;
  wng = warning;
  warning off

  % treat non-exceptional arguments
  xinf = x.inf(:);
  xsup = x.sup(:);

  IndexInfPos = ( xinf>=0 );
  len1 = sum(IndexInfPos);
  IndexSupNeg = ( xsup<=0 );

  Y = atanh_pos( [ xinf(IndexInfPos) ; -xsup(IndexSupNeg) ] , -1 );
  y.inf(IndexInfPos) = Y(1:len1);
  y.sup(IndexSupNeg) = -Y( len1+1 : end );

  IndexInfNeg = ( xinf<0 );
  len1 = sum(IndexInfNeg);
  IndexSupPos = ( xsup>0 );
  len2 = sum(IndexSupPos);

  Y = atanh_pos( [ -xinf(IndexInfNeg) ; xsup(IndexSupPos) ] , 1 );
  y.inf(IndexInfNeg) = -Y(1:len1);
  y.sup(IndexSupPos) = Y( len1+1 : len1+len2 );

  y.inf(xinf==-1) = -inf;
  y.sup(xsup==-1) = -inf;
  y.inf(xinf==1) = inf;
  y.sup(xsup==1) = inf;

  if ~INTLAB_CONST.RealStdFctsExcptnIgnore                               % any input out of range to NaN (NaN-mode)
    index = indexneg | indexpos;
    if any(index(:))                    % exceptional arguments to NaN
      if INTLAB_CONST.OCTAVE
        y.inf = real(y.inf);
        y.sup = real(y.sup);
      end
      y.inf(index) = NaN;
      y.sup(index) = NaN;
    end
  end

  setround(rndold)
  warning(wng)
  