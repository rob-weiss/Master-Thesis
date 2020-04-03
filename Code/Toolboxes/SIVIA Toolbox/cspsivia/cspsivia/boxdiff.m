function boxes = boxdiff(ix, iy)
% BOXDIFF Return the difference of two interval boxes as a list of boxes.
%
%  In:
%      ix - an interval box
%      iy - an interval box, subset of ix
%  Out:
%      boxes - a list of 2*(dimension of ix) boxes represeting the difference ix - iy
%
%  Example
%      d = boxdiff([infsup(-10, 10), infsup(-10, 10)], [infsup(-2, 2), infsup(3, 4)]);
%

    if any(size(ix) ~= size(iy))
        error('boxdiff:IncorrectInput', 'Interval boxes cannot have different dimension.')
    elseif ~all(in(iy, ix))
        error('boxdiff:IncorrectInput', 'The second argument has to be a subset of the first argument.')
    end
    
    boxsize = isize(ix);    
    dim = size(ix,2);
    boxes = intval(zeros(2*dim, dim));
    counter = 0;
    
    for i=1:dim
       % calculate two boxes for the difference in each dimension
       left = ix; 
       left(i) = infsup(inf(ix(i)), inf(iy(i)));
       right = ix;
       right(i) = infsup(sup(iy(i)), sup(ix(i)));
       % cut the box ix for the next iteration
       ix(i) = infsup(inf(iy(i)), sup(iy(i)));
       if isize(left) > 0 || (boxsize == 0 && any(left ~= ix))
           counter = counter + 1;
           boxes(counter, :) = left;
       end
       if isize(right) > 0 || (boxsize == 0 && any(right ~= ix))
           counter = counter + 1;
           boxes(counter, :) = right;
       end
    end
    boxes = boxes(1:counter, :);
end

