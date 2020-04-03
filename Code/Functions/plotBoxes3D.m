function [] = plotBoxes3D(boxes, color, alpha, nolines, legendName, resizeLive)
% PLOTBOXES

persistent handles;

for i = 1:length(handles)
    delete(handles(i));
end

% get fulldimensional boxes
iSlog = false(1, size(boxes, 1));
for i=1:size(boxes, 1)
    if all(rad(boxes(i, :)) > 0)
        iSlog(i) = true;
    end
end
boxes = boxes(iSlog, :);

if (~isempty(boxes)) % plot boxes
    for i = 1:size(boxes, 1)-1
        handle = plotBox3D(boxes(i, :), alpha, color);
        handles = [handles; handle];
    end
    handle = plotBox3D(boxes(end, :), alpha, color, legendName);
    handles = [handles; handle];
end

if nolines % display plot without borders
    set(findobj(boxes, 'type', 'patch'),'LineStyle', 'none');
end

xLimits = xlim;
yLimits = ylim;
zLimits = zlim;

axesLimOffset = 4;

minX = min(inf(boxes(:, 1))) - axesLimOffset;
maxX = max(sup(boxes(:, 1))) + axesLimOffset;
minY = min(inf(boxes(:, 2))) - axesLimOffset;
maxY = max(sup(boxes(:, 2))) + axesLimOffset;
minZ = min(inf(boxes(:, 3))) - axesLimOffset;
maxZ = max(sup(boxes(:, 3))) + axesLimOffset;

allAxesInFigure = findall(gcf,'type','axes');

if minX < xLimits(1)
    xLimits = [minX xLimits(2)];
end

if maxX > xLimits(2)
    xLimits = [xLimits(1) maxX];
end

if minY < yLimits(1)
    yLimits = [minY yLimits(2)];
end

if maxY > yLimits(2)
    yLimits = [yLimits(1) maxY];
end

if minZ < zLimits(1)
    zLimits = [minZ zLimits(2)];
end

if maxZ > zLimits(2)
    zLimits = [zLimits(1) maxZ];
end

if resizeLive
    xLimits = [minX maxX];
    yLimits = [minY maxY];
    zLimits = [minZ maxZ];
end

for axIndex = 1:length(allAxesInFigure)
    axis(allAxesInFigure(axIndex), [xLimits(1) xLimits(2) yLimits(1) yLimits(2) zLimits(1) zLimits(2)])
    view(allAxesInFigure(axIndex), 3)
end

end

