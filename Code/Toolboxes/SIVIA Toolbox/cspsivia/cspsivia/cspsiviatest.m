function [ iS, iN, iB ] = cspsiviatest(func, ix, eps, divparts, divside)
% CSPSIVIATEST A version of the SIVIA algorithm for use with a test function. 
%   The test function can be any vector function, which returns 1 if the box 
%   is to be kept as a solution, 0 if it contains no solutions and any other 
%   value if it cannot be decided (the box will be further divided).
%   This function does not support the use of contractors.
%
%   See also CSPSIVIA.

    St = stack;
    St.push(ix);
    rr = 0;
    
    % initialize result vectors
    dim = size(ix, 2);
    iS = ivect(dim);
    iN = ivect(dim);
    iB = ivect(dim);

    while (~isempty(St))
        ix = St.pop();
        test = cellfun(@(f)(feval(f, [ix{:}])), func); % evaluate test functions
        
        if any(test == 0)                   % test failed, no solutions
            iN.insert([ix{:}]);
        elseif all(test == 1)               % test succeeded, solutions only
            iS.insert([ix{:}]);
        elseif (2*max(rad([ix{:}])) < eps)  % box too small
            iB.insert([ix{:}]);
        else
        % divide box and use sivia on each part
            if strcmp(divside, 'rr') % update round robin index
                rr = mod(rr, length(ix)) + 1;
                boxes = dividebox(ix, eps, divparts, rr);
            else
                boxes = dividebox(ix, eps, divparts, divside);
            end
            for i=1:divparts,
                St.push(boxes(i,:));
            end
        end
    end
    
    % remove any trailing zeros from the results
    iS = iS.items();
    iN = iN.items();
    iB = iB.items();
end