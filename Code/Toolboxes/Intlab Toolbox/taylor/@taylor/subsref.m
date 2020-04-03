function r = subsref(a,s)
%SUBSREF      Implements subscripted references for Taylor
%

% written  05/21/09     S.M. Rump
% modified 07/07/10     S.M. Rump  treatment of "end"-index
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 04/27/14     S.M. Rump  access a.t
% modified 05/18/14     S.M. Rump  code optimization
% modified 08/04/14     S.M. Rump  access .tt for internal use
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST
  
  rndold = getround;
  if rndold
    setround(0)
  end

  INTLAB_TAYLOR_ORDER = INTLAB_CONST.TAYLOR_ORDER;

  while 1
    if ~isa(a,'taylor')                  % index reference a.x(i) etc.
      r = subsref(a,s(1));
    elseif strcmp(s(1).type,'()')        % index reference a(i)
      INTLAB_CONST.TAYLOR_END = 0;       % reset INTLAB variable
      index = reshape(1:prod(a.size),a.size);
      index = index(s(1).subs{:});
      r.size = size(index);
      r.t = a.t(:,index(:));
      r = class(r,'taylor');
    elseif strcmp(s(1).type,'{}')        % Taylor coefficient reference a{i}
      INTLAB_TAYLOR_END = INTLAB_CONST.TAYLOR_END;
      if INTLAB_TAYLOR_END
        INTLAB_CONST.TAYLOR_END = 0;     % reset INTLAB variable
        error('"end" cannot be used in an index expression when accessing derivatives by {}')
      end
      INTLAB_CONST.TAYLOR_END = 0;       % reset INTLAB variable
      index = ( 1:INTLAB_TAYLOR_ORDER+1 );
      index = index(s(1).subs{:}+1);
      r = a.t(index,:).';
    elseif strcmp(s(1).type,'.')         % index reference a.t
      if strcmp(s(1).subs,'t')
        if isempty(a)
          r = [];
        else
          newsize = [a.size size(a.t,1)];
          if newsize(2)==1
            newsize(2) = [];
          end
          if issparse(a.t) && ( length(newsize)>2 )
            r = reshape(full(a.t).',newsize);
          else
            r = reshape(a.t.',newsize);
          end
        end
      elseif strcmp(s(1).subs,'tt')     % internal use
        r = a.t;
      elseif strcmp(s(1).subs,'mid')
        r = mid(a);
      else
        error('invalid subscript reference for taylor')
      end
    else
      error('invalid index reference for taylor')
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
