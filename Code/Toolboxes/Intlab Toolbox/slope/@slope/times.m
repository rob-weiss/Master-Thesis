function u = times(a,b)
%TIMES        Slope multiplication  a .* b
%

% written  12/06/98     S.M. Rump
% modified 09/28/01     S.M. Rump  matrices and multi-dimensional arrays
% modified 04/04/04     S.M. Rump  set round to nearest for safety
%                                    improved performance
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 09/28/08     S.M. Rump  check for rounding to nearest improved
% modified 08/26/12     S.M. Rump  global variables removed
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  global INTLAB_CONST

  rndold = getround;
  if rndold
    setround(0)
  end

  INTLAB_SLOPE = INTLAB_CONST.SLOPE;

  if ~isa(a,'slope')
    a = slope(a);
  end
  if ~isa(b,'slope')
    b = slope(b);
  end

  na = size(a.r.inf,1);
  nb = size(b.r.inf,1);

  if ( na==1 ) && ( nb~=1 )
    a.r = a.r(ones(nb,1),:);
    a.s = a.s(ones(nb,1),:);
    u.size = b.size;
  elseif ( na~=1 ) && ( nb==1 )
    b.r = b.r(ones(na,1),:);
    b.s = b.s(ones(na,1),:);
    u.size = a.size;
  else
    if ~isequal(a.size,b.size)
      error('dimensions not compatible for minus')
    end
    u.size = a.size;
  end

  u.r = a.r .* b.r;
  indexc = 1:INTLAB_SLOPE.NUMVAR;
  indexr = 2:INTLAB_SLOPE.NUMVAR+1;
  u.s = intersect( a.r(:,indexr) .* b.s + b.r(:,indexc) .* a.s , ...
                   b.r(:,indexr) .* a.s + a.r(:,indexc) .* b.s );

  u.r = rangeimprove(u);

  u = class(u,'slope');
  
  setround(rndold)

