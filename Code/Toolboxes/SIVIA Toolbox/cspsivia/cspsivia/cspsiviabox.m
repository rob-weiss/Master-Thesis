function [ ix ] = cspsiviabox(constr, ix, varsbyconstr)
% CSPSIVIABOX Use the BoxNarrow contractor to contract an interval box.
%
%   constr - a description of the CSP
%               - function representation of the constraints
%               - relations in the constraints
%               - string 'newt' if the Newton method should be used
%               - string representation of the constraints (if 'newt')
%               - desired precision (if 'newt')
%   ix - an interval box, domain of the variables
%   varsbyconstr - lists of variables used in each constraint

    func = constr{1};
    rel = constr{2};
    newt = 0;
    
    if strcmp(constr{end}, 'newt')
        strf = constr{3};
        eps = constr{4};
        newt = 1;
    end
    
    while (true)
        boxsize = isize(ix);
        for i=1:length(func)      % use all constraints and variables
            if newt
                ix = boxnarrownewton(func{i}, rel{i}, strf{i}, ix, varsbyconstr{i}, eps);
            else
                ix = boxnarrow(func{i}, rel{i}, ix, varsbyconstr{i});
                eps = 0;
            end
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