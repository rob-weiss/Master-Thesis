function [initSearchSpace] = narrowSearchSpace(k, ukm1, EulerAngles, distanceMeasurements, pf)
%NARROWSEARCHSPACE Summary of this function goes here
%   Detailed explanation goes here

if pf.plotEstimatesLive
    plotBoxes3D(pf.propagatedBox, 'yellow', 0.1, 0, 'Initial box', pf.resizeLive);
    pause(pf.pauseTime);
end

% Construct constraints
constraints = constructConstraints(distanceMeasurements, pf.landmarks, pf.boundedErrorProp.uncertaintyInt);

nRuns = 0;

if k == 65
    a = 3;
end

while nRuns < 3
    switch pf.boundedErrorAlg
        
        case 'contr'
            
            xInt = pf.propagatedBox;
            lastVolume = volume(pf.propagatedBox);
            ax = gca;
            figTitle = ax.Title.String;
            
            for contraction = 1:pf.boundedErrorProp.maxNContr
                xInt = contract(xInt, constraints, pf);
                ax.Title.String = [figTitle, ' -- contraction ' num2str(contraction)];
                currentVolume = volume(xInt);
                if (lastVolume - currentVolume) < pf.boundedErrorProp.threshold
                    break;
                end
                lastVolume = currentVolume;
            end
            
            ax.Title.String = figTitle;
            
            xIntHull = xInt;
            
        case 'sivia'
            
            [~, xIntHull] = sivia(pf.propagatedBox, constraints, pf);
    end
    
    if ~isempty(xIntHull) && all(~isnan(xIntHull))
        break
    else
        pf.propagatedBox = pf.initialBox;
        nRuns = nRuns + 1;
    end
end

if k == 1
    initSearchSpace = propagateBoxBackwards(xIntHull, ukm1, EulerAngles, pf);
else
    initSearchSpace = xIntHull;
end

if pf.plotEstimatesLive
    plotBoxes3D(initSearchSpace, 'yellow', 0.1, 0, 'Backpropagated box', pf.resizeLive);
    pause(pf.pauseTime);
end

end

