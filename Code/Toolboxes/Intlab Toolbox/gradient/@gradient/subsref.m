function r = subsref(a,s)
%SUBSREF      Implements subscripted references for gradients
%

% written  10/16/98     S.M. Rump
% modified 11/30/98     S.M. Rump  empty indices
% modified 10/12/99     S.M. Rump  index access
% modified 09/14/00     S.M. Rump  g.dx(i,j) fixed
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    aaccess .dx of sparse arrays, .mid allowed
%                                    Matlab sparse bug
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 08/26/12     S.M. Rump  global variables removed
% modified 10/03/12     S.M. Rump  INTLAB_GRADIENT_DERIV_ERROR removed
% modified 10/05/12     S.M. Rump  internal use
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 12/09/15     S.M. Rump  prod(size) to numel(s), Matlab 6.5 bug
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST
 
  rndold = getround;
  if rndold
    setround(0)
  end

  INTLAB_GRADIENT_NUMVAR = INTLAB_CONST.GRADIENT_NUMVAR;

  while 1
    if ~isa(a,'gradient')                % index reference a.x(i) etc.
      r = subsref(a,s(1));
    elseif strcmp(s(1).type,'()')        % index reference a(i)
      r.x = a.x(s(1).subs{:});
      index = reshape(1:numels(a.x),size(a.x));
      index = index(s(1).subs{:});
      r.dx = a.dx(index(:),:);
      r = class(r,'gradient');
    elseif strcmp(s(1).type,'.')         % index reference a.x or a.dx
      if strcmp(s(1).subs,'x')
        r = a.x;
      elseif strcmp(s(1).subs,'dx')
        sizeadx = size(a.x);
        if length(sizeadx)==2 & sizeadx(2)==1
          sizeadx = sizeadx(1);
        end
        if issparse(a.dx) & ( length(sizeadx)>1 )
          error('access of .dx for sparse gradient with more than one column, see gradientinit')
        end
        r = reshape(a.dx,[sizeadx INTLAB_GRADIENT_NUMVAR]);
      elseif strcmp(s(1).subs,'ddx')    % for internal use
        r = a.dx;
      elseif strcmp(s(1).subs,'mid')
        r = mid(a);
      else
        error('invalid subscript reference for gradient')
      end
    else
      error('invalid index reference for gradient')
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
