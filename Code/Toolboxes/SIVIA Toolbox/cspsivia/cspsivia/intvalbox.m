classdef intvalbox
% INTVALBOX A class to store interval boxes with their properties.
%   
%   val  - an interval vector (box)
%   type - type of the box in the result
%               * 1   for the subset of a result
%               * 0.5 for undetermined
%               * 0   for a box containing no solution
%   level - number of divisions required to create the box
%   count - number of boxes merged on the same level used to create the box
%
% See also CSPSIVIAMERGE.
    
    properties
        val;
        type;
        count;
        level;
    end
    
    methods
        function iv = intvalbox(val, type, count, level)
            iv.val = val;
            iv.type = type;
            iv.count = count;
            iv.level = level;
        end
    end
    
end