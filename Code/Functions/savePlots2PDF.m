function figHandles = savePlots2PDF(logFilePath, logFileName, tikzBool)
%SAVEPLOTS2PDF Summary of this function goes here
%   Detailed explanation goes here

figHandles = findobj('Type', 'figure');
for i = 1:length(figHandles)
    savePlot2PDF(logFilePath, [logFileName, '-figure-', num2str(i)], figHandles(i));
    
    if tikzBool
        savePlot2TIKZ([logFilePath, 'TikZ/'], [logFileName, '-figure-', num2str(i)], figHandles(i));
    end
end

close(figHandles);

end

