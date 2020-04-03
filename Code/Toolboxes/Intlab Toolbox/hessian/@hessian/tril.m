function a = tril(a,k)
%TRIL         Implements  tril(a,k)  for hessians
%
%   c = tril(a,k)
%
% functionality as Matlab function tril for matrices
%

% written  04/04/04     S.M. Rump
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 04/30/14     S.M. Rump  Matlab bug cured
%

  if nargin==1
    k = 0;
  end

  ver = [ '      ' version];
  if isequal(ver(end-6:end-1),'R2007b')
    %%% Matlab bug in Version 2007b: Using tril(...,k) may cause core dump
    a.x = triu(a.x.',-k).';
    index = ( triu( ones(size(a.x)) , -k )' == 0 );
  else
    a.x = tril(a.x,k);
    index = ( tril( ones(size(a.x)) , k ) == 0 );
  end
  
  a.dx(:,index) = 0;
  a.hx(:,index) = 0;
