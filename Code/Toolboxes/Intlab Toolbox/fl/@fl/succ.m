function R = succ(A,k)
%SUCC         fl-successor of fl-type A
%
%   R = succ(A)
%
%On return, R consists of the (elementwise) smallest fl-numbers with A < R.
%Similarly,
%
%   R = succ(A,k)
%
%produces the  k-th successor. Negative k yields k-th predecessor.
%

% written  10/31/13     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST

  if isa(A,'intval')
    error('function successor not for fl-type intervals')
  end

  rndold = getround;
  if rndold
    setround(0)
  end

  const = INTLAB_CONST.FL_CONST;        % initialize constants
  eta = const.subrealmin;

  if nargin==1
    k = 1;
  end

  R = A;
  if k<0
    setround(-1)
    for i=1:(-k)
      R = R - eta;
    end
  else
    setround(1)
    for i=1:k
      R = R + eta;
    end
  end
    
  setround(rndold)
