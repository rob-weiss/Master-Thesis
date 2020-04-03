function constraints = constructConstraints(distanceMeasurements, landmarks, delta)
%CONSTRUCTCONSTRAINTS Summary of this function goes here
%   Detailed explanation goes here
 
nLandmarks = size(landmarks, 1);
constraints = cell(nLandmarks * 2, 1);

for i = 1:nLandmarks
    
    d = distanceMeasurements(i, 1);
    
    % Construct constraints given by lower and upper bound for each landmark
    c1 = ['sqrt((x - ' num2str(landmarks(i, 1)) ')^2 + (y - ' num2str(landmarks(i, 2)) ...
        ')^2 + (z - ' num2str(landmarks(i, 3)) ')^2) >= ' num2str(d - delta)];
    c2 = ['sqrt((x - ' num2str(landmarks(i, 1)) ')^2 + (y - ' num2str(landmarks(i, 2)) ...
        ')^2 + (z - ' num2str(landmarks(i, 3)) ')^2) <= ' num2str(d + delta)];
    
    constraints{2 * i - 1} = c1;
    constraints{2 * i} = c2;
end

end

