function a = cintval(a,index)
%CINTVAL      Type cast to complex interval
%
%  c = cintval(a)
%

% written  10/16/98     S.M. Rump
% modified 11/30/98     S.M. Rump  improved speed
% modified 09/02/00     S.M. Rump  same as tocmplx, rounding preserved
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/20/05     S.M. Rump  faster check for rounding to nearest
% modified 12/03/05     S.M. Rump  sparse input
% modified 12/04/05     S.M. Rump  tocmplx replaced by cintval
% modified 09/06/15     S.M. Rump  infinite intervals, second parameter
% modified 12/09/15     S.M. Rump  mid/rad
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
%

  if ~a.complex
    if nargin==2                          % take real interval as imag part
      amid = mid(a);
      a.rad = rad(a);
      a.complex = 1;
      a.mid = amid;
      a.inf = [];
      a.sup = [];
      return
    end
    if isequal(a.inf,a.sup)
      a.complex = 1;
      a.mid = a.inf;
      a.rad = 0;
    else
      if issparse(a.inf)                  % sparse input
        [i,j,s] = find(a);
        [m,n] = size(a.inf);
        a = sparse(i,j,cintval(full(s)),m,n);
        return
      else                                % full input
        index = ( a.inf==a.sup );
        anyindex = any(index(:));
        if anyindex
          amid = a.inf;
          arad = zeros(size(a.inf));
        end
        rndold = getround;
        if ~anyindex
          setround(1)
          amid = mid(a);
          arad = rad(a);
        else
          index = ~index;
          setround(1)
          ainf_ = a.inf(index);
          asup_ = a.sup(index);
          % cure Matlab     
          % amid(index) = mid(a(index));
          % arad(index) = rad(a(index));
          amid(index) = 0.5*(ainf_+asup_);
          arad(index) = 0.5*(asup_-ainf_);
        end
        a.complex = 1;
        a.mid = amid;
        a.rad = arad;
        setround(rndold)                  % set rounding to previous value
      end
    end
    a.inf = [];
    a.sup = [];
  end
