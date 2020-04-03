function result = satisfiesConstraints(k, particle, measurement, landmarks, uncertaintyInterval)
%SATISFIESCONSTRAINTS Summary of this function goes here
%   Detailed explanation goes here

result = false;

predictedMeasurement = hFun(k, particle, 0, landmarks);

if (all(predictedMeasurement < (measurement + uncertaintyInterval))) && ...
    (all(predictedMeasurement > (measurement - uncertaintyInterval)))
    result = true;
end
    
end

