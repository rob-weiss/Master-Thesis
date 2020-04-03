function [ iS, iN, iB ] = cspsivialoop(constraints, varsind, allvars, ix, eps, ctr, divparts, divside)
% CSPSIVIALOOP Basic Set Inverter via Interval Analysis algorithm.
%
%   constraints  - a cell array of constraints represented by objects of
%                  class constr
%   varsind      - indices of variables used and variables with single
%                  occurrence in a constraint
%   allvars      - a vector of names of all variables
%   ix           - initial box of variable domains (cell array)
%   eps          - desired precision
%   ctr          - type of the contractor used
%   divparts     - number of parts to divide the box into
%   divside      - 'lf' divide by longest side,
%                - 'sf' divide by shortest side, 
%                - 'rr' round robin strategy
%
%   See also CSPSIVIA.

    St = stack;
    St.push(ix);
    
    [strf, rel, func, intvs] = cellfun(@(x)(deal(x.strconstr, x.rel, x.normfunc, x.normintv)), constraints, 'UniformOutput', false);
    
    % logical vectors indicating which constraints are satisfied
    StSat = stack;
    StSat.push(zeros(1, length(intvs)));
    
    rr = 0;
    
    % initialize result vectors
    dim = size(ix, 2);
    iS = ivect(dim);
    iN = ivect(dim);
    iB = ivect(dim);
    
    % choose a contractor function
    if strcmp(ctr, 'none')
        usectr = 0;
        constr = [];
    elseif strcmp(ctr, 'fbprop')
        ctrfun = @cspsiviahull;
        usectr = 1;
        constr = strf;
    elseif strcmp(ctr, 'boxnar')
        ctrfun = @cspsiviabox;
        usectr = 1;
        constr = {func, rel, ''};
    elseif strcmp(ctr, 'boxnarnewt')
        ctrfun = @cspsiviabox;
        usectr = 1;
        constr = {func, rel, strf, eps, 'newt'};
    elseif strcmp(ctr, 'comb')
        ctrfun = @cspsiviahullbox;
        usectr = 1;
        constr = {strf, func, rel, varsind{2}, eps};
    elseif strcmp(ctr, 'mohc')
        ctrfun = @cspsiviamohc;
        usectr = 1;
        constr = {strf, func, rel, varsind{2}, eps, allvars};
    else
        error('cspsiviactr:WrongValue', 'Incorrect contractor type: Choose none, fbprop (Forward-Backward), boxnar (BoxNarrow), boxnarnewt (BoxNarrow with interval Newton), mohc (Monotonic Hull Consistency) or comb (combined).');
    end

    while (~isempty(St))
        ix = St.pop();
        sat = StSat.pop();    % constraints already satisfied by ix
        % if a contractor is set, contract the box according to the constraints
        if (usectr)
            ixnew = ctrfun(constr, ix, varsind{1});
            if (any(cellfun(@isnan, ixnew)))
                iN.insert([ix{:}]);
                continue;
            else
               iN.insertset(boxdiff([ix{:}], [ixnew{:}]));
               ix = ixnew;
            end
        end
        % evaluate left sides (natural interval extesions) for ix
        v = varsind{1};
        sol = cellfun(@(f, vars)(feval(f, ix{vars})), func(sat == 0), v(sat == 0), 'UniformOutput', false);

        if any(cellfun(@emptyintersect, sol, intvs(sat == 0))) 
            % box contains no solutions
            iN.insert([ix{:}]);
        else
            j = 0;
            for i=1:length(sat)
                if ~sat(i)
                    j = j+1;
                    sat(i) = in(sol{j}, intvs{i});
                end
            end 
            if all(sat)
            % box with solutions only            
                if ~ismember([ix{:}], iS.items(), 'rows')
                    iS.insert([ix{:}]);
                end
            elseif (2*max(cellfun(@rad, ix)) < eps)   
                % box is undetermined, but too small
                    iB.insert([ix{:}]);
            else
            % divide box and use sivia on each part
                if strcmp(divside, 'rr') % update round robin index, if used
                    rr = mod(rr, length(ix)) + 1;
                    boxes = dividebox(ix, eps, divparts, rr);
                else
                    boxes = dividebox(ix, eps, divparts, divside);
                end
                for i=1:divparts,
                    St.push(boxes(i,:));
                    StSat.push(sat);
                end
            end
        end
    end
    
    % remove any trailing zeros from the results
    iS = iS.items();
    iN = iN.items();
    iB = iB.items();  
end