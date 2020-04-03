function result = spliteq(expr)
% SPLITEQ Split an equation or inequality into parts.
%
%   In:
%       expr - a string expression representing an equation or inequality
%   Out:
%       LS   - left side of the equation / inequality
%       RS   - right side of the equation / inequality
%       rel  - relation between the sides (<= or >= for inequalities, == for
%              equations)
%       interval - if RS is zero, LS belongs to this interval
%
%   Example
%       result = spliteq('2*x+sin(y)=5');
%

    if strfind(expr, '<=')
        exprsplit = regexp(expr,'<=','split');
        LS = exprsplit{1};
        RS = exprsplit{2};
        rel = '<=';
        interval = infsup(-inf, 0);
        
    elseif strfind(expr, '>=')
        exprsplit = regexp(expr,'>=','split');
        LS = exprsplit{1};
        RS = exprsplit{2};
        rel = '>=';
        interval = infsup(0, inf);
        
    elseif strfind(expr, '=')
        exprsplit = regexp(expr,'=','split');
        LS = exprsplit{1};
        RS = exprsplit{2};
        rel = '==';
        interval = intval(0);        
    else
        error('spliteq:IncorrectInput', 'Incorrect input: An equation or inequality is required.');
    end
    
    result = {LS, rel, RS, interval};
end