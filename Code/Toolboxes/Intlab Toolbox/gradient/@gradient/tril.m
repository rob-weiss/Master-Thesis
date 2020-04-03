function a = tril(a,k)
%TRIL         Implements  tril(a,k)  for gradients
%
%   c = tril(a,k)
%
% functionality as Matlab function tril for matrices
%

% written  10/16/98     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    improved performance
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 04/30/14     S.M. Rump  Matlab bug cured
% modified 05/18/14     S.M. Rump  code optimization
%

  global INTLAB_CONST

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
  
  a.dx(index,:) = 0;
