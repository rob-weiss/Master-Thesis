function r = rangeapprox(r,a,index,select,p,q,delta,mu)
%RANGEAPPROX  Range approximation by p,q,delta; rounding +1 after call
%
%   r = rangeapprox(r,a,index,select,p,q,delta)
%
%       r   r(index) input, index components of r output
%a(index)   given affine variable
%   index   non-empty index set of a.mid
%  select   0  all indices of r and a
%           1  all indices of a, r(index)
%           2  a(index) and r(index)
%       p   inclusion of slope
%       q   inclusion of offset
%   delta   non-negative radius
%
%Careful, .range is NOT adapted, subsequent call necessary:
%  r.range = intersect( affarirange(struct(r)) , fun(a.range) )
%dimensions of p, q and delta same as index
%On return, components r(index) are set
%If mu is specified (only for p~=0), then range  p*(x-mu)+q +/- delta
%

% written  11/03/13    S.M. Rump
% modified 04/23/14    S.M. Rump  set/getappdata replaced by global
% modified 05/09/14    S.M. Rump  index access
% modified 05/17/14    S.M. Rump  code optimization
% modified 05/21/14    S.M. Rump  All zero sparse: 1-by-1
% modified 12/09/15    S.M. Rump  prod(size) to numel
% modified 22/23/17    S.M. Rump  Octave's isequal (thanks to Kai Ohlhus)
%

  global INTLAB_CONST

  % select appropriate components in a
  if select<=1                              % all indices, at least of a
    Kvar = numel(a.mid);                    % total number of variables
    amid = a.mid;
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if nnz(a.err)
      aerr = a.err;
      Kerr = size(r.err,1);                 % number of error terms
      if Kerr>size(aerr,1)                  % adapt size of error terms
        aerr(Kerr,1) = 0;
      end
    else
      aerr = [];
      Kerr = 0;                             % no error term
    end
    arnderr = a.rnderr;
  else                                      % selected indices
    Kvar = numel(index);                    % number of selected variables
    amid = a.mid(index);
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if nnz(a.err)
      aerr = a.err(:,index);
      Kerr = size(r.err,1);                 % number of error terms
      if Kerr>size(aerr,1)                  % adapt size of error terms
        aerr(Kerr,1) = 0;
      end
    else
      aerr = [];
      Kerr = 0;                             % no error term
    end
    arnderr = a.rnderr(index);
  end
  
  if isequal(0,p)    % instead of isequal(p,0) makes Octave happy :)
    
    % affine approximation f(x) in q +/- delta on [x1,x2]
    if select==0                            % all indices
      r.mid = mid(q);
      r.err = [];
      setround(1)
      r.rnderr = r.rnderr + delta(:)';
    elseif select==1                        % all indices of a
      r.mid(index) = q;                     % q is point [ rad(f(X)) ]
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(r.err)
        r.err(:,index) = 0;
      end
      setround(1)
      r.rnderr(index) = r.rnderr(index) + delta(:)';
    else
      r.mid(index) = mid(q(index));
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(r.err)
        r.err(:,index) = 0;
      end
      delta = delta(index);
      r.rnderr(index) = r.rnderr(index) + delta(:)';
    end
    delta = 0;
    
  else
    
    % affine approximation f(x) in px+q +/- delta on [x1,x2]
    if nargin==8                            % range  p*(x-mu)+q +/- delta
      p_amid_q = q;
    else                                    % range  p*x+q +/- delta
      p_amid_q = p.*amid + q;
    end
    if select==0                            % all indices
      r.mid = mid(p_amid_q);
    else
      r.mid(index) = mid(p_amid_q);
    end
    p = p(:);
    magp = mag(p);
    
    setround(1)
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if nnz(a.err)
      [I,J,S] = find(aerr);
      Q = p.mid(J).*intval(S(:));             % midp * aerr
      if select==0                            % all indices
        r.err = sparse(I,J,mid(Q),Kerr,Kvar);
        r.rnderr = rad(p)'.*sum(abs(aerr),1) + magp'.*sum(abs(arnderr),1) + ...
          ( reshape(rad(p_amid_q),1,Kvar) + sum(sparse(I,J,rad(Q),Kerr,Kvar),1) );
      else
        r.err(:,index) = sparse(I,J,mid(Q),Kerr,Kvar);
        r.rnderr(index) = rad(p)'.*sum(abs(aerr),1) + magp'.*sum(abs(arnderr),1) + ...
          ( reshape(rad(p_amid_q),1,Kvar) + sum(sparse(I,J,rad(Q),Kerr,Kvar),1) );
      end
    else
      if select==0                            % all indices
        r.rnderr = magp'.*sum(abs(arnderr),1) + reshape(rad(p_amid_q),1,Kvar) ;
      else
        r.rnderr(index) = magp'.*sum(abs(arnderr),1) + reshape(rad(p_amid_q),1,Kvar) ;
      end
    end
  end
  
  if ( nargin==8 ) && ~isequal(0,p)             % take care of radius
    % isequal(0,p)    instead of isequal(p,0) makes Octave happy :)
    N = INTLAB_CONST.AFFARI;
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if ~nnz(r.err)
      if select==0
        r.err = sparse([],[],[],N+Kvar,Kvar);
      else
        Kvar_r = numel(index);                  % number variables in r
        r.err = sparse([],[],[],N+Kvar,Kvar_r);
      end
    end
    if select==0                                % all indices
%       r.err(N+1:N+Kvar,:) = spdiags( magp.*mag(a.range(:)) ,0,Kvar,Kvar);
      v = 1:Kvar;
      r.err = [ r.err ; sparse(v,v,magp.*mag(a.range(:)),Kvar,Kvar) ];
    elseif select==1                            % all indices of a
      % index must be logical!
      MN = numel(a.mid);
      magarangeindex = mag(a.range);
%       r.err(N+1:N+Kvar,index) = spdiags( magp.*magarangeindex(:) , 0,Kvar,Kvar);
      r.err = [ r.err ; sparse(N-size(r.err,1),MN) ; ...
        sparse(1:Kvar,find(index),magp.*magarangeindex(:),Kvar,MN) ];
    else
      % index must not be logical!
      MN = numel(a.mid);
      magarangeindex = mag(a.range(index));
%       r.err(N+1:N+Kvar,index) = spdiags( magp.*magarangeindex(:) , 0,Kvar,Kvar);
      r.err = [ r.err ; sparse(N-size(r.err,1),MN) ; ...
        sparse(1:Kvar,index,magp.*magarangeindex(:),Kvar,MN) ];
    end
    INTLAB_CONST.AFFARI = N+Kvar;
  end
  
  delta = delta(:);
  if any(delta)
    if select==0                                % all indices
      r.rnderr = r.rnderr + delta';
    else
      r.rnderr(index) = r.rnderr(index) + delta';
    end
  end
