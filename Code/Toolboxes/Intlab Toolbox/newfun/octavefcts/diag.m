function res = diag(A,k)
%DIAG         Functionality as diag with check for parameter outside matrix
%

% written  08/04/14  S.M. Rump
%

  global INTLAB_CONST

  if INTLAB_CONST.OCTAVE    
    if nargin==1
      k = 0;
    end    
    [m n] = size(A);
    if ( m~=1 ) && ( n~=1 )
      if ( k<=-m ) || ( k>=n )
        res = ones(0,1);
        return
      end
      k = min(max(k,-m+1),n-1);
    end
  end
  
  res = builtin('diag',A,k);
