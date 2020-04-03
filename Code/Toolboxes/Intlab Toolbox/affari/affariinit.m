function res = affariinit(str,see)
%AFFARIINIT   Initialization of the affari-package (affine arithmetic)
%
%Basic ideas of ideas of affine arithmetic are published in 
%  E.R. Hansen: A generalized interval arithmetic, in "Interval Mathematics", 
%     edited by K. Nickel, Lecture Notes in Computer Science 29, Springer,
%     pages 7-18, 1975.
%Subsequently affine arithmetic was developed by Comba, Stolfi and Andrade to diminish
%overestimation in interval arithmetic. References are
%   L.H. de Figueiredo and J. Stolfi: Self-Validated Numerical Methods and 
%      Applications, Brazilian Mathematics Colloquium monograph, IMPA, 1997
%and
%   M. Kashiwagi: About affine arithmetic, http://verifiedby.me/kv/affine (in japanese)
%
% The INTLAB implementation is based on
%   S.M. Rump, M. Kashiwagi: Implementation and improvements of affine arithmetic,
%     Nonlinear Theory and Its Applications, IEICE,, 2(3):1101–1119, 2015.
%
%Affine arithmetic variables carry (potentially many) error terms. Each initialization
%   x = affari(2)
%of a variable inevitably creates a new error term. Thus it is unavoidable that
%   for i=1:3, x=affari(intval(2)); end, struct(x), x.err
%creates three new error terms. More precisely, after the loop the error
%term of x is a sparse vector with three components when starting afresh.
%
%An m by n affari variable x consists of structure components 
%  x.mid     m x n   midpoint
%  x.err     K x mn  error terms
%  x.rnderr  1 x mn  non-negative, covering rounding errors
%  x.range   m x n   inclusion of the range of x
%Mathematically, the affari structure components represent, up to rounding errors,
%the m by n interval quantity
%   midrad( x.mid , R ) with
%R = reshape( sum(x.err,1) + x.rnderr , size(x.mid) ) .
%
%After some computations the number of error terms may increase rapidly. 
%In that case the call
%   str = affariinit
%resets the number of error terms. If str is specified, then a corresponding
%message is stored in str.
%
%CARE is necessary: After calling "affariinit" only NEWLY defined variables
%can be used safely. Using previously defined affari variables produces 
%erroneous results. 
%
%For nonlinear functions of affine variables, basically the Min-Range and
%the Chebyshev-type approximations are known. The former minimizes the
%range, whereas the latter minimizes the area of an inclusion at the price
%of overestimation for wide intervals. Both have pro and cons, see the
%affari demo.
%
%affariinit('ApproxChebyshev')   Default Chebyshev-type approximation (default)
%affariinit('ApproxMinRange')    Default Min-Range approximation
%affariinit('ApproxMode')        Retrieves the current approximation mode
%affariinit('ApproxMode',0)      Same, but suppresses a corresponding message.
%
%For example, 
%  ApproxMode = affariinit('ApproxMode',0);
%  affariinit('ApproxChebyshev')
%    ... ...
%  affariinit(Approx);
%performs some computations using Chebyshev approximations and restores the
%previous approximation mode. 
%
%There are two ways to handle quadratic and rounding errors: 
%First, to put quadratic and rounding errors each time into a new error term, 
%and second to put it into the .rnderr component.
%Note that in the former mode the number of error terms increases rapidly. 
%Nevertheless, there are advantages and disadvantages, see the affari demo. 
%To switch between the first and second model use
%
%affariinit('RoundingErrorsToErrorTerm')  Rounding errors into new error term (default)
%affariinit('RoundingErrorsToRnderr')     Rounding errors into .rnderr component
%affariinit('RoundingErrors')             Retrieves the current ErrorTerm mode
%affariinit('RoundingErrors',0)           Same, but suppresses a corresponding message.
%
%Putting Rounding errors into new error terms was suggested by M. Kashiwagi 
%from Waseda and proves to be very useful in iterations, see the affari demo.
%
%There are two ways to display affari variables:
%
%affariinit('DisplayIntval')      Default display is as an interval (default)
%affariinit('DisplayErrorterms')  Default display is midpoint and error terms
%affariinit('Display')            Retrieves the current display mode
%affariinit('Display',0)          Same, but suppresses a corresponding message.
%
%A shortcut is  
%  format intval   or   format errorterms
%
%In the first case the intval value of affari variables is displayed.
%Using infsup, midrad or _-representation is controlled by intvalinit.
%In the second case the internal representation is visible.
%

