function c = mid(a)
%MID          Implements  mid(a)  for intervals (rounded)
%
%   c = mid(a)
%
% mid(a) and rad(a) computed such that
%    alpha  in  < mid(a) , rad(a) >  for all alpha in a
%
%For intervals at least 3 bits wide, the midpoint is always an inner point.
%

% written  10/16/98     S.M. Rump
% modified 06/22/99     S.M. Rump  for sparse matrices
% modified 09/02/00     S.M. Rump  rounding unchanged after use
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/20/05     S.M. Rump  faster check for rounding to nearest
% modified 09/10/07     S.M. Rump  performance, huge arrays
% modified 10/18/08     S.M. Rump  again huge arrays
% modified 07/23/09     S.M. Rump  changed formula: midpoint now in rnd to nearest
%                                    to make sure mid([1-eps,1+2eps])=1 
%                                    (thanks to Gerhard Heindl for pointing to this)
% modified 10/06/09     S.M. Rump  check for rndold
% modified 12/07/13     S.M. Rump  huge sparse input
% modified 05/01/14     S.M. Rump  rounding
% modified 05/15/14     S.M. Rump  code optimization
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  if a.complex                            % complex or thin interval
    c = a.mid;
  else
    rndold = getround;
    setround(1)
    
    % use a.inf + (0.5*a.sup-0.5*a.inf) for correct result in case a.sup-a.inf overflows
    [m,n] = size(a.inf);
    if m*n<2^31                           % input not huge
      c = a.inf + (0.5*a.sup-0.5*a.inf);  % make sure result correct in underflow range
      indexinf = ( a.inf==-inf );
      indexsup = ( a.sup==inf );
      anyindexinf = any(indexinf(:));
      anyindexsup = any(indexsup(:));
      if anyindexinf                      % make sure mid([-inf,x]) is x
        c(indexinf) = a.sup(indexinf);
      end
      if anyindexsup                      % make sure mid([x,inf]) is x
          c(indexsup) = a.inf(indexsup);
      end
      if anyindexinf || anyindexsup       % some components are inf
        c(indexinf & indexsup) = 0;       % make sure mid([-inf,inf]) is 0
      end
    else                                  % take care of huge matrices
      % check some components are inf
      % careful with intervals [0,2] or [-2,0] or [-2,2]
      [Iinf,Jinf,Sinf] = find(a.inf);
      [Isup,Jsup,Ssup] = find(a.sup);
      if ( ~isempty(Iinf) ) || ( ~isempty(Isup) )
        if isequal(Iinf,Isup) && isequal(Jinf,Jsup)  % inf and sup nonzero
          S = Sinf + (0.5*Ssup-0.5*Sinf);   % make sure result correct in underflow range
          indexinf = ( Sinf==-inf );
          if any(indexinf)                  % make sure mid([-inf,x]) is x
            S(indexinf) = Ssup(indexinf);
          end
          indexsup = ( Ssup==inf );
          if any(indexsup)                  % make sure mid([x,inf]) is x
            S(indexsup) = Sinf(indexsup);
          end
          S(indexinf & indexsup) = 0;       % make sure mid([-inf,inf]) is 0
          c = sparse(Iinf,Jinf,S,m,n);
        else
          ainfsup = sparse([Iinf;Isup],[Jinf;Jsup],[complex(Sinf,0);complex(0,Ssup)],m,n);
          [I,J,S] = find(ainfsup);
          Sold = S;
          S = real(S) + (0.5*imag(S)-0.5*real(S));
          indexinf = ( real(Sold)==-inf );
          if any(indexinf(:))               % make sure mid([-inf,x]) is x
            S(indexinf) = imag(Sold(indexinf));
          end
          indexsup = ( imag(Sold)==inf );
          if any(indexsup(:))               % make sure mid([x,inf]) is x
            S(indexsup) = real(Sold(indexsup));
          end
          S(indexinf & indexsup) = 0;       % make sure mid([-inf,inf]) is 0
          c = sparse(I,J,S,m,n);
        end
      else
        c = a.inf;                        % input entirely zero
      end
    end
    setround(rndold)                    % reset rounding
  end
  