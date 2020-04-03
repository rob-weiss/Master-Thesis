function A = toeplitz(c,r)
%TOEPLITZ     Implements  toeplitz(c,r)  for affaris
%
%   A = toeplitz(c,r)
%
% functionality as Matlab function toeplitz
%

% written  08/09/02     S.M. Rump 
% modified 05/17/14     S.M. Rump  code optimization
% modified 05/21/14     S.M. Rump  All zero sparse: 1-by-1
%
  
  m = length(c);
  if nargin==2
    c = affari(c);
    r = affari(r);
    n = length(r);
    index = toeplitz(1:m,1:n);
    A.mid = toeplitz(c.mid,r.mid);
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if ~nnz(c.err)              % c has no error terms
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(r.err)             % c has no, r has error terms
        cr_err = [ sparse([],[],[],size(r.err,1),m) , r.err];
      else
        cr_err = [];            % both c and r have no error terms
      end
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
    A.range = toeplitz(c.range,r.range);
  else                              % one argument
    index = toeplitz(1:m);
    A.mid = toeplitz(c.mid);
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if nnz(c.err)
      A.err = c.err(:,index);
    else
      A.err = [];
    end
    A.rnderr = c.rnderr(index(:)');
    A.range = toeplitz(c.range);
  end
  
  A = class(A,'affari');
