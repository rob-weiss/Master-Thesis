function [ X , xs ] = verifynlssnonsquare(fun,xs,see)
%VERIFYNLSSNONSQUARE   Verified solution of over- or underdeterminted nonlinear system
%
%   [ X , xs ] = verifynlssnonsquare(f,xs,see)
%
%Let f:R^n->R^m be given together with xs s.t. f(xs) is approximately zero.
%
%For n<m, the overdetermined nonlinear system is solved as a least squares
%problem, i.e. norm(f(x),2) is minimized. 
%
%For n>m, an inclusion of the minimum 2-norm solution of the underdetermined 
%nonlinear system f(x)=0 is computed.
%
%In both cases a minimum based on the approximation xs is computed. That
%need not to be the global minimum. To safely compute the latter, please
%use verifyglobalmin or verifyconstraintglobalmin.
%
%For n=m, the square nonlinear system is solved. In that case verifynlss
%may be used as well.
%

% written  02/27/17     S.M. Rump
%

  if ( nargin<3 ) || isempty(see)
    see = 0;
  end
  
  n = length(xs);
  m = length(feval(fun,xs));
  
  if n==m       % square system of nonlinear equations
    [X,xs] = verifynlss(fun,xs,[],see);
  elseif n>m    % underdetermined nonlinear system
    [X,xs] = verifyconstraintlocalmin(@(x)(sum(x.^2,1)),fun,xs,see);
  elseif n<m    % overdetermined nonlinear system
    [X,xs] = verifylocalmin(@(x)sum(fun(x).^2),xs,'',see);
  end

end  % verifynlssnonsquare
