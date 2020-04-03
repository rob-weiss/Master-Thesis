function [ newx ] = boxnarrow(func, rel, ix, indofvars)
% BOXNARROW The BoxNarrow contractor using a shaving method.
%
%   func      - left side of the constraint (anonymous function)
%   rel       - relation used in the constraint
%   ix        - an interval box (domain of the variables)
%   indofvars - a list of indices of variables used in the constraint

l = length(indofvars);
newx = ix;
for i = 1:l
    y0 = ix(indofvars(1:i-1)); % access by index vector
    y1 = ix(indofvars(i+1:end));
    
    fi = @(x)(func(y0{:}, x, y1{:}));
    
    iv = ix(indofvars(i));
    iv = [iv{:}];

    if 2*rad(iv) > 0.5
        part = infsup(inf(iv), inf(iv) + 0.5);
    else
        part = iv;
    end

    if (strcmp(rel, '=='))
        while (~(in(0,fi(part)))) % find left quasi-zero
            if (sup(part) == sup(iv)) % last part, domain contracted to empty set
                newx{indofvars(i)} = NaN;
                return;
            end
            if abs(sup(part) - sup(iv)) > 0.5
                part = infsup(sup(part), sup(part) + 0.5);
            else
                part = infsup(sup(part), sup(iv));
            end
        end
        lb = inf(part);
        
        if 2*rad(iv) > 0.5
            part = infsup(sup(iv) - 0.5, sup(iv));
        else
            part = iv;
        end
        
        while (~(in(0,fi(part)))) % find right quasi-zero
            if abs(inf(part) - inf(iv)) > 0.5
                part = infsup(inf(part) - 0.5, inf(part));
            else
                part = infsup(inf(iv), inf(part));
            end
        end
        ub = sup(part);
        
    elseif (strcmp(rel, '<='))        
         while (fi(part) > 0) % find left quasi-zero
            if (sup(part) == sup(iv)) % last part, domain contracted to empty set
                newx{indofvars(i)} = NaN;
                return;
            end
            if abs(sup(part) - sup(iv)) > 0.5
                part = infsup(sup(part), sup(part) + 0.5);
            else
                part = infsup(sup(part), sup(iv));
            end
        end
        lb = inf(part);
        
        if 2*rad(iv) > 0.5
            part = infsup(sup(iv) - 0.5, sup(iv));
        else
            part = iv;
        end
        
        while (fi(part) > 0) % find right quasi-zero
            if abs(inf(part) - inf(iv)) > 0.5
                part = infsup(inf(part) - 0.5, inf(part));
            else
                part = infsup(inf(iv), inf(part));
            end
        end
        ub = sup(part);
        
    elseif (strcmp(rel, '>='))
         while (fi(part) < 0) % find left quasi-zero
            if (sup(part) == sup(iv)) % last part, domain contracted to empty set
                newx{indofvars(i)} = NaN;
                return;
            end
            if abs(sup(part) - sup(iv)) > 0.5
                part = infsup(sup(part), sup(part) + 0.5);
            else
                part = infsup(sup(part), sup(iv));
            end
        end
        lb = inf(part);
        
        if 2*rad(iv) > 0.5
            part = infsup(sup(iv) - 0.5, sup(iv));
        else
            part = iv;
        end
        
        while (fi(part) < 0) % find right quasi-zero
            if abs(inf(part) - inf(iv)) > 0.5
                part = infsup(inf(part) - 0.5, inf(part));
            else
                part = infsup(inf(iv), inf(part));
            end
        end
        ub = sup(part);
    end
    
    newx{indofvars(i)} = infsup(lb, ub);
end

end