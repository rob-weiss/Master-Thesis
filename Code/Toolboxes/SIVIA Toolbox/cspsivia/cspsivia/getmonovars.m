function [monovars, notmonovars, fmax, fmin] = getmonovars(func, vars, allvars, ix, ig)
% GETMONOVARS Separate monotonic variables.
%   In:
%       func    - function represented by a string
%       vars    - indices of variables with multiple occurences in func
%       allvars - a list of names of all variables
%       ix      - an interval box of variable domains
%       ig      - gradient of the function
%   Out:
%       monovars    - indices of monotonic variables
%       notmonovars - indices of non-monotonic variables
%       fmax, fmin  - func with monotonic variables replaced by their bounds

    notmonovars = zeros(1, length(vars));
    monovars = zeros(1, length(vars));
    fmin = func;
    fmax = func;
    names = allvars(vars);
    
    for i=1:length(vars)
       if in(0, ig(i))    % variable is not monotonic
           notmonovars(i) = 1;
       elseif (ig(i) < 0) % variable is decreasing
           monovars(i) = 1;
           expr = ['([^a-z]|^)(', names{i}, ')([^a-z]|$)'];
           fmax = regexprep(fmax, expr, ['$1', num2str(ix(i).inf, '%f'), '$3'], 'emptymatch');
           fmin = regexprep(fmin, expr, ['$1', num2str(ix(i).sup, '%f'), '$3'], 'emptymatch');
       else               % variable is increasing
           monovars(i) = 1;
           expr = ['([^a-z]|^)(', names{i}, ')([^a-z]|$)'];
           fmax = regexprep(fmax, expr, ['$1', num2str(ix(i).sup, '%f'), '$3'], 'emptymatch');
           fmin = regexprep(fmin, expr, ['$1', num2str(ix(i).inf, '%f'), '$3'], 'emptymatch');
       end
    end
    
    % convert logical values to indices
    notmonovars = vars(logical(notmonovars));
    monovars = vars(logical(monovars));

end