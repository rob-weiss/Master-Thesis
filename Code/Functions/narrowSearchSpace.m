function [initSearchSpace] = narrowSearchSpace(ukm1, EulerAngles, distanceMeasurements, pf)
%NARROWSEARCHSPACE Summary of this function goes here
%   Detailed explanation goes here

if pf.plotEstimatesLive
    plotBoxes3D(pf.initialBox, 'yellow', 0.1, 0, 'Initial box', pf.resizeLive);
    pause(pf.pauseTime);
end

% Construct constraints
constraints = constructConstraints(distanceMeasurements, pf.landmarks, pf.boundedErrorProp.uncertaintyInt);

switch pf.boundedErrorAlg
    
    case 'contr'
        
        xInt = pf.initialBox;
        lastVolume = volume(pf.initialBox);
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
        
        [~, xIntHull] = sivia(pf.initialBox, constraints, pf);
end

initSearchSpace = propagateBoxBackwards(xIntHull, ukm1, EulerAngles, pf);

if pf.plotEstimatesLive
    plotBoxes3D(initSearchSpace, 'yellow', 0.1, 0, 'Backpropagated box', pf.resizeLive);
    pause(pf.pauseTime);
end

end

