function r = subsasgn(r,s,b)
%SUBSASGN     Implements subscripted assignments for hessians
%
%  example  r(2,:) = b
%

% written  04/04/04     S.M. Rump
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 05/09/07     S.M. Rump  assignment r(:)=...
% modified 08/26/12     S.M. Rump  global variables removed
% modified 09/26/12     S.M. Rump  index handling (thanks to Matthew Weinstein)
% modified 04/04/14     S.M. Rump  affari added
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
% modified 12/10/15     S.M. Rump  empty assignment, Matlab 6.5 bug
% modified 12/12/15     S.M. Rump  prod(size) to numel(s)
%

  global INTLAB_CONST
  

  N = INTLAB_CONST.HESSIAN_NUMVAR;

  if length(s)>1
    error('multiple indexing for hessian assignment not allowed')
  end

  if strcmp(s.type,'()')     % assignment r(i) = b

    rEmpty = isempty(r);     % assignment r(i) = b for empty r
    if isempty(b)
      if isempty(r.x(s.subs{:}))
        return
      end
      % does not work in Matlab 5.3 for sparse r
      r.x(s.subs{:}) = [];
      value = zeros(size(r.x));
      value(s.subs{:}) = 1;
      index = find(value);
      r.dx( : , index ) = [];
      r.hx( : , index ) = [];
      return
    end

    if ~isa(b,'hessian')
      b = hessian(b);
    end

    if ~rEmpty
      resultIsintval = isa(r.x,'intval');
      if ~resultIsintval && isa(b.x,'intval')
        r = intval(r);
        resultIsintval = 1;
      end
      resultIsaffari = isa(r.x,'affari');
      if ~resultIsaffari && isa(b.x,'affari')
        r = affari(r);
        resultIsaffari = 1;
      end
      sizeincreased = 0;
      if length(s.subs)==1              % single index
        if ~isequal(s.subs{1},':')      % not r(:)=...
          if size(r.x,1)==1             % row vector
            sizeincreased = ( s.subs{1}>size(r.x,2) );
          else
            sizeincreased = ( s.subs{1} > numels(r.x) );
          end
          if sizeincreased
            srx = size(r.x);
            if length(srx)==2
              if all(prod(srx)~=srx)
                error('matrix cannot be resized by assignment a(I) = b')
              end
            else
              error('attempt to grow size of array along ambiguous dimension')
            end
          end
        end
      else                            % multiple index
        for i=1:length(s.subs)
          if ~isequal(s.subs{i},':')
            sizeincreased = sizeincreased | ( s.subs{i} > size(r.x,i) );
          end
        end
      end
      if sizeincreased                % size increased, adapt .x and .dx and .hx
        rx = r.x;
        rdx = r.dx;
        rhx = r.hx;
        value = ones(size(r.x));
        value( s.subs{:} ) = 0;
        r.x = zeros(size(value));
        INTLAB_HESSIAN_SPARSE = INTLAB_CONST.HESSIAN_SPARSE;
        if N<INTLAB_HESSIAN_SPARSE
          r.dx = zeros(N,numel(value));
          r.hx = zeros(N*N,numel(value));
        else
          r.dx = sparse([],[],[],N,numel(value));
          r.hx = sparse([],[],[],N*N,numel(value));
        end
        if resultIsintval
          r.x = intval(r.x);
          r.dx = intval(r.dx);
          r.hx = intval(r.hx);
        end
        if resultIsaffari
          r.x = affari(r.x);
          r.dx = affari(r.dx);
          r.hx = affari(r.hx);
        end
        index = find(value);
        r.x( index ) = rx;
        r.dx( : , index ) = rdx;
        r.hx( : , index ) = rhx;
      end
    else                     % assignment r(i) = b for empty r
      resultIsintval = isa(b.x,'intval');
      resultIsaffari = isa(b.x,'affari');
      r.x(s.subs{:}) = 0;
      INTLAB_HESSIAN_SPARSE = INTLAB_CONST.HESSIAN_SPARSE;
      if N<INTLAB_HESSIAN_SPARSE
        r.dx = zeros(N,numels(r.x));
        r.hx = zeros(N*N,numels(r.x));
      else
        r.dx = sparse([],[],[],N,numels(r.x));
        r.hx = sparse([],[],[],N*N,numels(r.x));
      end
      if resultIsintval
        r.x = intval(r.x);
        r.dx = intval(r.dx);
        r.hx = intval(r.hx);
      end
      if resultIsaffari
        r.x = affari(r.x);
        r.dx = affari(r.dx);
        r.hx = affari(r.hx);
      end
    end
    r.x( s.subs{:} ) = b.x;
    value = reshape(1:numels(r.x),size(r.x));
    index = value( s.subs{:} );
    if ( numels(b.x)==1 ) && ( length(index)~=1 )
      r.dx(:,index) = b.dx(:,ones(1,length(index)));
      r.hx(:,index) = b.hx(:,ones(1,length(index)));
    else
      r.dx(:,index) = b.dx;
      r.hx(:,index) = b.hx;
    end
    if rEmpty
      r = class(r,'hessian');
    end
  elseif strcmp(s(1).subs,'x') & isa(b,'affari')
    r.x = b;
  else
    error('invalid index reference for hessian')
  end

  