function a = sum(a,dim)
%SUM          Implements  sum(a,dim)  for affaris
%
%   c = sum(a,dim)
%
% parameter dim optional, functionality as Matlab function sum
%

% written  12/06/13  S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/17/14     S.M. Rump  code optimization
% modified 05/21/14     S.M. Rump  All zero sparse: 1-by-1
%

  [m n] = size(a.mid);
  if nargin==1
    if m==1
      dim = 2;
    else
      dim = 1;
    end
  end

  if ( m==1 ) || ( n==1 )    % vector sum
    if  ~( ( ( m==1 ) && ( dim==1 ) ) || ( ( n==1 ) && ( dim==2 ) ) )
      S = sum(intval(a.mid));
      a.mid = mid(S);
      rndold = getround;
      setround(1)
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(a.err)
        T = sum(intval(a.err),2);
        a.err = mid(T);
        a.rnderr = sum(a.rnderr) + S.rad(:)' + sum(T.rad,1);
      else
        a.rnderr = sum(a.rnderr) + S.rad(:)';
      end
      a = intersectNaN( a , sum(a.range) );
      setround(rndold)
    end
    return
  end
  
  rndold = getround;                % save rounding mode
  setround(0)
  
  % input is affari matrix
  index = reshape(1:m*n,m,n)';
  S = sum(intval(a.mid),dim);
  a.mid = mid(S);
  
  % treat error term
  % take care of "All zero sparse: 1-by-1": do not use 'isempty'
  if nnz(a.err)
    K = size(a.err,1);
    if dim==1                       % column sum
      E = reshape(sum(intval(reshape(a.err(:,index),K*n,m)),2),K,n);
    else                            % row sum, dim=2
      E = reshape(sum(intval(reshape(a.err,K*m,n)),2),K,m);
    end
    a.err = mid(E);
    setround(1)
    S = sum(rad(S),1) + sum(rad(E),1);
  else
    setround(1)
    S = sum(rad(S),1);
  end
  
  % treat rounding error term
  setround(1)
  if dim==1                       % column sum
    a.rnderr = sum(reshape(a.rnderr,m,n),1) + S;
  else                            % row sum, dim=2
    a.rnderr = sum(reshape(a.rnderr(index),n,m),1) + S;
  end
  a = intersectNaN( a , sum(a.range,dim) );
  setround(rndold)

  % no extra error term for rounding error
%   if INTLAB_CONST.AFFARI_ROUNDINGERRORS
%     a = rnderrintoerrterm(a);
%   end
