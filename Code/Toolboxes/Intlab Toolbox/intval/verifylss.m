function [X,Xinf,Xsup] = verifylss(A,b,param)
%VERIFYLSS    Verified solution of linear system
%
%    X = verifylss(A,b)
%
%Dense linear system solver based on
%  S.M. Rump. Accurate solution of dense linear systems, Part II: 
%    Algorithms using directed rounding. Journal of Computational 
%    and Applied Mathematics (JCAM), 242:185-212, 2013. 
%
%This covers also extremely ill-conditioned systems (for point data) by
%
%    x = verifylss(A,b,'illco')
%
%as analyzed in
%  S.M. Rump: Inversion of extremely ill-conditioned matrices in
%  floating-point. Japan J. Indust. Appl. Math. (JJIAM), 26:249-277, 2009
%
%and covers a new way to compute inner inclusions by
%
%    [x,yinf,ysup] = verifylss(A,b)
%
%In this case for each index i there exists A1,A2 in A and b1,b2 in b with
%A1*x1=b1 and A2*x2=b2 in b such that
%
%    x1_i <= yinf_i   and ysup_i <= x2_i .
%
%This new method as described in the first mentioned paper may work even if
%only one entry in A and/or b is thick. Note that yinf and ysup are point
%vectors, thus displaying them is by the Matlab standard round to nearest.
%To display valid inner bounds use
%
%    displayinner(yinf,ysup)
%
%For sparse linear systems matrix is assumed to be s.p.d., otherwise normal
%equations are used. For symmetric matrix they can be forced to use by
%
%   x = verifylss(A,b,'normal');
%
%Note that this squares the condition number.
%
%Sparse system solver based on
%  S.M. Rump: Validated Solution of Large Linear Systems, Computing
%    Supplementum 9, 191-212, 1993
%and
%  S.M. Rump: Verification of Positive Definiteness. BIT Numerical 
%    Mathematics, 46:433-452, 2006.
%
%Improved residual improvement for point matrix is possible by
%  intvalinit('ImprovedResidual')
%For quadruple precision improvement of residual (for maximum accurate results) use
%  intvalinit('QuadrupleResidual')
%Because of interpretation overhead this is only for point dense matrix and for vector right
%  hand side. Extra computational costs and gain in accuracy is as follows (timing in 
%  seconds on an 2.8 GHz Laptop, point matrix and point right hand side, relative error
%  means maximum relative error of inclusion over all components and all test cases):
%
%  time[sec]      t1 = doubleresidual,  t2 = improvedresidual,  t3 = quadrupleresidual
%  max.rel.error  r1 = doubleresidual,  r2 = improvedresidual,  r3 = quadrupleresidual
%
%condition number of matrix 1e8:
%
%     n     t1     t2     t3     t2/t1     t3/t1      r1         r2         r3
%--------------------------------------------------------------------------------
%   500    0.087  0.114  0.17     1.3       1.9     3.9e-07    7.6e-11    1.6e-16
%  2000    2.5    2.9    3.9      1.17      1.6     8.1e-07    5.1e-10    1.6e-16
%  5000   32     34     40        1.08      1.3     1.1e-06    1.3e-09    1.6e-16
%
%condition number of matrix 1e14:
%
%     n     t1     t2     t3     t2/t1     t3/t1      r1         r2         r3
%--------------------------------------------------------------------------------
%   500    0.113  0.14   0.34     1.3       3.0     2.8e-01    5.1e-05    3.6e-16
%  2000    3.4    3.8    8.3      1.12      2.5     4.8e-01    3.6e-04    8.8e-16
%  5000   45     48     75        1.07      1.7     6.6e-01    8.1e-04    1.3e-15
%
%
%
%The minimum norm solution of an overdetermined linear system and the least squares
%solution of an underdetermined linear system for real point data is included by
%
%    X = verifylss(A,b)
%
%A new method is used based on
%  S.M. Rump: Verified Bounds for Least Squares Problems and Underdetermined 
%    Linear Systems. SIAM J. Matrix Anal. Appl. (SIMAX), 33(1):130-148, 2012.
%
%This is now also working for sparse input data. It uses, however, an 
%extra-precise residual iteration, which may be slow due to interpretation
%overhead. An alternative is to use a sort of normal equations by
%
%    X = verifylss(A,b,'normal')
%
%based on
%  S.M. Rump: Solving Algebraic Systems with High Accuracy, in "A New
%    Approach to Scientific Computation", eds. U. Kulisch and W. Miranker,
%    Academic Press, 51-120, 1983.
%

