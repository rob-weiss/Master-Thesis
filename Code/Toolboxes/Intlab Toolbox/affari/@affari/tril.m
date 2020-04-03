function a = tril(a,k)
%TRIL         Implements  tril(a,k)  for affaris
%
%   c = tril(a,k)
%
% functionality as Matlab function tril for matrices
%

% written  08/09/02     S.M. Rump 
% modified 04/30/14     S.M. Rump  Matlab bug cured
% modified 05/21/21     S.M. Rump  All zero sparse: 1-by-1
%

  if nargin==1
    k = 0;
  end
  
  ver = [ '      ' version];
  if isequal(ver(end-6:end-1),'R2007b')
    %%% Matlab bug in Version 2007b: Using tril(...,k) may cause core dump
    a.mid = triu(a.mid.',-k).';
    index = ( triu( ones(size(a.mid)) , -k )' == 0 );
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if nnz(a.err)
      a.err(:,index) = 0;
    end
    a.rnderr(index) = 0;
    a.range = triu(a.range.',-k).';
  else
    a.mid = tril(a.mid,k);
    index = ( tril( ones(size(a.mid)) , k ) == 0 );
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if nnz(a.err)
      a.err(:,index) = 0;
    end
    a.rnderr(index) = 0;
    a.range = tril(a.range,k);
  end
  