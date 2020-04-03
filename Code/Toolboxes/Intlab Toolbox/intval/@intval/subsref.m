function c = subsref(a,s)
%SUBSREF      Implements subscripted references for intervals
%
%   example   c = a(:,3:5)
%

% written  10/16/98     S.M. Rump
% modified 11/23/98     S.M. Rump  improved speed
% modified 09/14/00     S.M. Rump  a.inf(i) fixed
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    Matlab sparse bug
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 12/09/15     S.M. Rump  prod(size) to numel, Matlab 6.5 bug
% modified 02/08/16     F. Buenger code optimization  

  global INTLAB_CONST
  isintval_a = true;
  len_s = length(s);
  
  while len_s
    if isintval_a
      if strcmp(s(1).type,'()')     % index reference a(i,j)
        if a.complex                    % a is complex
          c = INTLAB_CONST.COMPLEXINTERVAL;
          c.mid = a.mid(s(1).subs{:});
          % careful: just 0 is not sparse and may cause tremendous memory need
          if isequal(a.rad,0)
            c.rad = a.rad;
          else
            c.rad = a.rad(s(1).subs{:});
          end
        else                          % a is real
          c = INTLAB_CONST.REALINTERVAL;
          c.inf = a.inf(s(1).subs{:});
          c.sup = a.sup(s(1).subs{:});
        end
      elseif strcmp(s(1).type,'.')     % subfield access
        if strcmp(s(1).subs,'inf')
          if a.complex
            c = inf(a);
          else
            c = a.inf;
          end
        elseif strcmp(s(1).subs,'sup')
          if a.complex
            c = sup(a);
          else
            c = a.sup;
          end
        elseif strcmp(s(1).subs,'mid')
          if a.complex
            c = a.mid;
          else
            c = mid(a);
          end
        elseif strcmp(s(1).subs,'rad')
          if a.complex
            c = a.rad;
          else
            c = rad(a);
          end
        else
          error('invalid subscript reference for intval')
        end
      else
        error('invalid index reference for intval')
      end
    else  % for a.inf(i) etc.
      c = subsref(a,s(1));
    end
    len_s = len_s-1;
    
    if len_s
      s = s(2:end);
      a = c;
      isintval_a = isa(a,'intval');
    end
  end
