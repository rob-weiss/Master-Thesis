function [ iS, iN, iB ] = cspsiviamerge(constraints, varsind, ix, eps, divparts, divside)
% CSPSIVIAMERGE A variant of the SIVIA algorithm containing a function used 
%   to merge the generated boxes.
%
%   In:
%       constraints  - a cell array of constraints represented by objects of
%                      class constr
%       varsind      - indices of variables used and variables with single
%                      occurrence in a constraint
%       ix           - initial box of variable domains
%       eps          - desired precision, the algorithm terminates when width(x) < eps
%       divparts     - number of parts to divide the box into (default 2)
%       divside  [can only be specified if divparts is] (default 'lf')
%                    - 'lf' divide by longest side,
%                    - 'sf' divide by shortest side, 
%                    - 'rr' round robin strategy
%   Out:
%       S - boxes that only contain solutions
%       N - boxes that contain no solutions
%       B - boxes that may contain solutions
%
%   See also CSPSIVIA.

    ix = intvalbox(ix, -1, 1, 0);
    St = stack;
    
    [~, ~, func, intvs] = cellfun(@(x)(deal(x.strconstr, x.rel, x.normfunc, x.normintv)), constraints, 'UniformOutput', false);
    
    % logical vectors indicating which constraints are satisfied
    StSat = stack;
    
    [ix, sat] = testbox(ix, func, intvs, varsind, zeros(1, length(intvs)), eps); % set type of ix
    St.push(ix);
    StSat.push(sat);
    
    rr = 0;
    current = [];
    currset = 0;
    
    % initialize result vectors
    dim = size(ix.val, 2);
    iS = ivect(dim);
    iN = ivect(dim);
    iB = ivect(dim);

    while (~St.isempty())
        ix = St.pop();
        if currset && current.level > ix.level % current box cannot be merged
            if current.type == 0
                iN.insert([current.val{:}]);
            elseif current.type == 0.5
                iB.insert([current.val{:}]);
            elseif current.type == 1
                iS.insert([current.val{:}]);
            end
            currset = 0;
            current = [];
        end
        if ix.type == -1
            sat = StSat.pop();    % constraints already satisfied by ix
            if currset
                St.push(current);
                current = [];
                currset = 0;
            end
            if strcmp(divside, 'rr') % update round robin index, if used
                rr = mod(rr, length(ix.val)) + 1;
                boxes = dividebox(ix.val, eps, divparts, rr);
            else
                boxes = dividebox(ix.val, eps, divparts, divside);
            end
            for i=divparts:-1:1,                   
                % get the type and push children onto the stack
                [child, chsat] = testbox(intvalbox(boxes(i,:), -1, 1, ix.level + 1), func, intvs, varsind, sat, eps);
                St.push(child);
                if child.type == -1
                    StSat.push(chsat);
                end
            end
            continue;
        end
        if currset % a box to be merged is set
            if ix.type == current.type && ix.level == current.level % merge boxes
                newbox = mergeboxes(ix, current, divparts);
                St.push(newbox);
                current = [];
                currset = 0;
                continue;
            else % output current box
                if current.type == 0
                    iN.insert([current.val{:}]);
                elseif current.type == 0.5
                    iB.insert([current.val{:}]);
                elseif current.type == 1
                    iS.insert([current.val{:}]);
                end
                if St.isempty()
                    if ix.type == 0
                        iN.insert([ix.val{:}]);
                    elseif ix.type == 0.5
                        iB.insert([ix.val{:}]);
                    elseif ix.type == 1
                        iS.insert([ix.val{:}]);
                    end
                end
                current = ix;
                currset = 1;
            end
        else % a box to be merged is unset
            current = ix;
            currset = 1;
            if St.isempty()
                if current.type == 0
                    iN.insert([current.val{:}]);
                elseif current.type == 0.5
                    iB.insert([current.val{:}]);
                elseif current.type == 1
                    iS.insert([current.val{:}]);
                end
            end
            continue;
        end
    end
    
    % remove any trailing zeros from the results
    iS = iS.items();
    iN = iN.items();
    iB = iB.items();  
end

function newbox = mergeboxes(box1, box2, divparts)
    % MERGEBOXES Merge two objects of the intvalbox class and set the count 
    %   and level properties of the new box.
    index = find([box1.val{:}] ~= [box2.val{:}]);
    ix = [box1.val{:}];
    iy = [box2.val{:}];
    
    lower = min(inf(ix(index)), inf(iy(index)));
    upper = max(sup(ix(index)), sup(iy(index)));
    
    newbox = ix;
    newbox(index) = infsup(lower, upper);
    if box1.count + box2.count == divparts % last node in the layer
        count = 1;
        level = box1.level - 1;
    else
        count = box1.count + box2.count;
        level = box1.level;
    end
    newbox = intvalbox(mat2cell(newbox), box1.type, count, level);
end

function [ix, sat] = testbox(ix, func, intvs, varsind, sat, eps)
    % TESTBOX Get the type of the intvalbox object according to the CSP.

    % evaluate left sides (natural interval extesions) for ix
    v = varsind{1};
    sol = cellfun(@(f, vars)(feval(f, ix.val{vars})), func(sat == 0), v(sat == 0), 'UniformOutput', false);

    if any(cellfun(@emptyintersect, sol, intvs(sat == 0))) 
        % box contains no solutions
        ix.type = 0;
    else
        j = 0;
        for i=1:length(sat)
            if ~sat(i)
                j = j+1;
                sat(i) = in(sol{j}, intvs{i});
            end
        end 
        if all(sat)
        % box with solutions only
            ix.type = 1;
        elseif (2*max(cellfun(@rad, ix.val)) < eps)   
        % box is undetermined, but too small
            ix.type = 0.5;
        else
        % divide box and use sivia on each part
            ix.type = -1;
        end
    end
end