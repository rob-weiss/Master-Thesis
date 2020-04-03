function [ iS, iN, iB ] = cspsivia( f, ix, eps, varargin )
% CSPSIVIA A simple branch & bound algorithm (Set Inverter via Interval Analysis)
% that returns three sets of boxes describing the solution set of a CSP.
%
%   In:
%       f   - a cell array of constraints (anonymous functions),
%           - or a cell array of constraints (strings),
%           - or a handle of a test function
%       ix  - initial box of variable domains
%       eps - desired precision, the algorithm terminates when width(x) < eps
%   (Optional)
%       ctr - 'fbprop' use forward-backward propagation,
%           - 'boxnar' use boxnarrow contractor,
%           - 'boxnarnewt' use boxnarrow with interval Newton,
%           - 'comb'   use the combination of fbprop and boxnarrow,
%           - 'mohc'   use the monotonic hull consistency contractor,
%           - 'none'   do not use any contractor.
%       divparts - number of parts to divide the box into (default 2)
%       divside  [can only be specified if divparts is] (default 'lf')
%                - 'lf' divide by longest side,
%                - 'sf' divide by shortest side, 
%                - 'rr' round robin strategy
%       merge - use a box-merging algorithm (value 1)
%   Out:
%       S - boxes that only contain solutions
%       N - boxes that contain no solutions
%       B - boxes that may contain solutions
%
%   Example
%      [iS, iN, iB] = CSPSIVIA(f, ix, eps, 'fbprop');

intvalinit('RealStdFctsExcptnNaN', 0); % use real arithmetic, ignore NaN (parameter 0 -- don't display warning)

numargs = length(varargin);
if numargs > 4
    error('cspsivia:TooManyInputs', 'Too many optional input arguments.');
end

% assign values to optional arguments
optargs = {'none', 2, 'lf', 0};
optargs(1:numargs) = varargin;
[ctr, divparts, divside, merge] = optargs{:};
ix = num2cell(ix, 1);

if isempty(ctr)
    ctr = 'none';
end
if isempty(divparts)
    divparts = 2;
end
if isempty(divside)
    divside = 'lf';
end
if isempty(merge)
    merge = 0;
end

if merge && ~(strcmp(ctr, 'none'))
    disp('Warning: A contractor cannot be used with the box-merging algorithm.');
end

if iscell(f)
    if ischar(f{1})     % input by strings
        
        % create constraint objects from strings
        constraints = cell(1, length(f));
        for i=1:length(f)
            constraints{i} = constr(f{i});
        end
        
        % get indices of variables used in constraints and variables with single occurence
        [varsind, allvars] = getvars(cellfun(@(x)(x.normleft), constraints, 'UniformOutput', false));
        
        if ~merge
            [iS, iN, iB] = cspsivialoop(constraints, varsind, allvars, ix, eps, ctr, divparts, divside);
        else
            [iS, iN, iB] = cspsiviamerge(constraints, varsind, ix, eps, divparts, divside);
        end
        
    elseif isa(f{1}, 'function_handle')
        firstf = func2str(f{1});
        if (firstf(1) == '@')   % input by anonymous functions
            
            % get the body of the function
            f = cellfun(@func2str, f, 'UniformOutput', false);
            f = cellfun(@(s)(regexp(s, '\(.*\)\((.*)\)', 'tokens')), f);
            
            % create constraint objects from strings
            constraints = cell(1, length(f));
            for i=1:length(f)
                constraints{i} = constr(f{i});
            end

            % get indices of variables used in constraints and variables with single occurence
            [varsind, allvars] = getvars(cellfun(@(x)(x.normleft), constraints, 'UniformOutput', false));

            if ~merge
                [iS, iN, iB] = cspsivialoop(constraints, varsind, allvars, ix, eps, ctr, divparts, divside);
            else
                [iS, iN, iB] = cspsiviamerge(constraints, varsind, ix, eps, divparts, divside);
            end
            
        else    % input by a test function
            if ~(strcmp(ctr, 'none'))
                disp('Warning: A contractor cannot be used for test functions.');
            end
            [iS, iN, iB] = cspsiviatest(f, ix, eps, divparts, divside);
        end
    else
        error('cspsivia:WrongType', 'Incorrect input type: Constraints can only be a cell array of strings or functions.');
    end
else
    error('cspsivia:WrongType', 'Incorrect input type: Constraints can only be a cell array of strings or functions.');
end       
    
end