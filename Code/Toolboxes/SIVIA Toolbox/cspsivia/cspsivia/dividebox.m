function [ boxes ] = dividebox(ix, eps, divparts, divside)
% DIVIDEBOX Divides the given interval box into smaller boxes.
%
%   ix       - interval box to be divided (cell array)
%   eps      - desired precision, does not divide if width(side) < eps
%   divparts - number of boxes to be created
%   divside  - 'lf' divide by longest side
%            - 'sf' divide by shortest side
%            - or divide by the side with the given index
%
%   Example
%       DIVIDEBOX({infsup(-5, 5), infsup(0, 20)}, 0.5, 2, 'lf')
%

    r = cellfun(@rad, ix);
    [maxsize, maxdim] = max(r); % size and index of max dimension
    [minsize, mindim] = min(r); % size and index of min dimension

    if (strcmp(divside, 'lf'))
        % divide by longest side
        boxes = divideside(ix, divparts, maxdim, maxsize);
    elseif (strcmp(divside, 'sf'))
        % try to divide by shortest side
        if (2*minsize >= eps)
            boxes = divideside(ix, divparts, mindim, minsize);
        else % shortest side too short, use lf
            boxes = divideside(ix, divparts, maxdim, maxsize);
        end
    elseif (divside <= length(ix)) % check if index is correct
        if (2*r(divside) >= eps)
            boxes = divideside(ix, divparts, divside, r(divside));
        else % chosen side too short, use lf
            boxes = divideside(ix, divparts, maxdim, maxsize);
        end
    else
        error('dividebox:WrongValue', 'Unknown argument value: divside. Use lf (longest first), sf (shortest first) or the index of the side to divide by.');
    end
end

function [ boxes ] = divideside(ix, divparts, divindex, divsize)
    ixdiv = ix{divindex};
    size = 2*divsize/divparts;       % length of the new side
    boxes = repmat(ix, divparts, 1); % pre-allocate space for new boxes
    for i = 1:divparts
        lb = inf(ixdiv) + (i - 1)*size;        % compute new lower bound
        ub = sup(ixdiv) - (divparts - i)*size; % compute new upper bound
        boxes{i, divindex} = intval(lb, ub, 'infsup');
    end
end