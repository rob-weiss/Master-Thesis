function normconstr = normeq(constr)
% NORMEQ Rearrange an equation or inequality into a form f(x) = 0,
%  f(x) >= 0 or f(x) <= 0
%
%   Example
%       normconstr = normeq('5*x*y+1=3*log(x)');
%

    if iscell(constr)
        constr = constr{:};
    end
    % split the constraint into parts
    splitc = spliteq(constr);
    if strcmp(splitc{2}, '==')
        splitc{2} = '=';
    end
    
    if (~strcmp(splitc{3},'0') && ~strcmp(splitc{3},' 0'))
        normconstr = strcat(splitc{1}, '-', '(', splitc{3}, ')', splitc{2}, '0');
    else % left side already equal to zero
        normconstr = constr;
    end
end