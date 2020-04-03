function y = asec(x)
%ASEC         Implements  asec(x)  for intervals
%
%   y = asec(x)
%
%interval standard function implementation
%

% written  10/16/98     S.M. Rump
% modified 12/30/98     S.M. Rump  improved speed and use asin
% modified 09/12/99     S.M. Rump  complex allowed, sparse input,
%                                  major revision, improved accuracy near 1
% modified 09/02/00     S.M. Rump  rounding unchanged after use
% modified 01/20/03     S.M. Rump  Matlab sqrt fixed
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    accelaration for sparse input
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 12/04/05     S.M. Rump  'realstdfctsexcptnignore' added and
%                                     some improvements
% modified 09/06/07     S.M. Rump  approximate std fcts removed, exceptional arguments
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 10/20/08     S.M. Rump  check for zero omitted
% modified 10/20/08     S.M. Rump  StdFctsException ignore/NaN
% modified 08/26/12     S.M. Rump  global variables removed
% modified 10/13/12     S.M. Rump  INTLAB_INTVAL_STDFCTS
% modified 04/04/14     S.M. Rump  end function
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/15/14     S.M. Rump  code optimization
% modified 08/01/14     S.M. Rump  Octave bug
% modified 07/21/15     S.M. Rump  old RealStdFctsExcptnIgnore/Occurred deleted
%                                    new design hidden from user
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST

  rndold = getround;
  if rndold
    setround(0)
  end

  if x.complex
    if issparse(x.mid)
      x.mid = full(x.mid);
      x.rad = full(x.rad);
    end
    y = acos( 1./x );
    if rndold
      setround(rndold)
    end
    return
  end
  
  if issparse(x.inf)
    x.inf = full(x.inf);
    x.sup = full(x.sup);
  end
  % input x real and full
  % real range of definition:  [-inf,-1] and [1,inf]
  % take care for intersection( x , (-1,1) ) nonempty
  INTLAB_STDFCTS_EXCPTN = INTLAB_CONST.STDFCTS_EXCPTN;
  Index1 = ( abs(x.inf)<1 );           % (partially) exceptional indices
  Index2 = ( abs(x.sup)<1 ); 
  
  if INTLAB_CONST.RealStdFctsExcptnIgnore % ignore input out of range (ignore-mode)
    indexpartial = ( Index1(:) | Index2(:) );
    indexentire = ( x.inf(:)<=-1 ) & ( x.sup(:)>= 1 ); % entire range
    index = ( indexpartial(:) | indexentire(:) );
    if any(index)
      INTLAB_CONST.RealStdFctsExcptnOccurred = 1;
      y = x;
      if any(Index1(:))
        % x.inf(Index1) = 1;
        % x.sup(Index1) = max(x.sup(Index1),1);
        y.inf(Index1) = 0;
        y.sup(Index1) = asec_pos(max(x.sup(Index1),1),1);
      end
      if any(Index2(:))
        % x.inf(Index2) = min(x.inf(Index2),-1);
        % x.sup(Index2) = -1;
        INTLAB_STDFCTS_PI = INTLAB_CONST.STDFCTS_PI;
        y.sup(Index2) = INTLAB_STDFCTS_PI.PISUP;
        yy = asec_pos(-min(x.inf(Index2),-1),1);
        setround(-1)
        y.inf(Index2) = INTLAB_STDFCTS_PI.PIINF - yy;
      end
      if any(indexentire(:))
        y.inf(indexentire) = -inf;
        y.sup(indexentire) = inf;
      end
      index = ~index;
      if any(index(:))
        %VVVV  y(index) = sec(x(index));
        s.type = '()'; s.subs = {index}; y = subsasgn(y,s,asec(subsref(x,s)));
        %AAAA  Matlab bug fix
      end
      if rndold
        setround(rndold)
      end
      return
    end
  else
    if any(Index1(:)) || any(Index2(:))   % handle input out-of-range
      if INTLAB_STDFCTS_EXCPTN<=1 % out-of-range input handled as complex
        if INTLAB_STDFCTS_EXCPTN==1
          warning('ASEC: Real interval input out of range changed to be complex')
        end
        y = x;
        index = Index1 | Index2;
        %VVVV  y(index) = acos(cintval(1./x(index)));
        s.type = '()'; s.subs = {index}; y = subsasgn(y,s,acos(cintval(1./subsref(x,s))));
        %AAAA  Matlab bug fix
        index = ( abs(x)>=1 );      % inside range
        if any(index(:))
          %VVVV  y(index) = acos(1./x(index));
          s.type = '()'; s.subs = {index}; y = subsasgn(y,s,acos(1./subsref(x,s)));
          %AAAA  Matlab bug fix
        end
        Index = ( x.inf<=-1 ) & ( x.sup>= 1 );
        if any(Index(:))            % exceptional arguments to NaN
          if INTLAB_CONST.OCTAVE
            y.inf = real(y.inf);
            y.sup = real(y.sup);
          end
          y.inf(Index) = NaN;
          y.sup(Index) = NaN;
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

  % treat positive intervals
  index1 = ( x.inf>0 );
  if any(index1(:))
    y.inf(index1) = asec_pos(x.inf(index1),-1);
    y.sup(index1) = asec_pos(x.sup(index1),1);
  end

  % treat negative intervals
  index1 = ( x.sup<0 );
  if any(index1(:))
    INTLAB_STDFCTS_PI = INTLAB_CONST.STDFCTS_PI;
    yy = asec_pos(-x.inf(index1),1);
    setround(-1)
    y.inf(index1) = INTLAB_STDFCTS_PI.PIINF - yy;
    yy = asec_pos(-x.sup(index1),-1);
    setround(1)
    y.sup(index1) = INTLAB_STDFCTS_PI.PISUP - yy;
  end
  
  Index = Index1 | Index2;
  if any(Index(:))                    % exceptional arguments to NaN
    if INTLAB_CONST.OCTAVE
      y.inf = real(y.inf);
      y.sup = real(y.sup);
    end
    y.inf(Index) = NaN;
    y.sup(Index) = NaN;
  end
  
  setround(rndold)
  warning(wng)
  
end  % function asec


function y = asec_pos(x,rnd)
% local asec for double vector x>=1 with rounding corresponding to rnd
%

  y = x;
  setround(rnd)

  index = ( x<1.5 );              % 1 <= x < 1.5
  if any(index(:))
    e = x(index) - 1;             % difference exact because x near 1
    e = sqrt_rnd( e.*(2+e) , rnd );
    y(index) = atan_pos(e(:),rnd);
  end

  index1 = ( x>1e17 );            % x > 1e17
  if any(index1(:))
    e = x(index1) - eps;
    y(index1) = atan_pos(e(:),rnd);
  end

  index = ~( index | index1 );    % 1.5 <= x <= 1e17
  if any(index(:))
    e = x(index);
    e = sqrt_rnd(e.*e-1,rnd);
    y(index) = atan_pos(e(:),rnd);
  end
  
end  % functoin asec_pos
