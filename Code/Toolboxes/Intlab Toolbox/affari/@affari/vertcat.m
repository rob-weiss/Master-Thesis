function c = vertcat(varargin)
%VERTCAT      Implements  [a(1) ; a(2) ; ...]  for affari
%

% written  03/08/14     S.M. Rump
% modified 05/21/14     S.M. Rump  All zero sparse: 1-by-1
%

  a = affari(varargin{1});
  c.mid = a.mid.';
  crange = a.range.';
  [m n] = size(a.mid);
  index = reshape( 1:(m*n) , m , n )';
  % take care of "All zero sparse: 1-by-1": do not use 'isempty'
  if nnz(a.err)
    c.err = a.err( : , index(:) );
  else
    c.err = [];
  end
  c.rnderr = a.rnderr;

  for i=2:length(varargin)
    a = affari(varargin{i});
    c.mid = [ c.mid a.mid.' ];
    crange = [ crange a.range.' ];
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if nnz(a.err)
      [m n] = size(a.mid);
      index = reshape( 1:(m*n) , m , n )';
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(c.err)
        ec = size(c.err,1);             % adapt number of error terms
        ea = size(a.err,1);
        if ea<ec
          a.err(ec,1) = 0;
        elseif ec<ea
          c.err(ea,1) = 0;
        end
        c.err = [ c.err , a.err(:,index(:)) ];   % arrays stored columnwise
      else
        c.err = [ sparse([],[],[],size(a.err,1),length(c.rnderr)) a.err(:,index(:)) ];
      end
    else
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(c.err)
        c.err(1,size(c.err,2)+length(a.rnderr)) = 0;
      end
    end
    c.rnderr = [ c.rnderr , a.rnderr ]; 
  end
  [m n] = size(c.mid);
  index = reshape( 1:(m*n) , m , n )';
  c.mid = c.mid.';
  % take care of "All zero sparse: 1-by-1": do not use 'isempty'
  if nnz(c.err)
    c.err = c.err( : , index(:)' );
  end
  c.range = crange.';

  c = class(c,'affari');
