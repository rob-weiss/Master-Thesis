function [] = plotZeroWeights(t, zeroWeights, legendNames, titleString)
%PLOTZEROWEIGHTS Summary of this function goes here
%   Detailed explanation goes here

if all(zeroWeights == 0)
        return;
end
    
markerSize = 10;

figure()
hold on
for i = 1:size(zeroWeights, 1)
    
    if sum(zeroWeights(i, :)) == 0
        continue;
    end
    
    stem(t, zeroWeights(i, :), 'filled', 'DisplayName', legendNames(i), 'MarkerSize', markerSize);
    
    markerSize = markerSize - 2;
end
hold off

set(gca, 'YGrid','on')
set(gca, 'YScale', 'log');


title(titleString);
xlabel('Time in s');
ylabel('Number of particles with weight equal to 0');
legend('-DynamicLegend');

end

