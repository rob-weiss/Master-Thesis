function r = subsasgn(r,s,b)
%SUBSASGN     Implements subscripted assignments for affari
%
%  example  r(2,:) = b
%

% written  12/06/13     S.M. Rump
% modified 05/17/14     S.M. Rump  code optimization
% modified 05/21/14     S.M. Rump  All zero sparse: 1-by-1
% modified 12/09/15     S.M. Rump  prod(size) to numel
% modified 12/10/15     S.M. Rump  empty assignment, Matlab 6.5 bug
% modified 03/19/19     S.M. Rump  increased size
%

  if length(s)>1
    error('multiple indexing for affari assignment not allowed')
  end

  if strcmp(s.type,'()')     % assignment r(i) = b

    rEmpty = isempty(r);     % assignment r(i) = b for empty r
    if isempty(b)
      if isempty(r.mid(s.subs{:}))
        return
      end
      % does not work in Matlab 5.3 for sparse r
      value = zeros(size(r.mid));
      r.mid(s.subs{:}) = [];
      r.range(s.subs{:}) = [];
      if isempty(r.mid)
        r = affari([]);
        return
      end
      value(s.subs{:}) = 1;
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(r.err)
        r.err( : , value(:)==1 ) = [];  
      end
      r.rnderr( value(:)==1 ) = [];  
      return
    end

    if ~isa(b,'affari')
      b = affari(b);
    end

    if ~rEmpty
      sizeincreased = 0;
      if length(s.subs)==1               % single index
        if ~isequal(s.subs{1},':')       % not call r(:)=...
          if size(r.mid,1)==1              % row vector
            sizeincreased = ( s.subs{1}>size(r.mid,2) );
          else
            sizeincreased = ( s.subs{1} > numel(r.mid) );
          end
          if sizeincreased
            srx = size(r.mid);
            if length(srx)==2
              if all(prod(srx)~=srx)
                error('matrix cannot be resized by assignment a(I) = b')
              end
            else
              error('attempt to grow size of array along ambiguous dimension')
            end
          end
        end
      end
      if sizeincreased                % size increased, adapt components
        rmid = r.mid;
        rerr = r.err;
        rrnderr = r.rnderr;
        rrange = r.range;
        value = ones(size(r.mid));
        value( s.subs{:} ) = 0;
        r.mid = zeros(size(value));
        r.range = intval(r.mid);
        r.err = sparse([],[],[],size(rerr,1),numel(value),0);
        r.rnderr = sparse([],[],[],1,numel(value),0);
        r.mid( value==1 ) = rmid;
        r.range( value==1 ) = rrange;
        if ~isempty(rerr)
          r.err( : , value(:)==1 ) = rerr;
        end
        r.rnderr( value(:)==1 ) = rrnderr;
      end
    else                     % assignment r(i) = b for empty r
      r.mid(s.subs{:}) = 0;
      r.err = [];
      r.rnderr = sparse([],[],[]);
      r.range(s.subs{:}) = intval(0);
    end
    r.mid( s.subs{:} ) = b.mid;
    r.range( s.subs{:} ) = b.range;
    value = reshape(1:numel(r.mid),size(r.mid));
    index = value( s.subs{:} );
    if ( size(b.err,2)==1 ) && ( length(index)~=1 )
      b.err(:,index) = b.err * ones(1,length(index));
      b.rnderr(index) = b.rnderr * ones(l,length(index));
    end
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if nnz(b.err)
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(r.err)
        r.err(1:size(b.err,1),index) = b.err;
      else
        r.err = sparse([],[],[],size(b.err,1),length(r.rnderr));
        r.err(:,index) = b.err;
      end
    else
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(r.err)
        r.err(:,index) = sparse(size(r.err,1),numel(index));
      end
    end
    r.rnderr(index) = b.rnderr;
    if rEmpty
      r = class(r,'affari');
    end
  else
    error('invalid index reference for affari')
  end
