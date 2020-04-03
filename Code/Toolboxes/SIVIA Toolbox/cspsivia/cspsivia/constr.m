classdef constr
% CONSTR An equation or inequality constraint for a CSP.
%
%   strconstr - constraint represented by a string
%   rel       - binary relation ==, <=, >=
%   
%   data after setting the right side equal to zero
%   normleft - left side of the constraint (string)
%   normfunc - left side of the constraint (anon. function)
%   normintv - interval range
%
%   Example
%       lineconstr = constr('x+y >= 2');
%    
    properties
        strconstr;
        rel;
        normleft;
        normfunc;
        normintv;
    end
    
    methods
        function c = constr(s)
            c.strconstr = s;
            arr = spliteq(normeq(s));
            c.rel = arr{2};
            c.normleft = arr{1};
            c.normfunc = str2anon(arr{1});
            c.normintv = arr{4};
        end
    end
    
end

