function [] = savePlot2TIKZ(filePath, fileName, figHandle)
%SAVEPLOT2TIKZ Save current figure to Tikz file

answer = mkdir(filePath);

matlab2tikz([filePath, fileName, '.tikz'], 'figurehandle', figHandle, ...
    'height', '\figureheight', 'width', '\figurewidth', 'showInfo', false);

% 'extraaxisoptions', 'title style={font=\normal},'
end

