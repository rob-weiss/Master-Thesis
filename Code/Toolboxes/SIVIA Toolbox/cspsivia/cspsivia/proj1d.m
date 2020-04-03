function [ iS, iN, iB ] = proj1d( iS, iN, iB, i, visual, varargin )
% PROJ1D Project interval boxes to a chosen dimension.
%
%    iS, iN, iB - three sets of interval boxes
%    i          - index of the dimension
%    visual     - if true, plot the results
%    projy (optional) - display projection on the y-axis
%
%    Example:
%       [iS, iN, iB] = CSPSIVIA({'x^2+y^2 >= 9'}, [infsup(-5, 5), infsup(-5,5)], 0.25);
%       PROJ1D(iS, iN, iB, 1, 1);
%
%  See also PROJ2D.

    % check number of optional arguments and set the projection axis
    if length(varargin) > 1
        error('cspsivia:proj1d', 'Too many optional arguments.');
    elseif length(varargin) == 1
        projy = varargin{1};
    else
        projy = 0;
    end

    % check projection index and remove intervals in other dimensions
    sets = {iS, iN, iB};
    for j=1:3
        s = sets{j};
        if s
            if length(s(1,:)) >= i
                sets{j} = s(:, i);
            else
                error('cspsivia:proj1d', 'Projection index exceeds vector dimensions.');
            end
        end
    end
    if length(i) ~= 1
        error('cspsivia:proj1d', 'Wrong number of projection indices. One index required.');
    end
    [iS, iN, iB] = sets{:};
    
    if ~isempty(iS)
        iSinf = iS.inf; % lower bounds of feasible intervals
        iSsup = iS.sup; % upper bounds of feasible intervals
    else
        iSinf = [];
        iSsup = [];
    end
    if ~isempty(iB)
        iBinf = iB.inf; % lower bounds of undetermined intervals
        iBsup = iB.sup; % upper bounds of undetermined intervals
    else
        iBinf = [];
        iBsup = [];
    end
    
    fields = {iSinf, iSsup, iBinf, iBsup};
    nodes = cell(length(iSinf)+length(iSsup)+length(iBinf)+length(iBsup), 3);
    lowers = [1, 0, 1, 0]; % if true, the value represents a lower bound
    types = [1, 1, 0, 0];  % if true, the value belongs to a feasible interval
    index = 0;
    
    % create triplets (value, islowerbound, isfeasible)
    for j=1:4     
        field = fields{j};
        lower = lowers(j);
        sbox = types(j);
        
        for k=1:length(field)
            index = index+1;
            nodes{index, 1} = field(k);
            nodes{index, 2} = lower;
            nodes{index, 3} = sbox;
        end
    end
    
    % sort the triplets primarily by value (ascending)
    % and by islowerbound property (lower bounds first)
    nodes = sortrows(nodes, [1 -2]);
    
    % set counters and on-flags (currently active types of intervals)
    onS = 0; 
    countS = 0;
    onB = 0;
    countB = 0;
    
    % values that may be used as left-most and right-most points
    if ~isempty(iN)
        newbox = intval(min(iN.inf));
        m = max(iN.sup);
    else
        newbox = intval(0);
        m = 0;
    end
    
    iS = ivect(1);
    iN = ivect(1);
    iB = ivect(1);
    
    % create new projected intervals using sorted triples
    for j=1:size(nodes, 1)
        value = nodes{j, 1};
        lower = nodes{j, 2};
        sbox = nodes{j, 3};

        if lower && sbox % lower bound of a feasible interval
            countS = countS + 1; % new S-type interval found
            if ~onS
                if onB % B-type is active, end it and set new values
                    newbox = infsup(inf(newbox), value);
                    iB.insert(newbox);
                    newbox = intval(value);
                else % N-type active
                    if inf(newbox) < value
                        newbox = infsup(inf(newbox), value);
                        iN.insert(newbox);
                    end
                    newbox = intval(value);
                end
            end
            onS = 1; % set S-type as active
        elseif lower && ~sbox % lower bound of an undetermined interval
            countB = countB + 1;
            if ~onS && ~onB % N-type active
                if inf(newbox) < value
                    newbox = infsup(inf(newbox), value);
                    iN.insert(newbox);
                end
                newbox = intval(value);
            end
            onB = 1;
        elseif ~lower && sbox % upper bound of a feasible interval
            countS = countS - 1; % end of one S-type interval
            if countS == 0 % no more S-type intervals active, end interval
                onS = 0;
                newbox = infsup(inf(newbox), value);
                iS.insert(newbox);
                newbox = intval(value);
            end
        else % upper bound of an undetermined interval
            countB = countB - 1;
            if ~onS && countB == 0 % end a B-type interval
                onB = 0;
                newbox = infsup(inf(newbox), value);
                iB.insert(newbox);
                newbox = intval(value);
            end
        end 
    end

    if inf(newbox) < m % add the last interval containing no solutions
        newbox = infsup(inf(newbox), m);
        iN.insert(newbox);
    end
    
    % remove any trailing zeros from the results
    iS = iS.items();
    iN = iN.items();
    iB = iB.items();
    
    if visual
        % plot the results
        figure;
        if ~projy % project onto x-axis       
            hold all;
            for j=1:length(iS) % plot intervals with solutions
                plot([inf(iS(j)), sup(iS(j))], [0 0], 'r', 'LineWidth', 5);
            end
            for j=1:length(iN) % plot intervals without any solutions
                plot([inf(iN(j)), sup(iN(j))], [0 0], 'k');
            end
            for j=1:length(iB) % plot undetermined intervals
                plot([inf(iB(j)), sup(iB(j))], [0 0], 'y', 'LineWidth', 5);
            end
            hold off;       
        else     % project onto y-axis
            hold all;
            for j=1:length(iS)
                plot([0 0], [inf(iS(j)), sup(iS(j))], 'r', 'LineWidth', 5);
            end
            for j=1:length(iN)
                plot([0 0], [inf(iN(j)), sup(iN(j))], 'k');
            end
            for j=1:length(iB)
                plot([0 0], [inf(iB(j)), sup(iB(j))], 'y', 'LineWidth', 5);
            end
            hold off;
        end
    end
    
end