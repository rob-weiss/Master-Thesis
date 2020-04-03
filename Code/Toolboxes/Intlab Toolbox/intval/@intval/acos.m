function y = acos(x)
%ACOS         Implements  acos(x)  for intervals
%
%   y = acos(x)
%
%interval standard function implementation
%

% written  12/30/98     S.M. Rump
% modified 08/31/99     S.M. Rump  complex allowed, sparse input,
%                                  pos/neg split, major revision,
%                                  improved accuracy, corrected
%                                  branchcut
% modified 09/02/00     S.M. Rump  rounding unchanged after use
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    accelaration for sparse input
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 12/04/05     S.M. Rump  'realstdfctsexcptnignore' added and
%                                     some improvements
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
    index = ( x==0 );
    if any(index(:))                    % treat zero indices
      INTLAB_STDFCTS_PI = INTLAB_CONST.STDFCTS_PI;
      PI2 = intval(INTLAB_STDFCTS_PI.PI2INF,INTLAB_STDFCTS_PI.PI2SUP,'infsup');
      y = intval(repmat(PI2,size(x)));
      index = ~index;
      %VVVV  y(index) = acos(full(x(index)));
      s.type = '()'; s.subs = {index}; y = subsasgn(y,s,acos(full(subsref(x,s))));
      %AAAA  Matlab bug fix
    else
      y = acos(full(x));
    end
    return
  end
      
  rndold = getround;
  if rndold
    setround(0)
  end

  if x.complex
%   y = -i * log( x + sqrt(x.^2-1) );
    y = i * acosh(x);
    index = ( real(y.mid) < 0 );
    y.mid(index) = -y.mid(index);
    if rndold
      setround(rndold)
    end
    return
  end

  % input x real and full
  % real range of definition:  [-1,1]
  indexneg = ( x.inf<-1 );               % (partially) exceptional indices
  indexpos = ( x.sup>1 );                % (partially) exceptional indices

  if INTLAB_CONST.RealStdFctsExcptnIgnore % ignore input out of range (ignore-mode)
    if any(indexneg(:) | indexpos(:))
      INTLAB_CONST.RealStdFctsExcptnOccurred = 1;
      x.inf(indexneg) = -1;               % completely exceptional indices treated below
      x.sup(indexpos) = 1;
      y = acos(x);
      index = ( x.sup<-1 ) | ( x.inf>1 ); % completely exceptional indices
      if any(index(:))
        y.inf(index) = NaN;
        y.sup(index) = NaN;
      end
      if rndold
        setround(rndold)
      end
      return
    end
  else
    INTLAB_STDFCTS_EXCPTN = INTLAB_CONST.STDFCTS_EXCPTN;
    if any(indexneg(:)) || any(indexpos(:)) % handle input out-of-range
      if INTLAB_STDFCTS_EXCPTN<=1  % out-of-range input handled as complex
        if INTLAB_STDFCTS_EXCPTN==1
          warning('ACOS: Real interval input out of range changed to be complex')
        end
        y = x;
        exceptions = indexneg | indexpos;
        %VVVV  y(exceptions) = acos(cintval(x(exceptions)));
        s.type = '()'; s.subs = {exceptions}; y = subsasgn(y,s,acos(cintval(subsref(x,s))));
        %AAAA  Matlab bug fix
        index = ~exceptions;
        if any(index(:))
          %VVVV  y(index) = acos(x(index));
          s.type = '()'; s.subs = {index}; y = subsasgn(y,s,acos(subsref(x,s)));
          %AAAA  Matlab bug fix
        end
        if rndold
          setround(rndold)
        end
        return
      end
      if INTLAB_CONST.RealStdFctsExcptnIgnore % ignore input out of range (ignore-mode)
        INTLAB_CONST.RealStdFctsExcptnOccurred = 1;
        x.inf(indexneg) = -1;               % completely exceptional indices treated below
        x.sup(indexpos) = 1;
        Index = ( x.sup<-1 ) | ( x.inf>1 ); % completely exceptional indices
      end
    end
  end

  % input x real and full
  y = x;

  % treat non-exceptional cases
  xinf = x.inf(:);
  xsup = x.sup(:);

  % switch off warning since exceptional values may occur
  wng = warning;
  warning off

  index = ( xsup>=0 );
  if any(index)
    y.inf(index) = - asin_pos_( xsup(index) , 1 , -1 );
  end

  index = ( xsup<0 );
  if any(index)
    y.inf(index) = asin_pos_( -xsup(index) , -1 , 1 );
  end

  index = ( xinf>=0 );
  if any(index)
    y.sup(index) = - asin_pos_( xinf(index) , -1 , -1 );
  end

  index = ( xinf<0 );
  if any(index)
    y.sup(index) = asin_pos_( -xinf(index) , 1 , 1 );
  end
  
  if ~INTLAB_CONST.RealStdFctsExcptnIgnore
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

  % restore warning status
  warning(wng);

  y.inf = reshape(y.inf,size(x.inf));
  y.sup = reshape(y.sup,size(x.sup));

  setround(rndold)
