function [landmarks, landmarksXYZ, lowerLimits, upperLimits] = computeLandmarkPositions(position, lm)
%COMPUTELANDMARKPOSITIONS Compute landmark positions according to the
%parameters in structure lm

% lm.landmarksPerAxis:  Number of landmarks in [x, y, z]-direction. This creates an array
%                       of x * y * z landmarks, equally spaced along the respective
%                       coordinate axes between the min and max points specified below
% lm.alpha              Scaling parameter alpha >= 0 that controls the spread of the
%                       landmarks:
%                       For alpha = 0 all landmarks will be located in the same spot in
%                       the middle of the trajectory.
%                       For alpha = 1 the landmarks will be located between the respective
%                       min and max values of the trajectory in each coordinate direction.
%                       For alpha > 1 the landmarks will be spread beyond the respective
%                       min and max values of the trajectory in each coordinate direction.
% lm.muX = 0;           mean in x-direction
% lm.sigmaX = 5;        standard deviation in x-direction
% lm.muY = 0;           mean in y-direction
% lm.sigmaY = 5;        standard deviation in y-direction
% lm.muZ = -20;         mean in z-direction
% lm.sigmaZ = 5;        standard deviation in z-direction
%                       Mean mu and standard deviation sigma for each coordinate direction
%                       which determine the final landmark positions.
%                       mu = 0 and sigmaLandmarks = 0 ensure exact placement according to
%                       the specifications above. mu != serves as an offset to the
%                       positions and sigma > 0 varies the positions of the landmarks
%                       randomly.

[lowerLimits, upperLimits] = computeLimits3D(position, lm.alpha);
lowerLimits = [-250, -250, -250];
upperLimits = [250, 250, 0];

% Recompute width of scaled area
width = upperLimits - lowerLimits;

% Compute distance between two landmarks
stepX = width(1) / (lm.landmarksPerAxis(1) - 1 + 1E-3); % avoids INF for only 1 landmark per dimension
stepY = width(2) / (lm.landmarksPerAxis(2) - 1 + 1E-3);
stepZ = width(3) / (lm.landmarksPerAxis(3) - 1 + 1E-3);

% Compute number of landmarks
n = prod(lm.landmarksPerAxis);

% Initialise n x 3 matrix that stores the landmark positions
landmarks = zeros(n, 3);

% Initialise cell array that stores the landmarks as they are placed in
% the environment. For example, landmarksXYZ{1, 2, 3} returns the 1st
% landmark in x-direction, the 2nd in y-direction and the 3rd in
% z-direction
landmarksXYZ = cell(lm.landmarksPerAxis(1), lm.landmarksPerAxis(2), lm.landmarksPerAxis(3));

n = 1;
for iz = 0:lm.landmarksPerAxis(3)-1
    for iy = 0:lm.landmarksPerAxis(2)-1
        for ix = 0:lm.landmarksPerAxis(1 )-1
            landmarksXYZ{ix + 1, iy + 1, iz + 1} = ...
                [lowerLimits(1) + ix * stepX, ...
                lowerLimits(2) + iy * stepY, ...
                lowerLimits(3) + iz * stepZ] ...
                + [normrnd(lm.muX, lm.sigmaX, 1, 1), ...
                normrnd(lm.muY, lm.sigmaY, 1, 1), ...
                normrnd(lm.muZ, lm.sigmaZ, 1, 1)];
            landmarks(n, :) = landmarksXYZ{ix + 1, iy + 1, iz + 1};
            n = n + 1;
        end
    end
end

% lowerLimits = [ ...
%     min(lowerLimits(1), lowerLimits(1) + lm.muX), ...
%     min(lowerLimits(2), lowerLimits(2) + lm.muY), ...
%     min(lowerLimits(3), lowerLimits(3) + lm.muZ)];
% upperLimits = [ ...
%     max(upperLimits(1), upperLimits(1) + lm.muX), ...
%     max(upperLimits(2), upperLimits(2) + lm.muY), ...
%     max(upperLimits(3), upperLimits(3) + lm.muZ)];

end

