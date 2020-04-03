function c = subsasgn(c,s,b)
%SUBSASGN     Implements subscripted assignments for intervals
%
%   example   c(i,:) = b
%

% written  10/16/98     S.M. Rump
% modified 11/23/98     S.M. Rump  delete components by a(i,j) = []
% modified 07/01/99     S.M. Rump  multi-dimensional arrays, complex=0
% modified 09/02/00     S.M. Rump  real-complex assignment
% modified 09/28/01     S.M. Rump  empty left or right hand side
% modified 09/29/02     S.M. Rump  sparse parameters
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    remove check for 'double'
%                                    Matlab sparse bug
%                                    complex assignment a(n,n)=.. for huge n
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 08/26/12     S.M. Rump  global variables removed
% modified 10/13/12     S.M. Rump  INTLAB_INTVAL_STDFCTS
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/15/14     S.M. Rump  code optimization
% modified 12/09/15     S.M. Rump  prod(size) to numel
% modified 12/10/15     S.M. Rump  empty assignment, Matlab 6.5 bug
% modified 02/10/16     S.M. Rump  code optimization
%

  global INTLAB_CONST

  if length(s)>1
    error('multiple indexing for interval assignment not allowed')
  end

  if strcmp(s.type,'()')     % subarray assignment c(i,j) = b
  % on entry, l.h.s. c is either of type interval or, not defined.
  % The latter case is equivalent to isa(c,'intval')=0, because
  % always exist('c')=1.
    if ~isa(b,'intval')
      b = intval(b);
    end
    if ~isa(c,'intval')
      c = INTLAB_CONST.COMPLEXINTERVAL;
      c.complex = b.complex;
      c.mid = [];
      c.rad = [];
    end
    INTLAB_STDFCTS_RCASSIGN = INTLAB_CONST.STDFCTS_RCASSIGN;
    if INTLAB_STDFCTS_RCASSIGN
      if c.complex && ~b.complex
        b = cintval(b);
      end
      if ~c.complex && b.complex
        if INTLAB_STDFCTS_RCASSIGN==1
          warning('**** Subscripted assignment  real(...) = complex')
        else
          error('**** Subscripted assignment  real(...) = complex')
        end
        c = cintval(c);
      end
    else
      if b.complex~=c.complex
        if b.complex
          c = cintval(c);
        else
          b = cintval(b);
        end
      end
    end
    if c.complex
      if isequal(c.rad,0)
        if issparse(c.mid)
          c.rad = sparse([],[],[],size(c.mid,1),size(c.mid,2));
        else
          c.rad = zeros(size(c.mid));
        end
      end
      if isempty(b.mid)
        if ~isempty(c.mid(s.subs{:}))
          c.mid(s.subs{:}) = [];
          c.rad(s.subs{:}) = [];
        end
      else
        c.mid(s.subs{:}) = b.mid;
        c.rad(s.subs{:}) = b.rad;
      end
      if ~any(c.rad)
        c.rad = 0;
      end
    else
      if isempty(b.inf)
        if ~isempty(c.inf(s.subs{:}))
          c.inf(s.subs{:}) = [];
          c.sup(s.subs{:}) = [];
        end
      else
        c.inf(s.subs{:}) = b.inf;
        c.sup(s.subs{:}) = b.sup;
      end
    end
  elseif strcmp(s.type,'.')      % subfield access
    if strcmp(s.subs,'inf')
      error('for safety, explicit assignment of x.inf=y not allowed; use x=infsup(y,sup(x))')
    elseif strcmp(s.subs,'sup')
      error('for safety, explicit assignment of x.sup=y not allowed; use x=infsup(inf(x),y)')
    elseif strcmp(s.subs,'mid')
      error('for safety, explicit assignment of x.mid=y not allowed; use x=midrad(y,rad(x))')
    elseif strcmp(s.subs,'rad')
      error('for safety, explicit assignment of x.rad=y not allowed; use x=midrad(mid(x),y)')
    else
      error('invalid call of subsasgn')
    end
  else
    error('invalid call of subsasgn')
  end

    