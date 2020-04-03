function [] = plotProjections2D(iS, iN, iB, position)
%PLOTPROJECTIONS2D Plot projections of three-dimensional SIVIA result in 2 dimensions

% x
proj2d(iS, iN, iB, [1, 2], 1);
hold on;
plot(position(1,1), position(2,1), 'Color', 'k', 'Marker', 'o', 'MarkerSize', 20, 'MarkerFaceColor', [0.4660    0.6740    0.1880]);

% y
proj2d(iS, iN, iB, [1, 3], 1);
hold on;
plot(position(1,1), position(3,1), 'Color', 'k', 'Marker', 'o', 'MarkerSize', 20, 'MarkerFaceColor', [0.4660    0.6740    0.1880]);

%z
proj2d(iS, iN, iB, [2, 3], 1);
hold on;
plot(position(2,1), position(3,1), 'Color', 'k', 'Marker', 'o', 'MarkerSize', 20, 'MarkerFaceColor', [0.4660    0.6740    0.1880]);

end

