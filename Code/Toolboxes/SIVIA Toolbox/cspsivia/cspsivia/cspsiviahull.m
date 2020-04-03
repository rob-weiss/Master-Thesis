function [ ix ] = cspsiviahull(constr, ix, varsbyconstr)
% CSPSIVIAHULL Use the forward-backward contractor to contract an interval box.
%
%   constr       - a cell array of constraints represented by strings
%   ix           - an interval box (cell array)
%   varsbyconstr - an array of lists of indices of variables used in the constraints
%

    while (~any(cellfun(@isnan, ix)))  % if the box is empty, end
        boxsize = isize(ix);
        for i=1:length(constr)      % use all constraints
           vars = varsbyconstr{i};
           result = fbprop(constr{i}, [ix{vars}]);
           for j=1:length(vars)     % set new domains for variables in the constraint
               ix{vars(j)} = result{j};
           end
        end
        
        newsize = isize(ix);
        % contraction too small, end
        if (newsize/boxsize > 0.9 || boxsize == 0) || (newsize < 10^(-15))
            break;
        end
    end
    
end