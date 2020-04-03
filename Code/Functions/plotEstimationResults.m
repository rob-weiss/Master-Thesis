function [] = plotEstimationResults(xh)
%PLOTESTIMATIONRESULTS Plot the results of the estimation process

hold on

% Plot 3D trajectory
plot3(xh(1, :), xh(2, :), xh(3, :), 'Color', [0.8500    0.3250    0.0980], ...
    'LineWidth', 1.5, 'DisplayName', 'Estimated trajectory');

end

