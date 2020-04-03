function cnd = cond(A,p,acc)
%COND         Verified inclusion of p-norm condition number
%
%Call
%   default p=2      cnd = cond(A)    or  cnd = cond(A,'illco')
%   p-norm           cnd = cond(A,p)  or  cnd = cond(A,p,'illco')
%
%Possible values for p: 1, 2, inf, 'fro'
%
%input   A     real or complex Matrix
%        p     p-norm is used, default is p=2
%        acc   optional, for real point matrices, acc='illco' implies
%                extra-accurate calculation for ill-conditioned matrices
%output  cnd   verified inclusion of p-norm condition number
%                result is NaN in case of failure (matrix too ill-conditioned)
%              for interval input intA an inclusion of cond(A,p) for all A in intA.
%
%Based on
%   S.M. Rump: Verified bounds for the p-norm condition number, Reliable Computing, 
%      Vol. 20, pp. 45-52, 2014.
%
%Note that an approximate inverse is used, so it may be time and memory
%consuming for sparse matrices. 
%
%The algorithm is not optimized for sharp inclusions because usually this seems
%not necessary. The statement
%   res = norm(intval(A),p)*norm(inv(intval(A)),p)
%usually produces (much) sharper inclusions, however, at the price of
%higher computing time for larger dimension.
%
% written  07/14/13     S.M. Rump
% modified 05/15/14     S.M. Rump  code optimization
% modified 07/31/17     S.M. Rump  singular inv(A)
%

  [m,n] = size(A);
  if m~=n
    error('verified condition number only for square matrices')
  end

  wng = warning;
  warning('off')
  
  if nargin<2
    p = 2;
    acc = 0;
  elseif nargin<3
    if ischar(p)
      if isequal(p,'fro')
        acc = 0;
      elseif isequal(p,'illco')
        acc = p;
        p = 2;
      else
        error('invalid call of cond')
      end
    else
      acc = 0;
    end
  end
  
  if ischar(acc) && ( ~isequal(acc,'illco') )
    error('if third argument is string it must be ''illco''')
  end
  
  ee = 1e-6;                            % accuracy requirement for normposA  

  if acc                                % ill-conditioned case
    
    if A.complex                        % check A is point matrix
      error('option ''illco'' only for real point matrices')
    else
      if ~isequal(A.inf,A.sup)
        error('option ''illco'' only for point matrices')
      end
      A = A.inf;
    end
    
    % preconditioner: approximate inverse, A is point matrix
    for i=1:3
      if i==1
        R = inv( A ) ;
      end
      if any(isinf(R(:))) || any(isnan(R(:)))
        if i==3
          return
        end
        R = inv(A.*(1+10^(-16+i)*randn(size(A))));
      else
        break
      end
    end
    B = AccDot(R,A,[]);                 % inclusion of RA
    S = inv(mid(B));                    % approximate midpoint inverse
    E = speye(n) - S*B;                 % inclusion of residual
    % A supposedly ill-conditioned, so spend the effort to bound ||E||_2
    if ( p==2 ) | strcmp(p,'fro')
      normE = mag(norm(E,2));           % upper bound of ||E||_2
    else
      normE = mag(norm(E,p));           % upper bound of ||E||_p
    end
    
    if normE<1
      if strcmp(p,'fro')                % careful: normE bounds ||E||_2
        cnd = norm(intval(A),p) * norm(S*intval(R),p) * midrad(1,mag(norm(E,'fro')/(1-normE))) ;
      else
        cnd = norm(intval(A),p) * norm(S*intval(R),p) / midrad(1,normE) ;
      end        
      cnd.inf = max(0,cnd.inf);         % take care of large r
    else
      cnd = intval(NaN);
    end
    
  else                                  % not ill-conditioned case
    
    if A.complex                        % complex input
      mA = A.mid;
    else                                % real input
      mA = mid(A);
    end
    R = inv(mA);
    E = speye(n) - R*A;                 % inclusion of residual
    if ( p==2 ) | strcmp(p,'fro')
      normE = mag(normposA(mag(E),ee)); % upper bound of ||E||_2      
    else
      normE = mag(norm(E,p));           % upper bound of ||E||_p
    end

    if normE<1 
      if strcmp(p,'fro')                % careful: normE bounds ||E||_2
        cnd = norm(intval(A),p) * norm(intval(R),p) * midrad(1,mag(norm(E,'fro')/(1-normE))) ;
      else
        cnd = norm(intval(A),p) * norm(intval(R),p) / midrad(1,normE) ;
      end
      cnd.inf = max(0,cnd.inf);         % take care of negative lower bound
    else
      cnd = intval(NaN);
    end

  end
  
  warning(wng)
  