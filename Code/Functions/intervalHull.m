function intervalHull = intervalHull(boxes)
%INTERVALHULL Summary of this function goes here
%   Detailed explanation goes here

intervalHull = boxes(1, :);

for i = 2:size(boxes, 1)
    
    intervalHull = hull(intervalHull, boxes(i, :));
    
end

end

