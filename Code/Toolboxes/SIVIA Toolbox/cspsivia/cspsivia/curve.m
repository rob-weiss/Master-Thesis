classdef curve
% CURVE A class representing curves. 
%   The curve is described by a set of functions (cell array func).
%
%   func      - a function represented by a string
%   plotcurve - plots a curve using the SIVIA algorithm
%
%   Example:
%       circle = curve({'x^2+y^2-5'}); 
%       circle.plotcurve([infsup(-5,5), infsup(-5,5)], 0.25);
%       
    properties
        func
    end
    
    methods
        function c = curve(f)
            c.func = f;
        end
        
        function plotcurve(this, box, eps)
            [iS, iN, iB] = cspsivia(this.func, box, eps);
            plotboxes(iS, iN, iB);
        end
    end
    
end

