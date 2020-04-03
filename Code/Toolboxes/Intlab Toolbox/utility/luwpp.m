function [L,U,perm,growth] = luwpp(A)
%LUWPP        Gaussion elimination with partial pivoting
%
%    [L,U,perm,growth] = luwpp(A);
%
%Input A may be rectangular and double, complex, intval, fl, or affari. 
%In either case the decomposition is performed in the corresponding 
%arithmetic. 
%If no zero pivots occur, L*U = A(perm,:) after execution.
%If specified, grwoth is the growth factor.
%
%To solve a linear system with partial pivoting use  solvewpp(A,b).
%

% written  12/01/97     S.M. Rump
% modified 03/10/14     S.M. Rump  type adjustment
% modified 05/18/14     S.M. Rump  code optimization
% modified 08/01/16     S.M. Rump  growth factor for hessian, affari ...
%

  [m,n] = size(A);
  eval(['L = ' class(A) '(eye(m));'])
  if isintval(A) && isa(A,'fl')
    L = intval(L);
  end
  U = A;
  perm = 1:m;
  growth = 0;

  for i=1:n-1
    if i<m
      [c,index] = max(mag( U(i:m,i) )); index = index+i-1;
      if index~=i                       % interchange due to pivoting
        row = L(i,1:i-1);
        L(i,1:i-1) = L(index,1:i-1);
        L(index,1:i-1) = row;
        row = U(i,i:n);
        U(i,i:n) = U(index,i:n);
        U(index,i:n) = row;
        k = perm(i);
        perm(i) = perm(index);
        perm(index) = k;
      end
      j=i+1:m;
      if isintval(A)
        if in(0,U(i,i))
          L = NaN; U = NaN; return
        end
      else
        if U(i,i)==0
          L = NaN; U = NaN; return
        end
      end
      f = U(j,i)/U(i,i);                % update
      U(j,i+1:n) = U(j,i+1:n) - f*U(i,i+1:n);
      L(j,i) = f;
      growth = max(growth,max(max(mag(L(:))),max(mag(U(:)))));
    end
  end
  if n<m
    j=n+1:m;
    L(j,n) = U(j,n)/U(n,n);
    growth = max(growth,max(max(mag(L(:))),max(mag(U(:)))));
  end

  U = triu(U);
  growth = growth/max(mag(A(:)));
  