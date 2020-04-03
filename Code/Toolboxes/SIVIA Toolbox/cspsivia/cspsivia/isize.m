function s = isize(ix)
% ISIZE Computes the size of an interval box defined as the product of all its sides.
%
%   ix - in interval box (a vector or a cell array)
%
%   Example
%       boxsize = isize([infsup(2,3), infsup(-10,10)]);

    if iscell(ix)
        s = prod(2*cellfun(@rad, ix));
    else
        s = prod(2*rad(ix));
    end
end

