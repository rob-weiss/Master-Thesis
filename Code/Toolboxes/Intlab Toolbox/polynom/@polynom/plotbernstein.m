function plotbernstein(B,a,b)
%PLOTBERNSTEIN  Plots Berstein points with connecting lines
%
%For univariate Bernstein points, 
%
%   plotbernstein(B)
%
%plots Bernstein points in default interval [0,1]. Correspondingly, 
%
%   plotbernstein(B,a,b)
%
%plots Bernstein points in the interval [a,b]. 
%
%For given polynomial P and an interval [a,b], a typical call for plotting P together with 
%its Bernstein points is
%
%   B = bernsteincoeff(ptrans(P,a,b,0,1)); 
%   plotpoly(P,a,b), hold on, plotbernstein(B,a,b), hold off
%

% written  12/25/02     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/20/05     S.M. Rump  faster check for rounding to nearest
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  rndold = getround;
  if rndold
    setround(0)
  end

  if ~isreal(B.c)
    error('polynomial must be real (point or interval)')
  end
  
  if size(B.e,2)==1                   % univariate polynomial
    
    if nargin==1
      a = 0;
      b = 1;
    end
    n = length(B.c);
    X = linspace(a,b,n);
    
    if isa(B.c,'intval')
      
      Bc = fliplr([B.c.inf B.c.sup]);
      XX = [X X];
      if n>1
        index = convhull(XX,Bc);
      else
        index = 1:2;
      end
      plot(XX,Bc,'o',XX(index),Bc(index),'-o')
      
    else
      
      Bc = fliplr(B.c);
      if n>2
        index = convhull(X,Bc);
      else
        index = 1:length(Bc);
      end
      plot(X,Bc,'o',X(index),Bc(index),'-o')
      
    end
    
  elseif size(B.e,2)==2                  % multivariate polynomial in two unknowns
    error('not yet implemented')
  else
    error('Bernstein plot only for polynomials in one or two unknowns')
  end
  
  setround(rndold)
