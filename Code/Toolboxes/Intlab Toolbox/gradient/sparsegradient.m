function res = sparsegradient(N,see)
%SPARSEGRADIENT  Number of unknowns from which gradients are stored sparse
%
%   N = sparsegradient         gets current value, default is 50
%   res = sparsegradient(N)    forces the gradient and gradient part
%                               of gradients to be sparse for N and more unknowns
%
%The values N=0 and N=inf imply always or never to use sparse storage, respectively. 
%The default is N=50 (set in startintlab), i.e. to use sparse storage for fifty and 
%  more variables. 
%
%When changing the current value, a corresponding message will be printed.
%To suppress the message, use
%
%   res = sparsegradient(N,0) 
%

% written  04/04/04     S.M. Rump
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/05/05     S.M. Rump  comment corrected
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
%

  global INTLAB_CONST
  
  if ( nargin==0 )                   % getting current width
    res = INTLAB_CONST.GRADIENT_SPARSE;
  else                               % setting current width
    if ( round(N)~=N ) || ( N<0 )
      error('Invalid input for sparsegradient')
    end
    INTLAB_GRADIENT_SPARSE = N;
    INTLAB_CONST.GRADIENT_SPARSE = INTLAB_GRADIENT_SPARSE;
    res = INTLAB_GRADIENT_SPARSE;
    if nargin==1
      see = 1;
    end
    if see
      if INTLAB_GRADIENT_SPARSE==0
        disp('===> Gradient derivative always stored sparse')
      elseif INTLAB_GRADIENT_SPARSE==inf
        disp('===> Gradient derivative always stored full')
      else
        disp(['===> Gradient derivative stored sparse for ' int2str(N) ' and more unknowns'])
      end
    end
  end
  