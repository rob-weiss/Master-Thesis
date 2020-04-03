function [ ix ] = cspsiviamohc(constr, ix, varsbyconstr)
% CSPSIVIAMOHC - Use the Monotonic Hull Consistency contractor to reduce an
%                interval box.
%
%   constr - a description of the CSP
%               - string representation of the constraints
%               - function representation of the constraints
%               - relations in the constraints
%               - an array of lists of indices of single-occuring variables
%               - desired precision
%               - a list of names of all variables
%   ix - an interval box, domain of the variables
%   varsbyconstr - lists of variables used in each constraint

    [strf, func, rel, singvars, eps, allvars] = constr{:};

    while (true)
        boxsize = isize(ix);
        for i=1:length(func)      % use all constraints and variables
            ix = mohcrevise({strf{i}, func{i}}, rel{i}, ix, varsbyconstr{i}, singvars{i}, allvars, eps);
            if (any(cellfun(@isnan, ix))) % if the box is empty, end
                return;
            end
        end
        newsize = isize(ix);

        % contraction too small, end
        if (newsize/boxsize > 0.9) || (boxsize == 0) || (newsize < 10^(-15))
            break;
        end
    end
    
end