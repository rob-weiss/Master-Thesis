function [ varsind, allvars ] = getvars( func )
% GETVARS Get indices of variables from a set used in each function
%
%   In:
%       func         - an array of functions represented by strings
%   Out:
%       varindex     - indices of variables used in each function
%       allvars      - the set of all variable names used
%       singvarindex - indices of variables with single occurrence
%       varsind = {varindex, singvarindex}
%
%   Example
%       [ind, all] = getvars({'2+3*x-y', 'cos(2*x)'});
%

    allvars = [];  % the set of all variables
    count = length(func);
    varsbyfunc = cell(1, count);  % subsets of vars for each function
    for i = 1:count
        varsbyfunc{i} = symvar(func{i});
        allvars = [allvars, varsbyfunc{i}'];
    end
    allvars = unique(allvars); % get all unique variables used
    
    varindex = cell(1, count);
    singvarindex = cell(1, count);
    for i = 1:count
        % find indices of variables used in functions
        [~, varindex{i}] = ismember(varsbyfunc{i}, allvars);
        
        % find single-occurrence variables
        sing = cellfun(@(var)(length(strfind(func{i}, var)) == 1), varsbyfunc{i}); 
        vars = varindex{i};
        singvarindex{i} = vars(sing);
    end
    varsind = {varindex, singvarindex};
end