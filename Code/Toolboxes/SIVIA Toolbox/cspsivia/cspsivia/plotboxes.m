function boxes = plotboxes( iS, iN, iB, varargin )
% PLOTBOXES 2-dimensional plot of three sets of interval boxes.
%   iS, iN, iB - vectors of interval boxes
%   (Optional) 
%       colors  - specify a color for each set of boxes
%       nolines - do not draw borders of the boxes
%
%   Example
%       PLOTBOXES(iS, iN, iB, {'green', 'blue', 'white'})
%       PLOTBOXES(iS, iN, iB, {[0.1 0.2 0.3], 'yellow', [0 0 0.5]})

    numargs = length(varargin);
    if (numargs == 0)
        colors = {'red', 'white', 'yellow'};
        nolines = 0;
    elseif (numargs == 1)
        colors = varargin{1};
        nolines = 0;
    elseif (numargs == 2)
        colors = varargin{1};
        nolines = varargin{2};
        if isempty(colors)
            colors = {'red', 'white', 'yellow'};
        end
    else
        error('plotboxes:WrongType', 'Unknown color type: use an array of 3 named colors, RGB values or leave blank for default colors.');
    end

    % get fulldimensional boxes
	iNlog = false(1, size(iN, 1));
    for i=1:size(iN, 1)
        if all(rad(iN(i, :)) > 0)
            iNlog(i) = true;
        end
    end
    iN = iN(iNlog, :);
        
	iBlog = false(1, size(iB, 1));
    for i=1:size(iB, 1)
        if all(rad(iB(i, :)) > 0)
            iBlog(i) = true;
        end
    end
    iB = iB(iBlog, :);
    
    iSlog = false(1, size(iS, 1));
    for i=1:size(iS, 1)
        if all(rad(iS(i, :)) > 0)
            iSlog(i) = true;
        end
    end
    iS = iS(iSlog, :);
        
    boxes = figure;
    
    if (~isempty(iN)) % plot boxes with no solutions
        plot(iN(:,1),iN(:,2), colors{2}); hold all;
    end

    if (~isempty(iB)) % plot boxes that may or may not contain solutions
        plot(iB(:,1),iB(:,2), colors{3}); hold all;
    end

    if (~isempty(iS)) % plot boxes with solutions
        plot(iS(:,1),iS(:,2), colors{1});
    end
    
    if nolines % display plot without borders
        set(findobj(boxes, 'type', 'patch'),'LineStyle', 'none');
    end
    
    hold off;
end

