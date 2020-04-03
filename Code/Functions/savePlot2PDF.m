function [] = savePlot2PDF(figurePath, fileName, figureHandle)
%SAVEPLOT2PDF Save figure to PDF file

% Save 3D plots to file
set(figureHandle, 'PaperOrientation', 'landscape');
print(figureHandle, fullfile(figurePath, fileName), '-dpdf', '-bestfit');

end

