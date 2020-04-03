function [ newx ] = boxnarrownewton( func, rel, strf, ix, indofvars, eps )
% BOXNARROWNEWTON A variation of the BoxNarrow contractor using the
% univariate interval Newton method.
%
%   func        - left side of constraint given by an anonymous function
%   rel         - relation in the constraint
%   strf        - string represation of the constraint
%   ix          - an interval box (cell array)
%   indofvars   - a list of indices of variables used in the constraint
%   eps         - desired precision

    l = length(indofvars);
    newx = ix;
    % add a slack variable to an inequality
    if strcmp(rel, '<=')
        strf = normeq(strf);
        exprsplit = regexp(strf,'<=','split');
        func = str2anon(strcat(exprsplit{1}, '+z__'));
        ix{end+1} = infsup(0, inf);
        indofvars(end+1) = length(ix);
    elseif strcmp(rel, '>=')
        strf = normeq(strf);
        exprsplit = regexp(strf,'>=','split');
        func = str2anon(strcat(exprsplit{1}, '-z__'));
        ix{end+1} = infsup(0, inf);
        indofvars(end+1) = length(ix);
    end
    
    for i = 1:l % for each variable
        y0 = ix(indofvars(1:i-1));
        y1 = ix(indofvars(i+1:end));
        fi = @(x)(func(y0{:}, x, y1{:}));

        lb = leftnarrow(ix{indofvars(i)}, fi, eps); % new lower bound
        ub = rightnarrow(ix{indofvars(i)}, fi, eps); % new upper bound

        newx{indofvars(i)} = hull(lb, ub);
    end

end

function ix = leftnarrow(ix, fi, eps)
    if ~in(0, fi(ix)) && ~isnan(fi(ix)) % no solution
        ix = NaN;
        return;
    end
    ix = uninewton(ix, fi); % use the Newton method
    if rad(ix) < eps/2 || isnan(ix)
        return;
    end
    dbox = dividebox({ix}, 0, 2, 1);
    [iy, iz] = dbox{:};
    ix = leftnarrow(iy, fi, eps);
    if isnan(ix)
        ix = leftnarrow(iz, fi, eps);
    end    
end

function ix = rightnarrow(ix, fi, eps)
    if ~in(0, fi(ix)) && ~isnan(fi(ix)) % no solution
        ix = NaN;
        return;
    end
    ix = uninewton(ix, fi); % use the Newton method
    if rad(ix) < eps/2 || isnan(ix)
        return;
    end
    dbox = dividebox({ix}, 0, 2, 1);
    [iy, iz] = dbox{:};
    ix = rightnarrow(iz, fi, eps);
    if isnan(ix)
        ix = rightnarrow(iy, fi, eps);
    end  
end

function ix = uninewton(ix, fi)
% Univariate interval Newton method
    y = intval(mid(ix));
    ig = fi(gradientinit(ix));
    if in(0, ig.dx) || isnan(ig.dx)
       return;
    else
       ix = intersect(y - fi(y)/ig.dx, ix); % Newton step
    end
end