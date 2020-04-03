function [] = plotNContractions(t, contractions)
%PLOTZEROWEIGHTS Summary of this function goes here
%   Detailed explanation goes here

figure()

for i = 1:size(contractions, 1)
    
    if sum(contractions(i, :)) ~= 0
       stem(t, contractions(i, :), 'filled');
       break;
    else
        continue;
    end
    
end

title('Number of contractions');
legend('Contractions');

end

