function A = hankel(c,r)
%HANKEL     Implements  hankel(c,r)  for affaris
%
%   A = hankel(c,r)
%
% functionality as Matlab function hankel
%

% written  08/09/02     S.M. Rump 
% modified 05/17/14     S.M. Rump  code optimization
%
  
  m = length(c);
  if nargin==2
    c = affari(c);
    r = affari(r);
    n = length(r);
    index = hankel(1:m,1:n);
    A.mid = hankel(c.mid,r.mid);
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if ~nnz(c.err)              % c has no error terms
      if nnz(r.err)         	% c has no, r has error terms
        cr_err = [ sparse([],[],[],size(r.err,1),m) , r.err];
      else
        cr_err = [];            % both c and r have no error terms
      end
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    elseif ~nnz(r.err)          % c has, r has no error terms
      cr_err = [ c.err , sparse([],[],[],size(c.err,1),n) ];
    else                        % both c and r have error terms
      Nc = size(c.err,1);
      Nr = size(r.err,1);
      if Nr>Nc
        c.err(Nr,1) = 0;
      elseif Nc>Nr
        r.err(Nc,1) = 0;
      end
      cr_err = [ c.err r.err ];
    end
    if isempty(cr_err) || isempty(index)
      A.err = [];
    else
      A.err = cr_err(:,index);
    end
    A.rnderr = [ c.rnderr r.rnderr ];
    if ~isempty(index)
      A.rnderr = A.rnderr(index(:)');
    end
    A.range = hankel(c.range,r.range);
  else
    index = hankel(1:m);
    index(index==0) = [];
    index = index(:)';
    A.mid = hankel(c.mid);
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if nnz(c.err)
      A.err = sparse([],[],[],size(c.err,1),m^2);
      A.err(:,index) = c.err(:,index);
    else
      A.err = [];
    end    
    if issparse(c.rnderr)
      A.rnderr = sparse([],[],[],1,m^2);
    else
      A.rnderr = zeros(1,m^2);
    end
    A.rnderr(index) = c.rnderr(index);
    A.range = hankel(c.range);
  end
  
  A = class(A,'affari');
