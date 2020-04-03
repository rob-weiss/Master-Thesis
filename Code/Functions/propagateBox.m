function xInt = propagateBox(k, box, velocityInputs, eulerAnglesYPRInputs, prop)
%PROPAGATEBOX Summary of this function goes here
%   Detailed explanation goes here

% Propagate
sigmaW = [prop.sigmaVelocity * ones(1,3), prop.sigmaEulerAngles * ones(1,3)]';

noise = infsup(-prop.uncertainty * sigmaW, prop.uncertainty * sigmaW);

velocityInt = velocityInputs ...
    + infsup(-prop.uncertainty * prop.sigmaVelocity, prop.uncertainty * prop.sigmaVelocity);
eulerAnglesInt = eulerAnglesYPRInputs ...
    + infsup(-prop.uncertainty * prop.sigmaEulerAngles, prop.uncertainty * prop.sigmaEulerAngles);
xInt = phiFun(k, box', velocityInt, noise, prop.samplePeriod, eulerAnglesInt)';

end

