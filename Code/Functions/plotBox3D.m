function handles = plotBox3D(box, alpha, color, legendName)
%PLOTBOX3D Summary of this function goes here
%   Detailed explanation goes here

origins = inf(box);
widths = sup(box) - origins;
handles = plotcube(widths, origins, alpha, color);

if (nargin > 3) && ~isempty(legendName)
    % Add legend entry
    handles(end+1) = patch(0, 0, 0, color, 'DisplayName', legendName);
end

end

