classdef rectcintval
% RECTCINTVAL Rectangular complex interval.
%   Composed of real and imaginary parts represented by real intervals.
%   Basic arithmetic operations are supported, approximation of exact multiplication
%   and division is calculated using the CSPSIVIA function.
%
%   A =  RECTCINTVAL(infsup(0,1), infsup(2,3)) creates [0, 1] + [2, 3]i
%
%   See also INTVAL.
    
    properties
        re  % real part
        im  % imaginary part
    end
    
    methods
        function ci = rectcintval(re, im)
            if (isintval(re) && isintval(im))
                ci.re = re;
                ci.im = im;
            else
                error('cintval:WrongType', 'Real and imaginary parts of cintval have to be intervals.')
            end
        end
        
        function c = plus(a, b)     % c = a + b
            c.re = a.re + b.re;
            c.im = a.im + b.im;
        end
        
        function c = minus(a, b)    % c = a - b
            c.re = a.re - b.re;
            c.im = a.im - b.im;
        end
        
        function c = uminus(a)      % c = -a
            c.re = -a.re;
            c.im = -a.im;
        end
        
        function c = uplus(a)       % c = +a
            c = a;
        end
        
        function c = times(a, b)    % c = a .* b
            mprod = a * b;
            [iS, iN, iB] = cspsivia({'x - (a*c-b*d) = 0', 'y - (a*d+b*c) = 0'}, [a.re, a.im, b.re, b.im, mprod.re, mprod.im], 1, 'fbprop');
            iS = iS(:, 5:6);
            iN = iN(:, 5:6);
            iB = iB(:, 5:6);
            c = {iS, iN, iB};
            boxes = plotboxes(c{1}, c{2}, c{3}, {'r','w','b'});
            set(findobj(boxes, 'type', 'patch'),'LineStyle', 'none');
        end
        
        function c = mtimes(a, b)   % c = a * b
            c.re = a.re*b.re - a.im*b.im;
            c.im = a.re*b.im + a.im*b.re;
        end
        
        function c = rec(a)         % c = 1/a
            if in(0, a.re) && in(0, a.im)
                error('rectcintval:DivByZero', 'Error: Divisor contains zero.')
            else
                c.re = a.re/(a.re^2+a.im^2);
                c.im = -a.im/(a.re^2+a.im^2);
            end
        end
        
        function c = rdivide(a, b)  % c = a ./ b
            mdiv = a / b;
            [iS, iN, iB] = cspsivia({'x - ((a*c+b*d)/(c^2+d^2)) = 0', 'y - ((b*c-a*d)/(c^2+d^2)) = 0'}, [a.re, a.im, b.re, b.im, mdiv.re, mdiv.im], 1, 'fbprop');
            iS = iS(:, 5:6);
            iN = iN(:, 5:6);
            iB = iB(:, 5:6);
            c = {iS, iN, iB};
            boxes = plotboxes(c{1}, c{2}, c{3}, {'r','w','b'});
            set(findobj(boxes, 'type', 'patch'),'LineStyle', 'none');
        end
        
        function c = mrdivide(a, b) % c = a / b
            if in(0, b.re) && in(0, b.im)
                error('rectcintval:DivByZero', 'Error: Divisor contains zero.')
            else
                c = a * rec(b);
            end
        end
        
        function t = eq(a, b)       % a == b  
            t = ((a.re == b.re) && (a.im == b.im));
        end
        
        function t = ne(a, b)       % a ~= b 
            t = ~eq(a,b);
        end
        
        function display(a)
            display(a.re);
            display(a.im);
        end
    end
    
end