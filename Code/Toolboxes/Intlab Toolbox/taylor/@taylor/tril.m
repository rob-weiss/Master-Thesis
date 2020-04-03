function a = tril(a,k)
%TRIL         Implements  tril(a,k)  for Taylor
%
%   c = tril(a,k)
%
% functionality as Matlab function tril for matrices
%

% written  05/21/09     S.M. Rump
% modified 04/30/14     S.M. Rump  Matlab bug cured
%

  if nargin==1
    k = 0;
  end
  
  index = reshape(1:prod(a.size),a.size);
  ver = [ '      ' version];
  if isequal(ver(end-6:end-1),'R2007b')
    %%% Matlab bug in Version 2007b: Using tril(...,k) may cause core dump
    index = find(triu(index',-k)'==0);
  else
    index = find(tril(index,k)==0);
  end
  a.t(:,index) = 0;
