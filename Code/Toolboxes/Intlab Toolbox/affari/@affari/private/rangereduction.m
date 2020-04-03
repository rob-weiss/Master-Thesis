function [a,indexnan,Sinf,Ssup] = rangereduction(a,mode)
%RANGEREDUCTION  Range reduction 
%
%  mode  1  a.mid-k*pi into [-pi/2,pi/2]     for tangent
%        2  a.mid-k*pi into [0,pi]           for cotangent
%        3  a.mid-k*pi into [-0.5*pi,2.5*pi] for sine
%        4  a.mid-k*pi into [-0.5*pi,2.5*pi] for sine
%

%Ignores that input may be point intval (then better range reduction)
%Rounding downwards after execution
%

% written  04/04/14     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  transformed midpoint
%

  global INTLAB_CONST

  % Pi inclusion of pi
  % PI.PI2INF <= pi/2 <= PI.PI2SUP 
  Pi = intval('pi');
  TwoPi = 2*Pi;
  PI = INTLAB_CONST.STDFCTS_PI;      

  switch mode
    case 1      % a.mid-k*pi into [-pi/2,pi/2]  for tangent
      % transform x.inf and x.sup mod pi/2
      [ xinfinf , xinfsup , Sinf ] = modpi2(a.range.inf);
      [ xsupinf , xsupsup , Ssup ] = modpi2(a.range.sup);      
      
      % indices with result NaN
      setround(1)
      delta = a.range.sup - a.range.inf;
      indexnan = ( delta >= PI.PISUP ) | ...
        ( floor(Sinf/4) ~= floor(Ssup/4) );
      
      % transform input
      Sinf(Sinf>3) = Sinf(Sinf>3) - 4;
      Ssup(Ssup>3) = Ssup(Ssup>3) - 4;
      
      % treat supremum, rounding upwards
      arangesup = xsupsup;      % corresponds to Ssup=2
      index = ( Ssup==0 );
      if any(index(:))
        arangesup(index) = xsupsup(index) - PI.PI2INF;
      end
      index = ( Ssup==1 );
      if any(index(:))
        arangesup(index) = - xsupinf(index);
      end
      index = ( Ssup==3 );
      if any(index(:))
        arangesup(index) = ( -xsupinf(index) ) + PI.PI2SUP;
      end
      
      % treat infimum, rounding downwards
      setround(-1)
      arangeinf = xinfinf;
      index = ( Sinf==0 );
      if any(index(:))
        arangeinf(index) = xinfinf(index) - PI.PI2SUP;
      end
      index = ( Sinf==1 );
      if any(index(:))
        arangeinf(index) = - xinfsup(index);
      end
      index = ( Sinf==3 );
      if any(index(:))
        arangeinf(index) = ( -xinfsup(index) ) + PI.PI2INF;
      end
     
      % restrict range and tread NaN
      a.range = intersect( intval(arangeinf,arangesup,'infsup') , midrad(0,PI.PI2SUP) );
      a.mid = a.range.mid;
      a.mid(indexnan) = NaN;
      a.range(indexnan) = NaN;

    case 2      % a.mid-k*pi into [0,pi]  for cotangent
      % transform x.inf and x.sup mod pi/2
      [ xinfinf , xinfsup , Sinf ] = modpi2(a.range.inf);
      [ xsupinf , xsupsup , Ssup ] = modpi2(a.range.sup);      
      
      % indices with result NaN
      setround(1)
      delta = a.range.sup - a.range.inf;
      % transform range 1..2 to 8..9
      Sinf(Sinf<2) = Sinf(Sinf<2) + 8;
      Ssup(Ssup<2) = Ssup(Ssup<2) + 8;
      indexnan = ( delta >= PI.PIINF ) | ...
        ( floor((Sinf-2)/4) ~= floor((Ssup-2)/4) );
      % transform input to range 2..5
      Sinf(Sinf>5) = Sinf(Sinf>5) - 4;
      Ssup(Ssup>5) = Ssup(Ssup>5) - 4;
      
      % treat supremum, rounding upwards
      arangesup = xsupsup;      % corresponds to Ssup=2
      index = ( Ssup==3 );
      if any(index(:))
        arangesup(index) =  ( -xsupinf(index) ) + PI.PI2SUP;
      end
      index = ( Ssup==4 );
      if any(index(:))
        arangesup(index) = xsupsup(index) + PI.PI2SUP;
      end
      index = ( Ssup==5 );
      if any(index(:))
        arangesup(index) = ( -xsupinf(index) ) + PI.PISUP;
      end
      
      % treat infimum, rounding downwards
      setround(-1)
      arangeinf = xinfinf;
      index = ( Sinf==3 );
      if any(index(:))
        arangeinf(index) = ( -xinfsup(index) ) + PI.PI2INF;
      end
      index = ( Sinf==4 );
      if any(index(:))
        arangeinf(index) = xinfinf(index) + PI.PI2INF;
      end
      index = ( Sinf==5 );
      if any(index(:))
        arangeinf(index) = ( -xinfsup(index) ) + PI.PIINF;
      end
     
      % restrict range and tread NaN
      a.range = intersect( intval(arangeinf,arangesup,'infsup') , infsup(0,PI.PISUP) );
      a.mid = a.range.mid;
      a.mid(indexnan) = NaN;
      a.range(indexnan) = NaN;

    case {3,4}  % a.mid-k*pi into [-pi/2,5/2*pi]  for sine, cosine
      [ xinfinf , xinfsup , Sinf ] = modpi2(a.range.inf(:));
      [ xsupinf , xsupsup , Ssup ] = modpi2(a.range.sup(:));
      % octils 0 <= Sinf, Ssup <= 7
      xinf = intval(xinfinf,xinfsup,'infsup');  % all column vectors
      xsup = intval(xsupinf,xsupsup,'infsup');
      Pi2 = 0.5*Pi;
      
      % prepare potential infima
      index = odd(Sinf);                    % odd index
      if any(index)
        xinf(index) = ( -xinf(index) ) + ((Sinf(index)-1)/2)*Pi2;
      end
      index = ~index;                       % even index
      if any(index)
        xinf(index) = xinf(index) + (Sinf(index)/2-1)*Pi2;
      end

      % prepare potential suprema
      index = odd(Ssup);                    % odd index
      if any(index)
        xsup(index) = ( -xsup(index) ) + ((Ssup(index)-1)/2)*Pi2;
      end
      index = ~index;                       % even index
      if any(index)
        xsup(index) = xsup(index) + (Ssup(index)/2-1)*Pi2;
      end
      
      % redefine octil from 0..7 into quartil 0..3
      Sinf = floor(Sinf/2);
      Ssup = floor(Ssup/2);
 
      % identify intervals to extend
      reverse = ( Sinf>Ssup );
      if any(reverse)
        xsup(reverse) = xsup(reverse) + TwoPi;
        Ssup(reverse) = Ssup(reverse) + 4;
      end
      
      % identify huge intervals (stored in indexnan)
      if mode==3            % sine
        indexnan = ( diam(a.range(:))>=TwoPi.inf ) | ...
          ( ( Sinf==Ssup ) & ( xinf>xsup ) ) | ...
          ( reverse & ( ((Sinf==1) & (Ssup==4)) | (Ssup==6) ) );
      else                  % cosine
        indexnan = ( diam(a.range(:))>=TwoPi.inf ) | ...
          ( ( Sinf==Ssup ) & ( xinf>xsup ) ) | ...
          ( reverse & ( ((Sinf==2) & (Ssup==5)) ) );
      end
      nothuge = ~indexnan;
            
      % resize range
      if any(nothuge)
        if all(nothuge)
          a.range = reshape( hull(xinf,xsup), size(a.mid) );
        else
          a.range(nothuge) = hull(xinf(nothuge),xsup(nothuge));
          a.range = reshape( a.range, size(a.mid) );
        end        
      end
      a.mid = a.range.mid;

  end
  
  % take care of possibly transformed midpoint (maximum error by modpi2)
  setround(1)
  a.rnderr = a.rnderr + eps;
  
end  % rangereduction
