function [xInt, xIntHull] = sivia(xInt, constraints, pf)
%SIVIA Summary of this function goes here
%   Detailed explanation goes here

% Run SIVIA with forward-backward contractor
[iS, ~, iB] = cspsivia(constraints, xInt, pf.boundedErrorProp.epsilon, pf.boundedErrorProp.contrType);

xInt = [iS; iB];

% Compute interval hull
if ~isempty(xInt)
    xIntHull = intervalHull(xInt);
else
    xIntHull = [];
    return
end

% Plot results
if pf.plotEstimatesLive
    
    if ~isempty(iS)
        plotBoxes3D(iS, 'red', 0.7, 0, 'Inner approximation', pf.resizeLive);
        pause(pf.pauseTime);
    end
    if ~isempty(iS) && ~isempty(iB)
        plotBoxes3D([iS; iB], 'yellow', 0.4, 0, 'Outer approximation', pf.resizeLive);
        pause(pf.pauseTime);
    else
        if ~isempty(iB)
            plotBoxes3D([iS; iB], 'yellow', 0.4, 0, 'Outer approximation', pf.resizeLive);
            pause(pf.pauseTime);
        end
    end
    if ~isempty(xIntHull)
        plotBoxes3D(xIntHull, 'green', 0.1, 0, 'Interval hull', pf.resizeLive);
        pause(pf.pauseTime);
    end
end

end

