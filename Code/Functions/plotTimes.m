function [] = plotTimes(times, titleName, legendNames)
%PLOTTIMES Summary of this function goes here
%   Detailed explanation goes here

% figure()
% bar(times);
% set(gca, 'XTickLabel', {'PF', 'UPF', 'PFC', 'UPFC', 'PFS', 'UPFS'})
%
% title(titleName);
% xlabel('Filters');
% ylabel('Time in s');

figure()
b = bar(times, 0.4, 'FaceColor', 'flat');

colors = [...
    0.8500    0.3250    0.0980;
    0.9290    0.6940    0.1250;
    0.4940    0.1840    0.5560;
    0.4660    0.6740    0.1880;
    0.3010    0.7450    0.9330];

b.CData = colors;

set(gca, 'XTickLabel', legendNames)

title(titleName);
ylabel('Computation Time / computation time PF');
set(gca, 'YGrid','on')
set(gca, 'YScale', 'log');

yl = ylim;
if yl(1) > 1
    ylim([1, yl(2)]);
end

end

