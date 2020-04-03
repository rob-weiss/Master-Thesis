function [] = plotInitErrors(errors, titleName)
%PLOTTIMES Summary of this function goes here
%   Detailed explanation goes here

figure()
b = bar(errors, 0.4, 'FaceColor', 'flat');

b.CData = [...
    0         0.4470    0.7410;
    0.8500    0.3250    0.0980;
    0.9290    0.6940    0.1250;
    0.4940    0.1840    0.5560;
    0.4660    0.6740    0.1880;
    0.3010    0.7450    0.9330];

set(gca, 'XTickLabel', {'PF', 'UPF', 'PFC', 'UPFC', 'PFS', 'UPFS'})

title(titleName);
ylabel('Error in m');
set(gca, 'YGrid','on')
set(gca, 'YScale', 'log');

% offset = 3;
% yb = cat(1, b.YData);
% xb = bsxfun(@plus, b(1).XData, [b.XOffset]');
% hold on;
% 
% for j = 1:size(errors, 2)
%     text(xb(j), yb(j) + offset, ...
%         ['\scriptsize ', num2str(errors(j), ...
%         '$%0.2f$')], 'rotation', 0, ...
%         'interpreter', 'latex', ...
%         'HorizontalAlignment','center');
% end

end

