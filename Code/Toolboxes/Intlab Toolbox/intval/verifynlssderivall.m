function [List,ListS,ListData] = verifynlssderivall(varargin)
%VERIFYNLSSDERIVALL  Global nonlinear system solver for derivative
%
%Finds all zeros of the gradient of a function f:R^n->R within the box x0. 
%
%The function f needs to be in "vectorized form", i.e. [f(x) f(y)] and f([x y]) 
%must be equal. To achieve that, replace operations "o" by ".o" and replace 
%direct access to components x(i) by x(i,:). 
%If f is a function handle or a character string, this may be achieved 
%by funvec(f); if f is an inline function, it is converted automatically. 
%
%Standard calls are
%
%   [ X , XS ] = verifynlssderivall(f,x0)              or
%   [ X , XS , Data ] = verifynlssderivall(f,x0)
%
%or with optional parameters (if opt is omitted or empty, default
%paramaters are used)
%
%   [ X , XS , Data ] = verifynlssderivall(f,x0,opt)
%
%The output parameter Data stores data to continue the search, for example by
%
%   [ X , XS ] = verifynlssderivall(Data)
%   for k=1:kmax
%     [ X , XS , Data ] = verifynlssderivall(f)
%   end
%
%or, similarly,
%
%   [ X , XS , Data] = verifynlssderivall(Data,opt)
%
%Similarly,
%
%   [ X , XS ] = verifynlssderivall(f,x0,[],param1,param2,...)   or
%   [ X , XS ] = verifynlssderivall(f,x0,opt,param1,param2,...)
%
%evaluates the function f with extra paramaters param1, param2 ...
%
%Upon completion, X is an n x K array, each column containing a unique zero
%of the gradient of f, whereas XS is an n x L array possibly containing a zero 
%of the gradient of f. 
%
%input    f         f:R^n->R, function to find all zeros of the gradient in x0
%         x0        box to be searched
%         opt.fields  optional, if not specified, default values are used
%             Display   0    no extra display (default)
%                       1    see information on the iteration progress
%                       'x'   for 1<=n<=3, plots of the iteration progress,
%                               boxes filled with color 'x'
%                       '~'   same but with random color
%                       's'   same but only skeleton
%                       '.p'  same as above but with pause after some iterations
%             Boxes     'bisection' into boxes subboxes, default 16
%             iFunMax   maximal number of function evaluations, default 1e6
%             TolXAbs   Termination absolute tolerance on inclusions X
%             TolXRel   Termination relative tolerance on inclusions X
%output   X         n x K array of K inclusion boxes of unique zeros of f' within x0
%         XS        n x L array of L possible inclusion boxes
%         Data      Data to continue search
%
%Parameters in opt may be set by "verifynlssallset":
%   opt = verifynlssallset('boxes',256);
%or directly
%   [X,Xs] = verifynlssderivall(@(x)cos(x^2)+atan(x-erf(x)-asinh(x^3)),infsup(-5,5),verifynlssallset('display','~'))
%The List XS of possible inclusion boxes might be long. To collect boxes
%with a significant part in common, use 
%   XS = collectList(XS);
%For long lists that might take a considerable amout of computing time,
%depending on the structure of XS. Therefore, collection in not included
%here. For details and examples, see collectList.
%
%Using ideas in
%  O. Knüppel: Einschließungsmethoden zur Bestimmung der Nullstellen
%     nichtlinearer Gleichungssysteme und ihre Implementierung.
%     PhD thesis, Hamburg University of Technology, 1994.
%

% written  02/27/17   S.M. Rump
% modified 07/30/17   S.M. Rump  maximal number of function evaluations
% modified 10/09/17   S.M. Rump  default number of subboxes
% modified 12/12/17  S.M. Rump  check call with correct data
%

  global INTLAB_DERIV_CALLED
  
  INTLAB_DERIV_CALLED = true;
  [List,ListS,ListData] = verifynlssall(varargin{:});
  
end  % verifynlssderivall
