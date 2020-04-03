function c = subsref(a,s)
%SUBSREF      Implements subscripted references for fl-type
%
%   example   C = A(:,3:5)
%

% written  11/07/13     S.M. Rump
% modified 12/09/15     S.M. Rump  prod(size) to numel, Matlab 6.5 bug
%

  while 1
    if ~isa(a,'fl')                   % for a.inf(i) etc.
      c = subsref(a,s(1));
    elseif strcmp(s(1).type,'()')     % index reference a(i,j)
      c.value = a.value(s(1).subs{:});
      c = class(c,'fl');
    elseif strcmp(s(1).type,'.')     % subfield access
      if strcmp(s(1).subs,'value')
        c = a.value;
      elseif strcmp(s(1).subs,'inf')
        if isa(a.value,'intval')
          c = a.value.inf;
        else
          c = a.value;
        end
      elseif strcmp(s(1).subs,'sup')
        if isa(a.value,'intval')
          c = a.value.sup;
        else
          c = a.value;
        end
      else
        error('invalid subscript reference for intval')
      end
    else
      error('invalid index reference for intval')
    end
    if length(s)==1
      return
    end
    s = s(2:end);
    a = c;
  end
