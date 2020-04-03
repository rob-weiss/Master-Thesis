function [xkm1, wkm1] = drawSamples(nSamples, nx, initSearchSpace)
%DRAWSAMPLES Summary of this function goes here
%   Detailed explanation goes here

xkm1 = zeros(nx, nSamples);
    for i = 1:nSamples
        xkm1(:, i) = unifrnd(inf(initSearchSpace), sup(initSearchSpace));
    end
    
    wkm1 = 1/nSamples * ones(1, nSamples); % All particles get the same weight
    
end

