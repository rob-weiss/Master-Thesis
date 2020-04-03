function r = subsasgn(r,s,b)
%SUBSASGN     Implements subscripted assignments for gradients
%
%  example  r(2,:) = b
%

% written  10/16/98     S.M. Rump
% modified 11/30/98     S.M. Rump  delete components by r(i,j) = []
% modified 10/12/99     S.M. Rump  correction for rowvectors
% modified 09/26/01     S.M. Rump  empty left or right hand side
% modified 03/03/03     S.M. Rump  assignment g(3)=g(2) for g is 2x2
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    assignment g(5)=1 for g is 2x1
%                                    sparse input
%                                    Matlab sparse bug
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 05/09/07     S.M. Rump  assignment r(:)=... (thanks S. Loisel)
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 08/26/12     S.M. Rump  global variables removed
% modified 09/26/12     S.M. Rump  index handling (thanks to Matthew Weinstein)
% modified 04/04/14     S.M. Rump  affari added
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
% modified 12/09/15     S.M. Rump  prod(size) to numel
% modified 12/10/15     S.M. Rump  empty assignment and no change of rounding
% modified 12/09/15     S.M. Rump  prod(size) to numel(s), Matlab 6.5 bug
%

  global INTLAB_CONST

  INTLAB_GRADIENT_NUMVAR = INTLAB_CONST.GRADIENT_NUMVAR;

  if length(s)>1
    error('multiple indexing for gradient assignment not allowed')
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
      r.dx( value(:)==1 , : ) = [];  
      return
    end

    if ~isa(b,'gradient')
      b = gradient(b);
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
      if length(s.subs)==1               % single index
        if ~isequal(s.subs{1},':')       % not call r(:)=...
          if size(r.x,1)==1              % row vector
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
      if sizeincreased                % size increased, adapt .x and .dx
        rx = r.x;
        rdx = r.dx;
        value = ones(size(r.x));
        value( s.subs{:} ) = 0;
        r.x = zeros(size(value));
        if issparse(rdx)
          r.dx = sparse([],[],[],numel(value),INTLAB_GRADIENT_NUMVAR,0);
        else
          r.dx = zeros(numel(value),INTLAB_GRADIENT_NUMVAR);
        end
        if resultIsintval
          r.x = intval(r.x);
          r.dx = intval(r.dx);
        end
        if resultIsaffari
          r.x = affari(r.x);
          r.dx = affari(r.dx);
        end
        r.x( value==1 ) = rx;
        r.dx( value(:)==1 , : ) = rdx;
      end
    else                     % assignment r(i) = b for empty r
      resultIsintval = isa(b.x,'intval');
      resultIsaffari = isa(b.x,'affari');
      r.x(s.subs{:}) = 0;
      if issparse(b.dx)
        r.dx = sparse([],[],[],numels(r.x),INTLAB_GRADIENT_NUMVAR,0);
      else
        r.dx = zeros(numels(r.x),INTLAB_GRADIENT_NUMVAR);
      end
      if resultIsintval
        r.x = intval(r.x);
        r.dx = intval(r.dx);
      end
      if resultIsaffari
        r.x = affari(r.x);
        r.dx = affari(r.dx);
      end
    end
    r.x( s.subs{:} ) = b.x;
    value = reshape(1:numels(r.x),size(r.x));
    index = value( s.subs{:} );
    if ( numels(b.x)==1 ) && ( length(index)~=1 )
      r.dx(index,:) = ones(length(index),1) * b.dx;
    else
      r.dx(index,:) = b.dx;
    end
    if rEmpty
      r = class(r,'gradient');
    end
  elseif strcmp(s(1).subs,'x') && isa(b,'affari')
    r.x = b;
  elseif strcmp(s(1).subs,'dx') && isa(b,'affari')
    r.dx = b;
  else
    error('invalid index reference for gradient')
  end

    