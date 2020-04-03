function r = affari(x,str)
%AFFARI       Affine arithmetic class constructor
%
%   r = affari(x)
%

% written  04/04/14    S.M. Rump
% modified 04/23/14    S.M. Rump  set/getappdata replaced by global
%

  global INTLAB_CONST
  
  superiorto('intval')

  if nargin==1
    if isa(x,'affari')
      r = x;
    elseif isa(x,'gradient')
      r = gradient(x,'gradientaffari');
    elseif isa(x,'hessian')
      r = hessian(x,'hessianaffari');
    elseif isa(x,'taylor')
      r = taylor(x,'tayloraffari');
    else
      if ~isreal(x)
        error('affari only for real input')
      end
      if isempty(x)
        r.mid = [];
        r.err = [];
        r.rnderr = [];
        r.range = intval([]);
      else
        s = size(x);
        if length(s)>2
          error('maximally two dimensions for affari variables')
        end
        m = s(1);
        n = s(2);
        if isa(x,'intval')
          N = INTLAB_CONST.AFFARI;
          r.mid = mid(x);
          % cure Matlab bug (used in times, rdivide, ...):
          % find(sparse([],[],[],1,2)) produces correctly 1-by-0 emptymatrix, but
          % find(sparse([],[],[],1,2)) produces []
          radx = rad(x);
          index = find(radx(:)~=0);
          if any(index)
            K = length(index);
            r.err = sparse(N+(1:K),index,radx(index),N+K,m*n);
            INTLAB_CONST.AFFARI = N+K;
          else
            r.err = [];
          end
        else
          r.mid = x;
          r.err = [];
        end
        if issparse(x)
          r.rnderr = sparse([],[],[],1,m*n);
        else
          r.rnderr = zeros(1,m*n);
        end
        r.range = intval(x);
      end
      r = class(r,'affari');      
    end
  elseif isequal(str,'init')
    r = class(x,'affari');  
  else
    error('invalid call of constructor affari')
  end
  