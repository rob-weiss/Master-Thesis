function ixnew = contract(ix, f, pf)
%CONTRACT Summary of this function goes here
%   Detailed explanation goes here

% create constraint objects from strings
constraints = cell(1, length(f));
for i=1:length(f)
    constraints{i} = constr(f{i});
end

% get indices of variables used in constraints and variables with single occurence
[varsind, allvars] = getvars(cellfun(@(x)(x.normleft), constraints, 'UniformOutput', false));

[strf, rel, func, ~] = cellfun(@(x)(deal(x.strconstr, x.rel, x.normfunc, x.normintv)), constraints, 'UniformOutput', false);

% choose a contractor function
if strcmp(pf.boundedErrorProp.contrType, 'fbprop')
    ctrfun = @cspsiviahull;
    constraint = strf;
elseif strcmp(pf.boundedErrorProp.contrType, 'boxnar')
    ctrfun = @cspsiviabox;
    constraint = {func, rel, ''};
elseif strcmp(pf.boundedErrorProp.contrType, 'boxnarnewt')
    ctrfun = @cspsiviabox;
    constraint = {func, rel, strf, contr.eps, 'newt'};
elseif strcmp(pf.boundedErrorProp.contrType, 'comb')
    ctrfun = @cspsiviahullbox;
    constraint = {strf, func, rel, varsind{2}, contr.eps};
elseif strcmp(pf.boundedErrorProp.contrType, 'mohc')
    ctrfun = @cspsiviamohc;
    constraint = {strf, func, rel, varsind{2}, contr.eps, allvars};
else
    error('cspsiviactr:WrongValue', 'Incorrect contractor type: Choose fbprop (Forward-Backward), boxnar (BoxNarrow), boxnarnewt (BoxNarrow with interval Newton), mohc (Monotonic Hull Consistency) or comb (combined).');
end
ix = {ix(1,1), ix(1,2), ix(1,3)};
result = ctrfun(constraint, ix, varsind{1});
ixnew = [result{1}, result{2}, result{3}];

if pf.plotEstimatesLive
    plotBoxes3D(ixnew, 'green', 0.1, 0, 'Contracted box', pf.resizeLive);
    pause(pf.pauseTime);
end

end

