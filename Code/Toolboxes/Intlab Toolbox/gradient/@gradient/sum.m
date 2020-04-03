function a = sum(a,dim)
%SUM          Implements  sum(a,dim)  for gradients
%
%   c = sum(a,dim)
%
% parameter dim optional, functionality as Matlab function sum
%

% written  10/16/98     S.M. Rump
% modified 11/03/03     S.M. Rump  performance improvement
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 12/05/05     S.M. Rump  improved performance
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 08/26/12     S.M. Rump  global variables removed
% modified 05/18/14     S.M. Rump  code optimization
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
% modified 03/10/17     S.M. Rump  take care of NaN-components
%

  [m n] = size(a.x);
  if nargin==1
    if m==1
      dim = 2;
    else
      dim = 1;
    end
  end

  if ( m==1 ) || ( n==1 )    % vector sum
    if  ~( ( ( m==1 ) && ( dim==1 ) ) || ( ( n==1 ) && ( dim==2 ) ) )
      a.x = sum(a.x);
      a.dx = sum(a.dx);
    end
    return
  end
  
  rndold = getround;
  if rndold
    setround(0)
  end

  a.x = sum(a.x,dim);       % matrix sum
  if dim==1                 % column sum
    % the following not working for inf-components
    % a.dx = sparse(repmat(1:n,m,1),1:m*n,1)*a.dx;
    a.dx = reshape(sum(reshape(a.dx,m,[]),1),n,[]);
  else                      % row sum
    % the following not working for inf-components
    % a.dx = repmat(speye(m),1,n)*a.dx;   % thanks to J. Kubitz
    a.dx = reshape(sum(reshape(a.dx',[],n),2),[],m)';
  end
  
  if rndold
    setround(rndold)
  end
