function [ ix ] = mohcrevise( constr, rel, ix, vars, singvars, allvars, eps )
% MOHCREVISE The Monotonic Hull Consistency contractor.
%   constr   - a constraint represented by a string and an anonymous function
%   rel      - relation used in the constraint
%   ix       - an interval box (variable domains)
%   vars     - indices of variables used in the constraint
%   singvars - a list of single-occurring variables
%   allvars  - a list of names of all variables
%   eps      - desired precision

    [strf, func] = constr{:};
    ix = [ix{:}];
    
    % call the forward-backward contractor first
    tmpix = fbprop(strf, ix(vars)); 

    ix(vars) = [tmpix{:}];
    if any(isnan([tmpix{:}]))
        ix = num2cell(ix, 1);
        return;
    end
 
    % get indices of variables with multiple occurrences
    multvars = find(~ismember(vars, singvars));
    if multvars
        cont = 1;
        names = allvars(vars);
        strf = normeq(strf);
        fvect = spliteq(strf);
        fvect = fvect{1};
        fvect = vectinput(fvect, names);
    else
        ix = num2cell(ix, 1);
        return;
    end
    
    % add a slack variable to an inequality
    if strcmp(rel, '<=')
        exprsplit = regexp(strf,'<=','split');
        strf = strcat(exprsplit{1}, '+zz');
        func = str2anon(strcat(exprsplit{1}, '+zz'));
        ix(end+1) = infsup(0, inf);
        singvars(end+1) = length(allvars) + 1;
        vars(end+1) = length(allvars) + 1;
        added = 1;
    elseif strcmp(rel, '>=')
        exprsplit = regexp(strf,'>=','split');
        strf = strcat(exprsplit{1}, '-zz');
        func = str2anon(strcat(exprsplit{1}, '-zz'));
        ix(end+1) = infsup(0, inf);
        singvars(end+1) = length(allvars) + 1;
        vars(end+1) = length(allvars) + 1;
        added = 1;
    else
        strf = spliteq(strf);
        strf = strf{1};
        added = 0;
    end
    
    if cont
       % calculate partial derivatives for variables with multiple occurrences
       ig = getgradient(fvect, multvars, ix(vars));
       
       % separate monotonic variables and create functions fmin, fmax
       [monovars, notmonovars, fmax, fmin] = getmonovars(strf, multvars, allvars, ix(multvars), ig);

       % perform a MinMax-revise contraction for single-occurring or nonmonotonic variables
       ind = unique(sort([notmonovars, singvars]));
       if ind ~= length(allvars) + 1 % do not use slack variable
           tmpix = minmaxrev(ix(ind), fmax, fmin);
           ix(ind) = tmpix;
           if any(isnan(tmpix))
               if added 
                   ix = num2cell(ix(1:end-1), 1);
               else
                   ix = num2cell(ix, 1);
               end
               return;
           end
       end

       % perform a BoxNarrow contraction for monotonic variables
       [~, ind] = ismember(monovars, multvars);
       ig = ig(ind);
       ix = monoboxnarrow(ix, func, fmax, fmin, vars, monovars, ig, eps);
    end

    if ~added
        ix = num2cell(ix, 1);
    else
        ix = num2cell(ix(1:end-1), 1);
    end
end

function ig = getgradient(func, vars, ix)
    ig = func(gradientinit(ix));
    ig = ig.dx;
    ig = ig(vars);
end

function ix = minmaxrev(ix, fmax, fmin)
    if isempty(ix)
        ix = NaN;
        return;
    end
    ix = fbprop([fmin, '<= 0'], ix);
    ix = [ix{:}];
    if any(isnan(ix))
        return;
    end
    ix = fbprop([fmax, '>= 0'], ix);
    ix = [ix{:}];
end

function fvect = vectinput(strf, names)
% vectorize the input of a function

    matches = cell(length(names), 1);
    count = 0;
    for i=1:length(names)
       % get positions of variable name in the string
       expr = ['(?:[^a-z]|^)(', names{i}, ')(?:[^a-z]|$)'];
       tok = regexp(strf, expr, 'tokenExtents');
       tok = [tok{:}];
       tok = tok(1:2:end);
       for j=1:length(tok);
           count = count + 1;
           matches{count} = [i, tok(j)];
       end
    end
    matches = cell2mat(matches);
    matches = sortrows(matches, 2);
    for i=size(matches, 1):-1:1
       % replace matches by vector variables
       tok = matches(i, :);
       strf = [strf(1:tok(2)-1), 'x(', num2str(tok(1)), ')', strf(tok(2)+1:end)];
    end
    
    ff = ['@(x)(', strf, ')'];
    fvect = eval(ff);
end