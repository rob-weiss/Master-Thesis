function volume = volume(boxes)
%VOLUME Summary of this function goes here
%   Detailed explanation goes here

volume = 0;

if isintval(boxes)
    for i = 1:size(boxes, 1)
        volume = volume + prod(sup(boxes(i, :)) - inf(boxes(i, :)));
    end
else
    lowerLimits = boxes(1, :);
    upperLimits = boxes(2, :);
    for i = 1:size(boxes, 1)
        volume = prod(upperLimits - lowerLimits);
    end
end

end


