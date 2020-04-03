function [progress, msg] = printProgress(k, nSamples)
%PRINTPROGRESS Prints the progress to the console

persistent reverseStr

if k == 1
    reverseStr = '';
end
progress = 100 * ((k-1) / nSamples + 1 / nSamples);
msg = sprintf('Progress:      %3.1f %%', progress);
disp([reverseStr, msg]);
reverseStr = repmat(sprintf('\b'), 1, length(msg) + 1);

if k == nSamples
    disp([reverseStr, sprintf('\b')]);
end

end

