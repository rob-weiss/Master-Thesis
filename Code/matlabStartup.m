set(0, 'DefaultFigureWindowStyle', 'docked');

% Set text interpreter, axes interpreter, and legend interpreter to 'LaTeX'.
set(groot, 'defaultTextInterpreter', 'latex');
set(groot, 'defaultAxesTickLabelInterpreter', 'latex');
set(groot, 'defaultLegendInterpreter', 'latex');

cd '/Users/rob/Documents/Archive/Studies/Master Thesis/Code/Toolboxes/Intlab Toolbox';
startintlab

warning('off','all')

cd '/Users/rob/Documents/Archive/Studies/Master Thesis/Code';

matlabColors = [ ...
    0         0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840];

clc