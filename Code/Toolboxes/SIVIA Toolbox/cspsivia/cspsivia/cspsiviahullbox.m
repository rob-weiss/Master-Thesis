function [ ix ] = cspsiviahullbox(constr, ix, varsbyconstr)
% CSPSIVIAHULLBOX Use a combination of the forward-backward contractor and
% the boxnarrow contractor to effectively contract an interval box.
%
%   constr - a description of the CSP
%               - string representation of the constraints
%               - function representation of the constraints
%               - relations in the constraints
%               - an array of lists of indices of single-occuring variables
%               - desired precision
%   ix - an interval box, domain of the variables
%   varsbyconstr - lists of variables used in each constraint

    [strf, func, rel, singvars, eps] = constr{:};

    while (true)
        boxsize = isize(ix);
        
        cont = true;
        while (cont)
            cont = false;
            for i = 1:length(strf)
                ix2 = ix;
                vars = varsbyconstr{i};
                result = fbprop(strf{i}, [ix{vars}]);
                for j=1:length(vars)     % set new domains for variables in the constraint
                    ix{vars(j)} = result{j};
                end
                
                % check a condition for repeating the loop
                changes = cellfun(@(a,b)(isize(a)/isize(b) <= 0.9), ix, ix2); % domains, that were contracted enough
                cont = (~any(cellfun(@isnan, ix)) && (any(changes(singvars{i})) || cont));
            end
        end
        
        if (~any(cellfun(@isnan, ix)))
            multind = cellfun(@(a,b)(length(a) ~= length(b)), singvars, varsbyconstr);
            if any(multind)  % a constraint with multiple var occurrences exists
                c = {func(multind), rel(multind), 'newt', eps};
                ix = cspsiviabox(c, ix, varsbyconstr);
            end
        end
        
        newsize = isize(ix);
        if (newsize/boxsize > 0.9 || boxsize == 0 || any(cellfun(@isnan, ix))) || (newsize < 10^(-15))
            break;
        end
    end

end