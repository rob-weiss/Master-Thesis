function xInt = propagateBox(k, box, velocityInputs, eulerAnglesYPRInputs, prop)
%PROPAGATEBOX Summary of this function goes here
%   Detailed explanation goes here

% Propagate
sigmaW = [prop.sigmaVelocity * ones(1,3), prop.sigmaEulerAngles * ones(1,3)]';

noise = infsup(-prop.uncertaintyInterval * sigmaW, prop.uncertaintyInterval * sigmaW);

velocityInt = velocityInputs ...
    + infsup(-prop.uncertaintyInterval * prop.sigmaVelocity, prop.uncertaintyInterval * prop.sigmaVelocity);
eulerAnglesInt = eulerAnglesYPRInputs ...
    + infsup(-prop.uncertaintyInterval * prop.sigmaEulerAngles, prop.uncertaintyInterval * prop.sigmaEulerAngles);
xInt = phiFun(k, box', velocityInt, noise, prop.samplePeriod, eulerAnglesInt)';

end

