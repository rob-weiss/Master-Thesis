function r = subsref(a,s)
%SUBSREF      Implements subscripted references for Hessians
%

% written  04/04/04     S.M. Rump
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 08/26/12     S.M. Rump  global variables removed
% modified 10/03/12     S.M. Rump  INTLAB_HESSIAN_DERIV_ERROR removed
% modified 10/06/12     S.M. Rump  internal use
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
% modified 10/04/15     S.M. Rump  significant performance gain for sparse input
% modified 12/10/15     S.M. Rump  setround, Matlab 6.5 bug
% modified 12/12/15     S.M. Rump  prod(size) to numel(s)
%

  global INTLAB_CONST
  

  N = INTLAB_CONST.HESSIAN_NUMVAR;

  while 1
    if ~isa(a,'hessian')                 % index reference a.x(i) etc.
      r = subsref(a,s(1));
    elseif strcmp(s(1).type,'()')        % index reference a(i)
      r.x = a.x(s(1).subs{:});
      index = reshape(1:numels(a.x),size(a.x));
      index = index(s(1).subs{:});
      r.dx = a.dx(:,index(:));
      r.hx = a.hx(:,index(:));
      r = class(r,'hessian');
    elseif strcmp(s(1).type,'.')         % index reference a.x, a.dx or a.hx
      if strcmp(s(1).subs,'x')
        r = a.x;
      elseif strcmp(s(1).subs,'dx')
        sizeax = size(a.x);
        if ( length(sizeax)==2 ) && ( sizeax(2)==1 ) 
          sizeax = sizeax(1);            % row gradient for column vector a.x
        end
        if issparse(a.dx) && ( length(sizeax)>1 )
          error('access of .dx sparse hessian with more than one column, see hessianinit')
        end
        r = reshape(transpose(a.dx),[sizeax N]);
      elseif strcmp(s(1).subs,'ddx')
        r = a.dx;
      elseif strcmp(s(1).subs,'hx')
        if issparse(a.hx) && ( numels(a.x)>1 )
          error('access of .hx of non-scalar sparse hessian, see hessianinit')
        end
        if issparse(a.hx)
          if size(a.hx,2)==1
            r = reshape(a.hx,N,N).';
            r = a.hx + r(:);
          else
            [I,J,S] = find(a.hx);
            index = reshape(1:N*N,N,N)';
            r = a.hx + sparse(index(I),J,S);
          end
        else                                % no sparse ND-arrays
%           r = a.hx + reshape(permute(reshape(a.hx,N,N,[]),[2 1 3]),N^2,[]);
          index = reshape(1:N*N,N,N)';
          r = a.hx + a.hx(index(:),:);     % Hessian is .hx + transpose(.hx)
        end
        sizeax = size(a.x);
        if prod(sizeax)==1
          r = reshape(r,N,N);
        else
          r = reshape(r,[sizeax N N]);
        end
      elseif strcmp(s(1).subs,'hhx')
        index = reshape(1:N*N,N,N)';
        r = a.hx + a.hx(index(:),:);     % Hessian is .hx + transpose(.hx)
      elseif strcmp(s(1).subs,'mid')
        r = mid(a);
      else
        error('invalid subscript reference for hessian')
      end
    else
      error('invalid index reference for hessian')
    end
    if length(s)==1  
      return
    end
    s = s(2:end);
    a = r;
  end
