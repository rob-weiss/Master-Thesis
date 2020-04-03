function xIntkm1 = propagateBoxBackwards(box, velocityInputs, eulerAnglesYPRInputs, prop)
%PROPAGATEBOX Summary of this function goes here
%   Detailed explanation goes here

uncertaintyIntVel = prop.sigmaVelocity * ones(1,3)';
uncertaintyIntAng = prop.sigmaEulerAngles * ones(1,3)';

velocityInt    = velocityInputs + infsup(-uncertaintyIntVel, uncertaintyIntVel);
eulerAnglesInt = eulerAnglesYPRInputs + infsup(-uncertaintyIntAng, uncertaintyIntAng);

xIntkm1 = (box' - rotationMatrix(eulerAnglesInt) * velocityInt * prop.samplePeriod)';

end

