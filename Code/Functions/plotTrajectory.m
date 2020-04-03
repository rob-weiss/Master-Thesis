function ax1 = plotTrajectory(landmarks, positions, plotTitle, plotFullscreen, kidnapIndices)
%PLOTTRAJECTORY Plot 3D trajectory and landmarks

if nargin < 5
    kidnapIndices      = [];
end

if nargin < 4
    plotFullscreen = false;
end

nLandmarks = size(landmarks, 1);

figure();
if plotFullscreen
    set(gcf, 'WindowStyle','normal', 'Position', get(0, 'Screensize'));
end

ax1 = axes;

% Plot 3D trajectory
if ~isempty(kidnapIndices)
    kidnapFirstSample = kidnapIndices(1);
    kidnapLastSample = kidnapIndices(2);
    
    hold on;
    plot3(positions(1, kidnapLastSample+1:end), ...
        positions(2, kidnapLastSample+1:end), ...
        positions(3, kidnapLastSample+1:end), 'color', ...
        [0    0.4470    0.7410], 'LineWidth', 2, 'DisplayName', 'Trajectory');
    
    plot3(positions(1, kidnapFirstSample:kidnapLastSample), ...
        positions(2, kidnapFirstSample:kidnapLastSample), ...
        positions(3, kidnapFirstSample:kidnapLastSample), ':', 'color', ...
        [0.9290    0.6940    0.1250], 'LineWidth', 2, 'DisplayName', 'Kidnapping');
    
    plot3(positions(1, 1:kidnapFirstSample-1), ...
        positions(2, 1:kidnapFirstSample-1), ...
        positions(3, 1:kidnapFirstSample-1), 'color', ...
        [0    0.4470    0.7410], 'LineWidth', 2, 'HandleVisibility', 'off');  
    hold off;
else
    plot3(positions(1, :), positions(2, :), positions(3, :), 'color', ...
        [0    0.4470    0.7410], 'LineWidth', 2, 'DisplayName', 'Trajectory');
end

grid on
legend show
legend('Location','northeast');

if ~isempty(landmarks)
    
    hold on
    % Plot landmarks
    scatter3(landmarks(:,1),  landmarks(:,2),  landmarks(:,3), 200, ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'green', 'DisplayName', 'Landmarks');
    
    % Plot auxiliary lines
    xlim([-300, 300]);
    ylim([-300, 300]);
    zlim([-300, 0]);
    xl = xlim;
    yl = ylim;
    zl = zlim;
    for n = 1:nLandmarks
        landmark = landmarks(n, :);
        line([landmark(1) landmark(1)], [landmark(2) landmark(2)], ...
            [landmark(3) zl(1)], 'Color', [0.5 0.5 0.5], 'LineStyle','--', 'HandleVisibility', 'off')
        line([landmark(1) landmark(1)], [landmark(2) yl(2)], ...
            [landmark(3) landmark(3)], 'Color', [0.5 0.5 0.5], 'LineStyle','--', 'HandleVisibility', 'off')
        line([landmark(1) xl(2)], [landmark(2) landmark(2)], ...
            [landmark(3) landmark(3)], 'Color', [0.5 0.5 0.5], 'LineStyle','--', 'HandleVisibility', 'off')
    end
    
    hold off
    
    % Plot landmark numbers
    %     for e = 1:nLandmarks
    %         figureText(e) = text(landmarks(e, 1), landmarks(e, 2), landmarks(e, 3), ...
    %             ['$',num2str(e),'$'], 'HorizontalAlignment', 'center');
    %     end
    %
    %     % Bring text to front
    %     axHidden = axes('Visible','off','hittest','off'); % Invisible axes
    %     % Keep axes aligned
    %     linkprop([ax1 axHidden],{'CameraPosition' 'XLim' 'YLim' 'ZLim' 'Position'});
    %     set(figureText,'Parent',axHidden); % Put the text in the invisible Axes
    
    %set(gcf,'CurrentAxes', ax1)
    
end

title(plotTitle);
xlabel('$x$');
ylabel('$y$');
zlabel('$z$');

fig = gcf;

view(3);

end