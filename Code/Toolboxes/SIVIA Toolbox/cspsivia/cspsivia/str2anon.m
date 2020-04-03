function [ anon_f ] = str2anon( sfunc )
% STR2ANON Creates an anonymous function from a string expression.
%
%   sfunc - a boolean or numeric function represented by a string
%
%   Example
%       F = STR2ANON('x+y') creates a function to add its two parameters.
%       F = STR2ANON('3*x = 9') creates a boolean function.
%
%   See also STR2FUNC.

    sfunc = regexprep(sfunc, '([^<>])=', '$1==');
    vars = symvar(sfunc); % get a list of variables used
    if ~isempty(vars)
        last = vars{end};
    else
        last = [];
    end
    vars = ['@(', sprintf('%s,',vars{1:end-1}), last, ') '];
    anon_f = eval(strcat(vars, '(', sfunc, ')'));
end