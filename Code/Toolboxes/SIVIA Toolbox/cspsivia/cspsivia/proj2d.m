function [ iS, iN, iB ] = proj2d( iS, iN, iB, i, visual)
% PROJ2D Project interval boxes into 2 dimensions.
%
%   iS, iN, iB - three sets of interval boxes
%   i          - a vector of two indices of the dimensions
%   visual     - if true, plot the results
%
% See also PROJ1D.

    % check projection indices and remove intervals in other dimensions
    sets = {iS, iN, iB};
    if length(i) ~= 2
        error('cspsivia:proj2d', 'Incorrect number of projection indices.');
    end
    for j=1:3
        s = sets{j};
        if s
            if all(length(s(1,:)) >= i)
                sets{j} = s(:, i);
            else
                error('cspsivia:proj2d', 'Projection index exceeds vector dimensions.');
            end
        end
    end
    [iS, iN, iB] = sets{:};
    
    % bounds of feasible interval boxes
    if ~isempty(iS)
        iSlr = iS(:, 1);
        iSdown = iS.inf(:, 2);
        iSup = iS.sup(:, 2);
    else
        iSlr = [];
        iSdown = [];
        iSup = [];
    end
    
    % bounds of undetermined interval boxes
    if ~isempty(iB)
        iBlr = iB(:, 1);
        iBdown = iB.inf(:, 2);
        iBup = iB.sup(:, 2);
    else
        iBlr = [];
        iBdown = [];
        iBup = [];
    end
    
    % get left and right bounds of the box
    if ~isempty(iN)
        minN = min(iN.inf(:, 1));
        maxN = max(iN.sup(:, 1));
        boxN = infsup(minN, maxN);
    else
        boxN = [];
    end
    
    fields = {iSdown, iSup, iBdown, iBup};
    nodes = cell(length(iSdown)+length(iSup)+length(iBdown)+length(iBup), 4);
    lowers = [1, 0, 1, 0]; % if true, the value represents a lower bound
    types = [1, 1, 0, 0];  % if true, the value belongs to a feasible interval
    index = 0;

    % create quadruples (value, islowerbound, isfeasible, index)
    for j=1:4     
        field = fields{j};
        lower = lowers(j);
        sbox = types(j);
        
        for k=1:length(field)
            index = index+1;
            nodes{index, 1} = field(k);
            nodes{index, 2} = lower;
            nodes{index, 3} = sbox;
            nodes{index, 4} = k;
        end
    end
    
    % sort the quadruples primarily by value (ascending)
    % and by islowerbound property (lower bounds first)
    nodes = sortrows(nodes, [1 -2]);
    
    stripeS = false(1, size(iS, 1)); % feasible intervals in the current stripe
    stripeB = false(1, size(iB, 1)); % undetermined intervals
    
    iS = ivect(2);
    iN = ivect(2);
    iB = ivect(2);
    
    j = 1;
    while j < length(nodes)
        value = nodes{j, 1};
        
        while j < length(nodes) && nodes{j, 1} == value % nodes in one stripe
            
           if nodes{j, 3} % feasible box
               if nodes{j, 2} % lower bound, add interval
                   stripeS(nodes{j, 4}) = 1;
               else % upper bound, remove interval
                   stripeS(nodes{j, 4}) = 0;
               end
               
           else % boundary box
               if nodes{j, 2} % lower bound, add interval
                   stripeB(nodes{j, 4}) = 1;
               else % upper bound, remove interval
                   stripeB(nodes{j, 4}) = 0;
               end
           end
           j = j + 1;
        end
        
        [iStmp, iNtmp, iBtmp] = proj1d(iSlr(stripeS), boxN, iBlr(stripeB), 1, 0);
        
        % add y-coordinates and insert into results
        if j < length(nodes)
            iy = infsup(value, nodes{j+1, 1});
            iStmp(:, 2) = iy;
            iNtmp(:, 2) = iy;
            iBtmp(:, 2) = iy;
            iS.insertset(iStmp);
            iN.insertset(iNtmp);
            iB.insertset(iBtmp);
        end
    end
    
    % remove trailing zeros
    iS = iS.items();
    iN = iN.items(); 
    iB = iB.items();
    
    if visual
        plotboxes(iS, iN, iB, [], 1);
    end
end