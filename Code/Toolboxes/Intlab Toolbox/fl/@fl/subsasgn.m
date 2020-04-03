function c = subsasgn(c,s,b)
%SUBSASGN     Implements subscripted assignments for fl-type
%
%   example   C(i,:) = A
%

% written  11/07/13     S.M. Rump
% modified 12/09/15     S.M. Rump  prod(size) to numel
% modified 12/10/15     S.M. Rump  empty assignment, Matlab 6.5 bug
%

  if length(s)>1
    error('multiple indexing for fl-type assignment not allowed')
  end

  if strcmp(s.type,'()')     % subarray assignment c(i,j) = b
  % on entry, l.h.s. c is either of fl-type or, not defined.
  % The latter case is equivalent to isa(c,'fl')=0, because
  % always exist('c')=1.
    if ~isa(b,'fl')
      b = fl(b);
    end
    if ~isa(c,'fl')
      c.value = [];
      c = class(c,'fl');
    end
    if isempty(b.value)
      if ~isempty(c.value(s.subs{:}))
        c.value(s.subs{:}) = [];
      end
    else
      c.value(s.subs{:}) = b.value;
    end
  elseif strcmp(s.type,'.')      % subfield access
    if strcmp(s.subs,'value')
      error('for safety, explicit assignment of C.value=A not allowed; use C=fl(A).')
    elseif strcmp(s.subs,'inf')
      error('for safety, explicit assignment of C.inf=A not allowed.')
    elseif strcmp(s.subs,'sup')
      error('for safety, explicit assignment of C.value=A not allowed.')
    else
      error('invalid call of subsasgn')
    end
  else
    error('invalid call of subsasgn')
  end

    