function r = intersectNaN(r,Y)
%INTERSECTNAN intersect(affarirange(r),Y) with special care for NaNs
%
%   r = intersectNaN(r,Y)
%
%Indices r(index) are set to +/-inf if isnan(r) but ~isnan(Y).
%Radius inf is put into .rnderr, no care about extra error term.
%

% written  04/19/14  S.M. Rump
% modified 05/21/14  S.M. Rump  All zero sparse: 1-by-1
%

  R = affarirange(r);
  r.range = intersect( R , Y );
  index = isnan(R) & ( ~isnan(Y) );
  if any(index(:))
    r.mid(index) = mid(Y(index));
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if nnz(r.err)
      r.err(:,index) = 0;
      if ~any(r.err(:))
        r.err = [];
      end    
    end
    r.rnderr(index) = rad(Y(index));
    r.range(index) = Y(index);
  end
  