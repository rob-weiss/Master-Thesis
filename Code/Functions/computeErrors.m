function [rmsError, errors] = computeErrors(position, xh)
%COMPUTEERRORS Computes errors and root mean-squared error

nSamples = size(position, 2);

errors = zeros(1, nSamples);

for i = 1:nSamples
    errors(i) = norm(position(:,i) - xh(:, i));
end

rmsError = sqrt(mean(errors.^2));

end