%Affari variables are stored by
%  .mid      the midpoint, at most two dimensions
%  .err      row vector of columns of error terms
%  .rnderr   extra non-negative component covering rounding errors
%  .range    intersection of affari and interval range
%Thus x=affari(midrad(randn(3,2),1e-10)) produces
%  x.mid     the 3x2 matrix of midpoints
%  x.err     the 6x6 matrix such that x(:,i) is the i-th affari variable
%  x.rnderr  a non-negative 1x6 vector carrying absolute value of rounding errors
%  x.range   the interval matrix midrad(randn(3,2),1e-10)
%The structure component  x.range is an inclusion of the range. The affari-part
%is - up to rounding errors - the interval  
%   midrad( x.mid , R ) with
%R = reshape( sum(x.err,1) + x.rnderr , size(x.mid) )
%It is always a superset of x.range.
%
%Strategy for slope computation on X=[x1,x2] s.t. f(x) in <p*x+q,delta>
%I)  Min-Range approximation
%  a) f convex or concave with f'~=0 in X
%       p = f'(x1)  for f convex increasing  or  f concave decreasing, i.e. f'f">=0
%       p = f'(x2)  for f convex decreasing  or  f concave increasing, i.e. f'f"<=0
%       q = ( f(x1)+f(x2) - p*(x1+x2) ) / 2
%       delta = abs( ( f(x2)-f(x1) - p*(x2-x1) ) / 2 )
%  b) f general
%       p = 0
%       q = mid(f(X))
%       delta = rad(f(X))
%II) Chebyshev approximation (default)
%  a) f convex or concave (maybe f'=0)
%       p = ( f(x2)-f(x1) ) / ( x2-x1 )
%       xi s.t. f'(xi) = p
%       delta = ( f(xi) - f(x1) - p*(xi-x1) ) / 2
%       q = f(x1) - p*x1 + delta
%       delta = abs(delta)
%  b) f with at most one zero of f" in X
%       p = ( f(x2)-f(x1) ) / ( x2-x1 )
%       i)  exactly one xi in X with f'(xi) = p: as in IIa)
%           q = ( f(x1)+f(xi) - p*(x1+xi) ) / 2
%           delta = abs( f(xi) - f(x1) - p*(xi-x1) ) / 2
%       ii) xi1, xi2 in X with f'(xi1) = f'(xi2) = p
%           1) f general
%              q = ( f(xi1)+f(xi2) - p*(xi1+xi2) ) / 2
%              delta = abs( f(xi1) - f(xi2) + p*(xi2-xi1) ) / 2
%           2) f(-x) = -f(x)
%              q = 0
%              delta = abs( f(xi1) - p*xi1 )
%  c) f general: representation p*(x-mu)+q instead of p*x+q
%       i)  mu = mid(X)
%           p = f'(mu)
%           E = hull( 0.5*f"(X)*rad(X)^2 , 0 )
%           q = f(mu) + mid(E)
%           delta = rad(E)
%       ii) mu = mid(X)
%           S = f(slopeinit(mu,X))
%           slope = S.s
%           p = mid(slope)
%           q = f(mu)
%           delta = rad(slope)*rad(X)
%       Choose triple (p,q,delta) with minimum delta
%

% written  12/06/13     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 04/25/14     S.M. Rump  comment
%

  global INTLAB_CONST
  
  if ( nargin==0 )          % reset affari package
    if isempty(INTLAB_CONST.AFFARI)             % very first initialization
      INTLAB_CONST.AFFARI_DISPLAY = 1;          % display intervals (default)
      INTLAB_CONST.AFFARI_APPROX = 0;           % Chebyshev approximation (default)
      INTLAB_CONST.AFFARI_ROUNDINGERRORS = 1;   % Rounding errors into new error term (default)      
    end
    INTLAB_CONST.AFFARI = 0;
    res = 'Affari package is initialized to zero error terms';
    
  elseif ischar(str)
    
    if nargin==1
      see = 0;
    end
    
    switch lower(str)
      
      case 'display'
        if INTLAB_CONST.AFFARI_DISPLAY
          res = 'DisplayIntval';
        else
          res = 'DisplayErrorterms';
        end

      case 'displayintval'
        INTLAB_CONST.AFFARI_DISPLAY = 1; 
        if nargout>0
          res = 'DisplayIntval';
        end
        if see
          disp('===> Display affari variables as interval')
        end

      case 'displayerrorterms'
        INTLAB_CONST.AFFARI_DISPLAY = 0; 
        if nargout>0
          res = 'DisplayErrorterms';
        end
        if see
          disp('===> Display internal structure of affari variables')
        end
        
      case 'roundingerrors'
        if INTLAB_CONST.AFFARI_ROUNDINGERRORS
          res = 'RoundingErrorsToErrorTerm';
        else
          res = 'RoundingErrorsToRnderr';
        end                
      
      case 'roundingerrorstoerrorterm'
        INTLAB_CONST.AFFARI_ROUNDINGERRORS = 1;
        if nargout>0
          res = 'RoundingErrorsToErrorTerm';
        end
        if see
          disp('===> Affari rounding errors into .rnderr component')
        end

      case 'roundingerrorstornderr'
        INTLAB_CONST.AFFARI_ROUNDINGERRORS = 0;
        if nargout>0
          res = 'RoundingErrorsToRnderr';
        end
        if see
          disp('===> Affari rounding errors into new error term')
        end

      case 'approxmode'
        if INTLAB_CONST.AFFARI_APPROX
          res = 'ApproxMinRange';
        else
          res = 'ApproxChebyshev';
        end                
      
      case 'approxminrange'
        INTLAB_CONST.AFFARI_APPROX = 1;
        if nargout>0
          res = 'ApproxMinRange';
        end
        if see
          disp('===> Affari default Min-Range approximation')
        end

      case 'approxchebyshev'
        INTLAB_CONST.AFFARI_APPROX = 0;
        if nargout>0
          res = 'ApproxChebyshev';
        end
        if see
          disp('===> Affari default Min-Range approximation')
        end

      case 'setaffarivars'  % internal option: sets number of error terms
        INTLAB_CONST.AFFARI = see;

      otherwise
        error('invalid call of affariinit')

    end

  else
    error('invalid call of affariinit')
  end

