function a = setvalueindex(a,index,value)
%SETVALUEINDEX  set values in a(index)
%
%   a = setvalueindex(a,index,value)
%
%  a      structure to be changed, input and output
%  index  values on index set to be changed
%           index=[] means all indices
%  value  -1   a(index) -> -a(index)
%         NaN  a(index) -> NaN
%

% written  04/04/14    S.M. Rump
% modified 04/23/14    S.M. Rump  set/getappdata replaced by global
% modified 05/09/14    S.M. Rump  general value removed
% modified 05/17/14    S.M. Rump  code optimization
% modified 05/21/14    S.M. Rump  All zero sparse: 1-by-1
%

  if isequal(value,-1)
    if isempty(index)
      a.mid = -a.mid;
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(a.err)
        a.err = -a.err;
      end
      a.range = -a.range;
    else
      a.mid(index) = -a.mid(index);
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(a.err)
        a.err(:,index) = -a.err(:,index);
      end
      a.range(index) = -a.range(index);
    end
  elseif isequaln(value,NaN)
    if isempty(index)
      a.mid = NaN(size(a.mid));
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(a.err)
        a.err = [];
      end
      a.range = intval(NaN(size(a.range)));
    else
      index = index(:)';
      a.mid(index) = NaN;
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(a.err)
        a.err(:,index) = 0;
        if nnz(a.err)==0
          a.err = [];
        end
      end
      a.range(index) = intval(NaN);
    end
  else
    error('invalid call of setvalueindex')
  end
    
