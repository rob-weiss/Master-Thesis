function [] = plotVolumes(t, volumes, legendNames)
%PLOTVOLUMES Summary of this function goes here
%   Detailed explanation goes here

figure()

hold on

for i = 1:size(volumes, 1)
    
    if sum(volumes(i, :)) ~= 0
       plot(t, volumes(i, :), 'DisplayName', legendNames(i));
    end
    
    
end

hold off

set(gca, 'YScale', 'log');
title('Volumes vs. time');
legend('-DynamicLegend');

end

