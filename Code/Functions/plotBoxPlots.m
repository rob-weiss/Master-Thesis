function [] = plotBoxPlots(errors, titleName)
%PLOTBOXPLOTS Summary of this function goes here
%   Detailed explanation goes here

figure()
boxplot(errors, 'Notch', 'on', 'Jitter',0.5, 'Labels', {'PF', 'UPF', 'PFC', 'UPFC', 'PFS', 'UPFS', 'PFCP', 'PFSP'});

set(gca, 'YGrid','on')
set(gca, 'YScale', 'log');
%xlabel('Filters')
ylabel('Error in m')
title(titleName);

end

