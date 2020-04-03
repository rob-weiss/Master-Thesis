function A = sum(A,dim)
%SUM          Implements  sum(a,dim)  for fl-type
%
%   C = sum(A,dim)
%
% parameter dim optional
% functionality as Matlab function sum for matrices
%

% written  10/21/13     S.M. Rump
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
%

  global INTLAB_CONST
  
  const = INTLAB_CONST.FL_CONST;        % initialize constants
  [m,n] = size(A.value);
  
  if INTLAB_CONST.FL_MODE_ACCU
    if const.prec>13
      if nargin==2
        A = fl(sum(double(A),dim));
      else
        A = fl(sum(double(A)));
      end
      return
    else
      prec = 2*const.prec;
    end
  else
    prec = const.prec;
  end

  if nargin==1,
    if m==1
      dim=2;
    else
      dim=1;
    end
  end
  
  if dim==1
    P = A.value(1,:);
    for i=2:m
      P = flround(P+A.value(i,:),prec,const.expBias);
    end
  else
    P = A.value(:,1);
    for i=2:n
      P = flround(P+A.value(:,i),prec,const.expBias);
    end
  end
  
  A.value = P;
  
     