function r = subsref(a,s)
%SUBSREF      Implements subscripted references for affari
%

% written  04/04/14     S.M. Rump
% modified 05/21/14     S.M. Rump  All zero sparse: 1-by-1
% modified 05/22/14     S.M. Rump  sparse([])
% modified 12/09/15     S.M. Rump  prod(size) to numel, Matlab 6.5 bug
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  rndold = getround;
  if rndold
    setround(0)
  end

  while 1
    if ~isa(a,'affari')                 % index reference a.x(i) etc.
      r = subsref(a,s(1));
    elseif strcmp(s(1).type,'()')       % index reference a(i)
      if isempty(a.mid)
        r = affari([]);
        if rndold
          setround(rndold)
        end
        return
      end
      r.mid = a.mid(s(1).subs{:});
      rrange = a.range(s(1).subs{:});
      index = reshape(1:numel(a.mid),size(a.mid));
      index = index(s(1).subs{:});
      index = index(:)';
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(a.err)
        r.err = a.err(:,index);
        % cure Matlab bug (used in times, rdivide, ...):
        % find(sparse([],[],[],1,2)) produces correctly 1-by-0 emptymatrix, but
        % find(sparse([],[],[],1,2)) produces []
        if ~nnz(r.err)
          r.err = [];
        end
      else
        r.err = [];
      end
      r.rnderr = a.rnderr(index);
      r.range = rrange;
      r = class(r,'affari');
    elseif strcmp(s(1).type,'.')         % index reference a.err ...
      if strcmp(s(1).subs,'mid')
        r = mid(a.range);
      elseif strcmp(s(1).subs,'err')
        r = a.err;
      elseif strcmp(s(1).subs,'rnderr') 
        r = a.rnderr;
      elseif strcmp(s(1).subs,'range') 
        r = a.range;
      elseif strcmp(s(1).subs,'inf') 
        r = a.range.inf;
      elseif strcmp(s(1).subs,'sup') 
        r = a.range.sup;
      elseif strcmp(s(1).subs,'rad') 
        r = rad(a.range);
      else
        error('invalid subscript reference for affari')
      end
    else
      error('invalid index reference for affari')
    end
    if length(s)==1
      if rndold
        setround(rndold)
      end
      return
    end
    s = s(2:end);
    a = r;
  end
