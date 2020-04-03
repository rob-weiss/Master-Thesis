function [lowerLimits, upperLimits] = computeLimits3D(position, alpha)
%COMPUTELIMITS3D Comutes the upper and lower limits of the volume traversed
% by the trajectory given by the 'position' matrix, scaled by the parameter
% 0 < alpha < INF, where alpha = 1 results in no scaling and alpha > 1
% spreads the limits farther apart.

pos_x = position(1, :);
pos_y = position(2, :);
pos_z = position(3, :);

% Compute width of the area that is traversed by the robot
widthX = max(pos_x) - min(pos_x);
widthY = max(pos_y) - min(pos_y);
widthZ = max(pos_z) - min(pos_z);

% Compute midpoint of the area that is traversed by the robot
midpointX = (max(pos_x) + min(pos_x)) / 2;
midpointY = (max(pos_y) + min(pos_y)) / 2;
midpointZ = (max(pos_z) + min(pos_z)) / 2;

% Compute min and max values of the area where the landmarks are
% positioned
minX = midpointX - alpha * widthX / 2;
maxX = midpointX + alpha * widthX / 2;
minY = midpointY - alpha * widthY / 2;
maxY = midpointY + alpha * widthY / 2;
minZ = midpointZ - alpha * widthZ / 2;
maxZ = midpointZ + alpha * widthZ / 2;

lowerLimits = [minX, minY, minZ];
upperLimits = [maxX, maxY, maxZ];

end

