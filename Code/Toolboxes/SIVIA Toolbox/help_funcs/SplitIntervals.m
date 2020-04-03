function [Min, Max] = SplitIntervals(I)

if (length(size(I)) ~= 2)
    error('Wrong number of dimensions')
end

if (size(I, 2) ~= 1)
    error('Wrong number of columns')
end

Min = inf(I);
Max = sup(I);

end