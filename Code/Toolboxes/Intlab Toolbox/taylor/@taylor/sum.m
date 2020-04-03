function a = sum(a,dim)
%SUM          Implements  sum(a,dim)  for Taylor
%
%   c = sum(a,dim)
%
% parameter dim optional, functionality as Matlab function sum
%

% written  05/21/09     S.M. Rump
% modified 04/27/14     S.M. Rump  size for vector sum
% modified 05/18/14     S.M. Rump  code optimization
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  m = a.size(1);
  n = a.size(2);
  k = size(a.t,1);
  if nargin==1
    if m==1
      dim = 2;
    else
      dim = 1;
    end
  end

  if ( m==1 ) || ( n==1 )    % vector sum
    if  ~( ( ( m==1 ) && ( dim==1 ) ) || ( ( n==1 ) && ( dim==2 ) ) )   
      a.size = [1 1];
      a.t = sum(a.t,2);      
    end
    return
  end
  
  rndold = getround;
  if rndold
    setround(0)
  end

  if dim==1                             % sum of columns
    index = reshape(1:prod(a.size),m,n)';
    a.size = [1 n];
    a.t = reshape(sum(reshape(a.t(:,index),k*n,m),2),k,n);   % sum of rows of transposed
  else                                  % sum of rows
    a.size = [m 1];
    a.t = reshape(sum(reshape(a.t,k*m,n),2),k,m);
  end
  
  if rndold
    setround(rndold)
  end