% written  10/16/98     S.M. Rump
% modified 11/06/98     second stage for dense systems and improvements for
%                         sparse systems, A. Neumaier, S.M. Rump
% modified 10/12/99     S.M. Rump  interval iteration stops if NaN occurred
% modified 09/02/00     S.M. Rump  rounding unchanged after use
% modified 04/02/02     S.M. Rump  improved residual added
% modified 06/26/02     S.M. Rump  output always of type intval, also for NaN
% modified 12/25/02     S.M. Rump  second stage offset corrected
% modified 11/29/03     S.M. Rump  second stage only, quadruple precision residual
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/20/05     S.M. Rump  faster check for rounding to nearest
% modified 02/09/06     S.M. Rump  error message prevented (thanks to Jiri Rohn)
% modified 09/20/07     S.M. Rump  intval answer if nan input (thanks to Jiri Rohn)
% modified 10/03/08     S.M. Rump  check for inf and NaN
% modified 02/18/09     S.M. Rump  change isempty to any
% modified 12/06/09     S.M. Rump  normal equations with paramater normal
% modified 02/16/10     S.M. Rump  minsvd initial approximation
% modified 03/01/10     S.M. Rump  isspd
% modified 03/16/10     S.M. Rump  symmetry/Hermitian ensured
% modified 08/07/10     S.M. Rump  upper case Dot_
% modified 08/26/12     S.M. Rump  global variables removed, rounding
% modified 08/28/12     S.M. Rump  Complete redesign of the entire routine:
%     complete redesign of dense linear systems,
%     extremely ill-conditioned linear systems added,
%     new method for underdetermined systems and least squares problems,
%         also for sparse input data
%     SECOND_STAGE superfluous,
%     parameter 'normal' for sparse as string
% modified 10/07/12     S.M. Rump  Componentwise estimates for rectangular
%                                    systems (inspired by S. Miyajima)
% modified 10/07/12     S.M. Rump  approximate smallest singular value
% modified 10/07/12     S.M. Rump  improved condition number of augmented
%                                    system for rectangular systems
% modified 10/16/12     S.M. Rump  comment
% modified 03/20/13     S.M. Rump  change gamma_n into n*eps
% modified 07/14/13     S.M. Rump  point matrix and rhs
% modified 02/28/14     S.M. Rump  rounding mode
% modified 03/03/14     S.M. Rump  Minamihata's improvement
% modified 03/18/14     S.M. Rump  avoid bad scaled solution
% modified 04/02/14     S.M. Rump  Minamihata's second improvement
% modified 04/04/14     S.M. Rump  end function
% modified 04/17/14     S.M. Rump  repmat(nan,...
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/01/14     S.M. Rump  scaling
% modified 05/15/14     S.M. Rump  code optimization
% modified 10/04/15     S.M. Rump  singmin
% modified 01/15/16     S.M. Rump  improvement of Minamihata's third ansatz
%                                    and new iteration
% modified 01/29/16     S.M. Rump  accY (thanks to Florian Bünger)
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
% modified 07/31/16     S.M. Rump  singular inv(A)
% modified 09/22/16     S.M. Rump  minor improvements
% modified 02/22/17     S.M. Rump  normal equations improved (thanks to
%                                    Marko Lange for pointing to that)
%

% table produced by testverifylss
%

  [m,k] = size(A);
  [m1,n] = size(b);
  Aflag = any(isnan(A) | isinf(A));
  bflag = any(isnan(b) | isinf(b));
  if any(Aflag(:)) || any(bflag(:))
    X = intval(NaN(m1,n));
    return
  end
  if m~=m1
    error('linear system solver: inner matrix dimensions must agree')
  end
  
  % Scale columns to avoid badly scaled solution
  [dummy,M] = log2(abs(mid(nonzeros(mag(A)))));
  M = max(M);       % column maximum
  if max(M)-min(M)>60
    scale = 1;
    Dscale = diag(2.^(-M));
    A = A*Dscale;
  else
    scale = 0;
  end
  
  rndold = getround;
  if rndold
    setround(0)
  end
  
  if nargin==2
    param = 0;
  else
    param = lower(param);
    if ~ismember(param,{'normal','illco'})
      error('verifylss called with invalid parameter')
    end
  end

  if ( m==k ) && issparse(A)       % A supposed to s.p.d. and square
    if ~isequal(A,A') || isequal(param,'normal')
%       error('sparse linear systems for non-s.p.d. matrices not yet implemented; use parameter ''normal''.')
      if isintval(A)
        mA = mid(A);
        rA = rad(A);
      else
        mA = A;
        rA = 0;
      end
      if all(rA(:)==0)
        rA = 0;
      end
      setround(-1)
      P1 = mA'*mA;
      setround(1)
      P2 = mA'*mA;
      mAtA = 0.5*(P1+P2);
      NrrA = TwoNormRadius(abs(mAtA-P1),1);
      X = sparselss(mAtA,A'*intval(b),rA,NrrA,A,b);
    else
      X = sparselss(A,b);
    end
  else
    wng = warning;                 % get current warning mode
    warning off
    if m==k                        % non-sparse input
      if nargout==3
        [X,Xinf,Xsup] = LssErrBnd(A,b,param);
      else
        X = LssErrBnd(A,b,param);
      end
    else
      if issparse(A) && isequal(param,'normal')
        error('sparse non-square systems by ''normal'' approach not implemented; avoid parameter ''normal''.')
      end
      % Use augmented system if A or b is complex or thick
      if ( ~isequal(param,'normal') )
        if ( ~isreal(A) ) || ( ~isreal(b) )
          param = 'normal';
        else
          if isa(A,'intval')
            if isequal(A.inf,A.sup)
              A = A.inf;
            else
              param = 'normal';
            end
          end
          if isa(b,'intval')
            if isequal(b.inf,b.sup)
              b = b.inf;
            else
              param = 'normal';
            end
          end
        end
      end
          
      % use heuristic factor to improve condition number of augmented matrix
      if m>k      % least squares problem
        if isequal(param,'normal')
          phi = 0.0001*sqrt(norm(mid(A),inf)*norm(mid(A),1));
          Y = LssErrBnd( [ A -phi*eye(m) ; zeros(k) A' ] , [ b ; zeros(k,n) ] );
          if ~isnan(Y)
            X = Y(1:k,:);
          else
            X = intval(NaN(k,n));
          end
        else
          X = verifylssr(A,b,2);
        end
      else        % minimal norm solution
        if isequal(param,'normal')
          phi = 0.0001*sqrt(norm(mid(A),inf)*norm(mid(A),1));
          Y = LssErrBnd( [ A' -phi*eye(k) ; zeros(m) A ] , [ zeros(k,n) ; b ] );
          if ~isnan(Y)
            X = Y(m+1:m+k,:);
          else
            X = intval(NaN(k,n));
          end
        else
          X = verifylssr(A,b,2);
        end
      end
    end
    warning(wng)                         % reset old rounding mode
  end
 
  if scale
    X = Dscale*X;
  end
      
  setround(rndold)

end  % function verifylss


function X = sparselss(A,b,Arad,NrrA,origA,origb)
% linear system solver for sparse matrices
% normal: coming from normal equations, N upper bound for norm(AtA)
  global INTLAB_CONST
  spparms('autommd',0);             % no additional minimum degree ordering
  setround(0)                       % rounding to nearest
  n = dim(A);
  normal = ( nargin>2 );            % the usual case
  if normal
    Aisintval = 0;
  else
    if isa(A,'intval')
      Aisintval = 1;
      Arad = rad(A);
    else
      Aisintval = 0;
    end
    A = mid(A);                     % save memory
  end
   
  d = diag(A);                      % check diagonal positive
  m = min(d);
  if m<=0
    X = intval(NaN(size(b)));
    return
  end
  
  % Minimum degree reordering
  if exist('symamd','file')
    perm = symamd(A);
  else
    if n<2000                       % symmmd can be very slow
      perm = symmmd(A);
    end
  end
  if exist('perm','var')
    A = A(perm,perm);
    if ( Aisintval || normal ) && ( ~isequal(Arad,0) )
      Arad = Arad(perm,perm);
    end
    b = b(perm,:);
    d = d(perm);
    if normal
      origA = origA(perm,perm);
      origb = origb(perm,:);
    end
  end
  
  if max(d)/m > n                   % apply van der Sluis scaling
    D = spdiags( 2.^(-round(0.5*log2(d))) ,0,n,n );
    A = D*A*D;                      % exact since D_ii are powers of 2
    if Aisintval                    % constants below take care of underflow
      Arad = D*Arad*D;
    end
    b = D*b;
    vdSscale = 1;
  else
    vdSscale = 0;
  end
  
  [s,xs] = singmin(A,mid(b));
% condA = cond(A)
% minAii=min(diag(A)), maxAii=max(diag(A))
  if s>0        % approximation for smallest singular value positive
    s = .8*s;
    if Aisintval      
      residual = mag(b-A*intval(xs));
      setround(1)
      residual = residual + Arad*abs(xs);
      residual = sqrt(sum(residual.^2));
      if size(b,2)~=1                       % matrix right hand side
        residual = repmat(residual,n,1);
      end
      N = TwoNormRadius(Arad,1);
      if s<=N
        X = intval(NaN(size(b)));
        setround(0)
        return
      end
    else
      N = 0;
      INTLAB_INTVAL_RESIDUAL = INTLAB_CONST.INTVAL_RESIDUAL;
      if normal
        if vdSscale
          Dxs = D*xs;
        else
          Dxs = xs;
        end
        if INTLAB_INTVAL_RESIDUAL==1      % improved residual calculation
          residual = mag(lssresidual(origA,Dxs,intval(origb)));
        else                              % quadruple residual calculation not for sparse matrices
          residual = mag(origb-origA*intval(Dxs));
        end
      else
        if INTLAB_INTVAL_RESIDUAL==1      % improved residual calculation
          residual = mag(lssresidual(A,xs,intval(b)));
        else                              % quadruple residual calculation not for sparse matrices
          residual = mag(b-A*intval(xs));
        end
      end
      setround(1)
      residual = sqrt(sum(residual.^2,1));
      if size(b,2)~=1                       % matrix right hand side
        residual = repmat(residual,n,1);
      end
    end
    setround(-1)
    A = A - s*speye(n);
    setround(0)
    failed = 0;
    if isspd(A,0,0)                     % fast test
      minsvd = s;
    else                                % fast test failed, try sharper test
      [C,p] = chol(A);
      if p==0           % Cholesky decomposition of shifted matrix succeeded
        setround(-1)
        p1 = C'*C - A;
        setround(1)
        r = norm(p1,1);
        r = max( norm(C'*C - A,1) , r );
        minsvd = - (r - s);
      else              % Cholesky decomposition of shifted matrix failed
        failed = 1;
      end
    end
  else          % approximation for smallest singular value failed
    failed = 1;
  end
  if normal & ( ~failed )
    minsvd = minsvd - NrrA;             % rounding is downwards
    if minsvd<=0
      failed = true;
    else
      minsvd = sqrt(minsvd);
      if ~isequal(Arad,0)
        Nrad = TwoNormRadius(Arad,0);   % non-symmetric case
        minsvd = sqrt(minsvd) - Nrad;
      end
    end
  end
  if failed || ( minsvd<=0 )
    X = intval(NaN(size(b)));
  else
    if ~Aisintval                       % point matrix
      setround(1)
      if issparse(xs)
        residual = sparse(residual);
      end
      X = midrad( xs , residual/minsvd );
    else                                % interval matrix
      if minsvd > N
        setround(1)
        denom = -(N-minsvd);
        X = midrad( xs , residual/denom );    % A interval, lssresidual not used
      else
        X = intval(NaN(size(b)));
      end
    end
  end
  if vdSscale
    X = D*X;
  end
  if exist('perm','var')
    [dummy,perm] = sort(perm);
    X = X(perm,:);
  end
  setround(0)
  
end  % function sparselss

function N = TwoNormRadius(A,sym)
% upper bound N on the 2-norm of non-negative A
% sym=1  A symmetric, thus norm(A,2)=rho(A)
% rounding mode may be changed
  setround(0)           % set rounding to nearest
  % approximation of norm(rad(A)) = rho(rad(A))
  x = ones(size(A,1),1);
  m = 1;
  M = 2;
  iter = 0;
  if sym                % input matrix symmetric
    while ( abs((M-m)/(m+M))>.1 ) && ( iter<10 )
      iter = iter+1;
      y = A*x;
      x = y./x;
      M = max(x);
      m = min(x);
      scale = max(y);
      x = max( y/scale , 1e-12 );
    end
    % upper bound N of norm(rad(A)) = rho(rad(A))
    setround(1)
    y = A*x;
    N = max(y./x);
  else
    At = A';
    while ( abs((M-m)/(m+M))>.1 ) && ( iter<10 )
      iter = iter+1;
      y = At*(A*x);
      x = y./x;
      M = max(x);
      m = min(x);
      scale = max(y);
      x = max( y/scale , 1e-12 );
    end
    % upper bound N of norm(rad(A)) = rho(rad(A))
    setround(1)
    y = At*(A*x);
    N = sqrt(max(y./x));
  end
end  % function TwoNormRadius

  
function [s,xs] = singmin(A,b)     
  % approximation of smallest singular value and approximate solution 
  % for positive definite A
  global INTLAB_CONST
  n = dim(A);
  [C,p] = chol(A);
  if p==0                       % Cholesky decomposition succeeded
    Cp = C';
    % approximation s of smallest eigenvalue
    y = C\(Cp\sign(randn(n,2)));    % initial vectors for inverse power iteration
    s = real(n./diag(y'*y));
    k = 0; 
    notready = 1;
    while notready || ( k<3 )
      k = k+1;
      sold = s;
      z = ( Cp\y )*diag(s);
      y = C\z;
      s = real(diag(z'*z)./diag(y'*y));
      notready = any(abs(s-sold)>.0001*abs(s+sold));
    end
    s = mean(s);                % approximation of smallest singular value
    % approximate solution of linear system
    xs = C\(Cp\b);
    % At least one residual iteration for backward stability (Skeel)
    INTLAB_INTVAL_RESIDUAL = INTLAB_CONST.INTVAL_RESIDUAL;
    if INTLAB_INTVAL_RESIDUAL==1      % more accurate residual calculation
      resnorm = inf;  
      while 1
        resnormold = resnorm;
        res = C\(Cp\lssresidual(A,xs,b));
        resnorm = norm(res,1);
        if resnorm<resnormold
          xs = xs + res;
        end
        if resnorm >= 1e-2*resnormold, break, end   % beware of zero residual 
      end
    else                              % quadruple precision only for dense matrices
      xs = xs + C\(Cp\(b-A*xs));
    end
  else                                % Cholesky decomposition failed
    s = 0;
    xs = 0;
  end
  
end  % function singmin

  
function [x,yinf,ysup] = LssErrBnd(A,b,param)
% Inclusion x for the solution of the linear system Ax=b; 
% computation uses interval arithmetic.
  global INTLAB_CONST

  setround(0)                               % rounding to nearest
  if nargin==2
    Illco = 0;
  else
    Illco = isequal(param,'illco');
  end
  
  % initialize results
  if nargout==3
    yinf = NaN(size(b)); 
    ysup = yinf; 
    x = intval(yinf); 
  else
    x = intval(NaN(size(b))); 
  end
  
  % initialize constants
  n = size(A,2);
  tolA = any(any(rad(A)>0)); tolb = any(any(rad(b)>0)); 
  tol = tolA || tolb;
  midA = mid(A);
  midb = mid(b);
  nrhs = size(b,2);

  % preconditioner: approximate inverse
  for i=1:3
    if i==1
      R = inv( midA ) ;
    end
    if any(isinf(R(:))) || any(isnan(R(:)))
      if i==3
        return
      end
      R = inv(midA.*(1+10^(-16+i)*randn(size(A))));
    else
      break
    end
  end

  % acc=0: try to compute only lower bound of R*A, E only by E <= Cinfd + n(u|R||A|+eta)
  % acc=1: full accuracy by computing interval bounds for R*A, E explicitly given
  acc = tol || ( ~isreal(A) ) || ( nargout>1 ) || ( n<=100 );
  if acc
    C = R*intval(A);
    d = mig(diag(C));
  else
    setround(-1);                           % rounding to downwards
    Cinf = R*midA;                          % lower bound Cinf <= RA
    d = diag(Cinf);                         % lower bound of diag(RA)
    Cinfd = abs(Cinf);
    Cinfd(1:n+1:n^2) = 0;                   % Cinfd ~ E for <RA>=D-E
    absA = sup(abs(A));                     % E <= Cinfd + n(u|R||A|+eta)
    absR = abs(R);
    setround(0);                            % rounding to nearest
  end
  if any(d<=0) && ( Illco==0 )              % C is not H-matrix
    return
  end
  
  % approximate solution with at least one iteration to ensure backward stability (Skeel)
  xs = R * midb ;
  INTLAB_INTVAL_RESIDUAL = INTLAB_CONST.INTVAL_RESIDUAL;
  improvedresidual = ( INTLAB_INTVAL_RESIDUAL==1 ) | ...
    ( ( INTLAB_INTVAL_RESIDUAL==2 ) & ( size(b,2)>1 ) );
  if improvedresidual    % improved residual calculation
    resnorm = inf;
    i = 0;
    while i<15
      i = i+1;
      resnormold = resnorm;
      res = R*lssresidual(midA,xs,midb);
      resnorm = norm(res,1);
      if resnorm<resnormold
        xs = xs + res;
      end
      if resnorm >= 1e-1*resnormold, break, end   % beware of zero residual
    end
  elseif INTLAB_INTVAL_RESIDUAL==2          % quadruple precision residual calculation
    normxs = norm(xs,inf); N = inf;         % initialization of constants
    for iter=1:10                           % at most 10 residual iterations
      Nold = N;                             % update constants
      delta = R*Dot_(-1,midb,midA,xs);      % correction for xs
      N = norm(delta,inf);                  % norm of correction
      if N<Nold, xs = xs-delta; end         % correction acceptable
      if ( ( iter==1 ) && ( N<1e-9*normxs ) ) || ( N<eps*normxs ) || ( N>=0.3*Nold )
        break                               % stop iteration if well-conditioned
      end                                   %    or no improvement
    end
  else
    xs = xs + R*(midb - midA*xs);
  end

  % compute c s.t. |R(A*xs-b)|<=c
  if isa(A,'intval')
    if tolA                               % matrix A with tolerances
      c = mag(R*(A*xs-b));                % upper bound of |R(A*xs-b)|
    else                                  % only tolerances in r.h.s.
      if tolb
        c = mag(R*lssresidual(midA,xs,b));  % b thick, quadruple residual does not make sense
      else
        if improvedresidual
          c = mag(R*lssresidual(midA,xs,intval(b)));
        elseif INTLAB_INTVAL_RESIDUAL==2
          c = mag(R*Dot_(1,midb,midA,-xs,-2));
        else
          c = mag(R*(b - midA*intval(xs)));
        end
      end
    end
  else                                % A thin, possibly improved residual calculation
    if improvedresidual
      c = mag(R*lssresidual(A,xs,intval(b)));
    elseif INTLAB_INTVAL_RESIDUAL==2
      if tolb
        c = mag(R*lssresidual(A,xs,b)); % b thick, quadruple residual does not make sense
      else
        c = mag(R*Dot_(1,midb,A,-xs,-2));
      end
    else
      c = mag(R*(b - A*intval(xs)));
    end
  end

  if acc
    E = mag(C); E(1:n+1:n^2) = 0;
    [u,v] = MVectorNew(E,d);
  else
    % E <= Cinfd + n(u|R||A|+eta); use eps=2^(-52) because of rounding upwards
    [u,v] = MVectorNew(Cinfd,d);
    u = u - n*(eps*(absR*(absA*v))+subrealmin);    % now u <= M*v
    if any(u<=0) || any(v<=0)             % iteration as for acc=0
      acc = 1;                            
      setround(1);                        % round to upwards
      Csup = R*midA;                      % upper bound ra<= Csup
      E = max(abs(Cinf),abs(Csup)); E(1:n+1:n^2) = 0;
      [u,v] = MVectorNew(E,d);            % u <= M*v
    end
  end
  
  if all(u>0) && all(v>0)                 % C proved to be H-matrix
    setround(1)                           % rounding to upwards
    dinv = 1./d;                          % upper bound of diag(D^-1)
    beta = c;
    y = c;
    if nrhs==1
      err0 = max(c./u)*v;
      for iter=1:10
        if acc
          y = E*(dinv.*y);
        else
          dinv_y = dinv.*y;
          y = Cinfd*dinv_y + n*(eps*(absR*(absA*dinv_y))+subrealmin);
        end
        err = min( err0 , dinv.*beta + max(y./u)*v );
        if all(err>=0.9999*err0)
          break
        else
          err0 = err;
        end
        beta = beta + y;
      end
    else
      err0 = bsxfun(@times,max(bsxfun(@ldivide,u,c)),v);
      for iter=1:10
        dinv_y = bsxfun(@times,dinv,y);
        if acc
          y = E*dinv_y;
        else
          y = Cinfd*dinv_y + n*(eps*(absR*(absA*dinv_y))+subrealmin);
        end
        err = min( err0 , bsxfun(@times,dinv,beta) + bsxfun(@times,max(bsxfun(@ldivide,u,y)),v) );
        if all(all(err>=0.9999*err0))
          break
        else
          err0 = err;
        end
        beta = beta + y;
      end
    end
    
    x = xs + midrad(0,err);               % final inclusion
    
    if ( nargout>1 ) && ( tolA || tolb ) && ( ~Illco )  && ...
         isreal(A) && isreal(b)           % inner inclusion
      mA = -(-inf_(A)-sup(A))/2; rA = -(inf_(A)-mA); % inner inclusion of A
      resinf = inf_(b) + mA*(-xs) + rA*(-abs(xs)); % lower inner bound
      setround(-1)                        % rounding downwards
      ressup = sup(b) + mA*(-xs) + rA*abs(xs);     % upper inner bound
      mu = resinf + 0.5*(ressup-resinf);  % inner midpoint
      rho = mu - resinf;                  % inner radius, maybe negative
      csup = R*mu + abs(R)*rho;           % upper inner bound correction
      setround(1)                         % rounding upwards
      cinf = R*mu + abs(R)*(-rho);        % lower inner bound correction
      e = mag(speye(n)-C)*err;            % inner correction
      yinf = xs + cinf + e;               % inner lower bound
      ysup = -(e - csup - xs);            % inner upper bound
    end
    
  end

  % treating extremely ill-conditioned matrices
  if Illco && ( ~tolA ) && ( ~tolb )      % solution by phase II
    if nrhs==1
      x = LssErrBnd(AccDot(R,A,[]),Dot_(R,midb,-2),0);
    else
      x = LssErrBnd(AccDot(R,A,[]),AccDot(R,b,[]),0);
    end
  end
  
end  % function LssErrBnd

  
function [u,v] = MVectorNew(E,d)
% Vector iteration on M=D-E, D,E>=0, to verify M-property, start vector v=1./d.
% Rounding to downwards after execution.
  setround(-1)                              % rounding to downwards
  vnew = 1./d;                              % first guess
  minu = -inf;                              % initialization
  for iter=1:15                             % at most 15 iterations
    v = vnew;                               % update
    w = E*(-v);
    minuold = minu;
    % vector iteration, u <= M*v. Not yet true if acc, i.e. E is replaced by Cinfd
    u = d.*v + w;
    minu = min(u);
    vnew = -w./d + eps;                     % update of guess of H-vector
    r = vnew./v;                            % ratio new and old Perron vector
    if ( max(r)<1.001*min(r) ) && ( ( minu>0 ) || ( minu<minuold ) )
      return                                % sufficiently accurate
    end
  end
  
end  % function MVectorNew
    
  
function x = verifylssr(A,b,acc)
%minimum norm solution A^+b for underdetermined linear systems
%and least squares problems.
%        x = verifylssr(A,b,acc)
%with
%  acc  0   avoiding explicit computation of X (for very large sparse systems)
%       1   new method w/o extra-precise residual iteration
%       2   new method with extra-precise residual iteration
%
%For acc=1 the accuracy of the results decreases with increasing condition
%number, for acc=2 more, more computing time is needed to compute maximally 
%accurate results (sometimes much more due to interpretation overhead).
%
%Here always A,b are thin and acc=2
%

  setround(0)
  if nargin<=2
    acc = 1;
  end
  [m,n] = size(A);
  
  % check the trivial cases
  if n==1                               % trivial least square
    x = (intval(A')*b)/sum(real(intval(A')*A));
    return
  elseif m==1                           % trivial underdetermined
    x = (intval(A')*b)/sum(real(intval(A)*A'));
    return
  end
  
  nrhs = size(b,2);
  
  if m>n                                % least squares
    x = intval(NaN(n,nrhs));
    R = qr(A,0);                        % using economy size QR
    if any(diag(R)==0), return, end
    if ~issparse(A)
      R = triu(R(1:n,:));
    else
      R = full(R);
    end
    S = inv(R);                         % approximate inverse of R
    if any(isnan(S(:))) || any(isinf(S(:))), return, end
    if acc
      setround(1)                   % rounding to upwards
      e = ones(n,1);
      Eps = eps/2;
      g2n = n*eps;                  % 2n*eps i.b.a. 2^-52 !
      gm = m*Eps;
      X = A*S;                      % upper bound of AS
      accX = 0;
      % accX = 0:  |AS-X| <= D  with  D = g2n|A||S| + n*eta*e_m*e_n' by (6.8)
      % realmin = 0.5 Eps^-1 eta = eps^-1 eta for Eps:=eps/2=2^-53
      De = g2n*(abs(A)*(abs(S)*e)) + max(n^2*eps,1)*realmin;
      Xe = abs(X)*e;
      setround(0)
      E = abs(X'*X-speye(n));       % rdg to nearest approx of |X'X-I|
      setround(1)
      % |X'X-I| <= (1+Eps)|E| + gm|X'||X| + m*eta/2*e_n*e_n' by (6.6)
      % X'X symmetric, so norm(E*e,inf)=norm(E,inf)=norm(E,1)=max(sum(E))
      normE = max(sum(E));
      % upper bound for norm(X^TX-I,inf) by (6.7)
      normE = normE + ( Eps*normE + gm*max( abs(X')*Xe ) + max(m*n*Eps,1)*realmin );
      y = Xe + De;
      % upper bound for norm(I-(AS)^T(AS),inf) by (6.2)
      alpha = normE + max( De'*abs(X) + g2n*((y'*abs(A))*abs(S)) ) + ...
                max(n*eps*sum(y),1)*realmin;
      if alpha>0.9
        setround(-1)
        Xinf = A*S;                 % lower bound of AS
        setround(1)
        D = X - Xinf;
        accX = 1;
        % accX = 1:  AS in [Xinf,X], so that  |AS-X| <= D
        De = D*e;   % see (6.1) and (6.2) in the paper
        alpha = normE + max( abs(X')*De + D'*(Xe+De));
        if ( alpha<2 ) && ( alpha>0.9 )
          X = 0.5*(Xinf+X);
          D = X - Xinf;
          accX = 2;
          % accX = 2:  |AS-X| <= D
          Xe = X*e;
          De = D*e;
          setround(0)
          E = abs(X'*X-speye(n));       % rdg to nearest approx of |X'X-I|
          setround(1)
          normE = max(sum(E));
          normE = normE + ( Eps*normE + gm*max( abs(X')*Xe ) + max(m*n*Eps,1)*realmin );
          alpha = normE + max( abs(X')*De + D'*(Xe+De));
        end
      end          
    else
      B = A'*intval(A);
      if nnz(B)>0.1*numel(B)
        B = full(B);
      end
      B = S'*B;
      B = mag(B*S-speye(n));
      setround(1)
      alpha = norm(B,1);     % 1-norm faster for symmetric matrix
      setround(0)
    end      
    if ( alpha>=1 ) || isnan(alpha)
      return
    end
    
    % residual part (in rounding to nearest)
    if acc
      xs1 = S*(X'*b);
      ws = X*(X'*b) - b;
    else
      xs1 = S*(S'*(A'*b));
      ws = A*(S*(S'*(A'*b))) - b;
    end
    if acc==2
      xs2 = zeros(n,nrhs);
      dnorm = inf;
      for i=1:10
        dnormold = dnorm;
        if nrhs==1
          res_ws = Dot_(A',ws);
        else
          res_ws = AccDot(A',ws);
        end
        if nrhs==1
          res_xs = Dot_(A,xs1,A,xs2,-1,ws,-1,b);
        else
          res_xs = AccDot(A,xs1,A,xs2,-1,ws,-1,b);
        end
        if acc
          beta = X'*res_xs + S'*res_ws;
          d_ws = X*beta - res_xs;
        else
          beta = S'*(A'*res_xs) + S'*res_ws;
          d_ws = A*(S*beta) - res_xs;
        end
        d_xs = S * beta;
        dnorm = norm(res_xs,1);
        if dnorm<dnormold
          ws = ws - d_ws;
          % xs1+xs2 := xs1+xs2-d_xs
          xx = xs2 + xs1;
          z = xx - xs2;
          e = ( xs2 - (xx-z) ) + (xs1-z);
          x = xx - d_xs;
          z = xx + d_xs;
          xs2 = e + ( ( (z-x) - d_xs ) + (xx-z) );
          xs1 = x;
          %         xs = xs - d_xs;
        end
        if dnorm>=1e-1*dnormold, break, end   % beware of zero residual
      end      
      if nrhs==1
        res_ws = Dot_(A',ws,-2);
        res_xs = Dot_(A,xs1,A,xs2,-1,ws,-1,b,-2);
      else
        res_ws = AccDot(A',ws,[]);
        res_xs = AccDot(A,xs1,A,xs2,-1,ws,-1,b,[]);
      end
    else
      res_ws = A'*intval(ws);
      res_xs = (A*intval(xs1)-ws)-b;
    end
    setround(1)
    if acc
      magres_xs = mag(res_xs);
      switch accX
        % Xtres_xs = X'*res_xs
        case 0   % accX = 0:  |AS-X| <= D  with  D = g2n|A||S| + n*eta*e_m*e_n'
          r = g2n*max((magres_xs'*abs(A))*abs(S)) + max(max(n*sum(magres_xs)*eps,1)*realmin);
          Xtres_xs = X'*res_xs + midrad(0,repmat(r',1,nrhs));
        case 1   % accX = 1:  AS in [Xinf,X] and  |AS-X| <= D
          Xtres_xs = X'*res_xs + midrad(0,D'*magres_xs);
        case 2   % accX = 2:  |AS-X| <= D
          Xtres_xs = X'*res_xs + midrad(0,D'*magres_xs);
      end
    else
      Xtres_xs = S'*(A'*res_xs);
    end
    Stres_ws = S'*res_ws;

    delta = mag(Xtres_xs + Stres_ws);
    % componentwise estimate, inspired by S. Miyajima:
    %   A^+b - xs = S(I-E)^-1*delta  
    % with E:=I-X^T*X and delta = X^T*rho_xs + S^T*rho_ws, 
    % and using |Mx| <= norm(x,p)*norm(M_i*,q)
    %Note rounding is upwards:
    err1 = mag(norm(delta,inf)/(-(alpha-1))*sum(abs(S),2));
    err2 = mag(norm(delta,2)/(-(alpha-1))*sqrt(sum(S.*S,2)));
    err = midrad(0,min(err1,err2));
    if nrhs>1
      err = repmat(err,1,nrhs);
    end
    if acc==2
      x = xs1 + ( xs2 + err );
    else
      x = xs1 - err;
    end
    
  else                              % underdetermined, m<n
    x = intval(NaN(n,nrhs));
    R = qr(A',0);                   % using economy size QR
    if any(diag(R)==0), return, end
    if ~issparse(A)
      R = triu(R(1:m,:));
    else
      R = full(R);
    end
    S = inv(R');                    % approximate inverse of R
    if any(isnan(S(:))) || any(isinf(S(:))), return, end
    if acc
      setround(1)                   % rounding to upwards
      Eps = eps/2;
      g2m = m*eps;                  % 2n*eps i.b.a. 2^-52 !
      gn = n*Eps;
      Y = S*A;                      % upper bound of SA
      % accY = 0;
      % accY = 0:  |SA-Y| <= D  with  D = g2m|S||A| + m*eta*e_m*e_n' by (6.8)
      % realmin = 0.5 Eps^-1 eta = eps^-1 eta for Eps:=eps/2=2^-53
      Dte = g2m*(sum(abs(S))*abs(A))' + max(m^2*eps,1)*realmin;
      Yte = sum(abs(Y))';
      setround(0)
      E = abs(Y*Y'-speye(m));       % rdg to nearest approx of |YY'-I|
      setround(1)
      % |YY'-I| <= (1+Eps)|E| + gn|Y||Y'| + n*eta/2*e_m*e_m' by (6.6)
      % YY' symmetric, so norm(E*e,inf)=norm(E,inf)=norm(E,1)=max(sum(E)) 
      % upper bound for norm(YY^T-I,inf) by (6.7)
      normE = max(sum(E));
      normE = normE + ( Eps*normE + gn*max( abs(Y)*Yte ) + max(m*n*Eps,1)*realmin );
      y = Yte + Dte;
      % upper bound for norm(I-(SA)^T(SA),inf) by (6.2)
      alpha = normE + max( abs(Y)*Dte + g2m*(abs(S)*(abs(A)*y)) ) + ...
                max(m*eps*sum(y),1)*realmin;
      if alpha>0.9
        setround(-1)
        Yinf = S*A;                 % lower bound of SA
        setround(1)
        D = Y - Yinf;
        % accY = 1;
        % accY = 1:  SA in [Yinf,Y], so that  |SA-Y| <= D
        Dte = sum(D)';
        alpha = normE + max( abs(Y)*Dte + D*(Yte+Dte));
        if ( alpha<2 ) && ( alpha>0.9 )
          Y = 0.5*(Yinf+Y);
          D = Y - Yinf;
          % accY = 2;
          % accY = 2:  |SA-Y| <= D
          Yte = sum(abs(Y))';
          Dte = sum(D)';
          setround(0)
          E = abs(Y*Y'-speye(m));       % rdg to nearest approx of |YY'-I|
          setround(1)
          normE = max(sum(E));
          normE = normE + ( Eps*normE + gn*max( abs(Y)*Yte ) + max(m*n*Eps,1)*realmin );
          alpha = normE + max( abs(Y)*Dte + D*(Yte+Dte));
        end
      end      
    else
      B = intval(A)*A';
      if nnz(B)>0.1*numel(B)
        B = full(B);
      end
      B = S*B;
      B = mag(B*S'-speye(m));
      setround(1)
      alpha = max(sum(B,1));  % 1-norm faster for symmetric matrix
      setround(0)
    end
    if ( alpha>=1 ) || isnan(alpha)
      return
    end
    setround(0)
    % residual part (in rounding to nearest)
    Sb = S*b;
    if acc
      xs = Y'*Sb;
    else
      xs = A'*(S'*Sb);
    end
    ws1 = S'*Sb;
    if acc==2
      ws2 = zeros(size(ws1));
      dnorm = inf;
      for i=1:10
        dnormold = dnorm;
        if nrhs==1
          res_ws = Dot_(A',ws1,A',ws2,-1,xs);
        else
          res_ws = AccDot(A',ws1,A',ws2,-1,xs);
        end
        if nrhs==1
          if acc
            d_ws = S'*( Y*res_ws + S*Dot_(A,xs,-1,b) );
          else
            d_ws = S'*( S*( A*res_ws + Dot_(A,xs,-1,b) ));
          end
        else
          if acc
            d_ws = S'*( Y*res_ws + S*AccDot(A,xs,-1,b) );
          else
            d_ws = S'*( S*( A*res_ws + AccDot(A,xs,-1,b) ));
          end
        end
        d_xs = A'*d_ws - res_ws;
        dnorm = norm(d_xs,1);
        if dnorm<dnormold
          % ws1+ws2 := ws1+ws2-d_ws
          xx = ws2 + ws1;
          z = xx - ws2;
          e = ( ws2 - (xx-z) ) + (ws1-z);
          x = xx - d_ws;
          z = xx + d_ws;
          ws2 = e + ( ( (z-x) - d_ws ) + (xx-z) );
          ws1 = x;
          xs = xs - d_xs;
        end
        if dnorm>=5e-1*dnormold, break, end   % beware of zero residual
      end
      if nrhs==1
        res_ws = Dot_(A',ws1,A',ws2,-1,xs,-2);
        res_xs = Dot_(A,xs,-1,b,-2);
      else
        res_ws = AccDot(A',ws1,A',ws2,-1,xs,[]);
        res_xs = AccDot(A,xs,-1,b,[]);
      end
    else
      res_ws = A'*intval(ws1)-xs;
      res_xs = A*intval(xs)-b;
    end
    setround(1)
    
    % componentwise estimate, inspired by S. Miyajima:
    %   A^+b -xs - rho_ws = Y^H*(I-E)^-1*delta 
    % with E:=I-X^T*X and delta = S*rho_xs - Y*rho_ws
    % and using |Mx| <= norm(x,p)*norm(M_i*,q)
    %Note rounding is upwards
    
    if acc
      delta = S*res_xs - Y*res_ws;
      Yte = sum(abs(Y),1)';
    else
      B = intval(S)*A;
      delta = S*res_xs - B*res_ws;
      Yte = sum(mag(B),1)';
    end
    err = mag(norm(delta,inf))/(-(alpha-1)) * Yte;
    if nrhs==1
      x = xs - ( res_ws + midrad(0,err) );
    else
      x = xs - ( res_ws + midrad(0,repmat(err,1,nrhs)) );
    end
  end
  
end  % function verifylssr
    