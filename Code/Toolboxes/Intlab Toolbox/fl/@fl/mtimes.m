function C = mtimes(A,B)
%MTIMES       fl-type multiplication  A * B
%

% written  10/21/13     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
%

  global INTLAB_CONST

  const = INTLAB_CONST.FL_CONST;       % initialize constants

  if isa(A,'fl')
    A = A.value;
  end

  if isa(B,'fl')
    B = B.value;
  end

  [m,k] = size(A);
  [k1,n] = size(B);
  
  if ( m*k==1 ) || ( k1*n==1 ) || ( k==1 )    % scalar A or B or outer product
    C = fl(A*B);
  else
    if k~=k1
      error('dimensions not compatible')
    end
    if INTLAB_CONST.FL_MODE_ACCU
      if const.prec>13
        C = fl(A*B);
        return
      end
      K = 2*const.prec;
    else
      K = const.prec;
    end
    C = flround(A(:,1)*B(1,:),K);
    for i=2:k-1
      C = flround( C + flround(A(:,i)*B(i,:),K) , K );
    end
    C = fl( C + flround(A(:,k)*B(k,:),K) );
  end
  