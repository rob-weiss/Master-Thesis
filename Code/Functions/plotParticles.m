function [] = plotParticles(particles, weights, text, pauseTime, resizeLive)
%PLOTPARTICLES Plot a set of particles

persistent handles;

if nargin < 2
    np = size(particles, 2);
    weights = 1 / np * ones(1, np);
end

delete(handles)

hold on;
% sizes = 50 * (weights ~= 0) + 200 * (weights == 0);
handles = scatter3(particles(1, weights ~= 0),  particles(2, weights ~= 0),  particles(3, weights ~= 0), ...
    50, weights(weights ~= 0), 'filled', 'MarkerEdgeColor', 'k', 'DisplayName', 'Weighted particles');

handles = [handles, scatter3(particles(1, weights == 0),  particles(2, weights == 0),  particles(3, weights == 0), ...
    50, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'k', 'DisplayName', 'Weight = 0')];

hold off;

xLimits = xlim;
yLimits = ylim;
zLimits = zlim;

axesLimOffset = 4;

minX = min(particles(1,:)) - axesLimOffset;
maxX = max(particles(1,:)) + axesLimOffset;
minY = min(particles(2,:)) - axesLimOffset;
maxY = max(particles(2,:)) + axesLimOffset;
minZ = min(particles(3,:)) - axesLimOffset;
maxZ = max(particles(3,:)) + axesLimOffset;

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

title(text);
pause(pauseTime)

end

