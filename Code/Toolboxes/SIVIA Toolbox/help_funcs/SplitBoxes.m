function [Min_X, Max_X, Min_Y, Max_Y] = SplitBoxes(B)

if (length(size(B)) ~= 2)
    error('Wrong number of dimensions')
end

if (size(B, 2) ~= 2)
    error('Wrong number of dimensions')
end

inf_B = inf(B);
sup_B = sup(B);

Min_X = inf_B(:,1);
Max_X = sup_B(:,1);
Min_Y = inf_B(:,2);
Max_Y = sup_B(:,2);

end